@isTest
private class TempPassengerTriggerTest {
	
	/* This function is used to reconcile the input date */
	@isTest static void testCorrectnessOfInputData() {
		String name = 'Earth Pho-ngoen';
		String ropNo = 'TS00001';
		String tier = 'Member';
		String gender = 'M';
		String status = 'AC';
		String email = 'Earth@earth.com';

		TempPassenger__c temp1 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, status, email);
		insert temp1;
		List<TempPassenger__c> templist = [SELECT Id, Name, ROP_Title__c, ROP_Number__c, ROP_First_Name__c, 
											ROP_Last_Name__c, ROP_Date_of_Birth__c, ROP_Mailing_Address__c, 
												ROP_Home_Phone__c, ROP_Business_Phone__c, ROP_Mobile_Phone__c, 
													ROP_Fax_Phone__c, ROP_Gender__c, ROP_Email__c, ROP_Tier__c, 
														ROP_Seat_Preference__c, ROP_Food_Preference__c, ROP_Language__c, ROP_Status__c 
															FROM TempPassenger__c 
																WHERE ROP_Number__c = :ropNo];
		//List<TempPassenger__c> templist = [SELECT Id FROM TempPassenger__c WHERE ROP_Number__c = :ropNo];
		System.assertNotEquals(null, templist);
	}

	@isTest static void testCreateNewAccount(){
		String name = 'Earth Pho-ngoen';
		String ropNo = 'TS00001';
		String tier = 'Member';
		String gender = 'M';
		String status = 'AC';
		String email = 'Earth@earth.com';

		TempPassenger__c temp1 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, status, email);
		insert temp1;
		List<Account> accountlist = [SELECT Id FROM Account WHERE ROP_Number__c = :ropNo];
		System.assertNotEquals(null, accountlist);
	}

	@isTest static void testUpdateAccount(){
		String name = 'Earth Pho-ngoen';
		String ropNo = 'TS00001';
		String tier = 'Member';
		String gender = 'M';
		String status = 'AC';
		String email = 'Earth@earth.com';
		TempPassenger__c temp1 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, status, email);
		insert temp1;
		TempPassenger__c temp2 = MockupData_Test.createTempPassenger('E A', ropNo, tier, gender, status, email);
		insert temp2;

		List<Account> accountlist = [SELECT Id, Name FROM Account WHERE ROP_Number__c = :ropNo];
		System.assertEquals(1, accountlist.size());
		System.assertEquals('E A', accountlist.get(0).Name);
	}

	@isTest static void testCreateNewMembership(){
		String name = 'Earth Pho-ngoen';
		String ropNo = 'TS00001';
		String tier = 'Member';
		String gender = 'M';
		String status = 'AC';
		String email = 'Earth@earth.com';

		TempPassenger__c temp1 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, status, email);
		insert temp1;
		List<Membership__c> memlist = [SELECT Id FROM Membership__c WHERE Name = :ropNo];
		System.assertNotEquals(null, memlist);
	}

	@isTest static void testUpdateMembership(){
		String name = 'Earth Pho-ngoen';
		String ropNo = 'TS00001';
		String tier = 'Member';
		String gender = 'M';
		String status = 'AC';
		String email = 'Earth@earth.com';
		TempPassenger__c temp1 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, status, email);
		insert temp1;
		TempPassenger__c temp2 = MockupData_Test.createTempPassenger(name, ropNo, tier, gender, 'IN', email);
		insert temp2;

		List<Membership__c> memlist = [SELECT Id, Status__c FROM Membership__c WHERE Name = :ropNo];
		System.assertEquals(1, memlist.size());
		System.assertEquals('Inactive', memlist.get(0).Status__c);
	}
}