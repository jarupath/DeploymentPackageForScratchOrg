@isTest
private class PaxFlownDetailBatch_Test {
	
	@isTest
	static void test() {
		TriggerActivator.overrideTriggerActivation('Flight_Trigger__c', false);
		TriggerActivator.overrideTriggerActivation('Passenger_Trigger__c', false);
		List<Flight__c> insertFlightList = new List<Flight__c>();
		List<Passenger__c> insertPassengerList = new List<Passenger__c>();
		String pnrPrefix = '2BSJ62';

		Date flightDateUTC = System.today().addDays(-1);
		String flightDateText = DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),flightDateUTC.day()).format('YYYY-MM-dd');
		//String conditionDate =DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),01).format('YYYY-MM-dd');
		//PAX_Flown_Summary__c masterPaxFlownSummary = new PAX_Flown_Summary__c(Name=(DateTime.newInstance(flightDateUTC.year(),flightDateUTC.month(),01).format('YYYY-MM')),Data_Date_Key__c=conditionDate,Data_Date__c=date.newInstance(flightDateUTC.year(),flightDateUTC.month(),01));
		String fltdate = BE8_DateUtility.convertDateFormatToTraditionalFormat(flightDateText);
		System.debug('JK: fltdate - ' + fltdate);
		Flight__c flightno1 = new Flight__c (Name = 'TG410',Flight_Date_UTC__c = flightDateText,Flight_Area__c='Europe',Flight_Region__c='Intercontinental',Flight_Number__c='TG410', Flight_External_ID__c = 'TG0410_' + fltdate + '_1', STD_LT__c = flightDateText + ' 09:00:00');
		Flight__c flightno2 = new Flight__c (Name = 'TG8903',Flight_Date_UTC__c = flightDateText,Flight_Area__c='Northern',Flight_Region__c='Regional',Flight_Number__c='TG8903', Flight_External_ID__c = 'TG8903_' + fltdate + '_1', STD_LT__c = flightDateText + ' 09:00:00');
		Flight__c flightno3 = new Flight__c (Name = 'TG430',Flight_Date_UTC__c = flightDateText,Flight_Area__c='Northern',Flight_Region__c='Intercontinental',Flight_Number__c='TG430', Flight_External_ID__c = 'TG0430_' + fltdate + '_1', STD_LT__c = flightDateText + ' 09:00:00');
		
		
		insertFlightList.add(flightno1);
		insertFlightList.add(flightno2);
		insertFlightList.add(flightno3);
		insert insertFlightList;

		Passenger__c passenger1_1 = new Passenger__c(First_Name__c='F1',Last_Name__c='L1',FlightId__c=flightno1.ID,Cabin_Code__c='Y',Flight_Master__c='TG410'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15A');
		Passenger__c passenger1_2 = new Passenger__c(First_Name__c='F2',Last_Name__c='L2',FlightId__c=flightno1.ID,Cabin_Code__c='Y',Flight_Master__c='TG410'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15B');
		Passenger__c passenger1_3 = new Passenger__c(First_Name__c='F3',Last_Name__c='L3',FlightId__c=flightno1.ID,Cabin_Code__c='Y',Flight_Master__c='TG410'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15C');
		Passenger__c passenger1_4 = new Passenger__c(First_Name__c='F4',Last_Name__c='L4',FlightId__c=flightno1.ID,Cabin_Code__c='C',Flight_Master__c='TG410'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15D');
		Passenger__c passenger1_5 = new Passenger__c(First_Name__c='F5',Last_Name__c='L5',FlightId__c=flightno1.ID,Cabin_Code__c='C',Flight_Master__c='TG410'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15E');
		
		Passenger__c passenger2_1 = new Passenger__c(First_Name__c='F1',Last_Name__c='L1',FlightId__c=flightno2.ID,Cabin_Code__c='Y',Flight_Master__c='TG8903'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15A');
		Passenger__c passenger2_2 = new Passenger__c(First_Name__c='F2',Last_Name__c='L2',FlightId__c=flightno2.ID,Cabin_Code__c='Y',Flight_Master__c='TG8903'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15B');
		Passenger__c passenger2_3 = new Passenger__c(First_Name__c='F3',Last_Name__c='L3',FlightId__c=flightno2.ID,Cabin_Code__c='C',Flight_Master__c='TG8903'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15C');
		Passenger__c passenger2_4 = new Passenger__c(First_Name__c='F4',Last_Name__c='L4',FlightId__c=flightno2.ID,Cabin_Code__c='C',Flight_Master__c='TG8903'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15D');
		
		//Duplicate person paxkey
		Passenger__c passenger3_1 = new Passenger__c(First_Name__c='F1',Last_Name__c='L1',FlightId__c=flightno3.ID,Cabin_Code__c='Y',Flight_Master__c='TG430'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15A');
		Passenger__c passenger3_2 = new Passenger__c(First_Name__c='F1',Last_Name__c='L1',FlightId__c=flightno3.ID,Cabin_Code__c='Y',Flight_Master__c='TG430'+flightDateText,PNR__c='PNR', Checkin_Seat__c='15B');

		insertPassengerList.add(passenger1_1);
		insertPassengerList.add(passenger1_2);
		insertPassengerList.add(passenger1_3);
		insertPassengerList.add(passenger1_4);
		insertPassengerList.add(passenger1_5);
		insertPassengerList.add(passenger2_1);
		insertPassengerList.add(passenger2_2);
		insertPassengerList.add(passenger2_3);
		insertPassengerList.add(passenger2_4);
		insertPassengerList.add(passenger3_1);
		insertPassengerList.add(passenger3_2);

		insert insertPassengerList;

		Test.startTest();
            Database.executeBatch(new PaxFlownDetailBatch(),200);
        Test.stopTest();

		//List<PAX_Flown_Summary__c> summaryList = [SELECT ID,Total_Passengers__c FROM PAX_Flown_Summary__c WHERE Data_Date_Key__c ='2017-03-01'];
		List<PAX_Flown_Summary__c> summaryList = [SELECT ID,Total_Passengers__c FROM PAX_Flown_Summary__c];
		List<PAX_Flown_Detail__c> detailList = [SELECT ID,Total_Passengers__c FROM PAX_Flown_Detail__c ];
		System.debug('JK: summaryList - ' + summaryList);
		System.debug('JK: detailList - ' + detailList);
		System.assertEquals(1,summaryList.size());
		System.assertEquals(5,detailList.size());
		System.assertEquals(10,summaryList.get(0).Total_Passengers__c);
	}
	
	
}