@isTest
private class Emailmsg_Controller_Test {
	@testSetup static void DataPreparation(){
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}
	
	@isTest static void testChangeCaseStatusNew() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Status = Emailmsg_Controller.SNEW;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id, Status=Emailmsg_Controller.SNEW, FromAddress = 'from@email.com');
	    insert email;

	    Test.startTest();

	    Emailmsg_Controller.changecasestatus(new List<EmailMessage>{email}, new Set<Id>{newCase.Id});

	    Test.stopTest();

	    Case updateCase = [select Status from Case where id = :newCase.Id limit 1];
	    System.debug('JK: status 1 - ' + updateCase.Status);
	    Assert.assertEquals(Emailmsg_Controller.SNEW, updateCase.Status);
	}

	@isTest static void testChangeCaseStatusNewExternal() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Status = Emailmsg_Controller.SNEW;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id, Status=Emailmsg_Controller.SNEW,
	    	ToAddress='test@email.com', FromAddress = 'from@email.com');
	    insert email;

	    Test.startTest();

	    Emailmsg_Controller.changecasestatus(new List<EmailMessage>{email}, new Set<Id>{newCase.Id});

	    Test.stopTest();

	    Case updateCase = [select Status from Case where id = :newCase.Id limit 1];
	    System.debug('JK: status 2 - ' + updateCase.Status);
	    Assert.assertEquals(Emailmsg_Controller.SNEW, updateCase.Status);
	}
	
	@isTest static void testChangeCaseStatusSent() {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Status = Emailmsg_Controller.SNEW;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id, Status=Emailmsg_Controller.SENT);
	    insert email;

	    Test.startTest();

	    Emailmsg_Controller.changecasestatus(new List<EmailMessage>{email}, new Set<Id>{newCase.Id});

	    Test.stopTest();

	    Case updateCase = [select Status from Case where id = :newCase.Id limit 1];
	    Assert.assertNotEquals(Emailmsg_Controller.SNEW, updateCase.Status);
	}

	@isTest static void testChangeCaseStatusSentExternal() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Status = Emailmsg_Controller.SNEW;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id, Status=Emailmsg_Controller.SENT,
	    	ToAddress='test@email.com');
	    insert email;

	    Test.startTest();

	    Emailmsg_Controller.changecasestatus(new List<EmailMessage>{email}, new Set<Id>{newCase.Id});

	    Test.stopTest();

	    Case updateCase = [select Status from Case where id = :newCase.Id limit 1];
	    Assert.assertNotEquals(Emailmsg_Controller.SNEW, updateCase.Status);
	}

	@isTest static void testGetMapEmailMsgList() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Status = Emailmsg_Controller.SNEW;
	    insert newCase;

	    EmailMessage email = new EmailMessage(ParentId = newCase.Id, Status=Emailmsg_Controller.SENT);
	    insert email;

	    Test.startTest();

	    Emailmsg_Controller.setdefaultbccaddress(new List<EmailMessage>{email});

	    Test.stopTest();

	    Assert.assertNotEquals(null, email.ccaddress);
	}
}