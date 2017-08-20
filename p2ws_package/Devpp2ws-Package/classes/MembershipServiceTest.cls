@isTest
private class MembershipServiceTest {

	@isTest static void testConvertSubTierToActualTier() {
		Membership__c mem = new Membership__c(
		    Name = 'ZZ99999',
		    Airline__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY,
		    Tier__c = 'SILVER O'
		);
		List<Membership__c> membershipList = new List<Membership__c>();
		membershipList.add(mem);

		MembershipService.convertSubTierToActualTier(membershipList);
		Assert.assertEquals('SILV', mem.Tier__c);
	}
}