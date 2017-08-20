public with sharing class FlightService {
	public static final String CLASS_NAME = 'FlightService';
	public static String flightQuery = 'SELECT Previous_Flight_Master__c ,Previous_Flight_External_ID__c, Previous_Flight_Number__c, Previous_Flight_Date_UTC__c, Previous_Flight_Date_LT__c, Accepted_Passengers__c, AircraftId__c, Aircraft_Configuration__c, Aircraft_Type__c, Arrival_Delay_DateTime__c, Arrival_Delay__c, Arrival_STN_ICAO__c, Arrival_STN_Name__c, Arrival_STN__c, Arrival_Terminal__c, ARR_FLT_FROM_del__c, ATA_LT_DateTime__c, ATA_LT__c, ATA_UTC_DateTime__c, ATA_UTC__c, ATA__c, ATD_LT_DateTime__c, ATD_LT__c, ATD_UTC_DateTime__c, ATD_UTC__c, ATD__c, A_C_Reg__c, BAY_ARR_DEP__c, Belt__c, Block_Time_DateTime__c, Block_Time__c, Booking_Passengers__c, Case_Amount__c, Change_Flight_Date_LT__c, Change_Flight_Date_UTC__c, Change_Flight_Number__c, CreatedById, CreatedDate, Departed__c, Departure_Delay_DateTime__c, Departure_Delay__c, Departure_STN_ICAO__c, Departure_STN_Name__c, Departure_STN__c, Departure_Terminal__c, DEP_FLT_TO_del__c, Destination__c, ETA_LT_DateTime__c, ETA_LT__c, ETA_UTC_DateTime__c, ETA_UTC__c, ETA__c, ETD_LT_DateTime__c, ETD_LT__c, ETD_UTC_DateTime__c, ETD_UTC__c, ETD__c, Flight_Cancel_Flag__c, Flight_Change_Flag__c, Flight_Date_LT__c, Flight_Date_UTC__c, Flight_Date__c, Flight_External_ID__c, Flight_Master__c, Flight_Number__c, Flight_Remark__c, Flying_Time_Elapsed_Time__c, Gate__c, Id, Integration_Source__c, IsDeleted, Is_Matching_User_Preference__c, LastModifiedById, LastModifiedDate, Leg_Number__c, Name, Next_Flight_Number__c, Next_Flight_STD_LT_DateTime__c, Next_Flight_STD_LT__c, Next_Flight_STD_UTC_DateTime__c, Next_Flight_STD_UTC__c, Number_of_Cabin_Crew__c, Number_of_Cockpit_Crew__c, Number_of_Extra_Crew__c, Number_of_GE__c, Number_of_Passive_Crew__c, Origin__c, OwnerId, RecordTypeId, Sector__c, SSR_Report_Date_Arrival__c, SSR_Report_Date__c, Status_txt__c, STA_LT_DateTime__c, STA_LT__c, STA_UTC_DateTime__c, STA_UTC__c, STA__c, STD_LT_DateTime__c, STD_LT__c, STD_UTC_DateTime__c, STD_UTC_TEST_del__c, STD_UTC__c, STD__c, AircraftId__r.Aircraft_Registration__c FROM Flight__c ';

	public static List<Flight__c> createFlightsFromModel(WS_FlightModel model) {
		List<Flight__c> flightList = new List<Flight__c>();
		if (model != null && model.return_Z != null) {
			WS_FlightModel.Return_Z flightModel = model.return_Z;
			Boolean isChangedOrCanceledFlight = flightModel.flightCancelFlag != null && flightModel.flightCancelFlag == '1' || flightModel.flightChangeFlag != null && flightModel.flightChangeFlag == '1';
			//System.debug('isChangedOrCanceledFlight: ' + isChangedOrCanceledFlight);
			if (isChangedOrCanceledFlight) {
				flightList.add(createUpdatedChangedFlight(flightModel));
			} else {
				String strRouting = '';
				String strLastArrival = '';
				for (WS_FlightModel.Legdetail leg : flightModel.legdetail) {
					strRouting += leg.departureSTN + '-';
					strLastArrival = leg.arrivalSTN;
					//System.debug('leg.aircraftRegistration ' + leg.aircraftRegistration);
					Aircraft__c aircraft = null;
					if (leg.aircraftRegistration != null) {
						aircraft = new Aircraft__c(Aircraft_Registration__c = leg.aircraftRegistration);
						//System.debug('aircraft ' + aircraft);
					}
					String strFlightName = '';
					try {
						strFlightName = 'TG' + Integer.valueOf(flightModel.flightNo) + ' / ' + BE8_DateUtility.toUpperMonthValue(flightModel.flightDateLT);
						//System.debug('Debug flightName :' + strFlightName);
					} catch (Exception e) {
						System.debug('ERROR while convert flightNo to Name :' + e);
					}
					Flight__c flight = new Flight__c(
					    Flight_Cancel_Flag__c = Boolean.valueOf(flightModel.flightCancelFlag),
					    Flight_Change_Flag__c = Boolean.valueOf(flightModel.flightChangeFlag),
					    Flight_Date_LT__c = flightModel.flightDateLT,
					    Flight_Date_UTC__c = flightModel.flightDateUTC,
					    Name = flightModel.flightNo,
					    //Name = strFlightName,
					    Flight_Number__c = 'TG' + flightModel.flightNo,
					    Next_Flight_Number__c = 'TG' + flightModel.nextFlightNo,
					    Next_Flight_STD_LT__c = flightModel.nextFlightSTD_LT,
					    Next_Flight_STD_UTC__c = flightModel.nextFlightSTD_UTC,
					    Origin__c = flightModel.origin,
					    Destination__c = flightModel.destination,
					    ATA_LT__c = leg.ATA_LT,
					    ATA_UTC__c = leg.ATA_UTC,
					    ATD_LT__c = leg.ATD_LT,
					    ATD_UTC__c = leg.ATD_UTC,
					    //AircraftId__r = aircraft,
					    Aircraft_Type__c = leg.aircraftType,
					    Arrival_STN__c = leg.arrivalSTN,
					    Arrival_STN_ICAO__c = leg.arrivalSTNICAO,
					    Arrival_STN_Name__c = leg.arrivalSTNName,
					    Arrival_Terminal__c = leg.arrivalTerminal,
					    Arrival_Delay__c = leg.arrivalDelay,
					    Block_Time__c = leg.blockTime,
					    Codeshare__c = leg.codeshareInfo,
					    Departure_Delay__c = leg.departureDelay,
					    Departure_STN__c = leg.departureSTN,
					    Departure_STN_ICAO__c = leg.departureSTNICAO,
					    Departure_STN_Name__c = leg.departureSTNName,
					    Departure_Terminal__c = leg.departureTerminal,
					    ETA_LT__c = leg.ETA_LT,
					    ETA_UTC__c = leg.ETA_UTC,
					    ETD_LT__c = leg.ETD_LT,
					    ETD_UTC__c = leg.ETD_UTC,
					    Leg_Number__c = Decimal.valueOf(leg.legSeq),
					    STA_LT__c = leg.STA_LT,
					    STA_UTC__c = leg.STA_UTC,
					    STD_LT__c = leg.STD_LT,
					    STD_UTC__c = leg.STD_UTC,
					    Flight_Master__c = 'TG' + flightModel.flightNo + '_' + flightModel.flightDateUTC.toUpperCase(),
					    Flight_External_ID__c = 'TG' + flightModel.flightNo + '_' + flightModel.flightDateUTC + '_' + leg.legSeq,
					    Change_Flight_Date_LT__c = flightModel.changeFlightDateLT,
					    Change_Flight_Date_UTC__c = flightModel.changeFlightDateUTC,
					    Change_Flight_Number__c = flightModel.changeFlightNo,
					    Gate__c = leg.gate,
					    BAY_ARR_DEP__c = leg.bay
					);
					if (aircraft != null) {
						flight.AircraftId__r = aircraft;
						flight.A_C_Reg__c = aircraft.Aircraft_Registration__c;
					}

					flightList.add(flight);
				}
				strRouting += strLastArrival;
				if (flightList != null && !flightList.isEmpty()) {
					for (Flight__c f : flightList) {
						f.Routing__c = strRouting;
					}
					//System.debug('Debug Flight Routing = ' + strRouting);
				}
			}// End for (WS_FlightModel.Legdetail leg


			return flightList;
		} else {
			return null;
		}
	}

	public static List<Database.UpsertResult> upsertFlightWithAircraftByExternalId(List<Flight__c> flightList) {
		Map<String, Aircraft__c> aircraftMap = new Map<String, Aircraft__c>();
		List<Flight__c> onScheduleFlightList = new List<Flight__c>();
		List<Flight__c> changedFlightList = new List<Flight__c>();
		for (Flight__c flight : flightList) {
			if (flight.AircraftId__r != null && flight.AircraftId__r.Aircraft_Registration__c != null && flight.AircraftId__r.Aircraft_Registration__c.length() > 0) {
				//System.debug(flight.AircraftId__r.Aircraft_Registration__c.length());
				String externalId = flight.AircraftId__r.Aircraft_Registration__c;
				//System.debug('Flight :' + flight.Flight_Master__c + ' - aircraft :' + externalId);
				Aircraft__c aircraft = new Aircraft__c(Name = externalId, Aircraft_Registration__c = externalId);
				aircraftMap.put(aircraft.Aircraft_Registration__c, aircraft);
			} else {
				flight.AircraftId__c = null;
				flight.AircraftId__r = null;
			}

			if (flight.Flight_Cancel_Flag__c || flight.Flight_Change_Flag__c) {
				changedFlightList.add(flight);
			} else {
				onScheduleFlightList.add(flight);
			}
		}
		Database.UpsertResult[] aircraftUpsertResult = Database.upsert(aircraftMap.values(), Aircraft__c.Fields.Aircraft_Registration__c, false);
		//System.debug(aircraftUpsertResult);
		Database.UpsertResult[] onScheduleFlightUpsertResult = Database.upsert(onScheduleFlightList, Flight__c.Fields.Flight_External_ID__c, false);
		//System.debug(onScheduleFlightUpsertResult);
		Database.UpsertResult[] changedFlightUpsertResult = upsertChangedFlightList(changedFlightList);
		//System.debug(changedFlightUpsertResult);
		List<Database.UpsertResult> upsertResultList = new List<Database.UpsertResult>();
		upsertResultList.addAll(aircraftUpsertResult);
		upsertResultList.addAll(onScheduleFlightUpsertResult);
		upsertResultList.addAll(changedFlightUpsertResult);

		String aircraftUpsertResultErrMsg = BE8_GlobalUtility.getErrorMessage(aircraftUpsertResult);
		if(String.isNotBlank(aircraftUpsertResultErrMsg)) {
			AppLogger.error('FlightService', 'upsertFlightWithAircraftByExternalId', '', 'aircraftUpsertResult:' + aircraftUpsertResultErrMsg, null);
		}

		String onScheduleFlightUpsertResultErrMsg = BE8_GlobalUtility.getErrorMessage(onScheduleFlightUpsertResult);
		if(String.isNotBlank(onScheduleFlightUpsertResultErrMsg)) {
			AppLogger.error('FlightService', 'upsertFlightWithAircraftByExternalId', '', 'onScheduleFlightUpsertResult:'+onScheduleFlightUpsertResultErrMsg, null);
		}

		String changedFlightUpsertResultErrMsg = BE8_GlobalUtility.getErrorMessage(changedFlightUpsertResult);
		if(String.isNotBlank(changedFlightUpsertResultErrMsg)) {
			AppLogger.error('FlightService', 'upsertFlightWithAircraftByExternalId', '', 'changedFlightUpsertResult:'+changedFlightUpsertResultErrMsg, null);
		}

		return upsertResultList;
	}

	private static Database.UpsertResult[] upsertChangedFlightList(List<Flight__c> changedFlightList) {
		List<Flight__c> actualListToBeUpserted = new List<Flight__c>();
		Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', changedFlightList);
		Map<String, List<SObject>> existingFlightListMap = BE8_GlobalUtility.getSObjectListMap('Flight_Master__c', [SELECT Id, Flight_Master__c FROM Flight__c WHERE Flight_Master__c IN :flightMasterSet]);
		//System.debug('existingFlightListMap: ' + existingFlightListMap);
		for (Flight__c changedFlight : changedFlightList) {
			String flightMaster = changedFlight.Flight_Master__c;
			if (existingFlightListMap.containsKey(flightMaster)) {
				List<Flight__c> existingFlightList = (List<Flight__c>)existingFlightListMap.get(flightMaster);
				for (Flight__c existingFlight : existingFlightList) {
					Flight__c clonedFlight = changedFlight.clone(false, true, false, false);
					clonedFlight.Id = existingFlight.Id;
					actualListToBeUpserted.add(clonedFlight);
				}
			}
		}
		//System.debug('actualListToBeUpserted: ' + actualListToBeUpserted);
		return Database.upsert(actualListToBeUpserted, false);
	}

	public static Flight__c createUpdatedChangedFlight(WS_FlightModel.Return_Z flightModel) {
		Flight__c changedFlight = new Flight__c();
		changedFlight.Origin__c = flightModel.origin;
		changedFlight.Destination__c = flightModel.destination;
		changedFlight.Change_Flight_Date_LT__c = flightModel.changeFlightDateLT;
		changedFlight.Change_Flight_Date_UTC__c = flightModel.changeFlightDateUTC;
		changedFlight.Change_Flight_Number__c = flightModel.changeFlightNo;
		changedFlight.Flight_Cancel_Flag__c = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(Integer.valueOf(flightModel.flightCancelFlag));
		changedFlight.Flight_Change_Flag__c = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(Integer.valueOf(flightModel.flightChangeFlag));
		changedFlight.Flight_Date_LT__c = flightModel.flightDateLT;
		changedFlight.Flight_Date_UTC__c = flightModel.flightDateUTC;
		//changedFlight.Flight_Remark__c = flightModel.flightRemark;
		changedFlight.Flight_Number__c = 'TG' + flightModel.flightNo;
		changedFlight.Flight_Master__c = 'TG' + flightModel.flightNo + '_' + flightModel.flightDateUTC;
		return changedFlight;
	}
//public static String convertCrewListExternalIDformat(String inputString) {
//	String[] input = inputString.split('_');
//	input[0] = input[0].replace('TG', '');
//	input[1] = BE8_DateUtility.convertTGFlightDateformat(input[1], '-');
//	input[2] = String.valueOf(Integer.valueOf(input[2]));
//	return input[0] + '_' + input[1] + '_' + input[2];
//}

	public static Map<String, Aircraft__c> getExistingAircraft(List<String> aircraftRegList) {
		List<Aircraft__c> existingAircraft = [SELECT Id, Name, Aircraft_Registration__c, Aircraft_Type__c FROM Aircraft__c WHERE Aircraft_Registration__c in :aircraftRegList];
		Map<String, Aircraft__c> aircraftMap = new Map<String, Aircraft__c>();
		for (Aircraft__c aircraft : existingAircraft) {
			aircraftMap.put(aircraft.Name, aircraft);
		}
		return aircraftMap;
	}

	public static Boolean addSchedule(String jobName, DateTime targetScheduleTime, Map<String, DateTime> currentScheduleMap, Set<DateTime> scheduleDateTimeSet) {
		if (!scheduleDateTimeSet.contains(targetScheduleTime)) {
			scheduleDateTimeSet.add(targetScheduleTime);
			currentScheduleMap.put(jobName, targetScheduleTime);
			return true;
		}
		return false;
	}

	public static void schedulePreFlightBatch(Set<Id> flightIdSet) {
		List<Flight__c> flightList = [SELECT Id, Flight_Date_LT__c, STD_UTC_DateTime__c, STA_UTC_DateTime__c, ATA_UTC_DateTime__c, ATD_UTC_DateTime__c, ETD_UTC_DateTime__c, ETA_UTC_DateTime__c, Flight_External_ID__c, Flight_Number__c, Flight_Date_UTC__c, Flight_Master__c, Leg_Number__c FROM Flight__c WHERE Id IN: flightIdSet];
		Map<String, Job_Queue__c> jobQueueMap = new Map<String, Job_Queue__c>();
		Set<String> jobNameSetToAbort = new Set<String>();
		for (Flight__c flight : flightList) {
			Datetime expectDepartureDateTime = flight.STD_UTC_DateTime__c;
			if (flight.ETD_UTC_DateTime__c != null) {
				expectDepartureDateTime = flight.ETD_UTC_DateTime__c;
			}

			DateTime expectArrivalDateTime = flight.STA_UTC_DateTime__c;
			if (flight.ETA_UTC_DateTime__c != null) {
				expectArrivalDateTime = flight.ETA_UTC_DateTime__c;
			}

			DateTime actualDepartureDateTime = flight.ATD_UTC_DateTime__c;
			DateTime actualArrivalDateTime = flight.ATA_UTC_DateTime__c;
			if (expectDepartureDateTime != null && expectArrivalDateTime != null && flight.Flight_External_ID__c != null) {
				DateTime eightyHoursBeforeTakeOff = expectDepartureDateTime.addHours(-80);
				DateTime twentyfourHoursBeforeTakeOff = expectDepartureDateTime.addHours(-24);
				DateTime eightHoursBeforeTakeOff = expectDepartureDateTime.addHours(-8);
				DateTime threeHoursBeforeTakeOff = expectDepartureDateTime.addHours(-3);
				DateTime twoHoursBeforeTakeOff = expectDepartureDateTime.addHours(-2);
				DateTime oneHourBeforeTakeOff = expectDepartureDateTime.addHours(-1);
				DateTime thirtyMinsBeforeTakeOff = expectDepartureDateTime.addMinutes(-30);
				DateTime twentyfiveMinsBeforeTakeOff = expectDepartureDateTime.addMinutes(-25);
				DateTime oneHourBeforeLanding = expectArrivalDateTime.addHours(-1);
				DateTime oneHourAfterLanding = expectArrivalDateTime.addHours(1);

				Map<String, DateTime> dateTimeMap = new Map<String, DateTime>();
				Set<DateTime> scheduleDateTimeSet = new Set<DateTime>();

				addSchedule(BE8_GlobalConstants.JOB_80H_BF_TAKEOFF, eightyHoursBeforeTakeOff, dateTimeMap, scheduleDateTimeSet);
				addSchedule(BE8_GlobalConstants.JOB_24H_BF_TAKEOFF, twentyfourHoursBeforeTakeOff, dateTimeMap, scheduleDateTimeSet);
				addSchedule(BE8_GlobalConstants.JOB_8H_BF_TAKEOFF, eightHoursBeforeTakeOff, dateTimeMap, scheduleDateTimeSet);
				addSchedule(BE8_GlobalConstants.JOB_3H_BF_TAKEOFF, threeHoursBeforeTakeOff, dateTimeMap, scheduleDateTimeSet);

				Integer step = 1;
				for (DateTime scheduleTime = threeHoursBeforeTakeOff;
				        scheduleTime >= threeHoursBeforeTakeOff && scheduleTime <= oneHourBeforeTakeOff;
				        scheduleTime = scheduleTime.addMinutes(15)) {
					addSchedule(BE8_GlobalConstants.JOB_3H_1H_PERIOD_BF_TAKEOFF + '_' + step, scheduleTime, dateTimeMap, scheduleDateTimeSet);
					step++;
				}

				step = 1;
				Integer waitMinsPerJob = 15;
				Integer maxJob = 3;
				DateTime maxScheduleTime = expectDepartureDateTime.addMinutes(waitMinsPerJob * maxJob);
				//System.debug('SJ :' + BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + ' expectDepartureDateTime: '+expectDepartureDateTime + ' maxScheduleTime: '+maxScheduleTime +' actualDepartureDateTime: '+ actualDepartureDateTime);

				for (DateTime scheduleTime = oneHourBeforeTakeOff;
				        scheduleTime <= maxScheduleTime;
				        scheduleTime = scheduleTime.addMinutes(waitMinsPerJob)) {

					//System.debug('SJ :' + BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + ' scheduleTime: '+scheduleTime);
					if (actualDepartureDateTime == null
					        || (actualDepartureDateTime != null && scheduleTime <= actualDepartureDateTime)) {
						addSchedule(BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF + '_' + step, scheduleTime, dateTimeMap, scheduleDateTimeSet);
					} else {
						String jobName = getSyncFlightJobName(flight, BE8_GlobalConstants.JOB_1H_PERIOD_BF_TAKEOFF, step);
						jobNameSetToAbort.add(jobName);
					}
					step++;
				}

				//addSchedule(BE8_GlobalConstants.JOB_25M_BF_TAKEOFF, twentyfiveMinsBeforeTakeOff, dateTimeMap, scheduleDateTimeSet);

				step = 1;
				waitMinsPerJob = 20;
				maxJob = 3;
				maxScheduleTime = expectArrivalDateTime.addMinutes(waitMinsPerJob * maxJob);
				for (DateTime scheduleTime = oneHourBeforeLanding;
				        scheduleTime <= maxScheduleTime;
				        scheduleTime = scheduleTime.addMinutes(waitMinsPerJob)) {
					if (actualArrivalDateTime == null
					        || (actualArrivalDateTime != null && scheduleTime <= actualArrivalDateTime)) {
						addSchedule(BE8_GlobalConstants.JOB_1H_PERIOD_BF_LANDING + '_' + step, scheduleTime, dateTimeMap, scheduleDateTimeSet);
					} else {
						String jobName = getSyncFlightJobName(flight, BE8_GlobalConstants.JOB_1H_PERIOD_BF_LANDING, step);
						jobNameSetToAbort.add(jobName);
					}
					step++;
				}
				//addSchedule(BE8_GlobalConstants.JOB_1H_BF_LANDING, oneHourBeforeLanding, dateTimeMap, scheduleDateTimeSet);
				for (String key : dateTimeMap.keySet()) {
					DateTime dt = dateTimeMap.get(key);
					String jobName = getSyncFlightJobName(flight, key);
					if (dt >= DateTime.now()) {
						Map<String, Object> parameter = new Map<String, Object> {
							'flightNumber' => flight.Flight_Number__c,
							'flightDate' => flight.Flight_Date_UTC__c,
							'flightId' => flight.Id,
							'flightMaster' => flight.Flight_Master__c,
							'flightLeg' => Integer.valueOf(flight.Leg_Number__c)
						};
						String json = System.json.serialize(parameter);
						//String jobName = 'Flight_' + flight.Flight_External_ID__c + '_B' + batchNo;
						//batchNo++;
						Job_Queue__c jobQueue = new Job_Queue__c(Class_Name__c = 'PreFlightBatchScheduler', Schedule_Time__c = dt, Parameter__c = json, Job_Name__c = jobName, Reference_Id__c = flight.Id);
						jobQueueMap.put(jobName, jobQueue);
					} else {
						jobNameSetToAbort.add(jobName);
					}
				}
			}
		}
		List<CronTrigger> jobInSFDCQueues = [SELECT Id, State, NextFireTime, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE State = 'WAITING' AND CronJobDetail.Name IN :jobQueueMap.keySet()];

		for (CronTrigger jobInSFDCQueue : jobInSFDCQueues) {
			if (jobQueueMap.containsKey(jobInSFDCQueue.CronJobDetail.Name) && jobQueueMap.get(jobInSFDCQueue.CronJobDetail.Name) != null) {
				Job_Queue__c sameJobQueue = jobQueueMap.get(jobInSFDCQueue.CronJobDetail.Name);
				if (jobInSFDCQueue.NextFireTime != sameJobQueue.Schedule_Time__c) {
					sameJobQueue.Scheduled__c = true;
				} else {
					jobQueueMap.remove(sameJobQueue.Job_Name__c);
				}
			} else {
				String message = jobInSFDCQueue.CronJobDetail.Name + ' not found in jobQueueMap1 :' + JSON.serialize(jobQueueMap);
				AppLogger.debug('FlightService', 'schedulePreFlightBatch', jobInSFDCQueue.CronJobDetail.Name, message, null);
			}
		}
		if (!jobNameSetToAbort.isEmpty()) {
			Set<String> abortedJobs = BE8_GlobalUtility.abortScheduledJob(jobNameSetToAbort);
			if(!abortedJobs.isEmpty()) {
				AppLogger.debug('FlightService', 'abortScheduledJob', '', String.join(new List<String>(abortedJobs), ', '), null);
			}
		}

		List<Job_Queue__c> jobQueuesToDelete = new List<Job_Queue__c>();
		for (Job_Queue__c oldJobQueue : [SELECT Id, Schedule_Time__c, Job_Name__c FROM Job_Queue__c WHERE Job_Name__c IN :jobQueueMap.keySet() AND Scheduled__c = false]) {
			if (jobQueueMap.containsKey(oldJobQueue.Job_Name__c) && jobQueueMap.get(oldJobQueue.Job_Name__c) != null) {
				Job_Queue__c newJobQueue = jobQueueMap.get(oldJobQueue.Job_Name__c);
				if (newJobQueue.Schedule_Time__c != oldJobQueue.Schedule_Time__c) {
					jobQueuesToDelete.add(oldJobQueue);
				} else {
					jobQueueMap.remove(oldJobQueue.Job_Name__c);
				}
			} else {
				String message = oldJobQueue.Job_Name__c + ' not found in jobQueueMap2 : ' + JSON.serialize(jobQueueMap);
				AppLogger.debug('FlightService', 'schedulePreFlightBatch', oldJobQueue.Job_Name__c, message, null);
			}
		}
		CronTrigger_Repository.getInstance().getByName(jobQueueMap.keySet());

		Database.DeleteResult[] deleteResults = Database.delete(jobQueuesToDelete, false);
		for(Database.DeleteResult eachDeleteResult : deleteResults) {
			if(!eachDeleteResult.isSuccess()) {
				String errorMsg = '';
				for(Database.Error err : eachDeleteResult.getErrors()) {
					errorMsg += err.getStatusCode() + ': ' + err.getMessage();
				}
				AppLogger.error('FlightService', 'schedulePreFlightBatch jobQueuesToDelete', '', errorMsg, null);
			}
		}

		Database.SaveResult[] insertResults = Database.insert(jobQueueMap.values(), false);
		for(Database.SaveResult eachResult : insertResults) {
			if(!eachResult.isSuccess()) {
				String errorMsg = '';
				for(Database.Error err : eachResult.getErrors()) {
					errorMsg += err.getStatusCode() + ': ' + err.getMessage();
				}
				AppLogger.error('FlightService', 'schedulePreFlightBatch insert jobQueueMap', '', errorMsg, null);
			}
		}

		AppLogger.insertLogs();
	}

	public static Boolean isSystemIntegrationProfile() {
		String profileName = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
		//System.debug('VERIFIED USER PROFILE:-' + profileName);
		Set<String> profileSet = BE8_GlobalConstants.USER_INTEGRATION_SET;
		Boolean isProfile = false;
		if (profileSet.contains(profileName)) {
			isProfile = true;
		}
		if (profileName != null && isProfile) {
			return true;
		}
		return false;
	}

	public static void processFlightFromPreFlightBatch(Set<Id> flightIdSet, List<String> ropNumberList, Boolean isRetrialWithPreviousFlight, Boolean updateFlight, Boolean updatePassenger, Boolean updatePassengerWithNewWS, Boolean updateCrew, Boolean updateLopa, Boolean updateROP) {
		List<Flight__c> flightList = new List<Flight__c>();
		System.debug('SJ Sync |Flight :' + updateFlight + ' |Passenger :' + updatePassenger + ' |Crew :' + updateCrew + ' |Lopa :' + updateLopa + ' |ROP :' + updateROP );
		//if (updateFlight) {
		flightList = Database.query(flightQuery + ' WHERE Id IN :flightIdSet');
		//}
		try {
			List<Flight__c> flightToBeUpdated = new List<Flight__c>();
			List<Crew_List__c> crewListToBeInserted = new List<Crew_List__c>();
			List<Attachment> attachmentListToBeInserted = new List<Attachment>();
			List<Attachment> attachmentListToBeDeleted = new List<Attachment>();
			Map<String, Object> mPaxInfo = new Map<String, Object>();
			if (updateROP && !updatePassenger) {
				//System.debug('SJ Sync updateROP without Passenger');
				List<Passenger__c> passengers = [SELECT Id, AccountId__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet];
				Set<Id> accountIdSet = new Set<Id>();
				for (Passenger__c passenger : passengers) {
					accountIdSet.add(passenger.AccountId__c);
				}
				Set<String> membershipNameSet = new Set<String>();
				List<Membership__c> memberships = [SELECT Id, Name FROM Membership__c WHERE AccountId__c IN :accountIdSet];
				for (Membership__c membership : memberships) {
					membershipNameSet.add(membership.Name);
				}
				ropNumberList.addAll(membershipNameSet);
			}

			for (Flight__c flight : flightList) {
				//System.debug('Flight data :' + flight);
				//System.debug('Flight :' + flight.Flight_Number__c + ' - ' + flight.Flight_Date_UTC__c);

				if (updatePassenger) {
					//System.debug('SJ Sync updatePassenger');
					Map<String, Object> mPaxInfoEachFlight = CSE_SOAPUpdatePax_WS.updatePassengerInformation(flight, isRetrialWithPreviousFlight);
					if (mPaxInfoEachFlight != null && !mPaxInfoEachFlight.isEmpty()) {
						mPaxInfo.putAll(mPaxInfoEachFlight);
					}
				}

				//System.debug('Map info :' + mPaxInfo);
				List<Crew_List__c> crewList;
				if (updateCrew) {
					//System.debug('SJ Sync updateCrew');
					crewList = CrewOnFlightService.updateCrew(flight, isRetrialWithPreviousFlight);
				}

				Map<String, Object> lopaResultMap;
				if (updateLopa) {
					//System.debug('SJ Sync updateLopa');
					lopaResultMap = CSE_SOAPUpdateLopa_WS.updateLopaInformation(flight);
				}

				if (crewList != null) {
					crewListToBeInserted.addAll(crewList);
				}
				if (lopaResultMap != null && lopaResultMap.get('flight-aircraft') != null) {
					flightToBeUpdated.addAll((List<Flight__c>) lopaResultMap.get('flight-aircraft'));
				}
				if (lopaResultMap != null && lopaResultMap.get('attachmentList') != null) {
					Map<Id, Attachment> attachmentDeDuplicateMap = new Map<Id, Attachment>();
					for (Attachment eachAttachment : (List<Attachment>) lopaResultMap.get('attachmentList')) {
						attachmentDeDuplicateMap.put(eachAttachment.ParentId, eachAttachment);
					}
					attachmentListToBeInserted.addAll(attachmentDeDuplicateMap.values());
				}
				if (lopaResultMap != null && lopaResultMap.get('existingAttachment') != null) {
					attachmentListToBeDeleted.addAll((List<Attachment>) lopaResultMap.get('existingAttachment'));
				}
				if (mPaxInfo.containsKey('PAX-ROP') && updateROP) {
					List<String> rpl = (List<String>)mPaxInfo.get('PAX-ROP');
					ropNumberList.addAll(rpl);
				}
				if (updatePassengerWithNewWS) {
					String flightDateLTFromSTDLT = flight.STD_LT__c.split(' ').get(0);
					try {
						//System.debug('JK: before execute New Pax List');
						List<Map<String, String>> filterListMap = new List<Map<String, String>>();
						List<String> groupIndicator = new List<String>();
						groupIndicator.add('OFD');
						CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
						String fltNo = String.valueOf(Integer.valueOf(flight.Flight_Number__c.remove('TG')));
						WS_New_Pax_List_Model newPaxListModel = ws.getPaxModel(filterListMap, groupIndicator, 'TG', fltNo, flightDateLTFromSTDLT, flight.Departure_STN__c);
						//System.debug('JK: New Pax List Model');
						//System.debug(JSON.serialize(newPaxListModel));
						//System.debug('JK: after callout');
						Map<String, Passenger__c> updatedPaxMap = New_Pax_List_Management.updatePaxConnectingFltInfoAndTkt(((Map<String, Passenger__c>)mPaxInfo.get('PAX')).values(), flight, newPaxListModel);
						mPaxInfo.put('PAX', updatedPaxMap);
						//System.debug('JK: after update data');
						//System.debug(mPaxInfo.get('PAX'));

						String message = 'Callout New Pax List:' +
						                 flight.Flight_Number__c + ' - ' + flightDateLTFromSTDLT + '(LT) - ' + flight.Departure_STN__c + ' - ' + flight.Arrival_STN__c +
						                 ' :';
						AppLogger.debug('NEW_PAX_LIST', 'New Pax List Callout', flight.Flight_Number__c + '_' + flightDateLTFromSTDLT + '(LT)', message, null);

					} catch (Exception e) {
						String message = 'ERROR while call New Pax List:' +
						                 flight.Flight_Number__c + ' - ' + flightDateLTFromSTDLT + '(LT) - ' + flight.Departure_STN__c + ' - ' + flight.Arrival_STN__c +
						                 ' :' + e;
						AppLogger.error('NEW_PAX_LIST', 'New Pax List Callout', flight.Flight_Number__c + '_' + flightDateLTFromSTDLT + '(LT)', message, e);
					}
				}
			}

			if (!mPaxInfo.isEmpty()) {
				CSE_SOAPUpdatePax_WS.updatePassengerToDatabase(mPaxInfo);
			}
			List<Database.SaveResult> crewListSaveResult = Database.insert(crewListToBeInserted, false);
			List<Database.SaveResult> flightSaveResult = Database.update(flightToBeUpdated, false);
			List<Database.SaveResult> attachmentSaveResult = Database.insert(attachmentListToBeInserted, false);
			List<Database.DeleteResult> attachmentDeleteResult = Database.delete(attachmentListToBeDeleted, false);

			List<Database.SaveResult> allSaveResult = new List<Database.SaveResult>();
			allSaveResult.addAll(crewListSaveResult);
			allSaveResult.addAll(flightSaveResult);
			allSaveResult.addAll(attachmentSaveResult);

			String saveResultErrorMessage = BE8_GlobalUtility.getErrorMessage(allSaveResult);
			String deleteResultErrorMessage = BE8_GlobalUtility.getErrorMessage(attachmentDeleteResult);
			//String allErrorMessage = '' + saveResultErrorMessage + deleteResultErrorMessage;
			String allErrorMessage = '' + saveResultErrorMessage;
			if (allErrorMessage != null && allErrorMessage.length() > 0) {
				AppLogger.error('PreFlightBatch', 'execute', String.valueOf(flightIdSet), allErrorMessage, null);
				//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG, 'PreFlightBatch', 'start', String.valueOf(flightIdSet), 'Flight__c', allErrorMessage, '', null, System.currentTimeMillis());
			}
		} catch (System.Exception e) {
			AppLogger.error('PreFlightBatch', 'execute', String.valueOf(flightIdSet), e.getMessage(), e);
			//BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'PreFlightBatch', 'start', String.valueOf(flightIdSet), 'Flight__c', e.getMessage(), '', e, System.currentTimeMillis());
		}
	}

	public static void processFlightFromPreFlightBatch(Set<Id> flightIdSet, List<String> ropNumberList, Boolean isRetrialWithPreviousFlight) {
		Boolean updateFlight = true;
		Boolean updatePassenger = true;
		Boolean updatePassengerWithNewWS = false;
		Boolean updateCrew = true;
		Boolean updateLopa = true;
		Boolean updateROP = true;
		processFlightFromPreFlightBatch(flightIdSet, ropNumberList, isRetrialWithPreviousFlight, updateFlight, updatePassenger, updatePassengerWithNewWS, updateCrew, updateLopa, updateROP);
	}

	public static void executeBatchForDelayedFlight(Map<String, SObject> changedFlightMapByChangedFlightNumber) {
		if (changedFlightMapByChangedFlightNumber != null && changedFlightMapByChangedFlightNumber.size() > 0) {
			Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', changedFlightMapByChangedFlightNumber.values());
			Map<String, List<SObject>> existingFlightListMap = BE8_GlobalUtility.getSObjectListMap('Flight_Master__c', Database.query(flightQuery + ' WHERE Flight_Master__c IN :flightMasterSet'));
			//AppLogger.debug('FlightService', 'executeBatchForDelayedFlight', '', JSON.serialize(changedFlightMapByChangedFlightNumber), null);
			//AppLogger.debug('FlightService', 'flightMasterSet', '', 'flightMasterSet ' + JSON.serialize(flightMasterSet), null);
			//AppLogger.debug('FlightService', 'existingFlightListMap', '', 'existingFlightListMap ' + JSON.serialize(existingFlightListMap), null);
			for (String changedFlightNumber : changedFlightMapByChangedFlightNumber.keySet()) {
				Flight__c changedFlight = (Flight__c)changedFlightMapByChangedFlightNumber.get(changedFlightNumber);
				String flightMaster = changedFlight.Flight_Master__c;
				if (existingFlightListMap.containsKey(flightMaster)) {
					List<Flight__c> existingFlight = (List<Flight__c>) existingFlightListMap.get(flightMaster);
					if (!Test.isRunningTest()) {
						//AppLogger.debug('FlightService', 'executeBatchForDelayedFlight', '', JSON.serialize(changedFlight), null);
						Database.executeBatch(new PreFlightBatch(changedFlight.Flight_Master__c, changedFlightNumber, Date.valueOf(BE8_DateUtility.convertTGFlightDateformat(changedFlight.Change_Flight_Date_UTC__c)), 'UTC', existingFlight, false), 1);
					}
				} else {
					AppLogger.error('FlightService', 'executeBatchForDelayedFlight', '', flightMaster + ' not found', null);
				}
			}
		}
	}

	public static void executeBatchForDelayedFlightRetrial(List<Flight__c> retrialFlightList) {
		//System.debug('retrialFlightList: ' + retrialFlightList);
		Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Id', retrialFlightList);
		retrialFlightList = Database.query(flightQuery + ' WHERE Id IN : flightIdSet');
		//System.debug('retrialFlightList: ' + retrialFlightList);
		if (retrialFlightList != null && retrialFlightList.size() > 0) {
			Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Previous_Flight_Master__c', retrialFlightList);
			Map<String, List<SObject>> existingFlightListMap = BE8_GlobalUtility.getSObjectListMap('Change_Flight_Number__c', Database.query(flightQuery + ' WHERE Flight_Master__c IN :flightMasterSet'));
			for (Flight__c flight : retrialFlightList) {
				String changeFlightNumber = flight.Change_Flight_Number__c;
				if (changeFlightNumber != null && existingFlightListMap.containsKey(changeFlightNumber)) {
					List<Flight__c> existingFlight = (List<Flight__c>) existingFlightListMap.get(changeFlightNumber);
					//System.debug('existingFlight: ' + existingFlight);
					//System.debug('Flight_Number__c: ' + flight.Flight_Number__c + ' flight.Change_Flight_Date_UTC__c:' + flight.Change_Flight_Date_UTC__c);
					if (!Test.isRunningTest()) {
						Database.executeBatch(new PreFlightBatch(flight.Flight_Master__c, flight.Flight_Number__c, Date.valueOf(BE8_DateUtility.convertTGFlightDateformat(flight.Change_Flight_Date_UTC__c)), 'UTC', existingFlight, true), 1);
					}
				}
			}
		}
	}

	public static List<Flight__c> calculateFlightRegion(List<Flight__c> flightList) {
		//AppLogger.debug('FlightService', 'calculateFlightRegion', '', 'flightList: ' + JSON.serialize(flightList), null);
		Map<String, List<Flight__c>> flightMap = new Map<String, List<Flight__c>>();
		for (Flight__c each : flightList) {
			if (each.Flight_Number__c != null) {
				String flightNumberWithoutTG = each.Flight_Number__c.replace('TG', '');
				try {
					String flightNumberWithOutLeadingZero = String.valueOf(Integer.valueOf(flightNumberWithoutTG));
					String finalFlightNumber = flightNumberWithOutLeadingZero.left(3);

					List<Flight__c> tempList = flightMap.get(finalFlightNumber);
					if(tempList == null){
						tempList = new List<Flight__c>();
						flightMap.put(finalFlightNumber, tempList);
					}
					tempList.add(each);
				} catch (System.TypeException e) {
					//AppLogger.error('FlightService', 'calculateFlightRegion', each.Id, 'flightNumberWithoutTG: ' + flightNumberWithoutTG, e);
				}
			}
		}
		//System.debug(flightMap);
		List<CTI_Area_with_Sector__c> ctiAreaList = [SELECT Id, Flight_Number__c, Area__c, Region__c FROM CTI_Area_with_Sector__c WHERE Flight_Number__c IN : flightMap.keySet()];
		//System.debug(ctiAreaList);
		Map<String, SObject> ctiAreaMap = BE8_GlobalUtility.getSObjectMap('Flight_Number__c', ctiAreaList);
		//AppLogger.debug('FlightService', 'calculateFlightRegion', '', 'ctiAreaMap: ' + JSON.serialize(ctiAreaMap), null);
		for (String flightNumber : flightMap.keySet()) {
			List<Flight__c> flightListWithThisFlightNumber = flightMap.get(flightNumber);
			CTI_Area_with_Sector__c ctiArea = (CTI_Area_with_Sector__c)ctiAreaMap.get(flightNumber);
			for(Flight__c eachFlight : flightListWithThisFlightNumber){
				if (eachFlight != null && ctiArea != null) {
					eachFlight.Flight_Region__c = ctiArea.Region__c;
					eachFlight.Flight_Area__c = ctiArea.Area__c;
				}
			}
		}
		//AppLogger.debug('FlightService', 'calculateFlightRegion', '', 'flightMap.values(): ' + JSON.serialize(flightMap.values()), null);
		List<Flight__c> allFlightList = new List<Flight__c>();
		for(List<Flight__c> eachFlight : flightMap.values()){
			allFlightList.addAll(eachFlight);
		}
		return allFlightList;
	}

	public static String getFlightLocalExternalId(Flight__c flight) {
		String flightDateLocal = BE8_DateUtility.convertToTGFlightDateformat(flight.Flight_Date_LT__c, '-');
		if (!String.isBlank(flightDateLocal)) {
			return flight.Flight_Number__c + '_' + flightDateLocal + '_' + flight.Leg_Number__c;
		} else {
			throw new CustomException('Cannot convertTGFlightDateformat :' + flight.Flight_Date_LT__c);
		}
	}

	public static String getSyncFlightJobName(Flight__c flight, String templateJobName, Integer step) {
		return getSyncFlightJobName(flight, templateJobName + '_' + step);
	}

	public static String getSyncFlightJobName(Flight__c flight, String suffix) {
		return ('Flight_' + getFlightLocalExternalId(flight) + '_' + suffix).toUpperCase();
	}

	public static String generateFlightName(Flight__c flight) {
        if (flight.Name != null && !flight.Name.contains('TG')) {
            //if (flight.Flight_Date_LT__c != null) {
            //    if (!flight.Flight_Date_LT__c.contains('-')) {
            //        flight.Name = 'TG' + Integer.valueOf(flight.Name) + ' / ' + BE8_DateUtility.toUpperMonthValue(flight.Flight_Date_LT__c);
            //    } else {
            //        String  flightDateLT = BE8_DateUtility.convertDateFormatToTraditionalFormat(flight.Flight_Date_LT__c);
            //        flight.Name = 'TG' + Integer.valueOf(flight.Name) + ' / ' + BE8_DateUtility.toUpperMonthValue(flightDateLT);
            //    }
            //}
            if(flight.STD_LT_DateTime__c != null){
            	Date flightDateLocalTimeAtDepartureStation = flight.STD_LT_DateTime__c.dateGMT();
            	String flightDateLocalTimeAtDepartureStationString = String.valueOf(flightDateLocalTimeAtDepartureStation);
            	String formattedFlightDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(flightDateLocalTimeAtDepartureStationString);
            	flight.Name = 'TG' + Integer.valueOf(flight.Name) + ' / ' + formattedFlightDate;
            } else if(String.isNotBlank(flight.STD_LT__c)) {
            	List<String> flightSTDLTParts =  flight.STD_LT__c.split(' ');
            	if(!flightSTDLTParts.isEmpty()) {
            		String formattedFlightDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(flightSTDLTParts.get(0));
            		flight.Name = 'TG' + Integer.valueOf(flight.Name) + ' / ' + formattedFlightDate;
            	}
            }
        }
        return flight.Name;
	}
}