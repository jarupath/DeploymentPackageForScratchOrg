@isTest
private class InFlightLOPAStatusHandlerTest {
	private static String LAST_NAME = 'TEST';

	@testSetup static void setUp() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}

	private static void testAndAssert(String ffpTier, String expectedStatus) {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Account account = new Account(Name = LAST_NAME, Last_Name__c = LAST_NAME, Date_Of_Birth__c = Date.today(), ROP_Number__c = '234234234');
		insert account;
		Passenger__c passenger = new Passenger__c(Last_Name__c = LAST_NAME, Date_Of_Birth_Input__c = Date.today(), AccountId__c = account.Id, Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = ffpTier);
		insert passenger;
		passenger = [SELECT Id, Checkin_Seat__c , Booking_Seat__c, FFP_Tier__c, FFP_Carrier__c, FlightId__c, Cabin_Code__c, AccountId__r.Last_Name__c, AccountId__r.Date_Of_Birth__c, Last_Name__c, Date_of_Birth_Input__c, Match_with_ROP__c FROM Passenger__c WHERE Id = :passenger.Id];
		//Assert.assert(passenger.Match_with_ROP__c);
		String status = new InFlightLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, null, lopaPos);
		Assert.assertEquals(expectedStatus, status);
	}

	private static void testAndAssert(String ffpTier, String expectedStatus, String impact, Boolean hasPassenger) {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Account account = new Account(Name = LAST_NAME, Last_Name__c = LAST_NAME, Date_Of_Birth__c = Date.today(), ROP_Number__c = 'asdasddsa');
		insert account;
		Passenger__c passenger;
		if(hasPassenger){
			passenger = new Passenger__c(Last_Name__c = LAST_NAME, Date_Of_Birth_Input__c = Date.today(), AccountId__c = account.Id, Checkin_Seat__c = '1A', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = ffpTier);
			insert passenger;
			passenger = [SELECT Id, Checkin_Seat__c , Booking_Seat__c, FFP_Tier__c, FFP_Carrier__c, FlightId__c, Cabin_Code__c, AccountId__r.Last_Name__c, AccountId__r.Date_Of_Birth__c, Last_Name__c, Date_of_Birth_Input__c, Match_with_ROP__c FROM Passenger__c WHERE Id = :passenger.Id];
		}
		//Assert.assert(passenger.Match_with_ROP__c);
		Case maintenanceCase = new Case();
		insert maintenanceCase;
		Case_Group_Member__c caseGroupMember = new Case_Group_Member__c(CaseId__c = maintenanceCase.Id, Position__c = '1A', Impact__c = impact);

		String status = new InFlightLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, new List<Case_Group_Member__c> {caseGroupMember}, lopaPos);
		Assert.assertEquals(expectedStatus, status);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedFromLOPA() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', 'Z');
		String status = new InFlightLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.LOPA_STATUS_BLOCKED_FROM_LOPA, status);
	}

	@isTest static void testGetLOPAPositionStatus_Available() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		String status = new InFlightLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, null, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.LOPA_STATUS_AVAILABLE, status);
	}

	@isTest static void testGetLOPAPositionStatus_Occupied() {
		MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos = MockupData_Test.createMockUpLopaPos('1A', null);
		Passenger__c passenger = new Passenger__c(Checkin_Seat__c = '1A');
		String status = new InFlightLOPAStatusHandler().getLOPAPositionStatus('1A', BE8_GlobalConstants.TYPE_SEAT, passenger, null, lopaPos);
		Assert.assertEquals(BE8_GlobalConstants.LOPA_STATUS_OCCUPIED, status);
	}

	@isTest static void testGetLOPAPositionStatus_Blocked() {
		testAndAssert(null, BE8_GlobalConstants.LOPA_STATUS_BLOCK, BE8_GlobalConstants.IMPACT_BLOCK, false);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedOccupied() {
		testAndAssert(null, BE8_GlobalConstants.LOPA_STATUS_BLOCK_OCCUPIED, BE8_GlobalConstants.IMPACT_BLOCK, true);
	}

	@isTest static void testGetLOPAPositionStatus_Malfunction() {
		testAndAssert(null, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION, BE8_GlobalConstants.IMPACT_MALFUNCTION, false);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionOccupied() {
		testAndAssert(null, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_OCCUPIED, BE8_GlobalConstants.IMPACT_MALFUNCTION, true);
	}

	@isTest static void testGetLOPAPositionStatus_OccupiedPlatinum() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_PLATINUM);
		//testAndAssert(BE8_GlobalConstants.FFP_TIER_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_PLATINUM, BE8_GlobalConstants.IMPACT_MALFUNCTION, true);
	}

	@isTest static void testGetLOPAPositionStatus_OccupiedGold() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_GOLD, BE8_GlobalConstants.LOPA_STATUS_OCCUPIED_GOLD);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedPlatinum() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_BLOCK_PLATINUM, BE8_GlobalConstants.IMPACT_BLOCK, true);
	}

	@isTest static void testGetLOPAPositionStatus_BlockedGold() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_GOLD, BE8_GlobalConstants.LOPA_STATUS_BLOCK_GOLD, BE8_GlobalConstants.IMPACT_BLOCK, true);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionPlatinum() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_PLATINUM, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_PLATINUM, BE8_GlobalConstants.IMPACT_MALFUNCTION, true);
	}

	@isTest static void testGetLOPAPositionStatus_MalfunctionGold() {
		testAndAssert(BE8_GlobalConstants.FFP_TIER_GOLD, BE8_GlobalConstants.LOPA_STATUS_MALFUNCTION_GOLD, BE8_GlobalConstants.IMPACT_MALFUNCTION, true);
	}
}