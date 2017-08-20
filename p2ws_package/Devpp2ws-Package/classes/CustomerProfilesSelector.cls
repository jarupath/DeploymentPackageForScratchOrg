public class CustomerProfilesSelector extends fflib_SObjectSelector {
	public List<Schema.SObjectField> getSObjectFieldList() {
		return null;
	}

	public Schema.SObjectType getSObjectType() {
		return Account.sObjectType;
	}	
}