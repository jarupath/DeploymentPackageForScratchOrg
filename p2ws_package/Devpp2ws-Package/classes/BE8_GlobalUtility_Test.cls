@isTest
private class BE8_GlobalUtility_Test {

	@isTest static void testLogMessage() {
		System_Settings__c systemSetting = System_Settings__c.getOrgDefaults();
		systemSetting.Debug__c = true;
		systemSetting.Log_Purge_Days__c = 7;
		upsert systemSetting;

		BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'SourceClass', 'SourceFunction', 'LogMessage', 'PayLoad', new DmlException(), 10);
		List<Application_Log__c> actualLogs = [SELECT Id, Debug_Level__c, Message__c FROM Application_Log__c];

		BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'SourceClass', 'SourceFunction', 'referenceId', 'referenceInfo', 'logMessage', 'payLoad', new DmlException(), 100);

		List<Application_Log__c> appLogs = new List<Application_Log__c>();
		BE8_GlobalUtility.cacheLogMessage('SourceClass', 'SourceFunction', BE8_GlobalConstants.LEVEL_DEBUG, 'message', 'referenceId', appLogs);

		Assert.assertEquals(1, appLogs.size());
		Assert.assertEquals(1, actualLogs.size());
		Assert.assertEquals(BE8_GlobalConstants.LEVEL_DEBUG, actualLogs.get(0).Debug_Level__c);
		Assert.assertEquals('LogMessage', actualLogs.get(0).Message__c);
	}

	@isTest static void testGetRecordType() {
		Map<String, Id> actualCaseRecordTypeIdMap = BE8_GlobalUtility.getRecordTypeMapByDevNameFromSObject('Case');
		Map<Id, String> actualCaseRecordTypeDevNameMap = BE8_GlobalUtility.getRecordTypeDevNameMapByIdFromSObject('Case');
		Map<Id, RecordType> expectCaseRecordTypes = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Case']);
		Assert.assertEquals(expectCaseRecordTypes.size(), actualCaseRecordTypeIdMap.size());
		Assert.assertEquals(expectCaseRecordTypes.size(), actualCaseRecordTypeDevNameMap.size());

		Id expectRecordTypeId = (new List<Id>(expectCaseRecordTypes.keySet())).get(0);
		String expectRecordTypeDevName = expectCaseRecordTypes.get(expectRecordTypeId).DeveloperName;
		Assert.assertEquals(expectRecordTypeId, BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', expectRecordTypeDevName));
	}

	@isTest static void testIsEmailValid() {
		Assert.assertEquals(true, BE8_GlobalUtility.isEmailValid('test@beryl8.com'));
		Assert.assertEquals(false, BE8_GlobalUtility.isEmailValid('test@beryl8com'));
	}

	@isTest static void testToNumber() {
		Assert.assertEquals('123', BE8_GlobalUtility.toNumber(123));
	}

	@isTest static void testToExportDateFormat() {
		Assert.assertEquals('2006-12-31', BE8_GlobalUtility.toExportDateFormat(Date.newInstance(2006, 12, 31)));
	}

	@isTest static void testGetLocaleDateMap() {
		Assert.assertEquals('d/M/yyyy, H:mm',  BE8_GlobalUtility.getLocaleDateMap().get('th_TH'));
	}

	//@isTest static void testRemoveCDATAfromXMLString() {
	//	Assert.assertEquals('xxxx', BE8_GlobalUtility.removeCDATAfromXMLString('<![CDATA[xxxx]]>'));
	//}

	@isTest static void testGetSetting() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Assert.assertEquals('FLIGHT_ENDPOINT', BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_ENDPOINT));
	}

	@isTest static void testGetDateString() {
		Assert.assertEquals('12312016' , BE8_GlobalUtility.getDateString(Date.newInstance(2016, 12, 31), 'MMddyyyy'));
	}

	@isTest static void testStringToNumber() {
		Assert.assertEquals(1234, BE8_GlobalUtility.toNumber('1,234'));
	}

	@isTest static void testGetIdSet() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Set<Id> idSet = BE8_GlobalUtility.getIdSet('Id', passengers);
		Assert.assertEquals(10, idSet.size());
	}

	@isTest static void testGetStringSet() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Set<String> idSet = BE8_GlobalUtility.getStringSet('Id', passengers);
		Assert.assertEquals(10, idSet.size());
	}

	@isTest static void testGetSObjectMapByString() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Assert.assertEquals(new Map<String, Passenger__c>(passengers), BE8_GlobalUtility.getSObjectMap('Id', passengers));
	}

	@isTest static void testGetSObjectMapBySet() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Map<String, sObject> objMap = BE8_GlobalUtility.getSObjectMap(new Set<String> {'Id', 'Sector__c'}, passengers);
		Assert.assertEquals(passengers.size(), objMap.size());
	}

	@isTest static void testGetSObjectListMapByString() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Map<String, List<sObject>> objMapBySector = BE8_GlobalUtility.getSObjectListMap('Sector__c', passengers);
		Assert.assertEquals(1, objMapBySector.size());
		Assert.assertEquals(10, objMapBySector.values().get(0).size());

		Map<String, List<sObject>> objMapById = BE8_GlobalUtility.getSObjectListMap('Id', passengers);
		Assert.assertEquals(10, objMapById.size());
		Assert.assertEquals(1, objMapById.values().get(0).size());
	}

	@isTest static void testGetSObjectListMapBySet() {
		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		insert flight;
		List<Passenger__c> passengers = MockupData_Test.createBookingPassengers(10, flight.Id, 'C', 'C');
		insert passengers;

		Map<String, List<sObject>> objMapBySector = BE8_GlobalUtility.getSObjectListMap(new Set<String> {'Sector__c', 'FlightId__c'}, passengers);
		Assert.assertEquals(1, objMapBySector.size());
		Assert.assertEquals(10, objMapBySector.values().get(0).size());

		Map<String, List<sObject>> objMapById = BE8_GlobalUtility.getSObjectListMap(new Set<String> {'Id', 'Sector__c'}, passengers);
		Assert.assertEquals(10, objMapById.size());
		Assert.assertEquals(1, objMapById.values().get(0).size());
	}

	@isTest static void testConvertDurationToMiniteUnit() {
		Assert.assertEquals('650', BE8_GlobalUtility.convertDurationToMiniteUnit('1050', null));
	}

	@isTest static void testGetExistingAccount() {
		Account account = MockupData_Test.createAccount('AccountName');
		insert account;

		Membership__c membership = MockupData_Test.createMembership();
		membership.EXTMember__c = '1900';
		membership.Status__c = BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE;
		membership.AccountId__c = account.Id;
		insert membership;

		Map<String, String> actualMap = BE8_GlobalUtility.getExistingAccount(new List<String> {'1900'});
		Assert.assertEquals(account.Id, actualMap.get('1900'));
	}

	@isTest static void testGetExistingAccountMember() {
		Account account = MockupData_Test.createAccount('AccountName');
		insert account;

		Membership__c membership = MockupData_Test.createMembership();
		membership.EXTMember__c = '1900';
		membership.Status__c = BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE;
		membership.AccountId__c = account.Id;
		insert membership;

		Map<String, Membership__c> actualMap = BE8_GlobalUtility.getExistingAccountMember(new List<String> {'1900'});
		Assert.assertEquals(membership.Id, actualMap.get('1900').Id);

	}

	@isTest static void testPrint() {
		Account account = MockupData_Test.createAccount('accountName');
		BE8_GlobalUtility.print(Database.upsert(new List<Account> {account}));
		BE8_GlobalUtility.print('prefix', Database.upsert(new List<Account> {account}));
	}

	@isTest static void testGetErrorMessage() {
		Account account = MockupData_Test.createAccount(null);
		String errorMsg = null;
		errorMsg = BE8_GlobalUtility.getErrorMessage(Database.upsert(new List<Account> {account}, false));
		Assert.assertNotEquals('', errorMsg);

		account.Name = 'AccountName';
		errorMsg = BE8_GlobalUtility.getErrorMessage(Database.upsert(new List<Account> {account}));
		Assert.assertEquals('', errorMsg);

		account.Name = 'AccountName2';
		errorMsg = BE8_GlobalUtility.getErrorMessage(Database.update(new List<Account> {account}));
		Assert.assertEquals('', errorMsg);

		account.Name = null;
		errorMsg = BE8_GlobalUtility.getErrorMessage(Database.update(new List<Account> {account}, false));
		Assert.assertNotEquals('', errorMsg);

		errorMsg = BE8_GlobalUtility.getErrorMessage(Database.delete(new List<Account> {account}));
		Assert.assertEquals('', errorMsg);
	}

	@isTest static void testAbortScheduledJob() {
		PreFlightBatchScheduler scheduler = new PreFlightBatchScheduler('', '', null, '', 1);
		String sch = '0 0 0 1 1 ? 2022';
		Test.startTest();
		String jobID = system.schedule('Test Job', sch, scheduler);
		BE8_GlobalUtility.abortScheduledJob('Test Job');
		Test.stopTest();

		List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
		                             FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Test Job'];

		Assert.assertEquals(0, jobList.size());
	}

	@isTest static void testAbortScheduledJobByState() {
		PreFlightBatchScheduler scheduler = new PreFlightBatchScheduler('', '', null, '', 1);
		String sch = '0 0 0 1 1 ? 2022';

		Test.startTest();
		String jobID = system.schedule('Test Job', sch, scheduler);
		BE8_GlobalUtility.abortScheduledJob('Test Job', 'WAITING');
		Test.stopTest();

		List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
		                             FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Test Job'];

		Assert.assertEquals(0, jobList.size());
	}

	@isTest static void testAbortScheduledJobBySet() {
		PreFlightBatchScheduler scheduler = new PreFlightBatchScheduler('', '', null, '', 1);
		String sch = '0 0 0 1 1 ? 2022';
		Test.startTest();
		String jobID = system.schedule('Test Job', sch, scheduler);
		BE8_GlobalUtility.abortScheduledJob(new Set<String> {'Test Job'});
		Test.stopTest();

		List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
		                             FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Test Job'];
		Assert.assertEquals(0, jobList.size());
	}

	@isTest static void testMassDeleteJobs() {
		PreFlightBatchScheduler scheduler = new PreFlightBatchScheduler('', '', null, '', 1);
		String sch = '0 0 0 1 1 ? 2022';
		Test.startTest();
		String jobID = system.schedule('Test Job', sch, scheduler);
		BE8_GlobalUtility.massDeleteJobs(new List<Id> {jobID});
		Test.stopTest();

		List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
		                             FROM CronTrigger WHERE CronJobDetail.Name LIKE 'Test Job'];
		Assert.assertEquals(0, jobList.size());
	}

	@isTest static void testGetMsgBetween() {
		Assert.assertEquals('And', BE8_GlobalUtility.getMsgBetween('StartAndEnd', 'Start', 'End'));
	}

	@isTest static void testGetCrewIdByUserId() {
		Crew__c crew = MockupData_Test.createCrew('firstname', 'lastname', 'personalId', 'rank');
		insert crew;

		Crew_Mapping__c crewMapping = MockupData_Test.createCrewMapping();
		crewMapping.UserId__c = UserInfo.getUserId();
		crewMapping.isActive__c = true;
		crewMapping.CrewId__c = crew.Id;
		insert crewMapping;

		Test.startTest();
		Id crewId = BE8_GlobalUtility.getCrewIdByUserId(UserInfo.getUserId());
		Test.stopTest();

		Assert.assertEquals(crew.Id, crewId);
	}

	@isTest static void testGetCurrentCrewMapping() {
		Crew_Mapping__c crewMapping = MockupData_Test.createCrewMapping();
		crewMapping.UserId__c = UserInfo.getUserId();
		crewMapping.isActive__c = true;
		insert crewMapping;

		Test.startTest();
		Crew_Mapping__c actualCrewMapping = BE8_GlobalUtility.getCurrentCrewMapping(UserInfo.getUserId());
		Test.stopTest();

		Assert.assertEquals(crewMapping.Id, actualCrewMapping.Id);
	}

	@isTest static void testUpdateLastSyncTimeOfUser() {
		Datetime expectSynTime = System.now();
		expectSynTime = expectSynTime.addDays(-1);

		Crew_Mapping__c crewMapping = MockupData_Test.createCrewMapping();
		crewMapping.UserId__c = UserInfo.getUserId();
		crewMapping.isActive__c = true;
		insert crewMapping;

		Test.startTest();
		BE8_GlobalUtility.updateLastSyncTimeOfUser(expectSynTime, UserInfo.getUserId());
		Test.stopTest();

		Crew_Mapping__c actualCrewMapping = [SELECT Id, Last_Sync_Time__c FROM Crew_Mapping__c WHERE Id = :crewMapping.Id];
		Assert.assertEquals(expectSynTime, actualCrewMapping.Last_Sync_Time__c);
	}

	@isTest static void testGetFlightIdSetFromUserId() {
		Crew__c crew = MockupData_Test.createCrew('firstname', 'lastname', '123456', 'rank');
		insert crew;

		Crew_Mapping__c crewMapping = MockupData_Test.createCrewMapping();
		crewMapping.UserId__c = UserInfo.getUserId();
		crewMapping.isActive__c = true;
		crewMapping.CrewId__c = crew.Id;
		insert crewMapping;

		Flight__c flight = MockupData_Test.createFlight('TGXXX', '', 1);
		flight.STA_UTC__c = String.valueOf(System.now().addDays(1));
		flight.STD_UTC__c = String.valueOf(System.now().addDays(1));
		flight.Flight_External_ID__c = 'TG0308_28OCT16_1';
		insert flight;

		Crew_List__c crewList = MockupData_Test.createCrewList('Firstname Lastname', flight.Flight_External_ID__c, '123456', '123456');
		crewList.Flight_Temp__c = 'TG0308_28OCT16_1';
		crewList.CrewId__c = crew.Id;
		insert crewList;

		Test.startTest();
		Set<Id> flightIdSet =  BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
		Test.stopTest();

		Assert.assertEquals(new Set<Id> {flight.Id}, flightIdSet);
	}

	@isTest static void testGetObjectNameFromRecordIdPrefix() {
		Assert.assertEquals('Account', BE8_GlobalUtility.getObjectNameFromRecordIdPrefix('001'));
	}

	@isTest static void testGenerateRandomString() {
		Test.startTest();
		String result = BE8_GlobalUtility.generateRandomString(4);
		Test.stopTest();

		System.assertEquals(4, result.length());
		String regex = '^[a-zA-Z0-9]*$' ;
		Pattern regexPattern = Pattern.compile(regex);
		Matcher regexMatcher = regexPattern.matcher(result);
		System.assert(regexMatcher.matches());
	}

	@isTest static void testReplaceCharToString() {
		String str = '';
		Test.startTest();
		str = BE8_GlobalUtility.replaceCharToString('12345678', '4', 'XXX');
		Test.stopTest();

		Assert.assertEquals('123XXX5678', str);
	}

	@isTest static void testSubStringByMaxLength(){
        String test1 = '123123123123123';
        Assert.assertEquals(5, BE8_GlobalUtility.subStringByMaxLength(test1, 5).length());

        String test2 = '12345';
        Assert.assertEquals(test2.length(), BE8_GlobalUtility.subStringByMaxLength(test2, 20).length());
    }

    @isTest static void testGetSetString(){
    	Set<String> setString = new Set<String>{'01', '02', '03'};
    	String returnString = '';

    	Test.startTest();
    	returnString = BE8_GlobalUtility.getSetToString(setString);
    	Test.stopTest();

    	System.assertEquals('01, 02, 03', returnString, 'return string should be 01, 02, 03');
    }
}