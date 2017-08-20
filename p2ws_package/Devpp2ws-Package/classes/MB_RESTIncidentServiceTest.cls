@isTest
private class MB_RESTIncidentServiceTest {

	@testSetup static void setUp() {
		MockupData_Test.initializeWebServiceCustomSetting();
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}

	@isTest static void testCreateSinglePassengerIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		flight.Name = 'TG998 / 01OCT16';
		insert flight;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		insert passenger;
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Passenger complained.';
		incident.subject = 'Passenger Incident';
		incident.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_DECK_LOG_INTEGER;
		incident.isLog = 0;
		incident.isMulti = 0;
		incident.isVoided = 0;
		incident.rptType = 'Complaint';
		incident.inCate = '1';
		incident.status = 1;
		incident.paxMem = new List<MB_RestRequestInfoModel.incident_paxMem>();
		MB_RestRequestInfoModel.incident_paxMem mem = new MB_RestRequestInfoModel.incident_paxMem();
		mem.id = passenger.Id;
		//mem.newPos = '14F';
		//mem.newClass = 'First Class';
		incident.paxMem.add(mem);

		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
		Assert.assertEquals(1, createdCaseList[0].Case_Group_Members__r.size());
		Assert.assertEquals(passenger.Id, createdCaseList[0].Passengerid__c);
		Assert.assertEquals(flight.Name, responseList[0].fltNum);
	}

	@isTest static void testCreateMultiplePassengerIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		List<Passenger__c> passengerList = new List<Passenger__c> {
			MockupData_Test.createPassenger(flight.Id, 'F'),
			MockupData_Test.createPassenger(flight.Id, 'F'),
			MockupData_Test.createPassenger(flight.Id, 'F'),
			MockupData_Test.createPassenger(flight.Id, 'F')
		};
		insert passengerList;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Passengers complained.';
		incident.isLog = 0;
		incident.isMulti = 1;
		incident.isVoided = 0;
		incident.rptType = 'Complaint';
		incident.inCate = '1';
		incident.status = 1;
		incident.paxMem = new List<MB_RestRequestInfoModel.incident_paxMem>();
		for (Passenger__c passenger : passengerList) {
			MB_RestRequestInfoModel.incident_paxMem mem = new MB_RestRequestInfoModel.incident_paxMem();
			mem.id = passenger.Id;
			incident.paxMem.add(mem);
		}

		MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
		Assert.assertEquals(passengerList.size(), createdCaseList[0].Case_Group_Members__r.size());
		Assert.assertEquals(passengerList[0].Id, createdCaseList[0].Passengerid__c);
	}

	@isTest static void testCreateSingleEquipmentIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;
		//List<Passenger__c> passengerList = new List<Passenger__c> {
		//	new Passenger__c(Name = 'Test1', FlightId__c = flight.Id)
		//};
		//insert passengerList;
		Master_Map__c equipment = new Master_Map__c(Name = 'Equipment', Field_Name__c = BE8_GlobalConstants.SERVICE_EQUIPMENT);
		insert equipment;
		Master_Map__c part = new Master_Map__c(Name = 'Part', Field_Name__c = 'PART', Depend_On_Object__c = equipment.Id);
		insert part;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Seat Broken.';
		incident.isLog = 1;
		incident.isMulti = 0;
		incident.isVoided = 0;
		incident.rptType = 'Problem';
		incident.inCate = '1';
		incident.equipId = equipment.Id;
		incident.partId = part.Id;
		incident.seqNo = '1234';
		incident.condi = 'ADJUST;BREAK';
		incident.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_CABIN_LOG_INTEGER;
		incident.status = 1;
		incident.posMem = new List<MB_RestRequestInfoModel.incident_posMem>();
		MB_RestRequestInfoModel.incident_posMem mem = new MB_RestRequestInfoModel.incident_posMem();
		mem.Id = '1A';
		mem.impact = BE8_GlobalConstants.IMPACT_MAP_BY_STRING.get('Block');
		incident.posMem.add(mem);
		MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(2, createdCaseList.size());
		Case cabinLogCase = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id, Impact__c FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey AND RecordType.Name = :BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE LIMIT 1];
		Assert.assertEquals(1, cabinLogCase.Case_Group_Members__r.size());
		Assert.assertEquals(BE8_GlobalConstants.IMPACT_MAP_BY_INTEGER.get(mem.impact), cabinLogCase.Case_Group_Members__r.get(0).Impact__c);
	}

	@isTest static void testCreateMultipleEquipmentIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;
		//List<Passenger__c> passengerList = new List<Passenger__c> {
		//	new Passenger__c(Name = 'Test1', FlightId__c = flight.Id)
		//};
		//insert passengerList;
		Master_Map__c equipment = new Master_Map__c(Name = 'Equipment', Field_Name__c = BE8_GlobalConstants.SERVICE_EQUIPMENT);
		insert equipment;
		Master_Map__c part = new Master_Map__c(Name = 'Part', Field_Name__c = 'PART', Depend_On_Object__c = equipment.Id);
		insert part;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Seat Broken.';
		incident.isLog = 1;
		incident.isMulti = 0;
		incident.isVoided = 0;
		incident.rptType = 'Problem';
		incident.inCate = '1';
		incident.equipId = equipment.Id;
		incident.partId = part.Id;
		incident.seqNo = '1234';
		incident.condi = 'ADJUST;BREAK';
		incident.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_CABIN_LOG_INTEGER;
		incident.status = 1;
		incident.posMem = new List<MB_RestRequestInfoModel.incident_posMem>();
		MB_RestRequestInfoModel.incident_posMem mem1 = new MB_RestRequestInfoModel.incident_posMem();
		mem1.Id = '1A';
		incident.posMem.add(mem1);
		MB_RestRequestInfoModel.incident_posMem mem2 = new MB_RestRequestInfoModel.incident_posMem();
		mem1.Id = '2A';
		incident.posMem.add(mem2);
		MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(2, createdCaseList.size());
		Case cabinLogCase = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey AND RecordType.Name = :BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE LIMIT 1];
		Assert.assertEquals(2, cabinLogCase.Case_Group_Members__r.size());
		//Assert.assertEquals(passengerList[0].Id, createdCaseList[0].Passengerid__c);
	}

	@isTest static void testCreateEmergencyIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);

		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		insert passenger;
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Passenger Deceased.';
		incident.subject = 'Passenger Deceased';
		incident.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_DECK_LOG_INTEGER;
		incident.isLog = 0;
		incident.isMulti = 0;
		incident.isVoided = 0;
		incident.rptType = 'Information';
		incident.inCate = BE8_GlobalConstants.INCIDENT_CATEGORY_MOBILE_EMERGENCY;
		incident.status = 1;
		incident.emerType = BE8_GlobalConstants.EMERGENCY_TYPE_PASSENGER_DECEASE_INTEGER;
		incident.paxMem = new List<MB_RestRequestInfoModel.incident_paxMem>();
		incident.crewMem = new List<MB_RestRequestInfoModel.incident_crewMem>();
		incident.staffMem = new List<MB_RestRequestInfoModel.incident_staffMem>();
		MB_RestRequestInfoModel.incident_paxMem mem = new MB_RestRequestInfoModel.incident_paxMem();
		mem.id = passenger.Id;
		incident.paxMem.add(mem);
		MB_RestRequestInfoModel.incident_crewMem crewMem = new MB_RestRequestInfoModel.incident_crewMem();
		crewMem.Id = airPurser.Id;
		incident.crewMem.add(crewMem);
		MB_RestRequestInfoModel.incident_staffMem staffMem = new MB_RestRequestInfoModel.incident_staffMem();
		staffMem.id = 'TEST';
		incident.staffMem.add(staffMem);

		MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, Priority, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
		Assert.assertEquals(3, createdCaseList[0].Case_Group_Members__r.size());
		Assert.assertEquals(passenger.Id, createdCaseList[0].Passengerid__c);
		Assert.assertEquals(BE8_GlobalConstants.CASE_PRIORITY_URGENT, createdCaseList[0].Priority);
	}

	@isTest static void testCreatePassengerIncidentWithCompensation() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);

		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		insert passenger;
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		String mobileAppKey = '1';
		MB_RestRequestInfoModel.incident_model incident = new MB_RestRequestInfoModel.incident_model();
		incident.id = mobileAppKey;
		incident.fltId = flight.Id;
		incident.creBy = airPurser.Id;
		incident.repBy = airHostage.Id;
		incident.descr = 'Passenger complained.';
		incident.subject = 'Passenger Incident';
		incident.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_DECK_LOG_INTEGER;
		incident.isLog = 0;
		incident.isMulti = 0;
		incident.isVoided = 0;
		incident.rptType = 'Complaint';
		incident.inCate = '1';
		incident.status = 1;
		incident.seqNo = '1234';
		incident.paxMem = new List<MB_RestRequestInfoModel.incident_paxMem>();
		incident.compen = new List<MB_RestRequestInfoModel.incident_compensation>();
		MB_RestRequestInfoModel.incident_paxMem mem = new MB_RestRequestInfoModel.incident_paxMem();
		mem.id = passenger.Id;
		//mem.newPos = '14F';
		//mem.newClass = 'First Class';
		incident.paxMem.add(mem);
		MB_RestRequestInfoModel.incident_compensation compenMem = new MB_RestRequestInfoModel.incident_compensation();
		compenMem.detail = 'TEST';
		compenMem.type = 'Contact Center';
		compenMem.quantity = '100';
		compenMem.amount = '100';
		compenMem.paxId = passenger.Id;
		incident.compen.add(compenMem);

		MB_RESTIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r), (SELECT Id FROM Compensations__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
		Assert.assertEquals(1, createdCaseList[0].Case_Group_Members__r.size());
		Assert.assertEquals(1, createdCaseList[0].Compensations__r.size());
		Assert.assertEquals(passenger.Id, createdCaseList[0].Passengerid__c);
	}

	@isTest static void testRetrieveIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Aircraft__c aircraft = new Aircraft__c(Name = 'TEST');
		insert aircraft;
		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.STD_UTC__c = String.valueOf(DateTime.now());
		flight.STA_UTC__c = String.valueOf(DateTime.now().addHours(10));
		flight.AircraftId__c = aircraft.Id;
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		Crew_List__c crewList = new Crew_List__c(CrewId__c = airPurser.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = airPurser.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		Account ropAccount = new Account(Name = 'TEST');
		insert ropAccount;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		passenger.AccountId__c = ropAccount.Id;
		insert passenger;

		List<Case> allCaseList = new List<Case>();
		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		Case caseOnAccountFromPreviousFlight = new Case(AccountId = ropAccount.Id);
		allCaseList.add(caseOnAccountFromPreviousFlight);
		Case caseOnPassengerOfThisFlight = new Case(AccountId = ropAccount.Id, Passengerid__c = passenger.Id, Flightid__c = flight.Id, A_C_REG_ID__c = aircraft.Id);
		allCaseList.add(caseOnPassengerOfThisFlight);
		insert allCaseList;

		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id));
		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id));
		insert allCaseGroupMemberList;

		List<MB_RestResponseInfoModel.incident_model> incidentList = MB_RESTIncidentService.retrieveIncidentInfo();
		Assert.assertEquals(2, incidentList.size());
	}

}