@isTest
private class MB_RESTPassengerServiceTest {

	@isTest static void testRetrievePassengerInfo() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CREW_LIST_TRIGGER, false);

		Aircraft__c aircraft = MockupData_Test.getMockUpAircraft();
		insert aircraft;
		MockupData_Test.insertMockUpServiceEquipment();
		MockupData_Test.insertEquipmentOnAircraft(aircraft.Aircraft_Description__c);
		Flight__c flight = MockupData_Test.getMockUpFlight();
		flight.STD_UTC__c = String.valueOf(DateTime.now());
		flight.STA_UTC__c = String.valueOf(DateTime.now().addHours(10));
		flight.AircraftId__c = aircraft.Id;
		insert flight;
		Crew__c crew = new Crew__c (Crew_First_Name__c = 'TEST', Personel_Id__c = 'TEST');
		insert crew;
		Crew_List__c crewList = new Crew_List__c(CrewId__c = crew.Id, FlightId__c = flight.Id);
		insert crewList;
		Crew_Mapping__c crewMapping = new Crew_Mapping__c(CrewId__c = crew.Id, UserId__c = UserInfo.getUserId(), isActive__c = true, Last_Sync_Time__c = Datetime.now());
		insert crewMapping;

		Passenger__c passengerWithoutAccount = new Passenger__c(
		    Name = 'John Smith',
		    First_Name__c = 'John',
		    Last_Name__c = 'Smith',
		    FlightId__c = flight.Id
		);
		insert passengerWithoutAccount;

		Account account = new Account(Name = 'Alan Smith');
		insert account;
		Membership__c ropMembership = new Membership__c(Name = '12345', Airline__c = 'TG', AccountId__c = account.Id);
		insert ropMembership;
		Passenger__c passengerWithROP = new Passenger__c(
		    Name = 'Alan Smith',
		    First_Name__c = 'Alan',
		    Last_Name__c = 'Smith',
		    AccountId__c = account.Id,
		    FlightId__c = flight.Id,
		    FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY,
		    FFP_Number__c = '12345',
		    FFP_Tier__c = 'PLAT',
		    SSR__c = true,
		    SSR_Service__c = 'WCHS(Confirmed)',
		    Special_Meal__c = 'SFML[- NO Crab]'
		);
		insert passengerWithROP;

		List<MB_RestResponseInfoModel.passengerInfo_model> passengerModelList = MB_RESTPassengerService.retrievePassengerInfo();
		Assert.assertEquals(2, passengerModelList.size());
	}

	@isTest static void testGetPaxKey() {
		Flight__c flight = new Flight__c(Name = 'TG930 / 04MAR25', Flight_Number__c = 'TG0930', Leg_Number__c = 1, STD_UTC__c = '04Mar25 1730', STD_LT__c = '04Mar25 1830', STA_UTC__c = '04Mar25 2030', Flight_Date_UTC__c = '04Mar25', Flight_Date_LT__c = '04Mar25', Flight_External_Id__c = 'TG0930_04Mar25_1');
		insert flight;
		String firstName = 'JOHN MR';
		String lastName = 'SMITH';
		String pnr = '1234';
		Passenger__c pax = new Passenger__c(First_Name__c = firstName, Last_Name__c = lastName, PNR__c = pnr, FlightId__c = flight.Id);
		insert pax;
		Passenger__c queryPax = [SELECT Id, Pax_Key_txt__c FROM Passenger__c WHERE Id = :pax.Id];
		String paxKey = queryPax.Pax_Key_txt__c;
		Assert.assertEquals(firstName + '_' + lastName + '_' + pnr + '_TG0930_04Mar25', paxKey);
	}

	/*
		Scenario: Update Passenger Psychology of a Passenger with an Account
		Positive/Negative Case: Postive
		Expected Result:
		- Psychology fields in Account will be updated
	*/
	@isTest static void testUpdatePassengerPsychologyPositiveOneAccount(){
		String pLike = 'A';
		String dislike = 'B';
		String byOther = 'C';
		String byGnd = 'D';
		String bySale = 'E';

		Account testAccount = MockupData_Test.createAccount('Gas');
		insert testAccount;
		MB_RestRequestInfoModel.passengerPsychology_model paxPsy = new MB_RestRequestInfoModel.passengerPsychology_model();
		paxPsy.accId = testAccount.Id;
		paxPsy.pLike = pLike;
		paxPsy.dislike = dislike;
		paxPsy.byOther = byOther;
		paxPsy.byGnd = byGnd;
		paxPsy.bySale = bySale;

		List<MB_RestRequestInfoModel.passengerPsychology_model> paxPsyList = new List<MB_RestRequestInfoModel.passengerPsychology_model> {paxPsy};
		MB_RESTPassengerService.updatePassengerPsychology(paxPsyList);

		testAccount = [SELECT Id, Like__c, Dislike__c, Information__c, By_Ground_Customer_Service__c, By_Sale_and_Marketing__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];
		Assert.assertEquals(pLike, testAccount.Like__c);
		Assert.assertEquals(dislike, testAccount.Dislike__c);
		Assert.assertEquals(byOther, testAccount.Information__c);
		Assert.assertEquals(byGnd, testAccount.By_Ground_Customer_Service__c);
		Assert.assertEquals(bySale, testAccount.By_Sale_and_Marketing__c);
	}

	/*
		Scenario: Update Passenger Psychology of two Passenger with two Account
		Positive/Negative Case: Postive
		Expected Result:
		- Psychology fields in Accounts will be updated
	*/
	@isTest static void testUpdatePassengerPsychologyPositiveTwoAccount(){
		String pLike = 'A';
		String dislike = 'B';
		String byOther = 'C';
		String byGnd = 'D';
		String bySale = 'E';

		Account testAccount = MockupData_Test.createAccount('Gas');
		insert testAccount;

		Account testAccount2 = MockupData_Test.createAccount('Vee');
		insert testAccount2;

		MB_RestRequestInfoModel.passengerPsychology_model paxPsy = new MB_RestRequestInfoModel.passengerPsychology_model();
		paxPsy.accId = testAccount.Id;
		paxPsy.pLike = pLike;
		paxPsy.dislike = dislike;
		paxPsy.byOther = byOther;
		paxPsy.byGnd = byGnd;
		paxPsy.bySale = bySale;

		MB_RestRequestInfoModel.passengerPsychology_model paxPsy2 = new MB_RestRequestInfoModel.passengerPsychology_model();
		paxPsy2.accId = testAccount2.Id;
		paxPsy2.pLike = pLike + '2';
		paxPsy2.dislike = dislike + '2';
		paxPsy2.byOther = byOther + '2';
		paxPsy2.byGnd = byGnd + '2';
		paxPsy2.bySale = bySale + '2';

		List<MB_RestRequestInfoModel.passengerPsychology_model> paxPsyList = new List<MB_RestRequestInfoModel.passengerPsychology_model> ();
		paxPsyList.add(paxPsy);
		paxPsyList.add(paxPsy2);
		MB_RESTPassengerService.updatePassengerPsychology(paxPsyList);

		testAccount = [SELECT Id, Like__c, Dislike__c, Information__c, By_Ground_Customer_Service__c, By_Sale_and_Marketing__c FROM Account WHERE Id = :testAccount.Id LIMIT 1];
		Assert.assertEquals(pLike, testAccount.Like__c);
		Assert.assertEquals(dislike, testAccount.Dislike__c);
		Assert.assertEquals(byOther, testAccount.Information__c);
		Assert.assertEquals(byGnd, testAccount.By_Ground_Customer_Service__c);
		Assert.assertEquals(bySale, testAccount.By_Sale_and_Marketing__c);

		testAccount2 = [SELECT Id, Like__c, Dislike__c, Information__c, By_Ground_Customer_Service__c, By_Sale_and_Marketing__c FROM Account WHERE Id = :testAccount2.Id LIMIT 1];
		Assert.assertEquals(pLike + '2', testAccount2.Like__c);
		Assert.assertEquals(dislike + '2', testAccount2.Dislike__c);
		Assert.assertEquals(byOther + '2', testAccount2.Information__c);
		Assert.assertEquals(byGnd + '2', testAccount2.By_Ground_Customer_Service__c);
		Assert.assertEquals(bySale + '2', testAccount2.By_Sale_and_Marketing__c);
	}

}