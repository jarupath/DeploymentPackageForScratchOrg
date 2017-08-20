public with sharing class ROPEnrollment_Manual_Queueable implements Queueable, Database.AllowsCallouts {
	private Id ropEnrollmentId;

	public ROPEnrollment_Manual_Queueable(Id ropEnrollmentId) {
		this.ropEnrollmentId = ropEnrollmentId;
		AppLogger.setReferenceId('ROPEnrollment_Manual_Queueable_' + ropEnrollmentId);
		AppLogger.debug('ROPEnrollment_Manual_Queueable', 'Constructor', ropEnrollmentId, 'ropEnrollmentId:' + ropEnrollmentId, null);
	}

	public void execute(QueueableContext context) {
		String toEmails = MailList_Repository.getEmailAddress('ROP Enrollment', 'ROPEnrollment_Manual');
		ROP_Enrollment__c ropEnrollment = [SELECT Id, Salutation__c, Country_Code__c, PassengerId__r.Passenger_Salutation_Auto__c, Area_Code__c, First_Name__c, Last_Name__c, Birthdate__c, Gender__c, Email__c, Phone_Number__c, FlightId__r.Name, PassengerId__r.Sector__c, PassengerId__r.Nationality__c, PassengerId__r.Name, PassengerId__r.Booking_Class__c, PassengerId__r.Cabin_Code__c, PassengerId__r.Checkin_Seat__c FROM ROP_Enrollment__c WHERE Id = : ropEnrollmentId LIMIT 1];
		String bodyMsg = '';
		bodyMsg += 'Salutation:\n';
		bodyMsg += 'First Name: ' + ropEnrollment.First_Name__c + '\n';
		bodyMsg += 'Last Name: ' + ropEnrollment.Last_Name__c + '\n';
		bodyMsg += 'Date of Birth: ' + ropEnrollment.Birthdate__c + '\n';
		bodyMsg += 'Gender: ' + ropEnrollment.Gender__c + '\n';
		bodyMsg += 'Nationality: ' + ropEnrollment.PassengerId__r.Nationality__c + '\n';
		bodyMsg += 'Email: ' + ropEnrollment.Email__c + '\n';
		bodyMsg += 'Phone Number: ' + ropEnrollment.Country_Code__c + ' ' + ropEnrollment.Area_Code__c + ' ' + ropEnrollment.Phone_Number__c + '\n';
		bodyMsg += 'Flight No.: ' + ropEnrollment.FlightId__r.Name + '\n';
		bodyMsg += 'Origin-Destination: ' + ropEnrollment.PassengerId__r.Sector__c + '\n';
		bodyMsg += 'Booking Class: ' + ropEnrollment.PassengerId__r.Booking_Class__c + '\n';
		bodyMsg += 'Flown Cabin Class: ' + ropEnrollment.PassengerId__r.Cabin_Code__c + '\n';
		bodyMsg += 'Seat No.: ' + ropEnrollment.PassengerId__r.Checkin_Seat__c + '\n';

		try {
			Email_Service.sendEmail('SFDC | Manual ROP Enrollment On-Board: ' + ropEnrollment.PassengerId__r.Name, toEmails, bodyMsg);
			AppLogger.debug('ROPEnrollment_Manual_Queueable', 'execute', 'ROPEnrollment_Manual_Queueable_' + ropEnrollmentId, 'success', null);
		} catch (Exception e) {
			AppLogger.error('ROPEnrollment_Manual_Queueable', 'execute', 'ROPEnrollment_Manual_Queueable_' + ropEnrollmentId, 'exception', e);

		}
	}

	public static Id process(Id ropEnrollmentId) {
		Id jobId;
		try {
			ROPEnrollment_Manual_Queueable manual = new ROPEnrollment_Manual_Queueable(ropEnrollmentId);
			jobId = System.enqueueJob(manual);
			AppLogger.debug('ROPEnrollment_Manual_Queueable', 'enqueueJob', 'ROPEnrollment_Manual_Queueable_' + ropEnrollmentId, 'jobId:' + jobId, null);
		} catch (Exception e) {
			AppLogger.error('ROPEnrollment_Manual_Queueable', 'enqueueJob', 'ROPEnrollment_Manual_Queueable_' + ropEnrollmentId, 'exception', e);
		}
		return jobId;
	}
}