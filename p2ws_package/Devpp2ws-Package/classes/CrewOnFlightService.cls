public with sharing class CrewOnFlightService {
	private static String CLASS_NAME = 'CrewOnFlightService';

	public static Crew__c createCrew(Crew_List__c crewlist) {
		String[] crewName = crewlist.Name.split(' ');
		String crewId = crewlist.Crew_Temp__c;
		Crew__c newCrew = new Crew__c(
		    Personel_Id__c = crewId,
		    Rank__c = crewlist.Rank__c);

		if (crewName.size() == 1) {
			newCrew.Name = crewName[0];
			newCrew.Crew_First_Name__c = crewName[0];
		} else if (crewName.size() > 1) {
			newCrew.Name = crewName[0] + ' ' + crewName[1];
			newCrew.Crew_First_Name__c = crewName[0];
			newCrew.Crew_Last_Name__c = crewName[1];
		}
		return newCrew;
	}

	public static Flight__c createFlight(String[]  flightInfo, String flightExternalId) {
		String flightNo = flightInfo[0].substring(2, flightInfo[0].length());
		//String flightDate = BE8_DateUtility.convertTGFlightDateformat(flightInfo[1]);
		Integer legNo = Integer.valueOf(flightInfo[2]);
		return new Flight__c(
		           Name = flightNo,
		           //Flight_Date_UTC__c = flightDate,
		           Flight_Date_UTC__c = flightInfo[1],
		           Leg_Number__c = legNo,
		           Flight_External_ID__c = flightExternalId,
		           Integration_Source__c = '2');
	}

	public static List<Crew_List__c> getCrewListFromDataModel(WS_CrewonFlightModel crewmodel, String flightExternalId) {
		List<Crew_List__c> crewlist = new List<Crew_List__c>();
		if (crewmodel.CrewOnFlightQueryRes != null && crewmodel.CrewOnFlightQueryRes.return_Z != null) {
			Integer crewlistNo = crewmodel.CrewOnFlightQueryRes.return_Z.size();
			//String evaLastDate = null;
			//Integer evanum = 0;
			for (Integer i = 0; i < crewlistNo; i++) {
				Integer evanum = 0;
				String evaLastDate = null;
				//System.debug('input eva date: ' + crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaLastDate);
				if (crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaLastDate != '-' && crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaLastDate != null) {
					evaLastDate = BE8_DateUtility.convertTGFlightDateformat(crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaLastDate, null);
				}
				if (crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaNum != '-' && crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaNum != null) {
					evanum = Integer.valueOf(crewmodel.CrewOnFlightQueryRes.return_Z.get(i).evaNum);
				}
				//System.debug('eva Date: ' + evaLastDate);
				System.debug('Seq No: ' + crewmodel.CrewOnFlightQueryRes.return_Z.get(i).seqNo);
				Crew_List__c crewonflight = new Crew_List__c(
				    Name = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).firstname + ' ' + crewmodel.CrewOnFlightQueryRes.return_Z.get(i).lastname,
				    Nickname__c = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).nickname,
				    Acting_Rank__c = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).actrank,
				    CrewList_Temp__c = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).staffno + '_' + flightExternalId,
				    Crew_Temp__c = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).staffno,
				    SEQ_No__c = Integer.valueOf(crewmodel.CrewOnFlightQueryRes.return_Z.get(i).seqNo),
				    Duty_Code__c = crewmodel.CrewOnFlightQueryRes.return_Z.get(i).dutycode,
				    Flight_Temp__c = flightExternalId,
				    POS_Fly__c = crewmodel.CrewonFlightQueryRes.return_Z.get(i).posfly,
				    Rank__c = crewmodel.CrewonFlightQueryRes.return_Z.get(i).rank,
				    //Last_EVAL__c = evaLastDate != null ? Date.valueOf(evaLastDate) : null,
				    No_of_Eval__c = evanum,
				    Language__c = crewmodel.CrewonFlightQueryRes.return_Z.get(i).thirdlang,
				    Duty_Assignment__c = crewmodel.CrewonFlightQueryRes.return_Z.get(i).dutyassign != null ? crewmodel.CrewonFlightQueryRes.return_Z.get(i).dutyassign.trim() : null,
				    Gender__c = crewmodel.CrewonFlightQueryRes.return_Z.get(i).gender
				);
				if (evaLastDate != null) {
					crewonflight.Last_EVAL__c = Date.valueOf(evaLastDate);
				}
				if (crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltno != null && crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltno != '') {
					String fnumber = 'TG' + Integer.valueOf(crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltno);
					crewonflight.returnfltno__c = fnumber;
				}
				if (crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltdate != null && crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltdate != '') {
					crewonflight.returnfltdate__c = BE8_DateUtility.convertTGFlightDateformat(crewmodel.CrewonFlightQueryRes.return_Z.get(i).returnfltdate, null);
				}
				crewlist.add(crewonflight);
			}
		} else {
			//BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'getCrewListFromDataModel', BE8_GlobalConstants.LEVEL_DEBUG, 'No Crew List found.', flightExternalId, PreFlightBatch.applicationLogCache);
			AppLogger.debug(CLASS_NAME, 'getCrewListFromDataModel', flightExternalId, 'No Crew List found.', null);
		}
		return crewlist;
	}



	public static List<Crew_List__c> updateCrew(Flight__c pFlight, Boolean isRetrialWithPreviousFlight) {
		//WS_CrewonFlightModel crewOnFlightModel = new CSE_SOAPCREWONFLIGHT_WS().getCrewonFlight('10Sep16', '0930', 'BKK', 'CDG');
		//List<Crew_List__c> crewlist = getCrewListFromDataModel(crewOnFlightModel, 'TG0930_10Sep16_1');
		System.debug('updateCrew');
		System.debug('pFlight: ' + pFlight + ' isRetrialWithPreviousFlight: ' + isRetrialWithPreviousFlight);
		String strFlightNumber = null;
		if (isRetrialWithPreviousFlight) {
			strFlightNumber = pFlight.Change_Flight_Number__c;
		} else {
			strFlightNumber = pFlight.Flight_Number__c;
		}
		strFlightNumber = strFlightNumber.replace('TG', '');

		String strFlightDate = null;
		//if (isRetrialWithPreviousFlight) {
		//	strFlightDate = BE8_DateUtility.convertToTGFlightDateformat(pFlight.Change_Flight_Date_UTC__c, '-');
		//} else {
			strFlightDate = pFlight.STD_UTC__c != null && pFlight.STD_UTC__c != '' ? BE8_DateUtility.convertToTGFlightDateformat(pFlight.STD_UTC__c.split(' ').get(0), '-') : BE8_DateUtility.convertToTGFlightDateformat(pFlight.Flight_Date_UTC__c, '-');
		//}

		// UTC Version
		//if (isRetrialWithPreviousFlight) {
		//	strFlightDate = BE8_DateUtility.convertToTGFlightDateformat(pFlight.Change_Flight_Date_UTC__c, '-');
		//} else {
		//	strFlightDate = BE8_DateUtility.convertToTGFlightDateformat(pFlight.Flight_Date_UTC__c, '-');
		//}

		String strKey = null;
		if (pFlight.Flight_External_ID__c != null) {
			strKey = pFlight.Flight_External_ID__c;
		} else {
			strKey = pFlight.Flight_Number__c + '_' + strFlightDate + '_' + pFlight.Leg_Number__c;
		}
		System.debug('Crew on flight string :' + strKey + ' flightNum :' + strFlightNumber);
		List<Crew_List__c> crewlist = null;
		try {
			System.debug('Get Crew on Flight strFlightDate:' + strFlightDate + ' strFlightNumber:' + strFlightNumber);
			WS_CrewonFlightModel crewOnFlightModel = new CSE_SOAPCREWONFLIGHT_WS().getCrewonFlight(strFlightDate, strFlightNumber, pFlight.Departure_STN__c, pFlight.Arrival_STN__c);
			crewlist = getCrewListFromDataModel(crewOnFlightModel, strKey);
			Set<String> crewPersonnelNoList = BE8_GlobalUtility.getStringSet('Personnel_ID__c', crewlist);
			AppLogger.debug(CLASS_NAME, 'updateCrew', JSON.serialize(crewPersonnelNoList), pFlight.Flight_External_Id__c, null);
		} catch (Exception e) {
			String message = 'Get Crew on Flight from Flight Date: ' + strFlightDate + ' Flight Number: ' + strFlightNumber + ' Departure: ' + pFlight.Departure_STN__c + ' Arrival: ' + pFlight.Arrival_STN__c + '\n' + e.getMessage();
			//BE8_GlobalUtility.cacheLogMessage(CLASS_NAME, 'updateCrew', BE8_GlobalConstants.LEVEL_DEBUG, message, pFlight.Id, PreFlightBatch.applicationLogCache);
			AppLogger.error(CLASS_NAME, 'updateCrew', pFlight.Flight_External_Id__c, message, e);
		}
		//if(crewlist != null){
		//	insert crewlist;
		//}
		return crewlist;
	}
}