@isTest
private class CaseFlow_Test {
	@testSetup static void MockData(){
		//System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		//insert sysconfig;
		List<Flight__c> flightList = new List<Flight__c>();
		List<Crew_List__c> crewList = new List<Crew_List__c>();
		//Initiate Flight
		Flight__c flight1 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    Departure_STN__c  = 'BKK',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1');
		flightList.add(flight1);

		Crew_List__c crew2 = new Crew_List__c(
			Name = 'Temp Crew2',
		    Flight_Temp__c = 'TG0628_20Dec25_1',
		    //FlightId__c = flight1.Id,
		    Crew_Temp__c = '01232',
		    Crew_External_ID__c = '01232_TG0628_20Dec25_1',
		    Acting_Rank__c = 'AP',
		    Rank__c = 'AP');
		crewList.add(crew2);

		insert flightList;
		insert crewList;

		//Initiate Crew Mapping
		List<Crew_List__c> crew = [SELECT Id, CrewId__c FROM Crew_List__c WHERE Name = 'Temp Crew2' LIMIT 1];
		Crew_Mapping__c crewMap = new Crew_Mapping__c(
			UserId__c = '00528000004uNdcAAE',
			CrewId__c = crew.get(0).CrewId__c);
		insert crewMap;		

		Master_Map__c eq1 = new Master_Map__c(
			Name = 'ELECTRICAL & PNEUMATIC HEADPHONE', 
			Field_Name__c = 'SERVICE EQUIPMENT');
		insert eq1;
		Master_Map__c eq2 = new Master_Map__c(
			Name = 'HEADPHONE BODY',
			Field_Name__c = 'PART',
			Depend_On_Object__c = eq1.Id);
		insert eq2;

		System_Configuration__c sysconfig = new System_Configuration__c();
		sysconfig.Case_Closed_Record_Type_ID__c = '01228000000iqFZ';
		sysconfig.Case_Group_Member_Record_Type_ID__c = '01228000000iqFf';
		sysconfig.S3_Tier_1_Queue_ID__c = '00G28000002ZcPZ';
		sysconfig.S4_First_Platinum_Queue_ID__c = '00G28000002ZcPa';
		sysconfig.S4_Level_8_In_Flight_Queue_ID__c = '00G28000002ZcPc';
		sysconfig.S4_Tier_2_Queue_ID__c = '00G28000002ZcPf';
		sysconfig.S4_Tier_1_Queue_ID__c = '00G28000002ZcPe';
		sysconfig.S3_Chief_Queue_ID__c = '00G28000002ZcPY';
		sysconfig.S4_Level_8_Ground_Queue_ID__c = '00G28000002ZcPb';
		sysconfig.S4_Level_8_Queue_ID__c = '00G28000002ZcPd';
		sysconfig.AO_Baggage_Claim__c = '00G28000002ZcPX';

		insert sysconfig;

		List<Passenger__c> paxList = MockupData_Test.createPassengerList(flight1.Id, 100);
		insert paxList;
	}

	@isTest static void testForCaseDMLLimit() {
		//Amount of Case
		Integer incidentNumber = 1;
		//Amount of position in wach case
		Integer positionNumber = 300;
		//Integer incidentNumber = 55;
		//////Amount of position in wach case
		//Integer positionNumber = 10;
		//Set up
		MockupData_Test.initializeWebServiceCustomSetting();
		String flightId = [SELECT Id FROM Flight__c WHERE Flight_External_ID__c = 'TG0628_20Dec25_1'].get(0).Id;
		String crewId = [SELECT Id FROM Crew__c WHERE Personel_Id__c = '01232'].get(0).Id;
		//Map<String, Master_Map__c> equipMap = new Map<String, Master_Map__c>([SELECT Id, Depend_On_Object__c, (SELECT Id, Name FROM Depend_On_Object__r) FROM Master_Map__c WHERE Field_Name__c = :BE8_GlobalConstants.SERVICE_EQUIPMENT AND Aircraft_Description__c = null]);
		List<Master_Map__c> equipList = [SELECT Id, Depend_On_Object__c, (SELECT Id, Name FROM Depend_On_Object__r) FROM Master_Map__c WHERE Field_Name__c = :BE8_GlobalConstants.SERVICE_EQUIPMENT AND Aircraft_Description__c = null];
		Master_Map__c equip = equipList.get(0);
		String equipId = equip.Id;
		String partId = equip.Depend_On_Object__r.get(0).Id;

		List<MB_RESTRequestInfoModel.incident_model> incidentModelList = MockupData_Test.getIncidentModelList(incidentNumber, flightId, crewId, equipId, partId, positionNumber);
		for(MB_RESTRequestInfoModel.incident_model inci : incidentModelList){
			System.debug(inci);
		}

		System.debug('SJ : noQueriesDebug');
		Test.startTest();
		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(incidentModelList);
		Test.stopTest();
		for(MB_RestResponseInfoModel.incident_model res : responseList){
			System.debug('----------RESPONSE----------');
			System.debug(res);
		}
	}

	//@isTest static void testForCaseWithPaxDMLLimit(){
	//	//Flightid__c,Passengerid__c,Status,Origin,Priority,Impact,Case_Type__c,Description,RecordTypeId
	//	//a0DN000000BnSZ9,a0IN0000004eGg7,New,Phone,Medium,Medium,Commendation,Case Detail - I think TG's service is world class.,012N00000009VqkIAE
	//	List<Case> caseList = new List<Case>();
	//	Map<String, SObject> recordTypeMap = BE8_GlobalUtility.getSObjectMap('Name', [SELECT Id, Name FROM RecordType]);
	//	String status = 'New';
	//	String origin = 'Phone';
	//	String priority = 'Medium';
	//	String impact = 'Medium';
	//	String caseType = 'Complaint';
	//	String description = 'Case Detail - I think TG\'s service is world class.';
	//	Id flightId = [SELECT Id FROM Flight__c LIMIT 1].Id;
	//	List<Passenger__c> paxList = [SELECT Id FROM Passenger__c];

	//	for(Passenger__c pax : paxList){
	//		Case thisca = new Case();
	//		thisca.Flightid__c = flightId;
	//		thisca.Passengerid__c = pax.Id;
	//		thisca.Status = status;
	//		thisca.Origin = origin;
	//		thisca.Priority = priority;
	//		thisca.Impact__c = impact;
	//		thisca.Case_Type__c = caseType;
	//		thisca.Description = description;
	//		thisca.RecordTypeId = ((RecordType)recordTypeMap.get('Customer Feedback View')).Id;

	//		caseList.add(thisca);
	//	}

	//	Test.startTest();
	//	insert caseList;
	//	Test.stopTest();
	//	System.debug('Case Group');
	//	System.debug(JSON.serialize([SELECT Id, Name, Passengerid__r.Name, FlightId__r.Name FROM Case_Group_Member__c]));
	//}
}