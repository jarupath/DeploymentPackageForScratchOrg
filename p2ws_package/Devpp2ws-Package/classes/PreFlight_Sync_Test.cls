@isTest
private class PreFlight_Sync_Test {
	@testSetup static void setup() {
		MockupData_Test.initializeWebServiceCustomSetting();
		TriggerActivator.initializeTriggerActivation(true);

		Flight__c flight = MockupData_Test.createFlight('TG0628', '2017-03-16', 1);
		insert flight;
	}

	public static Flight__c getFlight() {
		List<Flight__c> flights = [SELECT Id, Flight_Master__c, Flight_Number__c, Flight_Date_UTC__c, Flight_Date_LT__c, Flight_External_Id__c, Departure_STN__c, Arrival_STN__c, Leg_Number__c, STD_LT__c, STD_UTC__c FROM Flight__c];
		return flights.get(0);
	}

	@isTest
	static void testFutureSync() {
		Flight__c flight = getFlight();
		PreFlight_Sync.FutureSync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_24H_BF_TAKEOFF);
	}

	@isTest 
	static void testQueueableSync() {
		Flight__c flight = getFlight();
		PreFlight_Sync.QueueableSync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_24H_BF_TAKEOFF);
	}

	@isTest 
	static void testAsyncPreFlight() {
		Flight__c flight = getFlight();
		PreFlight_Sync.AsyncPreFlight(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_24H_BF_TAKEOFF);
	}

	@isTest
	static void testSetupWhichObjectToUpdate() {
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_80H_BF_TAKEOFF);
		Assert.assertEquals(false, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(false, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(false, preflightSync.updateCrew);
		Assert.assertEquals(true, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_24H_BF_TAKEOFF);
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(false, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(true, preflightSync.updateCrew);
		Assert.assertEquals(false, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_8H_BF_TAKEOFF);
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(false, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(true, preflightSync.updateCrew);
		Assert.assertEquals(false, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF);
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(false, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(true, preflightSync.updateCrew);
		Assert.assertEquals(false, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(true, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(true, preflightSync.updateCrew);
		Assert.assertEquals(true, preflightSync.updateLopa);
		Assert.assertEquals(true, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF);
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(true, preflightSync.updatePassenger);
		Assert.assertEquals(true, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(true, preflightSync.updateCrew);
		Assert.assertEquals(false, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);

		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_LANDING);
		Assert.assertEquals(true, preflightSync.updateFlight);
		Assert.assertEquals(false, preflightSync.updatePassenger);
		Assert.assertEquals(false, preflightSync.updatePassengerWithNewWS);
		Assert.assertEquals(false, preflightSync.updateCrew);
		Assert.assertEquals(false, preflightSync.updateLopa);
		Assert.assertEquals(false, preflightSync.updateROP);
		Test.stopTest();
	}

	@isTest
	static void testSyncAll() {
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		preflightSync.updateLopa = true;
		preflightSync.sync();
		Test.stopTest();
	}


	@isTest
	static void testSyncWithCreateChatteGroup() {
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.MANUAL_JOB);
		preflightSync.updateLopa = true;
		preflightSync.sync();
		Test.stopTest();
	}

	@isTest
	static void testSyncROPWithoutPassenger() {
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		preflightSync.updateROP = true;
		preflightSync.updatePassenger = false;
		preflightSync.sync();
		Test.stopTest();
	}

	@isTest
	static void testSyncWithoutUpdateFlight() {
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		preflightSync.updateFlight = false;
		preflightSync.sync();
		Test.stopTest();
	}

	@isTest
	static void testRetrieveFlight() {
		Map<String, HttpCalloutMock> httpCalloutMockMap = new Map<String, HttpCalloutMock>();
		httpCalloutMockMap.putAll(PreFlight_Mock.mockFlightWS());
		PreFlight_Mock.mockMultiCallout(null, httpCalloutMockMap);
		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		List<Flight__c> flights = preflightSync.retrieveFlight();
		Test.stopTest();
	}

	@isTest
	static void testRetrievePassenger() {
		Map<String, WebServiceMock> webserviceMockMap = new Map<String, WebServiceMock>();
		Map<String, HttpCalloutMock> httpCalloutMockMap = new Map<String, HttpCalloutMock>();
		webserviceMockMap.putAll(PreFlight_Mock.mockPassengerWS());
		httpCalloutMockMap.putAll(PreFlight_Mock.mockNewPassengerWS());
		PreFlight_Mock.mockMultiCallout(webserviceMockMap, httpCalloutMockMap);

		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		Map<String, Object> passengerMap = preflightSync.retrievePassenger(new List<Flight__c> {flight});
		Test.stopTest();
	}

	@isTest
	static void testRetrieveCrew() {
		Map<String, HttpCalloutMock> httpCalloutMockMap = new Map<String, HttpCalloutMock>();
		httpCalloutMockMap.putAll(PreFlight_Mock.mockCrewOnFlight());
		PreFlight_Mock.mockMultiCallout(null, httpCalloutMockMap);

		Flight__c flight = getFlight();
		PreFlight_Sync preflightSync;
		Test.startTest();
		preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', Integer.valueOf(flight.Leg_Number__c), BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
		List<Crew_List__c> crewLists = preflightSync.retrieveCrew(new List<Flight__c> {flight});
		Test.stopTest();
	}



	//@isTest
	//static void testRetrieveCrew() {
	//	Map<String, HttpCalloutMock> mockWSMap = new Map<String, HttpCalloutMock>();
	//	mockWSMap.putAll(PreFlight_Mock.mockFlightWS());
	//	PreFlight_Mock.mockMultiCallout(mockWSMap);

	//	Flight__c flight = MockupData_Test.createFlight('TG0628', '2017-03-16', 1);
	//	insert flight;

	//	Flight__c actualFlight = [SELECT Id, Flight_Master__c, Flight_Number__c, Flight_Date_UTC__c FROM Flight__c WHERE Id = :flight.Id];

	//	PreFlight_Sync preflightSync;
	//	Test.startTest();
	//	preflightSync = new PreFlight_Sync(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(flight.Flight_Date_UTC__c), 'UTC', BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
	//	List<Crew_List__c> crewLists = preflightSync.retrieveCrew(LIST flights);
	//	Test.stopTest();
	//}
}