@isTest
private class ClearScheduledJobBatch_Test
{
	@isTest
	static void test() {
		Job_Queue__c jobQueue = new Job_Queue__c();
		jobQueue.Scheduled__c = true;
		insert jobQueue;

		Test.startTest();
		Database.executeBatch(new ClearScheduledJobBatch());
		Test.stopTest();

		List<Job_Queue__c> jobQueues = [SELECT Id FROM Job_Queue__c];
		Assert.assertEquals(0, jobQueues.size());
	}
}