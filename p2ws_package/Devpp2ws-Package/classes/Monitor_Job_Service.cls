public with sharing class Monitor_Job_Service {
	public Monitor_Job_Service() {
		
	}

	public static void logJobSummary() {
		String summary = Monitor_Job_Service.getJobSummary();
		if(summary != '') {
			List<Application_Log__c> logs = [SELECT Id FROM Application_Log__c WHERE Source_Function__c = 'MonitorJobSchedulable_SummaryJob'];
			Application_Log__c log;
			if(logs.isEmpty()) {
				log = new Application_Log__c();
				log.Source__c = 'MonitorJobSchedulable';
				log.Source_Function__c = 'MonitorJobSchedulable_SummaryJob';
				insert log;
			} else {
				log = logs.get(0);
			}

			Attachment attachment = new Attachment();
			attachment.Body = Blob.valueOf(summary);
			attachment.Name = String.valueOf(System.now()) + '.txt';
			attachment.ParentId = log.Id;
			insert attachment;
		}
	}

	public static String getJobSummary() {
		String scheduleJobSummary = getScheduleJobSummary();
		if(scheduleJobSummary == '') {
			return '';
		}
 
		String summary = '';
		summary += 'Summary Job Queue\n';
		summary += getJobQueueSummary();

		summary += 'Summary Schedule Job\n';
		summary += scheduleJobSummary;
		return summary;
	}

	public static String getJobQueueSummary() {
		String summary = '';

		DateTime startTime = System.now().addHours(-1);
		DateTime endTime = System.now().addHours(1);

		List<Job_Queue__c> jobs = [SELECT Id, NAme, Schedule_Time__c FROM Job_Queue__c WHERE Schedule_Time__c > :startTime AND Schedule_Time__c < :endTime  ORDER BY Schedule_Time__c ASC];
		Map<DateTime, Integer> nextFireTimeCounterMap = new Map<DateTime, Integer>();
		Map<String, Integer> jobNameCounterMap = new Map<String, Integer>();
		for(Job_Queue__c job : jobs) {
		    Integer nextFireTimeCounter = 0;
		    if(nextFireTimeCounterMap.containsKey(job.Schedule_Time__c)) {
		        nextFireTimeCounter = nextFireTimeCounterMap.get(job.Schedule_Time__c);
		    }
		    nextFireTimeCounter++;
		    nextFireTimeCounterMap.put(job.Schedule_Time__c, nextFireTimeCounter);
		    
		    Integer jobNameCounter = 0;
		    if(jobNameCounterMap.containsKey(job.Name)) {
		        jobNameCounter = jobNameCounterMap.get(job.Name);
		    }
			jobNameCounter++;
			jobNameCounterMap.put(job.Name, jobNameCounter);
		}

		for(DateTime nextFireTime : nextFireTimeCounterMap.keySet()) {
		    if(nextFireTimeCounterMap.get(nextFireTime) >= 5) {
		    	summary += nextFireTime + ' ('+nextFireTimeCounterMap.get(nextFireTime)+')\n';
		    }
		}

		for(String jobName: jobNameCounterMap.keySet()) {
		    if(jobNameCounterMap.get(jobName) > 1) {
		    	summary += jobName + ' ('+jobNameCounterMap.get(jobName)+')\n';
		    }
		}

		return summary;
	}

	public static String getScheduleJobSummary() {
		String summary = '';
		DateTime startTime = System.now().addHours(-1);
		DateTime endTime = System.now().addHours(1);
		List<CronTrigger> jobs = [SELECT Id, CronJobDetail.Name, NextFireTime FROM CronTrigger WHERE NextFireTime > :startTime AND NextFireTime <= :endTime AND CronJobDetail.Name LIKE 'Flight%'];
		Map<DateTime, Integer> nextFireTimeCounterMap = new Map<DateTime, Integer>();
		Map<String, Integer> jobNameCounterMap = new Map<String, Integer>();
		for(CronTrigger job : jobs) {
		    Integer nextFireTimeCounter = 0;
		    if(nextFireTimeCounterMap.containsKey(job.NextFireTime)) {
		        nextFireTimeCounter = nextFireTimeCounterMap.get(job.NextFireTime);
		    }
		    nextFireTimeCounter++;
		    nextFireTimeCounterMap.put(job.NextFireTime, nextFireTimeCounter);
		    
		    Integer jobNameCounter = 0;
		    if(jobNameCounterMap.containsKey(job.CronJobDetail.Name)) {
		        jobNameCounter = jobNameCounterMap.get(job.CronJobDetail.Name);
		    }
			jobNameCounter++;
			jobNameCounterMap.put(job.CronJobDetail.Name, jobNameCounter);
		}

		for(DateTime nextFireTime : nextFireTimeCounterMap.keySet()) {
		    //if(nextFireTimeCounterMap.get(nextFireTime) >= 5) {
		    	summary += nextFireTime + ' ('+nextFireTimeCounterMap.get(nextFireTime)+')\n';
		    //}
		}

		for(String jobName: jobNameCounterMap.keySet()) {
		    if(jobNameCounterMap.get(jobName) > 1) {
		    	summary += jobName + ' ('+jobNameCounterMap.get(jobName)+')\n';
		    }
		}

		return summary;
	}
}