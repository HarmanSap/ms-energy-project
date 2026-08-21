sap.ui.define([], function () {
    "use strict";

    // Standalone press handler for the "Add Phase" button on the Phases table
    // toolbar (declared in manifest.json under the activePhases LineItem actions).
    //
    // Fiori Elements loads a manifest custom-action press handler as a PLAIN
    // module (not a controller extension), calls the method with
    // (oContext, aSelectedContexts), and binds `this` to the page ExtensionAPI.
    //
    // addPhase is bound to the root EnergyProjects, so we invoke it against the
    // page's own context (oContext = the current/root entity). FE shows the name
    // parameter dialog automatically. The Common.SideEffects #AddPhase annotation
    // on the action refreshes the Phases table + DCEP dropdown, so no explicit
    // refresh is needed here.
    return {
        onAddPhase: function (oContext) {
            return this.getEditFlow().invokeAction("EnergyServicePOC.addPhase", {
                contexts: oContext,
                label: "Add Phase"
            });
        }
    };
});
