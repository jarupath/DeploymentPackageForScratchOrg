@isTest
private class FlightTriggerTest {

	///* This function is used to test for the correction of flight name convertion */
	//@isTest static void testFlightName() {
	//	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	//	upsert flight Flight_External_ID__c;
	//	flight = [SELECT Id, Name FROM Flight__c WHERE Id =: flight.Id LIMIT 1];
	//	System.assertNotEquals(flight.Id, null);
	//	System.assertEquals('TG680 / 30SEP16', flight.Name);
	//}

	///* This function is used to test for insert flight with the existing aircraft - this function should make input flight lookup to the related aircraft */
	//@isTest static void testInsertFromFileExistingAircraft(){
	//	Flight__c flight1 = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
	//	Aircraft__c air = new Aircraft__c(Name='XXXX1', Aircraft_Type__c='A380', Aircraft_Registration__c='XXXX1');
	//	insert air;
	//	upsert flight1 Flight_External_ID__c;
	//	List<Aircraft__c> airlist = [select Id, Name from Aircraft__c where Name='XXXX1'];
	//	System.assertEquals(1, airlist.size());
	//	Flight__c temp = [select Id, Name, AircraftId__c from Flight__c where Flight_External_ID__c='TG0998_01Oct16_1'];
	//	System.assertEquals(air.Id, temp.AircraftId__c);

	//}

	///* This function is used to test for insert flight with non-existing aircraft - this function should create new aircraft and make input flight lookup to the related aircraft */
	//@isTest static void testInsertFromFileNewAircraft(){
	//	Flight__c flight1 = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
	//	upsert flight1 Flight_External_ID__c;
	//	List<Aircraft__c> airlist = [select Id, Name from Aircraft__c where Name='XXXX1'];
	//	System.assertEquals(1, airlist.size());
	//	Flight__c temp = [select Id, Name, AircraftId__c from Flight__c where Flight_External_ID__c='TG0998_01Oct16_1'];
	//	System.assertEquals(airlist.get(0).Id, temp.AircraftId__c);
	//}

	// This is used to test in upsert the existing flight with related aircraft and the existing flight didn't lookup to any aircraft scenario - 
	//	this function should update the existing flight information without create any new record 
	//@isTest static void testUpsertExistingFlightWithLookupAircraft(){
	//	Flight__c flight1 = MockupData_Test.createFlight('0998', '01Oct16', 1, '', '');
	//	upsert flight1 Flight_External_ID__c;
	//	System.debug('Flight1 External Id: ' + flight1.Flight_External_ID__c);
	//	Flight__c flight2 = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
	//	upsert flight2 Flight_External_ID__c;

	//	List<Aircraft__c> airlist = [select Id, Name from Aircraft__c where Name='XXXX1'];
	//	System.assertEquals(1, airlist.size());

	//	List<Flight__c> flight = [select Id from Flight__c where Flight_External_ID__c='TG0998_01Oct16_1'];
	//	System.assertEquals(1, flight.size());

	//	Flight__c temp = [select Id, Name, AircraftId__c from Flight__c where Flight_External_ID__c='TG0998_01Oct16_1'];
	//	System.assertEquals(airlist.get(0).Id, temp.AircraftId__c);
	//}

	///* This function is used to test for the correction of flight external Id */
	//@isTest static void testExternalIdCorrection(){
	//	Flight__c flight1 = MockupData_Test.createFlight('0998', '01Oct16', 1);
	//	upsert flight1 Flight_External_ID__c;
	//	Flight__c flight = [select Id, Flight_External_ID__c from Flight__c where Flight_External_ID__c='TG0998_01Oct16_1'];
	//	System.assertNotEquals(null, flight);
	//}

	//@isTest static void testInsertFromFileWithDupplicateAircraft(){
	//	List<Flight__c> flightList = new List<Flight__c>();
	//	flightList.add(MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380'));
	//	flightList.add(MockupData_Test.createFlight('0999', '02Oct16', 1, 'XXXX1', 'A380'));
	//	upsert flightList Flight_External_ID__c;

	//	List<Aircraft__c> airList = [SELECT Id, Name FROM Aircraft__c WHERE Name = 'XXXX1'];
	//	System.assertEquals(1, airList.size()); 
	//}

	@isTest static void testUpdateFlightInformationShouldReturnCorrectInfoOfDateTime(){
		List<Flight__c> flightList = new List<Flight__c>();
		flightList.add(MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380'));
		upsert flightList Flight_External_ID__c;
		System.debug('input flight1: ' + flightList);
		Flight__c f = MockupData_Test.createFlight('0998', '2016-10-01', 1, 'XXXX1', 'A380');
		upsert f Flight_External_ID__c;
		System.debug('input flight1: ' + f);
		System.debug([SELECT Id, Name, Flight_Date_UTC__c, Flight_Date_LT__c, STD_UTC__c, STD_LT__c FROM Flight__c WHERE Id = :f.Id]);
	}

	/* This function is used to test in case that flight is changed and the changed that populate a new flight, 
		flight trigger should detected the change and query new flight according to the information from the original flight  */
	//@isTest static void testQueryChangedWhenDetected(){
	//	List<Flight__c> flightList = new List<Flight__c>();
	//	flightList.add(MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380'));
	//	System.debug('Flight Mock: ' + flightList.get(0));
	//	flightList.get(0).Change_Flight_Number__c = 'TG9989';
	//	flightList.get(0).Change_Flight_Date_UTC__c = '03Oct16';
	//	flightList.get(0).Flight_Number__c = 'TG0998';
	//	upsert flightList Flight_External_ID__c;
	//}
}