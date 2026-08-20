using EnergyService as service from '../../srv/service';

// ── List Report ───────────────────────────────────────────────────────────────

annotate service.EnergyProjects with @(
    UI.SelectionFields: [],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Project Name' }
    ]
);

// ── Object Page ───────────────────────────────────────────────────────────────

annotate service.EnergyProjects with @(
    UI.HeaderInfo: {
        TypeName      : 'Energy Project',
        TypeNamePlural: 'Energy Projects',
        Title         : { Value: name }
    },
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
                    Target: 'phases/@UI.LineItem'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'DCEPSection',
                    Label : 'DCEP Projects',
                    Target: 'dcepProjects/@UI.LineItem'
                }
            ]
        },
        // Tab 2 — placeholder
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ProjectDetailsTab',
            Label : 'Project & Location Details',
            Target: '@UI.FieldGroup#Placeholder'
        }
    ],
    UI.FieldGroup#Placeholder: {
        Data: [{ Value: name, Label: 'Project Name' }]
    }
);

// ── Phases table ──────────────────────────────────────────────────────────────

annotate service.Phases with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID,   Label: 'Phase ID'   },
        { $Type: 'UI.DataField', Value: name, Label: 'Phase Name' }
    ]
);

// ── DCEP Projects table with Phase dropdown ───────────────────────────────────

annotate service.DCEPProjects with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name,     Label: 'Project Name' },
        { $Type: 'UI.DataField', Value: type,     Label: 'Type'         },
        { $Type: 'UI.DataField', Value: phase_ID, Label: 'Phase'        }
    ]
);

annotate service.DCEPProjects with {
    phase    @(
        Common.Text           : phase.name,
        Common.TextArrangement: #TextOnly
    );
    phase_ID @(
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
