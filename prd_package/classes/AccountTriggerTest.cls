@isTest
private class AccountTriggerTest {
	
	@isTest static void test_method_one() {
		// Implement test code
		Account acc = new Account(Name = 'Test', ROP_Number__c='1234567');
		upsert acc ROP_Number__c;
		System.assertNotEquals(acc.Id, null);
	}
	
}