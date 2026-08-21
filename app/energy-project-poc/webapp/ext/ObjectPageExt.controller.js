sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    // POC-only Object Page extension: after Save, re-enter Edit so the page
    // stays editable (matches the customer app). Phases are added through the
    // standard Fiori Elements Create button on the draft-enabled Phases table.
    return ControllerExtension.extend("energyprojectpoc.ext.ObjectPageExt", {

        override: {
            editFlow: {
                // After Save the page is back on the active document — re-enter edit
                // so the app stays editable (matches the customer app).
                onAfterSave: function (mParameters) {
                    var oContext = mParameters && mParameters.context;
                    if (oContext) {
                        this.base.getExtensionAPI().getEditFlow().editDocument(oContext);
                    }
                }
            }
        }
    });
});
