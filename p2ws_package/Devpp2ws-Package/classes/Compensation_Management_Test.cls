@isTest
private class Compensation_Management_Test {
	@testSetup static void DataPreparation(){
		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
	}
	
	@isTest static void testAutoApproveGround() {

		String port = 'port';

	    UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles',
        Port__c=port);

	    System.runAs(u) {

	    	Compensation_Ground_Service__c gsSetting = new Compensation_Ground_Service__c(Name=port, Port__c=port);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New');
		    c.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Compensation__c', 'GS_Compensation');
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveInFlight() {

	    UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_In_flight__c gsSetting = new Compensation_In_flight__c(Name='name1234', Role_Name__c=uRole.Name);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New');
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveTier2Zero() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Tier_2__c gsSetting = new Compensation_Tier_2__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=Compensation_Management.zero);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveTier2() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Tier_2__c gsSetting = new Compensation_Tier_2__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveChiefZero() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Chief__c gsSetting = new Compensation_Chief__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=Compensation_Management.zero);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveChief() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Chief__c gsSetting = new Compensation_Chief__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveManagerZero() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Manager__c gsSetting = new Compensation_Manager__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=Compensation_Management.zero);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveManager() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_Manager__c gsSetting = new Compensation_Manager__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveAOZero() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_AO__c gsSetting = new Compensation_AO__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=Compensation_Management.zero);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveAO() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_AO__c gsSetting = new Compensation_AO__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveD7Zero() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_D7__c gsSetting = new Compensation_D7__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=Compensation_Management.zero);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveD7() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_D7__c gsSetting = new Compensation_D7__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveD7Gift() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_D7__c gsSetting = new Compensation_D7__c(Name=Compensation_Management.GIFTS, Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c=Compensation_Management.GIFTS, Total__c=100);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}

	@isTest static void testAutoApproveD7ROE() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    Profile profile = [select name from profile where id = :UserInfo.getProfileId() limit 1];

	    User u = new User(Alias = 'newUser', Email='newuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='12234@testorg.com', userroleid=uRole.Id,
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');

	    System.runAs(u) {

	    	Compensation_D7__c gsSetting = new Compensation_D7__c(Name='Cash', Role_Name__c=profile.Name,
	    		Maximum_Value__c=100);
			insert gsSetting;

	    	Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		    insert flight;

		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

	    	Test.startTest();

		    Compensation__c c = new Compensation__c(CaseId__c = newCase.Id, Status__c = 'New', Compensation_Tools__c='Cash', Amount__c=100, ROE__c=1);
		    insert c;

		    Compensation__c cUpdate = [Select Status__c from Compensation__c where id = :c.Id limit 1];
		    Assert.assertEquals(Compensation_Management.Approved, cUpdate.Status__c);

		    Test.stopTest();
	    }

	}
	
}