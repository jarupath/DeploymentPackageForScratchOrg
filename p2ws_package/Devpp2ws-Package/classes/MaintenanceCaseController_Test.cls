@isTest
private class MaintenanceCaseController_Test {
	
	@isTest static void testController() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Account a = new Account();
    	a.Name = 'firstName' + ' ' + 'lastName';
    	a.First_Name__c = 'firstName';
    	a.Last_Name__c = 'lastName';
    	a.ROP_Tier__c = 'Gold';
    	insert a;

	    Passenger__c p = new Passenger__c();
        p.SSR_Service__c = '';
        p.First_Name__c = 'firstName';
        p.Last_Name__c = 'lastName';
        p.FlightId__c = flight.Id;
        p.AccountId__c = a.Id;
        p.Class__c = 'C';
        insert p;

        Case thisCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
        thisCase.PassengerId__c = p.Id;
        thisCase.FlightId__c = flight.Id;
        thisCase.Status = 'New';
        thisCase.Channel__c = 'Phone';
        insert thisCase;

        List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
        System.assertEquals(1, caseMembers.size());

	    ApexPages.currentPage().getParameters().put('id', flight.Id);
	    
	    ApexPages.StandardController stdCaseController = new ApexPages.StandardController(flight);
	    
	    Test.startTest();

	    MaintenanceCaseController ctrl = new MaintenanceCaseController(stdCaseController);
	    Assert.assertEquals(8, ctrl.con.getPageSize());
	    Assert.assertNotEquals(null, ctrl.caseGroupMemberList);
	    Assert.assertNotEquals(null, ctrl.hasNext);
	    Assert.assertNotEquals(null, ctrl.hasPrevious);
	    Assert.assertNotEquals(null, ctrl.pageNumber);
	    ctrl.previous();
	    ctrl.next();
	    ctrl.con = null;
	    Assert.assertEquals(null, ctrl.caseGroupMemberList);

	    Test.stopTest();
	}

}