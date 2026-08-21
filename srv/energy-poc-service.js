const cds = require('@sap/cds');

// Handler for EnergyServicePOC (CAP picks it up by matching file name).
// addPhase adds an active phase for the current project so it shows up in the
// phase_ID dropdown right away.
module.exports = class EnergyServicePOC extends cds.ApplicationService {
    init() {
        // FE calls this on the draft while editing, so handle both the active
        // entity and the draft. Either way we insert an active phase (the draft
        // uses the same project ID).
        const addPhase = async (req) => {
            const projectID = req.params[req.params.length - 1]?.ID;
            await INSERT.into('ms.energy.Phase').entries({
                name: req.data.name,
                project_ID: projectID
            });
        };
        this.on('addPhase', 'EnergyProjects', addPhase);
        this.on('addPhase', 'EnergyProjects.drafts', addPhase);
        return super.init();
    }
};
