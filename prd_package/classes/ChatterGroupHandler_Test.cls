@isTest
public class ChatterGroupHandler_Test {

	@isTest
	static void test_createGroupWithMembers() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			String groupName = 'TG-001 Chatter Group';
			List<user> listUser = [Select Id, Name From User Where Id != :UserInfo.getUserId() ];
			ChatterGroupHandler.createGroupWithMembers(groupName, listUser, 'Private');
		}
	}

	@isTest
	static void test_CreateGroupsWithMembers() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			Map<String, List<User>> mapGroupNAme = new Map<String, List<User>> {
				'TG-001 Chatter Group' => new List<USer>{new User(Id = UserInfo.getUserId())},
				'TG-002 Chatter Group' => new List<USer>{new User(Id = UserInfo.getUserId())}
			};
			ChatterGroupHandler.createGroupsWithMembers(mapGroupNAme, 'Private');
		}
	}
	@isTest
	static void getGroupRole() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			ChatterGroupHandler.getGroupRole(new User(Id = UserInfo.getUserId()));
		}
	}
	@isTest
	static void addMember() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			List<User> listUser = [Select Id, Name From User Where Id != :UserInfo.getUserId()];
			String groupName = 'TG-003 Chatter Group';
			List<user> listUserx = new List<User> {new User( Id = UserInfo.getUserId()  )};
			ChatterGroupHandler.createGroupWithMembers(groupName, listUserx, 'Private');

			System.debug('DEBUG - ADDMEMBER');
			System.debug(listUser);
			ChatterGroupHandler.addMemberToGroup(groupName, listUser);
		}
	}
	@isTest
	static void removeMember() {
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser) {
			List<User> listUser = [Select Id, Name From User Where Id != :UserInfo.getUserId() ];
			String groupName = 'TG-004 Chatter Group';
			List<user> listUserx = new List<User> {new User( Id = UserInfo.getUserId()  )};
			ChatterGroupHandler.createGroupWithMembers(groupName, listUserx, 'Private');

			System.debug('DEBUG - REMOVEMEMBER');
			System.debug(listUser);

			ChatterGroupHandler.addMemberToGroup(groupName, listUser);
			ChatterGroupHandler.removeMemberFromGroup(groupName, listUser);
		}

	}
}