global class ClearScheduledJobBatch implements Database.Batchable<sObject> {

	//String query = 'SELECT Id FROM AsyncApexJob WHERE status!=\'Completed\' AND status!=\'Aborted\' AND status != \'Failed\' ';
	String query = 'SELECT Id FROM Job_Queue__c WHERE Scheduled__c = true AND Queued_Time__c = null';

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		//for (AsyncApexJob each : (List<AsyncApexJob>)scope) {
		//	System.abortJob(each.Id);
		//}

		delete scope;
	}

	global void finish(Database.BatchableContext BC) {

	}

}