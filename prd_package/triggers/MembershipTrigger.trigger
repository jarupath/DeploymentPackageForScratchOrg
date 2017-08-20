trigger MembershipTrigger on Membership__c (before insert, before update) {
	if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
		MembershipService.convertSubTierToActualTier(Trigger.new);
	}
}