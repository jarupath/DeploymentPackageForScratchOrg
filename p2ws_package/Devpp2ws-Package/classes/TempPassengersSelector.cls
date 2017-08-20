public class TempPassengersSelector extends fflib_SObjectSelector {
	public List<Schema.SObjectField> getSObjectFieldList() {
		return null;
	}

	public Schema.SObjectType getSObjectType() {
		return TempPassenger__c.sObjectType;
	}	
}