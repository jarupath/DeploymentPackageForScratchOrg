@isTest
private class FlightScheduleServiceTest {

    @isTest static void testGetSchedulePositiveWithArrivingFlight() {
        TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);

        Aircraft__c aircraft1 = MockupData_Test.createAircraft('HS-TUA', 'HS-TUA', '787');
        insert aircraft1;

        List<Flight__c> flightList = new List<Flight__c>();

        Flight__c flight1 = MockupData_Test.createFlight('123', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 07:00:00';
        flight1.STA_UTC__c = '2017-01-09 10:00:00';
        flight1.Departure_STN__c = 'HKG';
        flight1.Arrival_STN__c = 'BKK';
        flight1.AircraftId__c = aircraft1.Id;
        flightList.add(flight1);

        Flight__c flight2 = MockupData_Test.createFlight('124', '2017-01-09', 1);
        flight2.STD_UTC__c = '2017-01-09 12:00:00';
        flight2.STA_UTC__c = '2017-01-09 18:00:00';
        flight2.Departure_STN__c = 'BKK';
        flight2.Arrival_STN__c = 'HKG';
        flight2.AircraftId__c = aircraft1.Id;
        flightList.add(flight2);

        Flight__c flight3 = MockupData_Test.createFlight('125', '2017-01-08', 1);
        flight3.STD_UTC__c = '2017-01-08 12:00:00';
        flight3.STA_UTC__c = '2017-01-08 18:00:00';
        flight3.Departure_STN__c = 'BKK';
        flight3.Arrival_STN__c = 'HKG';
        flight3.AircraftId__c = aircraft1.Id;
        flightList.add(flight3);

        Flight__c flight4 = MockupData_Test.createFlight('126', '2017-01-09', 1);
        flight4.STD_UTC__c = '2017-01-09 13:00:00';
        flight4.STA_UTC__c = '2017-01-09 20:00:00';
        flight4.Departure_STN__c = 'BKK';
        flight4.Arrival_STN__c = 'HKG';
        flight4.AircraftId__c = aircraft1.Id;
        flightList.add(flight4);

        insert flightList;

        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.newInstanceGmt(2017, 1, 9, 11, 0, 0), 'BKK');

        Assert.assertEquals(2, resultList.size());
        Assert.assertEquals('TG123 HKG', resultList[0].arrFlightFrom);
        Assert.assertEquals('TG124 HKG', resultList[0].depFlightTo);
    }

    @isTest static void testGetSchedulePositiveWithDepartingFlightAndTwoAircraft() {
        TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);

        Aircraft__c aircraft1 = MockupData_Test.createAircraft('HS-TUA', 'HS-TUA', '787');
        insert aircraft1;
        Aircraft__c aircraft2 = MockupData_Test.createAircraft('HS-TUB', 'HS-TUB', '787');
        insert aircraft2;

        List<Flight__c> flightList = new List<Flight__c>();

        Flight__c flight1 = MockupData_Test.createFlight('123', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 02:00:00';
        flight1.STA_UTC__c = '2017-01-09 05:00:00';
        flight1.Departure_STN__c = 'HKG';
        flight1.Arrival_STN__c = 'BKK';
        flight1.AircraftId__c = aircraft1.Id;
        flightList.add(flight1);

        Flight__c flight2 = MockupData_Test.createFlight('124', '2017-01-09', 1);
        flight2.STD_UTC__c = '2017-01-09 10:00:00';
        flight2.STA_UTC__c = '2017-01-09 18:00:00';
        flight2.Departure_STN__c = 'BKK';
        flight2.Arrival_STN__c = 'HKG';
        flight2.AircraftId__c = aircraft1.Id;
        flightList.add(flight2);

        Flight__c flight3 = MockupData_Test.createFlight('201', '2017-01-09', 1);
        flight3.STD_UTC__c = '2017-01-09 11:00:00';
        flight3.STA_UTC__c = '2017-01-09 13:00:00';
        flight3.Departure_STN__c = 'BKK';
        flight3.Arrival_STN__c = 'ICN';
        flight3.AircraftId__c = aircraft2.Id;
        flightList.add(flight3);

        Flight__c flight4 = MockupData_Test.createFlight('202', '2017-01-09', 1);
        flight4.STD_UTC__c = '2017-01-09 13:00:00';
        flight4.STA_UTC__c = '2017-01-09 20:00:00';
        flight4.Departure_STN__c = 'ICN';
        flight4.Arrival_STN__c = 'BKK';
        flight4.AircraftId__c = aircraft2.Id;
        flightList.add(flight4);

        Flight__c flight5 = MockupData_Test.createFlight('200', '2017-01-09', 1);
        flight5.STD_UTC__c = '2017-01-09 01:00:00';
        flight5.STA_UTC__c = '2017-01-09 04:00:00';
        flight5.Departure_STN__c = 'ICN';
        flight5.Arrival_STN__c = 'BKK';
        flight5.AircraftId__c = aircraft2.Id;
        flightList.add(flight5);

        insert flightList;

        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.newInstanceGmt(2017, 1, 9, 11, 0, 0), 'BKK');

        Assert.assertEquals(2, resultList.size());
        Assert.assertEquals('TG123 HKG', resultList[0].arrFlightFrom);
        Assert.assertEquals('TG124 HKG', resultList[0].depFlightTo);
        Assert.assertEquals('TG200 ICN', resultList[1].arrFlightFrom);
        Assert.assertEquals('TG201 ICN', resultList[1].depFlightTo);
    }

    @isTest static void testGetScheduleWithFlightAlreadyDepartedRecently() {
        TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);

        Aircraft__c aircraft1 = MockupData_Test.createAircraft('HS-TBG', 'HS-TBG', '787');
        insert aircraft1;

        List<Flight__c> flightList = new List<Flight__c>();

        Flight__c flight1 = MockupData_Test.createFlight('TG638', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 07:00:00';
        flight1.STA_UTC__c = '2017-01-09 09:45:00';
        flight1.Departure_STN__c = 'BKK';
        flight1.Arrival_STN__c = 'HKG';
        flight1.AircraftId__c = aircraft1.Id;
        flightList.add(flight1);

        Flight__c flight2 = MockupData_Test.createFlight('TG639', '2017-01-09', 1);
        flight2.STD_UTC__c = '2017-01-09 10:55:00';
        flight2.STA_UTC__c = '2017-01-09 13:40:00';
        flight2.Departure_STN__c = 'HKG';
        flight2.Arrival_STN__c = 'BKK';
        flight2.AircraftId__c = aircraft1.Id;
        flightList.add(flight2);

        Flight__c flight3 = MockupData_Test.createFlight('TG307', '2017-01-09', 1);
        flight3.STD_UTC__c = '2017-01-09 15:15:00';
        flight3.STA_UTC__c = '2017-01-09 18:40:00';
        flight3.Departure_STN__c = 'BKK';
        flight3.Arrival_STN__c = 'CMB';
        flight3.AircraftId__c = aircraft1.Id;
        flightList.add(flight3);

        insert flightList;

        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.newInstanceGmt(2017, 1, 9, 16, 30, 0), 'BKK');

        Assert.assertEquals(1, resultList.size());
        Assert.assertEquals('TG639 HKG', resultList[0].arrFlightFrom);
        Assert.assertEquals('TG307 CMB', resultList[0].depFlightTo);
    }

    @isTest static void testGetScheduleWithoutFlightInSystemShouldReturnEmptyList() {
        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.now(), 'BKK');
        Assert.assertEquals(0, resultList.size(), 'The result should be an empty list, because there is no flight in the system.');
    }

    @isTest static void testGetScheduleShouldReturnEmptyList() {
        List<Flight__c> flightList = new List<Flight__c>();

        Flight__c flight1 = MockupData_Test.createFlight('123', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 10:00:00';
        flightList.add(flight1);

        Flight__c flight2 = MockupData_Test.createFlight('124', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 12:00:00';
        flightList.add(flight2);

        Flight__c flight3 = MockupData_Test.createFlight('125', '2017-01-08', 1);
        flight1.STD_UTC__c = '2017-01-08 12:00:00';
        flightList.add(flight3);

        insert flightList;

        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.newInstanceGmt(2017, 2, 7, 11, 0, 0), 'BKK');
        Assert.assertEquals(0, resultList.size(), 'The result should be an empty list, because there is no flight that is in the range of time to be retrieved.');
    }

    @isTest static void testGetScheduleWithNullShouldThrowException() {
        Boolean isError = false;
        try {
            List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, null, 'BKK');
        } catch (CustomException e) {
            isError = true;
        }
        Assert.assert(isError, 'If the input DateTime is null, an exception is thrown.');
    }

    @isTest static void testGetScheduleShouldReturnArrAndDepBAY(){
        TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);

        Aircraft__c aircraft1 = MockupData_Test.createAircraft('HS-TUA', 'HS-TUA', '787');
        insert aircraft1;

        List<Flight__c> flightList = new List<Flight__c>();

        Flight__c flight1 = MockupData_Test.createFlight('123', '2017-01-09', 1);
        flight1.STD_UTC__c = '2017-01-09 07:00:00';
        flight1.STA_UTC__c = '2017-01-09 10:00:00';
        flight1.Departure_STN__c = 'HKG';
        flight1.Arrival_STN__c = 'BKK';
        flight1.AircraftId__c = aircraft1.Id;
        flight1.BAY_ARR_DEP__c = 'C7';
        flightList.add(flight1);

        Flight__c flight2 = MockupData_Test.createFlight('124', '2017-01-09', 1);
        flight2.STD_UTC__c = '2017-01-09 12:00:00';
        flight2.STA_UTC__c = '2017-01-09 18:00:00';
        flight2.Departure_STN__c = 'BKK';
        flight2.Arrival_STN__c = 'HKG';
        flight2.AircraftId__c = aircraft1.Id;
        flight2.BAY_ARR_DEP__c = 'B9';
        flightList.add(flight2);

        insert flightList;

        List<FlightScheduleService.FlightScheduleRecord> resultList = FlightScheduleService.getSchedule(2, 6, DateTime.newInstanceGmt(2017, 1, 9, 11, 0, 0), 'BKK');

        Assert.assertEquals(1, resultList.size());
        Assert.assertEquals('C7/B9', resultList[0].bayArrDep);
    }
}