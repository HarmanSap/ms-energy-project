sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    // POC-only: after Save, go back into edit mode so the page stays editable.
    return ControllerExtension.extend("energyprojectpoc.ext.ObjectPageExt", {

        override: {
            editFlow: {
                // Save drops us back on the active doc, so re-open it for editing.
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
