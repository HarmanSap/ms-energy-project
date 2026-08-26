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

// full dialog value help — omitting ValueListWithFixedValues gives the Search+Select dialog
annotate service.DCEPProjects with {
    phase_ID @(
        Common.Label          : 'Phase',
        Common.Text           : phase.name,
        Common.TextArrangement: #TextOnly,
        Common.ValueList      : {
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
