@isTest
private class CSE_SOAPCrewDutyAssignment_WS_Test {
	@testSetup static void DataPreparation(){
		MockupData_Test.initialApplicationLogCustomSetting();
		MockupData_Test.initializeWebServiceCustomSetting();

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
		    Arrival_STN__c = '',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1'
		);
		insert flightList;

		crewlistList.add(MockupData_Test.createCrewList('Earth Pho-thong', 'TG0628_20Dec25_1', '12345', '12345_TG0628_20Dec25_1'));
		crewlistList.add(MockupData_Test.createCrewList('Notto Sooddom', 'TG0628_20Dec25_1', '12346', '12346_TG0628_20Dec25_1'));
		crewlistList.add(MockupData_Test.createCrewList('Mai Meow', 'TG0628_20Dec25_1', '12345', '12347_TG0628_20Dec25_1'));
		insert crewlistList;


	}
	
	@isTest static void testGetSOAPRequest() {
		String NONCE_START_TAG = '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">';
		String NONCE_END_TAG = '</wsse:Nonce>';
		String CREATED_START_TAG = '<wsu:Created>';
		String CREATED_END_TAG = '</wsu:Created>';
		String REQ_TXN_ID_START_TAG = '<head:ReqTxnID>';
		String REQ_TXN_ID_END_TAG = '</head:ReqTxnID>';

		String req = '' + 
				'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:crew="http://xml.thaiairways.com/crew/update/crewrecord" xmlns:v1="http://xml.thaiairways.com/crew/update/crewrecord/insertdutyassign/v1_0"> '  +
				'    <soapenv:Header> '  +
				'        <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> '  +
				'            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871"> '  +
				'                <wsse:Username>FB_SICSE</wsse:Username> '  +
				'                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">tgfbtgfb1</wsse:Password> '  +
				'                <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary"></wsse:Nonce> '  +
				'                <wsu:Created></wsu:Created> '  +
				'            </wsse:UsernameToken> '  +
				'        </wsse:Security> '  +
				'        <head:ReqHeader> '  +
				'            <head:ReqDateTime>2017-01-18T13:20:00-05:00</head:ReqDateTime> '  +
				'            <head:ReqTxnID></head:ReqTxnID> '  +
				'            <head:SvcVer>v1_0</head:SvcVer> '  +
				'            <head:IsLastTxn>true</head:IsLastTxn> '  +
				'            <head:Credentials> '  +
				'                <head:MWCredential> '  +
				'                    <head:ReqID>FB_SICSE</head:ReqID> '  +
				'                    <head:ReqPwd/> '  +
				'                    <head:UserID/> </head:MWCredential> '  +
				'            </head:Credentials> '  +
				'        </head:ReqHeader> '  +
				'    </soapenv:Header> '  +
				'    <soapenv:Body> '  +
				'        <crew:InsertDutyAssignReq> '  +
				'            <v1:arg0> '  +
				'                <v1:cabinduty>AP</v1:cabinduty> '  +
				'                <v1:fltDateUTC>10JAN17</v1:fltDateUTC> '  +
				'                <v1:fltno>null</v1:fltno>' +
				'                <v1:perno>15865</v1:perno> '  +
				'                <v1:remarks>Crew 15865\'s duty is changed from null to AP</v1:remarks> '  +
				'                <v1:sector>BKKHKG</v1:sector> '  +
				'                <v1:updtstatus>Approved</v1:updtstatus> '  +
				'            </v1:arg0> '  +
				'        </crew:InsertDutyAssignReq> '  +
				'    </soapenv:Body> '  +
				'</soapenv:Envelope>';
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model crewdutyModel = new CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model();
		crewdutyModel.cabinduty = 'AP';
		crewdutyModel.fltDateLT = '10JAN17';
		crewdutyModel.perno = '15865';
		crewdutyModel.remark = 'Crew 15865\'s duty is changed from null to AP';
		crewdutyModel.sector = 'BKKHKG';
		crewdutyModel.updtstatus = 'Approved';
		List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model> crewmodelList = new List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model>{crewdutyModel};
		CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
		String reqFromMethod = ws.getSoapRequest(crewmodelList);
		String nonce = BE8_GlobalUtility.getMsgBetween(reqFromMethod, NONCE_START_TAG, NONCE_END_TAG);
		String created = BE8_GlobalUtility.getMsgBetween(reqFromMethod, CREATED_START_TAG, CREATED_END_TAG);
		String reqTxnId = BE8_GlobalUtility.getMsgBetween(reqFromMethod, REQ_TXN_ID_START_TAG, REQ_TXN_ID_END_TAG);
		reqFromMethod = reqFromMethod.remove(nonce);
		reqFromMethod = reqFromMethod.remove(created);
		reqFromMethod = reqFromMethod.remove(reqTxnId);
		reqFromMethod = reqFromMethod.remove(' ');
		req = req.remove(' ');

		System.assertEquals(req, reqFromMethod, 'Soap XML request from method should be equal to the req String');
	}
	
	@isTest static void testGetResponseSuccess() {
		setupWSCallout('s', 1);
        CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
        Test.startTest();
        CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model resp = ws.callout(new List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model>());
        Test.stopTest();
        System.assertEquals('SUCCESS', resp.status, 'Response status should be equal to SUCCESS');
        System.assertEquals(1, resp.recordNo, 'Amount of record should be equal to 1');
        
	}
	
	@isTest static void testGetResponseFailure() {
		setupWSCallout('e', 1);
        CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
        Test.startTest();
        CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model resp = ws.callout(new List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model>());
        Test.stopTest();
        System.assertEquals('ERROR', resp.status, 'Response status should be equal to ERROR');
        System.assertEquals(-1, resp.recordNo, 'Amount of record should be equal to -1');
	}

	@isTest static void testCrewDutyAssignmentCalloutSuccess(){
		setupWSCallout('s', 3);
		Set<String> flightIdSet = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id FROM Flight__c]).keySet();
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewModelList = new List<MB_RESTRequestInfoModel.crewDutyAssignment_model>();
		MockupData_Test.createMBCrewDutyAssignment(crewModelList, flightIdSet);
		Test.startTest();
		CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
		List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model> crewdutyModelList = CSE_SOAPCrewDutyAssignment_WS.getcrewDutyAssignmentModelListFromMBModel(crewModelList, '2017-01-10', 'BKK-HKG', '0628');
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = ws.callout(crewdutyModelList);
		Test.stopTest();
		System.assertEquals(1, AppLogger.getLogModel().size(), 'Size of Log model should be equal to 1');
		System.assertEquals(2, AppLogger.getAttachModel().values()[0].size(), 'Size of attachment in Log model should be equal to 2 due to the attachments should be cover request and response attachment');
	}

	@isTest static void testCrewDutyAssignmentCalloutFailure(){
		setupWSCallout('e', 3);
		Set<String> flightIdSet = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id FROM Flight__c]).keySet();
		List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewModelList = new List<MB_RESTRequestInfoModel.crewDutyAssignment_model>();
		MockupData_Test.createMBCrewDutyAssignment(crewModelList, flightIdSet);
		Test.startTest();
		CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
		List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model> crewdutyModelList = CSE_SOAPCrewDutyAssignment_WS.getcrewDutyAssignmentModelListFromMBModel(crewModelList, '2017-01-10', 'BKK-HKG', '0628');
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = ws.callout(crewdutyModelList);
		Test.stopTest();
		System.assertEquals(1, AppLogger.getLogModel().size(), 'Size of Log model should be equal to 1');
		System.assertEquals(2, AppLogger.getAttachModel().values()[0].size(), 'Size of attachment in Log model should be equal to 2 due to the attachments should be cover request and response attachment');
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
}