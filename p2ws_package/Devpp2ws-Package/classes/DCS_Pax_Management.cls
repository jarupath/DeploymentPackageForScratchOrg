public without sharing class DCS_Pax_Management {
	public static void syncDCS(Flight__c flight, List<Map<String, String>> filterListMap, List<String> groupIndicator, Boolean isPSTCall, String jobName){
		String carrier = DCS_Pax_Util_Service.getFlightCarrier(flight.Flight_Number__c);
		String fltNo = DCS_Pax_Util_Service.getFlightNo(flight.Flight_Number__c);
		String fltDate = DCS_Pax_Util_Service.getSTDLT(flight.STD_LT__c);
		String boardPoint = flight.Departure_STN__c;

		//if variable if null => log

		WS_DCS_Pax_Model dcsPaxModel = getDCSPaxModel(filterListMap, groupIndicator, carrier, fltNo, fltDate, boardPoint);

		if(dcsPaxModel == null){

		}
		else {
			Map<String, object> infoMap = prepareData(dcsPaxModel, flight, isPSTCall);
			Map<String, object> resultMap = DCS_Pax_Util_Service.updateToDB(infoMap);
			if(resultMap != null && !resultMap.isEmpty()) logAfterSync(infoMap, resultMap, jobName);
			AppLogger.insertLogModel();
			AppLogger.insertLogs();
		}
	}

	public static void logAfterSync(Map<String, object> infoMap, Map<String, object> resultMap, String jobName){
		DCS_Pax_Log_Service.setJobName(jobName);
		System.debug('resultMap.containsKey(ACC-RESULT): ' + resultMap.containsKey('ACC-RESULT'));
		System.debug('resultMap.containsKey(TRA-RESULT): ' + resultMap.containsKey('TRA-RESULT'));
		System.debug('resultMap.containsKey(MEM-RESULT): ' + resultMap.containsKey('MEM-RESULT'));
		System.debug('resultMap.containsKey(PAX-RESULT): ' + resultMap.containsKey('PAX-RESULT'));
		System.debug('resultMap.containsKey(DEL-RESULT): ' + resultMap.containsKey('DEL-RESULT'));
		if(resultMap.containsKey('ACC-RESULT')) DCS_Pax_Log_Service.logUpsert(infoMap.get('ACCOUNT'), resultMap.get('ACC-RESULT'), 'Account');
		if(resultMap.containsKey('TRA-RESULT')) DCS_Pax_Log_Service.logUpsert(infoMap.get('TRAVELDOC'), resultMap.get('TRA-RESULT'), 'Travel_Document__c');
		if(resultMap.containsKey('MEM-RESULT')) DCS_Pax_Log_Service.logUpsert(infoMap.get('MEMBERSHIP'), resultMap.get('MEM-RESULT'), 'Membership__c');
		if(resultMap.containsKey('PAX-RESULT')) DCS_Pax_Log_Service.logUpsert(infoMap.get('PAX'), resultMap.get('PAX-RESULT'), 'Passenger__c');
		if(resultMap.containsKey('DEL-RESULT')) DCS_Pax_Log_Service.logDelete(infoMap.get('DELETE-PAX'), resultMap.get('DEL-RESULT'), 'Passenger__c');
	}

	public static WS_DCS_Pax_Model getDCSPaxModel(List<Map<String, String>> filterListMap, List<String> groupIndicator, String carrier, String fltNo, String fltDate, String boardPoint){
		WS_DCS_Pax_Model dcsPaxModel = null;
		CSE_SOAPDCSPax_WS ws = new CSE_SOAPDCSPax_WS();
		String response = ws.getPax(filterListMap, groupIndicator, carrier, fltNo, fltDate, boardPoint);
		if(response != null) dcsPaxModel = ws.getPaxModel(response);
		return dcsPaxModel;
	}

	public static Map<String, object> prepareData(WS_DCS_Pax_Model dcspaxmodel, Flight__c flight, Boolean isPSTCallout){
		Map<String, object> returnMap = new Map<String, object>();
		Map<String, Passenger__c> paxMap = getPaxMapFromModel(dcspaxmodel, flight);
		Map<String, Passenger__c> paxMapSFDC = DCS_Pax_Util_Service.getCurrentPaxMap(flight);
		List<Passenger__c> paxListDelete = null;
		if(!isPSTCallout)paxListDelete = DCS_Pax_Util_Service.getPaxListToDelete(paxMap, paxMapSFDC);
		DCS_Pax_Util_Service.updateDCSPaxIdFromPaxSFDC(paxMap, paxMapSFDC);
		Map<String, Account> accGenerateMap = updatePaxAccount(paxMapSFDC, paxMap);
		Map<String, Membership__c> membershipGenerateMap = updateMembership(accGenerateMap, paxMap);
		List<Travel_Document__c> travelDocList = updateTravelDocument(accGenerateMap, paxMap);

		returnMap.put('ACCOUNT', accGenerateMap);
		returnMap.put('PAX', paxMap);
		returnMap.put('TRAVELDOC', travelDocList);
		returnMap.put('MEMBERSHIP', membershipGenerateMap);
		returnMap.put('DELETE-PAX', paxListDelete);

		System.debug('Pax Map FROM DCS Model');
		System.debug(JSON.serialize(paxMap));
		if(paxMap != null)System.debug('Pax Map Size FROM DCS Model: ' + paxMap.size());
		System.debug('Pax Map FROM SFDC Record');
		System.debug(JSON.serialize(paxMapSFDC));
		if(paxMapSFDC != null)System.debug('Pax Map Size FROM SFDC Model: ' + paxMapSFDC.size());
		System.debug('Pax List to Delete');
		System.debug(JSON.serialize(paxListDelete));
		if(paxListDelete != null)System.debug('Pax List to Delete Size: ' + paxListDelete.size());
		System.debug('Account Map FROM DCS Model');
		System.debug(JSON.serialize(accGenerateMap));
		System.debug('Membership Map FROM DCS Model');
		System.debug(JSON.serialize(membershipGenerateMap));
		System.debug('Travel Document List FROM DCS Model');
		System.debug(JSON.serialize(travelDocList));

		return returnMap;
	}

	public static Map<String, Account> updatePaxAccount(Map<String, Passenger__c> sfdcPaxMap, Map<String, Passenger__c> paxmap){
		Map<String, Account> accmap = new Map<String, Account>();
		if(paxmap != null && !paxmap.isEmpty()){
			accmap = DCS_Pax_Record_Service.concreteAccount(sfdcPaxMap, paxmap);
		}
		if(accmap != null && !accmap.isEmpty()) return accmap;
		return null;
	}

	public static List<Travel_Document__c> updateTravelDocument(Map<String, Account> accmap, Map<String, Passenger__c> paxmap){
		List<Travel_Document__c> returnlist = new List<Travel_Document__c>();
		if(accmap != null && !accmap.isEmpty() && paxmap != null && !paxmap.isEmpty()){
			List<Passenger__c> paxlist = DCS_Pax_Record_Service.getPaxListToCreateTravelDoc(accmap.keySet(), paxmap);
			returnlist = DCS_Pax_Record_Service.concreteTravelDoc(paxList);
		}
		if(returnlist != null && !returnlist.isEmpty()) return returnlist;
		return null;
	}

	public static Map<String, Membership__c> updateMembership(Map<String, Account> accmap, Map<String, Passenger__c> paxmap){
		Map<String, Membership__c> returnmap = new Map<String, Membership__c>();
		if(accmap != null && !accmap.isEmpty() && paxmap != null && !paxmap.isEmpty()){
			Map<String, Passenger__c> returnpaxmap = DCS_Pax_Record_Service.getPaxMapToCreateMembership(accmap.keySet(), paxmap);
			returnmap = DCS_Pax_Record_Service.concreteMembership(returnpaxmap);
		}
		if(returnmap != null && !returnmap.isEmpty()) return returnmap;
		return null;
	}

	public static Map<String, Passenger__c> getPaxMapFromModel(WS_DCS_Pax_Model dcspaxmodel, Flight__c flight){
		Map<String, Passenger__c> odspaxmap = DCS_Pax_Util_Service.getCurrentPaxMap(flight);
		List<WS_DCS_Pax_Model.cls_customerLevel> paxModelList = DCS_Pax_Model_Handler.getCustomerLevelList(dcspaxmodel);
		List<Passenger__c> paxList = new List<Passenger__c>();
		if(paxModelList != null){
			WS_DCS_Pax_Model.cls_flightDetailsGroup flightInfoModel = dcspaxmodel.flightDetailsGroup;
			Flight__c flightInfo = DCS_Pax_Record_Service.getFlight(flightInfoModel);
			for(WS_DCS_Pax_Model.cls_customerLevel paxmodel : paxModelList){
				if(!DCS_Pax_Model_Service.isInfant(paxmodel)){
					Passenger__c pax = new Passenger__c();
					pax.FlightId__c = flight.Id;
					DCS_Pax_Record_Service.getPaxBasicInfo(pax, paxModel);
					DCS_Pax_Record_Service.getPaxConnectingFlight(pax, paxModel);
					DCS_Pax_Record_Service.getPaxTicketInfo(pax, paxModel);
					DCS_Pax_Record_Service.getPaxSSR(pax, paxModel);
					DCS_Pax_Record_Service.updatePaxWSKey(pax, odspaxmap, flight);
					paxList.add(pax);
				}
			}
		}
		
		//can not used WS_Key__c  to generate key any more
		if(paxlist != null && !paxlist.isEmpty()) return DCS_Pax_Util_Service.getPaxMapByGenerateKey(paxlist);
		return null;
	}

	public static Map<String, Passenger__c> getPaxMapFromModel(Map<String, Passenger__c> paxmap, WS_DCS_Pax_Model dcspaxmodel, Flight__c flight){
		Map<String, Passenger__c> odspaxmap = DCS_Pax_Util_Service.getCurrentPaxMap(flight);
		List<WS_DCS_Pax_Model.cls_customerLevel> paxModelList = DCS_Pax_Model_Handler.getCustomerLevelList(dcspaxmodel);
		List<Passenger__c> paxList = new List<Passenger__c>();
		if(paxModelList != null){
			WS_DCS_Pax_Model.cls_flightDetailsGroup flightInfoModel = dcspaxmodel.flightDetailsGroup;
			Flight__c flightInfo = DCS_Pax_Record_Service.getFlight(flightInfoModel);
			for(WS_DCS_Pax_Model.cls_customerLevel paxmodel : paxModelList){
				if(!DCS_Pax_Model_Service.isInfant(paxmodel)){
					Passenger__c pax = null;
					String paxmodelkey = DCS_Pax_Util_Service.getDCSPaxGenerateKey(paxmodel, flight);
					if(paxmap != null && !paxmap.isEmpty() && paxmodelkey != null && paxmap.containsKey(paxmodelkey))
						pax = paxmap.get(paxmodelkey);
					else pax = new Passenger__c();
					DCS_Pax_Record_Service.getPaxBasicInfo(pax, paxModel);
					DCS_Pax_Record_Service.getPaxConnectingFlight(pax, paxModel);
					DCS_Pax_Record_Service.getPaxTicketInfo(pax, paxModel);
					DCS_Pax_Record_Service.getPaxSSR(pax, paxModel);
					//DCS_Pax_Record_Service.updatePaxWSKey(pax, odspaxmap, flight);
					paxList.add(pax);
				}
			}
		}
		
		if(paxlist != null && !paxlist.isEmpty()) return DCS_Pax_Util_Service.getPaxMapByGenerateKey(paxlist);
		return null;
	}
}