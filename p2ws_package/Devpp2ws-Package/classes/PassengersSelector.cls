public class PassengersSelector extends fflib_SObjectSelector {
	public List<Schema.SObjectField> getSObjectFieldList() {
		return null;
	}

	public Schema.SObjectType getSObjectType() {
		return Passenger__c.sObjectType;
	}	
}