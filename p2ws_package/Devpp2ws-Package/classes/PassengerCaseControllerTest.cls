@isTest
private class PassengerCaseControllerTest {
	
	@isTest static void testConstructor() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_GROUP_MEMBER_TRIGGER, false);

		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;

		List<Passenger__c> passengerList = new List<Passenger__c>();
		passengerList.addAll(MockupData_Test.createAcceptedPassengers(10, flight.Id, 'Y', 'BKK-HKG'));
		insert passengerList;

		List<Case> caseList = new List<Case>();
		caseList.add(new Case(FlightId__c = flight.Id, PassengerId__c = passengerList.get(0).Id));
		insert caseList;

		ApexPages.currentPage().getParameters().put('id', flight.Id);
		ApexPages.StandardController stdCaseController = new ApexPages.StandardController(flight);
		PassengerCaseController ctrl = new PassengerCaseController(stdCaseController);

		Assert.assertEquals(caseList.size(), ctrl.caseList.size());
		Assert.assert(ctrl.hasNext != null);
		Assert.assert(ctrl.hasPrevious != null);
		ctrl.next();
		ctrl.previous();
		Assert.assert(ctrl.pageNumber != null);
	}
	
}