sap.ui.define([
    "sap/ui/core/mvc/ControllerExtension"
], function (ControllerExtension) {
    "use strict";

    // after saving, jump straight back into edit mode
    return ControllerExtension.extend("energyprojectpoc.ext.ObjectPageExt", {

        override: {
            editFlow: {
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
