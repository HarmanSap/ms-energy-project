const cds = require('@sap/cds');

module.exports = class EnergyServicePOC extends cds.ApplicationService {
    init() {
        // inserts an active phase so it shows up in the dropdown right away
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
