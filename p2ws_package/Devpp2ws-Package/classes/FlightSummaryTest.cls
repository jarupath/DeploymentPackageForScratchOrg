@isTest
private class FlightSummaryTest {

	@isTest static void testConstructor() {
		// TG628 / 29NOV16 Leg 1 and 2
		List<Flight__c> flightList = (List<Flight__c>) System.JSON.deserializeStrict('[{"attributes":{"type":"Flight__c","url":"/services/data/v38.0/sobjects/Flight__c/a0DN000000BrBfdMAF"},"Name":"TG628 / 29NOV16","Flight_Number__c":"TG0628","Flight_Date_UTC__c":"2016-11-29","Origin__c":"BKK","Destination__c":"ICN","Flight_External_ID__c":"TG0628_29Nov16_1","Flight_Date_LT__c":"2016-11-29","ETA_LT__c":"2016-11-29 14:07:00","ATA_LT__c":"2016-11-29 14:26:00","ATA_UTC__c":"2016-11-29 06:26:00","ATD_UTC__c":"2016-11-29 03:27:00","STD_UTC__c":"2016-11-29 03:30:00","ATD_LT__c":"2016-11-29 10:27:00","ETD_LT__c":"2016-11-29 10:30:00","Routing__c":"BKK-HKG-ICN","Departure_STN__c":"BKK","Arrival_STN__c":"HKG","STA_LT__c":"2016-11-29 14:20:00","STD_LT__c":"2016-11-29 10:30:00","STA_UTC__c":"2016-11-29 06:20:00"},{"attributes":{"type":"Flight__c","url":"/services/data/v38.0/sobjects/Flight__c/a0DN000000BrBfeMAF"},"Name":"TG628 / 29NOV16","Flight_Number__c":"TG0628","Flight_Date_UTC__c":"2016-11-29","Origin__c":"BKK","Destination__c":"ICN","Flight_External_ID__c":"TG0628_29Nov16_2","Flight_Date_LT__c":"2016-11-29","ETA_LT__c":"2016-11-29 20:02:00","ATA_LT__c":"2016-11-29 20:10:00","ATA_UTC__c":"2016-11-29 11:10:00","ATD_UTC__c":"2016-11-29 07:33:00","STD_UTC__c":"2016-11-29 07:30:00","ATD_LT__c":"2016-11-29 15:33:00","ETD_LT__c":"2016-11-29 15:30:00","Routing__c":"BKK-HKG-ICN","Departure_STN__c":"HKG","Arrival_STN__c":"ICN","STA_LT__c":"2016-11-29 20:05:00","STD_LT__c":"2016-11-29 15:30:00","STA_UTC__c":"2016-11-29 11:05:00"}]', List<Flight__c>.class);
		insert flightList;
		Apexpages.currentpage().getparameters().put('id', flightList.get(0).Id);
		FlightSummary ctrl = new FlightSummary(new ApexPages.StandardController(new Flight__c()));
	}
}