global class UpgradeSeat_Summary_Report_Schedulable implements Schedulable {
	global void execute(SchedulableContext sc) {
		UpgradeSeat_Summary_Report report = new UpgradeSeat_Summary_Report(1);
		report.sendSummaryReport();
	}
}