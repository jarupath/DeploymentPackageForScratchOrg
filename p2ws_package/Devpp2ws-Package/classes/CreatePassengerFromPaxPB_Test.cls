@isTest
private class CreatePassengerFromPaxPB_Test {
	
	@isTest static void testCreateAccountFromPax() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
    	String lastName = 'Last Name';

    	Account a = new Account();
    	a.Name = firstName + ' ' + lastName;
    	a.First_Name__c = firstName;
    	a.Last_Name__c = lastName;
    	a.ROP_Tier__c = 'Gold';
    	insert a;

    	Flight__c f = new Flight__c();
    	f.Name = 'TG 1234';
    	insert f;

        Flight__c fdummy = new Flight__c();
        fdummy.Name = 'TGXXX';
        insert fdummy;

    	Passenger__c p = new Passenger__c();
        p.SSR_Service__c = '';
        p.First_Name__c = firstName;
        p.Last_Name__c = lastName;
        p.FlightId__c = f.Id;
        p.AccountId__c = a.Id;
        p.Class__c = 'C';
        p.Travel_Document_Number__c = '1234asdf';
        p.Date_of_Birth_Input__c = Date.today();
        insert p;

        Passenger__c p2 = new Passenger__c();
        p2.SSR_Service__c = '';
        p2.First_Name__c = firstName;
        p2.Last_Name__c = lastName;
        p2.FlightId__c = f.Id;
        p2.AccountId__c = a.Id;
        p2.Class__c = 'C';
        p2.Travel_Document_Number__c = '5678asdf';
        p2.IgnoreProcessBuilder__c = true;
        p2.Date_of_Birth_Input__c = Date.today();
        insert p2;

        Case thisCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    thisCase.Flightid__c = f.Id;
	    thisCase.PassengerId__c = p.Id;
	    insert thisCase;

	    List<Passenger__c> pList = new List<Passenger__c>{p,p2};

	    Test.startTest();
	    CreatePassengerFromPaxProcessBuilder.createAccountFromPax(pList);
	    Test.stopTest();

        List<Account> accList = [select id from Account];
        Assert.assertEquals(2, accList.size());
	}
	
}