using EnergyServicePOC as service from '../../srv/energy-poc-service';

// list report
annotate service.EnergyProjects with @(
    UI.SelectionFields: [],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Project Name' }
    ]
);

// DCEP table is read/update only, no create
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

// "Add Phase" action - adds an active phase, then refreshes the tables
annotate service.EnergyProjects with actions {
    addPhase @(
        Common.SideEffects #AddPhase: {
            TargetEntities: [ activePhases, dcepProjects ]
        }
    );
};

// object page
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
        // phases tab (default)
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
        // project & location details tab (DCEP table lives here now)
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
        },
        // same DCEP table again, in its own section
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'DCEPTab',
            Label : 'DCEP Projects',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'DCEPSection2',
                    Label : 'DCEP Projects',
                    Target: 'dcepProjects/@UI.LineItem#Copy'
                }
            ]
        }
    ],
    UI.FieldGroup#Placeholder: {
        Data: [{ Value: name, Label: 'Project Name' }]
    }
);

// phases table
annotate service.Phases with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Phase Name' }
    ]
);

// show the phase name instead of the id (also used in the DCEP dropdown)
annotate service.Phases with {
    ID @(
        Common.Text           : name,
        Common.TextArrangement: #TextOnly
    );
};

// DCEP table with the phase dropdown
annotate service.DCEPProjects with @(
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name,     Label: 'Project Name' },
        { $Type: 'UI.DataField', Value: type,     Label: 'Type'         },
        { $Type: 'UI.DataField', Value: phase_ID, Label: 'Phase'        }
    ],
    // same columns, second qualifier so the 2nd section gets its own table id
    UI.LineItem #Copy: [
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
