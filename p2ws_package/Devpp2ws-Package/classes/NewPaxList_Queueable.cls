public class NewPaxList_Queueable implements Queueable, Database.AllowsCallouts {
	private Flight__c eachFlight;
	private List<Passenger__c> passengers;
    private NewPaxList_Queueable nextNewPaxListQueueable;

	public NewPaxList_Queueable(Flight__c eachFlight, List<Passenger__c> passengers){
		this.eachFlight = eachFlight;
		this.passengers = passengers;
	}

    public void setNextNewPaxListQueueable(NewPaxList_Queueable nextNewPaxListQueueable) {
        this.nextNewPaxListQueueable = nextNewPaxListQueueable;
    }


	public void execute(QueueableContext context) {
		String flightDateLTFromSTDLT = eachFlight.STD_LT__c.split(' ').get(0);
        try {
            List<Map<String, String>> filterListMap = new List<Map<String, String>>();
            List<String> groupIndicator = new List<String>();
            groupIndicator.add('OFD');
            CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
            String fltNo = String.valueOf(Integer.valueOf(eachFlight.Flight_Number__c.remove('TG')));
            WS_New_Pax_List_Model newPaxListModel = ws.getPaxModel(filterListMap, groupIndicator, 'TG', fltNo, flightDateLTFromSTDLT, eachFlight.Departure_STN__c);
            Map<String, Passenger__c> updatedPaxMap = New_Pax_List_Management.updatePaxConnectingFltInfoAndTkt(passengers, eachFlight, newPaxListModel);
            upsert updatedPaxMap.values() WS_Key__c;
            AppLogger.debug('NewPaxList_Queueable', 'execute', eachFlight.Flight_External_ID__c, 'success ' + updatedPaxMap.size(), null);
        } catch (Exception e) {
            AppLogger.error('NewPaxList_Queueable', 'execute', eachFlight.Flight_External_ID__c, 'Exception: ', e);
        }

        if(nextNewPaxListQueueable != null) {
            Id jobId = System.enqueueJob(nextNewPaxListQueueable);
            if (jobId != null) {
                AppLogger.debug('NewPaxList_Queueable', 'enqueueJob next job', nextNewPaxListQueueable.eachFlight.Flight_External_Id__c, 'enqueueJob next job:' + jobId, null);
            } else {
                AppLogger.error('NewPaxList_Queueable', 'enqueueJob next job', nextNewPaxListQueueable.eachFlight.Flight_External_Id__c, 'error to enqueueJob next job', null);
            }
        } 
        AppLogger.insertLogs();
	}

	public static void execute(Flight__c eachFlight, List<Passenger__c> passengers, String jobName){
		if(passengers != null && !passengers.isEmpty()){
			NewPaxList_Queueable queueable = new NewPaxList_Queueable(eachFlight, passengers);
			Id jobId = System.enqueueJob(queueable);
			if (jobId != null) {
			    AppLogger.debug('NewPaxList_Queueable', 'enqueueJob', jobName, 'enqueueJob :' + jobId, null);
			} else {
			    AppLogger.error('NewPaxList_Queueable', 'enqueueJob', jobName, 'error to enqueueJob', null);
			}
		}
	}

    public static void execute(NewPaxList_Queueable newPaxListQueueable, String jobName) {
        Id jobId = System.enqueueJob(newPaxListQueueable);
        if (jobId != null) {
            AppLogger.debug('NewPaxList_Queueable', 'enqueueJob', jobName, 'enqueueJob :' + jobId, null);
        } else {
            AppLogger.error('NewPaxList_Queueable', 'enqueueJob', jobName, 'error to enqueueJob', null);
        }
    }
}