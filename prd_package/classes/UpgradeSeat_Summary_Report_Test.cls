@isTest
private class UpgradeSeat_Summary_Report_Test
{
	@isTest
	static void testSendSummary() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		Case myCase = MockupData_Test.createCase('01', 'New', 'CTI');
		myCase.Payment_Type__c = 'Mileage';
		myCase.Is_Upgrade_Seat_Case__c = true;
		insert myCase;

		Test.startTest();
		UpgradeSeat_Summary_Report report = new UpgradeSeat_Summary_Report();
		report.sendSummaryReport();
		Test.stopTest();
	}

	@isTest
	static void testSchedule() {
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		Test.startTest();
		String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new UpgradeSeat_Summary_Report_Schedulable());
         
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}