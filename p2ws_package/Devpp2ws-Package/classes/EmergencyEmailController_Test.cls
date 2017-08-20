@isTest
private class EmergencyEmailController_Test {
	@testSetup static void DataPreparation(){
		MockupData_Test.initializeSystemConfigurationCustomSetting();
	}
	
	@isTest static void testGetBodyPassenger() {

		MockupData_Test.initializeSystemConfigurationCustomSetting();

		Account a = new Account();
		a.Name = 'firstName' + ' ' + 'lastName';
    	a.First_Name__c = 'firstName';
    	a.Last_Name__c = 'lastName';
    	a.ROP_Tier__c = 'Gold';
    	insert a;

    	Account a2 = new Account();
		a2.Name = 'firstName2' + ' ' + 'lastName2';
    	a2.First_Name__c = 'firstName2';
    	a2.Last_Name__c = 'lastName2';
    	a2.ROP_Tier__c = 'Gold';
    	insert a2;
		
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Passenger__c p = new Passenger__c();
        p.SSR_Service__c = '';
        p.First_Name__c = 'firstName';
        p.Last_Name__c = 'lastName';
        p.FlightId__c = flight.Id;
        p.AccountId__c = a.Id;
        p.Class__c = 'C';
        insert p;

        Passenger__c p2 = new Passenger__c();
        p2.SSR_Service__c = '';
        p2.First_Name__c = 'firstName2';
        p2.Last_Name__c = 'lastName2';
        p2.Name = p2.First_Name__c + ' ' + p2.Last_Name__c;
        p2.FlightId__c = flight.Id;
        p2.AccountId__c = a2.Id;
        p2.Class__c = 'C';
        insert p2;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.PassengerId__c = p.Id;
	    newCase.Emergency_Type__c = BE8_GlobalConstants.EMERGENCY_TYPE_PASSENGER_DECEASE;
	    insert newCase;

	    Case_Group_Member__c cMember = new Case_Group_Member__c(Caseid__c=newCase.Id, Passengerid__c=p2.Id);
	    insert cMember;
	    
	    Test.startTest();

	    EmergencyEmailController ctrl = new EmergencyEmailController([SELECT Id, Flightid__r.ETD_LT_DateTime__c, Flightid__r.ETA_LT_DateTime__c, Flightid__r.STD_LT_DateTime__c, Flightid__r.STA_LT_DateTime__c, Emergency_Send_Email__c, Flightid__r.Name, Flightid__r.Aircraftid__r.Name, Flightid__r.STD_UTC__c, Flightid__r.ETD_UTC__c, Flightid__r.STA_UTC__c, Flightid__r.ETA_UTC__c, Flightid__r.Aircraft_Description__c, Flightid__r.Origin__c, Flightid__r.Destination__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Passengerid__r.AccountId__r.ROP_Number__c, Passengerid__r.AccountId__r.ROP_Tier__c, Passengerid__r.AccountId__r.Gender__c, Passengerid__r.AccountId__r.Nationality__c, Emergency_Type__c, Description, Reported_By_Crew__r.Name, Passengerid__r.FFP_Number__c, Passengerid__r.FFP_Tier__c, Passengerid__r.Gender__c, Passengerid__r.Nationality_Fullname__c, CrewId__c, Passengerid__r.FFP_Carrier__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Created_By_Crew__r.Name, (SELECT Id, Staff_Name__c, Staff_Personal_Number__c, Passengerid__r.FFP_Carrier__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Role__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Detail__c FROM Case_Group_Members__r) FROM Case WHERE Id = :newCase.Id limit 1]);
	    String body = ctrl.getBody();
	    Assert.assertNotEquals(null, body);
	    Assert.assert(body.contains('Flight Information'));
	    Assert.assert(body.contains('Passenger Information'));
	    Assert.assert(body.contains('firstName2'));
	    Assert.assert(body.contains('Description'));

	    Test.stopTest();
	}

	@isTest static void testGetBodyCrew() {
		
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Crew__c crew = MockupData_Test.createCrew('crewFirstName', 'crewLastName', '12345', 'FM');
	    crew.Name = 'crewFirstName crewLastName';
	    insert crew;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.CrewId__c = crew.Id;
	    newCase.Flightid__c = flight.Id;
	    newCase.Emergency_Type__c = BE8_GlobalConstants.EMERGENCY_TYPE_CREW_DECEASE;
	    insert newCase;

	    Case_Group_Member__c cMember = new Case_Group_Member__c(Caseid__c=newCase.Id, CrewId__c=crew.Id, Staff_Name__c='staffName');
	    insert cMember;
	    
	    Test.startTest();

	    EmergencyEmailController ctrl = new EmergencyEmailController([SELECT Id, Flightid__r.ETD_LT_DateTime__c, Flightid__r.ETA_LT_DateTime__c, Flightid__r.STD_LT_DateTime__c, Flightid__r.STA_LT_DateTime__c, Emergency_Send_Email__c, Flightid__r.Name, Flightid__r.Aircraftid__r.Name, Flightid__r.STD_UTC__c, Flightid__r.ETD_UTC__c, Flightid__r.STA_UTC__c, Flightid__r.ETA_UTC__c, Flightid__r.Aircraft_Description__c, Flightid__r.Origin__c, Flightid__r.Destination__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Passengerid__r.AccountId__r.ROP_Number__c, Passengerid__r.AccountId__r.ROP_Tier__c, Passengerid__r.AccountId__r.Gender__c, Passengerid__r.AccountId__r.Nationality__c, Emergency_Type__c, Description, Reported_By_Crew__r.Name, Passengerid__r.FFP_Number__c, Passengerid__r.FFP_Tier__c, Passengerid__r.Gender__c, Passengerid__r.Nationality_Fullname__c, CrewId__c, Passengerid__r.FFP_Carrier__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Created_By_Crew__r.Name, (SELECT Id, Staff_Name__c, Staff_Personal_Number__c, Passengerid__r.FFP_Carrier__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Role__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Detail__c FROM Case_Group_Members__r) FROM Case WHERE Id = :newCase.Id limit 1]);
	    String body = ctrl.getBody();
	    Assert.assertNotEquals(null, body);
	    Assert.assert(body.contains('Flight Information'));
	    Assert.assert(body.contains('Crew Information'));
	    Assert.assert(body.contains('crewFirstName'));
	    Assert.assert(body.contains('Description'));

	    Test.stopTest();
	}

	@isTest static void testGetBodySlider() {
		
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Emergency_Type__c = BE8_GlobalConstants.EMERGENCY_TYPE_SLIDER_DEPLOYMENT;
	    insert newCase;

	    Case_Group_Member__c cMember = new Case_Group_Member__c(Caseid__c=newCase.Id, Staff_Name__c='staffName');
	    insert cMember;
	    
	    Test.startTest();

	    EmergencyEmailController ctrl = new EmergencyEmailController([SELECT Id, Flightid__r.ETD_LT_DateTime__c, Flightid__r.ETA_LT_DateTime__c, Flightid__r.STD_LT_DateTime__c, Flightid__r.STA_LT_DateTime__c, Emergency_Send_Email__c, Flightid__r.Name, Flightid__r.Aircraftid__r.Name, Flightid__r.STD_UTC__c, Flightid__r.ETD_UTC__c, Flightid__r.STA_UTC__c, Flightid__r.ETA_UTC__c, Flightid__r.Aircraft_Description__c, Flightid__r.Origin__c, Flightid__r.Destination__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Passengerid__r.AccountId__r.ROP_Number__c, Passengerid__r.AccountId__r.ROP_Tier__c, Passengerid__r.AccountId__r.Gender__c, Passengerid__r.AccountId__r.Nationality__c, Emergency_Type__c, Description, Reported_By_Crew__r.Name, Passengerid__r.FFP_Number__c, Passengerid__r.FFP_Tier__c, Passengerid__r.Gender__c, Passengerid__r.Nationality_Fullname__c, CrewId__c, Passengerid__r.FFP_Carrier__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Created_By_Crew__r.Name, (SELECT Id, Staff_Name__c, Staff_Personal_Number__c, Passengerid__r.FFP_Carrier__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Role__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Detail__c FROM Case_Group_Members__r) FROM Case WHERE Id = :newCase.Id limit 1]);
	    Assert.assertNotEquals(null, ctrl.getBody());
	    Assert.assert(ctrl.getBody().contains('Flight Information'));
	    Assert.assert(ctrl.getBody().contains('staffName'));
	    Assert.assert(ctrl.getBody().contains('Description'));

	    Test.stopTest();
	}

	@isTest static void testGetBodyTurbulent() {
		
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
	    insert flight;

	    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
	    newCase.Flightid__c = flight.Id;
	    newCase.Emergency_Type__c = BE8_GlobalConstants.EMERGENCY_TYPE_SEVERE_TURBULENCE;
	    insert newCase;
	    
	    Test.startTest();

	    EmergencyEmailController ctrl = new EmergencyEmailController(newCase);
	    Assert.assertNotEquals(null, ctrl.getBody());
	    Assert.assert(ctrl.getBody().contains('Flight Information'));
	    Assert.assert(ctrl.getBody().contains('Description'));

	    Test.stopTest();
	}
	
}