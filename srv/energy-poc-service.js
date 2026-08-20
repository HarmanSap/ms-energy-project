const cds = require('@sap/cds');

// Handler for EnergyServicePOC (auto-loaded by CAP via matching file name).
// addPhase inserts an ACTIVE Phase linked to the current project, committed
// immediately — so it is visible to the phase_ID value list right away.
module.exports = class EnergyServicePOC extends cds.ApplicationService {
    init() {
        // FE calls the action on the DRAFT instance while editing, so register
        // for both the active entity and its draft shadow. Either way we insert
        // an ACTIVE Phase (the draft shares the active project's ID).
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
