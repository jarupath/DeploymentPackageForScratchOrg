global class FieldDescribe {
	global String fieldAPI;
	global String fieldLabel;
	global String fieldType;
	global String relatedToObject;
	global Boolean isEditable;
	global Boolean isCreateable;
	global Boolean isRequire;
	global String objectAPI;

	global List<SelectOption> picklistOption;
	
	global FieldDescribe(String objectName,Schema.FieldSetMember configField){
		fieldAPI 	= configField.getFieldPath();
		fieldLabel 	= configField.getLabel();
		fieldType 	= String.valueOf(configField.getType() );
		isRequire  	= configField.getRequired()||configField.getDBRequired();
		objectAPI 	= objectName;
		if(fieldType=='PICKLIST'||fieldType=='MULTIPICKLIST'){
			picklistOption = new List<SelectOption>();
			Schema.DescribeFieldResult thisField = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap().get(fieldAPI).getDescribe();
			List<Schema.PicklistEntry> listPicklistValue = thisField.getPicklistValues();
			for(Schema.PicklistEntry eachPicklist :listPicklistValue){
				if(eachPicklist.isActive()){
					// should it be like a map of String?
					picklistOption.add(new SelectOption(eachPicklist.getLabel(),eachPicklist.getValue() ) );
				}
			}
		}
		if(fieldType=='REFERENCE'){
			if(fieldAPI=='OwnerId'){
				this.relatedToObject = 'User';
			}else{
				Schema.DescribeFieldResult thisField = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fields.getMap().get(fieldAPI).getDescribe();
				List<Schema.sObjectType> listsObjectType = thisField.getReferenceTo();
				for(Schema.sObjectType objType :listsObjectType){
					this.relatedToObject = String.valueOf(objType);
				}
			}
		}
	}

	global FieldDescribe(Schema.FieldSetMember configField){
		fieldAPI 	= configField.getFieldPath();
		fieldLabel 	= configField.getLabel();
		fieldType 	= String.valueOf(configField.getType() );
		isRequire  	= configField.getRequired()||configField.getDBRequired();

	}
	// for get field by standard
	global FieldDescribe(Schema.DescribeFieldResult configField) {
		fieldAPI 		= configField.getname();
		fieldLabel 		= configField.getLabel();
		fieldType  		= String.valueOf(configField.getType() );
		isCreateable 	= configField.isCreateable();
		isEditable 		= configField.isUpdateable() && configField.isAccessible() && configField.isCreateable();
		isRequire 		= !configField.isNillable();
		relatedToObject = configField.getRelationshipName();
		if(fieldType=='PICKLIST'||fieldType=='MULTIPICKLIST'){
			picklistOption = new List<SelectOption>();
			List<Schema.PicklistEntry> listPicklistValue = configField.getPicklistValues();
			for(Schema.PicklistEntry eachPicklist :listPicklistValue){
				if(eachPicklist.isActive()){
					// should it be like a map of String?
					picklistOption.add(new SelectOption(eachPicklist.getLabel(),eachPicklist.getValue() ) );
				}
			}
		}
	}


}