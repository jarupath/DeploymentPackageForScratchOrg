/**
 * @author chansak.s@beryl8.com
 * @21/03/2017 create new
 */
global class PaxFlownDetailSchedule implements Schedulable {
	global void execute(SchedulableContext sc) {
    	Database.executeBatch(new PaxFlownDetailBatch());
    }
}