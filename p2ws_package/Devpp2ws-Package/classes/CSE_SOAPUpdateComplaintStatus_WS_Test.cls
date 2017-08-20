@isTest
private class CSE_SOAPUpdateComplaintStatus_WS_Test {
	@testSetup static void MockData(){
		MockupData_Test.initialApplicationLogCustomSetting();
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
	}
	
	@isTest static void testApplicationLogShouldbeCreatedForPostStatusEqualToCLOSE() {
		//Amount of Case
		Integer incidentNumber = 3;
		//Amount of position in wach case
		Integer positionNumber = 2;
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
		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(incidentModelList);
		for(MB_RESTRequestInfoModel.incident_model incident : incidentModelList){
			CSE_SOAPUpdateComplaintStatus_WS.updateStatus(incident.seqNo, 'CLOSE');
		}
		List<Case> caseList = [SELECT Id, Subject, Status FROM Case];
		List<Application_Log__c> applogList = [SELECT Id, Name, Source__c, Reference_Id__c, Reference_Information__c, Message__c, Debug_Level__c FROM Application_Log__c WHERE Source__c = 'CSE_SOAPUpdateComplaintStatus_WS'];
		for(Application_Log__c applog : applogList){
			System.debug(applog);
		}
		for(Case c : caseList){
			System.debug(c);
		}
		System.assertEquals(3, applogList.size());
	}

		@isTest static void testApplicationLogShouldbeCreatedForPostStatusNOTEqualToCLOSE() {
		//Amount of Case
		Integer incidentNumber = 3;
		//Amount of position in wach case
		Integer positionNumber = 2;
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
		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(incidentModelList);
		for(MB_RESTRequestInfoModel.incident_model incident : incidentModelList){
			CSE_SOAPUpdateComplaintStatus_WS.updateStatus(incident.seqNo, 'CLOS');
		}
		List<Case> caseList = [SELECT Id, Subject, Status FROM Case];
		List<Application_Log__c> applogList = [SELECT Id, Name, Source__c, Reference_Id__c, Reference_Information__c, Message__c, Debug_Level__c FROM Application_Log__c WHERE Source__c = 'CSE_SOAPUpdateComplaintStatus_WS'];
		for(Application_Log__c applog : applogList){
			System.debug(applog);
		}
		for(Case c : caseList){
			System.debug(c);
		}
		System.assertEquals(3, applogList.size());
	}

	@isTest static void testApplicationLogShouldbeCreatedForPostStatusIsNULL() {
		//Amount of Case
		Integer incidentNumber = 3;
		//Amount of position in wach case
		Integer positionNumber = 2;
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
		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(incidentModelList);
		for(MB_RESTRequestInfoModel.incident_model incident : incidentModelList){
			CSE_SOAPUpdateComplaintStatus_WS.updateStatus(incident.seqNo, null);
		}
		List<Case> caseList = [SELECT Id, Subject, Status FROM Case];
		List<Application_Log__c> applogList = [SELECT Id, Name, Source__c, Reference_Id__c, Reference_Information__c, Message__c, Debug_Level__c FROM Application_Log__c WHERE Source__c = 'CSE_SOAPUpdateComplaintStatus_WS'];
		for(Application_Log__c applog : applogList){
			System.debug(applog);
		}
		for(Case c : caseList){
			System.debug(c);
		}
		System.assertEquals(3, applogList.size());
	}

	@isTest static void testApplicationLogShouldbeCreatedForPostSeqNoIsNULL() {
		//Amount of Case
		Integer incidentNumber = 3;
		//Amount of position in wach case
		Integer positionNumber = 2;
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
		List<MB_RestResponseInfoModel.incident_model> responseList = MB_RESTIncidentService.createIncident(incidentModelList);
		for(MB_RESTRequestInfoModel.incident_model incident : incidentModelList){
			CSE_SOAPUpdateComplaintStatus_WS.updateStatus(null, 'CLOSE');
		}
		List<Case> caseList = [SELECT Id, Subject, Status FROM Case];
		List<Application_Log__c> applogList = [SELECT Id, Name, Source__c, Reference_Id__c, Reference_Information__c, Message__c, Debug_Level__c FROM Application_Log__c WHERE Source__c = 'CSE_SOAPUpdateComplaintStatus_WS'];
		for(Application_Log__c applog : applogList){
			System.debug(applog);
		}
		for(Case c : caseList){
			System.debug(c);
		}
		System.assertEquals(3, applogList.size());
	}
}