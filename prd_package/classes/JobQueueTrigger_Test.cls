@isTest
public class JobQueueTrigger_Test {
	@testSetup static void setup() {

	}

	@isTest
	static void test() {
		Flight__c flight = MockupData_Test.createFlight('TG0916', '2017-03-30', 1);
		insert flight;

		Job_Queue__c jobQueue = new Job_Queue__c();
		jobQueue.Job_Name__c = 'JobName';
		jobQueue.Class_Name__c = 'PreFlightBatchScheduler';
		jobQueue.Manual_Run__c = true;
		jobQueue.Parameter__c = '{"flightMaster":"TG0916_30Mar17","flightId":"a0IN0000004tXAgMAM","flightDate":"2017-03-30","flightNumber":"TG0916", "flightLeg":"1"}';
		jobQueue.Schedule_Time__c = System.now();
		Test.startTest();
		insert jobQueue;
		Test.stopTest();

		List<Job_Queue__c> actualJobQueues = [SELECT Id, Manual_Run__c FROM Job_Queue__c];
		Assert.assertEquals(1, actualJobQueues.size());
		Assert.assertEquals(false, actualJobQueues.get(0).Manual_Run__c);
	}

}