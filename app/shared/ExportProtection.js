// Shared export helper — call setup() from onInit in any FE V4 List Report controller extension.
//
// Uses sap.ui.export.Spreadsheet (https://ui5.sap.com/#/api/sap.ui.export.Spreadsheet)
// and JSZip 3.x which SAP already bundles at sap/ui/export/js/libs/JSZip3 (https://stuk.github.io/jszip/).
// No extra libraries needed. JSZip registers on window.JSZip3 (AMD is disabled on that bundle).
//
// xlsx is just a zip of XML files (ECMA-376: https://ecma-international.org/publications-and-standards/standards/ecma-376/).
// We modify sheet1.xml to add sheet protection, and styles.xml to mark editable columns as unlocked.
// All xlsx cells are locked by default — protection just has no effect until <sheetProtection> is present,
// so we have to unlock the editable columns explicitly. There's no "lock only column B" shortcut.
sap.ui.define(["sap/ui/export/Spreadsheet"], function (Spreadsheet) {
    "use strict";

    // FE V4 gives us column properties as arrays like ['type'] instead of plain strings
    // this just builds a simple lookup so we know which Excel letter each property maps to
    function _buildColumnMap(aColumns) {
        var map = {};
        aColumns.forEach(function (oCol, i) {
            var props = Array.isArray(oCol.property) ? oCol.property : [oCol.property];
            props.forEach(function (p) {
                if (p) { map[p] = String.fromCharCode(65 + i); }
            });
        });
        return map;
    }

    // when a sheet is protected, Excel locks every cell by default
    // so we need to explicitly mark the editable columns as "unlocked"
    // this adds a new style entry in styles.xml for that purpose
    function _addUnlockedStyle(stylesXml) {
        // count= on cellXfs tells us the index our new style will get
        var m = stylesXml.match(/(<cellXfs[^>]*count=")(\d+)(")/);
        var idx = m ? parseInt(m[2]) : 0;
        var newXf = '<xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0" applyProtection="1">'
            + '<protection locked="0" hidden="0"/></xf>';
        stylesXml = stylesXml.replace("</cellXfs>", newXf + "</cellXfs>");
        if (m) { stylesXml = stylesXml.replace(m[0], m[1] + (idx + 1) + m[3]); }
        return { stylesXml: stylesXml, unlockedIdx: idx };
    }

    // goes through every cell in the sheet and stamps the "unlocked" style on it
    // locked columns are left alone — they stay locked once sheet protection kicks in
    function _applyUnlockedCells(sheetXml, aLockedLetters, unlockedIdx) {
        var lockedSet = {};
        aLockedLetters.forEach(function (l) { lockedSet[l] = true; });

        return sheetXml.replace(
            /<c r="([A-Z]+)(\d+)"([^>]*)>/g,
            function (match, col, row, rest) {
                if (lockedSet[col]) { return match; }
                var cleanRest = rest.replace(/\s+s="\d+"/, "");
                return '<c r="' + col + row + '" s="' + unlockedIdx + '"' + cleanRest + ">";
            }
        );
    }

    // opens the xlsx (it's just a zip of xml files), applies our changes, zips it back up
    function _postProcess(arrayBuffer, oConfig, aColumns) {
        return new Promise(function (resolve, reject) {
            sap.ui.require(["sap/ui/export/js/libs/JSZip3"], function () {
                var JSZip = window.JSZip3;
                JSZip.loadAsync(arrayBuffer).then(function (zip) {
                    var sheetFile  = zip.file("xl/worksheets/sheet1.xml");
                    var stylesFile = zip.file("xl/styles.xml");
                    if (!sheetFile || !stylesFile) {
                        reject(new Error("[ExportProtection] xlsx ZIP missing expected files"));
                        return;
                    }
                    return Promise.all([sheetFile.async("string"), stylesFile.async("string")])
                        .then(function (res) {
                            var sheetXml   = res[0];
                            var stylesXml  = res[1];
                            var oColumnMap = _buildColumnMap(aColumns);

                            // lock the specified columns
                            var aLockedLetters = [];
                            if (oConfig.lockedProperties && oConfig.lockedProperties.length) {
                                oConfig.lockedProperties.forEach(function (prop) {
                                    if (oColumnMap[prop]) { aLockedLetters.push(oColumnMap[prop]); }
                                });

                                if (aLockedLetters.length) {
                                    var styled = _addUnlockedStyle(stylesXml);
                                    stylesXml = styled.stylesXml;
                                    sheetXml  = _applyUnlockedCells(sheetXml, aLockedLetters, styled.unlockedIdx);
                                    sheetXml  = sheetXml.replace(
                                        "</sheetData>",
                                        '</sheetData><sheetProtection sheet="1" selectLockedCells="0" selectUnlockedCells="0"/>'
                                    );
                                }
                            }

                            zip.file("xl/worksheets/sheet1.xml", sheetXml);
                            zip.file("xl/styles.xml", stylesXml);
                            return zip.generateAsync({ type: "uint8array" });
                        });
            }).then(function (bytes) {
                resolve(new Blob([bytes], {
                    type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                }));
            }).catch(reject);
            });
        });
    }

    return {
        // call this from onInit in your controller extension
        // oConfig = { entityName, lockedProperties }
        setup: function (oView, oConfig) {
            var tableId = "fe::table::" + oConfig.entityName + "::LineItem";

            oView.attachEventOnce("afterRendering", function () {
                var oTable = oView.byId(tableId);
                if (!oTable) {
                    console.warn("[ExportProtection] Table not found:", tableId);
                    return;
                }

                // intercept the standard Export button before SAP handles it
                oTable.attachBeforeExport(function (oEvent) {
                    oEvent.preventDefault();
                    var mSettings = oEvent.getParameter("exportSettings");
                    var aColumns  = mSettings && mSettings.workbook && mSettings.workbook.columns || [];

                    var oSpreadsheet = new Spreadsheet(mSettings);

                    // grab the file just before it would download, modify it, then save ourselves
                    oSpreadsheet.attachBeforeSave(function (oSaveEvent) {
                        oSaveEvent.preventDefault();
                        var arrayBuffer = oSaveEvent.getParameter("data");
                        var oDialog     = oSaveEvent.getParameter("exportDialog");
                        var fileName    = (mSettings.fileName || "Export") + ".xlsx";

                        var cleanup = function () {
                            try {
                                if (oDialog && typeof oDialog.destroy === "function") {
                                    oDialog.close();
                                    oDialog.destroy();
                                }
                            } catch (e) { /* ignore */ }
                            try { oSpreadsheet.destroy(); } catch (e) { /* ignore */ }
                        };

                        _postProcess(arrayBuffer, oConfig, aColumns)
                            .then(function (blob) {
                                var a = document.createElement("a");
                                a.href = URL.createObjectURL(blob);
                                a.download = fileName;
                                document.body.appendChild(a);
                                a.click();
                                document.body.removeChild(a);
                                URL.revokeObjectURL(a.href);
                                cleanup();
                            })
                            .catch(function (err) {
                                console.error("[ExportProtection] post-processing failed:", err);
                                cleanup();
                            });
                    });

                    oSpreadsheet.build();
                });
            });
        }
    };

    // ── future features (not needed yet) ──────────────────────────────────────

    // freeze header — will freeze row 1 so header stays visible while scrolling
    // function _applyFreezeHeader(sheetXml) {
    //     var freeze = '<pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/>';
    //     return sheetXml.replace(/(<sheetView[^>]*>)/, "$1" + freeze);
    // }
    // usage: if (oConfig.freezeHeader) { sheetXml = _applyFreezeHeader(sheetXml); }

    // data validation — will restrict a column to a dropdown list of allowed values
    // function _buildDataValidationXml(oConfig, oColumnMap) {
    //     var aDv = oConfig.dataValidation;
    //     if (!aDv || !aDv.length) { return ""; }
    //     var validEntries = aDv.filter(function (d) { return oColumnMap[d.property]; });
    //     if (!validEntries.length) { return ""; }
    //     var result = '<dataValidations count="' + validEntries.length + '">';
    //     validEntries.forEach(function (oDv) {
    //         var letter = oColumnMap[oDv.property];
    //         var formula = '"' + oDv.values.join(",") + '"';
    //         result += '<dataValidation type="list" allowBlank="1"'
    //             + ' showInputMessage="1" showErrorMessage="1"'
    //             + ' sqref="' + letter + '2:' + letter + '1048576">'
    //             + '<formula1>' + formula + '</formula1>'
    //             + '</dataValidation>';
    //     });
    //     return result + '</dataValidations>';
    // }
    // usage: var dvXml = _buildDataValidationXml(oConfig, oColumnMap);
    //        if (dvXml) { sheetXml = sheetXml.replace("</sheetData>", "</sheetData>" + dvXml); }

});
