@RestResource(urlMapping = '/crewduty/*')

global without sharing class MB_RESTCrewDutyAssignment {
private static final String CLASS_NAME = 'MB_RESTCrewDutyAssignment';
	@HttpPost
	global static CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model updateCrewDutyAssignment(List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutyList){
		Map<String, List<MB_RESTRequestInfoModel.crewDutyAssignment_model>> crewdutyListMapByFlight = new Map<String, List<MB_RESTRequestInfoModel.crewDutyAssignment_model>>();
		Map<String, String> crewlistExtIdMap = getCrewListIDFromCrewDutyMB(crewdutyList);
		for(MB_RESTRequestInfoModel.crewDutyAssignment_model crewduty : crewdutyList){
			String crewlistExtId = crewlistExtIdMap.get(crewduty.sfdcId);
			crewduty.sfdcId = crewlistExtId;
			if(crewdutyListMapByFlight.get(crewduty.fltId) != null){
				crewdutyListMapByFlight.get(crewduty.fltId).add(crewduty);
			}
			else{
				crewdutyListMapByFlight.put(crewduty.fltId, new List<MB_RESTRequestInfoModel.crewDutyAssignment_model>{crewduty});
			}
		}

		Set<String> flightIdSet = crewdutyListMapByFlight.keySet();
		List<Flight__c> flightList = [SELECT Id, Name, Sector__c, Flight_Date_LT__c, Flight_External_ID__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet];
		List<Crew_List__c> crewToBeUpdate = new List<Crew_List__c>();
		List<BE8_ApplicationLogWrapper> applogList = new List<BE8_ApplicationLogWrapper>();
		List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model> crewModelToBeUpdateToTHAI = new List<CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model>();

		for(Flight__c flight : flightList){
			List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutyOnFlightList = crewdutyListMapByFlight.get(flight.Id);
			for(MB_RESTRequestInfoModel.crewDutyAssignment_model crew : crewdutyOnFlightList){
				Crew_List__c crewList = new Crew_List__c();
				crewList.Duty_Assignment__c = crew.newDuty;
				crewList.Id = crew.sfdcId;
				crewToBeUpdate.add(crewList);

				CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model crewmodel = new CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignment_Model();
				crewmodel.cabinduty = crew.newDuty != null ? crew.newDuty : null;
				crewmodel.fltDateLT = flight.Flight_Date_LT__c != null ? BE8_DateUtility.convertToTGFlightDateformat(flight.Flight_Date_LT__c, '-') : null;
				crewmodel.perno = crew.perno != null ? crew.perno : null;
				crewmodel.remark = crew.perno != null && flight.Name != null ? 'Flight: ' + flight.Name + ' | Duty of crew no. ' + crew.perno + ' is chenged from ' + crew.oldDuty + ' to ' + crew.newDuty : null;
				crewmodel.sector = flight.Sector__c != null ? flight.Sector__c.remove('-') : null;
				crewmodel.updtstatus = crew.updtstatus != null ? crew.updtstatus : 'A';
				crewmodel.fltno = flight.Flight_Number__c.contains('TG') ? flight.Flight_Number__c.remove('TG') : flight.Flight_Number__c.remove('tg');

				crewModelToBeUpdateToTHAI.add(crewmodel);

				String logMessage = 'Old Duty: ' + crew.oldDuty + '\n';
				logMessage += 'New Duty: ' + crew.newDuty + '\n';
				logMessage += 'Personal Number: ' + crew.perno + '\n';
				logMessage += crewmodel.remark + '\n';
				logMessage += 'Update Status: ' + crew.updtstatus;

				AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, CLASS_NAME, 'updateCrewDutyAssignment', crew.sfdcId, 'Flight: ' + flight.Name + ' | ' + 'Crew Personel Number: ' + crew.perno, logMessage, null, null, null);
			}
		}
		//web service callout
		CSE_SOAPCrewDutyAssignment_WS ws = new CSE_SOAPCrewDutyAssignment_WS();
		CSE_SOAPCrewDutyAssignment_WS.WS_CrewDutyAssignmentResponse_Model response = ws.callout(crewModelToBeUpdateToTHAI);
		System.debug('JK: crewToBeUpdate - ' + JSON.serialize(crewToBeUpdate));
		Database.SaveResult[] updateResult =  Database.update(crewToBeUpdate, false);
		for(Database.SaveResult result : updateResult){
			if(!result.isSuccess()){
				AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, CLASS_NAME, 'updateCrewDutyAssignment', result.getId(), 'Crew List SFDC: ' + result.getId(), String.valueOf(result.getErrors()), null, null, null);
			}
		}
		AppLogger.insertLogs();
		AppLogger.insertLogModel();
		//BE8_GlobalUtility.logMessage(applogList);
		/**
			DEBUG SESSION
		*/
		System.debug('Input List: ' + crewdutyList);
		System.debug('Crew Duty List Map By Flight: ' + crewdutyListMapByFlight);
		System.debug('Flight Id Set: ' + flightIdSet);
		System.debug('Flight List Size: ' + flightList.size());
		for(Flight__c flight : flightList){
			System.debug(flight);
		}

		System.debug('App Log List Size: ' + applogList.size());
		for(BE8_ApplicationLogWrapper applog : applogList){
			System.debug(applog);
		}

		return response;
	}

	public static Map<String, String> getCrewListIDFromCrewDutyMB(List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewdutyList){
		Set<String> externalIdSet = new Set<String>();
		Map<String, String> returnMap = new Map<String, String>();
		for(MB_RESTRequestInfoModel.crewDutyAssignment_model crewduty : crewdutyList){
			externalIdSet.add(crewduty.sfdcId);
		}
		List<Crew_List__c> crewlistList = [SELECT Id, Crew_External_Id__c FROM Crew_List__c WHERE Crew_External_Id__c IN :externalIdSet];
		for(Crew_List__c c : crewlistList){
			returnMap.put(c.Crew_External_ID__c, c.Id);
		}

		return returnMap;
	}
}