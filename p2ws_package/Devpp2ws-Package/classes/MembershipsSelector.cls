public class MembershipsSelector extends fflib_SObjectSelector {
	public List<Schema.SObjectField> getSObjectFieldList() {
		return new List<Schema.SObjectField>{
			Membership__c.Id,
			Membership__c.Name,
			Membership__c.AccountId__c,
			Membership__c.EXTMember__c,
			Membership__c.Airline__c
		};
	}

	public Schema.SObjectType getSObjectType() {
		return Membership__c.sObjectType;
	}	

	public Map<String, Membership__c> getMembershipsMapByExternalId(List<String> externalIds){
		if(externalIds == null || externalIds.isEmpty())
			return null;
		return null;

	}

	public List<Membership__c> getMembershipsByExternalId(List<String> externalIds){
		if(externalIds == null || externalIds.isEmpty())
			return null;
		return null;
	}

	public String buildQueryMembershipByExternalId(){
		//return newQueryFactory().setCondition('id in :idSet').toSOQL();
		return null;
	}
}