public without sharing class IncidentService {
	public static String FLIGHT_LOG = 'Flight Log';
	public static String CABIN_LOG = 'Cabin Log';
	public static String compensationField = 'Id, Created_At_Mobile__c, Compensation_Detail__c, Compensation_Tools__c, Total__c, Amount__c, PassengerId__c, Problem__c, Currency__c, UpgradeCertificate__c, ISC_Form_No__c, Item_Code_No__c, From_Seat__c, From_Class__c, To_Seat__c, To_Class__c, Mobile_App_Key__c';
	public static String caseGroupMemberFields = 'Id, Created_At_Mobile__c, Equipment__c, A_C_Zone__c, Change_Seat__c, Change_Cabin_Class__c, Impact__c, CreatedDate, LastModifiedDate, Caseid__c, AccountId__c, Position__c, Passengerid__c, Passengerid__r.PaxKey__c, Passengerid__r.First_Name__c, Passengerid__r.Last_Name__c, Passengerid__r.PNR__c, Passengerid__r.Checkin_Seat__c, Passengerid__r.Change_Cabin_Class__c, Passengerid__r.Cabin_Code__c, Passengerid__r.Change_Seat__c, Passengerid__r.AccountId__c, New_Travel_Class__c, CrewId__c, Staff_Name__c, Staff_Personal_Number__c, Flightid__r.Flight_External_ID__c, Role__c, Detail__c';
	public static String caseFields = 'Id, Lack_of_Part__c, Lack_of_Time__c, DEP_STN__c, A_C_REG_ID__r.Aircraft_Type__c, A_C_REG_ID__r.Aircraft_Main_Type__c, Upgrade_Change_Seat_Type__c, Authorize_Number__c, Block_Name__c, Passenger_Phone__c, Passenger_Email__c, Action__c, FlightId__r.Flight_Number__c, Passengerid__r.Checkin_Seat__c, Passengerid__r.Change_Cabin_Class__c, Passengerid__r.AccountId__c, Passengerid__r.PaxKey__c, Change_Seat__c, Change_Cabin_Class__c, A_C_REG_ID__r.Name, Safety_Zone__c, Emergency_Type__c, Condition_Multi__c, SEQ_No_Display__c, Subject, CreatedDate, LastModifiedDate, Created_At_Mobile__c, Updated_At_Mobile__c, PartId__c, Incident_Category_Mobile__c, Passengerid__c, Mobile_App_Key__c, Flightid__c, Flightid__r.Flight_External_ID__c, Flightid__r.A_C_Reg__c, Created_By_Crew__c, Reported_By_Crew__c, Description, Case_Type__c, Incident_Type__c, Status, Priority, EquipmentId__c ';
	public static String caseQuery = 'SELECT ' + caseFields + ' ,(SELECT ' + caseGroupMemberFields + ' FROM Case_Group_Members__r), (SELECT ' + compensationField + ' FROM Compensations__r) FROM Case';
	public static String caseQueryWithoutCGM = 'SELECT ' + caseFields + ' ,(SELECT ' + compensationField + ' FROM Compensations__r) FROM Case';
	public static String caseGroupMemberQuery = 'SELECT ' + caseGroupMemberFields + ' FROM Case_Group_Member__c';

	public static String COMPENSATION_TOOLS_INFLIGHT_MILEAGE = 'Mileage';
	public static String COMPENSATION_TOOLS_S4_MILEAGE_COMPENSATION = 'Mileage Compensation';
	public static String COMPENSATION_TOOLS_INFLIGHT_MPD = 'MPD';
	public static String COMPENSATION_TOOLS_S4_EMD = 'EMD';
	public static String COMPENSATION_TOOLS_INFLIGHT_OTHERS = 'Others';
	public static String COMPENSATION_TOOLS_S4_OTHER = 'Other';

	public static String convertCompensationToolsFromS4ToInFlightWording(String input) {
		Map<String, String> convertMap = new Map<String, String> { COMPENSATION_TOOLS_S4_MILEAGE_COMPENSATION => COMPENSATION_TOOLS_INFLIGHT_MILEAGE, COMPENSATION_TOOLS_S4_EMD => COMPENSATION_TOOLS_INFLIGHT_MPD, COMPENSATION_TOOLS_S4_OTHER => COMPENSATION_TOOLS_INFLIGHT_OTHERS};
		return convertCompensationTools(input, convertMap);
	}

	public static String convertCompensationToolsFromInFlightToS4Wording(String input) {
		Map<String, String> convertMap = new Map<String, String> {COMPENSATION_TOOLS_INFLIGHT_MILEAGE => COMPENSATION_TOOLS_S4_MILEAGE_COMPENSATION, COMPENSATION_TOOLS_INFLIGHT_MPD => COMPENSATION_TOOLS_S4_EMD,  COMPENSATION_TOOLS_INFLIGHT_OTHERS => COMPENSATION_TOOLS_S4_OTHER};
		return convertCompensationTools(input, convertMap);
	}

	private static String convertCompensationTools(String input, Map<String, String> convertMap) {
		String result = convertMap.get(input);
		if (result != null) {
			return result;
		} else {
			return input;
		}
	}

	public static List<MB_RestResponseInfoModel.incident_model> retrieveIncidentInfo(List<Case> caseList) {
		Set<Id> allCaseIdSet = BE8_GlobalUtility.getIdSet('Id', caseList);
		Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId = new Map<Id, List<Case_Group_Member__c>>();
		for (Case_Group_Member__c eachCGM : IncidentService.getCaseGroupMemberFromCase(allCaseIdSet)) {
			if (!cgmListMapByCaseId.containsKey(eachCGM.Caseid__c)) {
				cgmListMapByCaseId.put(eachCGM.Caseid__c, new List<Case_Group_Member__c>());
			}
			cgmListMapByCaseId.get(eachCGM.Caseid__c).add(eachCGM);
		}
		List<MB_RestResponseInfoModel.incident_model> incidentList = IncidentService.createIncidentModelList(caseList, cgmListMapByCaseId);
		return incidentList;
	}

	public static String createCaseGroupMemberPositionSummaryString(List<Case_Group_Member__c> cgmList) {
		String summary = '';
		List<String> positionList = new List<String>();
		for (Case_Group_Member__c eachCGM : cgmList) {
			if (eachCGM.Position__c != null && !String.isEmpty(eachCGM.Position__c)) {
				positionList.add(eachCGM.Position__c);
			}
		}

		if (!positionList.isEmpty()) {
			summary = String.join(positionList, ',');
		}
		return summary;
	}

	public static List<Case_Group_Member__c> getCaseGroupMemberOfAccountList(Set<Id> accountIdSet, Set<String> flightMasterSet) {
		return Database.query(caseGroupMemberQuery + ' WHERE AccountId__c IN :accountIdSet OR PassengerId__r.Flight_Master__c IN :flightMasterSet ORDER BY CreatedDate DESC');
	}

	public static List<Case> getCaseList(Set<Id> caseIdSet) {
		return Database.query(caseQuery + ' WHERE Id IN :caseIdSet');
	}

	public static List<Case> getFlightCaseList(Set<Id> flightIdSet, Set<String> caseStatusNotIncludedSet, Set<Id> excludeCaseIdSet) {
		return Database.query(caseQueryWithoutCGM + ' WHERE Id NOT IN :excludeCaseIdSet AND Flightid__c IN :flightIdSet AND Status NOT IN :caseStatusNotIncludedSet');
	}

	public static List<Case> getAircraftCaseList(Set<Id> aircraftIdSet, Set<String> caseStatusNotIncludedSet, Set<Id> excludeCaseIdSet) {
		Id maintenanceCaseRecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		return Database.query(caseQuery + ' WHERE Id NOT IN :excludeCaseIdSet AND A_C_REG_ID__c IN :aircraftIdSet AND Status NOT IN :caseStatusNotIncludedSet AND RecordTypeId = :maintenanceCaseRecordTypeId');
	}

	public static List<Case> getAircraftCaseList(Set<Id> aircraftIdSet, Set<String> caseStatusNotIncludedSet, Set<Id> excludeCaseIdSet, DateTime lastSyncTime) {
		Set<Id> maintenanceCaseRecordTypeIdSet = new Set<Id> {BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE), BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_NEW_MAINTENANCE), BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_VOID_MAINTENANCE)};
		String condition = ' WHERE Id NOT IN :excludeCaseIdSet AND A_C_REG_ID__c IN :aircraftIdSet AND RecordTypeId IN :maintenanceCaseRecordTypeIdSet';
		if (lastSyncTime != null) {
			condition += ' AND LastModifiedDate >= :lastSyncTime';
		} else {
			condition += ' AND Status NOT IN :caseStatusNotIncludedSet';
		}
		System.debug(caseQuery + condition);
		return Database.query(caseQuery + condition);
	}

	public static List<Case_Group_Member__c> getCaseGroupMemberFromCase(Set<Id> allCaseIdSet) {
		return Database.query('SELECT ' + caseGroupMemberFields + ' FROM Case_Group_Member__c WHERE Caseid__c IN :allCaseIdSet');
	}

	public static List<MB_RestResponseInfoModel.incident_model> createIncidentModelListForErrorRecords(Database.UpsertResult[] caseSaveResultList, List<Case> allCaseList, Map<String, MB_RestRequestInfoModel.incident_model> incidentRequestMapByMobileAppKey, Map<Id, Flight__c> flightMap) {
		System.debug('allCaseList: ' + System.JSON.serialize(allCaseList));
		List<MB_RestResponseInfoModel.incident_model> responseList = new List<MB_RestResponseInfoModel.incident_model>();
		Integer index = 0;
		for (Database.UpsertResult saveResult : caseSaveResultList) {
			Boolean isDuplicateSEQNoCase = false;
			if (!saveResult.isSuccess()) {
				for (Database.Error eachError : saveResult.getErrors()) {
					//System.debug('eachError: ' + eachError);
					if (String.valueOf(eachError.getStatusCode()) == 'DUPLICATE_VALUE') {
						isDuplicateSEQNoCase = true;
						break;
					}
				}
			}

			if (isDuplicateSEQNoCase) {
				Case errorCase = allCaseList.get(index);
				MB_RestRequestInfoModel.incident_model errorIncident = incidentRequestMapByMobileAppKey.get(errorCase.Mobile_App_Key__c);
				MB_RestResponseInfoModel.incident_model incidentModel = new MB_RestResponseInfoModel.incident_model();
				incidentModel.id = errorIncident.Id;
				incidentModel.fltId = errorIncident.fltId;
				incidentModel.fltNum = errorIncident.fltNum;
				incidentModel.aircraftId = errorIncident.aircraftId;
				incidentModel.creBy = errorIncident.creBy;
				incidentModel.repBy = errorIncident.repBy;
				incidentModel.creDT = errorIncident.creDT;
				incidentModel.updDT = errorIncident.updDT;
				incidentModel.equipId = errorIncident.equipId;
				incidentModel.partId = errorIncident.partId;
				incidentModel.seqNo = errorIncident.seqNo;
				incidentModel.condi = errorIncident.condi;
				incidentModel.subject = errorIncident.subject;
				incidentModel.descr = errorIncident.descr;
				incidentModel.logType = errorIncident.logType != null ? Integer.valueOf(errorIncident.logType) : null;
				incidentModel.status = '' + errorIncident.status;
				incidentModel.isLog = errorIncident.isLog;
				incidentModel.isVoided = errorIncident.isVoided;
				incidentModel.rptType = errorIncident.rptType;
				incidentModel.emerType = errorIncident.emerType;
				incidentModel.inCate = errorIncident.inCate != null ? Integer.valueOf(errorIncident.inCate) : null;
				incidentModel.isSynced = 1;
				incidentModel.safetyZone = errorIncident.safetyZone;
				incidentModel.acReg = errorIncident.acReg;
				incidentModel.action = errorIncident.action;
				incidentModel.phone = errorIncident.phone;
				incidentModel.email = errorIncident.email;
				incidentModel.authName = errorIncident.authName;
				incidentModel.authNumber = errorIncident.authNumber;
				incidentModel.upChgType = errorIncident.upChgType;
				incidentModel.acType = flightMap.containsKey(incidentModel.fltId) ? flightMap.get(incidentModel.fltId).Aircraft_Type__c : null;
				incidentModel.acMainType = flightMap.containsKey(incidentModel.fltId) ? flightMap.get(incidentModel.fltId).AircraftId__r.Aircraft_Main_Type__c : null;
				incidentModel.isDup = 1;
				incidentModel.depSt = errorIncident.depSt;
				incidentModel.lackOfPart = errorIncident.lackOfPart;
				incidentModel.lackOfTime = errorIncident.lackOfTime;

				if (errorIncident.posMem != null) {
					incidentModel.posMem = new List<MB_RestResponseInfoModel.incident_posMem>();
					for (MB_RestRequestInfoModel.incident_posMem eachMem : errorIncident.posMem) {
						MB_RestResponseInfoModel.incident_posMem newMem = new MB_RestResponseInfoModel.incident_posMem();
						newMem.id = eachMem.id;
						newMem.impact = eachMem.impact;
						newMem.sfdcId = eachMem.sfdcId;
						newMem.acZone = eachMem.acZone;
						newMem.equipId = eachMem.equipId;
						incidentModel.posMem.add(newMem);
					}
				}

				if (errorIncident.paxMem != null) {
					incidentModel.paxMem = new List<MB_RestResponseInfoModel.incident_paxMem>();
					for (MB_RestRequestInfoModel.incident_paxMem eachMem : errorIncident.paxMem) {
						MB_RestResponseInfoModel.incident_paxMem newMem = new MB_RestResponseInfoModel.incident_paxMem();
						newMem.id = eachMem.id;
						newMem.accId = eachMem.accId;
						newMem.paxKey = eachMem.paxKey;
						newMem.role = eachMem.role;
						newMem.detail = eachMem.detail;
						newMem.sfdcId = eachMem.sfdcId;
						incidentModel.paxMem.add(newMem);
					}
				}

				if (errorIncident.crewMem != null) {
					incidentModel.crewMem = new List<MB_RestResponseInfoModel.incident_crewMem>();
					for (MB_RestRequestInfoModel.incident_crewMem eachMem : errorIncident.crewMem) {
						MB_RestResponseInfoModel.incident_crewMem newMem = new MB_RestResponseInfoModel.incident_crewMem();
						newMem.id = eachMem.id;
						newMem.role = eachMem.role;
						newMem.detail = eachMem.detail;
						newMem.sfdcId = eachMem.sfdcId;
						incidentModel.crewMem.add(newMem);
					}
				}

				if (errorIncident.staffMem != null) {
					incidentModel.staffMem = new List<MB_RestResponseInfoModel.incident_staffMem>();
					for (MB_RestRequestInfoModel.incident_staffMem eachMem : errorIncident.staffMem) {
						MB_RestResponseInfoModel.incident_staffMem newMem = new MB_RestResponseInfoModel.incident_staffMem();
						newMem.staffName = eachMem.staffName;
						newMem.id = eachMem.id;
						newMem.role = eachMem.role;
						newMem.detail = eachMem.detail;
						newMem.sfdcId = eachMem.sfdcId;
						incidentModel.staffMem.add(newMem);
					}
				}

				if (errorIncident.chSeat != null) {
					incidentModel.chSeat = new List<MB_RestResponseInfoModel.incident_changeSeatMem>();
					for (MB_RestRequestInfoModel.incident_changeSeatMem eachMem : errorIncident.chSeat) {
						MB_RestResponseInfoModel.incident_changeSeatMem newMem = new MB_RestResponseInfoModel.incident_changeSeatMem();
						newMem.id = eachMem.id;
						newMem.fromSeat = eachMem.fromSeat;
						newMem.fromClass = eachMem.fromClass;
						newMem.toSeat = eachMem.toSeat;
						newMem.toClass = eachMem.toClass;
						newMem.creDT = eachMem.creDT;
						incidentModel.chSeat.add(newMem);
					}
				}

				if (errorIncident.compen != null) {
					incidentModel.compen = new List<MB_RestResponseInfoModel.incident_compensation>();
					for (MB_RestRequestInfoModel.incident_compensation eachMem : errorIncident.compen) {
						MB_RestResponseInfoModel.incident_compensation newMem = new MB_RestResponseInfoModel.incident_compensation();
						newMem.id = eachMem.id;
						newMem.detail = eachMem.detail;
						newMem.type = eachMem.type;
						newMem.quantity = eachMem.quantity;
						newMem.amount = eachMem.amount;
						newMem.paxId = eachMem.paxId;
						newMem.incidentId = eachMem.incidentId;
						newMem.sfdcId = eachMem.sfdcId;
						newMem.problem = eachMem.problem;
						newMem.currenc = eachMem.currenc;
						newMem.upCer = eachMem.upCer;
						newMem.iscFormNum = eachMem.iscFormNum;
						newMem.itemCodeNum = eachMem.itemCodeNum;
						newMem.fromSeat = eachMem.fromSeat;
						newMem.fromClass = eachMem.fromClass;
						newMem.toSeat = eachMem.toSeat;
						newMem.toClass = eachMem.toClass;
						newMem.creDT = eachMem.creDT;
						incidentModel.compen.add(newMem);
					}
				}

				responseList.add(incidentModel);
			}
			index++;
		}
		return responseList;
	}

	public static List<Case_Group_Member__c> assignMasterCaseToCaseGroupMember(Map<String, Case> caseMap, Map<String, List<Case_Group_Member__c>> caseGroupMemberMap) {
		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		for (String key : caseGroupMemberMap.keySet()) {
			Case masterCase = caseMap.get(key);
			List<Case_Group_Member__c> caseGroupMemberList = caseGroupMemberMap.get(key);
			for (Case_Group_Member__c eachMember : caseGroupMemberList) {
				if (eachMember.Id == null && masterCase.Id != null) {
					eachMember.Caseid__c = masterCase.Id;
				}

				if (masterCase.Id != null) {
					allCaseGroupMemberList.add(eachMember);
				}
			}
			//allCaseGroupMemberList.addAll(caseGroupMemberList);
		}
		return allCaseGroupMemberList;
	}

	public static List<Compensation__c> assignMasterCaseToCompensation(Map<String, Case> caseMap, Map<String, List<Compensation__c>> compensationMap) {
		List<Compensation__c> allCompensationList = new List<Compensation__c>();
		for (String key : compensationMap.keySet()) {
			Case masterCase = caseMap.get(key);
			List<Compensation__c> compensationList = compensationMap.get(key);
			for (Compensation__c eachCompensation : compensationList) {
				if (eachCompensation.Id == null && masterCase.Id != null) {
					eachCompensation.CaseId__c = masterCase.Id;
				}

				if (masterCase.Id != null) {
					allCompensationList.add(eachCompensation);
				}
			}
			//allCompensationList.addAll(compensationList);
		}
		return allCompensationList;
	}

	public static List<MB_RestResponseInfoModel.incident_model> createIncidentModelList(List<Case> allCaseList, Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId, MobileIncidentStatusHandler statusHandler) {
		List<MB_RestResponseInfoModel.incident_model> incidentList = new List<MB_RestResponseInfoModel.incident_model>();
		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		if (cgmListMapByCaseId != null) {
			for (List<Case_Group_Member__c> eachList : cgmListMapByCaseId.values()) {
				allCaseGroupMemberList.addAll(eachList);
			}
		}
		Set<Id> passengerIdSetFromAllCaseGroupMemberList = BE8_GlobalUtility.getIdSet('Passengerid__c', allCaseGroupMemberList);
		Map<Id, Passenger__c> passengerMap = new Map<Id, Passenger__c>();
		if (passengerIdSetFromAllCaseGroupMemberList != null && passengerIdSetFromAllCaseGroupMemberList.size() > 0) {
			passengerMap = new Map<Id, Passenger__c>([SELECT Id, Checkin_Seat__c, Booking_Seat__c, AccountId__c, First_Name__c, Last_Name__c, PNR__c, PaxKey__c FROM Passenger__c WHERE Id IN :passengerIdSetFromAllCaseGroupMemberList]);
		}

		Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Flightid__c', allCaseList);
		Map<Id, Flight__c> flightMap = new Map<Id, Flight__c> ([SELECT Id, Name FROM Flight__c WHERE Id IN :flightIdSet]);

		for (Case eachCase : allCaseList) {
			List<Case_Group_Member__c> thisCGMList;
			if (cgmListMapByCaseId.containsKey(eachCase.Id)) {
				thisCGMList = cgmListMapByCaseId.get(eachCase.Id);
			} else {
				thisCGMList = new List<Case_Group_Member__c>();
			}

			MB_RestResponseInfoModel.incident_model incidentModel = new MB_RestResponseInfoModel.incident_model();
			incidentModel.id = eachCase.Mobile_App_Key__c != null ? eachCase.Mobile_App_Key__c : eachCase.Id;
			if (eachCase.A_C_REG_ID__r != null) {
				incidentModel.aircraftId = eachCase.A_C_REG_ID__c;
				incidentModel.acReg = eachCase.A_C_REG_ID__r.Name;
			}
			incidentModel.sfdcId = eachCase.Id;
			incidentModel.subject = eachCase.Subject;
			incidentModel.fltId = eachCase.Flightid__c;
			incidentModel.fltNum = flightMap.containsKey(incidentModel.fltId) ? flightMap.get(incidentModel.fltId).Name : null;
			incidentModel.creBy = eachCase.Created_By_Crew__c;
			incidentModel.repBy = eachCase.Reported_By_Crew__c;
			incidentModel.creDT = eachCase.Created_At_Mobile__c != null ? BE8_DateUtility.convertDateTimeToStringForMobileApp(eachCase.Created_At_Mobile__c) : BE8_DateUtility.convertDateTimeToStringForMobileApp(eachCase.CreatedDate);
			incidentModel.updDT = eachCase.Updated_At_Mobile__c != null ? BE8_DateUtility.convertDateTimeToStringForMobileApp(eachCase.Updated_At_Mobile__c) : BE8_DateUtility.convertDateTimeToStringForMobileApp(eachCase.LastModifiedDate);
			incidentModel.descr = eachCase.Description;
			incidentModel.rptType = eachCase.Case_Type__c;
			incidentModel.emerType = BE8_GlobalConstants.EMERGENCY_TYPE_TO_INTEGER_MAP.get(eachCase.Emergency_Type__c);
			incidentModel.status = '' + BE8_GlobalConstants.CASE_STATUS_TO_INTEGER_MAP.get(eachCase.Status);
			incidentModel.isVoided = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(eachCase.Status == BE8_GlobalConstants.CASE_STATUS_VOID);
			incidentModel.isLog = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(eachCase.EquipmentId__c != null);
			incidentModel.equipId = eachCase.EquipmentId__c;
			incidentModel.partId = eachCase.PartId__c;
			incidentModel.isMulti = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(thisCGMList.size() > 1);
			incidentModel.isSynced = 1;
			incidentModel.seqNo = eachCase.SEQ_No_Display__c;
			incidentModel.condi = eachCase.Condition_Multi__c;
			incidentModel.safetyZone = eachCase.Safety_Zone__c;
			incidentModel.logType = BE8_GlobalConstants.CASE_LOG_TYPE_MAP_STRING_TO_INTEGER.get(eachCase.Incident_Type__c);
			incidentModel.action = BE8_GlobalConstants.CASE_ACTION_MAP_STRING_TO_INTEGER.get(eachCase.Action__c);
			incidentModel.phone = eachCase.Passenger_Phone__c;
			incidentModel.email = eachCase.Passenger_Email__c;
			incidentModel.authName = eachCase.Block_Name__c;
			incidentModel.authNumber = eachCase.Authorize_Number__c;
			incidentModel.upChgType = eachCase.Upgrade_Change_Seat_Type__c;
			incidentModel.acType = eachCase.A_C_REG_ID__r.Aircraft_Type__c;
			incidentModel.acMainType = eachCase.A_C_REG_ID__r.Aircraft_Main_Type__c;
			incidentModel.isDup = 0;
			incidentModel.depSt = eachCase.DEP_STN__c;
			incidentModel.lackOfPart = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(eachCase.Lack_of_Part__c);
			incidentModel.lackOfTime = BE8_GlobalConstants.BOOLEAN_TO_INTEGER.get(eachCase.Lack_of_Time__c);

			incidentModel = calculateInCate(eachCase, incidentModel);

			incidentModel.posMem = new List<MB_RestResponseInfoModel.incident_posMem>();
			incidentModel.paxMem = new List<MB_RestResponseInfoModel.incident_paxMem>();
			incidentModel.crewMem = new List<MB_RestResponseInfoModel.incident_crewMem>();
			incidentModel.staffMem = new List<MB_RestResponseInfoModel.incident_staffMem>();
			incidentModel.compen = new List<MB_RestResponseInfoModel.incident_compensation>();
			incidentModel.chSeat = new List<MB_RestResponseInfoModel.incident_changeSeatMem>();

			for (Case_Group_Member__c eachMember : thisCGMList) {
				if (eachCase.EquipmentId__c != null) {
					MB_RestResponseInfoModel.incident_posMem mem = new MB_RestResponseInfoModel.incident_posMem();
					mem.id = eachMember.Position__c;
					mem.impact = BE8_GlobalConstants.IMPACT_MAP_BY_STRING.get(eachMember.Impact__c);
					mem.sfdcId = eachMember.Id;
					mem.acZone = eachMember.A_C_Zone__c;
					mem.equipId = eachMember.Equipment__c;
					incidentModel.posMem.add(mem);
				} else if (eachMember.Change_Seat__c != null && eachMember.Change_Cabin_Class__c != null) {
					MB_RestResponseInfoModel.incident_changeSeatMem mem = new MB_RestResponseInfoModel.incident_changeSeatMem();
					mem.id = eachMember.Id;
					if (eachMember.Passengerid__r != null) {
						mem.fromSeat = eachMember.Passengerid__r.Checkin_Seat__c;
						mem.fromClass = eachMember.Passengerid__r.Cabin_Code__c;
						MB_RestResponseInfoModel.incident_paxMem paxMem = new MB_RestResponseInfoModel.incident_paxMem();
						paxMem.id = eachMember.Passengerid__c;
						paxMem.accId = eachMember.Passengerid__r.AccountId__c;
						paxMem.paxKey = eachMember.Passengerid__r.PaxKey__c;
						incidentModel.paxMem.add(paxMem);
					}
					mem.toSeat = eachMember.Change_Seat__c;
					mem.toClass = eachMember.Change_Cabin_Class__c;
					mem.creDT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachMember.Created_At_Mobile__c);
					incidentModel.chSeat.add(mem);
				} else if (eachMember.Passengerid__c != null) {
					MB_RestResponseInfoModel.incident_paxMem mem = new MB_RestResponseInfoModel.incident_paxMem();
					MB_RestResponseInfoModel.incident_posMem posMem = new MB_RestResponseInfoModel.incident_posMem();
					mem.sfdcId = eachMember.Id;
					posMem.sfdcId = eachMember.Id;
					if (eachMember.PassengerId__c != null && passengerMap != null && passengerMap.containsKey(eachMember.PassengerId__c)) {
						Passenger__c retrievedPassenger = passengerMap.get(eachMember.PassengerId__c);
						mem.id = retrievedPassenger.Id;
						mem.accId = retrievedPassenger.AccountId__c;
						mem.paxKey = MB_RESTPassengerService.getPaxKey(retrievedPassenger);
						posMem.id = retrievedPassenger.Checkin_Seat__c;
						incidentModel.posMem.add(posMem);
					} else {
						mem.id = eachMember.Passengerid__c;
					}
					//mem.newPos = eachMember.Change_Seat__c;
					//mem.newClass = eachMember.Change_Cabin_Class__c;
					mem.role = eachMember.Role__c;
					mem.detail = eachMember.Detail__c;
					mem.sfdcId = eachMember.Id;
					incidentModel.paxMem.add(mem);
				} else if (eachMember.CrewId__c != null) {
					MB_RestResponseInfoModel.incident_crewMem mem = new MB_RestResponseInfoModel.incident_crewMem();
					mem.id = eachMember.CrewId__c;
					mem.role = eachMember.Role__c;
					mem.detail = eachMember.Detail__c;
					mem.sfdcId = eachMember.Id;
					incidentModel.crewMem.add(mem);
				} else if (eachMember.Staff_Name__c != null) {
					MB_RestResponseInfoModel.incident_staffMem mem = new MB_RestResponseInfoModel.incident_staffMem();
					mem.staffName = eachMember.Staff_Name__c;
					mem.id = eachMember.Staff_Personal_Number__c;
					mem.role = eachMember.Role__c;
					mem.detail = eachMember.Detail__c;
					mem.sfdcId = eachMember.Id;
					incidentModel.staffMem.add(mem);
				}
			}

			for (Compensation__c eachCompensation : eachCase.Compensations__r) {
				MB_RestResponseInfoModel.incident_compensation compenModel = new MB_RestResponseInfoModel.incident_compensation();
				compenModel.sfdcId = eachCompensation.Id;
				compenModel.detail = eachCompensation.Compensation_Detail__c;
				compenModel.type = convertCompensationToolsFromS4ToInFlightWording(eachCompensation.Compensation_Tools__c);
				compenModel.quantity = '' + eachCompensation.Total__c;
				compenModel.amount = '' + eachCompensation.Amount__c;
				compenModel.paxId = eachCompensation.PassengerId__c;
				compenModel.problem = eachCompensation.Problem__c;
				compenModel.currenc = eachCompensation.Currency__c;
				compenModel.upCer = eachCompensation.UpgradeCertificate__c;
				compenModel.iscFormNum = eachCompensation.ISC_Form_No__c;
				compenModel.itemCodeNum = eachCompensation.Item_Code_No__c;
				compenModel.fromSeat = eachCompensation.From_Seat__c;
				compenModel.fromClass = eachCompensation.From_Class__c;
				compenModel.toSeat = eachCompensation.To_Seat__c;
				compenModel.toClass = eachCompensation.To_Class__c;
				compenModel.id = eachCompensation.Mobile_App_Key__c;
				compenModel.creDT = BE8_DateUtility.convertDateTimeToStringForMobileApp(eachCompensation.Created_At_Mobile__c);

				incidentModel.compen.add(compenModel);
			}

			if(statusHandler != null){
				statusHandler.assignIncidentStatusFromSFDCToMobile(eachCase.Status, incidentModel);
			}

			incidentList.add(incidentModel);
		}

		return incidentList;
	}

	public static List<MB_RestResponseInfoModel.incident_model> createIncidentModelList(List<Case> allCaseList, Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId) {
		return createIncidentModelList(allCaseList, cgmListMapByCaseId, null);
	}

	public static MB_RestResponseInfoModel.incident_model calculateInCate(Case eachCase, MB_RestResponseInfoModel.incident_model incidentModel) {
		if (eachCase.Incident_Category_Mobile__c != null) {
			incidentModel.inCate =  Integer.valueOf(eachCase.Incident_Category_Mobile__c);
		} else {
			if (eachCase.Incident_Type__c == null) {
				incidentModel.inCate = 5; // Other
			} else if (eachCase.Incident_Type__c == FLIGHT_LOG) {
				incidentModel.incate = 3;
			} else if (eachCase.Incident_Type__c == CABIN_LOG) {
				incidentModel.inCate = 4;
			} else {
				incidentModel.inCate = 0;
			}
		}
		return incidentModel;
	}

	public static List<Case_Group_Member__c> getEquipmentCaseGroupMemberList(List<MB_RestRequestInfoModel.incident_posMem> posMem, Id flightId, Id aircraftId) {
		List<Case_Group_Member__c> equipmentCaseGroupMemberList = new List<Case_Group_Member__c>();
		for (MB_RestRequestInfoModel.incident_posMem each : posMem) {
			Case_Group_Member__c eachCaseGroupMember = new Case_Group_Member__c(
			    Id = each.sfdcId,
			    Position__c = each.id,
			    Flightid__c = flightId,
			    Aircraft__c = aircraftId,
			    Impact__c = BE8_GlobalConstants.IMPACT_MAP_BY_INTEGER.get(each.impact),
			    A_C_Zone__c = each.acZone,
			    Equipment__c = each.equipId
			);
			equipmentCaseGroupMemberList.add(eachCaseGroupMember);
		}
		return equipmentCaseGroupMemberList;
	}

	public static List<Case_Group_Member__c> getPassengerCaseGroupMemberList(List<MB_RestRequestInfoModel.incident_paxMem> paxMem, Id flightId, Id aircraftId, Map<Id, Passenger__c> passengerMap) {
		List<Case_Group_Member__c> passengerCaseGroupMemberList = new List<Case_Group_Member__c>();
		for (MB_RestRequestInfoModel.incident_paxMem eachPassengerModel : paxMem) {
			Id passengerId = eachPassengerModel.id;
			Passenger__c retrievedPassenger = passengerMap.get(passengerId);
			Id accountId = retrievedPassenger != null ? retrievedPassenger.AccountId__c : null;

			Case_Group_Member__c eachCaseGroupMember = new Case_Group_Member__c(
			    Id = eachPassengerModel.sfdcId,
			    Passengerid__c = passengerId,
			    AccountId__c = accountId,
			    Role__c = eachPassengerModel.role,
			    Detail__c = eachPassengerModel.detail,
			    Flightid__c = flightId,
			    Aircraft__c = aircraftId
			);

			//if (eachCaseGroupMember.Position__c == null && retrievedPassenger != null) {
			//    eachCaseGroupMember.Position__c = retrievedPassenger.Checkin_Seat__c != null ? retrievedPassenger.Checkin_Seat__c : retrievedPassenger.Booking_Seat__c;
			//}
			passengerCaseGroupMemberList.add(eachCaseGroupMember);
		}
		return passengerCaseGroupMemberList;
	}

	public static List<Case_Group_Member__c> getCrewCaseGroupMemberList(List<MB_RestRequestInfoModel.incident_crewMem> crewMem, Id flightId, Id aircraftId) {
		List<Case_Group_Member__c> crewCaseGroupMemberList = new List<Case_Group_Member__c>();
		for (MB_RestRequestInfoModel.incident_crewMem eachCrewModel : crewMem) {
			Case_Group_Member__c eachCaseGroupMember = new Case_Group_Member__c(
			    Id = eachCrewModel.sfdcId,
			    CrewId__c = eachCrewModel.id,
			    Role__c = eachCrewModel.role,
			    Detail__c = eachCrewModel.detail,
			    Flightid__c = flightId,
			    Aircraft__c = aircraftId
			);
			crewCaseGroupMemberList.add(eachCaseGroupMember);
		}
		return crewCaseGroupMemberList;
	}

	public static List<Case_Group_Member__c> getStaffCaseGroupMemberList(List<MB_RestRequestInfoModel.incident_staffMem> staffMem, Id flightId, Id aircraftId) {
		List<Case_Group_Member__c> staffCaseGroupMemberList = new List<Case_Group_Member__c>();
		for (MB_RestRequestInfoModel.incident_staffMem eachStaffModel : staffMem) {
			Case_Group_Member__c eachCaseGroupMember = new Case_Group_Member__c(
			    Id = eachStaffModel.sfdcId,
			    Staff_Name__c = eachStaffModel.staffName,
			    Staff_Personal_Number__c = eachStaffModel.id,
			    Role__c = eachStaffModel.role,
			    Detail__c = eachStaffModel.detail,
			    Flightid__c = flightId,
			    Aircraft__c = aircraftId
			);
			staffCaseGroupMemberList.add(eachCaseGroupMember);
		}
		return staffCaseGroupMemberList;
	}

	public static List<Case_Group_Member__c> getChangeSeatCaseGroupMemberList(List<MB_RestRequestInfoModel.incident_changeSeatMem> chSeat, Id flightId, Id aircraftId, Id passengerId) {
		List<Case_Group_Member__c> caseGroupMemberList = new List<Case_Group_Member__c>();
		for (MB_RestRequestInfoModel.incident_changeSeatMem eachMem : chSeat) {
			Case_Group_Member__c eachCaseGroupMember = new Case_Group_Member__c();
			eachCaseGroupMember.Id = eachMem.Id;
			eachCaseGroupMember.Flightid__c = flightId;
			eachCaseGroupMember.Aircraft__c = aircraftId;
			eachCaseGroupMember.Passengerid__c = passengerId;
			eachCaseGroupMember.Change_Seat__c = eachMem.toSeat;
			eachCaseGroupMember.Change_Cabin_Class__c = eachMem.toClass;
			eachCaseGroupMember.Created_At_Mobile__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachMem.creDT);
			caseGroupMemberList.add(eachCaseGroupMember);
		}
		return caseGroupMemberList;
	}

	public static Case createCaseFromModel(MB_RestRequestInfoModel.incident_model eachIncidentModel, Id flightId, Id aircraftId) {
		Case caseObj = new Case();
		caseObj.Id = eachIncidentModel.sfdcId;
		caseObj.Subject = eachIncidentModel.Subject;
		caseObj.Mobile_App_Key__c = eachIncidentModel.id;
		caseObj.Flightid__c = flightId;
		caseObj.A_C_REG_ID__c = aircraftId;
		caseObj.Created_By_Crew__c = eachIncidentModel.creBy;
		caseObj.Reported_By_Crew__c = eachIncidentModel.repBy;
		caseObj.DEP_STN__c = eachIncidentModel.depSt;
		if (eachIncidentModel.descr != null) {
			caseObj.Description = eachIncidentModel.descr;
		}
		if (eachIncidentModel.rptType != null) {
			caseObj.Case_Type__c = eachIncidentModel.rptType;
		} else {
			caseObj.Case_Type__c = BE8_GlobalConstants.CASE_TYPE_INFORMATION;
		}
		caseObj.Origin = BE8_GlobalConstants.CASE_CHANNEL_IN_FLIGHT;
		caseObj.Priority = BE8_GlobalConstants.CASE_PRIORITY_MEDIUM;
		caseObj.Incident_Category_Mobile__c = eachIncidentModel.inCate;
		caseObj.Created_At_Mobile__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachIncidentModel.creDT);
		caseObj.Updated_At_Mobile__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachIncidentModel.updDT);
		caseObj.Json_Body__c = JSON.serialize(eachIncidentModel);
		if (eachIncidentModel.logType != null) {
			System.debug(eachIncidentModel.logType);
			caseObj.Incident_Type__c = BE8_GlobalConstants.CASE_LOG_TYPE_MAP_INTEGER_TO_STRING.get(Integer.valueOf(eachIncidentModel.logType));
		}
		if (eachIncidentModel.safetyZone != null) {
			caseObj.Safety_Zone__c = eachIncidentModel.safetyZone;
		}
		if (eachIncidentModel.action != null) {
			caseObj.Action__c = BE8_GlobalConstants.CASE_ACTION_MAP_INTEGER_TO_STRING.get(eachIncidentModel.action);
		}
		caseObj.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_IN_FLIGHT);
		caseObj.Status = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(eachIncidentModel.isVoided) ? BE8_GlobalConstants.CASE_STATUS_VOID : BE8_GlobalConstants.INTEGER_TO_CASE_STATUS_FOR_INFLIGHT_MAP.get(eachIncidentModel.status);
		if (eachIncidentModel.phone != null) {
			caseObj.Passenger_Phone__c = eachIncidentModel.phone;
		}
		if (eachIncidentModel.email != null) {
			caseObj.Passenger_Email__c = eachIncidentModel.email;
		}
		if (eachIncidentModel.authName != null) {
			caseObj.Block_Name__c = eachIncidentModel.authName;
		}
		if (eachIncidentModel.authNumber != null) {
			caseObj.Authorize_Number__c = eachIncidentModel.authNumber;
		}
		if (eachIncidentModel.upChgType != null) {
			caseObj.Upgrade_Change_Seat_Type__c = eachIncidentModel.upChgType;
		}
		if (eachIncidentModel.lackOfPart != null) {
			caseObj.Lack_of_Part__c = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(eachIncidentModel.lackOfPart);
		}
		if (eachIncidentModel.lackOfTime != null) {
			caseObj.Lack_of_Time__c = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(eachIncidentModel.lackOfTime);
		}
		return caseObj;
	}

	public static List<Passenger__c> createPassengerSObjectForChangeSeat(MB_RestRequestInfoModel.incident_model incident, List<MB_RestRequestInfoModel.incident_changeSeatMem> chSeat, Id passengerId) {
		List<Passenger__c> passengerList = new List<Passenger__c>();
		if (passengerId != null) {
			for (MB_RestRequestInfoModel.incident_changeSeatMem eachSeatMem : chSeat) {
				Passenger__c passengerToChangeSeat = new Passenger__c();
				passengerToChangeSeat.Id = passengerId;
				passengerToChangeSeat.Change_Seat__c = eachSeatMem.toSeat;
				passengerToChangeSeat.Change_Cabin_Class__c = eachSeatMem.toClass;
				passengerToChangeSeat.Last_Change_Seat_DateTime__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachSeatMem.creDT);
				passengerList.add(passengerToChangeSeat);
			}
		}
		return passengerList;
	}

	public static List<Passenger__c> createPassengerSObjectForChangeSeat(MB_RestRequestInfoModel.incident_model incident, List<MB_RestRequestInfoModel.incident_compensation> compenMem, Id passengerId) {
		List<Passenger__c> passengerList = new List<Passenger__c>();
		if (passengerId != null) {
			for (MB_RestRequestInfoModel.incident_compensation eachCompen : compenMem) {
				if (eachCompen.toSeat != null && eachCompen.toClass != null) {
					Passenger__c passengerToChangeSeat = new Passenger__c();
					passengerToChangeSeat.Id = passengerId;
					passengerToChangeSeat.Change_Seat__c = eachCompen.toSeat;
					passengerToChangeSeat.Change_Cabin_Class__c = eachCompen.toClass;
					passengerToChangeSeat.Last_Change_Seat_DateTime__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachCompen.creDT);
					passengerList.add(passengerToChangeSeat);
				}
			}
		}
		return passengerList;
	}

	public static void sendEmergencyEmail(List<Case> emergencyCaseList) {
		Set<Id> caseIdSet = BE8_GlobalUtility.getIdSet('Id', emergencyCaseList);
		Case_Management.sendEmergencyEmail(caseIdSet);
	}
}