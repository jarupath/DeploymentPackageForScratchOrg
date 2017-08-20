public with sharing class CronTrigger_Repository {
	private static CronTrigger_Repository instance = null;
	private Map<String, CronTrigger> cronTriggerMap = new Map<String, CronTrigger>();

	public CronTrigger_Repository() {

	}

	public List<CronTrigger> getByName(Set<String> jobNames) {
		List<CronTrigger> cronTriggersToReturn = new List<CronTrigger>();
		Set<String> jobNamesForQuery = new Set<String>();
		for (String jobName : jobNames) {
			if (cronTriggerMap.containsKey(jobName)) {
				cronTriggersToReturn.add(cronTriggerMap.get(jobName));
			} else {
				jobNamesForQuery.add(jobName);
			}
		}
		//System.debug('SJ : getByName :' + jobNames.size() + ' ' +  jobNamesForQuery.size());
		if (!jobNamesForQuery.isEmpty()) {
			cronTriggersToReturn.addAll([SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE CronJobDetail.Name IN :jobNamesForQuery]);
		}
		return cronTriggersToReturn;
	}

	public static CronTrigger_Repository getInstance() {
		if (instance == null) instance = new CronTrigger_Repository();
		return instance;
	}
}