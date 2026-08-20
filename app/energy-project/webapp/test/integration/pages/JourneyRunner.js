sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"energyproject/test/integration/pages/EnergyProjectsList",
	"energyproject/test/integration/pages/EnergyProjectsObjectPage"
], function (JourneyRunner, EnergyProjectsList, EnergyProjectsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('energyproject') + '/test/flp.html#app-preview',
        pages: {
			onTheEnergyProjectsList: EnergyProjectsList,
			onTheEnergyProjectsObjectPage: EnergyProjectsObjectPage
        },
        async: true
    });

    return runner;
});

