@isTest
private class ProfileDataTest {
	
	@isTest static void test_method_one() {
		ProfileData data = new ProfileData();
		data.setupData();
		data.getProfileByName('System Integration');
		data.getProfileMapByName();
		data.getProfileMap();
		ProfileData.getInstance();
	}
	
}