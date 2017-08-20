trigger SFDCExternalKey_Trigger on SFDC_External_Key__c (before insert,before update) {
	public static Integer holdingTime = -1;
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			String objectType = '';
			Set<String> setGroupKey = new Set<String>();
			for(SFDC_External_Key__c externalKey :Trigger.New){
				objectType = externalKey.Object_Type__c;
				setGroupKey.add(externalKey.Group_Key__c);
			}
			List<SFDC_External_Key__c> listExternalKey =  SFDCExternalKeyHandler.getListSFDCExternalKeyByGroupKey(objectType, setGroupKey);
			if(!listExternalKey.isEmpty()){
				String groupDuplicateString = '';
				for(SFDC_External_Key__c duplicate :listExternalKey){
					groupDuplicateString += duplicate.Group_Key__c;
				}
				for(SFDC_External_Key__c externalKey :Trigger.New){
					externalKey.addError(groupDuplicateString+' Has been created already.');
				}
			}	
		}else if(Trigger.isUpdate){
			DateTime fifteenSecondBefore = System.now().addSeconds(holdingTime);

			for(SFDC_External_Key__c externalKey:Trigger.New ){
				if(externalKey.SystemModStamp>fifteenSecondBefore && !Test.isRunningTest()){
					externalKey.addError('This records has been updated with in a second before, please try again later.');
				}
			}
		}
	}
}