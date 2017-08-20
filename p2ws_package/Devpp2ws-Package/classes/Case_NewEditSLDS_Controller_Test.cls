@isTest
private class Case_NewEditSLDS_Controller_Test{
    @testSetup static void setUp() {
        MockupData_Test.initializeSystemConfigurationCustomSetting();
    }

	@isTest
	static void testEditCase() {
		MockupData_Test.insertMockUpEquipment();

        Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
        insert flight;

        Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'Maintenance');
        newCase.Flightid__c = flight.Id;
        insert newCase;

        ApexPages.currentPage().getParameters().put('flightId', flight.Id);
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(newCase);
        Case_NewEditSLDS_Controller ctrl = new Case_NewEditSLDS_Controller(stdCtrl);

        List<Schema.FieldSet> fieldSets = ctrl.getFieldSets();
        Assert.assertEquals(5, fieldSets.size());

        String jsonCGMs = ctrl.getJSONCaseGroupMembers();
        Assert.assertEquals('[]', jsonCGMs);

        String jsonEquipment = ctrl.getJSONEquipmentValue();
        //String expectJson = '[ {';
        //expectJson += '  "label" : "GALLEY AREA",';
        //expectJson += '  "value" : "a0LN0000006OHJnMAO"';
        //expectJson += '}, {';
        //expectJson += '  "label" : "LAVATORY (TOILET)",';
        //expectJson += '  "value" : "a0LN0000006OHJoMAO"';
        //expectJson += '}, {';
        //expectJson += '  "label" : "PASSENGER SEAT",';
        //expectJson += '  "value" : "a0LN0000006OHJpMAO"';
        //expectJson += '} ]';
        //Assert.assertEquals('[ {"label" : "GALLEY AREA","value" : "a0LN0000006OHJnMAO"}, {"label" : "LAVATORY (TOILET)","value" : "a0LN0000006OHJoMAO"}, {"label" : "PASSENGER SEAT","value" : "a0LN0000006OHJpMAO"} ]', jsonEquipment);
        Assert.assert(jsonEquipment.contains('GALLEY AREA'), 'GALLEY AREA should be included in equipment list');
        Assert.assert(jsonEquipment.contains('LAVATORY (TOILET)'), 'LAVATORY (TOILET) should be included in equipment list');
        Assert.assert(jsonEquipment.contains('PASSENGER SEAT'), 'PASSENGER SEAT should be included in equipment list');
	}
}