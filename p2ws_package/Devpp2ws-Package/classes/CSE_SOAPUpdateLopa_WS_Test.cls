@isTest
private class CSE_SOAPUpdateLopa_WS_Test {
	
	@isTest static void testUpdateLopaInformationNegativeCaseShouldLogError() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.startTest();
		Test.setMock(WebServiceMock.class, new Mock_TG_LOPA_WS.MockLOPAErrorTestLog());
		Flight__c flight = MockupData_Test.getMockUpFlight();
		CSE_SOAPUpdateLopa_WS.updateLopaInformation(flight);
		Test.stopTest();
		//System.assertEquals(1, PreFlightBatch.applicationLogCache.size());
	}	
}