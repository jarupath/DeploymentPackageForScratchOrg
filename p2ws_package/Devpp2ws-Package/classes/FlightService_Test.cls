@isTest
private class FlightService_Test {

	@isTest static void testCreateFlightsFromModelFromXMLSampleResponseShouldReturn2Flight() {
		String xmlFlightResponse = '<return>        <changeFlightDateLT/>        <changeFlightDateUTC/>        <changeFlightNo/>        <destination>ICN</destination>        <flightCancelFlag>false</flightCancelFlag>        <flightChangeFlag>false</flightChangeFlag>        <flightDateLT>30Sep16</flightDateLT>        <flightDateUTC>30Sep16</flightDateUTC>        <flightNo>628</flightNo>        <flightRemark/>        <legdetail>          <ATA_LT>30Sep16 1516</ATA_LT>          <ATA_UTC>30Sep16 0716</ATA_UTC>          <ATD_LT>30Sep16 1110</ATD_LT>          <ATD_UTC>30Sep16 0410</ATD_UTC>          <aircraftRegistration>HSTET  </aircraftRegistration>          <aircraftType>330</aircraftType>          <arrivalDelay/>          <arrivalSTN>HKG</arrivalSTN>          <arrivalSTNICAO>VHHH</arrivalSTNICAO>          <arrivalSTNName>HONG KONG                     </arrivalSTNName>          <arrivalTerminal/>          <belt/>          <blockTime>0306</blockTime>          <departureDelay>AM/0025</departureDelay>          <departureSTN>BKK</departureSTN>          <departureSTNICAO>VTBS</departureSTNICAO>          <departureSTNName>BANGKOK INTERNATIONAL         </departureSTNName>          <departureTerminal/>          <ETA_LT>30Sep16 1458</ETA_LT>          <ETA_UTC>30Sep16 0658</ETA_UTC>          <ETD_LT>30Sep16 1045</ETD_LT>          <ETD_UTC>30Sep16 0345</ETD_UTC>          <gate/>          <legSeq>1</legSeq>          <STA_LT>30Sep16 1430</STA_LT>          <STA_UTC>30Sep16 0630</STA_UTC>          <STD_LT>30Sep16 1045</STD_LT>          <STD_UTC>30Sep16 0345</STD_UTC>        </legdetail>        <legdetail>          <ATA_LT/>          <ATA_UTC/>          <ATD_LT/>          <ATD_UTC/>          <aircraftRegistration>HSTET  </aircraftRegistration>          <aircraftType>330</aircraftType>          <arrivalDelay/>          <arrivalSTN>ICN</arrivalSTN>          <arrivalSTNICAO>RKSI</arrivalSTNICAO>          <arrivalSTNName>INCHEON INTERNATIONAL         </arrivalSTNName>          <arrivalTerminal/>          <belt/>          <blockTime>0340</blockTime>          <departureDelay/>          <departureSTN>HKG</departureSTN>          <departureSTNICAO>VHHH</departureSTNICAO>          <departureSTNName>HONG KONG                     </departureSTNName>          <departureTerminal/>          <ETA_LT/>          <ETA_UTC/>          <ETD_LT/>          <ETD_UTC/>          <gate/>          <legSeq>2</legSeq>          <STA_LT>30Sep16 2010</STA_LT>          <STA_UTC>30Sep16 1110</STA_UTC>          <STD_LT>30Sep16 1530</STD_LT>          <STD_UTC>30Sep16 0730</STD_UTC>        </legdetail>        <nextFlightNo>657</nextFlightNo>        <nextFlightSTD_LT>30Sep16 2120</nextFlightSTD_LT>        <nextFlightSTD_UTC>30Sep16 1220</nextFlightSTD_UTC>        <origin>BKK</origin>      </return>';
		WS_FlightModel model = (WS_FlightModel) new XMLSerializer().deSerialize(xmlFlightResponse, WS_FlightModel.class, new Set<String> {'legdetail'});
		List<Flight__c> flightList = FlightService.createFlightsFromModel(model);
		System.assertEquals(2, flightList.size(), 'This flight must have 2 legs. (TG628)');

		for (Flight__c f : flightList) {
			System.assertEquals('BKK-HKG-ICN', f.Routing__c, 'The routing of the flight must be BKK-HKG-ICN, because the supplied input is from TG628 flight.');
		}

		List<Database.UpsertResult> upsertResultList = FlightService.upsertFlightWithAircraftByExternalId(flightList);
		for (Database.UpsertResult upsertResult : upsertResultList) {
			System.debug(upsertResult.getErrors());
			System.assertEquals(0, upsertResult.getErrors().size(), 'Upsert should not have error.');
		}
	}

	@isTest static void testGetExistingAircraft() {
		String hsTBAAircraftReg = 'HS-TBA';
		insert MockupData_Test.createAircraft(hsTBAAircraftReg, 'HS-TBA', '33H');
		Map<String, Aircraft__c> resultMap = FlightService.getExistingAircraft(new List<String> {hsTBAAircraftReg});
		System.assertEquals(1, resultMap.values().size(), 'The method should return only one aircraft.');
	}

	@isTest static void testCreateUpdatedChangedFlightForChangedFlight() {
		WS_FlightModel model = new WS_FlightModel();
		WS_FlightModel.Return_Z flightModel = new WS_FlightModel.Return_Z();
		String changeFlightNo = '9109';
		flightModel.origin = 'BKK';
		flightModel.destination = 'HKG';
		flightModel.changeFlightDateLT = '01DEC16';
		flightModel.changeFlightDateUTC = '01DEC16';
		flightModel.changeFlightNo = changeFlightNo;
		flightModel.flightCancelFlag = '0';
		flightModel.flightChangeFlag = '1';
		flightModel.flightDateLT = '01DEC16';
		flightModel.flightDateUTC = '30NOV16';
		flightModel.flightNo = '0910';
		flightModel.flightDateUTC = '30NOV16';
		Flight__c flight = FlightService.createUpdatedChangedFlight(flightModel);
		System.assert(flight.Flight_Change_Flag__c, 'Flight Change Flag must be set, because this flight has been changed to another flight on another day for some reason.');
		System.assertEquals(flight.Change_Flight_Number__c, changeFlightNo, 'Change Flight Number must be ' + changeFlightNo + '.');
	}

	@isTest static void testCreateUpdatedChangedFlightForCanceledFlight() {
		WS_FlightModel model = new WS_FlightModel();
		WS_FlightModel.Return_Z flightModel = new WS_FlightModel.Return_Z();
		flightModel.origin = 'BKK';
		flightModel.destination = 'HKG';
		flightModel.flightCancelFlag = '1';
		flightModel.flightChangeFlag = '0';
		flightModel.flightDateLT = '01DEC16';
		flightModel.flightDateUTC = '30NOV16';
		flightModel.flightNo = '0910';
		flightModel.flightDateUTC = '30NOV16';
		Flight__c flight = FlightService.createUpdatedChangedFlight(flightModel);
		System.assert(flight.Flight_Cancel_Flag__c, 'Flight Cancel Flag must be set, because this flight has been canceled for some reason.');
		System.assertEquals(flight.Change_Flight_Number__c, null, 'Change Flight Number must be null as it is a canceled flight case.');
	}

	@isTest static void testSchedulePreFlightBatch() {
		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.STD_UTC__c = String.valueOf(System.now().addHours(20));
		flight.STA_UTC__c = String.valueOf(System.now().addHours(20));
		flight.Flight_Date_LT__c = System.now().addHours(27).format('yyyy-MM-dd');
		insert flight;
		flight = [SELECT Id, Flight_External_ID__c FROM Flight__c WHERE Id = :flight.Id LIMIT 1];
		System.assert(flight.Flight_External_ID__c != null, 'Flight External Id must not be null, because it is used to create Job Queue and to maintain connection of Job Queue and the corresponding flight.');
		FlightService.schedulePreFlightBatch(new Set<Id> {flight.Id});
		List<Job_Queue__c> jobQueueList = [SELECT Id FROM Job_Queue__c];
		System.assertEquals(23, jobQueueList.size(), 'There must be 5 jobs which are 8hrs before scheduled departure, 2hrs before scheduled departure, half hrs before scheduled departure, one hour before scheduled landing and one hour after scheduled landing.');
	}

	@isTest static void testProcessFlightFromPreFlightBatch() {
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;
		Test.startTest();
		Test.setMock(WebServiceMock.class, new Mock_TG_Pax_WS.MockPax());
		FlightService.processFlightFromPreFlightBatch(new Set<Id> {flight.Id}, new List<String>(), false);
		Test.stopTest();
	}

	@isTest static void testExecuteBatchForDelayedFlight() {
		Map<String, SObject> changedFlightMapByChangedFlightNumber = new Map<String, SObject>();
		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.Flight_Master__c = 'TG0910_30Nov16';
		flight.Change_Flight_Number__c = 'TG9109';
		insert flight;
		changedFlightMapByChangedFlightNumber.put(flight.Change_Flight_Number__c, flight);
		FlightService.executeBatchForDelayedFlight(changedFlightMapByChangedFlightNumber);
	}

	@isTest static void testExecuteBatchForDelayedFlightRetrial() {
		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.Flight_Master__c = 'TG0910_30Nov16';
		flight.Change_Flight_Number__c = 'TG9109';
		flight.Previous_Flight_Master__c = 'TG0910_30Nov16';
		insert flight;
		FlightService.executeBatchForDelayedFlightRetrial(new List<Flight__c> {flight});
	}
	
	@isTest static void testCalculateFlightRegion(){
	    CTI_Area_with_Sector__c ctiArea = new CTI_Area_with_Sector__c(Name = '910BKKLHR', Flight_Number__c = '910', Sector__c = 'BKKLHR', Area__c = 'Europe', Region__c = 'Intercontinental');
	    insert ctiArea;
	    
	    Flight__c flight = MockupData_Test.getMockUpFlight();
	    insert flight;
	    flight = [SELECT Id, Flight_Area__c, Flight_Region__c FROM Flight__c WHERE Id =: flight.Id];
	    Assert.assertEquals('Europe', flight.Flight_Area__c);
	    Assert.assertEquals('Intercontinental', flight.Flight_Region__c);
	}
}