@isTest
private class MB_RESTAircraftIncidentServiceTest {

	@testSetup static void setUp() {
		MockupData_Test.initializeWebServiceCustomSetting();
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}

	@isTest static void testCreateSingleEquipmentIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};

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
		MB_RESTAircraftIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
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
		MB_RESTAircraftIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		List<Case> createdCaseList = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey];
		Assert.assertEquals(1, createdCaseList.size());
		Case cabinLogCase = [SELECT Id, RecordType.DeveloperName, Passengerid__c, (SELECT Id FROM Case_Group_Members__r) FROM Case WHERE Mobile_App_Key__c = :mobileAppKey AND RecordType.Name = :BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE LIMIT 1];
		Assert.assertEquals(2, cabinLogCase.Case_Group_Members__r.size());
		//Assert.assertEquals(passengerList[0].Id, createdCaseList[0].Passengerid__c);
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
		

		Account ropAccount = new Account(Name = 'TEST');
		insert ropAccount;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		passenger.AccountId__c = ropAccount.Id;
		insert passenger;

		Master_Map__c equipment = new Master_Map__c(Name = 'Equipment', Field_Name__c = BE8_GlobalConstants.SERVICE_EQUIPMENT);
		insert equipment;

		Id maintenanceCaseRecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		List<Case> allCaseList = new List<Case>();
		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		Case caseOnAccountFromPreviousFlight = new Case(AccountId = ropAccount.Id, SEQ_NO_Display__c = 'CF002F20122017', EquipmentId__c = equipment.Id, Status = 'Open', A_C_REG_ID__c = aircraft.Id,RecordTypeId = maintenanceCaseRecordTypeId);
		allCaseList.add(caseOnAccountFromPreviousFlight);
		Case caseOnPassengerOfThisFlight = new Case(AccountId = ropAccount.Id, Passengerid__c = passenger.Id, Flightid__c = flight.Id, A_C_REG_ID__c = aircraft.Id, SEQ_NO_Display__c = 'CF003F20122017', EquipmentId__c = equipment.Id, Status = 'Open', RecordTypeId = maintenanceCaseRecordTypeId);
		allCaseList.add(caseOnPassengerOfThisFlight);
		insert allCaseList;

		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id));
		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id));
		insert allCaseGroupMemberList;

		List<MB_RestResponseInfoModel.incident_model> incidentList = MB_RESTAircraftIncidentService.retrieveIncidentInfo();
		Assert.assertEquals(2, incidentList.size());
	}

	@isTest static void testCreateDuplicateEquipmentIncident() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);

		Flight__c flight = MockupData_Test.createFlight('0998', '01Oct16', 1, 'XXXX1', 'A380');
		insert flight;
		Crew__c airPurser = new Crew__c(Personel_Id__c = 'AP');
		Crew__c airHostage = new Crew__c(Personel_Id__c = 'AH');
		insert new List<Crew__c> {airPurser, airHostage};
		
		//List<Passenger__c> passengerList = new List<Passenger__c> {
		//	new Passenger__c(Name = 'Test1', FlightId__c = flight.Id)
		//};
		//insert passengerList;
		Master_Map__c equipment = new Master_Map__c(Name = 'Equipment', Field_Name__c = BE8_GlobalConstants.SERVICE_EQUIPMENT);
		insert equipment;
		Master_Map__c part = new Master_Map__c(Name = 'Part', Field_Name__c = 'PART', Depend_On_Object__c = equipment.Id);
		insert part;

		String mobileAppKey = '1';
		String seqNo = 'TEST';
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
		incident.seqNo = seqNo;
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

		MB_RestRequestInfoModel.incident_model incident2 = new MB_RestRequestInfoModel.incident_model();
		incident2.id = mobileAppKey;
		incident2.fltId = flight.Id;
		incident2.creBy = airPurser.Id;
		incident2.repBy = airHostage.Id;
		incident2.descr = 'Seat Broken.';
		incident2.isLog = 1;
		incident2.isMulti = 0;
		incident2.isVoided = 0;
		incident2.rptType = 'Problem';
		incident2.inCate = '1';
		incident2.equipId = equipment.Id;
		incident2.partId = part.Id;
		incident2.seqNo = seqNo;
		incident2.condi = 'ADJUST;BREAK';
		incident2.logType = '' + BE8_GlobalConstants.CASE_LOG_TYPE_CABIN_LOG_INTEGER;
		incident2.status = 1;
		incident2.posMem = new List<MB_RestRequestInfoModel.incident_posMem>();

		List<MB_RestResponseInfoModel.incident_model> resultList = MB_RESTAircraftIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident});
		Assert.assertEquals(1, resultList.size());
		resultList = MB_RESTAircraftIncidentService.createIncident(new List<MB_RestRequestInfoModel.incident_model> {incident2});
		Assert.assertEquals(1, resultList.size());
	}

	@isTest static void testGetChangeSeatCaseGroupMemberList() {
		List<MB_RestRequestInfoModel.incident_changeSeatMem> chSeat = new List<MB_RestRequestInfoModel.incident_changeSeatMem>();
		MB_RestRequestInfoModel.incident_changeSeatMem eachMem = new MB_RestRequestInfoModel.incident_changeSeatMem();
		chSeat.add(eachMem);
		IncidentService.getChangeSeatCaseGroupMemberList(chSeat, null, null, null);
	}
}