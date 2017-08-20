global class Fix_Data_Batch implements Database.Batchable<sObject> {
	
	String query;
	
	global Fix_Data_Batch(String query) {
		this.query = query;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		Database.saveResult[] result = Database.update(scope, false);
		List<String> results = new List<String>();
		for(Database.saveResult r : result){
			if(!r.isSuccess()){
				System.debug('error:' + JSON.serialize(r.getErrors()));
			}
		}
		//System.debug(JSON.serialize(scope));
		//System.debug(scope.size());
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('FINISH');	
	}
	
}