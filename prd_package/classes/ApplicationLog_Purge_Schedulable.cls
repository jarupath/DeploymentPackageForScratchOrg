global class ApplicationLog_Purge_Schedulable implements Schedulable {

	Integer lastNMonth;

	public ApplicationLog_Purge_Schedulable() {
		lastNMonth = 3;
	}

	public ApplicationLog_Purge_Schedulable(Integer lastNMonth) {
		this.lastNMonth = lastNMonth;
	}

	global void execute(SchedulableContext sc) {
		Database.executeBatch(new ApplicationLog_Purge_Batch(this.lastNMonth));
	}
}