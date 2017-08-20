@isTest
private class CaseEmailController_Test {
	@testSetup static void DataPreparation(){

		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		
	}
	
	@isTest static void firstPage() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id);
	    insert email;

	    ApexPages.currentPage().getParameters().put('id', newCase.Id);
	    
	    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
	    
	    Test.startTest();

	    CaseEmailController ctrl = new CaseEmailController(stdCaseController);
	    Assert.assertNotEquals(null, ctrl.currentInternalPage);

	    Test.stopTest();
	}

	@isTest static void nextInternalPage() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    insert newCase;

	    EmailMessage email1 = new EmailMessage(ParentId = newCase.Id);
	    insert email1;

	    EmailMessage email2 = new EmailMessage(ParentId = newCase.Id);
	    insert email2;

	    EmailMessage email3 = new EmailMessage(ParentId = newCase.Id);
	    insert email3;

	    ApexPages.currentPage().getParameters().put('id', newCase.Id);
	    
	    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
	    
	    Test.startTest();

	    CaseEmailController ctrl = new CaseEmailController(stdCaseController);
	    ctrl.internalPointerIndex = 0;
	    ctrl.internalEmailPageSize = 0;
	    ctrl.internalStartIndex = 1;
	    ctrl.internalEndIndex = 1;
	    ctrl.NextInternalPage();
	    Assert.assertNotEquals(null, ctrl.currentInternalPage);

	    Test.stopTest();
	}

	@isTest static void prevInternalPage() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    insert newCase;

	    EmailMessage email1 = new EmailMessage(ParentId = newCase.Id);
	    insert email1;

	    EmailMessage email2 = new EmailMessage(ParentId = newCase.Id);
	    insert email2;

	    EmailMessage email3 = new EmailMessage(ParentId = newCase.Id);
	    insert email3;

	    ApexPages.currentPage().getParameters().put('id', newCase.Id);
	    
	    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
	    
	    Test.startTest();

	    CaseEmailController ctrl = new CaseEmailController(stdCaseController);
	    ctrl.internalPointerIndex = 1;
	    ctrl.internalEmailPageSize = 0;
	    ctrl.internalStartIndex = 1;
	    ctrl.internalEndIndex = 1;
	    ctrl.PrevInternalPage();
	    Assert.assertNotEquals(null, ctrl.currentInternalPage);

	    Test.stopTest();
	}

	//@isTest static void prevExternalPage() {
	//	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	//    insert flight;

	//    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	//    newCase.Flightid__c = flight.Id;
	//    insert newCase;

	//    EmailMessage email1 = new EmailMessage(ParentId = newCase.Id);
	//    insert email1;

	//    EmailMessage email2 = new EmailMessage(ParentId = newCase.Id);
	//    insert email2;

	//    EmailMessage email3 = new EmailMessage(ParentId = newCase.Id);
	//    insert email3;

	//    ApexPages.currentPage().getParameters().put('id', newCase.Id);
	    
	//    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
	    
	//    Test.startTest();

	//    CaseEmailController ctrl = new CaseEmailController(stdCaseController);
	//    ctrl.externalPointerIndex = 2;
	//    ctrl.externalEmailPageSize = 1;
	//    ctrl.externalStartIndex = 1;
	//    ctrl.externalEndIndex = 1;
	//    ctrl.PrevExternalPage();
	//    Assert.assertNotEquals(null, ctrl.currentInternalPage);

	//    Test.stopTest();
	//}

	@isTest static void nextExternalPage() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    insert newCase;

	    EmailMessage email1 = new EmailMessage(ParentId = newCase.Id);
	    insert email1;

	    EmailMessage email2 = new EmailMessage(ParentId = newCase.Id);
	    insert email2;

	    EmailMessage email3 = new EmailMessage(ParentId = newCase.Id);
	    insert email3;

	    ApexPages.currentPage().getParameters().put('id', newCase.Id);
	    
	    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
	    
	    Test.startTest();

	    CaseEmailController ctrl = new CaseEmailController(stdCaseController);
	    ctrl.externalPointerIndex = 0;
	    ctrl.externalEmailPageSize = 0;
	    ctrl.externalStartIndex = 1;
	    ctrl.externalEndIndex = 4;
	    ctrl.NextExternalPage();
	    Assert.assertNotEquals(null, ctrl.currentInternalPage);

	    Test.stopTest();
	}
	
}