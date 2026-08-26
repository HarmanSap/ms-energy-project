using ms.energy as my from '../db/schema';

service DCEPListService @(path: '/odata/v4/dcep-list') {

    @readonly
    entity DCEPProjects as projection on my.DCEPProject;

    @readonly
    entity Phases as projection on my.Phase;
}
