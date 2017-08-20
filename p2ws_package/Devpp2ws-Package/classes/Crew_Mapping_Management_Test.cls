@isTest
private class Crew_Mapping_Management_Test {

	@testSetup static void DataPreparation(){
		User testUser = MockupData_Test.createUser('TEST', 'test@salesforcetgtest.com', 'System Administrator', null);
		insert testUser;

		System.runAs(testUser){
			Test.startTest();
			List<Flight__c> flightList = new List<Flight__c>();
			flightList.add(new Flight__c(Name = 'TG930 / 04MAR25', Flight_Number__c = 'TG0930', Leg_Number__c = 1, STD_UTC__c = '04Mar25 1730', STD_LT__c = '04Mar25 1830', STA_UTC__c = '04Mar25 2030', Flight_Date_UTC__c = '04Mar25', Flight_Date_LT__c = '04Mar25', Flight_External_Id__c = 'TG0930_04Mar25_1'));
			flightList.add(new Flight__c(Name = 'TG950 / 04MAR25', Flight_Number__c = 'TG0950', Leg_Number__c = 1, STD_UTC__c = '04Mar25 1730', STD_LT__c = '04Mar25 1830', STA_UTC__c = '04Mar25 2030', Flight_Date_UTC__c = '04Mar25', Flight_Date_LT__c = '04Mar25', Flight_External_Id__c = 'TG0950_04Mar25_1'));
			flightList.add(new Flight__c(Name = 'TG628 / 04MAR25', Flight_Number__c = 'TG0628', Leg_Number__c = 1, STD_UTC__c = '04Mar25 1730', STD_LT__c = '04Mar25 1830', STA_UTC__c = '04Mar25 2030', Flight_Date_UTC__c = '04Mar25', Flight_Date_LT__c = '04Mar25', Flight_External_Id__c = 'TG0628_04Mar25_1'));
			flightList.add(new Flight__c(Name = 'TG628 / 04MAR25', Flight_Number__c = 'TG0628', Leg_Number__c = 2, STD_UTC__c = '04Mar25 1730', STD_LT__c = '04Mar25 1830', STA_UTC__c = '04Mar25 2030', Flight_Date_UTC__c = '04Mar25', Flight_Date_LT__c = '04Mar25', Flight_External_Id__c = 'TG0628_04Mar25_2'));

			insert flightList;

			List<CollaborationGroup> chatterGroupList = new List<CollaborationGroup>();

			for(Flight__c flight : flightList){
				chatterGroupList.add(new CollaborationGroup(Name = flight.Name + '_' + flight.Leg_Number__c, CollaborationType = 'private'));
			}
			System.debug('JK: inserted chatter');
			System.debug(chatterGroupList);
			insert chatterGroupList;
			System.debug('gm: ' + JSON.serialize([SELECT Id, Member.Name, CollaborationGroup.Name FROM CollaborationGroupMember]));

			List<Crew__c> crewList = new List<Crew__c>();
			crewList.add(new Crew__c(Crew_First_Name__c = 'Earth', Crew_Last_Name__c = 'Kung', Personel_Id__c = '12345'));
			crewList.add(new Crew__c(Crew_First_Name__c = 'Earth1', Crew_Last_Name__c = 'Kung', Personel_Id__c = '12346'));
			crewList.add(new Crew__c(Crew_First_Name__c = 'Earth2', Crew_Last_Name__c = 'Kung', Personel_Id__c = '12347'));
			crewList.add(new Crew__c(Crew_First_Name__c = 'Earth3', Crew_Last_Name__c = 'Kung', Personel_Id__c = '12348'));

			insert crewList;

			List<Crew_List__c> crewlistList = new List<Crew_List__c>();
			crewlistList.add(new Crew_List__c(Name = 'Kung Earth', FlightId__c = flightList.get(0).Id, CrewId__c = crewList.get(0).Id, Flight_Temp__c = 'TG0930_04Mar25_1', Crew_Temp__c = '12345', CrewList_Temp__c = '12345_TG0930_04Mar25_1'));
			crewlistList.add(new Crew_List__c(Name = 'Kung Earth1', FlightId__c = flightList.get(1).Id, CrewId__c = crewList.get(1).Id, Flight_Temp__c = 'TG0950_04Mar25_1', Crew_Temp__c = '12346', CrewList_Temp__c = '12346_TG0950_04Mar25_1'));
			crewlistList.add(new Crew_List__c(Name = 'Kung Earth2', FlightId__c = flightList.get(2).Id, CrewId__c = crewList.get(2).Id, Flight_Temp__c = 'TG0628_04Mar25_1', Crew_Temp__c = '12347', CrewList_Temp__c = '12347_TG0628_04Mar25_1'));
			crewlistList.add(new Crew_List__c(Name = 'Kung Earth3', FlightId__c = flightList.get(3).Id, CrewId__c = crewList.get(3).Id, Flight_Temp__c = 'TG0628_04Mar25_2', Crew_Temp__c = '12348', CrewList_Temp__c = '12348_TG0628_04Mar25_2'));

			insert crewlistList;
			Test.stopTest();
		}
	}
	
	@isTest static void testGetAllFlightList() {
		List<Crew__c> crewList = [SELECT Id, Name FROM Crew__c];
		List<Flight__c> flightList = [SELECT Id FROM Flight__c];
		Map<String, List<Flight__c>> flightListMap = new Map<String, List<Flight__c>>();
		Integer loopcount = 0;
		for(Crew__c crew : crewList){
			flightListMap.put(crew.Id, new List<Flight__c>{flightList.get(loopcount)});
			loopcount++;
		}

		Test.startTest();
		Map<String, Flight__c> flightListFromMethod = Crew_Mapping_Management.getAllFlightList(flightListMap);
		Test.stopTest();

		System.debug('JK: testGetAllFlightList');
		System.debug(JSON.serialize(flightListFromMethod));
		System.assertNotEquals(null, flightListMap, 'Flight List Map that returned from method should not be null');
		System.assertEquals(4, flightListMap.size(), 'Flight List Map size should be equal to 4');
	}
	
	@isTest static void testGetCrewmapMap() {
		List<Crew__c> crewList = [SELECT Id, Name FROM Crew__c];
		List<User> userList = [SELECT Id FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE Name = 'Air Purser / In-Flight Manager')];

		List<Crew_Mapping__c> crewmapList = new List<Crew_Mapping__c>();
		System.debug('JK: testGetCrewmapMap');
		System.debug(JSON.serialize(userList));
		System.debug(JSON.serialize(crewList));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(0).Id, UserId__c = userList.get(0).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(1).Id, UserId__c = userList.get(1).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(2).Id, UserId__c = userList.get(2).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(3).Id, UserId__c = userList.get(3).Id));

		Test.startTest();
		Map<String, String> crewmapIdMap = Crew_Mapping_Management.getCrewmapMap(crewmapList);
		Test.stopTest();	

		System.debug('JK: testGetCrewmapMap');
		System.debug(JSON.serialize(crewmapIdMap));
		System.assertNotEquals(null, crewmapIdMap, 'crewmapIdMap should not be null');
		System.assertEquals(4, crewmapIdMap.size(), 'Crewmap Id map size should be equal to 4');

	}

	@isTest static void testGetGroupNameList() {
		List<Flight__c> flightList = [SELECT Id, Name, Leg_Number__c, STD_LT_DateTime__c FROM Flight__c];
		System.debug('JK: flight list - ' + JSON.serialize(flightList));
		List<String> expectedNameList = new List<String>{'TG930 / 04MAR25_1', 'TG950 / 04MAR25_1', 'TG628 / 04MAR25_1', 'TG628 / 04MAR25_2'};
		Test.startTest();
		Set<String> groupNameList = Crew_Mapping_Management.getGroupNameList(flightList);
		Test.stopTest();

		System.debug('JK: testGetGroupNameList');
		Integer loopcount = 0;
		for(String groupName : groupNameList){
			System.debug('Expected: ' + expectedNameList.get(loopcount));
			System.debug('Actual: ' + groupName);
			System.assertEquals(expectedNameList.get(loopcount), groupName, 'group name should be equal to ' + expectedNameList.get(loopcount));
			loopcount++;
		}
	}
	
	@isTest static void testGetCrewListMap() {
		List<Crew__c> crewList = [SELECT Id, Name FROM Crew__c];
		List<User> userList = [SELECT Id FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE Name = 'Air Purser / In-Flight Manager')];

		List<Crew_Mapping__c> crewmapList = new List<Crew_Mapping__c>();
		System.debug('JK: testGetCrewListMap');
		System.debug(JSON.serialize(userList));
		System.debug(JSON.serialize(crewList));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(0).Id, UserId__c = userList.get(0).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(1).Id, UserId__c = userList.get(1).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(2).Id, UserId__c = userList.get(2).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(3).Id, UserId__c = userList.get(3).Id));

		Test.startTest();
		Map<String, List<SObject>> crewlistMap = Crew_Mapping_Management.getCrewListMap(crewmapList);
		Test.stopTest();

		System.debug('JK: testGetCrewmapMap - crewlistMap | ' + JSON.serialize(crewlistMap));
		System.assertNotEquals(null, crewlistMap, 'CrewList Map should not be null');
		System.assertEquals(4, crewlistMap.size(), 'CrewList map size should be equal to 4 due to the amount of crew');
	}

	@isTest static void testIsExistingGroup() {
		List<Flight__c> flightList = [SELECT Id, Name, Leg_Number__c FROM Flight__c];

		Test.startTest();
		Map<Id, Boolean> existingMap = Crew_Mapping_Management.isExistingGroup(flightList);
		Test.stopTest();
		
		System.debug('JK: testIsExistingGroup');
		System.debug(JSON.serialize(existingMap));
		System.assertNotEquals(null, existingMap);
		for(Boolean isexist : existingMap.values()){
			System.assertEquals(true, isexist, 'Chatter isexisting status should be true because the chatter for every inserted flight are prepared');
		}
	}
	
	@isTest static void testAddCrewToChatter() {
		List<Crew__c> crewList = [SELECT Id, Name FROM Crew__c];
		List<User> userList = [SELECT Id FROM User WHERE UserRoleId IN (SELECT Id FROM UserRole WHERE Name = 'Air Purser / In-Flight Manager')];

		List<Crew_Mapping__c> crewmapList = new List<Crew_Mapping__c>();
		System.debug('JK: testGetCrewmapMap');
		System.debug(JSON.serialize(userList));
		System.debug(JSON.serialize(crewList));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(0).Id, UserId__c = userList.get(0).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(1).Id, UserId__c = userList.get(1).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(2).Id, UserId__c = userList.get(2).Id));
		crewmapList.add(new Crew_Mapping__c(CrewId__c = crewList.get(3).Id, UserId__c = userList.get(3).Id));

		insert crewmapList;
		Test.startTest();
		Crew_Mapping_Management.addCrewToChatter(crewmapList);
		Test.stopTest();

		List<CollaborationGroup> chatterList = [SELECT Id, Name, CollaborationType FROM CollaborationGroup];
		Set<Id> chatterIdSet = BE8_GlobalUtility.getIdSet('Id', chatterList);
		List<CollaborationGroupMember> chatterGroupMemList = [SELECT Id, MemberId, Member.Name, CollaborationGroupId, CollaborationGroup.Name FROM CollaborationGroupMember WHERE CollaborationGroupId IN :chatterIdSet];

		System.debug('JK: testAddCrewToChatter');
		System.debug(JSON.serialize(chatterGroupMemList));
		System.assertNotEquals(null, chatterGroupMemList, 'Crew from Crew Mapping should be added to chatter group');
		System.assertEquals(8 , chatterGroupMemList.size(), 'There should be 8 (crew mapping 4) crew in the list according to the amount of crew mapping');
	}
}