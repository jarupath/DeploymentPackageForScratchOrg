global class Purge_Batch implements Database.Batchable<sObject>, Database.Stateful {
    global String query;
    public List<Purge_Setting__mdt> purgeSettings = new List<Purge_Setting__mdt>();
    Purge_Setting__mdt currentPurgeSetting;
    public Integer countDelRecord;
    global Purge_Batch() {
 		this(null);
    }   

    global Purge_Batch(List<Purge_Setting__mdt> purgeSettings) {
    	if(purgeSettings == null) {
 			purgeSettings = [SELECT Id, Label, Object__c, Older_Than_N_Months__c, Condition__c FROM Purge_Setting__mdt];
    	}
    	this.purgeSettings = purgeSettings;
    	countDelRecord = 0;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
    	query = 'SELECT Id FROM Account LIMIT 0';
    	if(!purgeSettings.isEmpty()) {
    		currentPurgeSetting = purgeSettings.get(0);
    		BE8_SoqlBuilder soql = new BE8_SoqlBuilder(currentPurgeSetting.Object__c);
    		soql.addField('Id');
    		soql.addCondition('CreatedDate < LAST_N_MONTHS:' + currentPurgeSetting.Older_Than_N_Months__c.format());
    		if(!String.isBlank(currentPurgeSetting.Condition__c)) {
    			soql.addCondition(currentPurgeSetting.Condition__c);
    		}
    		query = soql.getQueryStr();
    		AppLogger.debug('Purge_Batch', 'start', currentPurgeSetting.Label, query, null);
    	} else {
    		AppLogger.debug('Purge_Batch', 'start', 'empty', 'empty', null);
    	}
    	AppLogger.insertLogs();
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
    	try {
        	delete scope;
    		countDelRecord += scope.size();
    	} catch(Exception e) {
    		AppLogger.error('Purge_Batch', 'execute', currentPurgeSetting.Label, 'Exception to deleted', e);
    		AppLogger.insertLogs();
    	}
    }

    global void finish(Database.BatchableContext BC) {
    	if(!purgeSettings.isEmpty()) {
			if(countDelRecord > 0) {
				AppLogger.debug('Purge_Batch', 'finish', currentPurgeSetting.Label, countDelRecord  + ' records deleted', null);
				AppLogger.insertLogs();	
			}

    		purgeSettings.remove(0);
    		if(!purgeSettings.isEmpty()) {
    			Database.executeBatch(new Purge_Batch(purgeSettings));
    		}
		}
    }
    
}