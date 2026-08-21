using ms.energy as my from '../db/schema';

// POC variant of the service — same data, plus an action that creates an
// ACTIVE Phase immediately (outside the draft) so it shows in the dropdown
// without a full page Save. App #1 (EnergyService) is untouched.
//
// The `phases` composition is EXCLUDED from this draft-enabled projection on
// purpose: a draft owns its compositions and rewrites them on Save, which would
// delete any phase added mid-edit. By exposing phases only through the
// `activePhases` association (read) + the addPhase action (write), an added
// phase is never part of the draft, so it survives Save in BOTH display and
// edit mode. dcepProjects stays a composition (edited inside the draft).
service EnergyServicePOC @(path: '/odata/v4/energy-poc') {

    @odata.draft.enabled
    entity EnergyProjects as projection on my.EnergyProject excluding { phases } actions {
        action addPhase(name: String);
    };

    entity Phases       as projection on my.Phase;
    entity DCEPProjects as projection on my.DCEPProject;
}
