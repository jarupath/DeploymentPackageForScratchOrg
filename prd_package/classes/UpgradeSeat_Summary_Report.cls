public without sharing class UpgradeSeat_Summary_Report {

	private Integer lastNDays;
	private List<Case> cases;

	public UpgradeSeat_Summary_Report() {
		this(7);
	}

	public UpgradeSeat_Summary_Report(Integer lastNDays) {
		AppLogger.setReferenceId('UpgradeSeat_Summary_Report_' + System.today().format());
		AppLogger.debug('UpgradeSeat_Summary_Report', 'Constructor', '', 'Constructor:~lastNDays[' + lastNDays + ']', null);
		this.lastNDays = lastNDays;
		this.cases = queryUpgradeSeatByMileCases();
	}

	public List<Case> queryUpgradeSeatByMileCases() {
		BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Case');
		soql.addField(new Set<String> {'Id', 'Integration_Error_Reason__c', 'Integration_Error__c', 'FlightId__r.Name', 'CreatedDate', 'Passengerid__r.Name', 'PNR__c', 'Passengerid__r.Sector__c', 'Upgrade_Seat_with_Amount__c', 'ROP_Award_Code__c', 'Passengerid__r.FFP_Number__c', 'FlightId__r.Flight_Number__c', 'FlightId__r.Flight_Date_LT__c', 'Passengerid__r.Cabin_Code__c','Passengerid__r.Booking_Class__c','Passengerid__r.Checkin_Seat__c', 'Change_Seat__c', 'Change_Cabin_Class__c', 'PassengerId__r.Passenger_Salutation_Auto__c', 'PassengerId__r.Last_Name__c', 'PassengerId__r.First_Name__c'});
		soql.addCondition('CreatedDate = LAST_N_DAYS:' + this.lastNDays);
		soql.addCondition('Is_Upgrade_Seat_Case__c = TRUE');
		soql.addCondition('Payment_Type__c = \'Mileage\'');
		soql.addOrder('Flightid__c ASC');
		soql.addOrder('Integration_Error__c ASC');
		AppLogger.debug('UpgradeSeat_Summary_Report', 'queryUpgradeSeatByMileCases', '', soql.getQueryStr(), null);
		return Database.query(soql.getQueryStr());
	}

	public void sendSummaryReport() {
		Integer total = this.cases.size();
		Integer success = 0;
		Integer failed = 0;

		List<List<String>> datas = new List<List<String>>();
		List<String> header = new List<String>();
		header.add('\"Flight Number\"');
		header.add('\"Flight Date\"');
		header.add('\"Sector\"');
		header.add('\"OriginalCabinClass\"');
		header.add('\"NewCabinClass\"');
		header.add('\"OriginalBookingClass\"');
		header.add('\"OriginalSeatNumber\"');
		header.add('\"NewSeatNumber\"');
		header.add('\"PNR\"');
		header.add('\"ROP No.\"');

		header.add('\"Salutation\"');
		header.add('\"FirstName\"');
		header.add('\"LastName\"');
		

		header.add('\"AwardCode\"');
		header.add('\"MileageUsed\"');
		header.add('\"Status\"');
		header.add('\"ErrorMessage\"');
		datas.add(header);
		for (Case eachCase : this.cases) {
			List<String> dataEachRow = new List<String>();
			if (!eachCase.Integration_Error__c) {
				success++;
			} else {
				failed++;
			}

			dataEachRow.add('\"' + eachCase.FlightId__r.Flight_Number__c + '\"');
			if (eachCase.FlightId__r.Flight_Date_LT__c != null) {
				dataEachRow.add('\"' + eachCase.FlightId__r.Flight_Date_LT__c + '\"');
			} else {
				dataEachRow.add('\"\"');
			}
			dataEachRow.add('\"' + eachCase.Passengerid__r.Sector__c + '\"');
			dataEachRow.add('\"' + eachCase.Passengerid__r.Cabin_Code__c + '\"');
			dataEachRow.add('\"' + eachCase.Change_Cabin_Class__c + '\"');
			dataEachRow.add('\"' + eachCase.Passengerid__r.Booking_Class__c + '\"');
			dataEachRow.add('\"' + eachCase.Passengerid__r.Checkin_Seat__c + '\"');
			dataEachRow.add('\"' + eachCase.Change_Seat__c + '\"');
			dataEachRow.add('\"' + eachCase.PNR__c + '\"');
			dataEachRow.add('\"' + eachCase.Passengerid__r.FFP_Number__c + '\"');
			
			dataEachRow.add('\"' + eachCase.PassengerId__r.Passenger_Salutation_Auto__c + '\"');
			dataEachRow.add('\"' + eachCase.PassengerId__r.First_Name__c + '\"');
			dataEachRow.add('\"' + eachCase.PassengerId__r.Last_Name__c + '\"');
			

			dataEachRow.add('\"' + eachCase.ROP_Award_Code__c + '\"');
			dataEachRow.add('\"' + eachCase.Upgrade_Seat_with_Amount__c + '\"');
			if (eachCase.Integration_Error__c) {
				dataEachRow.add('\"Error\"');
			} else {
				dataEachRow.add('\"Success\"');
			}
			dataEachRow.add('\"' + eachCase.Integration_Error_Reason__c + '\"');
			datas.add(dataEachRow);
		}

		String bodyMsg = '';
		bodyMsg += System.today().addDays(-this.lastNDays).format() + ' - ' + System.today().format() + '\n';
		bodyMsg += 'Total :' + total + '\n';
		bodyMsg += 'Success :' + success + '\n';
		bodyMsg += 'Failed :' + failed + '\n';

		String attachmentName = System.today().format() +  '_MileageUpgradeOnBoard.csv';
		String toEmails = MailList_Repository.getEmailAddress('Upgrade Seat', 'UpgradeSeatAdmin');

		try {
			Email_Service.sendEmailWithAttachment('SFDC | Mileage Upgrade On-Board: Daily Report', toEmails, bodyMsg, BE8_GlobalUtility.toCSVString(datas), attachmentName);
			AppLogger.debug('UpgradeSeat_Summary_Report', 'sendSummaryReport', '', 'success', null);
		} catch (Exception e) {
			AppLogger.error('UpgradeSeat_Summary_Report', 'sendSummaryReport', '', 'Exception', e);
		}
	}

}