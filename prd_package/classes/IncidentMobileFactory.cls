public abstract without sharing class IncidentMobileFactory {
	protected String instanceName = 'IncidentMobileFactory';
	protected List<MB_RestRequestInfoModel.incident_model> incidentList;
	protected List<Case> allCaseList;
	protected Database.UpsertResult[] caseSaveResultList;
	protected List<Case> caseWithSEQNoList;
	protected Map<String, MB_RestRequestInfoModel.incident_model> incidentRequestMapByMobileAppKey;
	protected Map<Id, Flight__c> flightMap;
	protected Map<String, Case> emergencyCaseMap;
	protected Boolean isCreateCabinReport;
	protected Id currentUserId = UserInfo.getUserId();
	protected User currentUser;
	protected Id currentUserCrewId;
	protected Crew__c currentCrew;

	public IncidentMobileFactory(List<MB_RestRequestInfoModel.incident_model> incidentList) {
		this.incidentList = incidentList;
		allCaseList = new List<Case>();
		caseSaveResultList = new List<Database.UpsertResult>();
		caseWithSEQNoList = new List<Case>();
		incidentRequestMapByMobileAppKey = new Map<String, MB_RestRequestInfoModel.incident_model>();
		flightMap = new Map<Id, Flight__c> ();
		emergencyCaseMap = new Map<String, Case>();
		isCreateCabinReport = true;

		currentUserId = UserInfo.getUserId();
		currentUser = [SELECT Id, Name FROM User WHERE Id = :currentUserId];
		currentUserCrewId = BE8_GlobalUtility.getCrewIdByUserId(currentUserId);
		currentCrew = new Crew__c();
		if(currentUserCrewId != null){
			currentCrew = [SELECT Id, Name FROM Crew__c WHERE Id = :currentUserCrewId];
		}
	}

	public void createIncident() {
		List<MB_RestRequestInfoModel.incident_model> incidentModelListWithFilter = new List<MB_RestRequestInfoModel.incident_model>();
		if (incidentList != null && !incidentList.isEmpty()) {
			incidentModelListWithFilter = filterCaseToUpdate();
			BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_INFO, instanceName, 'createIncident', 'Create Incident Log', System.JSON.serialize(incidentList), null, System.currentTimeMillis());
		}

		Set<Id> flightIdSet = new Set<Id>();
		Set<Id> crewIdSet = new Set<Id>();
		for (MB_RestRequestInfoModel.incident_model each : incidentModelListWithFilter) {
			if (each.fltId != null) {
				flightIdSet.add(each.fltId);
			}
			if (each.creBy != null) {
				crewIdSet.add(each.creBy);
			}
			if (each.repBy != null) {
				crewIdSet.add(each.repBy);
			}
		}

		Map<Id, Crew__c> crewMap = new Map<Id, Crew__c>();
		Map<Id, Passenger__c> passengerMap = new Map<Id, Passenger__c>();
		if (!crewIdSet.isEmpty()) {
			crewMap = new Map<Id, Crew__c>([SELECT Id, Name, Personel_Id__c FROM Crew__c WHERE Id IN :crewIdSet]);
		}

		if (!flightIdSet.isEmpty()) {
			flightMap = new Map<Id, Flight__c>([SELECT Id, AircraftId__c, Aircraft_Type__c, AircraftId__r.Aircraft_Main_Type__c FROM Flight__c WHERE Id IN :flightIdSet]);
			passengerMap = new Map<Id, Passenger__c>([SELECT Id, PaxKey__c, AccountId__c, Booking_Seat__c, Checkin_Seat__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet]);
		}

		Map<String, Case> passengerCaseMap = new Map<String, Case>();
		Map<String, List<Case_Group_Member__c>> passengerCaseGroupMemberMap = new Map<String, List<Case_Group_Member__c>>();
		Map<String, Case> equipmentCaseMap = new Map<String, Case>();
		Map<String, List<Case_Group_Member__c>> equipmentCaseGroupMemberMap = new Map<String, List<Case_Group_Member__c>>();
		emergencyCaseMap = new Map<String, Case>();
		Map<String, List<Case_Group_Member__c>> emergencyCaseGroupMemberMap = new Map<String, List<Case_Group_Member__c>>();
		Map<String, List<Compensation__c>> compensationMap = new Map<String, List<Compensation__c>>();
		Map<String, Case> otherCaseMap = new Map<String, Case>();
		List<Passenger__c> passengerToChangeSeatList = new List<Passenger__c>();

		for (MB_RestRequestInfoModel.incident_model eachIncidentModel : incidentModelListWithFilter) {
			incidentRequestMapByMobileAppKey.put(eachIncidentModel.id, eachIncidentModel);

			Boolean hasPassenger = (eachIncidentModel.paxMem != null && eachIncidentModel.paxMem.size() > 0);
			Boolean hasEquipment = eachIncidentModel.equipId != null && !String.isEmpty(eachIncidentModel.equipId);
			Boolean hasCrew = (eachIncidentModel.crewMem != null && eachIncidentModel.crewMem.size() > 0);
			Boolean hasStaff = (eachIncidentModel.staffMem != null && eachIncidentModel.staffMem.size() > 0);
			Boolean hasCompensation = (eachIncidentModel.compen != null && eachIncidentModel.compen.size() > 0);
			Boolean hasChangeSeat = (eachIncidentModel.chSeat != null && eachIncidentModel.chSeat.size() > 0);
			Boolean isEmergencyCase = eachIncidentModel.inCate == BE8_GlobalConstants.INCIDENT_CATEGORY_MOBILE_EMERGENCY;
			Boolean isUpdateMaintenanceCase = hasEquipment && eachIncidentModel.sfdcId != null;
			Boolean isVoided = BE8_GlobalConstants.INTEGER_TO_BOOLEAN.get(eachIncidentModel.isVoided);

			Id flightId = eachIncidentModel.fltId;
			Id aircraftId = flightMap.containsKey(eachIncidentModel.fltId) ? flightMap.get(eachIncidentModel.fltId).AircraftId__c : eachIncidentModel.aircraftId;

			System.debug('flight id' + flightId);
			System.debug('aircraft id: ' + aircraftId);
			System.debug('currentUserCrewId: ' + currentUserCrewId);
			System.debug('Get Crew: ' + crewMap.get(currentUserCrewId));
			System.debug('Incident: ' + eachIncidentModel);

			Case newCase = IncidentService.createCaseFromModel(eachIncidentModel, flightId, aircraftId);

			if (hasEquipment && !isEmergencyCase) {
				System.debug('##########eachIncidentModel.creBy: ' + eachIncidentModel.creBy);
				Crew__c crewObj = crewMap.get(eachIncidentModel.creBy);
				System.debug('###########crewObj: ' + crewObj);
				Case cabinLogCase = IncidentService.createCaseFromModel(eachIncidentModel, flightId, aircraftId);
				cabinLogCase.EquipmentId__c = eachIncidentModel.equipId;
				cabinLogCase.PartId__c = eachIncidentModel.partId != '' ? eachIncidentModel.partId : null;
				cabinLogCase.Condition_Multi__c = eachIncidentModel.condi;
				cabinLogCase.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
				cabinLogCase.Status = isVoided ? BE8_GlobalConstants.CASE_STATUS_VOID : BE8_GlobalConstants.CASE_STATUS_OPEN;
				cabinLogCase.SEQ_No_Display__c = eachIncidentModel.seqNo;
				if (crewObj != null) {
					cabinLogCase.Authorize_Number__c = crewObj.Personel_Id__c;
					cabinLogCase.Block_Name__c = crewObj.Name;
				}
				System.debug('cabinLogCase: ' + cabinLogCase);
				equipmentCaseMap.put(cabinLogCase.Mobile_App_Key__c, cabinLogCase);
				List<Case_Group_Member__c> equipmentCaseGroupMemberList = IncidentService.getEquipmentCaseGroupMemberList(eachIncidentModel.posMem, flightId, aircraftId);
				cabinLogCase.Position_Case_Group_Member__c = IncidentService.createCaseGroupMemberPositionSummaryString(equipmentCaseGroupMemberList);
				equipmentCaseGroupMemberMap.put(cabinLogCase.Mobile_App_Key__c, equipmentCaseGroupMemberList);
			}
			if ((hasPassenger || hasEquipment) && !isEmergencyCase && !isUpdateMaintenanceCase && isCreateCabinReport) {
				if (hasPassenger) {
					Id passengerId = eachIncidentModel.paxMem[0].id;
					Passenger__c retrievedPassenger = passengerMap.get(passengerId);
					Id accountId = retrievedPassenger != null ? retrievedPassenger.AccountId__c : null;
					newCase.Passengerid__c = passengerId;
					newCase.AccountId = accountId;
				}
				newCase.Status = isVoided ? BE8_GlobalConstants.CASE_STATUS_VOID : BE8_GlobalConstants.INTEGER_TO_CASE_STATUS_FOR_INFLIGHT_MAP.get(eachIncidentModel.status);
				newCase.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_IN_FLIGHT);


				passengerCaseMap.put(newCase.Mobile_App_Key__c, newCase);

				List<Case_Group_Member__c> passengerCaseGroupMemberList = new List<Case_Group_Member__c>();
				if (hasChangeSeat) {
					newCase.Change_Seat__c = eachIncidentModel.chSeat[0].toSeat;
					newCase.Change_Cabin_Class__c = eachIncidentModel.chSeat[0].toClass;
					passengerCaseGroupMemberList.addAll(IncidentService.getChangeSeatCaseGroupMemberList(eachIncidentModel.chSeat, flightId, aircraftId, newCase.Passengerid__c));
					System.debug(passengerCaseGroupMemberList);
					if (!isVoided) {
						passengerToChangeSeatList.addAll(IncidentService.createPassengerSObjectForChangeSeat(eachIncidentModel, eachIncidentModel.chSeat, newCase.Passengerid__c));
					}
				}
				if (hasPassenger && !hasChangeSeat) {
					passengerCaseGroupMemberList.addAll(IncidentService.getPassengerCaseGroupMemberList(eachIncidentModel.paxMem, flightId, aircraftId, passengerMap));
				}

				if (hasCrew) {
					passengerCaseGroupMemberList.addAll(IncidentService.getCrewCaseGroupMemberList(eachIncidentModel.crewMem, flightId, aircraftId));
					System.debug(passengerCaseGroupMemberList);
				}
				if (hasStaff) {
					passengerCaseGroupMemberList.addAll(IncidentService.getStaffCaseGroupMemberList(eachIncidentModel.staffMem, flightId, aircraftId));
					System.debug(passengerCaseGroupMemberList);
				}
				passengerCaseGroupMemberMap.put(newCase.Mobile_App_Key__c, passengerCaseGroupMemberList);
			}

			if (isEmergencyCase) {
				newCase.Emergency_Type__c = BE8_GlobalConstants.INTEGER_TO_EMERGENCY_TYPE_MAP.get(eachIncidentModel.emerType);
				newCase.Priority = BE8_GlobalConstants.CASE_PRIORITY_URGENT;
				newCase.Status = isVoided ? BE8_GlobalConstants.CASE_STATUS_VOID : BE8_GlobalConstants.INTEGER_TO_CASE_STATUS_FOR_INFLIGHT_MAP.get(eachIncidentModel.status);
				newCase.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_IN_FLIGHT);
				newCase.Emergency_Send_Email__c = true;


				emergencyCaseMap.put(newCase.Mobile_App_Key__c, newCase);
				List<Case_Group_Member__c> emergencyCaseGroupMemberList = new List<Case_Group_Member__c>();
				if (hasPassenger) {
					newCase.Passengerid__c = eachIncidentModel.paxMem[0].id;
					emergencyCaseGroupMemberList.addAll(IncidentService.getPassengerCaseGroupMemberList(eachIncidentModel.paxMem, flightId, aircraftId, passengerMap));
				}
				if (hasCrew) {
					newCase.CrewId__c = eachIncidentModel.crewMem[0].id;
					emergencyCaseGroupMemberList.addAll(IncidentService.getCrewCaseGroupMemberList(eachIncidentModel.crewMem, flightId, aircraftId));
				}
				if (hasStaff) {
					emergencyCaseGroupMemberList.addAll(IncidentService.getStaffCaseGroupMemberList(eachIncidentModel.staffMem, flightId, aircraftId));
				}
				emergencyCaseGroupMemberMap.put(newCase.Mobile_App_Key__c, emergencyCaseGroupMemberList);
			}

			if (!passengerCaseMap.containsKey(newCase.Mobile_App_Key__c) && !equipmentCaseMap.containsKey(newCase.Mobile_App_Key__c) && !emergencyCaseMap.containsKey(newCase.Mobile_App_Key__c)) {
				otherCaseMap.put(newCase.Mobile_App_Key__c, newCase);
			}

			if (hasCompensation) {
				List<Compensation__c> compensationList = new List<Compensation__c>();
				for (MB_RestRequestInfoModel.incident_compensation eachCompensationModel : eachIncidentModel.compen) {
					Compensation__c compensation = new Compensation__c();
					compensation.Id = eachCompensationModel.sfdcId;
					compensation.Compensation_Detail__c = eachCompensationModel.detail;
					compensation.Compensation_Tools__c = IncidentService.convertCompensationToolsFromInFlightToS4Wording(eachCompensationModel.type);
					//compensation.Total__c = eachCompensationModel.quantity != null ? Integer.valueOf(eachCompensationModel.quantity) : null;
					compensation.Total__c = 1; // Each compensation can only contains a single object of thing to be compensated except mileages
					if (compensation.Compensation_Tools__c == IncidentService.COMPENSATION_TOOLS_S4_MILEAGE_COMPENSATION) {
						// if it is Mileages, put the Mileages into Total__c field
						compensation.Total__c = eachCompensationModel.amount != null ? Decimal.valueOf(eachCompensationModel.amount) : null;
					}
					compensation.Amount__c = eachCompensationModel.amount != null ? Decimal.valueOf(eachCompensationModel.amount) : null;
					compensation.Status__c = BE8_GlobalConstants.APPROVED;
					compensation.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Compensation__c', BE8_GlobalConstants.IN_FLIGHT_COMPENSATION_RECORD_TYPE);
					compensation.Problem__c = eachCompensationModel.problem;
					compensation.Currency__c = eachCompensationModel.currenc;
					compensation.UpgradeCertificate__c = eachCompensationModel.upCer;
					compensation.ISC_Form_No__c = eachCompensationModel.iscFormNum;
					compensation.Item_Code_No__c = eachCompensationModel.itemCodeNum;
					compensation.From_Seat__c = eachCompensationModel.fromSeat;
					compensation.From_Class__c = eachCompensationModel.fromClass;
					compensation.To_Seat__c = eachCompensationModel.toSeat;
					compensation.To_Class__c = eachCompensationModel.toClass;
					compensation.Mobile_App_Key__c = eachCompensationModel.id;
					compensation.Created_At_Mobile__c = BE8_DateUtility.convertFromStringToDateTimeFromMobile(eachCompensationModel.creDT);
					compensationList.add(compensation);
				}
				if (!isVoided) {
					passengerToChangeSeatList.addAll(IncidentService.createPassengerSObjectForChangeSeat(eachIncidentModel, eachIncidentModel.compen, newCase.Passengerid__c));
				}
				compensationMap.put(eachIncidentModel.id, compensationList);
			}
		}

		// Insert Case
		allCaseList.addAll(passengerCaseMap.values());
		allCaseList.addAll(equipmentCaseMap.values());
		allCaseList.addAll(emergencyCaseMap.values());
		allCaseList.addAll(otherCaseMap.values());
		//upsert allCaseList;

		//List<Case> caseWithSEQNoList = new List<Case>();
		Map<String, Case> caseWithoutSEQNoMapByMobileAppKey = new Map<String, Case>();
		for (Case eachCase : allCaseList) {
			if (eachCase.SEQ_No_Display__c != null && eachCase.Id == null) {
				caseWithSEQNoList.add(eachCase);
			} else {
				caseWithoutSEQNoMapByMobileAppKey.put(eachCase.Mobile_App_Key__c, eachCase);
			}
		}

		List<Case> caseWithDuplicateSEQNoList = new List<Case>();
		System.debug('SJ before upsert caseWithSEQNoList');
		caseSaveResultList = Database.upsert(caseWithSEQNoList, Case.Fields.Id, false);
		System.debug('caseWithSEQNoList: ' + caseWithSEQNoList);
		System.debug('SJ after upsert caseWithSEQNoList');
		for (Case eachCase : caseWithSEQNoList) {
			if (eachCase.Id == null) {
				caseWithoutSEQNoMapByMobileAppKey.remove(eachCase.Mobile_App_Key__c);
				caseWithDuplicateSEQNoList.add(eachCase);
			}
		}

		if (caseWithDuplicateSEQNoList.size() > 0) {
			AppLogger.add(BE8_GlobalConstants.LEVEL_INFO, 'MB_RESTIncidentService', 'createIncident', 'Case with duplicate SEQ No', System.JSON.serialize(caseWithDuplicateSEQNoList), null, System.currentTimeMillis());
		}

		////Test ignore rules that change owner to admin
		//Database.DMLOptions options = new Database.DMLOptions();
		//  	options.assignmentRuleHeader.useDefaultRule = false;
		//  	List<Case> caseListToBeInsert = caseWithoutSEQNoMapByMobileAppKey.values();
		//  	for(Case c : caseListToBeInsert){
		//  		c.setOptions(options);
		//  	}
		//  	upsert caseListToBeInsert;


		System.debug('SJ before upsert caseWithoutSEQNoMapByMobileAppKey');
		Database.UpsertResult[] caseWithoutSEQNoMapByMobileAppKeyUpsertResultList = Database.upsert(caseWithoutSEQNoMapByMobileAppKey.values(), Case.Id, false);
		handleUpsertResultList(caseWithoutSEQNoMapByMobileAppKey.values(), caseWithoutSEQNoMapByMobileAppKeyUpsertResultList);
		System.debug('SJ after upsert caseWithoutSEQNoMapByMobileAppKey');

		List<Case_Group_Member__c> allCaseGroupMemberList = new List<Case_Group_Member__c>();
		allCaseGroupMemberList.addAll(IncidentService.assignMasterCaseToCaseGroupMember(passengerCaseMap, passengerCaseGroupMemberMap));
		allCaseGroupMemberList.addAll(IncidentService.assignMasterCaseToCaseGroupMember(equipmentCaseMap, equipmentCaseGroupMemberMap));
		allCaseGroupMemberList.addAll(IncidentService.assignMasterCaseToCaseGroupMember(emergencyCaseMap, emergencyCaseGroupMemberMap));
		Database.UpsertResult[] allCaseGroupMemberListUpsertResult = Database.upsert(allCaseGroupMemberList, Case_Group_Member__c.Id, false);
		handleUpsertResultList(allCaseGroupMemberList, allCaseGroupMemberListUpsertResult);
		System.debug(allCaseGroupMemberList);

		List<Compensation__c> compensationListWithMasterCase = IncidentService.assignMasterCaseToCompensation(passengerCaseMap, compensationMap);
		Database.UpsertResult[] compensationListUpsertResult = Database.upsert(compensationListWithMasterCase, Compensation__c.Id, false);
		handleUpsertResultList(compensationListWithMasterCase, compensationListUpsertResult);

		List<Passenger__c> dedupPassengerToChangeSeatList = PassengerService.dedupPassengerToChangeSeatList(passengerToChangeSeatList);
		Database.SaveResult[] dedupPassengerToChangeSeatListSaveResult = Database.update(dedupPassengerToChangeSeatList, false);
		handleSaveResultList(dedupPassengerToChangeSeatList, dedupPassengerToChangeSeatListSaveResult);
	}

	public void handleUpsertResultList(List<SObject> sObjectList, Database.UpsertResult[] upsertResultList) {
		for (Integer i = 0; i < upsertResultList.size(); i++) {
			Database.UpsertResult eachResult = upsertResultList[i];
			SObject eachSObject = sObjectList[i];
			if (!eachResult.isSuccess()) {
				String message = eachResult + ' ' + eachSObject;
				String referenceId = 'User: ' + currentUser.Id + '-' + currentUser.Name + ' Crew: ' + currentCrew.Name;
				AppLogger.error(instanceName, 'createIncident', referenceId, message, null);
			}
		}
	}

	public void handleSaveResultList(List<SObject> sObjectList, Database.SaveResult[] saveResultList) {
		for (Integer i = 0; i < saveResultList.size(); i++) {
			Database.SaveResult eachResult = saveResultList[i];
			SObject eachSObject = sObjectList[i];
			if (!eachResult.isSuccess()) {
				String message = eachResult + ' ' + eachSObject;
				String referenceId = 'User: ' + currentUser.Id + '-' + currentUser.Name + ' Crew: ' + currentCrew.Name;
				AppLogger.error(instanceName, 'createIncident', referenceId, message, null);
			}
		}
	}

	public void sendEmergencyEmail() {
		if (emergencyCaseMap != null && !emergencyCaseMap.isEmpty()) {
			IncidentService.sendEmergencyEmail(emergencyCaseMap.values());
		}
	}

	public void createCabinLogInSAP() {
		if (allCaseList != null && !allCaseList.isEmpty()) {
			for (Case eachCase : allCaseList) {
				if (eachCase.SEQ_No_Display__c != null) {
					try {
						Id jobId = System.enqueueJob(new CabinLogCallout_Queueable(eachCase.Id));
						if (jobId != null) {
							AppLogger.debug(instanceName, 'createCabinLogInSAP', eachCase.Id, 'enqueueJob :' + jobId, null);
						} else {
							AppLogger.error(instanceName, 'createCabinLogInSAP', eachCase.Id, 'error to enqueueJob', null);
						}
					} catch (Exception e) {
						AppLogger.error(instanceName, 'createCabinLogInSAP', eachCase.Id, 'exception', e);
					}
				}
			}
		}
	}

	public List<MB_RestRequestInfoModel.incident_model> filterCaseToUpdate() {
		List<MB_RestRequestInfoModel.incident_model> returnCaseList = new List<MB_RestRequestInfoModel.incident_model>();
		Map<Id, MB_RestRequestInfoModel.incident_model> caseFromModelMap = filterCaseWithId();
		Map<Id, Case> caseSFDCMap = new Map<Id, Case>([SELECT Id, Status, LastModifiedDate FROM Case WHERE Id IN :caseFromModelMap.keySet()]);
		for (Id key : caseFromModelMap.keySet()) {
			//Datetime modelUpdateTime = Datetime.parse(caseFromModelMap.get(key).updDT);
			Datetime modelUpdateTime = BE8_DateUtility.convertFromStringToDateTimeFromMobile(caseFromModelMap.get(key).updDT);
			if (caseSFDCMap.get(key).Status != BE8_GlobalConstants.CASE_STATUS_VOID && caseSFDCMap.get(key).Status != BE8_GlobalConstants.CASE_STATUS_CLOSED && caseSFDCMap.get(key).LastModifiedDate < modelUpdateTime) {
				returnCaseList.add(caseFromModelMap.get(key));
			}
		}
		returnCaseList.addAll(filterCaseWithNoId());
		return returnCaseList;
	}

	public Map<Id, MB_RestRequestInfoModel.incident_model> filterCaseWithId() {
		Map<Id, MB_RestRequestInfoModel.incident_model> returnMap = new Map<Id, MB_RestRequestInfoModel.incident_model>();
		for (MB_RestRequestInfoModel.incident_model c : incidentList) {
			if (c.sfdcId != null) {
				returnMap.put(c.sfdcId, c);
			}
		}
		return returnMap;
	}

	public List<MB_RestRequestInfoModel.incident_model> filterCaseWithNoId() {
		List<MB_RestRequestInfoModel.incident_model> returnList = new List<MB_RestRequestInfoModel.incident_model>();
		for (MB_RestRequestInfoModel.incident_model c : incidentList) {
			if (c.sfdcId == null) {
				returnList.add(c);
			}
		}
		return returnList;
	}

	public abstract List<MB_RestResponseInfoModel.incident_model> generateResponseList();
	//public List<MB_RestResponseInfoModel.incident_model> generateResponseList() {
	//	Set<Id> caseIdSetAfterInsert = BE8_GlobalUtility.getIdSet('Id', allCaseList);
	//	List<Case> caseListFromDatabase = Database.query(IncidentService.caseQueryWithoutCGM + ' WHERE Id IN :caseIdSetAfterInsert');
	//	Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId = new Map<Id, List<Case_Group_Member__c>>();
	//	for (Case_Group_Member__c eachCGM : Database.query('SELECT ' + IncidentService.caseGroupMemberFields + ' FROM Case_Group_Member__c WHERE Caseid__c IN :caseIdSetAfterInsert')) {
	//		if (!cgmListMapByCaseId.containsKey(eachCGM.Caseid__c)) {
	//			cgmListMapByCaseId.put(eachCGM.Caseid__c, new List<Case_Group_Member__c>());
	//		}
	//		cgmListMapByCaseId.get(eachCGM.Caseid__c).add(eachCGM);
	//	}

	//	List<MB_RestResponseInfoModel.incident_model> responseList = IncidentService.createIncidentModelList(caseListFromDatabase, cgmListMapByCaseId);
	//	responseList.addAll(IncidentService.createIncidentModelListForErrorRecords(caseSaveResultList, caseWithSEQNoList, incidentRequestMapByMobileAppKey, flightMap));
	//	return responseList;
	//}
}