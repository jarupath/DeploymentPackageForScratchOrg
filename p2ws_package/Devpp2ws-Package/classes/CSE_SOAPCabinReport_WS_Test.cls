@isTest
public with sharing class CSE_SOAPCabinReport_WS_Test {

	@testSetup static void MockData(){
		MockupData_Test.initializeWebServiceCustomSetting();
		MockupData_Test.initialApplicationLogCustomSetting();
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);
		List<Flight__c> flightList = new List<Flight__c>();
		List<Passenger__c> paxList = new List<Passenger__c>();
		List<Crew_List__c> crewlistList = new List<Crew_List__c>();
		List<Crew__c> cList = new List<Crew__c>();
		List<Case> caseList = new List<Case>();
		List<Master_Map__c> mastermapList = new List<Master_Map__c>();
		Aircraft__c air = new Aircraft__c(Aircraft_Registration__c = 'HS-TBA', Name = 'HS-TBA');
		insert air;

		Flight__c flight1 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    Departure_STN__c  = 'BKK',
		    Arrival_STN__c = '',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1',
		    AircraftId__c = air.Id
		);
		flightList.add(flight1);
		insert flightList;

		Passenger__c pax1 = new Passenger__c(
			Name = 'Pax Mockja',
			Booking_Class__c = 'W',
			Cabin_Code__c = 'F',
			First_Name__c = 'Mockja',
			Last_Name__c = 'Pax',
			Checkin_Seat__c = '12A',
			FlightId__c = flight1.Id
		);
		paxList.add(pax1);

		Crew__c c1 = new Crew__c(Crew_First_Name__c = 'Kung', Crew_Last_Name__c = 'Earth', Personel_Id__c = '12345');
		Crew__c c2 = new Crew__c(Crew_First_Name__c = 'Khun', Crew_Last_Name__c = 'Sawan', Personel_Id__c = '54321');
		cList.add(c1);
		cList.add(c2);

		insert cList;

		Crew_List__c crew1 = new Crew_List__c(
			Name = 'Kung Earth',
			Crew_Temp__c = '12345',
			Crew_External_ID__c = '12345_TG0628_20Dec25_1',
			FlightId__c = flight1.Id,
			CrewId__c = c1.Id
		);
		crewlistList.add(crew1);

		Crew_List__c crew2 = new Crew_List__c(
			Name = 'Khun Sawan',
			Crew_Temp__c = '54321',
			Crew_External_ID__c = '54321_TG0628_20Dec25_1',
			FlightId__c = flight1.Id,
			CrewId__c = c2.Id
		);
		crewlistList.add(crew2);

		Master_Map__c eq1 = new Master_Map__c(
			Name = 'ELECTRICAL & PNEUMATIC HEADPHONE', 
			Field_Name__c = 'SERVICE EQUIPMENT');
		mastermapList.add(eq1);

		Master_Map__c eq2 = new Master_Map__c(
			Name = 'HEADPHONE BODY',
			Field_Name__c = 'PART',
			Depend_On_Object__c = eq1.Id);
		mastermapList.add(eq2);

		insert crewlistList;
		insert paxList;
		insert mastermapList;

		List<Crew__c> crewList = [SELECT Id FROM Crew__c];
		System.debug('JK: crew - ' + JSON.serialize(crewList));

		List<MB_RESTRequestInfoModel.incident_model> incidentModelList = MockupData_Test.getIncidentModelList(1, flight1.Id, crew1.Id, eq1.Id, eq2.Id, 2);

		Case case1 = new Case(
			Json_Body__c = JSON.serialize(incidentModelList.get(0)), 
			Status = 'OPEN'
		);
		case1.FlightId__c = flight1.Id;
		case1.PassengerId__c = pax1.Id;
		case1.Created_By_Crew__c = crewList.get(0).Id;
		case1.Reported_By_Crew__c = crewList.get(1).Id;
		caseList.add(case1);
		insert caseList;
		System.debug('JK: case - ' + JSON.serialize(caseList));
	}

	@isTest static void testSendCabinReportToThai(){
		Test.setMock(HttpCalloutMock.class, new MockCabinReportWSResponseGenerator());
		Set<Id> caseIdSet = BE8_GlobalUtility.getIdSet('Id', [SELECT Id FROM Case]);
		Test.startTest();
		Map<String, CSE_SOAPCabinReport_WS.tgIDMap> responseMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, null);
		Test.stopTest();
		System.debug('JK: testSendCabinReportToThai - ' + JSON.serialize(responseMap));
        Map<String, CSE_SOAPCabinReport_WS.tgIDMap> returnMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, null);
        List<CSE_SOAPCabinReport_WS.tgIDMap> tgidMapList = new List<CSE_SOAPCabinReport_WS.tgIDMap>();
        for (CSE_SOAPCabinReport_WS.tgIDMap tgid : returnMap.values()) {
           tgidMapList.add(tgid);
        }
        CSE_SOAPCabinReport_WS.logMessage(tgidMapList);
        List<Application_Log__c> applogList = [SELECT Id, Name FROM Application_Log__c];
        System.debug('JK: logMessage - ' + JSON.serialize(tgidMapList));
		System.assertNotEquals(null, applogList, 'app log should not be null');
	}

	@isTest static void testSendCabinReportToThai_NullCaseIsSet(){
		Test.setMock(HttpCalloutMock.class, new MockCabinReportWSResponseGenerator());
		Set<Id> caseIdSet = null;
		Test.startTest();
		Map<String, CSE_SOAPCabinReport_WS.tgIDMap> responseMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, null);
		Test.stopTest();
		System.debug('JK: testSendCabinReportToThai_NullCaseIsSet - ' + JSON.serialize(responseMap));
        Map<String, CSE_SOAPCabinReport_WS.tgIDMap> returnMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, null);
        List<CSE_SOAPCabinReport_WS.tgIDMap> tgidMapList = new List<CSE_SOAPCabinReport_WS.tgIDMap>();
        for (CSE_SOAPCabinReport_WS.tgIDMap tgid : returnMap.values()) {
           tgidMapList.add(tgid);
        }
        CSE_SOAPCabinReport_WS.logMessage(tgidMapList);
        List<Application_Log__c> applogList = [SELECT Id, Name FROM Application_Log__c];
        System.assertNotEquals(null, applogList, 'app log should not be null');
	}
	
	@isTest static void testUpsertCabinReport_ResponseContainsTGID_ReturnCorrectResponseModel() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockCabinReportWSResponseGenerator());
		Test.startTest();
		CSE_SOAPCabinReport_WS.CabinReportModel c = new CSE_SOAPCabinReport_WS.CabinReportModel();
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = new CSE_SOAPCabinReport_WS().upsertCabinReport(c);
		Test.stopTest();
		CSE_SOAPCabinReport_WS.logMessage(new List<CSE_SOAPCabinReport_WS.CabinReportResponseModel>{m});
		List<Application_Log__c> applogList = [SELECT Id, Name FROM Application_Log__c];
		System.assertNotEquals(null, applogList, 'app log should not be null');
		System.assertEquals('T00061/2016', m.tgID);
		System.assertEquals(true, m.status);
	}

	@isTest static void testUpsertCabinReport_ResponseContainsTGID_NullParameter() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockCabinReportWSResponseGenerator());
		Test.startTest();
		CSE_SOAPCabinReport_WS.CabinReportModel c = new CSE_SOAPCabinReport_WS.CabinReportModel();
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = new CSE_SOAPCabinReport_WS().upsertCabinReport(null);
		Test.stopTest();
		CSE_SOAPCabinReport_WS.logMessage(new List<CSE_SOAPCabinReport_WS.CabinReportResponseModel>{m});
		List<Application_Log__c> applogList = [SELECT Id, Name FROM Application_Log__c];
		System.assertNotEquals(null, applogList, 'app log should not be null');
		System.assertEquals(false, m.status);
	}

	@isTest static void testGetResponseModel_XMLContainsTGID_ReturnValidData(){
		String xml = '' +
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
				'<soapenv:Body>' +
					'<ns2:InsertCabinReportResponse xmlns:ns2="http://bean.crmsinterface.cw.tg/">' +
  						'<return>T00061/2016</return>' +
					'</ns2:InsertCabinReportResponse>' +
  				'</soapenv:Body>' +
  			'</soapenv:Envelope>';
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = CSE_SOAPCabinReport_WS.getResponseModel(xml, '');
		System.assertEquals('T00061/2016', m.tgID);
		System.assertEquals(true, m.status);
	}

	@isTest static void testGetResponseModel_XMLContainsException_ReturnErrorData(){
		String xml = '' +
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
				'<soapenv:Body>' +
					'<soapenv:Fault>' +
  						'<faultcode>soapenv:Server</faultcode>' +
  						'<faultstring>Flight No Error format</faultstring>' +
						'<detail>' +
							'<ns2:Exception xmlns:ns2="http://bean.crmsinterface.cw.tg/">' +
  								'<message>Flight No Error format</message>' +
  							'</ns2:Exception>' +
  						'</detail>' +
  					'</soapenv:Fault>' +
  				'</soapenv:Body>' +
  			'</soapenv:Envelope>';
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = CSE_SOAPCabinReport_WS.getResponseModel(xml, '');
		System.assertEquals('Flight No Error format', m.errorMessage);
		System.assertEquals(false, m.status);
	}

	@isTest static void testGetResponseModel_XMLContainsException_ReturnErrorData_InvalidDescription(){
		String xml = '' +
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
				'<soapenv:Body>' +
					'<soapenv:Fault>' +
  						'<faultcode>soapenv:Server</faultcode>' +
  						'<faultstring>Flight No Error format</faultstring>' +
						'<detail>' +
  						'</detail>' +
  					'</soapenv:Fault>' +
  				'</soapenv:Body>' +
  			'</soapenv:Envelope>';
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = CSE_SOAPCabinReport_WS.getResponseModel(xml, '');
		System.assertEquals('Error data has return invalid description.', m.errorMessage);
		System.assertEquals(false, m.status);
	}

	@isTest static void testGetResponseModel_XMLContainsException_ReturnErrorData_ResponseNull(){
		String xml = null;
		CSE_SOAPCabinReport_WS.CabinReportResponseModel m = CSE_SOAPCabinReport_WS.getResponseModel(xml, '');
		System.assertEquals('Error no data response', m.errorMessage);
		System.assertEquals(false, m.status);
	}
}