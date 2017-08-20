@isTest
public with sharing class CSE_SOAPCABINLOG_WS_Test {
	@testSetup static void DataPreparation(){

		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		
	}

	@isTest static void testUpsertCabinReport_ResponseContainsTGID_ReturnCorrectResponseModel() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorSUCCESS());
		Test.startTest();
		CSE_SOAPCABINLOG_WS.CabinLogModel c = new CSE_SOAPCABINLOG_WS.CabinLogModel();
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = new CSE_SOAPCABINLOG_WS().insertCabinLog(c);
		Test.stopTest();

		System.assertEquals('S', m.responseType);
		System.assertEquals('Order UA007C011016 saved with notification UA007C011016', m.responseText);
		System.assertEquals(true, m.status);
	}

	@isTest static void testUpsertCabinReport_ResponseContainsTGID_ReturnErrorResponseModel() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorERROR());
		Test.startTest();
		CSE_SOAPCABINLOG_WS.CabinLogModel c = new CSE_SOAPCABINLOG_WS.CabinLogModel();
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = new CSE_SOAPCABINLOG_WS().insertCabinLog(c);
		Test.stopTest();
		System.assertEquals(false, m.status);
	}

	@isTest static void testUpsertCabinReport_ResponseContainsTGID_ReturnExceptionResponseModel() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorNULL());
		Test.startTest();
		CSE_SOAPCABINLOG_WS.CabinLogModel c = new CSE_SOAPCABINLOG_WS.CabinLogModel();
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = new CSE_SOAPCABINLOG_WS().insertCabinLog(c);
		Test.stopTest();
		System.assertEquals(false, m.status);
	}

	@isTest static void testUpsertCabinReport_createCabinLogFromCaseList() {
		MockupData_Test.initializeWebServiceCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;

		Case c = MockupData_Test.createCase('UA007C011016', 'Test Case', 'Maintenance');
		c.DEP_STN__c = 'BKK';
		c.Flightid__c = flight.Id;
		insert c;

		Set<Id> caseSet = new Set<Id>();
		caseSet.add(c.Id);

		Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorSUCCESS());
		Test.startTest();
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = CSE_SOAPCABINLOG_WS.createCabinLogFromCaseList(caseSet);
		Test.stopTest();
		System.assertEquals(true, m.status);
	}

	@isTest static void testUpsertCabinReport_createCabinLogFromCaseListERROR() {
		MockupData_Test.initializeWebServiceCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;

		Case c = MockupData_Test.createCase('UA007C011016', 'Test Case', 'Maintenance');
		c.DEP_STN__c = 'BKK';
		c.Flightid__c = flight.Id;
		insert c;

		Set<Id> caseSet = new Set<Id>();
		caseSet.add(c.Id);
		
		Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorERROR());
		Test.startTest();
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = CSE_SOAPCABINLOG_WS.createCabinLogFromCaseList(caseSet);
		Test.stopTest();
		System.assertEquals(false, m.status);
	}

	//@isTest static void testUpsertCabinReport_createCabinLogFromCaseListWithFuture() {
	//	MockupData_Test.initializeWebServiceCustomSetting();

	//	Case c = MockupData_Test.createCase('UA007C011016', 'Test Case', 'Maintenance');
	//	c.DEP_STN__c = 'BKK';
	//	insert c;

	//	Case_Group_Member__c member = new Case_Group_Member__c(CaseId__c = c.Id);
	//	member.Position__c = 'A5';
	//	insert member;

	//	List<Case> updatedCaseList = [Select Position_Case_Group_Member__c from case where id = :c.Id];
	//	System.assertEquals(1, updatedCaseList.size());
	//	System.assertEquals('A5', updatedCaseList.get(0).Position_Case_Group_Member__c);


	//	Set<Id> caseSet = new Set<Id>();
	//	caseSet.add(c.Id);

	//	Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorSUCCESS());
	//	Test.startTest();
	//	// CSE_SOAPCABINLOG_WS.createCabinLogFromCaseListWithFuture(caseSet); will be internally called by CaseTrigger after Case Group Member is being added
	//	Test.stopTest();
	//}

	@isTest static void testUpsertCabinReport_createCabinLogFromCaseListWithFutureNoUpdateNotMaintenance() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Flight__c flight = MockupData_Test.createFlight('TG0628', '2025-04-30', 1);
		insert flight;

		Case c = MockupData_Test.createCase('UA007C011016', 'Test Case', 'CTI');
		c.FlightId__c = flight.Id;
		System.debug('JKK: ' + JSON.serialize(c));
		insert c;

		Case_Group_Member__c member = new Case_Group_Member__c(CaseId__c = c.Id);
		member.Position__c = 'A5';
		insert member;

		List<Case> updatedCaseList = [Select Position_Case_Group_Member__c from case where id = :c.Id];
		System.assertEquals(1, updatedCaseList.size());
		System.assertEquals(null, updatedCaseList.get(0).Position_Case_Group_Member__c);
	}

	@isTest static void testGetResponseModel_XMLSaveSuccess_ReturnValidData(){
		String xml = '' +
		'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
   			'<SOAP-ENV:Header>' +
      			'<ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
     				'<ResDateTime>2016-11-01T15:14:17.676+07:00</ResDateTime>' +
         			'<ReqTxnID>AEK11111111112</ReqTxnID>' +
         			'<MWTxnID>SY_TGAIP_1477988056718</MWTxnID>' +
         			'<ResCode>SUCCESS</ResCode>' +
      			'</ResHeader>' +
   			'</SOAP-ENV:Header>' +
   			'<SOAP-ENV:Body>' +
      			'<ns0:UpdateCustomerComplaintRes xmlns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://xml.thaiairways.com/sapdt/update/customercomplaint" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint">' +
         			'<Customercomplaintreply>' +
            			'<Responsetype>S</Responsetype>' +
            			'<Responsetext>Order UA007C011016 saved with notification UA007C011016</Responsetext>' +
     				'</Customercomplaintreply>' +
      			'</ns0:UpdateCustomerComplaintRes>' +
   			'</SOAP-ENV:Body>' +
		'</SOAP-ENV:Envelope>';
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = CSE_SOAPCABINLOG_WS.getResponseModel(xml);
		System.assertEquals('S', m.responseType);
		System.assertEquals('Order UA007C011016 saved with notification UA007C011016', m.responseText);
		System.assertEquals(true, m.status);
	}


	@isTest static void testGetResponseModel_XMLContainsException_ReturnErrorData(){
		String xml = '' +
			'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
   				'<SOAP-ENV:Body>' +
      				'<SOAP-ENV:Fault>' +
         				'<faultcode>SOAP-ENV:Server</faultcode>' +
         				'<faultstring>Internal Error</faultstring>' +
         				'<faultactor>PROVIDER</faultactor>' +
         				'<detail>' +
            				'<mwerror:ErrList xmlns:mwerror="http://xml.accenture.com/common/fault" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint">' +
	               				'<mwerror:Err>' +
		                  			'<mwerror:ErrCat>30</mwerror:ErrCat>' +
		                  			'<mwerror:ErrCatDesc>Parsing Errors</mwerror:ErrCatDesc>' +
		                  			'<mwerror:ErrCode>3000</mwerror:ErrCode>' +
		              				'<mwerror:ErrDesc>Invalid Input Request data</mwerror:ErrDesc>' +
		                  			'<mwerror:ErrSev>Severity-2</mwerror:ErrSev>' +
		                  			'<mwerror:ErrSrc>MWTESTER</mwerror:ErrSrc>' +
		                  			'<mwerror:ErrTgt>SAPDT</mwerror:ErrTgt>' +
		                  			'<mwerror:ErrDateTime>2016-11-01T17:49:35.319+07:00</mwerror:ErrDateTime>' +
		                  			'<mwerror:ErrDetail/>' +
		                  			'<mwerror:MWErrDetails>' +
			                     		'<mwerror:ErrHeader>' +
			                        		'<mwerror:ServiceProvider>SAPDT</mwerror:ServiceProvider>' +
			                        		'<mwerror:MWTxnID>SY_TGAIP_1477997375144</mwerror:MWTxnID>' +
			                        		'<mwerror:ReqTxnID>AEK11111111112</mwerror:ReqTxnID>' +
			                        		'<mwerror:ReqID>MWTESTER</mwerror:ReqID>' +
			                        		'<mwerror:MWProcess>ServiceImplementation/ws.thaiairways.com/SAPDT/Update/CustomerComplaint/SOAPEndpoints/CustomerComplaintUpdateCustomerComplaint.process</mwerror:MWProcess>' +
			                        		'<mwerror:MWActivity>GenerateInputError – Fault</mwerror:MWActivity>' +
			                     		'</mwerror:ErrHeader>' +
		                  			'</mwerror:MWErrDetails>' +
	               				'</mwerror:Err>' +
            				'</mwerror:ErrList>' +
         				'</detail>' +
      				'</SOAP-ENV:Fault>' +
   				'</SOAP-ENV:Body>' +
			'</SOAP-ENV:Envelope>';
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = CSE_SOAPCABINLOG_WS.getResponseModel(xml);
		System.assertEquals('Invalid Input Request data', m.errorMessage);
		System.assertEquals(false, m.status);
	}

	//@isTest static void testUpsertCabinReport_createCabinLogFromCaseListWithFuture_DUPCASE() {
	//	MockupData_Test.initializeWebServiceCustomSetting();
	//	Test.setMock(HttpCalloutMock.class, new MockCabinLOGWSFactory.MockCABINLOGWSResponseGeneratorDUP());

	//	Case c = MockupData_Test.createCase('UA007C011016', 'Test Case', 'Maintenance');
	//	c.DEP_STN__c = 'BKK';
	//	insert c;

	//	Case_Group_Member__c member = new Case_Group_Member__c(CaseId__c = c.Id);
	//	member.Position__c = 'A5';
	//	insert member;

	//	List<Case> updatedCaseList = [Select Position_Case_Group_Member__c from case where id = :c.Id];
	//	System.assertEquals(1, updatedCaseList.size());
	//	System.assertEquals('A5', updatedCaseList.get(0).Position_Case_Group_Member__c);


	//	Set<Id> caseSet = new Set<Id>();
	//	caseSet.add(c.Id);
	//	System.debug('JK: AFTER UPDATE - ' + JSON.serialize([SELECT Id, Subject, Status FROM Case WHERE Id IN :caseSet]));
	//	Test.startTest();
	//	//CSE_SOAPCABINLOG_WS.createCabinLogFromCaseListWithFuture(caseSet); //will be internally called by CaseTrigger after Case Group Member is being added
	//	Test.stopTest();
	//}
}