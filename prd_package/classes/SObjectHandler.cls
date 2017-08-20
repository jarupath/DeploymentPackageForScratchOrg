global class SObjectHandler {
	global static SObject instantOf(String sObjectType) {
		return  Schema.getGlobalDescribe().get(sObjectType).newSObject();
	}

	global static List<FieldDescribe> getFieldOnFieldSet(String objectName, String fieldSetName){
		if(objectName!=''&&fieldSetName!=''){
			List<FieldDescribe> listFieldName = new List<FieldDescribe>();
			Map<String, Schema.FieldSet> mapFieldSet = Schema.getGlobalDescribe().get(objectName).getDescribe().fieldSets.getMap();
			Schema.FieldSet thisFieldSet; 
			if(mapFieldSet.containsKey(fieldSetName)){
				thisFieldSet = mapFieldSet.get(fieldSetName);
			}else{
				// thrown Error  ' No Found Field Set'
				
			}
			if(!thisFieldSet.getFields().isEmpty()){
				for(Schema.FieldSetMember fieldMember :thisFieldSet.getFields()){
					listFieldName.add(new FieldDescribe(objectName,fieldMember));
				}	
			}
			return listFieldName;
		}else{
			// thrown Error ' Object Name And Field Set Name Can not be blank'
		}
		return null;
	}
	global static FieldDescribe getFieldDescribe(String objectName, String fieldName){
		Schema.DescribeFieldResult thisField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe();
		FieldDescribe thisFieldDesc = new FieldDescribe(thisField);
		return thisFieldDesc;
	}


	global static List<String> getAllCustomSObjects() {
		List<String> sObjectList = new List<String>();
		//SobjectList.addAll(setStandardObject);
		for (Schema.SObjectType objTyp : Schema.getGlobalDescribe().Values()) {
			Schema.DescribeSObjectResult describeSObjectResultObj = objTyp.getDescribe();
			if (describeSObjectResultObj.isCustom()) {
				String name = objTyp.getDescribe().getName();
				// Exclude all the unwanted Sobjects e.g. History, Share etc..
				if (!name.containsignorecase('history') && !name.containsignorecase('tag') &&
				        !name.containsignorecase('share') && !name.containsignorecase('feed')) {
					SobjectList.add(name);
				}
			}
		}
		return sObjectList;
	}
	global static Set<String> availableType = new Set<String> {
		'STRING', 'NUMBER', 'BOOLEAN', 'DATE', 'DATETIME', 'CURRENCY', 'COMBOBOX', 'PICKLIST'
	};
}