global class ApplicationLog_Purge_Batch implements Database.Batchable<sObject> {
	
	String query;
	Integer lastNMonths;
	
	global ApplicationLog_Purge_Batch() {
		this.lastNMonths = 3;	
	}

	global ApplicationLog_Purge_Batch(Integer lastNMonths) {
		this.lastNMonths = lastNMonths;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		query = 'SELECT Id, CreatedDate FROM Application_Log__c WHERE CreatedDate < LAST_N_MONTHS:' + this.lastNMonths;
		System.debug('query :' + query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}