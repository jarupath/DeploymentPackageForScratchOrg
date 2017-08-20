@isTest
private class DCS_Pax_Util_Service_Test {
	static String paxQuery = 'SELECT Id, FlightId__c, First_Name__c, Last_Name__c, Date_of_Birth__c, PNR__c, Salutation__c, Travel_Document_Number__c, WS_Key__c FROM Passenger__c WHERE FlightId__c IN (SELECT Id FROM Flight__c WHERE Name = \'TG930 / 07JUL17\') LIMIT 1';
	static String flightQuery = 'SELECT Id, Name, Flight_Number__c, Leg_Number__c, STD_LT__c, Flight_Date_UTC__c, Flight_Date_LT__c, Flight_External_Id__c FROM Flight__c WHERE Name = \'TG930 / 07JUL17\' LIMIT 1';

	@testSetup static void DataPreparation(){
		Flight__c flight = new Flight__c();
		flight.Name = 'TG930 / 07JUL17';
		flight.Leg_Number__c = 1;
		flight.STD_LT__c = '2017-07-07 00:05:00';
		flight.Flight_Number__c = 'TG0930';
		flight.Flight_Date_UTC__c = '2017-07-06';
		flight.Flight_Date_LT__c = '2017-07-07';
		flight.Flight_External_ID__c = 'TG0930_2017-07-07_1';
		insert flight;

		List<Account> accounts = new List<Account>();

		Account acc1 = new Account();
		acc1.First_Name__c = 'Matthewfrancis';
		acc1.Last_Name__c = 'Killick';
		acc1.Name = 'Matthewfrancis Killick Mr';
		acc1.Salutation__c = 'Mr';
		acc1.Date_of_Birth__c = Date.valueOf('1990-07-07');
		acc1.Travel_Document__c = '123456789';
		acc1.Customer_External_Id__c = 'MATTHEWFRANCIS MR_KILLICK_07JUL90_123456789';
		accounts.add(acc1);
		insert accounts;

		List<Passenger__c> paxs = new List<Passenger__c>();

		Passenger__c pax1 = new Passenger__c();
		pax1.FlightId__c = flight.Id;
		pax1.AccountId__c = acc1.Id;
		pax1.First_Name__c = 'Matthewfrancis';
		pax1.Last_Name__c = 'Killick';
		pax1.Salutation__c = 'Mr';
		pax1.PNR__c = 'jcusxh';
		pax1.Date_of_Birth__c = '1990-07-07';
		pax1.Travel_Document_Number__c = '123456789';
		pax1.WS_KEY__c = '0930_2017-07-07_Matthewfrancis Mr_Killick_jcusxh_1';
		pax1.FFP_Carrier__c = 'TG';
		pax1.FFP_Number__c = 'RE12345';
		pax1.FFP_Tier__c = 'BASE';
		paxs.add(pax1);

		insert paxs;

		List<Membership__c> memberships = new List<Membership__c>();

		Membership__c mem1 = new Membership__c();
		mem1.AccountId__c = acc1.Id;
		mem1.Airline__c = 'TG';
		mem1.Name = 'RE12345';
		mem1.EXTMember__c = 'TG_RE12345';
		mem1.Tier__c = 'BASE';
		mem1.Tier_WS__c = 'BASE';
		memberships.add(mem1);

		insert memberships;

	}

	/**
										Key Management Util
	*/

	@isTest static void test_getPaxMapByGenerateKey(){
		Passenger__c pax = Database.query(paxQuery);
		Flight__c flight = Database.query(flightQuery);
		List<Passenger__c> paxs = new List<Passenger__c>();
		paxs.add(pax);

		Map<String, Passenger__c> paxMap = DCS_Pax_Util_Service.getPaxMapByGenerateKey(null);
		System.assertEquals(null, paxMap, 'pax map from null should be null');

		paxMap = DCS_Pax_Util_Service.getPaxMapByGenerateKey(paxs);
		System.assertNotEquals(null, paxMap, 'pax map should not be null');
		System.assertEquals(1, paxMap.size(), 'pax map size should be 1');
	}

	//@isTest static void test_getDCSPaxMapByGenerateKey(){

	//}

	@isTest static void test_getDCSPaxGenerateKey(){
		WS_DCS_Pax_Model.cls_customerLevel dcspax = Mockup_DCS_Pax.getSingleDCSPax();
		Flight__c flight = Database.query(flightQuery);

		String genKey = DCS_Pax_Util_Service.getDCSPaxGenerateKey(null, null);
		System.assertEquals(null, genKey, 'Generated key from null should be null');

		genKey = DCS_Pax_Util_Service.getDCSPaxGenerateKey(dcspax, flight);
		System.assertEquals('930_2017-07-07_byungwookmr_ahn_ui2biw_1', genKey, 'Generated key should be 930_2017-07-07_byungwookmr_ahn_ui2biw_1');
	}

	@isTest static void test_generateWSKey(){
		Passenger__c pax = Database.query(paxQuery);
		Flight__c flight = Database.query(flightQuery);

		String genKey = DCS_Pax_Util_Service.generateWSKey(null, null);
		System.assertEquals(null, genKey, 'Generated key from null should be null');

		genKey = DCS_Pax_Util_Service.generateWSKey(pax, flight);
		System.assertEquals('0930_2017-07-07_MATTHEWFRANCIS MR_KILLICK_JCUSXH_1', genKey, 'Generated key should be 0930_2017-07-07_MATTHEWFRANCIS MR_KILLICK_JCUSXH_1');
	}

	@isTest static void test_keyGenerateByWSKEY(){
		String genKey = DCS_Pax_Util_Service.keyGenerateByWSKEY(null);
		System.assertEquals(null, genKey, 'key generated from null should be null');

		genKey = DCS_Pax_Util_Service.keyGenerateByWSKEY('');
		System.assertEquals(null, genKey, 'key generated from empty string should be null');

		genKey = DCS_Pax_Util_Service.keyGenerateByWSKEY('0649_2017-07-04_MATTHEWFRANCIS MR_KILLICK_JCUSXH_1');
		System.assertNotEquals(null, genKey, 'key generated from 0649_2017-07-04_MATTHEWFRANCIS MR_KILLICK_JCUSXH_1 should not be null');
		System.assertEquals('649_2017-07-04_matthewfrancismr_killick_jcusxh_1', genKey, 'key generated from ws key shoud be 649_2017-07-04_matthewfrancismr_killick_jcusxh_1');
	}

	@isTest static void test_keyGenerateByDCSPaxInfo(){
		String genKey = DCS_Pax_Util_Service.keyGenerateByDCSPaxInfo('0649', '2017-07-04', 'Mr', 'Matthewfrancis', 'Killick', 'jcusxh', '1');
		System.assertNotEquals(null, genKey, 'key generated should not be null');
		System.assertEquals('649_2017-07-04_matthewfrancismr_killick_jcusxh_1', genKey, 'key generated from ws key shoud be 649_2017-07-04_matthewfrancismr_killick_jcusxh_1');
	}

	@isTest static void test_getFlightSTD(){
		WS_DCS_Pax_Model.cls_customerLevel paxmodel = Mockup_DCS_Pax.getSingleDCSPax();
		List<WS_DCS_Pax_Model.cls_timeData> timeDatas = DCS_Pax_Model_Handler.getTimeData(paxmodel);
		String fltdateSTD = DCS_Pax_Util_Service.getFlightSTD(null);
		System.assertEquals(null, fltdateSTD, 'flight date std from null should be null');

		fltdateSTD = DCS_Pax_Util_Service.getFlightSTD(timeDatas);
		System.assertEquals('2017-07-05T20:45:00.000Z', fltdateSTD, 'flight date std should be 2017-07-05T20:45:00.000Z');
	}

	/**
											Flight Util
	*/

	@isTest static void test_getDateTimeFormat(){
		String dtime = DCS_Pax_Util_Service.getDateTimeFormat(null);
		System.assertEquals(null, dtime, 'date time format from null should be equal to null');

		dtime = DCS_Pax_Util_Service.getDateTimeFormat('2017-07-01T00:00:00');
		System.assertEquals('2017-07-01T00:00:00.000Z', dtime, 'date time format should be equal to 2017-07-01T00:00:00.000Z');

	}

	@isTest static void test_getFlightCarrier(){
		String flightCarrier = DCS_Pax_Util_Service.getFlightCarrier(null);
		System.assertEquals('TG', flightCarrier, 'flight carrier from null should be TG');

		flightCarrier = DCS_Pax_Util_Service.getFlightCarrier('WE628');
		System.assertEquals('WE', flightCarrier, 'flight carrier from WE628 should be WE');

		flightCarrier = DCS_Pax_Util_Service.getFlightCarrier('EW0649');
		System.assertEquals('EW', flightCarrier, 'flight carrier from EW0649 should be EW');
	}

	@isTest static void test_getFlightNo(){
		String fltno = DCS_Pax_Util_Service.getFlightNo(null);
		System.assertEquals(null, fltno, 'flight no from null should be null');

		fltno = DCS_Pax_Util_Service.getFlightNo('TG628');
		System.assertEquals('628', fltno, 'flight no from TG628 should be 628');

		fltno = DCS_Pax_Util_Service.getFlightNo('TG0649');
		System.assertEquals('649', fltno, 'flight no from TG0649 should be 649');
	}

	@isTest static void test_getSTDLT(){
		String STDLTDate = DCS_Pax_Util_Service.getSTDLT(null);
		System.assertEquals(null, STDLTDate, 'std lt date from null should be null');

		STDLTDate = DCS_Pax_Util_Service.getSTDLT('2017-07-01 00:00:00');
		System.assertEquals('2017-07-01', STDLTDate, 'std lt date from 2017-07-01 00:00:00 should be 2017-07-01');
	}

    /**
											Account Util
    */

    @isTest static void test_getCustomerProfileExtId(){
    	Passenger__c pax = Database.query(paxQuery);

    	String customerExternalId = DCS_Pax_Util_Service.getCustomerProfileExtId(null);
    	System.assertEquals(null, customerExternalId, 'customer external id from null should be null');

    	customerExternalId = DCS_Pax_Util_Service.getCustomerProfileExtId(pax);
    	System.assertEquals('MATTHEWFRANCIS MR_KILLICK_07JUL90_123456789', customerExternalId, 'customer external id should be MATTHEWFRANCIS MR_KILLICK_07JUL90_123456789');
    }

    @isTest static void test_getAccountIdSet(){
    	Account acc = MockupData_Test.createAccount('account name');
    	insert acc;
    	Membership__c mem = MockupData_Test.createMembership();
    	mem.AccountId__c = acc.Id;
    	Set<Id> accountIdSet = DCS_Pax_Util_Service.getAccountIdSet(new List<Membership__c>{mem});
    	
    	System.assertNotEquals(null, accountIdSet);
    	System.assertEquals(1, accountIdSet.size());
    }

    @isTest static void test_getAccountMap(){
    	List<Account> accs = new List<Account>();
    	Account acc1 = MockupData_Test.createAccount('Account1 name');
    	Account acc2 = MockupData_Test.createAccount('Account2 name');
    	Account acc3 = MockupData_Test.createAccount('Account3 name');
    	acc1.ROP_Number__c = '12345';
    	acc2.ROP_Number__c = '12346';
    	acc3.ROP_Number__c = '12347';
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);

    	Map<String, Account> accMap = DCS_Pax_Util_Service.getAccountMap(accs);
    	System.assertNotEquals(null, accMap);
    	System.assertEquals(3, accMap.size());
    }

    @isTest static void test_getAccountMapFromSFDC(){
    	List<Account> accs = new List<Account>();
    	Account acc1 = MockupData_Test.createAccount('Account1 name');
    	Account acc2 = MockupData_Test.createAccount('Account2 name');
    	Account acc3 = MockupData_Test.createAccount('Account3 name');
    	acc1.ROP_Number__c = '12345';
    	acc2.ROP_Number__c = '12346';
    	acc3.ROP_Number__c = '12347';
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);
    	insert accs;

    	List<Membership__c> mems = new List<Membership__c>();
    	Membership__c mem1 = MockupData_Test.createMembership();
    	Membership__c mem2 = MockupData_Test.createMembership();
    	Membership__c mem3 = MockupData_Test.createMembership();
    	mem1.AccountId__c = acc1.Id;
    	mem2.AccountId__c = acc2.Id;
    	mem3.AccountId__c = acc3.Id;
    	mems.add(mem1);
    	mems.add(mem2);
    	mems.add(mem3);
    	insert mems;

    	Map<String, Account> accMap = DCS_Pax_Util_Service.getAccountMapFromSFDC(mems);
    	System.assertNotEquals(null, accMap);
    	System.assertEquals(3, accMap.size());
    }

    /**
											Membership Util
    */

    @isTest static void test_getMemberExtId(){
    	Passenger__c pax = new Passenger__c();
    	pax.First_Name__c = 'Account';
    	pax.Last_Name__c = 'name';
    	pax.Salutation__c = 'Mr';
    	pax.FFP_Number__c = '12345';
    	pax.FFP_Carrier__c = 'TG';

    	String membershipExternalId = DCS_Pax_Util_Service.getMemberExtId(pax);
    	System.assertNotEquals(null, membershipExternalId);
    	System.assertEquals('TG_12345', membershipExternalId);

    }

    @isTest static void test_getMembershipExtIdSet(){
    	List<Account> accs = new List<Account>();
    	Account acc1 = MockupData_Test.createAccount('Account1 name');
    	Account acc2 = MockupData_Test.createAccount('Account2 name');
    	Account acc3 = MockupData_Test.createAccount('Account3 name');
    	acc1.ROP_Number__c = '12345';
    	acc2.ROP_Number__c = '12346';
    	acc3.ROP_Number__c = '12347';
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);
    	insert accs;

    	List<Membership__c> mems = new List<Membership__c>();
    	Membership__c mem1 = MockupData_Test.createMembership();
    	Membership__c mem2 = MockupData_Test.createMembership();
    	Membership__c mem3 = MockupData_Test.createMembership();
    	mem1.AccountId__c = acc1.Id;
    	mem1.EXTMember__c = 'TG_12345';
    	mem2.AccountId__c = acc2.Id;
    	mem2.EXTMember__c = 'TG_12346';
    	mem3.AccountId__c = acc3.Id;
    	mem3.EXTMember__c = 'TG_12347';
    	mems.add(mem1);
    	mems.add(mem2);
    	mems.add(mem3);
    	insert mems;

    	Set<String> memExternalIdSet = DCS_Pax_Util_Service.getMembershipExtIdSet(mems);
    	System.assertNotEquals(null, memExternalIdSet);
    	System.assertEquals(3, memExternalIdSet.size());
    }

    @isTest static void test_getMembershipMap(){
    	List<Account> accs = new List<Account>();
    	Account acc1 = MockupData_Test.createAccount('Account1 name');
    	Account acc2 = MockupData_Test.createAccount('Account2 name');
    	Account acc3 = MockupData_Test.createAccount('Account3 name');
    	acc1.ROP_Number__c = '12345';
    	acc2.ROP_Number__c = '12346';
    	acc3.ROP_Number__c = '12347';
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);
    	insert accs;

    	List<Membership__c> mems = new List<Membership__c>();
    	Membership__c mem1 = MockupData_Test.createMembership();
    	Membership__c mem2 = MockupData_Test.createMembership();
    	Membership__c mem3 = MockupData_Test.createMembership();
    	mem1.AccountId__c = acc1.Id;
    	mem1.EXTMember__c = 'TG_12345';
    	mem2.AccountId__c = acc2.Id;
    	mem2.EXTMember__c = 'TG_12346';
    	mem3.AccountId__c = acc3.Id;
    	mem3.EXTMember__c = 'TG_12347';
    	mems.add(mem1);
    	mems.add(mem2);
    	mems.add(mem3);
    	insert mems;

    	Map<String, Membership__c> memMap = DCS_Pax_Util_Service.getMembershipMap(mems);
    	System.assertNotEquals(null, memMap);
    	System.assertEquals(3, memMap.size());
    }

    @isTest static void test_getMembershipMapFromSFDC(){
    	List<Account> accs = new List<Account>();
    	Account acc1 = MockupData_Test.createAccount('Account1 name');
    	Account acc2 = MockupData_Test.createAccount('Account2 name');
    	Account acc3 = MockupData_Test.createAccount('Account3 name');
    	acc1.ROP_Number__c = '12345';
    	acc2.ROP_Number__c = '12346';
    	acc3.ROP_Number__c = '12347';
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);
    	insert accs;

    	List<Membership__c> mems = new List<Membership__c>();
    	Membership__c mem1 = MockupData_Test.createMembership();
    	Membership__c mem2 = MockupData_Test.createMembership();
    	Membership__c mem3 = MockupData_Test.createMembership();
    	mem1.AccountId__c = acc1.Id;
    	mem1.EXTMember__c = 'TG_12345';
    	mem2.AccountId__c = acc2.Id;
    	mem2.EXTMember__c = 'TG_12346';
    	mem3.AccountId__c = acc3.Id;
    	mem3.EXTMember__c = 'TG_12347';
    	mems.add(mem1);
    	mems.add(mem2);
    	mems.add(mem3);
    	insert mems;

    	Map<String, Membership__c> memMap = DCS_Pax_Util_Service.getMembershipMapFromSFDC(mems);
    	System.assertNotEquals(null, memMap);
    	System.assertEquals(3, memMap.size());
    }

    /**
											Pax Util
    */

    @isTest static void test_getCurrentPaxMap(){
    	Flight__c flight  = Database.query(flightQuery);
    	Map<String, Passenger__c> paxMap = DCS_Pax_Util_Service.getCurrentPaxMap(flight);
    	System.assertNotEquals(null, paxMap);
    	System.assertEquals(1, paxMap.size());
    }

    //@isTest static void test_updatePaxWSKeyByCurrentPax(){

    //}

    @isTest static void test_comparePaxWithROPInfo(){
    	Passenger__c pax = new Passenger__c();
    	pax.First_Name__c = 'Passenger';
    	pax.Last_Name__c = 'Last-Name';

    	Account acc = new Account();
    	acc.First_Name__c = 'Passenger';
    	acc.Last_Name__c = 'LastName';
    	Boolean isTheSamePerson = DCS_Pax_Util_Service.comparePaxWithROPInfo(pax, acc);
    	System.assertEquals(true, isTheSamePerson);
    }

    @isTest static void test_getPaxListToDelete(){
        Passenger__c pax1 = new Passenger__c();
        pax1.First_Name__c = 'Passenger';
        pax1.Last_Name__c = 'Last-Name';

        Passenger__c pax2 = new Passenger__c();
        pax2.First_Name__c = 'Passenger';
        pax2.Last_Name__c = 'Last-Name2';

        Passenger__c pax3 = new Passenger__c();
        pax3.First_Name__c = 'Passenger';
        pax3.Last_Name__c = 'Last-Name3';

        Map<String, Passenger__c> paxMap = new Map<String, Passenger__c>{'1' => pax1};
        Map<String, Passenger__c> sfdcPaxMap = new Map<String, Passenger__c>{'1' => pax1, '2' => pax2, '3' => pax3};

        List<Passenger__c> paxs = DCS_Pax_Util_Service.getPaxListToDelete(paxMap, sfdcPaxMap);
        System.assertNotEquals(null, paxs);
        System.assertEquals(2, paxs.size());
    }

    @isTest static void test_updateDCSPaxIdFromPaxSFDC(){
        Passenger__c pax1 = new Passenger__c();
        pax1.First_Name__c = 'Passenger';
        pax1.Last_Name__c = 'Last-Name';

        Passenger__c pax2 = new Passenger__c();
        pax2.First_Name__c = 'Passenger';
        pax2.Last_Name__c = 'Last-Name2';

        Passenger__c pax3 = new Passenger__c();
        pax3.First_Name__c = 'Passenger';
        pax3.Last_Name__c = 'Last-Name3';

        Map<String, Passenger__c> paxMap = new Map<String, Passenger__c>{'1' => pax1, '2' => pax2, '3' => pax3};
        Map<String, Passenger__c> sfdcPaxMap = new Map<String, Passenger__c>{'1' => pax1, '2' => pax2, '3' => pax3};
        insert sfdcPaxMap.values();

        DCS_Pax_Util_Service.updateDCSPaxIdFromPaxSFDC(paxMap, sfdcPaxMap);
        for(String key : sfdcPaxMap.keySet()){
            System.assertEquals(sfdcPaxMap.get(key).Id, paxMap.get(key).Id);
        }
    }

    /**
											DB handling
    */

    //@isTest static void test_getError(){

    //}

    //@isTest static void test_updateToDB(){

    //}

    @isTest static void test_dedupAccountMap(){
        Map<String, Account> accs = new Map<String, Account>();
        Account acc1 = new Account(
            First_Name__c = 'Account',
            Last_Name__c = 'Last-Name',
            Customer_External_Id__c = 'key-1'
        );

        Account acc2 = new Account(
            First_Name__c = 'Account',
            Last_Name__c = 'Last-Name',
            Customer_External_Id__c = 'key-2'
        );

        Account acc3 = new Account(
            First_Name__c = 'Account',
            Last_Name__c = 'Last-Name',
            Customer_External_Id__c = 'key-2'
        );

        Account acc4 = new Account(
            First_Name__c = 'Account',
            Last_Name__c = 'Last-Name',
            Customer_External_Id__c = 'key-4'
        );

        accs.put('1', acc1);
        accs.put('2', acc2);
        accs.put('3', acc3);
        accs.put('4', acc4);

        DCS_Pax_Util_Service.dedupAccountMap(accs);
        System.assertNotEquals(null, accs);
        System.assertEquals(3, accs.size());
    }

    @isTest static void test_dedupMembershipMap(){
        Map<String, Membership__c> memMap = new Map<String, Membership__c>();
        Membership__c mem1 = new Membership__c(
            Name = 'EE12345',
            Airline__c = 'TG',
            EXTMember__c = 'TG_EE12345'
        );

        Membership__c mem2 = new Membership__c(
            Name = 'EE12346',
            Airline__c = 'TG',
            EXTMember__c = 'TG_EE12346'
        );

        Membership__c mem3 = new Membership__c(
            Name = 'EE12347',
            Airline__c = 'TG',
            EXTMember__c = 'TG_EE12347'
        );

        Membership__c mem4 = new Membership__c(
            Name = 'EE12347',
            Airline__c = 'TG',
            EXTMember__c = 'TG_EE12347'
        );

        memMap.put('1', mem1);
        memMap.put('2', mem2);
        memMap.put('3', mem3);
        memMap.put('4', mem4);

        DCS_Pax_Util_Service.dedupMembershipMap(memMap);
        System.assertNotEquals(null, memMap);
        System.assertEquals(3, memMap.size());
    }

    /**
                                        Callout Service
    */

    @isTest static void test_getFilterListMap(){
    	List<Map<String, String>> filterListMap = DCS_Pax_Util_Service.getFilterListMap('base');
    	System.assertNotEquals(null, filterListMap, 'filter list map base should not equal to null');
    	System.assertEquals(true, filterListMap.isEmpty(), 'filter list map base should be empty');

    	filterListMap = DCS_Pax_Util_Service.getFilterListMap('pst');
    	System.assertNotEquals(null, filterListMap, 'filter list map pst should not equal to null');
    	System.assertEquals(false, filterListMap.isEmpty(), 'filter list pst base should not be empty');
		System.assertEquals(2, filterListMap.size(), 'filter list map pst size shoule be 2');    	
    }

    @isTest static void test_getGroupIndicator(){
    	List<String> indicators = DCS_Pax_Util_Service.getGroupIndicator();
    	System.assertNotEquals(null, indicators, 'indicators should not be null');
    	System.assertEquals(false, indicators.isEmpty(), 'indicators should not be empty');
    	System.assertEquals(3, indicators.size(), 'indicators size should be equal to 3');
    }
}