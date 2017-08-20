trigger JobQueueTrigger on Job_Queue__c (before insert, before update) {

	Boolean isActive = Trigger_Activation__c.getInstance().Job_Queue_Trigger__c;
	if (isActive) {
		if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
			Integer numberOfJobInSFDCQueue = Database.countQuery('SELECT COUNT() FROM CronTrigger WHERE State = \'WAITING\'');
			List<JobQueueService.JobQueueWrapper> jobToBeScheduledList = new List<JobQueueService.JobQueueWrapper>();
			Set<String> jobNameSet = new Set<String>();

			for (Job_Queue__c job : Trigger.new) {
				Job_Queue__c previousState = Trigger.isInsert ? null : Trigger.oldMap.get(job.Id);
				Boolean isSetToSchedule = job.Scheduled__c && (Trigger.isInsert || !previousState.Scheduled__c);
				Boolean isManualRun = job.Manual_Run__c;
				if (isSetToSchedule || isManualRun) {
					jobToBeScheduledList.add(new JobQueueService.JobQueueWrapper(job));
					jobNameSet.add(job.Job_Name__c);
				}
			}

			jobToBeScheduledList.sort();
			System.debug('jobToBeScheduledList ' + jobToBeScheduledList);
			Set<String> abortedJobs = BE8_GlobalUtility.abortScheduledJob(jobNameSet);

			List<String> abortScheduleLogs = new List<String>();
			for (String abortedJob : abortedJobs) {
				abortScheduleLogs.add('abort ' + abortedJob);
			}

			if (!abortScheduleLogs.isEmpty()) {
				List<Config_Parameter__mdt> configParams = [SELECT DeveloperName, Value__c FROM Config_Parameter__mdt WHERE DeveloperName = 'jobQueueToScheduleLog'];
				if (!configParams.isEmpty()) {
					if (configParams.get(0).Value__c == 'file') {
						List<Application_Log__c> logs = [SELECT Id FROM Application_Log__c WHERE Source_Function__c = 'JobQueueToScheduleLog_Attachment'];
						Application_Log__c log;
						if (logs.isEmpty()) {
							log = new Application_Log__c();
							log.Source__c = 'JobQueueToScheduleLog_Attachment';
							log.Source_Function__c = 'JobQueueToScheduleLog_Attachment';
							insert log;
						} else {
							log = logs.get(0);
						}

						Attachment attachment = new Attachment();
						attachment.Body = Blob.valueOf(String.join(abortScheduleLogs, '\n'));
						attachment.Name = String.valueOf(System.now()) + '.txt';
						attachment.ParentId = log.Id;
						insert attachment;
					} else if (configParams.get(0).Value__c == 'record') {
						List<Application_Log__c> logsForInsert = new List<Application_Log__c>();
						for (String abortScheduleLog : abortScheduleLogs ) {
							Application_Log__c log = new Application_Log__c();
							log.Source__c = 'JobQueueToScheduleLog';
							log.Source_Function__c = 'AbortScheduleLog';
							log.Message__c = abortScheduleLog;
							logsForInsert.add(log);
						}
						insert logsForInsert;
					}
				}
			}

			System.debug('jobNameSet ' + jobNameSet);

			List<String> jobQueueToScheduleLogs = new List<String>();

			Boolean thereIsAvailableSpaceInJobQueue = true;
			for (JobQueueService.JobQueueWrapper wrapper : jobToBeScheduledList) {
				Job_Queue__c job = wrapper.job;
				System.debug(job.Schedule_Time__c);
				if (job.Class_Name__c == 'PreFlightBatchScheduler') {
					Map<String, Object> parameter = (Map<String, Object>) System.JSON.deserializeUntyped(job.Parameter__c);
					String flightNumber = String.valueOf(parameter.get('flightNumber'));
					Date flightDate = Date.valueOf(String.valueOf(parameter.get('flightDate')));
					Id flightId = (Id)parameter.get('flightId');
					String flightMaster = String.valueOf(parameter.get('flightMaster'));
					Integer flightLeg = Integer.valueOf(parameter.get('flightLeg'));

					//System.debug('-----------DEBUG SESSION IN JOB QUEUE TRIGGER------------');
					//System.debug('input flight date value: ' + parameter.get('flightDate'));
					//System.debug('converted flight date value: ' + flightDate);
					//System.debug('input flight number value: ' + parameter.get(flightNumber));
					//System.debug('Job Name: ' + job.Job_Name__c);

					String jobName = job.Job_Name__c;

					String cron = BE8_DateUtility.getExactCRONFromDateTime(job.Schedule_Time__c);
					//System.debug('cron ' + cron);
					PreFlightBatchScheduler schedulable = new PreFlightBatchScheduler(flightMaster, flightNumber, flightDate, 'UTC', flightLeg, jobName);

					job.Result__c = 'Successfully Scheduled';

					Boolean isManualRun = job.Manual_Run__c;
					Boolean scheduleTimeIsInThePast = job.Schedule_Time__c < DateTime.now();
					if (thereIsAvailableSpaceInJobQueue) {
						thereIsAvailableSpaceInJobQueue = numberOfJobInSFDCQueue < BE8_GlobalConstants.JOB_QUEUE_LIMIT;
					}
					try {
						if (isManualRun || (scheduleTimeIsInThePast && thereIsAvailableSpaceInJobQueue) ) {
							String nowCRON = BE8_DateUtility.getExactCRONFromDateTime(DateTime.now().addMinutes(1));
							JobQueueService.scheduleJob(jobName, nowCRON, schedulable, job);
							jobQueueToScheduleLogs.add(jobName + ' ' + DateTime.now().addMinutes(1) + ' ' + flightNumber + ' ' + flightDate);
							numberOfJobInSFDCQueue++;
						} else if (thereIsAvailableSpaceInJobQueue) {
							Map<Id, Profile> profileMap = ProfileData.getInstance().getProfileMap();
							Boolean isAdmin = false;
							if(profileMap.containsKey(UserInfo.getProfileId())) {
								if(profileMap.get(UserInfo.getProfileId()).Name.contains('Admin')) {
									isAdmin = true;
								}
							}	
							if(!isAdmin) {
								JobQueueService.scheduleJob(jobName, cron, schedulable, job);
								jobQueueToScheduleLogs.add(jobName + ' ' + job.Schedule_Time__c + ' ' + flightNumber + ' ' + flightDate);
								numberOfJobInSFDCQueue++;
							}
						} else {
							job.Result__c = 'Queue limit exceeded.';
							job.Scheduled__c = false;
						}
					} catch (System.AsyncException e) {
						job.Result__c = e.getMessage();
						job.Scheduled__c = false;
					}

					// Reset Manual Run Flag
					job.Manual_Run__c = false;
				}
			}

			if (!jobQueueToScheduleLogs.isEmpty()) {
				List<Config_Parameter__mdt> configParams = [SELECT DeveloperName, Value__c FROM Config_Parameter__mdt WHERE DeveloperName = 'jobQueueToScheduleLog'];
				if (!configParams.isEmpty()) {
					if (configParams.get(0).Value__c == 'file') {
						List<Application_Log__c> logs = [SELECT Id FROM Application_Log__c WHERE Source_Function__c = 'JobQueueToScheduleLog_Attachment'];
						Application_Log__c log;
						if (logs.isEmpty()) {
							log = new Application_Log__c();
							log.Source__c = 'JobQueueToScheduleLog_Attachment';
							log.Source_Function__c = 'JobQueueToScheduleLog_Attachment';
							insert log;
						} else {
							log = logs.get(0);
						}

						Attachment attachment = new Attachment();
						attachment.Body = Blob.valueOf(String.join(jobQueueToScheduleLogs, '\n'));
						attachment.Name = String.valueOf(System.now()) + '.txt';
						attachment.ParentId = log.Id;
						insert attachment;
					} else if (configParams.get(0).Value__c == 'record') {
						List<Application_Log__c> logsForInsert = new List<Application_Log__c>();
						for (String jobQueueToScheduleLog : jobQueueToScheduleLogs ) {
							Application_Log__c log = new Application_Log__c();
							log.Source__c = 'JobQueueToScheduleLog';
							log.Source_Function__c = 'JobQueueToScheduleLog';
							log.Message__c = jobQueueToScheduleLog;
							logsForInsert.add(log);
						}
						insert logsForInsert;
					}
				}
			}
		}
	}
}