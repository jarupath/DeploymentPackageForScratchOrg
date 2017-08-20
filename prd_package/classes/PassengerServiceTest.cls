@isTest
private class PassengerServiceTest {

	@isTest static void testConvertSubTierToActualTier() {
		Passenger__c passenger1 = new Passenger__c(First_Name__c = 'HELLO WORLD MR', Last_Name__c = 'SAWASDEE YO', FFP_Carrier__c = BE8_GlobalConstants.DEFAULT_TG_COMPANY, FFP_Tier__c = 'PSP1');
		PassengerService.convertSubTierToActualTier(new List<Passenger__c> {passenger1});
		Assert.assertEquals(passenger1.FFP_Tier__c, 'PLAT');
	}

	@isTest static void testDedupPassengerToChangeSeatList() {
		Passenger__c passenger1 = new Passenger__c(First_Name__c = 'HELLO WORLD MR', Last_Name__c = 'SAWASDEE YO', Last_Change_Seat_DateTime__c = System.now());
		insert passenger1;
		Passenger__c passenger2 = new Passenger__c(Id = passenger1.Id, First_Name__c = 'HELLO WORLD MR', Last_Name__c = 'SAWASDEE YO', Last_Change_Seat_DateTime__c = System.now().addHours(2));
		List<Passenger__c> result = PassengerService.dedupPassengerToChangeSeatList(new List<Passenger__c> {passenger1, passenger2});
		Assert.assertEquals(1, result.size());
	}

	@isTest static void testFormatPassengerNameFromList() {
		Passenger__c passenger1 = new Passenger__c(First_Name__c = 'HELLO WORLD MR', Last_Name__c = 'SAWASDEE YO');
		PassengerService.formatPassengerNameFromList(new List<Passenger__c> {passenger1});
		Assert.assertEquals('Mr. Hello World Sawasdee Yo', passenger1.Passenger_Name_Formatted__c);
		Assert.assertEquals('Mr.', passenger1.Passenger_Salutation_Auto__c);
		Assert.assertEquals('HELLO WORLD', passenger1.Passenger_First_Name_Auto__c);

		Passenger__c passenger2 = new Passenger__c(First_Name__c = 'HELLO WORLD MS', Last_Name__c = 'SAWASDEE YO');
		PassengerService.formatPassengerNameFromList(new List<Passenger__c> {passenger2});
		Assert.assertEquals('Ms. Hello World Sawasdee Yo', passenger2.Passenger_Name_Formatted__c);
		Assert.assertEquals('Ms.', passenger2.Passenger_Salutation_Auto__c);
		Assert.assertEquals('HELLO WORLD', passenger2.Passenger_First_Name_Auto__c);

		Passenger__c passenger3 = new Passenger__c(First_Name__c = 'HELLO WORLD', Last_Name__c = 'SAWASDEE YO');
		PassengerService.formatPassengerNameFromList(new List<Passenger__c> {passenger3});
		Assert.assertEquals('Hello World Sawasdee Yo', passenger3.Passenger_Name_Formatted__c);
		Assert.assertEquals(null, passenger3.Passenger_Salutation_Auto__c);
		Assert.assertEquals(null, passenger3.Passenger_First_Name_Auto__c);

		Passenger__c passenger4 = new Passenger__c(First_Name__c = 'HELLO WORLDMR', Last_Name__c = 'SAWASDEE YO');
		PassengerService.formatPassengerNameFromList(new List<Passenger__c> {passenger3});
		//Assert.assertEquals('Hello World Sawasdee Yo', passenger4.Passenger_Name_Formatted__c);
		Assert.assertEquals(null, passenger4.Passenger_Salutation_Auto__c);
		Assert.assertEquals(null, passenger4.Passenger_First_Name_Auto__c);
	}

	@isTest static void testChangePassengersSeat() {
		Passenger__c passenger = new Passenger__c();
		passenger.Name = 'TEST';
		passenger.Checkin_Seat__c = '1A';
		insert passenger;

		passenger.Change_Seat__c = '2B';
		passenger.Change_Cabin_Class__c = 'F';
		passenger.Last_Change_Seat_DateTime__c = System.now().addHours(-3);
		update passenger;
		passenger = [SELECT Id, Name, Change_Seat__c, Change_Cabin_Class__c, Last_Change_Seat_DateTime__c FROM Passenger__c WHERE Id = :passenger.Id LIMIT 1];
		Assert.assertEquals('2B', passenger.Change_Seat__c);
		Assert.assertEquals('F', passenger.Change_Cabin_Class__c);

		passenger.Change_Seat__c = '23B';
		passenger.Change_Cabin_Class__c = 'C';
		passenger.Last_Change_Seat_DateTime__c = System.now().addHours(1);
		update passenger;
		passenger = [SELECT Id, Name, Change_Seat__c, Change_Cabin_Class__c, Last_Change_Seat_DateTime__c FROM Passenger__c WHERE Id = :passenger.Id LIMIT 1];
		Assert.assertEquals('23B', passenger.Change_Seat__c);
		Assert.assertEquals('C', passenger.Change_Cabin_Class__c);

		passenger.Change_Seat__c = '45B';
		passenger.Change_Cabin_Class__c = 'Y';
		passenger.Last_Change_Seat_DateTime__c = System.now().addHours(-1);
		update passenger;
		passenger = [SELECT Id, Name, Change_Seat__c, Change_Cabin_Class__c, Last_Change_Seat_DateTime__c FROM Passenger__c WHERE Id = :passenger.Id LIMIT 1];
		Assert.assertEquals('23B', passenger.Change_Seat__c);
		Assert.assertEquals('C', passenger.Change_Cabin_Class__c);

	}
}