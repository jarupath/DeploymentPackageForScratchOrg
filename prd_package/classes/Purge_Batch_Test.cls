@isTest
private class Purge_Batch_Test
{
	@isTest
	static void testPurge() {
		MockupData_Test.initialApplicationLogCustomSetting();
		MockupData_Test.initializeSystemConfigurationCustomSetting();

		List<Flight__c> flightsForInsert = new List<Flight__c>();
		Flight__c flight1 = MockupData_Test.createFlight('TG0628', '30Sep16', 1);
		Flight__c flight2 = MockupData_Test.createFlight('TG0629', '30Sep16', 1);
		Flight__c flight3 = MockupData_Test.createFlight('TG0630', '30Sep16', 1);
		flightsForInsert.add(flight1);
		flightsForInsert.add(flight2);
		flightsForInsert.add(flight3);
		insert flightsForInsert;

		List<Case> casesForInsert = new List<Case>();
		Case newCase1 = MockupData_Test.createCase('01', 'New', 'Maintenance');
		newCase1.Flightid__c = flight1.Id;
		casesForInsert.add(newCase1);
		
		Case newCase3 = MockupData_Test.createCase('03', 'New', 'Maintenance');
		newCase3.Flightid__c = flight3.Id;
		casesForInsert.add(newCase3);
		insert casesForInsert;

		Test.setCreatedDate(flight1.Id, System.today().addDays(-240));
		Test.setCreatedDate(flight2.Id, System.today().addDays(-240));
		
		Test.startTest();
		Purge_Batch purgeBatch = new Purge_Batch();
		Database.executeBatch(purgeBatch);
		Test.stopTest();

		List<Flight__c> actualFlights = [SELECT Id FROM Flight__c];
		System.assertEquals(2, actualFlights.size());
	}
}