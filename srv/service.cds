using ms.energy as my from '../db/schema';

service EnergyService @(path: '/odata/v4/energy') {

    @odata.draft.enabled
    entity EnergyProjects as projection on my.EnergyProject;
    entity Phases          as projection on my.Phase;
    entity DCEPProjects    as projection on my.DCEPProject;
}
