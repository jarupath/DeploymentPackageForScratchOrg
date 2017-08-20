/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   Restful API to inquiry information from SFDC

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/08/2016  Charnun.T           First Create
------------------------------------------------------------*/
@RestResource(urlMapping = '/flight/*')
global without sharing class MB_RESTFlightService {
	/*
	SELECT Id, FlightId__c, FlightId__r.Name FROM Crew_List__c WHERE CrewId__c = 'a0CN000000Axz2Z' AND FlightId__r.Departed__c = false AND FlightId__r.STD_UTC_DateTime__c != null ORDER BY FlightId__r.STD_UTC_DateTime__c DESC LIMIT 2

	Query to check flights that are attached to this crew
	*/
	private static String cabinDutyQuery = 'SELECT Aircraft_Type__c, Cabin_Duty__c FROM Aircraft__c WHERE Aircraft_Type__c IN :';
	@HttpGet
	global static List<MB_RestResponseInfoModel.flightInfo_model> getFlightInfo() {
		Id currentUserId = UserInfo.getUserId();
		User currentUser = [SELECT Id, Name FROM User WHERE Id = :currentUserId LIMIT 1];
		Crew__c currentCrew = [SELECT Id, Name FROM Crew__c WHERE Id = :BE8_GlobalUtility.getCrewIdByUserId(currentUserId) LIMIT 1];

		List<MB_RestResponseInfoModel.flightInfo_model> flightInfoList = new List<MB_RestResponseInfoModel.flightInfo_model>();
		Crew_Mapping__c crewMapping = BE8_GlobalUtility.getCurrentCrewMapping(currentUserId);
		Id currentUserCrewId = crewMapping.CrewId__c;
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(currentUserId);
		System.debug('flightIdSet: ' + flightIdSet);
		List<Flight__c> flightList = [SELECT Id, Flight_Region__c, Codeshare__c, AircraftId__r.Aircraft_Name_TH__c, AircraftId__r.Cabin_Duty__c, AircraftId__r.Aircraft_Name_EN__c, AircraftId__r.Aircraft_Description__c, AircraftId__r.Cabin_Ver__c, Booking_Passengers__c, Last_Sync_Time__c, LastModifiedDate, Arrival_STN_Name__c, Departure_STN_Name__c, Flight_External_ID__c, Flight_Number__c, Flight_Date_UTC__c, Flight_Date_LT__c, Origin__c, Destination__c, Leg_Number__c, Aircraft_Type__c, Aircraft_Configuration__c, AircraftId__r.Name, Aircraft_Description__c, Departure_STN__c, Arrival_STN__c, STD_UTC__c, STD_LT__c, ETD_UTC__c, ETD_LT__c, STA_UTC__c, STA_LT__c, ETA_UTC__c, ETA_LT__c, Block_Time__c, Gate__c, Next_Flight_Number__c, Next_Flight_STD_UTC_DateTime__c, Departure_Delay_DateTime__c, (SELECT Id, Nickname__c, CrewId__r.Crew_Title__c, CrewId__r.Crew_First_Name__c, CrewId__r.Crew_Last_Name__c, CrewId__r.Crew_Type__c, Rank__c, Acting_Rank__c, Duty_Assignment__c, Duty_Code__c, Language__c, POS_Fly__c, No_of_Eval__c, CrewId__r.Personel_Id__c, SEQ_No__c, returnfltdate__c, returnfltno__c, Gender__c, Last_EVAL__c FROM Crews__r), (SELECT Id, Cabin_Code__c, Checkin_Seat__c FROM Passengers__r) FROM Flight__c WHERE Id IN :flightIdSet ORDER BY STD_UTC_DateTime__c ASC];
		Set<String> flightExternalIdSet = BE8_GlobalUtility.getStringSet('Flight_External_ID__c', flightList);

		Set<String> aircraftDescriptionSet = BE8_GlobalUtility.getStringSet('Aircraft_Description__c', flightList);
		List<Master_Map__c> generalEquipmentList = [SELECT Id, Check_by_CA_s_station__c, Checked_Procedure__c, LOPA_Concern_Location__c, Description__c, Quantity_to_be_checked__c, Total__c, Depend_On_Value__c, Cabin_Ver__c, Depend_On_Object_Name__c, Name, Aircraft_Description__c, Equipment_Type__c, Location__c, (SELECT Id, Name, LOPA_Concern_Location__c FROM Depend_On_Object__r) FROM Master_Map__c WHERE Field_Name__c = :BE8_GlobalConstants.SERVICE_EQUIPMENT AND Aircraft_Description__c = null];
		Map<String, List<SObject>> equipmentByAircraftMap = BE8_GlobalUtility.getSObjectListMap('Aircraft_Description__c', [SELECT Id, LOPA_Concern_Location__c, Check_by_CA_s_station__c, Checked_Procedure__c, Description__c, Quantity_to_be_checked__c, Total__c, Name, Depend_On_Object_Name__c , Cabin_Ver__c, Aircraft_Description__c, Depend_On_Value__c, Equipment_Type__c, Location__c FROM Master_Map__c WHERE Aircraft_Description__c != null AND Aircraft_Description__c IN :aircraftDescriptionSet]);
		Map<String, String> cabindutyMap = getCabinDutyMap(flightList);

		for (Flight__c flight : flightList) {
			MB_RestResponseInfoModel.flightInfo_model flightModel = new MB_RestResponseInfoModel.flightInfo_model();
			flightModel.id = flight.Id;
			flightModel.fltExtId = flight.Flight_External_ID__c;
			flightModel.flightNo = flight.Flight_Number__c;
			flightModel.dateU = BE8_DateUtility.convertDateToStringForMobileApp(BE8_DateUtility.convertStringToDate(flight.Flight_Date_UTC__c));
			flightModel.dateL = BE8_DateUtility.convertDateToStringForMobileApp(BE8_DateUtility.convertStringToDate(flight.Flight_Date_LT__c));
			flightModel.origin = flight.Origin__c;
			flightModel.dest = flight.Destination__c;
			flightModel.legNo = '' + flight.Leg_Number__c;
			flightModel.acType = flight.Aircraft_Type__c;
			flightModel.acCon = flight.Aircraft_Configuration__c;
			flightModel.acReg = flight.AircraftId__r.Name;
			flightModel.model = flight.AircraftId__r.Aircraft_Description__c;
			flightModel.depSt = flight.Departure_STN__c;
			flightModel.depStF = flight.Departure_STN_Name__c;
			flightModel.arrSt = flight.Arrival_STN__c;
			flightModel.arrStF = flight.Arrival_STN_Name__c;
			flightModel.stdUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.STD_UTC__c));
			flightModel.stdLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.STD_LT__c));
			flightModel.etdUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.ETD_UTC__c));
			flightModel.etdLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.ETD_LT__c));
			flightModel.staUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.STA_UTC__c));
			flightModel.staLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.STA_LT__c));
			flightModel.etaUTC = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.ETA_UTC__c));
			flightModel.etaLT = BE8_DateUtility.convertDateTimeToStringForMobileApp(BE8_DateUtility.convertStringToDateTime(flight.ETA_LT__c));
			flightModel.ft = flight.Block_Time__c;
			flightModel.gate = flight.Gate__c;
			flightModel.nFltNo = flight.Next_Flight_Number__c;
			flightModel.nFltDTu = BE8_DateUtility.convertDateTimeToStringForMobileApp(flight.Next_Flight_STD_UTC_DateTime__c);
			flightModel.depDl = BE8_DateUtility.convertDateTimeToStringForMobileApp(flight.Departure_Delay_DateTime__c);
			flightModel.lastM = BE8_DateUtility.convertDateTimeToStringForMobileApp(flight.Last_Sync_Time__c);
			flightModel.lastS = BE8_DateUtility.convertDateTimeToStringForMobileApp(crewMapping.Last_Sync_Time__c);
			flightModel.acName = flight.AircraftId__r.Aircraft_Name_EN__c;
			flightModel.acNameTH = flight.AircraftId__r.Aircraft_Name_TH__c;
			flightModel.codeShare = flight.Codeshare__c;
			flightModel.bookingPax = flight.Booking_Passengers__c;
			flightModel.acceptedPax = getAcceptedPax(flight.Passengers__r);
			flightModel.region = flight.Flight_Region__c;

			if(flight.AircraftId__c != null || cabindutyMap != null){
				if(flight.AircraftId__r.Cabin_Duty__c != null){
					flightModel.duty = flight.AircraftId__r.Cabin_Duty__c.split(',');
				}
				else if(flight.Aircraft_Type__c != null && cabindutyMap.containsKey(flight.Aircraft_Type__c)){
					flightModel.duty = cabindutyMap.get(flight.Aircraft_Type__c).split(',');
				}
			}


			flightModel.crewL = new List<MB_RestResponseInfoModel.crewL_model>();
			for (Crew_List__c cl : flight.Crews__r) {
				MB_RestResponseInfoModel.crewL_model crewListModel = new MB_RestResponseInfoModel.crewL_model();
				crewListModel.id = cl.CrewId__r.Personel_Id__c;
				crewListModel.title = cl.CrewId__r.Crew_Title__c;
				crewListModel.firstN = cl.CrewId__r.Crew_First_Name__c;
				crewListModel.lastN = cl.CrewId__r.Crew_Last_Name__c;
				crewListModel.nickN = cl.Nickname__c;
				crewListModel.type = cl.CrewId__r.Crew_Type__c;
				crewListModel.rank = cl.Rank__c;
				crewListModel.aRank = cl.Acting_Rank__c;
				crewListModel.duty = cl.Duty_Assignment__c;
				crewListModel.dutyC = cl.Duty_Code__c;
				crewListModel.lang = cl.Language__c;
				crewListModel.posFly = cl.POS_Fly__c;
				crewListModel.noOfEval = '' + cl.No_of_Eval__c;
				crewListModel.seqNo = cl.SEQ_No__c;
				crewListModel.sfdcId = cl.CrewId__c;
				crewListModel.rtFltNo = cl.returnfltno__c;
				crewListModel.rtFltD = BE8_DateUtility.convertDateToStringForMobileApp(BE8_DateUtility.convertStringToDate(cl.returnfltdate__c));
				crewListModel.gender = cl.Gender__c;
				crewListModel.lastEva = BE8_DateUtility.convertDateToStringForMobileApp(cl.Last_EVAL__c);
				flightModel.crewL.add(crewListModel);

				if (currentUserCrewId == cl.CrewId__c) {
					flightModel.userId = crewListModel;
				}
			}

			flightModel.equip = new List<MB_RestResponseInfoModel.sEquip_model>();
			List<Master_Map__c> equipmentList = new List<Master_Map__c>();
			equipmentList.addAll(generalEquipmentList);
			if (equipmentByAircraftMap.get(flight.Aircraft_Description__c) != null) {
				equipmentList.addAll((List<Master_Map__c>) equipmentByAircraftMap.get(flight.Aircraft_Description__c));
			}
			for (Master_Map__c eachEquipment : equipmentList) {
                if(eachEquipment.Cabin_Ver__c == null || eachEquipment.Cabin_Ver__c == flight.AircraftId__r.Cabin_Ver__c){
                 	MB_RestResponseInfoModel.sEquip_model eModel = new MB_RestResponseInfoModel.sEquip_model();
                    eModel.id = eachEquipment.Id;
                    eModel.type = eachEquipment.Equipment_Type__c;
                    eModel.zone = eachEquipment.Check_by_CA_s_station__c;
                    eModel.location = eachEquipment.Location__c;
                    eModel.name = eachEquipment.Name;
                    eModel.ataCh = eachEquipment.Depend_On_Object_Name__c;
                    eModel.cCA = eachEquipment.Check_by_CA_s_station__c;
                    eModel.cPro = eachEquipment.Checked_Procedure__c;
                    eModel.descr = eachEquipment.Description__c;
                    eModel.qty = eachEquipment.Quantity_to_be_checked__c;
                    eModel.total = eachEquipment.Total__c;
                    eModel.part = new List<MB_RestResponseInfoModel.part_model>();
                    eModel.lcc = eachEquipment.LOPA_Concern_Location__c;
                    if (eachEquipment.Depend_On_Object__r != null) {
                        for (Master_Map__c eachPart : eachEquipment.Depend_On_Object__r) {
                            MB_RestResponseInfoModel.part_model pModel = new MB_RestResponseInfoModel.part_model();
                            pModel.id = eachPart.Id;
                            pModel.name = eachPart.Name;
                            pModel.lcc = eachPart.LOPA_Concern_Location__c;
                            eModel.part.add(pModel);
                        }
                    }
                    flightModel.equip.add(eModel);   
                }
			}

			flightModel.condi = new List<String>();
			for (Schema.PicklistEntry each : Case.Condition_Multi__c.getDescribe().getPicklistValues()) {
				flightModel.condi.add(each.getValue());
			}

			flightInfoList.add(flightModel);
		}

		crewMapping.Last_Sync_Time__c = DateTime.now();
		crewMapping.Synced_Flights__c = '' + flightExternalIdSet;
		update crewMapping;

		logOutgoingResponse(flightInfoList, flightIdSet, currentUser, currentCrew);

		return flightInfoList;
	}

	private static void logOutgoingResponse(List<MB_RestResponseInfoModel.flightInfo_model> flightInfoList, Set<Id> flightIdSet, User currentUser, Crew__c currentCrew){
		List<MB_RestResponseInfoModel.flightInfo_model> resultClone = (List<MB_RestResponseInfoModel.flightInfo_model>) System.JSON.deserialize(System.JSON.serialize(flightInfoList), List<MB_RestResponseInfoModel.flightInfo_model>.class);
		for(MB_RestResponseInfoModel.flightInfo_model each : resultClone){
			each.equip = null;
			each.condi = null;
		}
		String json = BE8_GlobalUtility.subStringByMaxLength('User: ' + currentUser.Id + '-' + currentUser.Name + ' Crew: ' + currentCrew.Name + ' ' + System.JSON.serialize(resultClone), Application_Log__c.Message__c.getDescribe().getLength());
		Applogger.debug('MB_RESTFlightService', 'getFlightInfo', '' + flightIdSet, json, null);
		AppLogger.insertLogs();
	}
	/*
	// For debugging only
	List<Case> cases = [SELECT Id, Mobile_App_Key__c FROM Case WHERE Mobile_App_Key__c = 'TGTESTJA'];
	for(Case c : cases){
		System.debug('Case :' + c.Id + ' - ' + c.Mobile_App_Key__c);
	}

	List<Attachment> attLst = [SELECT Id, Name, Body, BodyLength, ParentId FROM Attachment WHERE ParentId = '500N0000004ZLXDIA4' ORDER BY ParentId];
	for(Attachment a : attList){
		System.debug('Attachment :ParentId / Name / Type :' + a.ParentId + ' / ' + a.Name + ' / ' + a.ContentType);
	}
	*/

	public static String getAttachmentFileExtension(Attachment pA) {
		// If content type is NOT NULL and contains /, split content type
		if (pA.ContentType != null && pA.ContentType.contains('/')) {
			String[] str = pA.ContentType.split('/');
			if (str.size() > 1) {
				return str[1].trim();
			}
		}

		// If content type is NULL, use NAME instead
		else {
			if (pA.Name != null && pA.Name.contains('.')) {
				String[] str = pA.Name.split('\\.');
				if (str.size() > 1) {
					return str[1].trim();
				}
			}
		}

		return 'JPG';
	}

	@HttpPost
	global static List<String> doPost(List<String> mobileAppKeyList) {
		Database.executeBatch(new CSE_AttachmentToTHAI(mobileAppKeyList), 1);
		List<String> mobileIncidentIdList = mobileAppKeyList;
		return mobileIncidentIdList;
	}

	public class linkModel {
		String caseId;
		String link;
	}

	@TestVisible
	private static String getAcceptedPax(List<Passenger__c> passengerList) {
		Map<String, Integer> classMap = new Map<String, Integer>();
		for (Passenger__c eachPax : passengerList) {
			String classCode = eachPax.Cabin_Code__c;
			if (!classMap.containsKey(classCode)) {
				classMap.put(classCode, 0);
			}
			if(eachPax.Checkin_Seat__c != null){
				Integer count = classMap.get(classCode);
				classMap.put(classCode, count + 1);
			}
		}

		List<String> classCodeList = new List<String> {'F', 'C', 'U', 'Y'};
		String acceptedPax = '';
		Integer count = 0;
		for(String classCode : classCodeList){
			if(classMap.containsKey(classCode)){
				acceptedPax += classCode + classMap.get(classCode);

				Boolean isTheLast = count == classCodeList.size() - 1;
				if(!isTheLast){
					acceptedPax += ' ';
				}
			}
			count++;
		}
		return acceptedPax;
	}

	@TestVisible
	private static Map<String, String> getCabinDutyMap(List<Flight__c> flightList){
		Set<String> aircraftTypes = getAircraftType(flightList);
		return getCabinDutyMapByAircraftType(aircraftTypes);
	}

	@TestVisible
	private static Map<String, String> getCabinDutyMapByAircraftType(Set<String> aircraftTypeSet){
		Map<String, String> returnMap = null;
		if(aircraftTypeSet != null){
			List<Aircraft__c> aircrafts = Database.query(cabinDutyQuery + 'aircraftTypeSet');
			if(aircrafts != null){
				for(Aircraft__c aircraft : aircrafts){
					if(returnMap == null) returnMap = new Map<String, String>();
					if(!returnMap.containsKey(aircraft.Aircraft_Type__c)) returnMap.put(aircraft.Aircraft_Type__c, aircraft.Cabin_Duty__c);
				}
			}
		}

		return returnMap;
	}

	@TestVisible
	private static Set<String> getAircraftType(List<Flight__c> flightList){
		Set<String> returnSet = null;
		if(flightList != null){
			for(Flight__c flight : flightList){
				if(returnSet == null) returnSet = new Set<String>();
				if(flight.Aircraft_Type__c != null) returnSet.add(flight.Aircraft_Type__c);
			}
		}

		return returnSet;
	}

	//public static String getAcceptedPaxFromFlightId(Id flightId){
	//	PassengerSectorPage page = new PassengerSectorPage(new Set<Id>{flightId});
	//	String acceptedPax = '';
	//	for(String classCode : page.classList){
	//		PassengerSectorPage.ClassView classView = page.totalClassMap.get(classCode);
	//		if(classView != null){
	//			acceptedPax += classCode + classView.totalAccepted;
	//			if(classView.totalInfantAccepted > 0){
	//				acceptedPax += '+' + classView.totalInfantAccepted + ' ';
	//			} else {
	//				acceptedPax += ' ';
	//			}
	//		}
	//	}
	//	return acceptedPax;
	//}
}