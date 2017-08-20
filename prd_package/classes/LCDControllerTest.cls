@isTest
private class LCDControllerTest {
	@testSetup static void DataPreparation(){

		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
		
	}
	
	@isTest static void testController() {
		Id maintenanceCaseRecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.PASSENGER_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.COMPENSATION_TRIGGER, false);
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;
		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'F');
		insert passenger;
		Case testCase = new Case(Passengerid__c = passenger.Id, Flightid__c = flight.Id, RecordTypeId = maintenanceCaseRecordTypeId);
		insert testCase;
		Compensation__c compensation = new Compensation__c(Total__c = 0, CaseId__c = testCase.Id);
		insert compensation;
		//Case currentCase = [SELECT Id, Passengerid__r.Name, Flightid__r.Flight_Date_LT__c, Flightid__r.Name, Flightid__r.Origin__c, Flightid__r.Destination__c, Case_Number_Custom_F__c, Passenger_Ticket_Number__c, Baggage_Check_Number__c, Excess_Bag_Ticket_Number__c, Account_Debited__c, LCD_Detail__c, (SELECT Id, Total_THB__c FROM Compensations__r WHERE Total_THB__c != null and Status__c = 'Approved') FROM Case WHERE Id =: stdController.getId() LIMIT 1];
		Apexpages.currentpage().getparameters().put('id', testCase.Id);
		LCDController ctrl = new LCDController(new ApexPages.StandardController(testCase));
	}
	
}