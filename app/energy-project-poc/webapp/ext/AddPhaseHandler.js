sap.ui.define([], function () {
    "use strict";

    // Press handler for the "Add Phase" button on the Phases table toolbar.
    // Just runs the addPhase action - FE handles the name dialog and refresh.
    return {
        onAddPhase: function (oContext) {
            return this.getEditFlow().invokeAction("EnergyServicePOC.addPhase", {
                contexts: oContext,
                label: "Add Phase"
            });
        }
    };
});
