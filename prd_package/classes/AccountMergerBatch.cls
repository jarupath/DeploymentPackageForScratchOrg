global class AccountMergerBatch implements Database.Batchable<String> {

	//private Map<String, Account> duplicatedAccountMap;

	global AccountMergerBatch(Map<String, Account> duplicatedAccountMap) {
		//this.duplicatedAccountMap = duplicatedAccountMap;
	}

	global List<String> start(Database.BatchableContext BC) {
		//return new List<String>(duplicatedAccountMap.keySet());
		return null;
	}

	global void execute(Database.BatchableContext BC, List<String> customerExternalIdList) {
		//AccountService.mergeAccount(new Set<String>(customerExternalIdList), duplicatedAccountMap);
	}

	global void finish(Database.BatchableContext BC) {

	}

}