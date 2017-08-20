@isTest
private class MB_RESTTopCaseInFlightTest {
	@isTest static void testGetTopCase() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);

		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.STD_UTC__c = String.valueOf(DateTime.now());
		flight.STA_UTC__c = String.valueOf(DateTime.now().addHours(10));
		insert flight;
		Crew__c crew = new Crew__c (Crew_First_Name__c = 'TEST', Personel_Id__c = 'TEST');
		insert crew;
		Crew_List__c crewList = new Crew_List__c(CrewId__c = crew.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = crew.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		passenger.FlightId__c = flight.Id;
		insert passenger;
		Case newCase = new Case();
		newCase.FlightId__c = flight.Id;
		newCase.PassengerId__c = passenger.Id;
		newCase.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_IN_FLIGHT);
		insert newCase;
		CTI__c cti = new CTI__c();
		cti.Flightid__c = flight.Id;
		cti.CaseId__c = newCase.Id;
		cti.Type_of_Issue__c = 'Complaint';
		cti.Type__c = 'Attitude and Care of Cabin Crew';
		insert cti;
		List<MB_RESTTopCaseInFlight.TopCase> result = MB_RESTTopCaseInFlight.getTopCase();
		Assert.assertEquals(1, result.size());
	}
}