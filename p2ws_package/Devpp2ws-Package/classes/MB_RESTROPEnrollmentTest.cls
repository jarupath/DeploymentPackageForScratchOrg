@isTest
private class MB_RESTROPEnrollmentTest {

	@isTest static void testEnrollROPNumberPositiveCase() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockROPEnrollmentWSFactory.MockROPEnrollmentWSSUCCESS());
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;
		List<Passenger__c> passengerList = MockupData_Test.createBookingPassengers(10, flight.Id, 'Y', 'BKK-HKG');
		insert passengerList;
		insert MockupData_Test.createROPNumberInventoryList(1000);

		List<MB_RestRequestInfoModel.ropEnrollment> ropEnrollmentList = new List<MB_RestRequestInfoModel.ropEnrollment>();
		List<ROP_Number_Inventory__c> ropNumberList = ROPEnrollmentService.getUnregisteredROPNumberList(100);
		for (Integer i = 0; i < passengerList.size() ; i++) {
			Passenger__c passenger = passengerList.get(i);
			ROP_Number_Inventory__c ropNumberObject = ropNumberList.get(i);
			String ropNumber = ropNumberObject.ROP_Number__c;
			ropEnrollmentList.add(MockupData_Test.createROPEnrollmentRequest(ropNumber, flight.Id, passenger.Id));
		}

		Test.startTest();
		List<MB_RestResponseInfoModel.ropEnrollment> result = MB_RESTROPEnrollment.enrollROPNumber(ropEnrollmentList);
		Test.stopTest();
		MB_RESTROPEnrollment.getROPEnrollment();
	}
}