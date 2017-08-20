@isTest
private class ROPEnrollment_Manual_Queueable_Test {
	@isTest
	static void test() {
		ROP_Enrollment__c ropEnrollment = new ROP_Enrollment__c();
		insert ropEnrollment;

		Id jobId;
		Test.startTest();
		jobId = ROPEnrollment_Manual_Queueable.process(ropEnrollment.Id);
		Test.stopTest();
		//Assert.assertNotEquals(null, jobId);
	}
}