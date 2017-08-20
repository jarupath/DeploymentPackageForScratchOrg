@isTest
private class ApplicationLog_Purge_Schedulable_Test {
	@isTest
	static void testPurgeApplicationLog() {
		List<Application_Log__c> logsForInsert = new List<Application_Log__c>();

		Application_Log__c log1 = new Application_Log__c();
		log1.Source__c = 'source1';
		log1.Source_Function__c = 'sourceFunction1';
		logsForInsert.add(log1);

		Application_Log__c log2 = new Application_Log__c();
		log2.Source__c = 'source2';
		log2.Source_Function__c = 'sourceFunction2';
		logsForInsert.add(log2);

		insert logsForInsert;

		Datetime pastDate = Datetime.now().addMonths(-5);
		Test.setCreatedDate(log1.Id, pastDate);

		Test.startTest();
		String cronDateTime = BE8_DateUtility.getExactCRONFromDateTime(System.now().addSeconds(2));
		System.schedule('testJobName', cronDateTime, new ApplicationLog_Purge_Schedulable(3));
		Test.stopTest();

		List<Application_Log__c> actualLogs = [SELECT Id FROM Application_Log__c];
		//Assert.assertEquals(1, actualLogs.size());
	}
}