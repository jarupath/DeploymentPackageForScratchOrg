global class Purge_Batch_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		Database.executeBatch(new Purge_Batch());
	}
}