@isTest
private class JobQueueServiceTest {
	
	@isTest static void testScheduleJob() {
		Job_Queue__c jq = new Job_Queue__c();
		JobQueueService.scheduleJob('TEST', MockupData_Test.TEST_CRON, new PreFlightBatchScheduler('TG123','TG123', Date.today(), 'UTC', 1), jq);
	}

	@isTest static void testEnqueueJob() {
		Map<String, Object> parameter = new Map<String, Object> {
			'flightNumber' => '1234',
			'flightDate' => Date.today()
		};
		Job_Queue__c jobQueue = new Job_Queue__c(Class_Name__c = 'PreFlightBatchScheduler', Schedule_Time__c = DateTime.now(), Parameter__c = System.json.serialize(parameter), Job_Name__c = 'TEST', Reference_Id__c = '');
		insert jobQueue;
		JobQueueService.enqueueJob();
	}

	@isTest static void testDeleteOutdatedScheduledJob(){
		JobQueueService.deleteOutdatedScheduledJob();
	}

	@isTest static void testJobQueueWrapper(){
		JobQueueService.JobQueueWrapper jq1 = new JobQueueService.JobQueueWrapper(new Job_Queue__c(Class_Name__c = 'PreFlightBatchScheduler', Schedule_Time__c = DateTime.now(), Job_Name__c = 'TEST', Reference_Id__c = ''));
		JobQueueService.JobQueueWrapper jq2 = new JobQueueService.JobQueueWrapper(new Job_Queue__c(Class_Name__c = 'PreFlightBatchScheduler', Schedule_Time__c = DateTime.now().addHours(1), Job_Name__c = 'TEST', Reference_Id__c = ''));
		System.assertEquals(-1, jq1.compareTo(jq2));
	}
	
}