@isTest
private class MD_CrewAppraisal_RestResource_Test {

	@testSetup
	static void setup() {
		MockupData_Test.initMDCrewAppraisal();
	}

	@isTest static void testSubmit() {
		MockupData_Test.initializeWebServiceCustomSetting();
		TriggerActivator.initializeTriggerActivation(true);

		//Test.setMock(WebServiceMock.class, new CrewAppraisal_WebServiceMock());
		Test.setMock(HttpCalloutMock.class, new CrewAppraisal_HttpCalloutMock());

		Flight__c flight = MockupData_Test.createFlight('0628', '04Feb17', 1);
		insert flight;

		//flight = [SELECT Id, Flight_External_ID__c FROM Flight__c WHERE Id = :flight.Id];

		List<Crew__c> crewsForInsert = new List<Crew__c>();
		Crew__c crew1 = MockupData_Test.createCrew('FirstName', 'LastName', '29800', 'IM');
		Crew__c crew2 = MockupData_Test.createCrew('FirstName', 'LastName', '37792', 'IM');
		insert crewsForInsert;

		List<Crew_List__c> crewListsForInsert = new List<Crew_List__c>();
		Crew_List__c crewList1 = MockupData_Test.createCrewList('crewListName', flight.Flight_External_ID__c, crew1.Personel_Id__c, crew1.Personel_Id__c + '_' + flight.Flight_External_ID__c);
		Crew_List__c crewList2 = MockupData_Test.createCrewList('crewListName', flight.Flight_External_ID__c, crew2.Personel_Id__c, crew2.Personel_Id__c + '_' + flight.Flight_External_ID__c);
		crewListsForInsert.add(crewList1);
		crewListsForInsert.add(crewList2);
		insert crewListsForInsert;

		List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers = new List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer>();
		String formNum = '02';
		String flightExternalId = 'TG0628_04Feb17_1';
		String staffNum = '29800';
		String evaStaffNum = '37792';
		MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer = MockupData_Test.createCrewAppraisalAnswer(formNum, flightExternalId, evaStaffNum, staffNum);
		answers.add(answer);
		Test.startTest();
		List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> resultAnswers = MD_CrewAppraisal_RestResource.submitAnswers(answers);
		Test.stopTest();
	}
}