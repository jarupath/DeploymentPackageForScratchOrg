@isTest
private class BE8_MasterDataRepository_Test
{
	@isTest
	static void testGetProfileByName() {
		Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		Test.startTest();
		Profile actualProfile = (Profile)BE8_MasterDataRepository.getInstance().getObjectByName('Profile', 'System Administrator');
		Test.stopTest();
		System.assertEquals(adminProfile.Id, actualProfile.Id);
	}

	@isTest 
	static void testGetUserRoleByName() {
		UserRole expect = [SELECT Id FROM UserRole WHERE DeveloperName = 'KW_Lounge'];

		Test.startTest();
		UserRole actual = (UserRole)BE8_MasterDataRepository.getInstance().getObjectByName('UserRole', 'KW_Lounge');
		Test.stopTest();
		System.assertEquals(expect.Id, actual.Id);
	}
}