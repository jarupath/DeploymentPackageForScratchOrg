global with sharing class FlightScheduleController {
	public String acTypeListJSON {get; set;}
	public String acRegListJSON {get; set;}
	//global class FlightView{
	//	String name;
	//	String std;
	//	String sta;
	//	Decimal legNumber;
	//	String departureStation;
	//	String arrivalStation;
	//	Boolean departed;

	//	public FlightView(Flight__c flight){
	//		name = flight.Name;
	//		std = '' + flight.STD__c;
	//		sta = '' + flight.STA__c;
	//		legNumber = flight.Leg_Number__c;
	//		departureStation = flight.Departure_STN__c;
	//		arrivalStation = flight.Arrival_STN__c;
	//		departed = flight.Departed__c;
	//	}
	//}

	public String stationPickList {get{
			List<Aircraft_Station__mdt> stationList = [SELECT Id, Full_Name__c, Code__c FROM Aircraft_Station__mdt];
			return System.JSON.serialize(stationList);
		}
		set;
	}

	public FlightScheduleController(ApexPages.StandardController controller) {
		List<AggregateResult> acTypeAircraftList = [SELECT Aircraft_Main_Type__c FROM Aircraft__c GROUP BY Aircraft_Main_Type__c];
		List<Map<String, String>> acTypeList = new List<Map<String, String>>();
		for (AggregateResult each : acTypeAircraftList) {
			acTypeList.add(new Map<String, String> { 'id' => (String) each.get('Aircraft_Main_Type__c'), 'text' => (String) each.get('Aircraft_Main_Type__c')});
		}
		acTypeListJSON = System.JSON.serialize(acTypeList);

		List<AggregateResult> acRegAircraftList = [SELECT Aircraft_Registration__c, Aircraft_Main_Type__c FROM Aircraft__c GROUP BY Aircraft_Registration__c, Aircraft_Main_Type__c];
		List<Map<String, String>> acRegList = new List<Map<String, String>>();
		for (AggregateResult each : acRegAircraftList) {
			acRegList.add(new Map<String, String> { 'id' => (String) each.get('Aircraft_Registration__c'), 'text' => (String) each.get('Aircraft_Registration__c'), 'acType' => (String) each.get('Aircraft_Main_Type__c')});
		}
		acRegListJSON = System.JSON.serialize(acRegList);
	}

	@RemoteAction
	global static List<FlightScheduleService.FlightScheduleRecord> getSchedule(Integer startTimeOffset, Integer endTimeOffset, DateTime currentTime, String currentStation) {
		List<FlightScheduleService.FlightScheduleRecord> aircraftList = FlightScheduleService.getSchedule(startTimeOffset, endTimeOffset, currentTime, currentStation);
		return aircraftList;
	}

}