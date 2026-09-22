sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension",
    "shared/ExportProtection"
], function (ControllerExtension, ExportProtection) {
    "use strict";

    return ControllerExtension.extend("projectlistsearch.ext.ListReportExtController", {
        override: {
            onInit: function () {
                ExportProtection.setup(this.base.getView(), {
                    entityName       : "DCEPProjects",
                    lockedProperties : ["type"]
                });
            }
        }
    });
});
