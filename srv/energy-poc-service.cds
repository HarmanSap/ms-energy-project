using ms.energy as my from '../db/schema';

// POC variant of the service — same data, plus an action that creates an
// ACTIVE Phase immediately (outside the draft) so it shows in the dropdown
// without a full page Save. App #1 (EnergyService) is untouched.
service EnergyServicePOC @(path: '/odata/v4/energy-poc') {

    @odata.draft.enabled
    entity EnergyProjects as projection on my.EnergyProject actions {
        action addPhase(name: String);
    };

    entity Phases       as projection on my.Phase;
    entity DCEPProjects as projection on my.DCEPProject;
}
