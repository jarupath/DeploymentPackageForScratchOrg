@isTest
private class Round_Robin_Controller_Test {
	@testSetup static void DataPreparation(){

		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		
	}
	
	@isTest static void testRoundrobin_method() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    User u1Q1 = new User(Alias = 'User1Q1', Email='User1Q1@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User1Q1@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u1Q1;

        User u2Q1 = new User(Alias = 'User2Q1', Email='User2Q1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User2Q1@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u2Q1;

        User u1Q2 = new User(Alias = 'User1Q2', Email='User1Q2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User1Q2@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u1Q2;

        User u2Q2 = new User(Alias = 'User2Q2', Email='User2Q2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User2Q2@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u2Q2;

        Id caseMemberId;

        System.runAs(u2q1){

        	Case_Team__c q1 = new Case_Team__c(Queue_ID__c=String.valueof(u1Q1.Id), Active__c=true);
			insert q1;

			Case_Team__c q2 = new Case_Team__c(Queue_ID__c=String.valueof(u1Q2.Id), Active__c=true);
			insert q2;

	        Case_Member__c m1 = new Case_Member__c(Userid__c=u1q1.id, Type__c='Round Robin User', Case_Teamid__c=q1.id, Assigned__c=true);
	        insert m1;

	        Case_Member__c m2 = new Case_Member__c(Userid__c=u2q1.id, Type__c='Round Robin User', Case_Teamid__c=q1.id, Assigned__c=false);
	        insert m2;

	        Case_Member__c m3 = new Case_Member__c(Userid__c=u1q2.id, Type__c='Round Robin User', Case_Teamid__c=q2.id, Assigned__c=true);
	        insert m3;
	        
	        Case_Member__c m4 = new Case_Member__c(Userid__c=u2q2.id, Type__c='Round Robin User', Case_Teamid__c=q2.id, Assigned__c=false);
	        insert m4;

	        Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
			insert flight;

	        Test.startTest();
		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;

		    //newCase.OwnerId = u1q1.Id;
		    newCase.OwnerId = u1q1.Id;
		    update newCase;
	        Test.stopTest();
	        caseMemberId = m2.Id;
        }
        Case_Member__c updateMember = [Select Assigned__c from Case_Member__c where Id = :caseMemberId limit 1];
        Assert.assertEquals(true, updateMember.Assigned__c);

	}

	@isTest static void testRoundrobin_method_markFirstMember() {

		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    User u1Q1 = new User(Alias = 'User1Q1', Email='User1Q1@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User1Q1@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u1Q1;

        User u2Q1 = new User(Alias = 'User2Q1', Email='User2Q1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User2Q1@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u2Q1;

        User u1Q2 = new User(Alias = 'User1Q2', Email='User1Q2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User1Q2@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u1Q2;

        User u2Q2 = new User(Alias = 'User2Q2', Email='User2Q2@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User2Q2@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u2Q2;

        Id caseMemberId;

        System.runAs(u1q1){

        	Case_Team__c q1 = new Case_Team__c(Queue_ID__c=String.valueof(u1Q1.Id), Active__c=true);
			insert q1;

			Case_Team__c q2 = new Case_Team__c(Queue_ID__c=String.valueof(u1Q2.Id), Active__c=true);
			insert q2;

	        Case_Member__c m1 = new Case_Member__c(Userid__c=u1q1.id, Type__c='Round Robin User', Case_Teamid__c=q1.id, Assigned__c=true);
	        insert m1;

	        Case_Member__c m2 = new Case_Member__c(Userid__c=u2q1.id, Type__c='Round Robin User', Case_Teamid__c=q1.id, Assigned__c=false);
	        insert m2;

	        Case_Member__c m3 = new Case_Member__c(Userid__c=u1q2.id, Type__c='Round Robin User', Case_Teamid__c=q2.id, Assigned__c=true);
	        insert m3;
	        
	        Case_Member__c m4 = new Case_Member__c(Userid__c=u2q2.id, Type__c='Round Robin User', Case_Teamid__c=q2.id, Assigned__c=false);
	        insert m4;

	        Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
			insert flight;
	        
	        Test.startTest();
		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		    newCase.Flightid__c = flight.Id;
		    insert newCase;
		    newCase.OwnerId = u2q1.Id;
		    update newCase;
	        Test.stopTest();

	        caseMemberId = m1.Id;
        }
        Case_Member__c updateMember = [Select Assigned__c from Case_Member__c where Id=:caseMemberId limit 1];
        Assert.assertEquals(true, updateMember.Assigned__c);
	}
	
}