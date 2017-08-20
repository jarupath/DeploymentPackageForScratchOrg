public with sharing class PreFlight_Queueable implements Queueable, Database.AllowsCallouts {
    public String flightMaster;
    public String flightNumber;
    public Date flightDate;
    public String timeMode;
    public Integer leg;
    public String jobName;
    public String suffixJobName;
    public List<Flight__c> flights;

    //public PreFlight_Queueable(List<Flight__c> flights, String suffixJobName) {
    //    Flight__c flight = flights.get(0);
    //    this.suffixJobName = suffixJobName;
    //    this.flightMaster = flight.Flight_Master__c;
    //    this.flightNumber = flight.Flight_Number__c;
    //    this.flightDate = Date.valueOf(flight.Flight_Date_UTC__c);
    //    this.timeMode = 'UTC';
    //    this.leg = Integer.valueOf(flight.Leg_Number__c);
    //    this.jobName = 'FLIGHT_' + flight.Flight_External_ID__c  + '_' + this.suffixJobName;
    //    flights.remove(0);
    //    this.flights = flights;
    //}

    public PreFlight_Queueable(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        this.flightMaster = flightMaster;
        this.flightNumber = flightNumber;
        this.flightDate = flightDate;
        this.timeMode = timeMode;
        this.jobName = jobName;
        this.leg = leg;
    }

    public void execute(QueueableContext context) {
        try {
            PreFlight_Sync preFlightSync = new PreFlight_Sync(this.flightMaster, this.flightNumber, this.flightDate, this.timeMode, this.leg, this.jobName);
            preFlightSync.sync();
        } catch(Exception e) {
            AppLogger.error('PreFlight_Queueable', 'execute', jobName, 'exception', e);
        }

        //try {
        //    if(this.flights != null && !this.flights.isEmpty()) {
        //        Id jobId = System.enqueueJob(new PreFlight_Queueable(this.flights, this.suffixJobName));
        //        if(jobId != null) {
        //            AppLogger.debug('PreFlight_Queueable', 'next execute', jobName, 'enqueueJob :' + jobId, null);
        //        } else {
        //            AppLogger.error('PreFlight_Queueable', 'next execute', jobName, 'error to enqueueJob', null);
        //        }    
        //    }
            
        //} catch (Exception e) {
        //    AppLogger.error('PreFlight_Queueable', 'next execute', jobName, 'exception', e);
        //}

        AppLogger.insertLogs();
    }
}