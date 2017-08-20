@isTest
private class MB_RESTLOPAServiceTest {

	@testSetup static void setUp() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}

	@isTest static void testRetrieveLOPAInfo() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_GROUP_MEMBER_TRIGGER, false);

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
		passenger.Checkin_Seat__c = '1A';
		insert passenger;

		List<Case> allCaseList = new List<Case>();
		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		Case caseOnAccountFromPreviousFlight = new Case(AccountId = ropAccount.Id);
		allCaseList.add(caseOnAccountFromPreviousFlight);
		Case caseOnPassengerOfThisFlight = new Case(AccountId = ropAccount.Id, Passengerid__c = passenger.Id, Flightid__c = flight.Id, A_C_REG_ID__c = aircraft.Id);
		allCaseList.add(caseOnPassengerOfThisFlight);
		insert allCaseList;

		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id, Position__c = '1A'));
		allCaseGroupMemberList.add(new Case_Group_Member__c(AccountId__c = ropAccount.Id, CaseId__c = caseOnAccountFromPreviousFlight.Id));
		insert allCaseGroupMemberList;

		MB_RestResponseInfoModel.lopaInfo_model lopaModel = MockupData_Test.getMockUpLOPA_HSTUB();
		String lopaJSON = System.JSON.serialize(lopaModel);
		Attachment lopaAttachment = new Attachment(Name = 'Master_LOPA.txt', Body = Blob.valueOf(lopaJSON), ParentId = flight.Id);
		insert lopaAttachment;

		MB_RESTLOPAService.retrieveLOPAInfo();
	}

}