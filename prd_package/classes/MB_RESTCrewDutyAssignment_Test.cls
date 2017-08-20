@isTest
private class MB_RESTCrewDutyAssignment_Test {
	@testSetup static void DataPreparation(){
		MockupData_Test.initialApplicationLogCustomSetting();

		List<TG_WS_SETTING__c> tgwssetting = new List<TG_WS_SETTING__c>();
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_ENDPOINT', TG_WS_VALUE__c = 'http://202.122.131.25/crew/update/crewrecord'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_USERNAME', TG_WS_VALUE__c = 'FB_SICSE'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_PASSWORD', TG_WS_VALUE__c = 'tgfbtgfb1'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_REQ_TXN_ID', TG_WS_VALUE__c = 'SFDC_SICSE'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_REQ_USER_ID', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_REQ_ID', TG_WS_VALUE__c = 'FB_SICSE'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT__REQ_PWD', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_SVC_VER', TG_WS_VALUE__c = 'v1_0'));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_MW_TXN_ID', TG_WS_VALUE__c = ''));
		tgwssetting.add(new TG_WS_SETTING__c(Name = 'CREW_DUTY_ASSIGNMENT_TIMEOUT', TG_WS_VALUE__c = '120000'));
		insert tgwssetting;

		List<Flight__c> flightList = new List<Flight__c>();
		List<Crew_List__c> crewlistList = new List<Crew_List__c>();

		Flight__c flight1 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    Departure_STN__c  = 'BKK',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1');

		Flight__c flight2 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    Departure_STN__c  = 'BKK',
		    STD_UTC__c = '20Dec25 0830',
		    STD_LT__c  = '20Dec25 1530',
		    STA_UTC__c = '20Dec25 1220',
		    STA_LT__c = '20Dec25 2020',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_2');

		flightList.add(flight1);
		flightList.add(flight2);
		insert flightList;

		Crew_List__c crew1 = MockupData_Test.createCrewList('Crew Test1', 'TG0628_20Dec25_1', '01234', '01234_TG0628_20Dec25_1');
		Crew_List__c crew2 = MockupData_Test.createCrewList('Crew Test2', 'TG0628_20Dec25_1', '01235', '01235_TG0628_20Dec25_1');
		Crew_List__c crew3 = MockupData_Test.createCrewList('Crew Test3', 'TG0628_20Dec25_1', '01236', '01236_TG0628_20Dec25_1');
		Crew_List__c crew4 = MockupData_Test.createCrewList('Crew Test4', 'TG0628_20Dec25_2', '01237', '01237_TG0628_20Dec25_2');
		Crew_List__c crew5 = MockupData_Test.createCrewList('Crew Test5', 'TG0628_20Dec25_2', '01238', '01238_TG0628_20Dec25_2');
		crewlistList.add(crew1);
		crewlistList.add(crew2);
		crewlistList.add(crew3);
		crewlistList.add(crew4);
		crewlistList.add(crew5);
		insert crewlistList;
	}
	
	@isTest static void testUpdateCrewDutyAssignmentWithSingleFlight() {
		setupWSCallout('s', 3);
		Set<String> fltIdSet = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1']).keySet();
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutymodel = getCrewDutyAssignmentMBModelList(fltIdSet);
		Test.startTest();
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = MB_RESTCrewDutyAssignment.updateCrewDutyAssignment(crewdutymodel);
		Test.stopTest();
		System.assertEquals('SUCCESS', response.status);
		System.assertEquals(3, response.recordNo);
	}

	@isTest static void testUpdateCrewDutyAssignmentWithMultiFlight() {
		setupWSCallout('s', 5);
		Set<String> fltIdSet = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1' OR Flight_External_ID__c = 'TG0628_20Dec25_2']).keySet();
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutymodel = getCrewDutyAssignmentMBModelList(fltIdSet);
		Test.startTest();
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = MB_RESTCrewDutyAssignment.updateCrewDutyAssignment(crewdutymodel);
		Test.stopTest();
		System.assertEquals('SUCCESS', response.status);
		System.assertEquals(5, response.recordNo);
	}

	@isTest static void testNumberOfReturnedApplicationLog(){
		setupWSCallout('s', 3);
		Set<String> fltIdSet = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1' OR Flight_External_ID__c = 'TG0628_20Dec25_2']).keySet();
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutymodel = getCrewDutyAssignmentMBModelList(fltIdSet);

		Test.startTest();
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = MB_RESTCrewDutyAssignment.updateCrewDutyAssignment(crewdutymodel);
		Test.stopTest();
		System.debug('debug applog');
		System.debug(JSON.serialize(AppLogger.getLogs()));
		System.debug(JSON.serialize(AppLogger.getLogModel().keySet()));
		System.debug(JSON.serialize(AppLogger.getLogModel().values()));

		List<Application_Log__c> applogList = [SELECT Id, Name, Source__c, Source_Function__c, Reference_Id__c, Reference_Information__c,  Message__c, Debug_Level__c FROM Application_Log__c];
		List<Attachment> attachList = [SELECT Id, Name, ParentId FROM Attachment];

		System.debug('JK: AppLogger');
		System.debug(JSON.serialize(AppLogger.getInstance()));

		//System.assertEquals(5, AppLogger.getLogs().size(), 'Amount of AppLogger\'s logs should be equal to 5 due to the number of crew list');
		//System.assertEquals(1, AppLogger.getLogModel().size(), 'Amount of AppLogger\'s logmodel should be equal to 1');
		//System.assertEquals(2, AppLogger.getAttachModel().values()[0].size(), 'Amount of attachment in AppLogger\'s logmodel should be equal to 2 in order to record web service request and response');
		System.assertEquals(6, applogList.size(), 'Amount of inserted Application Log should be equal to 6 (5 from logs and 1 from logmodel)');
		System.assertEquals(2, attachList.size());
	}

	private static void setupWSCallout(String calloutType, Integer recNo){
		Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
		if(calloutType == 's'){
			endpoint2TestResp.put(Mock_CSE_CrewDutyAssignment_Response.getCrewDutyAssignmentEndPoint(), Mock_CSE_CrewDutyAssignment_Response.getCrewDutyAssignmentResponseSuccess(recNo));	
		}
		else if(calloutType == 'e'){
			endpoint2TestResp.put(Mock_CSE_CrewDutyAssignment_Response.getCrewDutyAssignmentEndPoint(), Mock_CSE_CrewDutyAssignment_Response.getCrewDutyAssignmentResponseFailure());	
		}
		
		HttpCalloutMock multiCalloutMock = new MultiRequestMock(endpoint2TestResp);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
	}

	private static List<MB_RESTRequestInfoModel.crewDutyAssignment_model> getCrewDutyAssignmentMBModelList(Set<String> fltIdSet){
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> returnModel = new List<MB_RESTRequestInfoModel.crewDutyAssignment_model>();
		MockupData_Test.createMBCrewDutyAssignment(returnModel, fltIdSet);
		return returnModel;
	}
}