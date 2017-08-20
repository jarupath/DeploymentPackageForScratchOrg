@isTest
private class DCS_Pax_Record_Service_Test {

	@testSetup static void DataPreparation(){
		List<Account> accs = new List<Account>();
    	Account acc1 = Mockup_DCS_Pax.getAccount('1');
    	Account acc2 = Mockup_DCS_Pax.getAccount('2');
    	Account acc3 = Mockup_DCS_Pax.getAccount('3');
    	accs.add(acc1);
    	accs.add(acc2);
    	accs.add(acc3);
    	insert accs;
	}

	/**
										Manage Account
	*/
	
	@isTest static void test_getSFDCAccountMap() {
		Set<String> keySet = new Set<String>{'accountmr_name1_01jan90_12341', 'accountmr_name2_01jan90_12342', 'accountmr_name3_01jan90_12343'};
		Map<String, Account> accMap = DCS_Pax_Record_Service.getSFDCAccountMap(keySet);
		System.assertNotEquals(null, accMap);
		System.assertEquals(3, accMap.size());

		accMap = DCS_Pax_Record_Service.getSFDCAccountMap();
		System.assertNotEquals(null, accMap);
		System.assertEquals(3, accMap.size());
	}
	
	@isTest static void test_querySFDCAccountMap() {
		Set<String> keySet = new Set<String>{'accountmr_name1_01jan90_12341', 'accountmr_name2_01jan90_12342', 'accountmr_name3_01jan90_12343'};
		DCS_Pax_Record_Service.querySFDCAccountMap(keySet);
		Map<String, Account> accMap = DCS_Pax_Record_Service.sfdcAccountMap;
		System.assertNotEquals(null, accMap);
		System.assertEquals(3, accMap.size());
	}
	
	@isTest static void test_isContainsAllKey() {
		Set<String> keySet = new Set<String>{'accountmr_name1_01jan90_12341', 'accountmr_name2_01jan90_12342', 'accountmr_name3_01jan90_12343'};
		Map<String, Account> accMap = DCS_Pax_Record_Service.getSFDCAccountMap(keySet);
		Boolean isContainsAllKey = DCS_Pax_Record_Service.isContainsAllKey(accMap, keySet);
		System.assertEquals(true, isContainsAllKey);
	}
	
	@isTest static void test_concreteAccount() {
		
	}

	@isTest static void test_isReadyForCreateAccount() {
		Boolean isReadyForCreateAccount = DCS_Pax_Record_Service.isReadyForCreateAccount(Mockup_DCS_Pax.getPassenger('1'));
		System.assertEquals(true, isReadyForCreateAccount);
	}
	
	@isTest static void test_createAccountFromPax() {
		Passenger__c pax = Mockup_DCS_Pax.getPassenger('1');
		Account acc1 = DCS_Pax_Record_Service.createAccountFromPax(pax, true);
		System.assertEquals('Passenger', acc1.First_Name__c);
		System.assertEquals('name1', acc1.Last_Name__c);
		System.assertEquals('Male', acc1.Gender__c);
		System.assertEquals('Mr', acc1.Salutation__c);
		System.assertEquals('email@gmail.com', acc1.Email_1__c);
		System.assertEquals('+66900909999', acc1.Mobile__c);
		System.assertEquals('12341', acc1.Travel_Document__c);
		System.assertEquals('THA', acc1.Nationality__c);
		System.assertEquals(Date.valueOf('1990-01-01'), acc1.Date_of_Birth__c);

		insert acc1;
		insert pax;
		
		BE8_SoqlBuilder soqlBuilder = new BE8_SoqlBuilder('Passenger__c');
		soqlBuilder.addField('AccountId__c');
		soqlBuilder.addCondition('Id', pax.Id);
		soqlBuilder.setLimit(1);
		pax = Database.query(soqlBuilder.getQueryStr());

		System.assertEquals(pax.AccountId__c, acc1.Id);
	}

	@isTest static void test_getCustomerExternalIdTrimFromAccount() {
		Passenger__c pax = Mockup_DCS_Pax.getPassenger('1');
		Set<String> customerExternalIds = DCS_Pax_Record_Service.getCustomerExternalIdTrimFromAccount(new List<Passenger__c>{pax});

		System.assertNotEquals(null, customerExternalIds);
		System.assertEquals(1, customerExternalIds.size());
		System.assertEquals('passengermr_name1_01jan90_12341', new List<String>(customerExternalIds).get(0));
	}

	/**
										Manage Membership
	*/
	
	@isTest static void test_concreteMembership() {
		Account acc1 = Mockup_DCS_Pax.getAccount('1');
		insert acc1;
		Passenger__c pax1 = Mockup_DCS_Pax.getPassenger('1');
		pax1.AccountId__c = acc1.Id;

		
	}

	@isTest static void test_getPaxMapToCreateMembership() {
		
	}
	
	@isTest static void test_createMembershipFromPax() {
		
	}

    /**
										Manage Travel Document
    */

	@isTest static void test_concreteTravelDoc() {
		
	}

	@isTest static void test_getPaxListToCreateTravelDoc() {
		
	}
	
	@isTest static void test_createTravelDocumentFromPax() {
		
	}

	/**
										Manage Passenger
	*/

	@isTest static void test_getFlight() {
		
	}

	@isTest static void test_updatePaxInfoCheckbox() {
		
	}
	
	@isTest static void test_updatePaxPersonalInfo() {
		
	}

	@isTest static void test_updatePaxSeatInfo() {
		
	}

	@isTest static void test_updatePaxFlightInfo() {
		
	}

	@isTest static void test_updatePaxWSKey() {
		
	}
	
	@isTest static void test_getPaxConnectingFlight() {
		
	}

	@isTest static void test_getPaxTicketInfo() {
		
	}

	@isTest static void test_SSRPaxTravelDoc() {
		
	}

	@isTest static void test_SSRPaxFQTV() {
		
	}

	@isTest static void test_SSRPaxEmail() {
		
	}

	@isTest static void test_SSRPaxPhone() {
		
	}

	@isTest static void test_SSRPaxSpecialMeal() {
		
	}

	@isTest static void test_SSRPaxVipVVip() {
		
	}

	@isTest static void test_SSRPaxInfant() {
		
	}

	@isTest static void test_SSROthers() {
		
	}
}