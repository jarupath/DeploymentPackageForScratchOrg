global class ROPEnrollment_Summary_Report_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		ROPEnrollment_Summary_Report report = new ROPEnrollment_Summary_Report(7);
		report.sendSummaryReport();
	}
}