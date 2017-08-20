@isTest
private class FlightScheduleControllerTest {

	private static testMethod void testGetSchedule() {
        FlightScheduleController.getSchedule(6, 6, System.now(), 'BKK');
	}
	
	private static testMethod void testGetStationPickList() {
	    FlightScheduleController controller = new FlightScheduleController(new ApexPages.StandardController(new FLight__c()));
	    System.debug(controller.stationPickList);
	}

}