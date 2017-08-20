@isTest
private class PassengerListControllerTest {
	
	@isTest static void testGetPassengerList() {
		Flight__c flight = MockupData_Test.createFlight('TG123', '2017-03-27', 1);
		flight.Aircraft_Configuration__c = 'C20 Y300';
		flight.Departure_STN__c = 'HKG';
		insert flight;

		List<Passenger__c> passengersForInsert = new List<Passenger__c>();
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'C');
		passenger.Sector__c = 'BKK-HKG';
		passenger.SSR__c = true;
		passenger.SSR_Service__c = 'MAAS CIP';
		passenger.VIP_VVIP_Flag__c = true;
		passenger.Infant__c = true;
		passenger.Special_Meal__c = 'VGML';
		passenger.Date_of_Birth_Input__c = Date.today();
		passengersForInsert.add(passenger);
		insert passengersForInsert;
		List<PassengerListController.PassengerView> passengerList = PassengerListController.getPassengerList(flight.Id);
		Assert.assertEquals(passengersForInsert.size(), passengerList.size());
	}
}