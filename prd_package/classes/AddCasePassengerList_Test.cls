@isTest
private class AddCasePassengerList_Test {
        @testSetup static void DataPreparation(){
                // TriggerActivator.initializeTriggerActivation(true);
        }
	
	/* Case with no existing passenger */
	@isTest static void testGetPassengerList() {

        	MockupData_Test.initializeWebServiceCustomSetting();
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
                insert p;

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                insert p2;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(1, caseMembers.size());

        	ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
        	ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
        	ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

        	List<Passenger__c> pList = controller.getPassengerList();

        	Assert.assertEquals(1, pList.size());
                Assert.assertEquals(p2.Id, pList.get(0).Id);
	}

	/* Case with existing passenger */
	@isTest static void testGetPassengerListWithExistingPassenger() {

		MockupData_Test.initializeWebServiceCustomSetting();
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
                insert p;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Case_Group_Member__c member = new Case_Group_Member__c(Caseid__c=thisCase.Id, Passengerid__c=p.Id);
                insert member;

		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		List<Passenger__c> pList = controller.getPassengerList();

		Assert.assertEquals(0, pList.size());
	}

	/* This Case is Null */
	@isTest static void testGetPassengerListThisCaseIsNull() {

		MockupData_Test.initializeWebServiceCustomSetting();
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
                insert p;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

		ApexPages.currentPage().getParameters().put('id', '1234');
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		List<Passenger__c> pList = controller.getPassengerList();

		Assert.assertEquals(null, pList);
	}

	/* Add Passenger List to Case with new Primary Passenger */
	@isTest static void testAddToPassengerListSetNewPrimary() {

		MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		List<Passenger__c> pList = new List<Passenger__c>();
		String passengerIds = '';

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
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c(); // to be new primary
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                System.assertEquals(1, caseMembers.size());

		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
		controller.primaryPassenger = p4.Id;
		controller.addToPassengerList();

		List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
		Assert.assertEquals(5, caseMembers2.size());

		List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
		Assert.assertEquals(1, resultCase.size());
		Assert.assertEquals(p4.Id, resultCase.get(0).PassengerId__c);
	}

	/* Add Passenger List to Case with no new Primary Passenger */
	@isTest static void testAddToPassengerListNotSetNewPrimary() {

		MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		List<Passenger__c> pList = new List<Passenger__c>();
		String passengerIds = '';

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
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c();
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(1, caseMembers.size());

		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
		controller.addToPassengerList();

		List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
		Assert.assertEquals(5, caseMembers2.size());

		List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
		Assert.assertEquals(1, resultCase.size());
		Assert.assertEquals(p.Id, resultCase.get(0).PassengerId__c);
	}

	/* Add Passenger List to Case with null Primary Passenger */
	@isTest static void testAddToPassengerListNullPrimary() {

		MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		List<Passenger__c> pList = new List<Passenger__c>();
		String passengerIds = '';

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

                Passenger__c oldPrimary = new Passenger__c();
                oldPrimary.SSR_Service__c = '';
                oldPrimary.First_Name__c = firstName;
                oldPrimary.Last_Name__c = lastName;
                oldPrimary.FlightId__c = f.Id;
                oldPrimary.AccountId__c = a.Id;
                oldPrimary.Class__c = 'C';
                pList.add(oldPrimary);

        		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c();
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.PassengerId__c = oldPrimary.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(1, caseMembers.size());

		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
		controller.addToPassengerList();

		List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
		Assert.assertEquals(5, caseMembers2.size());

		List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
		Assert.assertEquals(1, resultCase.size());
		Assert.assertEquals(oldPrimary.Id, resultCase.get(0).PassengerId__c);
	}

	/* Add Passenger List - this case is null */
	@isTest static void testAddToPassengerListThisCaseIsNull() {

		MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		List<Passenger__c> pList = new List<Passenger__c>();
		String passengerIds = '';

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
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c();
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(1, caseMembers.size());

		ApexPages.currentPage().getParameters().put('id', '1234');
		ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
		ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

		controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
		controller.primaryPassenger = p4.Id;
		controller.addToPassengerList();

		List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
		Assert.assertEquals(1, caseMembers2.size());

		List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
		Assert.assertEquals(1, resultCase.size());
		Assert.assertEquals(p.Id, resultCase.get(0).PassengerId__c);
	}

        /* Add Passenger List to Case with new Primary Passenger */
        @isTest static void testAddToPassengerListSetNewPrimaryExistingPassengerIsNull() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

                String firstName = 'First Name';
                String lastName = 'Last Name';

                List<Passenger__c> pList = new List<Passenger__c>();
                String passengerIds = '';

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
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c(); // to be new primary
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(0, caseMembers.size());

                ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
                ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
                ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

                controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
                controller.primaryPassenger = p4.Id;
                controller.addToPassengerList();

                List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(4, caseMembers2.size());

                List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
                Assert.assertEquals(1, resultCase.size());
                Assert.assertEquals(p4.Id, resultCase.get(0).PassengerId__c);
        }

        /* Add Passenger List to Case with new Primary Passenger */
        @isTest static void testAddToPassengerListSetNewPrimaryExistingPassengerIsNullNotSelectPrimary() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

                String firstName = 'First Name';
                String lastName = 'Last Name';

                List<Passenger__c> pList = new List<Passenger__c>();
                String passengerIds = '';

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
                pList.add(p);

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                pList.add(p2);

                Passenger__c p3 = new Passenger__c();
                p3.SSR_Service__c = '';
                p3.First_Name__c = firstName;
                p3.Last_Name__c = lastName;
                p3.FlightId__c = f.Id;
                p3.AccountId__c = a.Id;
                p3.Class__c = 'C';
                pList.add(p3);

                Passenger__c p4 = new Passenger__c();
                p4.SSR_Service__c = '';
                p4.First_Name__c = firstName;
                p4.Last_Name__c = lastName;
                p4.FlightId__c = f.Id;
                p4.AccountId__c = a.Id;
                p4.Class__c = 'C';
                pList.add(p4);

                insert pList;

                Case thisCase = new Case();
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                List<Case_Group_Member__c> caseMembers = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(0, caseMembers.size());

                ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));
                ApexPages.currentPage().getParameters().put('ret', 'www.ret.com');
                ApexPages.currentPage().getParameters().put('top', 'www.top.com');

                AddCasePassengerListController controller = new AddCasePassengerListController();

                controller.thisPassengerIds = p.Id + ',' + p2.Id + ',' + p3.Id + ',' + p4.Id;
                controller.addToPassengerList();

                List<Case_Group_Member__c> caseMembers2 = [Select Id from Case_Group_Member__c where Caseid__c = :thisCase.Id];
                Assert.assertEquals(4, caseMembers2.size());

                List<Case> resultCase = [Select Id, PassengerId__c from Case where Id = :thisCase.Id];
                List<Passenger__c> passengerList = [SELECT Id FROM Passenger__c ORDER BY Name ASC];
                Assert.assertEquals(1, resultCase.size());
                Assert.assertEquals(passengerList.get(0).Id, resultCase.get(0).PassengerId__c);
        }
	
}