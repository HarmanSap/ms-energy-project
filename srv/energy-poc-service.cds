using ms.energy as my from '../db/schema';

// same as the main service but phases are excluded from the draft —
// the draft would overwrite them on save, so we manage them via addPhase instead
service EnergyServicePOC @(path: '/odata/v4/energy-poc') {

    @odata.draft.enabled
    entity EnergyProjects as projection on my.EnergyProject excluding { phases } actions {
        action addPhase(name: String);
    };

    entity Phases       as projection on my.Phase;
    entity DCEPProjects as projection on my.DCEPProject;
}
