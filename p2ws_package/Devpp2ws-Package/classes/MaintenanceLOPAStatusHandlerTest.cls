@isTest

private class MaintenanceLOPAStatusHandlerTest {
	@testSetup static void DataPreparation(){

		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		
	}
	
	@isTest static void testGetLOPAPositionStatus_BlockedFromLOPA() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', 'Z');
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCKED_FROM_LOPA, status);
	}

	@isTest static void testGetLOPAPositionStatus_Available() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_AVAILABLE, status);
	}

	@isTest static void testGetLOPAPositionStatus_Occupied() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A');
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_Blocked() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_BLOCK);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK, status);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedOccupied() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A');
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_BLOCK);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_Malfunction() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_MALFUNCTION);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION, status);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionOccupied() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A');
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_MALFUNCTION);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_OccupiedPlatinum() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_PLATINUM);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_OccupiedGold() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_GOLD);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedPlatinum() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_PLATINUM);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_BLOCK);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedGold() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_GOLD);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_BLOCK);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionPlatinum() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_PLATINUM);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_MALFUNCTION);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionGold() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_GOLD);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_MALFUNCTION);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_NoAction() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_GOLD);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = null);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_NO_ACTION, status);
	}

	@isTest static void testGetLOPAPositionStatus_Serviceable() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = BE8_GlobalConstants.FFP_TIER_GOLD);
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;
		Case maintenanceCase = new Case();
		maintenanceCase.Flightid__c = flight.Id;
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = BE8_GlobalConstants.IMPACT_SERVICABLE);
		String status = new MaintenanceLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.MAINTENANCE_LOPA_STATUS_SERVICEABLE, status);
	}
	
}