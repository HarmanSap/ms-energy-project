namespace ms.energy;

entity EnergyProject {
    key ID          : UUID;
    name            : String(100);
    phases          : Composition of many Phase       on phases.project      = $self;
    dcepProjects    : Composition of many DCEPProject on dcepProjects.project = $self;
    // Read-only view of ACTIVE phases (association, not composition) — resolves to
    // active data even inside a draft. Used by the POC app's Phases table.
    activePhases    : Association to many Phase        on activePhases.project = $self;
}

entity Phase {
    key ID      : UUID;
    name        : String(100);
    project     : Association to EnergyProject;
}

entity DCEPProject {
    key ID      : UUID;
    name        : String(100);
    type        : String(100);
    project     : Association to EnergyProject;
    phase_ID    : UUID;
    phase       : Association to Phase on phase.ID = phase_ID;
}
