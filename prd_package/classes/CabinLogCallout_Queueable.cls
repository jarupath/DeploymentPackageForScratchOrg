public with sharing class CabinLogCallout_Queueable implements Queueable, Database.AllowsCallouts {
	private Id cabinLogCaseId;

	public CabinLogCallout_Queueable(Id cabinLogCaseId) {
		this.cabinLogCaseId = cabinLogCaseId;
	}

	public void execute(QueueableContext context) {
		if(cabinLogCaseId != null){
			CSE_SOAPCABINLOG_WS.createCabinLogFromCaseList(new Set<Id> {cabinLogCaseId});
		}
		AppLogger.insertLogs();
	}
}