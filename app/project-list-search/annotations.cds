using DCEPListService as service from '../../srv/dcep-list-service';

annotate service.DCEPProjects with @(
    UI.SelectionFields: [ name, type, phase_ID ],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: name,     Label: 'Project Name' },
        { $Type: 'UI.DataField', Value: type,     Label: 'Type'         },
        { $Type: 'UI.DataField', Value: phase_ID, Label: 'Phase'        }
    ]
);

annotate service.Phases with {
    ID @(
        Common.Text           : name,
        Common.TextArrangement: #TextOnly
    );
};

// dialog-style value help for Project Name (no ValueListWithFixedValues → popup with search + table)
annotate service.DCEPProjects with {
    name @(
        Common.Label    : 'Project Name',
        Common.ValueList: {
            $Type         : 'Common.ValueListType',
            CollectionPath: 'DCEPProjects',
            Parameters    : [
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: name,
                    ValueListProperty: 'name'
                },
                {
                    $Type            : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty: 'type'
                },
                {
                    $Type            : 'Common.ValueListParameterOut',
                    LocalDataProperty: phase_ID,
                    ValueListProperty: 'phase_ID'
                }
            ]
        }
    );
};

// dropdown selection (ValueListWithFixedValues gives a simple select instead of the dialog)
annotate service.DCEPProjects with {
    phase_ID @(
        Common.Label                   : 'Phase',
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
