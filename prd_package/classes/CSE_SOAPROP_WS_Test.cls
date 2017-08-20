@isTest
private class CSE_SOAPROP_WS_Test {
	@isTest static void testGetROPProfile() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockROPMemberWSResponseGenerator());
		Test.startTest();
		WS_ROPProfileModel ropProfile = new CSE_SOAPROP_WS().getROPProfile('QW36598');

		System.assertEquals(null, ropProfile);
		//System.assertEquals('ZZ99999', ropProfile.MemberProfileRS.MemberID);
		Test.stopTest();
	}
}