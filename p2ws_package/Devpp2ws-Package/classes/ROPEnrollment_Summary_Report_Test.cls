@isTest
private class ROPEnrollment_Summary_Report_Test
{
	@isTest
	static void testSendSummary() {
		ROP_Enrollment__c ropEnrollment = new ROP_Enrollment__c();
		ropEnrollment.Status__c = 'Enroll';
		ropEnrollment.Enrollment_Date__c = System.today().addDays(-1);
		insert ropEnrollment;

		Test.startTest();
		ROPEnrollment_Summary_Report report = new ROPEnrollment_Summary_Report();
		report.sendSummaryReport();
		Test.stopTest();
	}

	@isTest
	static void testSchedule() {
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		Test.startTest();
		String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ROPEnrollment_Summary_Report_Schedulable());
         
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}