@isTest
private class MB_RESTAttachmentService_Test {
	@testSetup static void MockData(){
		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;

		Flight__c mockupFlight = MockupData_Test.createFlight('0517', '07Dec16', 1);
		insert mockupFlight;
		Passenger__c pax = new Passenger__c(
			Name = 'Khun Toey',
			First_Name__c = 'Toey',
			Last_Name__c = 'Khun',
			Email_1__c = 'toey.k@gmail.com',
			Date_of_Birth_Input__c = Date.newInstance(1994, 11, 12),
			FlightId__c = mockupFlight.Id,
			Travel_Document_Number__c = 'TRAVELTEST01'
			);
		insert pax;
		Case newCase1 = MockupData_Test.createCase('BB001F071216', 'Open', 'Maintenance');
		Case newCase2 = MockupData_Test.createCase('BB002F071216', 'Open', 'Maintenance');
		Case newCase3 = MockupData_Test.createCase('BB003F071216', 'Open', 'Maintenance');
		newCase1.Passengerid__c = pax.Id;
		newCase2.Passengerid__c = pax.Id;
		newCase3.Passengerid__c = pax.Id;
		newCase1.Flightid__c = mockupFlight.Id;
		newCase2.Flightid__c = mockupFlight.Id;
		newCase3.Flightid__c = mockupFlight.Id;
		newCase1.Mobile_App_Key__c = 'TGTEST01';
		newCase2.Mobile_App_Key__c = 'TGTEST02';
		newCase3.Mobile_App_Key__c = 'TGTEST03';
		List<Case> caseList = new List<Case>{newCase1, newCase2, newCase3};
		insert caseList;
	}
	
	@isTest static void testHTTPPOSTforAttachmentFromMobileToSFDC() {
		List<Case> caseList = [SELECT Id FROM Case WHERE Mobile_App_Key__c = 'TGTEST01'];
		System.debug('Test Method Case List: ' + caseList);
		MB_RestRequestInfoModel.attachment_list attach1 = new MB_RestRequestInfoModel.attachment_list();
		String input = 'Attachment1TEST1';
		List<String> bodyStr = new List<String>();
		Integer size = input.length()/5;
		Integer startDigit = 0;
		Integer endDigit = 0;
		for(Integer i=0;i<5;i++){
			if(i<4){
				startDigit = endDigit;
				endDigit = startDigit + size;
				
			}
			else{
				startDigit = endDigit;
				endDigit = input.length();
			}
			bodyStr.add(input.substring(startDigit, endDigit));
		}
		System.debug(bodyStr);
		attach1.name = 'Attachment1';
		attach1.body = bodyStr;
		attach1.contenttype = 'Text';
		attach1.parentId = 'TGTEST01';
		attach1.attachmentId = 'TGTEST01';
		System.debug('Test Method Input Attachment: ' + attach1);
		MB_RestRequestInfoModel.attachment_response attresponseModel = MB_RESTAttachmentService.doPost(attach1);
		System.debug('Test Method: ' + attresponseModel);
		List<Attachment> attList = [SELECT Id, Name, Body, ContentType, ParentId, Description FROM Attachment WHERE Id = :attresponseModel.salesforceId];
		System.debug('Test Method Inserted Attachment: ' + attList);
		System.debug('Test Method Inserted Attachment Body: ' + EncodingUtil.base64Encode(attList.get(0).Body));
		System.assertEquals(input, EncodingUtil.base64Encode(attList.get(0).Body), 'Attachment Body should be equal to input');
	}
}