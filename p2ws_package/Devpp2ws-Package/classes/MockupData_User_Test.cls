public with sharing class MockupData_User_Test {
	public MockupData_User_Test() {
		
	}

	public static User createUserIfNotExist(String profiileName, String userRoleDeveloperName) {
		//[SELECT Id FROM User WHERE profiileName]
		BE8_MasterDataRepository masterData = BE8_MasterDataRepository.getInstance();
		Profile profile = (Profile)masterData.getObjectByName('Profile', profiileName);
		UserRole userRole = (UserRole)masterData.getObjectByName('UserRole', userRoleDeveloperName);
		List<User> users = [SELECT Id FROM User WHERE Profile.Name = :profiileName AND UserRole.DeveloperName = :userRoleDeveloperName];
		if(users.isEmpty()) {
			String username = BE8_GlobalUtility.generateRandomString(10) + '@testorg.com';
			User user = new User(Alias = 'MockUser', Email=username, 
            EmailEncodingKey='UTF-8', LastName='MockLastName', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = profile.Id,
            TimeZoneSidKey='Asia/Bangkok', UserName=username, UserRoleId=userRole.Id);
            insert user;
            return user;
		} else {
			return users.get(0);
		}

		return null;
	}
}