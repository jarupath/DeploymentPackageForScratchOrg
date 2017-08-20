global with sharing class JobQueueService {

	global class JobQueueWrapper implements Comparable {
		public Job_Queue__c job;

		public JobQueueWrapper(Job_Queue__c job) {
			this.job = job;
		}

		global Integer compareTo(Object compareTo) {
			JobQueueWrapper otherObj = (JobQueueWrapper) compareTo;
			if (this.job.Schedule_Time__c > otherObj.job.Schedule_Time__c) {
				return 1;
			} else if (this.job.Schedule_Time__c < otherObj.job.Schedule_Time__c) {
				return -1;
			} else {
				return 0;
			}
		}
	}

	public static Job_Queue__c scheduleJob(String jobName, String cron, Schedulable schedulable, Job_Queue__c job) {
		Boolean isJobQueueSchedulerActive = Trigger_Activation__c.getInstance().Job_Queue_Scheduler__c;
		if (isJobQueueSchedulerActive) {
			System.schedule(jobName, cron, schedulable);
		}
		job.Scheduled__c = true;
		job.Queued_Time__c = DateTime.now();
		return job;
	}

	public static List<Job_Queue__c> enqueueJob() {
		//Boolean isJobQueueTriggerActive = Trigger_Activation__c.getInstance().Job_Queue_Trigger__c;
		List<CronTrigger> jobInSFDCQueue = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
		                                    FROM CronTrigger WHERE State = 'WAITING'];
		Integer numberOfJobInSFDCQueue = jobInSFDCQueue.size();
		if (numberOfJobInSFDCQueue < BE8_GlobalConstants.JOB_QUEUE_LIMIT) {
			Integer numberOfJobToBeQueued = BE8_GlobalConstants.JOB_QUEUE_LIMIT - numberOfJobInSFDCQueue;
			DateTime conditionDateTime = System.now().addHours(1);
			List<Job_Queue__c> jobToBeQueued = [SELECT Id, Schedule_Time__c FROM Job_Queue__c WHERE CreatedDate >= LAST_N_DAYS:14 AND Scheduled__c = false AND Schedule_Time__c < :conditionDateTime ORDER BY Schedule_Time__c ASC LIMIT 1000];
			Set<Id> jobIdSet = new Set<Id>();
			for (Job_Queue__c job : jobToBeQueued) {
				//System.debug(job.Schedule_Time__c);
				job.Scheduled__c = true;
				jobIdSet.add(job.Id);
			}
			System.debug(jobToBeQueued);
			Database.update(jobToBeQueued, false);
			return [SELECT Id, Class_Name__c, Job_Name__c, Parameter__c, Reference_Id__c, Result__c, Scheduled__c, Schedule_Time__c FROM Job_Queue__c WHERE Id IN :jobIdSet AND Scheduled__c = true];
		} else {
			return null;
		}
	}

	public static void deleteOutdatedScheduledJob() {
		DELETE [SELECT Id FROM Job_Queue__c WHERE Scheduled__c = true AND Age__c > :BE8_GlobalConstants.JOB_QUEUE_AGE_IN_DAYS LIMIT 1000];
	}
}