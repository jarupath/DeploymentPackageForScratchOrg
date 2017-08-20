@isTest
private class MB_RESTUpgradeSeatTest {
	
	@isTest static void test_method_one() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;
		List<Passenger__c> passengerList = MockupData_Test.createBookingPassengers(10, flight.Id, 'Y', 'BKK-HKG');
		insert passengerList;

		Passenger__c testPassenger = passengerList[0];
		testPassenger.First_Name__c = 'GOODNAME MR';
		update testPassenger;
		testPassenger = [SELECT Id, Name, PaxKey__c FROM Passenger__c WHERE Id =: testPassenger.Id LIMIT 1];

		List<MB_RESTRequestInfoModel.upgradeSeat> upgradeSeatList = new List<MB_RESTRequestInfoModel.upgradeSeat>();
		MB_RESTRequestInfoModel.upgradeSeat upgradeSeat = new MB_RESTRequestInfoModel.upgradeSeat();
		upgradeSeat.toClass = 'C';
		upgradeSeat.toSeat = '22A';
		upgradeSeat.paxKey = testPassenger.PaxKey__c;
		upgradeSeat.fltId = flight.Id;
		upgradeSeat.paxId = testPassenger.Id;
		upgradeSeat.upCode = 'A027';
		upgradeSeat.payType = 'Mile';
		upgradeSeat.isVoided = 0;
		upgradeSeat.creDT = BE8_DateUtility.convertDateTimeToStringForMobileApp(System.now());
		upgradeSeatList.add(upgradeSeat);

		MB_RESTUpgradeSeat.upgradeSeat(upgradeSeatList);
	}
	
}