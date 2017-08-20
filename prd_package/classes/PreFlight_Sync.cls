// PER FLIGHT

public with sharing class PreFlight_Sync {
    public static final String CLASS_NAME = 'PreFlight_Sync';

    public static void AsyncPreFlight(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        //PreFlight_Sync.FutureSync(flightMaster, flightNumber, flightDate, timeMode, jobName);
        PreFlight_Sync.QueueableSync(flightMaster, flightNumber, flightDate, timeMode, leg, jobName);
    }

    public static void QueueableSync(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        try {
            Id jobId = System.enqueueJob(new PreFlight_Queueable(flightMaster, flightNumber, flightDate, timeMode, leg, jobName));
            if (jobId != null) {
                AppLogger.debug('PreFlight_Sync', 'QueueableSync', jobName, 'enqueueJob :' + jobId, null);
            } else {
                AppLogger.error('PreFlight_Sync', 'QueueableSync', jobName, 'error to enqueueJob', null);
            }
        } catch (Exception e) {
            AppLogger.error('PreFlight_Sync', 'QueueableSync', jobName, 'exception', e);
        }
        AppLogger.insertLogs();
    }

    @future(callout = true)
    public static void FutureSync(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        Integer noFutureJob = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Future' AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')];
        if (noFutureJob < 40) {
            Performance_Debugger debugger = new Performance_Debugger();
            debugger.start();
            PreFlight_Sync preFlightSync = new PreFlight_Sync(flightMaster, flightNumber, flightDate, timeMode, leg, jobName);
            preFlightSync.sync();
            debugger.stop();
            AppLogger.debug('PreFlight_Sync', 'FutureSync', jobName, 'timeTaken=[' + debugger.getMessage() + ']', null);
        } else {
            AppLogger.debug('PreFlight_Sync', 'FutureSync', jobName, 'nealry exceeded the maximum number (40/50) of Apex future jobs.', null);
            System.enqueueJob(new PreFlight_Queueable(flightMaster, flightNumber, flightDate, timeMode, leg, jobName));
            //PreFlightBatch preFlightBatch = new PreFlightBatch(flightMaster, flightNumber, flightDate, 'UTC', jobName);
            //Database.executebatch(preFlightBatch, 1);
        }
        AppLogger.insertLogs();
    }

    private String flightMaster;
    private String flightNumber;
    private Date flightDate;
    private String timeMode;
    private String jobName;
    private Integer leg;
    private Boolean isRetrialWithPreviousFlight = false;

    public Boolean updatePassengerWithNewWS = false;
    public Boolean updateFlight = true;
    public Boolean updatePassenger = true;
    public Boolean updateCrew = true;
    public Boolean updateLopa = true;
    public Boolean updateROP = true;
    public Boolean createChatterGroup = false;

    //public static List<Application_Log__c> applicationLogCache = new List<Application_Log__c>();

    private List<Flight__c> existFlights;
    private List<Flight__c> flights;
    //private List<Passenger__c> existPassengers;
    //private List<Membership__c> existMemberships;
    private List<String> ropNumberList = new List<String>();

    //private Map<Id, Boolean> isChangedACRegMapByFlightId = new Map<Id, Boolean>();
    private Map<String, SObject> changedFlightMapByChangedFlightNumber;

    public PreFlight_Sync(String flightMaster, String flightNumber, Date flightDate, String timeMode, Integer leg, String jobName) {
        AppLogger.setReferenceId(jobName);
        //abortJob(jobName);

        this.flightMaster = flightMaster;
        this.flightNumber = flightNumber;
        this.flightDate = flightDate;
        this.timeMode = timeMode;
        this.jobName = jobName;
        this.leg = leg;
        setupWhichObjectToUpdate(this.jobName);
    }

    public void abortJob(String thisJobName) {
        if (thisJobName != null && thisJobName.length() > 0) {
            try {
                Boolean hasAbort = BE8_GlobalUtility.abortScheduledJob(thisJobName);
                if (hasAbort) {
                    AppLogger.debug('PreFlight_Sync', 'abortScheduledJob', thisJobName, 'abortScheduledJob : ' + thisJobName, null);
                } else {
                    AppLogger.error('PreFlight_Sync', 'abortScheduledJob', thisJobName, 'Cannot abortScheduledJob : ' + thisJobName, null);
                }
            } catch (Exception e) {
                AppLogger.error('PreFlight_Sync', 'abortScheduledJob', thisJobName, 'Cannot abortScheduledJob : ' + thisJobName, e);
            }
        }
    }

    public void sync() {
        Performance_Debugger debugger = new Performance_Debugger();
        try {
            debugger.start();
            queryData();
            debugger.stop();
            AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'queryData: ' + debugger.getMessage(), null);
            syncData();

            Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Id', flights);
            AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateROP=[' + updateROP + ']~ropNumberList=[' + ropNumberList.size() + ']', null);
            if (!Test.isRunningTest() && !flightIdSet.isEmpty() && updateROP && !ropNumberList.isEmpty()) {
                Database.executeBatch(new CSE_ROPCalloutBatch(flightIdSet), BE8_GlobalConstants.MAX_ROP_CALLOUT);
            }
        } catch (Exception e) {
            AppLogger.error('PreFlight_Sync', 'sync', jobName, 'sync Exception', e);
        }

        try {
            if (!String.isBlank(this.jobName)) {
                if (createChatterGroup) {
                    createChatterGroup(flights);
                    AppLogger.debug('FlightChatterGroupHandler', 'createChatterGroupByFlights', this.jobName, 'success', null);
                }
            }
        } catch (Exception e) {
            AppLogger.error('FlightChatterGroupHandler', 'createChatterGroupByFlights', this.jobName, '', e);
        }

        try {
            postSync();
            AppLogger.debug('PreFlight_Sync', 'postSync', jobName, 'success', null);
        } catch (Exception e) {
            AppLogger.error('PreFlight_Sync', 'postSync', jobName, 'postSync Exception', e);
        }
        AppLogger.insertLogs();
    }

    public void createChatterGroup(List<Flight__c> flights) {
        FlightChatterGroupHandler.createChatterGroupByFlights(flights);
    }

    public void queryData() {
        if (!String.isBlank(this.flightMaster)) {
            existFlights = Database.query(FlightService.flightQuery + ' WHERE Flight_Master__c = : flightMaster');
            if (updateROP && !updatePassenger) {
                List<Passenger__c> existPassengers = [SELECT Id, AccountId__c FROM Passenger__c WHERE FlightId__r.Flight_Master__c = :flightMaster];
                Set<Id> accountIdSet = BE8_GlobalUtility.getIdSet('AccountId__c', existPassengers);
                List<Membership__c> existMemberships = [SELECT Id, Name FROM Membership__c WHERE AccountId__c IN :accountIdSet];
                Set<String> membershipNameSet = BE8_GlobalUtility.getStringSet('Name', existMemberships);
                ropNumberList.addAll(membershipNameSet);
            }
        }
    }

    public void syncData() {
        Performance_Debugger debugger = new Performance_Debugger();
        if (updateFlight) {
            debugger.start();
            flights = retrieveFlight();
            debugger.stop();
            AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'retrieveFlight: ' + debugger.getMessage(), null);
            if (flights != null && existFlights != null) {
                processFlightData(existFlights, flights);
            }
        } else {
            flights = existFlights;
        }

        for (Flight__c eachFlight : flights) {
            eachFlight.Flight_Date_UTC__c = BE8_DateUtility.convertTGFlightDateformat(eachFlight.Flight_Date_UTC__c);
            eachFlight.Flight_Date_LT__c = BE8_DateUtility.convertTGFlightDateformat(eachFlight.Flight_Date_LT__c);
            eachFlight.STD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.STD_UTC__c);
            eachFlight.STD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.STD_LT__c);
            eachFlight.STA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.STA_UTC__c);
            eachFlight.STA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.STA_LT__c);
            eachFlight.ETD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ETD_UTC__c);
            eachFlight.ETD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ETD_LT__c);
            eachFlight.ETA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ETA_UTC__c);
            eachFlight.ETA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ETA_LT__c);
            eachFlight.ATD_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ATD_UTC__c);
            eachFlight.ATD_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ATD_LT__c);
            eachFlight.ATA_UTC__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ATA_UTC__c);
            eachFlight.ATA_LT__c = BE8_DateUtility.convertTGFlightDateTimeformat(eachFlight.ATA_LT__c);
            eachFlight.Last_Sync_Time__c = System.now();
            eachFlight.Last_Sync_Job_Name__C = jobName;
            FlightService.generateFlightName(eachFlight);
        }

        Map<String, Object> mPaxInfo;
        List<Crew_List__c> crewLists = new List<Crew_List__c>();
        Map<String, Map<String, TG_LOPA_Req.GetSeatMapRes>> lopaMapByFlightExternalId = new Map<String, Map<String, TG_LOPA_Req.GetSeatMapRes>>();

        List<NewPaxList_Queueable> newPaxListQueueables = new List<NewPaxList_Queueable>();

        NewPaxList_Queueable previousNewPaxListQueueable;
        NewPaxList_Queueable firstNewPaxListQueueable;

        for (Flight__c eachFlight : flights) {
            Integer legOfEachFlight = Integer.valueOf(eachFlight.Leg_Number__c);
            //if(legOfEachFlight != this.leg) {
            //    if(this.leg == null) {
            //        AppLogger.error('PreFlight_Sync', 'syncData', jobName, 'this.leg equals to null', null);
            //        this.leg = 1;
            //    }

            //    if(legOfEachFlight == this.leg + 1) {
            //        String newJobName = jobName + '_' + legOfEachFlight;
            //        AppLogger.debug('PreFlight_Sync', 'new AsyncPreFlight', newJobName, newJobName, null);
            //        PreFlight_Sync.AsyncPreFlight(this.flightMaster, this.flightNumber, this.flightDate, this.timeMode, legOfEachFlight, newJobName);
            //    } 
            //    continue;
            //}
            
            if (updateCrew) {
                debugger.start();
                try {
                    crewLists.addAll(CrewOnFlightService.updateCrew(eachFlight, isRetrialWithPreviousFlight));
                    debugger.stop();
                    AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateCrew: success ' + debugger.getMessage(), null);
                } catch (Exception e) {
                    debugger.stop();
                    AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateCrew: failed ' + debugger.getMessage(), e);
                }
            }

            if (updateLopa) {
                debugger.start();
                try {
                    Map<String, TG_LOPA_Req.GetSeatMapRes> lopaMap = CSE_SOAPUpdateLopa_WS.retrieveLopaMap(eachFlight);
                    lopaMapByFlightExternalId.put(eachFlight.Flight_External_ID__c, lopaMap);
                    debugger.stop();
                    AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateLopa: success lopaMapSize: ' + lopaMap.size() + ' ' + debugger.getMessage(), null);
                } catch (Exception e) {
                    debugger.stop();
                    AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateLopa: failed ' + debugger.getMessage(), e);
                }
            }

            if (updatePassenger) {
                //Map<String, Object> mPaxInfoEachFlight = CSE_SOAPUpdatePax_WS.updatePassengerInformation(eachFlight, isRetrialWithPreviousFlight);
                if(mPaxInfo == null || mPaxInfo.isEmpty()) {
                    debugger.start();
                    mPaxInfo = CSE_SOAPUpdatePax_WS.updatePassengerInformation(eachFlight, isRetrialWithPreviousFlight);
                    debugger.stop();
                    AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updatePassengerInformation: ' + debugger.getMessage() + ' '+ mPaxInfo.size(), null);


                    if (mPaxInfo.containsKey('PAX-ROP') && updateROP) {
                        List<String> rpl = (List<String>)mPaxInfo.get('PAX-ROP');
                        ropNumberList.addAll(rpl);
                    }
                }

                if (updatePassengerWithNewWS && mPaxInfo != null && !mPaxInfo.isEmpty()) {
                    List<Passenger__c> passengers = ((Map<String, Passenger__c>)mPaxInfo.get('PAX')).values();
                    passengers.addAll((List<Passenger__c>)mPaxInfo.get('PAX-CLONE'));
                    AppLogger.debug('PreFlight_Sync', 'sync_ReviseNewPaxQueueable', jobName, passengers.size() +'', null);

                    if(passengers != null && !passengers.isEmpty()) {
                        NewPaxList_Queueable eachNewPaxListQueueable = new NewPaxList_Queueable(eachFlight, passengers);
                        
                        if(firstNewPaxListQueueable == null) {
                            firstNewPaxListQueueable = eachNewPaxListQueueable;
                        } else if(previousNewPaxListQueueable != null) {
                            previousNewPaxListQueueable.setNextNewPaxListQueueable(eachNewPaxListQueueable);
                        }
                        previousNewPaxListQueueable = eachNewPaxListQueueable;
                    }
                }
            }
        }

        try {
            if(firstNewPaxListQueueable != null) {
                NewPaxList_Queueable.execute(firstNewPaxListQueueable, jobName);
            }
        } catch (Exception e) {
            AppLogger.error('PreFlight_Sync', 'syncData', jobName, 'NewPaxList_Queueable.execute : failed', e);
        }

        debugger.start();
        try {
            updateDataToDB(mPaxInfo, crewLists, lopaMapByFlightExternalId);
            debugger.stop();
            AppLogger.debug('PreFlight_Sync', 'sync', jobName, 'updateDataToDB: success ' + debugger.getMessage(), null);
        } catch (Exception e) {
            AppLogger.error('PreFlight_Sync', 'sync', jobName, 'updateDataToDB: failed ' + debugger.getMessage(), e);
        }
    }

    public void updateDataToDB(Map<String, Object> mPaxInfo, List<Crew_List__c> crewListsForInsert, Map<String, Map<String, TG_LOPA_Req.GetSeatMapRes>> lopaMapByFlightExternalId) {
        List<Database.UpsertResult> flightUpsertResultList = FlightService.upsertFlightWithAircraftByExternalId(flights);
        String errorMessage = BE8_GlobalUtility.getErrorMessage(flightUpsertResultList);
        if (errorMessage != null && errorMessage.length() > 0) {
            AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'PreFlight_Sync', 'updateDataToDB', jobName, 'Job Name', errorMessage, '', null, System.currentTimeMillis());
        }

        if (mPaxInfo != null && !mPaxInfo.isEmpty()) {
            try {
                CSE_SOAPUpdatePax_WS.updatePassengerToDatabase(mPaxInfo);
                AppLogger.debug('PreFlight_Sync', 'updateDataToDB', jobName, 'updatePassengerToDB success', null);
            } catch (Exception e) {
                AppLogger.debug('PreFlight_Sync', 'updateDataToDB', jobName, 'updatePassengerToDB failed', e);
            }
        }

        try {
            List<Attachment> attachmentsForInsert = new List<Attachment>();
            Set<String> acRegSet = BE8_GlobalUtility.getStringSet('A_C_Reg__c', flights);
            Map<String, SObject> aircraftMapByACReg = BE8_GlobalUtility.getSObjectMap('Aircraft_Registration__c', [SELECT Id, Aircraft_Registration__c FROM Aircraft__c WHERE Aircraft_Registration__c IN :acRegSet]);
            for (Flight__c eachFlight : flights) {
                if (lopaMapByFlightExternalId.containsKey(eachFlight.Flight_External_ID__c)) {
                    if (aircraftMapByACReg.containsKey(eachFlight.A_C_Reg__c)) {
                        eachFlight.AircraftId__c = aircraftMapByACReg.get(eachFlight.A_C_Reg__c).Id;
                    }
                    attachmentsForInsert.addAll(CSE_SOAPUpdateLopa_WS.createLopaAttachment(eachFlight, lopaMapByFlightExternalId.get(eachFlight.Flight_External_ID__c)));
                }
            }

            String allErrorMessage = '';
            Set<Id> flightIds = BE8_GlobalUtility.getIdSet('Id', flights);
            Set<Id> parentIds = new Set<Id>();
            parentIds.addAll(flightIds);
            parentIds.addAll(BE8_GlobalUtility.getIdSet('AircraftId__c', flights));
            if (updateLopa) {
                if (!attachmentsForInsert.isEmpty()) {
                    List<Attachment> attachmentsForDeleted = [SELECT Id FROM Attachment WHERE ParentId IN :parentIds AND Name LIKE '%LOPA.txt'];
                    List<Database.DeleteResult> attachmentDeleteResult = Database.delete(attachmentsForDeleted, false);
                    String deleteResultErrorMessage = BE8_GlobalUtility.getErrorMessage(attachmentDeleteResult);
                    allErrorMessage += deleteResultErrorMessage;
                }
            }
            List<Database.SaveResult> crewListSaveResult = Database.insert(crewListsForInsert, false);

            Set<String> keyAttachment = new Set<String>();
            for (Integer index = 0; index < attachmentsForInsert.size(); index++) {
                Attachment eachAttachment = attachmentsForInsert.get(index);
                String key = eachAttachment.Name + eachAttachment.ParentId;
                if (keyAttachment.contains(key)) {
                    attachmentsForInsert.remove(index);
                } else {
                    keyAttachment.add(key);
                }
            }

            List<Database.SaveResult> attachmentSaveResult = Database.insert(attachmentsForInsert, false);

            List<Database.SaveResult> allSaveResult = new List<Database.SaveResult>();
            allSaveResult.addAll(crewListSaveResult);
            allSaveResult.addAll(attachmentSaveResult);

            String saveResultErrorMessage = BE8_GlobalUtility.getErrorMessage(allSaveResult);
            allErrorMessage += saveResultErrorMessage;
            if (allErrorMessage != null && allErrorMessage.length() > 0) {
                //BE8_GlobalUtility.cacheLogMessage('PreFlight_Sync', 'updateDataToDB', BE8_GlobalConstants.LEVEL_ERROR, allErrorMessage, flightNumber + flightDate, PreFlightBatch.applicationLogCache);
                AppLogger.error('PreFlight_Sync', 'updateDataToDB', jobName, allErrorMessage, null);
            } else {
                AppLogger.debug('PreFlight_Sync', 'updateDataToDB', jobName, 'updateLopaToDB success', null);
            }
        } catch (Exception e) {
            AppLogger.debug('PreFlight_Sync', 'updateDataToDB', jobName, 'updateLopaToDB failed\n' + e.getMessage() + '\n' + e.getStackTraceString(), e);
        }
    }

    public List<Crew_List__c> retrieveCrew(List<Flight__c> flights) {
        List<Crew_List__c> crewLists = new List<Crew_List__c>();
        for (Flight__c eachFlight : flights) {
            List<Crew_List__c> retrievedCrewLists = CrewOnFlightService.updateCrew(eachFlight, isRetrialWithPreviousFlight);
            if (retrievedCrewLists != null && !retrievedCrewLists.isEmpty()) {
                crewLists.addAll(retrievedCrewLists);
            }
        }
        return crewLists;
    }

    public Map<String, Object> retrievePassenger(List<Flight__c> flights) {
        Map<String, Object> mPaxInfo = new Map<String, Object>();
        for (Flight__c eachFlight : flights) {
            Map<String, Object> mPaxInfoEachFlight = CSE_SOAPUpdatePax_WS.updatePassengerInformation(eachFlight, isRetrialWithPreviousFlight);
            if (mPaxInfoEachFlight != null && !mPaxInfoEachFlight.isEmpty()) {
                mPaxInfo.putAll(mPaxInfoEachFlight);
            }
        }
        return mPaxInfo;
    }

    public void processFlightData(List<Flight__c> existFlights, List<Flight__c> flights) {
        Boolean isJobThatMustSyncLOPA = this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3');
        if (!String.isBlank(this.jobName)
                && (this.jobName.contains(BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF)
                    || this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF))
                && !isJobThatMustSyncLOPA) {
            for (Flight__c flight : flights) {
                for (Flight__c existFlight : existFlights) {
                    if (existFlight.Flight_Master__c == flight.Flight_Master__c
                            && existFlight.Leg_Number__c == flight.Leg_Number__c) {
                        if (existFlight.A_C_Reg__c != flight.A_C_Reg__c) {
                            updateLopa = true;
                        } else {
                            updateLopa = false;
                        }
                    }
                }
            }
        }
    }

    public List<Flight__c> retrieveFlight() {
        String errorMessage = '';
        try {
            WS_FlightModel flightResponse = new CSE_SOAPFLIGHT_WS().getFlight(flightNumber, flightDate, timeMode);
            List<Flight__c> thisFlightList = FlightService.createFlightsFromModel(flightResponse);
            List<Flight__c> changedFlightList = new List<Flight__c>();
            for (Flight__c flight : thisFlightList) {
                if (flight.Flight_Change_Flag__c) {
                    changedFlightList.add(flight);
                }
            }

            changedFlightMapByChangedFlightNumber = BE8_GlobalUtility.getSObjectMap('Change_Flight_Number__c', changedFlightList);
            //List<Database.UpsertResult> upsertResultList = FlightService.upsertFlightWithAircraftByExternalId(thisFlightList);
            //String errorMessage = BE8_GlobalUtility.getErrorMessage(upsertResultList);
            //if (errorMessage != null && errorMessage.length() > 0) {
            //  BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'PreFlightBatch', 'syncFlight', flightNumber + flightDate, 'Flight__c', errorMessage, 'Fail when upserting flight', null, System.currentTimeMillis());
            //}
            //BE8_GlobalUtility.cacheLogMessage('PreFlight_Sync', 'retrieveFlight', BE8_GlobalConstants.LEVEL_DEBUG, 'success', flightNumber + flightDate, PreFlightBatch.applicationLogCache);
            AppLogger.debug('PreFlight_Sync', 'retrieveFlight', jobName, 'success', null);
            return thisFlightList;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            AppLogger.error('PreFlight_Sync', 'retrieveFlight', jobName, e.getMessage(), e);
            errorMessage = e.getMessage();
        }

        if (String.isBlank(errorMessage)) {
            errorMessage = 'Cannot sync flight';
        }
        Monitoring.notifyError('Sync Flight Error :' + jobName, errorMessage, 'SYNC_FLIGHT');

        return new List<Flight__c>();
    }

    public void postSync() {
        //insert applicationLogCache;
        AppLogger.debug('PreFlight_Sync', 'changedFlightMapByChangedFlightNumber', jobName, JSON.serialize(changedFlightMapByChangedFlightNumber), null);
        FlightService.executeBatchForDelayedFlight(changedFlightMapByChangedFlightNumber);
        JobQueueService.deleteOutdatedScheduledJob();
        JobQueueService.enqueueJob();
        deleteOutdatedScheduledJobCronTrigger();
    }

    public void deleteOutdatedScheduledJobCronTrigger() {
        Integer remainDMLStatement =  Limits.getLimitDMLStatements() - Limits.getDMLStatements() - 10;
        if (remainDMLStatement > 0) {
            String queryStr = 'SELECT Id, CronJobDetail.Name FROM CronTrigger WHERE State = \'DELETED\' AND StartTime < YESTERDAY ORDER BY StartTime LIMIT ' +  remainDMLStatement;
            List<CronTrigger> jobList = Database.query(queryStr);
            List<String> jobNames = new List<String>();
            for (CronTrigger job : jobList) {
                if (job != null && job.Id != null) {
                    System.abortJob(job.Id);
                    jobNames.add(job.CronJobDetail.Name);
                }
            }

            if (!jobNames.isEmpty()) {
                AppLogger.debug('PreFlight_Sync', 'abortScheduledJob', jobName, 'deleteOutdatedScheduledJobCronTrigger ' + String.join(jobNames, ','), null);
            }
        }
    }

    public void setupWhichObjectToUpdate(String thisJobName) {
        if (!String.isBlank(thisJobName)) {
            if (thisJobName.contains(BE8_GlobalConstants.JOB_80H_BF_TAKEOFF)) {
                updateFlight = false;
                updateCrew = false;
                //updateLopa = false;
                updateROP = false;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_24H_BF_TAKEOFF)) {
                updateLopa = false;
                updateROP = false;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_8H_BF_TAKEOFF)) {
                updateROP = false;
                updateLopa = false;
                createChatterGroup = true;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_3H_BF_TAKEOFF)) {
                //updatePassengerWithNewWS = true;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF)) {
                //updatePassengerWithNewWS = true;
                updateLopa = false;
                updateROP = false;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3')) {
                updatePassengerWithNewWS = true;
                updateLopa = true;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF)) {
                updatePassengerWithNewWS = true;
                updateLopa = false;
                updateROP = false;
            } else if (thisJobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_LANDING)) {
                updatePassenger = false;
                updateCrew = false;
                updateLopa = false;
                updateROP = false;
            } else if (thisJobName.contains(BE8_GlobalConstants.MANUAL_JOB)) {
                updatePassengerWithNewWS = true;
                createChatterGroup = true;
            }
        }
        String logMessage = 'jobName = [' + thisJobName + ']~';
        logMessage += 'updateFlight = [' + updateFlight + ']~';
        logMessage += 'updatePassenger = [' + updatePassenger + ']~';
        logMessage += 'updateCrew = [' + updateCrew + ']~';
        logMessage += 'updateLopa = [' + updateLopa + ']~';
        logMessage += 'updateROP = [' + updateROP + ']~';
        System.debug(logMessage);
        //BE8_GlobalUtility.cacheLogMessage('PreFlight_Sync', 'setupWhichObjectToUpdate', BE8_GlobalConstants.LEVEL_DEBUG, logMessage, jobName, PreFlightBatch.applicationLogCache);
        //AppLogger.add(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, Long timeTaken)

    }
}