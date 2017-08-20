global class Monitor_Job_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		Monitor_Job_Service.logJobSummary();
	}
}