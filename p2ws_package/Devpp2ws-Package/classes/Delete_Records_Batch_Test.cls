@isTest
public class Delete_Records_Batch_Test {
	
	@isTest 
	static void test() {
		Account account = MockupData_Test.createAccount('accountName');
		insert account;
		
		Account account2 = MockupData_Test.createAccount('accountName2');
		insert account2;

		String soql = 'SELECT Id FROM Account WHERE Name = \'accountName2\' ';

        Test.startTest();
		Delete_Records_Batch bat = new Delete_Records_Batch();
		bat.query = soql;
		bat.toEmail = 'somwut.j@beryl8.com';
		Database.executeBatch(bat);
		Test.stopTest();

		List<Account> actualAccount = [SELECT Id FROM Account];

		System.assertEquals(1, actualAccount.size());
		System.assertEquals(account.Id, actualAccount.get(0).Id);
	}
}