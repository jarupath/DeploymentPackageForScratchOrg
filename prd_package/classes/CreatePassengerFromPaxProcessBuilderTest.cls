@isTest
private class CreatePassengerFromPaxProcessBuilderTest {

	@testSetup static void DataForTest() {
		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		Flight__c mockupFlight = MockupData_Test.createFlight('0517', '07Dec16', 1);
		insert mockupFlight;
		Passenger__c pax = new Passenger__c(
		    Name = 'Khun Toey',
		    First_Name__c = 'Toey',
		    Last_Name__c = 'Khun',
		    Email_1__c = 'toey.k@gmail.com',
		    Date_of_Birth_Input__c = Date.newInstance(1994, 11, 12),
		    FlightId__c = mockupFlight.Id,
		    Travel_Document_Number__c = 'TRAVELTEST01'
		);
		insert pax;
		Case newCase1 = MockupData_Test.createCase('BB001F071216', 'Open', 'Maintenance');
		Case newCase2 = MockupData_Test.createCase('BB002F071216', 'Open', 'Maintenance');
		Case newCase3 = MockupData_Test.createCase('BB003F071216', 'Open', 'Maintenance');
		newCase1.Passengerid__c = pax.Id;
		newCase2.Passengerid__c = pax.Id;
		newCase3.Passengerid__c = pax.Id;
		newCase1.Flightid__c = mockupFlight.Id;
		newCase2.Flightid__c = mockupFlight.Id;
		newCase3.Flightid__c = mockupFlight.Id;
		List<Case> caseList = new List<Case> {newCase1, newCase2, newCase3};
		insert caseList;
		CreatePassengerFromPaxProcessBuilder.createAccountFromPax(new List<Passenger__c> {pax});
	}

	@isTest static void testCreateAccountFromPaxShouldCreateAccountAndTravelDocumentWhen4KeyFromPaxAreInclude() {
		List<Account> accountList = [SELECT
		                             Id, Name,
		                             First_Name__c,
		                             Last_Name__c,
		                             Mailling_Address__c,
		                             Date_of_Birth__c,
		                             Travel_Document__c,
		                             Customer_External_Id__c
		                             FROM Account WHERE Customer_External_Id__c = 'Toey_Khun_12NOV94_TRAVELTEST01'];
		Account accountFromMethod = accountList.get(0);
		Account account = new Account(
		    Name = 'Khun Toey',
		    First_Name__c = 'Toey',
		    Last_Name__c = 'Khun',
		    Mailling_Address__c = 'toey.k@gmail.com',
		    Date_of_Birth__c = Date.newInstance(1994, 11, 12),
		    Travel_Document__c = 'TRAVELTEST01',
		    Travel_Document_Expiry_Date__c = null,
		    Customer_External_Id__c = 'Toey_Khun_12NOV94_TRAVELTEST01'
		);

		List<Travel_Document__c> travelList = [SELECT
		                                       Id,
		                                       ExtDocument__c,
		                                       Travel_Document_Number__c
		                                       FROM Travel_Document__c
		                                       WHERE AccountId__c = :accountList.get(0).Id];
		Travel_Document__c travelFromMethod = travelList.get(0);
		Travel_Document__c travel = new Travel_Document__c(
		    ExtDocument__c = 'TRAVELTEST01',
		    Travel_Document_Number__c = 'TRAVELTEST01'
		);
		System.assertEquals(account.Name, accountFromMethod.Name, 'Assert Equal Account Name');
		System.assertEquals(account.First_Name__c, accountFromMethod.First_Name__c, 'Assert Equal Account First Name');
		System.assertEquals(account.Last_Name__c, accountFromMethod.Last_Name__c, 'Assert Equal Account Last Name');
		System.assertEquals(account.Mailling_Address__c, accountFromMethod.Mailling_Address__c, 'Assert Equal Account Mailling Address');
		System.assertEquals(account.Date_of_Birth__c, accountFromMethod.Date_of_Birth__c, 'Assert Equal Account Date of Birth');
		System.assertEquals(account.Travel_Document__c, accountFromMethod.Travel_Document__c, 'Assert Equal Account Travel Document');
		System.assertEquals(account.Customer_External_Id__c, accountFromMethod.Customer_External_Id__c, 'Assert Equal Account Customer External ID');

		System.assertEquals(travel.ExtDocument__c, travelFromMethod.ExtDocument__c, 'Assert Equal Travel Document ExtDocument');
		System.assertEquals(travel.Travel_Document_Number__c, travelFromMethod.Travel_Document_Number__c, 'Assert Equal Travel Document Number');
	}

	@isTest static void testCreateAccountFromPaxShuoldCreateAccountAndCreateLookupRelationFromCaseToAccount() {
		List<Passenger__c> paxList = [SELECT Id FROM Passenger__c];
		System.assertEquals(1, paxList.size());
		Passenger__c pax = paxList.get(0);
		List<Case> casePaxList = [SELECT Id FROM Case WHERE Passengerid__c = :pax.Id];
		List<Account> accountList = [SELECT Id FROM Account WHERE Customer_External_Id__c = 'Toey_Khun_12NOV94_TRAVELTEST01'];
		Account account = accountList.get(0);
		List<Case> caseAccountList = [SELECT Id FROM Case WHERE AccountId = :account.Id];

		System.assertEquals(casePaxList.size(), caseAccountList.size(), 'Assert Equal Case Amount Between Passenger and Account');
	}
}