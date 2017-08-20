public with sharing class BE8_MasterData {
	private String masterDataName = '';
	private Boolean hasQueryAll = false;
	private String keyName = 'DeveloperName';

	private Map<String, SObject> objMapByName = new Map<String, SObject>();
	private Map<Id, SObject> objMapById = new Map<Id, SObject>();

    private static ProfileData instance = null;
    private Map<String, Profile> profileMapByName;
    private Map<Id, Profile> profileMapById;

	public BE8_MasterData(String masterDataName) {
		this.masterDataName = masterDataName;
		hasQueryAll = false;

		if(!Schema.getGlobalDescribe().get(this.masterDataName).getDescribe().fields.getMap().containsKey(keyName)) {
			keyName = 'Name';
		}
	}

	public SObject getObjectByName(String objectName) {
		if(!hasQueryAll) {
			queryAll();
		}

		if(objMapByName.containsKey(objectName)) {
			return objMapByName.get(objectName);
		}

		return null;
	}

	public void queryAll() {
		BE8_SoqlBuilder soql = new BE8_SoqlBuilder(this.masterDataName);
		soql.addField(new Set<String>{'Id', keyName});
		if(this.masterDataName == 'Custom_Mail_List__mdt') {
			soql.addField(new Set<String>{'Email_Address__c', 'Email_Type__c'});
		}

		String queryAllSoql = soql.getQueryStr();
		System.debug('queryAllSoql :'+ queryAllSoql);
        objMapById = BE8_CacheQuery.getInstance().query('all_' + this.masterDataName, queryAllSoql);
        for(sObject eachObject : objMapById.values()) {
        	objMapByName.put((String)eachObject.get(keyName), eachObject);
        }
	}
}