global class ROPEnrollment_Success_Report_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		ROPEnrollment_Success_Report report = new ROPEnrollment_Success_Report(1);
		report.sendSummaryReport();
	}
}