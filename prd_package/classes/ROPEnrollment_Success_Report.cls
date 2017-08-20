public with sharing class ROPEnrollment_Success_Report {
	private Integer lastNDays;
	@TestVisible private List<ROP_Enrollment__c> ropEnrollments;

	public ROPEnrollment_Success_Report() {
		this(7);
	}

	public ROPEnrollment_Success_Report(Integer lastNDays) {
		this.lastNDays = lastNDays;
		this.ropEnrollments = queryROPEnrollments();
	}

	public List<ROP_Enrollment__c> queryROPEnrollments() {
		BE8_SoqlBuilder soql = new BE8_SoqlBuilder('ROP_Enrollment__c');
		soql.addField(new Set<String> {'Id', 'Enrollment_Date__c', 'Enrollment_Status__c', 'Enrollment_Type__c', 'Salutation__c', 'First_Name__c', 'Last_Name__c', 'Birthdate__c', 'Gender__c', 'Email__c', 'Phone_Number__c', 'FlightId__r.Name', 'FlightId__r.Flight_Number__c', 'FlightId__r.Origin__c', 'FlightId__r.Destination__c', 'Integration_Error_Reason__c', 'Integration_Error__c', 'ROP_Number_F__c', 'PassengerId__r.Sector__c', 'PassengerId__r.Booking_Class__c', 'PassengerId__r.Cabin_Code__c', 'PassengerId__r.Checkin_Seat__c', 'PassengerId__r.Passenger_Salutation_Auto__c','FlightId__r.Flight_Date_LT__c','FlightId__r.Flight_Number__c'});
		soql.addCondition('Enrollment_Date__c = LAST_N_DAYS:' + this.lastNDays);
		soql.addCondition('Enrollment_Status__c = \'Enroll\'');
		soql.addCondition('Integration_Error__c = false');
		soql.addCondition('Enrollment_Type__c = \'Web Service\'');
		soql.addOrder('FlightId__c ASC');
		System.debug(soql.getQueryStr());
		return Database.query(soql.getQueryStr());
	}

	public void sendSummaryReport() {
		Integer total = this.ropEnrollments.size();
		Integer success = 0;
		Integer failed = 0;

		List<List<String>> datas = new List<List<String>>();
		List<String> header = new List<String>();
		header.add('\"ROPNumber\"');
		//header.add('\"EnrollmentStatus\"');
		//header.add('\"EnrollmentType\"');
		header.add('\"Salutation\"');
		header.add('\"FirstName\"');
		header.add('\"LastName\"');

		header.add('\"Flight Number\"');
		header.add('\"Flight Date\"');
		header.add('\"Sector\"');
		header.add('\"BookingClass\"');
		header.add('\"FlownCabinClass\"');
		header.add('\"SeatNo\"');

		//header.add('\"Birthdate\"');
		//header.add('\"IsError\"');
		//header.add('\"ErrorMessage\"');
		datas.add(header);
		for (ROP_Enrollment__c ropEnrollment : this.ropEnrollments) {
			List<String> dataEachRow = new List<String>();
			//if(!ropEnrollment.Integration_Error__c) {
			//	success++;
			//} else {
			//	failed++;
			//}

			dataEachRow.add('\"' + ropEnrollment.ROP_Number_F__c + '\"');
			//dataEachRow.add('\"'+ropEnrollment.Enrollment_Status__c+'\"');
			//dataEachRow.add('\"'+ropEnrollment.Enrollment_Type__c+'\"');
			dataEachRow.add('\"' + ropEnrollment.PassengerId__r.Passenger_Salutation_Auto__c + '\"');
			dataEachRow.add('\"' + ropEnrollment.First_Name__c + '\"');
			dataEachRow.add('\"' + ropEnrollment.Last_Name__c + '\"');

			dataEachRow.add('\"' + ropEnrollment.FlightId__r.Flight_Number__c + '\"');
			if (ropEnrollment.FlightId__r.Flight_Date_LT__c != null) {
				dataEachRow.add('\"' + ropEnrollment.FlightId__r.Flight_Date_LT__c + '\"');
			} else {
				dataEachRow.add('\"\"');
			}
			dataEachRow.add('\"' + ropEnrollment.PassengerId__r.Sector__c + '\"');
			dataEachRow.add('\"' + ropEnrollment.PassengerId__r.Booking_Class__c + '\"');
			dataEachRow.add('\"' + ropEnrollment.PassengerId__r.Cabin_Code__c + '\"');
			dataEachRow.add('\"' + ropEnrollment.PassengerId__r.Checkin_Seat__c + '\"');

			//dataEachRow.add('\"'+ropEnrollment.Birthdate__c+'\"');
			//dataEachRow.add('\"'+ropEnrollment.Integration_Error__c+'\"');
			//dataEachRow.add('\"'+ropEnrollment.Integration_Error_Reason__c+'\"');
			datas.add(dataEachRow);
		}

		String bodyMsg = '';
		//bodyMsg += System.today().addDays(-this.lastNDays).format() + ' - ' + System.today().format() + '\n';
		bodyMsg += 'Total :' + total + '\n';
		//bodyMsg += 'Success :' + success +'\n';
		//bodyMsg += 'Failed :' + failed +'\n';

		String attachmentName = System.today().format() +  '_RetroCreditMilesOnBoard.csv';
		String toEmails = MailList_Repository.getEmailAddress('ROP Enrollment', 'ROPEnrollment_Summary_Report');
		Email_Service.sendEmailWithAttachment('SFDC | RETRO Credit Miles On-Board: Daily Report', toEmails, bodyMsg, BE8_GlobalUtility.toCSVString(datas), attachmentName);
	}
}