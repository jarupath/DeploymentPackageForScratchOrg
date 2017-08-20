/*
	This class is used to manage response from new pax list[DCS] web serivce in order to merge response with
	response from ods web service
	Method List - Description
	- getPaxMapWithKey - Create passenger map by generate key from input passenger list
	- getKeyFromWSKey - Generate key from passenger WS_Key__c that used to compare data 
						between data from ods and dcs
	- getKey - Generate key from passenger data of dcs that used to compare data 
						between data from ods and dcs
	- updatePaxConnectingFltInfoAndTkt - Update passenger data from ods with connecting flight, 
										 e-ticket info, and travel class that get from dcs
	- getFlightSTD - get flight std from response data from dcs
	- getDateTimeFormat - concatinate datetime data with '.000Z'
*/
public with sharing class New_Pax_List_Management {
	public static final String CLASS_NAME = 'New_Pax_List_Management';
	public static Map<String, Passenger__c> getPaxMapWithKey(List<Passenger__c> paxlist){
		Map<String, Passenger__c> returnMap = new Map<String, Passenger__c>();
		for(Passenger__c pax : paxlist){
			String key = getKeyFromWSKey(pax.WS_KEY__c);
			returnMap.put(key, pax);
		}

		return returnMap;
	}

	public static String getKeyFromWSKey(String wskey){
		Map<String, String> returnMap = new Map<String, String>();
		List<String> wsobj = wskey.split('_');
		String key = '';
		try{
			String fltNo = String.valueOf(Integer.valueOf(wsobj.get(0)));
			String fltDate = wsobj.get(1);
			String fname = wsobj.get(2).replaceAll(' ', '');
			String lname = wsobj.get(3);
			String pnr = wsobj.get(4);
			String legNo = wsobj.get(5);
			key = fltNo + '_' + fltDate + '_' + fname + '_' + lname + '_' + pnr + '_' + legNo;
			key = key.replace(' ', '');
		}
		catch(Exception e){
			AppLogger.error(CLASS_NAME, 'getKeyFromWSKey', wskey, e.getMessage(), e);
		}

		return key.toLowerCase();
	}

	public static String getKey(String fltNo, String fltDate, String fname, String lname, String pnr, String legNo){
		String key = fltNo + '_' + fltDate + '_' + fname + '_' + lname + '_' + pnr + '_' + legNo;
		key = key.toLowerCase();
		key = key.replaceAll(' ', '');
		return key;
	}

	public static Map<String, Passenger__c> updatePaxConnectingFltInfoAndTkt(List<Passenger__c> paxList, Flight__c flight, WS_New_Pax_List_Model newPaxListModel){
		System.debug('JK: updatePaxConnectingFltInfo');
		System.debug(JSON.serialize(paxList));
		System.debug(JSON.serialize(newPaxListModel.flightDetailsGroup.customerLevel));
		
		List<Map<String, String>> filterListMap = new List<Map<String, String>>();
		List<String> groupIndicator = new List<String>();
		groupIndicator.add('OFD');

		Map<String, Passenger__c> paxMap = getPaxMapWithKey(paxList);
		System.debug('JK: PaxMap');
		System.debug(JSON.serialize(paxMap));
		String flightNo = flight.Flight_Number__c.remove('TG');
		flightNo = String.valueOf(Integer.valueOf(flightNo));
		//CSE_SOAPNewPaxList_WS ws = new CSE_SOAPNewPaxList_WS();
		//WS_New_Pax_List_Model newPaxListModel = ws.getPaxModel(null, groupIndicator, 'TG', flightNo, flight.Flight_Date_UTC__c, flight.Departure_STN__c);

		List<WS_New_Pax_List_Model.cls_customerLevel> paxDcsList = newPaxListModel.flightDetailsGroup.customerLevel;
		WS_New_Pax_List_Model.cls_legDetails legDetail = newPaxListModel.flightDetailsGroup.legDetails;
		System.debug(paxDcsList);
		for(WS_New_Pax_List_Model.cls_customerLevel pax : paxDcsList){ 
			WS_New_Pax_List_Model.cls_otherFlightInfo connectingflt = pax.otherFlightInfo != null && !pax.otherFlightInfo.isEmpty() ? pax.otherFlightInfo.get(0) : null;
			WS_New_Pax_List_Model.cls_customerData paxData = pax != null ? pax.customerData : null;
			WS_New_Pax_List_Model.cls_documentDetails ticketInfo = pax.productLevel.TktInfo != null ? pax.productLevel.TktInfo.Tkt.documentDetails : null;
			
			String fname = '';
			if(paxData != null && paxData.otherPaxDetails != null){
				if(paxData.otherPaxDetails.title != null){
					fname = (paxData.otherPaxDetails.givenName + paxData.otherPaxDetails.title).replaceAll(' ', '');
				}
				else{
					fname = (paxData.otherPaxDetails.givenName).replaceAll(' ', '');
				}
			}
			else{
				System.debug('JK: NTBA');
				System.debug(JSON.serialize(pax));
			}
			//String fname = paxData.otherPaxDetails.title != null ? (paxData.otherPaxDetails.givenName + paxData.otherPaxDetails.title).replaceAll(' ', '') : (paxData.otherPaxDetails.givenName).replaceAll(' ', '');
			String lname = paxData.paxDetails.surname;
			String fltNo = legDetail.flightDetails.flightNumber;
			String fltDate = legDetail.departureDate;
			String pnr = pax.productLevel.sbrRecordLocator.reservation.controlNumber;
			String key = getKey(fltNo, fltDate, fname, lname, pnr, String.valueOf(flight.Leg_Number__c));

			System.debug('JK: Debug - connectingflt');
			System.debug(JSON.serialize(connectingflt));
			System.debug('key: ' + key);
			if(paxMap.get(key) != null){
				System.debug(JSON.serialize(pax));
				if(connectingflt!= null){
					System.debug('pax: ' + paxMap.get(key));
					System.debug('fltNo: ' + connectingflt.otherFlightData.flightIdentification.flightNumber);
					System.debug('fltDate: ' + connectingflt.otherFlightData.flightDate.departureDate);
					System.debug('segment: ' + connectingflt.otherFlightData.boardPointDetails + '-' + connectingflt.otherFlightData.offpointDetails);
					System.debug('STD: ' + getFlightSTD(connectingflt.timeData));
					paxMap.get(key).Connecting_Flight__c = connectingflt.otherFlightData.companyDetails.marketingCompany + connectingflt.otherFlightData.flightIdentification.flightNumber;
					paxMap.get(key).Connecting_Date__c = connectingflt.otherFlightData.flightDate.departureDate;
					paxMap.get(key).Connecting_Segment__c = connectingflt.otherFlightData.boardPointDetails.trueLocnId + '-' + connectingflt.otherFlightData.offpointDetails.trueLocnId;
					paxMap.get(key).Connecting_STD__c = getFlightSTD(connectingflt.timeData);
				}
				if(ticketInfo != null){
					paxMap.get(key).Ticket_Number__c = ticketInfo.number_z;
					paxMap.get(key).Ticket_Type__c = ticketInfo.type_z;
				}
				if(pax.legCabinCode != null && pax.legCabinCode.cabinDetails != null){
					System.debug('JK: Cabin Code From: ' + paxMap.get(key).Cabin_Code__c);
					System.debug('JK: Cabin Code To: ' + pax.legCabinCode.cabinDetails.classDesignator);
					paxMap.get(key).Cabin_Code__c = pax.legCabinCode.cabinDetails.classDesignator;
				}
			}
		}
		Map<String, Passenger__c> returnMap = new Map<String, Passenger__c>();
		for(Passenger__c pax : paxMap.values()){
			returnMap.put(pax.WS_KEY__c, pax);
		}

		System.debug('JK: paxMap - after update');
		System.debug(paxMap);

		return returnMap;
	}

	public static String getFlightSTD(List<WS_New_Pax_List_Model.cls_timeData> timeList){
		String returnStr = '';
		for(WS_New_Pax_List_Model.cls_timeData t : timeList){
			if(t.businessSemantic == 'STD'){
				returnStr = t.dateTime_z;
				break;
			}
		}

		return getDateTimeFormat(returnStr);

	}

	public static String getDateTimeFormat(String dtime){
		//List<String> dtimeSplit = dtime.split('T');
		//return dtimeSplit.get(0) + ' ' + dtimeSplit.get(1);
		return dtime + '.000Z';
	}
}