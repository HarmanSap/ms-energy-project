sap.ui.define([], function () {
    "use strict";

    // runs the addPhase action; FE handles the popup and table refresh
    return {
        onAddPhase: function (oContext) {
            return this.getEditFlow().invokeAction("EnergyServicePOC.addPhase", {
                contexts: oContext,
                label: "Add Phase"
            });
        }
    };
});
