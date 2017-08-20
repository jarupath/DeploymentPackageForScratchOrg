@isTest
private class PassengerSectorPage_Test {
	@isTest
	static void test() {
		Flight__c flight = MockupData_Test.createFlight('TG123', '2017-03-27', 1);
		flight.Aircraft_Configuration__c = 'C20 Y300';
		flight.Departure_STN__c = 'HKG';
		insert flight;

		List<Passenger__c> passengersForInsert = new List<Passenger__c>();
		Passenger__c checkInPassenger = MockupData_Test.createPassenger(flight.Id, 'C');
		checkInPassenger.Checkin_Seat__c = 'A00';
		checkInPassenger.Sector__c = 'BKK-HKG';
		passengersForInsert.add(checkInPassenger);

		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'C');
		passenger.Sector__c = 'BKK-HKG';
		passengersForInsert.add(passenger);
		insert passengersForInsert;

		ApexPages.currentPage().getParameters().put('id', flight.Id);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(flight);
		PassengerSectorPage ctrl = new PassengerSectorPage(stdCtrl);
	}

	@isTest
	static void testAcceptedPercentageEqualsToZero() {
		Flight__c flight = MockupData_Test.createFlight('TG123', '2017-03-27', 1);
		flight.Aircraft_Configuration__c = 'C20 Y300';
		flight.Departure_STN__c = 'HKG';
		insert flight;

		List<Passenger__c> passengersForInsert = new List<Passenger__c>();
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'C');
		passenger.Sector__c = 'BKK-HKG';
		passengersForInsert.add(passenger);
		insert passengersForInsert;

		ApexPages.currentPage().getParameters().put('id', flight.Id);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(flight);
		PassengerSectorPage ctrl = new PassengerSectorPage(stdCtrl);
	}

	//@isTest
	//static void testBookingEqualsToTwoAndAcceptedEqualsToOne() {
	//	Flight__c flight = MockupData_Test.createFlight('TG XXX', '', 1);
	//	flight.Aircraft_Configuration__c = 'C20 Y300';
	//	flight.Departure_STN__c = 'HKG';
	//	insert flight;

	//	List<Passenger__c> passengersForInsert = new List<Passenger__c>();
	//	List<Passenger__c> bookingPassengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'BKK-HKG');
	//	passengersForInsert.addAll(bookingPassengers);

	//	Passenger__c acceptedPassenger = MockupData_Test.createPassenger(flight.Id, 'C');
	//	acceptedPassenger.Sector__c = 'BKK-HKG';
	//	acceptedPassenger.Checkin_Seat__c = 'A03';
	//	passengersForInsert.add(acceptedPassenger);

	//	insert passengersForInsert;

	//	ApexPages.currentPage().getParameters().put('id', flight.Id);

	//	ApexPages.StandardController stdCtrl = new ApexPages.StandardController(flight);
	//	PassengerSectorPage ctrl = new PassengerSectorPage(stdCtrl);
	//}

	@isTest
	static void testBookingEqualsToTwoAndAcceptedEqualsToOne() {
		Flight__c flight = MockupData_Test.createFlight('TG123', '2017-03-27', 1);
		flight.Aircraft_Configuration__c = 'C20 Y300';
		flight.Booking_Passengers__c = 'C5 Y5';
		flight.Departure_STN__c = 'HKG';
		flight.Routing__c = 'BKK-HKG-ICN';
		insert flight;

		List<Passenger__c> passengersForInsert = new List<Passenger__c>();
		List<Passenger__c> acceptedPassengers = MockupData_Test.createAcceptedPassengers(10, flight.Id, 'C', 'BKK-HKG');
		passengersForInsert.addAll(acceptedPassengers);

		Passenger__c bookingPassenger = MockupData_Test.createPassenger(flight.Id, 'C');
		bookingPassenger.Sector__c = 'BKK-HKG';
		bookingPassenger.Booking_Class__c = 'A03';
		passengersForInsert.add(bookingPassenger);

		insert passengersForInsert;

		ApexPages.currentPage().getParameters().put('id', flight.Id);

		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(flight);
		PassengerSectorPage ctrl = new PassengerSectorPage(stdCtrl);
	}
}