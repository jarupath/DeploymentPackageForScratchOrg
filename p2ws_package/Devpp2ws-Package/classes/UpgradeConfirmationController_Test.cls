@isTest
private class UpgradeConfirmationController_Test {

    @isTest static void testGetViewUpgradeConfirmation() {
        MockupData_Test.initializeWebServiceCustomSetting();
        MockupData_Test.initializeSystemConfigurationCustomSetting();

        Flight__c flight = MockupData_Test.createFlight('TG 1234', '', 1);
        insert flight;

        Flight__c dummyFlight = MockupData_Test.createFlight('TGXXX', '', null);
        insert dummyFlight;

        Case thisCase = MockupData_Test.createCase('', 'New', 'CTI');
        thisCase.FlightId__c = flight.Id;
        thisCase.Latest_Document__c = 'LetterEN';
        thisCase.Status = 'New';
        thisCase.Channel__c = 'Phone';
        thisCase.Letter_Body__c = '| Line1 <br>   Line2 <br> @:LINE3:@ <br>';
        insert thisCase;

        Test.startTest();
        Test.setCurrentPage(Page.UpgradeConfirmation);
        ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
        ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
        UpgradeConfirmationController ctrl = new UpgradeConfirmationController(sc);
        Test.stopTest();

        Assert.assertNotEquals(null, ctrl.view);
        Assert.assertEquals(thisCase.Id, ctrl.view.caseObj.Id);
        Assert.assertEquals('&nbsp;Line1 \n&nbsp;&nbsp;&nbsp;Line2 \n&nbsp;...@:LINE3... \n', ctrl.view.letterBody);
    }
	
	// positive UpgradeConfirmation page
	//@isTest static void testGetViewUpgradeConfirmation() {
 //   	MockupData_Test.initializeWebServiceCustomSetting();
 //       MockupData_Test.initializeSystemConfigurationCustomSetting();

 //   	String firstName = 'First Name';
 //   	String lastName = 'Last Name';
 //   	String comment = 'comment test 1234';

 //   	Account a = new Account();
 //   	a.Name = firstName + ' ' + lastName;
 //   	a.First_Name__c = firstName;
 //   	a.Last_Name__c = lastName;
 //   	a.ROP_Tier__c = 'Gold';
 //   	insert a;

 //   	Flight__c f = new Flight__c();
 //   	f.Name = 'TG 1234';
 //   	insert f;

 //       Flight__c fdummy = new Flight__c();
 //       fdummy.Name = 'TGXXX';
 //       insert fdummy;

 //   	Passenger__c p = new Passenger__c();
 //       p.SSR_Service__c = '';
 //       p.First_Name__c = firstName;
 //       p.Last_Name__c = lastName;
 //       p.FlightId__c = f.Id;
 //       p.AccountId__c = a.Id;
 //       p.Class__c = 'C';
 //       insert p;

 //       Passenger__c p2 = new Passenger__c();
 //       p2.SSR_Service__c = '';
 //       p2.First_Name__c = firstName;
 //       p2.Last_Name__c = lastName;
 //       p2.FlightId__c = f.Id;
 //       p2.AccountId__c = a.Id;
 //       p2.Class__c = 'C';
 //       insert p2;

 //       Case thisCase = new Case();
 //       thisCase.PassengerId__c = p.Id;
 //       thisCase.FlightId__c = f.Id;
 //       thisCase.Status = 'New';
 //       thisCase.Channel__c = 'Phone';
 //       insert thisCase;

 //   	Test.startTest();

 //   	Test.setCurrentPage(Page.UpgradeConfirmation);
	//	ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
	//	ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
 //       UpgradeConfirmationController controller = new UpgradeConfirmationController(sc);

 //   	Test.stopTest();

 //   	System.assertNotEquals(null, controller.view);
 //       System.assertEquals(thisCase.Id, controller.view.caseObj.Id);
	//}

	//// positive UpgradeStandby page
	//@isTest static void testGetViewUpgradeStandby() {

 //   	MockupData_Test.initializeWebServiceCustomSetting();
 //       MockupData_Test.initializeSystemConfigurationCustomSetting();

 //   	String firstName = 'First Name';
 //   	String lastName = 'Last Name';
 //   	String comment = 'comment test 1234';

 //   	Account a = new Account();
 //   	a.Name = firstName + ' ' + lastName;
 //   	a.First_Name__c = firstName;
 //   	a.Last_Name__c = lastName;
 //   	a.ROP_Tier__c = 'Gold';
 //   	insert a;

 //   	Flight__c f = new Flight__c();
 //   	f.Name = 'TG 1234';
 //   	insert f;

 //       Flight__c fdummy = new Flight__c();
 //       fdummy.Name = 'TGXXX';
 //       insert fdummy;

 //   	Passenger__c p = new Passenger__c();
 //       p.SSR_Service__c = '';
 //       p.First_Name__c = firstName;
 //       p.Last_Name__c = lastName;
 //       p.FlightId__c = f.Id;
 //       p.AccountId__c = a.Id;
 //       p.Class__c = 'C';
 //       insert p;

 //       Passenger__c p2 = new Passenger__c();
 //       p2.SSR_Service__c = '';
 //       p2.First_Name__c = firstName;
 //       p2.Last_Name__c = lastName;
 //       p2.FlightId__c = f.Id;
 //       p2.AccountId__c = a.Id;
 //       p2.Class__c = 'C';
 //       insert p2;

 //       Case thisCase = new Case();
 //       thisCase.PassengerId__c = p.Id;
 //       thisCase.FlightId__c = f.Id;
 //       thisCase.Status = 'New';
 //       thisCase.Channel__c = 'Phone';
 //       insert thisCase;

 //   	Test.startTest();

 //   	Test.setCurrentPage(Page.UpgradeStandby);
	//	ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
	//	ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
 //       UpgradeConfirmationController controller = new UpgradeConfirmationController(sc);

 //   	Test.stopTest();

 //   	System.assertNotEquals(null, controller.view);
 //       System.assertEquals(thisCase.Id, controller.view.caseObj.Id);
	//}

}