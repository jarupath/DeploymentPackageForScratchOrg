@isTest
private class BE8_MasterData_Test
{
	@isTest
	static void testGetProfileByName() {
		Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

		Test.startTest();
		BE8_MasterData profileData = new BE8_MasterData('Profile');
		Profile actualProfile = (Profile)profileData.getObjectByName('System Administrator');
		Test.stopTest();
		System.assertEquals(adminProfile.Id, actualProfile.Id);
	}

	@isTest 
	static void testGetUserRoleByName() {
		UserRole expect = [SELECT Id FROM UserRole WHERE DeveloperName = 'KW_Lounge'];

		Test.startTest();
		BE8_MasterData useRoleData = new BE8_MasterData('UserRole');
		UserRole actual = (UserRole)useRoleData.getObjectByName('KW_Lounge');
		Test.stopTest();
		System.assertEquals(expect.Id, actual.Id);
	}
}