global class PreFlightBatchScheduler implements Schedulable {
    private String flightNumber;
    private Date flightDate;
    private String timeMode;
    private String jobName;
    private String flightMaster;
    private Integer leg;

    public PreFlightBatchScheduler(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg) {
        this.flightNumber = flightNumber;
        this.flightDate = flightDate;
        this.timeMode = timeMode;
        this.flightMaster = flightMaster;
        this.leg = leg;
    }

    public PreFlightBatchScheduler(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        this.flightNumber = flightNumber;
        this.flightDate = flightDate;
        this.timeMode = timeMode;
        this.jobName = jobName;
        this.flightMaster = flightMaster;
        this.leg = leg;
    }

    global void execute(SchedulableContext sc) {
        BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatchScheduler', 'execute', jobName, 'Flight__c', flightMaster + ' ' + flightNumber + ' ' + flightDate + ' ' + timeMode + ' ' + leg + ' ' + jobName, '', null, System.currentTimeMillis());
         //PreFlightBatch preFlightBatch = new PreFlightBatch(flightMaster, flightNumber, flightDate, timeMode, jobName);
         //Database.executebatch(preFlightBatch, 1);
        PreFlight_Sync.AsyncPreFlight(flightMaster, flightNumber, flightDate, timeMode, leg, jobName);
    }


}