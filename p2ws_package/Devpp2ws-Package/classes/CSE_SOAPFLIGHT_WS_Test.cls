@isTest
private class CSE_SOAPFLIGHT_WS_Test {
	
	@isTest static void testGetFlight() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockFlightWSResponseGenerator());
		Test.startTest();
		new CSE_SOAPFLIGHT_WS().getFlight('1234', Date.today(), 'UTC');
		Test.stopTest();
	}
	
}