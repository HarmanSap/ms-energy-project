using EnergyService as service from '../../srv/service';

// list report
annotate service.EnergyProjects with @(
    UI.SelectionFields: [],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name, Label: 'Project Name' }
    ]
);

// let users add rows to the sub-tables; refresh DCEP when a phase is added
annotate service.EnergyProjects with @(
    Capabilities.NavigationRestrictions: {
        RestrictedProperties: [
            {
                NavigationProperty: phases,
                InsertRestrictions: { Insertable: true }
            },
            {
                NavigationProperty: dcepProjects,
                InsertRestrictions: { Insertable: true }
            }
        ]
    },
    Common.SideEffects #PhasesChanged: {
        SourceEntities: [{ $NavigationPropertyPath: 'phases' }],
        TargetEntities: [{ $NavigationPropertyPath: 'dcepProjects' }]
    }
);

// object page
annotate service.EnergyProjects with @(
    UI.HeaderInfo: {
        TypeName      : 'Energy Project',
        TypeNamePlural: 'Energy Projects',
        Title         : { Value: name }
    },
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
                    Label : 'Phases(Inline)',
                    Target: 'phases/@UI.LineItem'
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
