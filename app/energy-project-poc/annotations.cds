using EnergyServicePOC as service from '../../srv/energy-poc-service';

// ── List Report ───────────────────────────────────────────────────────────────

annotate service.EnergyProjects with @(
    UI.SelectionFields: [],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Project Name' }
    ]
);

// ── DCEP Projects table: read/update only (no create) ───────────────────────────

annotate service.EnergyProjects with @(
    Capabilities.NavigationRestrictions: {
        RestrictedProperties: [
            {
                NavigationProperty: dcepProjects,
                InsertRestrictions: { Insertable: false }
            }
        ]
    }
);

// ── "Add Phase" action → creates an ACTIVE phase, then refreshes the tables ──────

annotate service.EnergyProjects with actions {
    addPhase @(
        Common.SideEffects #AddPhase: {
            TargetEntities: [ activePhases, dcepProjects ]
        }
    );
};

// ── Object Page ───────────────────────────────────────────────────────────────

annotate service.EnergyProjects with @(
    UI.HeaderInfo: {
        TypeName      : 'Energy Project',
        TypeNamePlural: 'Energy Projects',
        Title         : { Value: name }
    },
    UI.Identification: [
        { $Type: 'UI.DataFieldForAction', Action: 'EnergyServicePOC.addPhase', Label: 'Add Phase' }
    ],
    UI.Facets: [
        // Tab 1 — Phases (default)
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'PhasesTab',
            Label : 'Phases',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'PhasesSection',
                    Label : 'Phases',
                    Target: 'activePhases/@UI.LineItem'
                }
            ]
        },
        // Tab 2 — Project & Location Details (now also holds the DCEP Projects table)
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'ProjectDetailsTab',
            Label : 'Project & Location Details',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ProjectDetailsSection',
                    Label : 'Project & Location Details',
                    Target: '@UI.FieldGroup#Placeholder'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'DCEPSection',
                    Label : 'DCEP Projects',
                    Target: 'dcepProjects/@UI.LineItem'
                }
            ]
        }
    ],
    UI.FieldGroup#Placeholder: {
        Data: [{ Value: name, Label: 'Project Name' }]
    }
);

// ── Phases table ──────────────────────────────────────────────────────────────

annotate service.Phases with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Phase Name' }
    ]
);

// Show the Phase name (never the UUID) wherever the key is rendered — including
// the DCEP Phase value-list dropdown items.
annotate service.Phases with {
    ID @(
        Common.Text           : name,
        Common.TextArrangement: #TextOnly
    );
};

// ── DCEP Projects table with Phase dropdown ───────────────────────────────────

annotate service.DCEPProjects with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name,     Label: 'Project Name' },
        { $Type: 'UI.DataField', Value: type,     Label: 'Type'         },
        { $Type: 'UI.DataField', Value: phase_ID, Label: 'Phase'        }
    ]
);

annotate service.DCEPProjects with {
    phase_ID @(
        Common.Text                    : phase.name,
        Common.TextArrangement         : #TextOnly,
        Common.ValueListWithFixedValues: true,
        Common.ValueList               : {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'Phases',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: phase_ID,
                    ValueListProperty: 'ID'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'name'
                }
            ]
        }
    );
};
