public with sharing class LOPALabelRepository {
	private Map<String, SObject> lopaLabelMap;

	public LOPALabelRepository(String cabinVersion) {
		List<LOPA_Label__mdt> lopaLabelList = [SELECT Id, DeveloperName, Temp_Label__c, Actual_Label__c FROM LOPA_Label__mdt WHERE Cabin_Version__c = :cabinVersion];
		lopaLabelMap = BE8_GlobalUtility.getSObjectMap('Temp_Label__c', lopaLabelList);
	}

	public String getActualLabelFromTempLabel(String tempLabel){
		if(lopaLabelMap.containsKey(tempLabel)){
			LOPA_Label__mdt label = (LOPA_Label__mdt) lopaLabelMap.get(tempLabel);
			return label.Actual_Label__c;
		} else {
			return null;
		}
	}
}