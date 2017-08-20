@isTest
private class ROPEnrollment_Success_Report_Test {

	@isTest
	static void testSendSummaryReport() {
		ROP_Enrollment__c ropEnrollment = new ROP_Enrollment__c();
		ropEnrollment.Enrollment_Date__c = System.today().addDays(-1);
		ropEnrollment.Enrollment_Type__c = 'Web Service';
		ropEnrollment.Integration_Error__c = false;
		ropEnrollment.Status__c = 'Enroll';
		insert ropEnrollment;

		ROPEnrollment_Success_Report report = new ROPEnrollment_Success_Report();
		report.sendSummaryReport();

		Assert.assertEquals(1, report.ropEnrollments.size());
	}

	@isTest
	static void testSchedule() {
		String CRON_EXP = '0 0 0 15 3 ? 2022';
		Test.startTest();
		String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new ROPEnrollment_Success_Report_Schedulable());
         
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
		Test.stopTest();
	}
}