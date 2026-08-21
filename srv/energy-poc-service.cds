using ms.energy as my from '../db/schema';

// POC version of the service. Same data, but with an addPhase action that
// creates an active phase right away so it shows up in the dropdown without
// saving the whole page.
//
// We exclude the phases composition on purpose: a draft owns its compositions
// and rewrites them on save, which would wipe out a phase added mid-edit.
// Instead phases are read through the activePhases association and written via
// addPhase, so they aren't part of the draft and survive save. dcepProjects
// stays a composition (still edited in the draft).
service EnergyServicePOC @(path: '/odata/v4/energy-poc') {

    @odata.draft.enabled
    entity EnergyProjects as projection on my.EnergyProject excluding { phases } actions {
        action addPhase(name: String);
    };

    entity Phases       as projection on my.Phase;
    entity DCEPProjects as projection on my.DCEPProject;
}
