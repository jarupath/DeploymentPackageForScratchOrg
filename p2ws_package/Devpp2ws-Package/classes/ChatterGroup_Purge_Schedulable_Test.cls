@isTest
private class ChatterGroup_Purge_Schedulable_Test {
	@isTest
	static void testPurgeChatter() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			CollaborationGroup grp = new CollaborationGroup();
			grp.CollaborationType = 'Private';
			grp.Name = 'TG999 / 29FEB17_1';
			insert grp;

			Datetime pastDate = Datetime.now().addDays(-2);
			Test.setCreatedDate(grp.Id, pastDate);

			Test.startTest();
			//System.debug(JSON.serialize([SELECT Id,Name, CreatedDate From CollaborationGroup]));
			//System.debug(JSON.serialize([SELECT Id,Name, CreatedDate From CollaborationGroup WHERE CreatedDate != LAST_N_DAYS:1]));
			String cronDateTime = BE8_DateUtility.getExactCRONFromDateTime(System.now().addSeconds(2));
			System.schedule('testJobName', cronDateTime, new ChatterGroup_Purge_Schedulable());
			Test.stopTest();

			List<CollaborationGroup> actualGroups = [SELECT Id, Name, CreatedDate From CollaborationGroup];
			System.assertEquals(0, actualGroups.size());
		}
	}
}