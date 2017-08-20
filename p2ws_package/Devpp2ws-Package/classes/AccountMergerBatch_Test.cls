@isTest
private class AccountMergerBatch_Test
{
	//@isTest
	//static void test() {
	//	String externalId = '1234';
	//	Account existingAccount = new Account(Name = 'Existing', Customer_External_Id__c = externalId);
	//	insert existingAccount;

	//	Account duplicatedAccount = new Account(Name = 'Duplicated');
	//	insert duplicatedAccount;

	//	List<Case> existingCaseList = new List<Case>{
	//		new Case(Subject = 'Existing Case 1', AccountId = existingAccount.Id),
	//		new Case(Subject = 'Existing Case 2', AccountId = existingAccount.Id)
	//	};
	//	insert existingCaseList;

	//	Set<String> externalIdSet = new Set<String> {externalId};
	//	Map<String, Account> duplicatedAccountMap = new Map<String, Account>{ externalId => duplicatedAccount};
	//	Test.startTest();
	//	Database.executeBatch(new AccountMergerBatch(duplicatedAccountMap));
	//	Test.stopTest();

	//	List<Case> movedCaseList = [SELECT Id FROM Case WHERE AccountId = :duplicatedAccount.Id];
	//	Assert.assertEquals(2, movedCaseList.size());

	//}
}