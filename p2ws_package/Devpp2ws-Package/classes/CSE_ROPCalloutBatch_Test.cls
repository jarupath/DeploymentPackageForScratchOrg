@isTest
private class CSE_ROPCalloutBatch_Test {
	@isTest
	static void test() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;

		Account account = MockupData_Test.createAccount('AccountName');
		account.First_Name__c = 'A';
		account.Last_Name__c = 'B';
		account.Date_of_Birth__c = Date.today();
		insert account;

		Passenger__c passenger = new Passenger__c(FlightId__c = flight.Id , Name = 'ALAN NEAL', First_Name__c = 'ALAN', Last_Name__c = 'NEAL', Date_of_Birth_Input__c = Date.valueOf('1942-02-06'), FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Number__c = 'NY67945', AccountId__c = account.Id);
		insert passenger;
		System.debug('passenger: ' + passenger);

		Membership__c memberShip = MockupData_Test.createMembership();
		memberShip.AccountId__c = account.Id;
		memberShip.Name = 'NY67945';
		memberShip.EXTMember__c = 'TG_NY67945';
		memberShip.Status__c = 'Active';
		membership.Expiry_Date__c = Date.today().addDays(365);
		insert memberShip;

		SingleRequestMock fakeROPMileageResp = Mock_CSE_ROP_Response.getCurrentMileage();
		SingleRequestMock fakeROPResp = Mock_CSE_ROP_Response.getROPProfile();
		SingleRequestMock fakeAdditionalProfile = Mock_CSE_ROP_Response.getAdditionalProfile();

		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String, HttpCalloutMock>();
		endpoint2TestResp.put(Mock_CSE_ROP_Response.getCurrentMileageEndPoint(), fakeROPMileageResp);
		endpoint2TestResp.put(Mock_CSE_ROP_Response.getROPProfileEndPoint(), fakeROPResp);
		endpoint2TestResp.put(Mock_CSE_ROP_Response.getAdditionalProfileEndPoint(), fakeAdditionalProfile);

		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
		Test.setMock(HttpCalloutMock.class, multiCalloutMock);

		Test.startTest();
		Database.executeBatch(new CSE_ROPCalloutBatch(new Set<Id> {flight.Id}));
		Test.stopTest();

		List<Account> actualAccounts = [SELECT Id, Email_1__c, ROP_Email_1__c, First_Name__c, Last_Name__c FROM Account];
		System.debug('---------SELECT ACCOUNT-------');
		System.debug(actualAccounts);
		Assert.assertEquals(1, actualAccounts.size());
		Account actualAccount = actualAccounts.get(0);
		Assert.assertEquals('test@beryl8.com', actualAccount.Email_1__c);
		Assert.assertEquals('test@beryl8.com', actualAccount.ROP_Email_1__c);
		Assert.assertEquals('ALAN', actualAccount.First_Name__c);
		Assert.assertEquals('NEAL', actualAccount.Last_Name__c);

	}

	@isTest static void testFindExistingROPAndAccount(){
		CSE_ROPCalloutBatch ropBatch = new CSE_ROPCalloutBatch(new List<String>{'TG12345'});
		ropBatch.findExistingROPAndAccount(new List<String>{'TG12345'});
	}

	//@isTest static void testGetStringDate(){
	//	CSE_ROPCalloutBatch ropBatch = new CSE_ROPCalloutBatch(new List<String>{'TG12345'});
	//	String dateNull = ropBatch.getStringDate(null);
	//	String dateNotNull = ropBatch.getStringDate(Date.valueOf('2050-06-01'));
	//}


}