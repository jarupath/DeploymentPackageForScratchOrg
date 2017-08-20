/*
	This queable class is used to handle dcs pax callout from preflight_sync
*/
public class DCS_Pax_Queueable implements Queueable, Database.AllowsCallouts {
	private String carrier;
	private String fltNo;
	private String fltDate;
	private String boardPoint;
	private String jobName;
	private List<Map<String, String>> filterListMap;
	private List<String> groupIndicator;
	private Flight__c flight;
	private Boolean isPSTCall;
	private DCS_Pax_Queueable nextDCSPaxQueueable;

	public DCS_Pax_Queueable(Flight__c flight, List<Map<String, String>> filterListMap, List<String> groupIndicator, String jobName){
		this.flight = flight;
		this.filterListMap = filterListMap;
		this.groupIndicator = groupIndicator;
		this.flight = flight;
		this.isPSTCall = false;
		this.jobName = jobName;
	}

	public void setNextDCSPaxQueueable(DCS_Pax_Queueable dcsPaxQueable){
		nextDCSPaxQueueable = dcsPaxQueable;
	}

	public DCS_Pax_Queueable(Flight__c flight, List<Map<String, String>> filterListMap, List<String> groupIndicator, Boolean isPSTCall, String jobName){
		this.flight = flight;
		this.filterListMap = filterListMap;
		this.groupIndicator = groupIndicator;
		this.flight = flight;
		this.isPSTCall = isPSTCall;
		this.jobName = jobName;
	}

	public DCS_Pax_Queueable(){}

	public void execute(QueueableContext context) {
		System.debug('FLIGHT: ' + flight.Flight_External_ID__c);
		if(flight != null){
			DCS_Pax_Management.syncDCS(flight, filterListMap, groupIndicator, isPSTCall, jobName);
			if(nextDCSPaxQueueable != null){
				System.enqueueJob(nextDCSPaxQueueable);
			}
		}
	}

	public static void execute(Flight__c flight, List<Map<String, String>> filterListMap, List<String> groupIndicator, String jobName){
		System.enqueueJob(new DCS_Pax_Queueable(flight, filterListMap, groupIndicator, jobName));
	}
}