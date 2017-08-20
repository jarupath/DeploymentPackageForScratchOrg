/*------------------------------------------------------------
Author:			Nutchanon Phongoen
Company:		Beryl8
Description:	This batch makes callouts to Flight, Passenger, LOPA and Crew Web Service to consolidate the data of flights
				The batch is scheduled by another schedulerใ
Test Class:		PreFlightBatchTest
History
<Date>          <Authors Name>                <Brief Description of Change>
2016-12-02     Nutchanon Phongoen	          Officially documented the class

------------------------------------------------------------*/
global class PreFlightBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	private String flightMaster;
	private String flightNumber;
	private Date flightDate;
	private String timeMode;
	private String jobName;
	private Map<String, Account> duplicatedAccountMap;
	private List<String> ropNumberList;
	private Map<String, SObject> changedFlightMapByChangedFlightNumber;
	private List<Flight__c> retrialFlightList;
	private Boolean isRetrialWithPreviousFlight;
	private Map<Id, Boolean> isChangedACRegMapByFlightId = new Map<Id, Boolean>();
	private Map<String, SObject> previousFlightMapByLegNumber;
	//public static List<Application_Log__c> applicationLogCache = new List<Application_Log__c>();
	public static List<Flight__c> retrialFlightListCache = new List<Flight__c>();
	private Boolean updateFlight = true;
	private Boolean updatePassenger = true;
	private Boolean updatePassengerWithNewWS = false;
	private Boolean updateCrew = true;
	private Boolean updateLopa = true;
	private Boolean updateROP = true;
	private Set<Id> flightIdSet = new Set<Id>();

	/*
		Example :
		Database.executeBatch(new PreFlightBatch('0600', BE8_DateUtility.toDate('YYYY-MM-DD', '2016-11-12'), 'UTC'), 1);
		Database.executeBatch(new PreFlightBatch('1234', Date.today(),'UTC'), 1);
	*/
	global PreFlightBatch(String flightMaster, String flightNumber, Date flightDate, String timeMode) {
		this.flightMaster = flightMaster;
		this.flightNumber = flightNumber;
		this.flightDate = flightDate;
		this.timeMode = timeMode;
		duplicatedAccountMap = new Map<String, Account>();
		ropNumberList = new List<String>();
		changedFlightMapByChangedFlightNumber = new Map<String, SObject>();
		retrialFlightList = new List<Flight__c>();
		isRetrialWithPreviousFlight = false;
	}

	global PreFlightBatch(String flightMaster, String flightNumber, Date flightDate, String timeMode, String jobName) {
		this(flightMaster, flightNumber, flightDate, timeMode);
		this.jobName = jobName;

		if (!String.isBlank(this.jobName)) {
			if (this.jobName.contains(BE8_GlobalConstants.JOB_80H_BF_TAKEOFF)) {
				updateFlight = false;
				updateCrew = false;
				updateLopa = false;
				updateROP = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_24H_BF_TAKEOFF)) {
				updateLopa = false;
				updateROP = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_8H_BF_TAKEOFF)) {
				updateROP = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_3H_BF_TAKEOFF)) {
				//updatePassengerWithNewWS = true;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF)) {
				//updatePassengerWithNewWS = true;
				updateLopa = false;
				updateROP = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_3')) {
				updatePassengerWithNewWS = true;
				updateLopa = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF)) {
				updatePassengerWithNewWS = true;
				updateLopa = false;
				updateROP = false;
			} else if (this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_LANDING)) {
				updatePassenger = false;
				updateCrew = false;
				updateLopa = false;
				updateROP = false;
			}
		}
	}

	global PreFlightBatch(String flightMaster, String flightNumber, Date flightDate, String timeMode, List<SObject> previousFlightList, Boolean isRetrialWithPreviousFlight) {
		this(flightMaster, flightNumber, flightDate, timeMode);
		if (previousFlightList != null) {
			this.previousFlightMapByLegNumber = BE8_GlobalUtility.getSObjectMap('Leg_Number__c', previousFlightList);
		}
		this.isRetrialWithPreviousFlight = isRetrialWithPreviousFlight;
	}

	//global PreFlightBatch(String flightNumber, Date flightDate, String timeMode, Boolean isRetrialWithPreviousFlight) {
	//	this(flightNumber, flightDate, timeMode);
	//	this.isRetrialWithPreviousFlight = isRetrialWithPreviousFlight;
	//}

	global List<sObject> start(Database.BatchableContext BC) {
		List<Flight__c> flightList = new List<Flight__c>();
		//Flight__c currentFlight = [SELECT Id, A_C_Reg__c FROM Flight__c WHERE Id = :this.flightId];
		List<Flight__c> existFlightList = Database.query(FlightService.flightQuery + ' WHERE Flight_Master__c != null AND Flight_Master__c = :flightMaster');

		if (updateFlight) {
			try {
				WS_FlightModel flightResponse = new CSE_SOAPFLIGHT_WS().getFlight(flightNumber, flightDate, timeMode);
				flightList = FlightService.createFlightsFromModel(flightResponse);
				System.debug('Flight list :' + flightList);

				// Handle Changed Flight
				List<Flight__c> changedFlightList = new List<Flight__c>();
				for (Flight__c flight : flightList) {
                	flight.Last_Sync_Time__c = System.now();
                	flight.Last_Sync_Job_Name__c = jobName + ' (PreFlightBatch)';
					Boolean isChangedFlight = flight.Flight_Change_Flag__c;
					if (isChangedFlight) {
						changedFlightList.add(flight);
					}

					System.debug('SJ Sync flight :' + flight.Leg_Number__c + ' ' + flight.A_C_Reg__c + ' ' + flight.Flight_Master__c + ' ' +  flight.Id + ' ' + flight.AircraftId__c);

					for (Flight__c existFlight : existFlightList) {
						System.debug('SJ Sync existFlight :' + existFlight.Leg_Number__c + ' ' + existFlight.A_C_Reg__c + ' ' + existFlight.Flight_Master__c + ' ' +  existFlight.Id + ' ' + existFlight.AircraftId__c);
						if (existFlight.Flight_Master__c == flight.Flight_Master__c
						        && existFlight.Leg_Number__c == flight.Leg_Number__c) {
							if (existFlight.A_C_Reg__c != flight.A_C_Reg__c) {
								isChangedACRegMapByFlightId.put(existFlight.Id, true);
							} else {
								isChangedACRegMapByFlightId.put(existFlight.Id, false);
							}
						}
					}
				}
				changedFlightMapByChangedFlightNumber = BE8_GlobalUtility.getSObjectMap('Change_Flight_Number__c', changedFlightList);
				System.debug('changedFlightMapByChangedFlightNumber: ' + changedFlightMapByChangedFlightNumber);


				if (previousFlightMapByLegNumber != null && previousFlightMapByLegNumber.size() > 0) {
					System.debug('previousFlightMapByLegNumber: ' + previousFlightMapByLegNumber);
					if (!isRetrialWithPreviousFlight) {
						// Handle New Flight from Delay
						for (Flight__c newFlight : flightList) {
							if (newFlight.Leg_Number__c != null && previousFlightMapByLegNumber.containsKey(String.valueOf(newFlight.Leg_Number__c))) {
								Flight__c previousFlight = (Flight__c) previousFlightMapByLegNumber.get(String.valueOf(newFlight.Leg_Number__c));
								System.debug('previousFlight: ' + previousFlight);
								System.debug('newFlight: ' + newFlight);
								//newFlight.Name = previousFlight.Name;
								newFlight.Flight_External_ID__c = previousFlight.Flight_External_ID__c;
								newFlight.Flight_Master__c = previousFlight.Flight_Master__c;
								newFlight.Flight_Number__c = flightNumber;
								newFlight.Previous_Flight_Number__c = previousFlight.Flight_Number__c;
								newFlight.Previous_Flight_Date_LT__c = previousFlight.Flight_Date_LT__c;
								newFlight.Previous_Flight_Date_UTC__c = previousFlight.Flight_Date_UTC__c;
								newFlight.Previous_Flight_External_ID__c = previousFlight.Flight_External_ID__c;
								newFlight.Previous_Flight_Master__c = previousFlight.Flight_Master__c;
								newFlight.Flight_Change_Flag__c = previousFlight.Flight_Change_Flag__c;
								newFlight.Change_Flight_Number__c = previousFlight.Change_Flight_Number__c;
								newFlight.Change_Flight_Date_LT__c = previousFlight.Change_Flight_Date_LT__c;
								newFlight.Change_Flight_Date_UTC__c = previousFlight.Change_Flight_Date_UTC__c;
							} else {
								AppLogger.error('PreFlightBatch', 'start', jobName, 'During the callout for new flight from delay, the new flight has no leg number.\n' + newFlight + '\n' + flightMaster, null);
								//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatch', 'start', jobName, 'Flight__c', 'During the callout for new flight from delay, the new flight has no leg number.\n' + newFlight + '\n' + flightMaster, '', null, System.currentTimeMillis());
							}
						}
					} else if (isRetrialWithPreviousFlight) {
						// Revert Name and Flight Number from TG9109 back to TG910
						System.debug('flightList: ' + flightList);
						for (Flight__c flight : flightList) {
							if (flight.Leg_Number__c != null && previousFlightMapByLegNumber.containsKey(String.valueOf(flight.Leg_Number__c))) {
								Flight__c previousFlight = (Flight__c) previousFlightMapByLegNumber.get(String.valueOf(flight.Leg_Number__c));
								System.debug('previousFlight: ' + previousFlight);
								flight.Name = previousFlight.Previous_Flight_Number__c.replace(BE8_GlobalConstants.DEFAULT_TG_COMPANY, '');
								flight.Flight_Number__c = previousFlight.Previous_Flight_Number__c;
								flight.Flight_Date_LT__c = previousFlight.Previous_Flight_Date_LT__c;
								flight.Flight_Date_UTC__c = previousFlight.Previous_Flight_Date_UTC__c;
								flight.Flight_External_ID__c = previousFlight.Previous_Flight_External_ID__c;
								flight.Flight_Master__c = previousFlight.Previous_Flight_Master__c;
								flight.Flight_Change_Flag__c = previousFlight.Flight_Change_Flag__c;
								flight.Change_Flight_Number__c = previousFlight.Change_Flight_Number__c;
								flight.Change_Flight_Date_LT__c = previousFlight.Change_Flight_Date_LT__c;
								flight.Change_Flight_Date_UTC__c = previousFlight.Change_Flight_Date_UTC__c;
							} else {
								AppLogger.error('PreFlightBatch', 'start', jobName, 'During the callout for new flight from delay, the new flight has no leg number.\n' + flight + '\n' + flightMaster, null);
								//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatch', 'start', jobName, 'Flight__c', 'During the callout for new flight from delay, the new flight has no leg number.\n' + flight + '\n' + flightMaster, '', null, System.currentTimeMillis());
							}
						}
					}
				}

				// Upsert the flight information from TG Backend (TOP which uses UTC time mode)
				System.debug('Flight List to be Upserted: ' + flightList);
				List<Database.UpsertResult> upsertResultList = FlightService.upsertFlightWithAircraftByExternalId(flightList);
				flightIdSet = BE8_GlobalUtility.getIdSet('Id', flightList);
				System.debug('Upsert flight during start: ' + upsertResultList);
				String errorMessage = BE8_GlobalUtility.getErrorMessage(upsertResultList);
				if (errorMessage != null && errorMessage.length() > 0) {
					AppLogger.error('PreFlightBatch', 'start', jobName, 'Fail when upserting flight ' + flightMaster + '\n' + errorMessage, null);
					//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatch', 'start', jobName, 'Flight__c', errorMessage, 'Fail when upserting flight ' + flightMaster, null, System.currentTimeMillis());
				}

			} catch (System.Exception e) {
				System.debug('ERROR while upsertFlightWithAircraftByExternalId :' + e);
				AppLogger.error('PreFlightBatch', 'start', jobName, e.getMessage() + '\nFlight List: ' + flightList, e);
				//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'PreFlightBatch', 'start', jobName, flightMaster + ' Flight__c', e.getMessage() + '\nFlight List: ' + flightList, '', e, System.currentTimeMillis());
			}
			System.debug('flightList: ' + flightList);
			Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', flightList);
			flightList = Database.query(FlightService.flightQuery + ' WHERE Flight_Master__c IN :flightMasterSet');
			System.debug('flightList: ' + flightList);
		} else {
			//flightList = Database.query(FlightService.flightQuery + ' WHERE Flight_Master__c = :flightMaster');
			flightList = existFlightList;
		}
		AppLogger.debug('PreFlightBatch', 'start', jobName, '' + flightMaster + ' ' + flightNumber + ' ' + jobName, null);
		//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatch', 'start', jobName, 'Flight__c', '' + flightMaster + ' ' + flightNumber + ' ' + jobName, '', null, System.currentTimeMillis());
		Applogger.insertLogs();
		return flightList;
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if (!String.isBlank(this.jobName)) {
			AppLogger.setReferenceId(this.jobName);
		} else {
			AppLogger.setReferenceId(flightNumber + '_' + flightDate);
		}
		Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Id', scope);
		Boolean isChangeACReg = false;
		for (Id flightId : flightIdSet) {
			if (!String.isBlank(this.jobName)) {
				if (isChangedACRegMapByFlightId.containsKey(flightId) && isChangedACRegMapByFlightId.get(flightId)) {
					isChangeACReg = true;
					if (this.jobName.contains(BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF)) {
						updateLopa = isChangeACReg;
					} else if (this.jobName.contains(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF)) {
						updateLopa = isChangeACReg;
					}
				}
			}
		}

		if (!Test.isRunningTest()) {
			Performance_Debugger debugger = new Performance_Debugger();
			debugger.start();
			FlightService.processFlightFromPreFlightBatch(flightIdSet, ropNumberList, isRetrialWithPreviousFlight, updateFlight, updatePassenger, updatePassengerWithNewWS, updateCrew, updateLopa, updateROP);
			debugger.stop();
			AppLogger.debug('PreFlightBatch', 'processFlightFromPreFlightBatch', flightMaster + '_' + flightDate, debugger.getMessage(), null);
		}

		if (!String.isBlank(this.jobName)) {
			if (this.jobName.contains(BE8_GlobalConstants.JOB_8H_BF_TAKEOFF)) {
				System.debug('SJ :start create Chatter Group');
				try {
					FlightChatterGroupHandler.createChatterGroupByFlights(scope);
					AppLogger.debug('FlightChatterGroupHandler', 'createChatterGroupByFlights', this.jobName, 'success', null);
				} catch (Exception e) {
					AppLogger.error('FlightChatterGroupHandler', 'createChatterGroupByFlights', this.jobName, '', e);
				}
			}
		}

		// This is a retrial cache to store the changed flight that failed from retrieving passenger.
		// This is necessary due to the fact that rapid callout to TG Backed would produce error.
		// Therefore, the retrial callout must be in a separated transaction which will be execute during finish().
		retrialFlightList = retrialFlightListCache;
		AppLogger.insertLogs();
	}

	global void finish(Database.BatchableContext BC) {
		if (String.isBlank(this.jobName)) {
			AppLogger.setReferenceId(this.jobName);
		}
		System.debug('PreFlightBatch finish');

		// This is the ROP callout batch to retrieve the information of each passenger with ROP.
		// It has to be a batch to avoid the Governor Limits of Salesforce.
		if (!Test.isRunningTest() && flightIdSet != null && flightIdSet.size() > 0) {
			Database.executeBatch(new CSE_ROPCalloutBatch(flightIdSet), BE8_GlobalConstants.MAX_ROP_CALLOUT);
		}

		// This is the Account merge batch to resolve issue when two Account records with the same External Id occurred.
		// This means that there is a duplication of Account records, these two records must be merged.
		// For now, the functionality is disabled due to the face that it might invoke complex and unpredictable behavior.
		//if(!duplicatedAccountMap.isEmpty()){
		//	Database.executeBatch(new AccountMergerBatch(duplicatedAccountMap));
		//}

		// This function will abort the Scheduled Job that is the originator of this batch.
		// It must be done to avoid Ghost Job bug in Salesforce.
		if (jobName != null && jobName.length() > 0) {
			Boolean hasAbort = BE8_GlobalUtility.abortScheduledJob(jobName);
			if (hasAbort) {
				AppLogger.debug('PreFlightBatch', 'abortScheduledJob', jobName, 'abortScheduledJob : ' + jobName, null);
			} else {
				AppLogger.error('PreFlightBatch', 'abortScheduledJob', jobName, 'Cannot abortScheduledJob : ' + jobName, null);
			}
		}

		// This is the execution of PreFlightBatch for the delayed flight that should be labeled as TG9109 e.g.
		// If this batch succeeded, there would be no retrial. Therefore, the logic will assume that TG9109
		// is the flight that is going to board. While if this batch failed, the logic would assume that the previous
		// flight which is TG910 is the one that is going to board. Hence, another retrial batch will be
		// fired to use TG910 instead of TG9109.
		System.debug('changedFlightMapByChangedFlightNumber: ' + changedFlightMapByChangedFlightNumber);
		FlightService.executeBatchForDelayedFlight(changedFlightMapByChangedFlightNumber);

		// This is the execution of PreFlightBatch as a retrial for the failed delayed flight (TG9109 e.g.).
		// With this method, the delayed flight (TG9109) will be changed to the previous flight (TG910).
		System.debug('retrialFlightList: ' + retrialFlightList);
		System.debug('retrialFlightListCache: ' + retrialFlightListCache);
		FlightService.executeBatchForDelayedFlightRetrial(retrialFlightList);

		JobQueueService.deleteOutdatedScheduledJob();
		JobQueueService.enqueueJob();
		AppLogger.insertLogs();
	}

}