public without sharing class Case_TriggerHandler extends TriggerHandler {
	private static Case_TriggerHandler instance = null;
	private static final String NOESCALATETOS3GROUPNAME = 'No Escalate to S3';
	static Map<Id, Aircraft__c> aircraftMapForUpdate = null;
	static Map<Id, User> roleMap = null;
	static System_Configuration__c sysconfig = null;
	static Map<Id, Passenger__c> paxMap = null;
	static Map<Id, Flight__c> flightMap = null;
	static Map<Id, Passenger__c> paxCGMMap = null;
	static Map<Id, Compensation__c> compenMap = null;
	static Map<String, Group> queueMap = null;
	static Map<String, String> stationQMap = null;
	static Map<Id, Profile> profileMap = null;
	static Map<Id, Task> taskMap = null;
	static Map<String, RecordType> recMap = null;
	static Boolean isUpdateLackReportFlag = false;
	static Map<Id, Group> queueMapById = null;
	static Map<Id, String> noEscalateToS3GroupMap = null;
	static Map<String, CaseStatus> caseStatusClosedMap = null;


	static Map<Id, Case> caseMap = null;

	public void setupAircraft(Set<Id> aircraftIdSet) {
		Id MAINTENANCE_RECORDTYPE = BE8_RecordTypeRepository.getInstance().getRecordTypeMapByDevName('Case').get('Maintenance').Id;
		aircraftMapForUpdate = new Map<Id, Aircraft__c>([SELECT Id, (SELECT Id, Number_Of_Blocks__c, Number_Of_Completes__c, Number_Of_Malfunctions__c, Number_Of_Serviceables__c, Number_Of_NoActions__c FROM Cases__r WHERE Status NOT IN (:BE8_GlobalConstants.CASE_STATUS_CLOSED, :BE8_GlobalConstants.CASE_STATUS_VOID) AND RecordTypeId = :MAINTENANCE_RECORDTYPE) FROM Aircraft__c WHERE Id IN :aircraftIdSet]);
		System.debug('aircraftMapForUpdate: ' + JSON.serialize(aircraftMapForUpdate));
	}

	public Boolean isChangeNumberOfImpact(Case newCase) {
		System.debug('SJ : isChangeNumberOfImpact');
		//if(isInsert) {
		//	System.debug('SJ :isInsert :' + isInsert);
		//	return true;
		
		if(isUpdate) {
			Case oldCase = (Case)oldMap.get(newCase.Id);
			Boolean isChangeStatus = oldCase.Status != newCase.Status;
			Boolean isChangeToClosed = isChangeStatus && newCase.Status == BE8_GlobalConstants.CASE_STATUS_CLOSED;
			Boolean isChangeToVoid = isChangeStatus && newCase.Status == BE8_GlobalConstants.CASE_STATUS_VOID;
			Boolean isChangeNumber = newCase.Number_Of_Blocks__c != oldCase.Number_Of_Blocks__c
				        || newCase.Number_Of_Completes__c != oldCase.Number_Of_Completes__c
				        || newCase.Number_Of_Malfunctions__c != oldCase.Number_Of_Malfunctions__c
				        || newCase.Number_Of_Serviceables__c != oldCase.Number_Of_Serviceables__c
				        || newCase.Number_Of_NoActions__c != oldCase.Number_Of_NoActions__c;
			System.debug('SJ :isChangeNumber :' + isChangeNumber);
			System.debug('SJ :isChangeToClosed :' + isChangeToClosed);
			System.debug('SJ :isChangeToVoid :' + isChangeToVoid);
			System.debug('SJ :isChangeNumber :' + newCase.Number_Of_Blocks__c + ' ' + oldCase.Number_Of_Blocks__c);
			System.debug('SJ :isChangeStatus :' + newCase.Status + ' ' + oldCase.Status);
			if(isChangeToClosed || isChangeToVoid || isChangeNumber) {
				return true;
			} 
		}
		return false;
	}

	public void sumNumberOfImpactToAircraft() {
		System.debug('SJ : aircraftMapForUpdate :' + aircraftMapForUpdate.values().size());
		for (Aircraft__c eachAircraft : aircraftMapForUpdate.values()) {
			Decimal sumNumberOfBlocks = 0;
			Decimal sumNumberOfCompletes = 0;
			Decimal sumNumberOfMalfunctions = 0;
			Decimal sumNumberOfServiceables = 0;
			Decimal sumNumberOfNoActions = 0;
			System.debug('SJ : ' + eachAircraft.Cases__r.size());
			System.debug('SJ : ' + JSON.serialize(eachAircraft.Cases__r));
			for (Case eachCase : eachAircraft.Cases__r) {
				System.debug('SJ :' + eachCase.Id +  ' ' + eachCase.Number_Of_Blocks__c);
				sumNumberOfBlocks += eachCase.Number_Of_Blocks__c;
				sumNumberOfCompletes += eachCase.Number_Of_Completes__c;
				sumNumberOfMalfunctions += eachCase.Number_Of_Malfunctions__c;
				sumNumberOfServiceables += eachCase.Number_Of_Serviceables__c;
				sumNumberOfNoActions += eachCase.Number_Of_NoActions__c;
			}

			eachAircraft.Number_Of_Blocks__c = sumNumberOfBlocks;
			eachAircraft.Number_Of_Completes__c = sumNumberOfCompletes;
			eachAircraft.Number_Of_Malfunctions__c = sumNumberOfMalfunctions;
			eachAircraft.Number_Of_Serviceables__c = sumNumberOfServiceables;
			eachAircraft.Number_Of_NoActions__c = sumNumberOfNoActions;
		}
	}

	public void updateAircraft() {
		if (!aircraftMapForUpdate.isEmpty()) {
			update aircraftMapForUpdate.values();
		}
	}

	public static Case_TriggerHandler getInstanceWithSetup(Boolean isInsert, Boolean isUpdate, Boolean isDelete, Map<Id, sObject> oldMap) {
		instance = Case_TriggerHandler.getInstance();
		instance.setup(isInsert, isUpdate, isDelete, oldMap);
		return instance;
	}

	public static Case_TriggerHandler getInstance() {
		if (instance == null) instance = new Case_TriggerHandler();
		return instance;
	}

	public Map<Id, User> getRoleMap(){
		roleMap = roleMap == null ? new Map<Id, User>([SELECT Id, Name, UserRole.Name, Station__c, Authorized_Department_EN__c, Authorized_Department_TH__c, Authorized_Position_EN__c, Authorized_Position_TH__c, Name_TH__c FROM User]) : roleMap;
		return roleMap;
	}

	public static System_Configuration__c getSysconfig(){
		sysconfig = sysconfig == null ? [SELECT Id, TGWebMaster_Email__c, Reminder_Time__c FROM System_Configuration__c] : sysconfig;
        return sysconfig;
	}

	public static Map<String, Group> getQueueMap(){
		if(queueMap == null){
			queueMap = new Map<String, Group>();
			List<Group> gList = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
			for(Group g : gList){
				queueMap.put(g.Name, g);
			}
		}
        return queueMap;
	}

	public static Map<Id, Group> getQueueMapById(){
		if(queueMapById == null){
			if(queueMap == null){
				queueMapById = new Map<Id, Group>();
				List<Group> gList = [SELECT Id, Name FROM Group WHERE Type = 'Queue'];
				for(Group g : gList){
					queueMapById.put(g.Id, g);
				}				
			}
			else{
				queueMapById = new Map<Id, Group>();
				for(Group g : queueMap.values()){
					queueMapById.put(g.Id, g);
				}				
			}
		}
        return queueMapById;
	}

	public Map<Id, Passenger__c> getPaxList(Set<Id> paxIdSet){
		Boolean isNeededQuery = true;
		if(paxMap != null){
			Set<Id> paxMapIdSet = paxMap.keySet();
			if(paxMapIdSet.containsAll(paxIdSet) && paxMapIdSet.size() == paxIdSet.size()){
				isNeededQuery = false;
			}
		}
		paxMap = isNeededQuery == true ? getPaxMapFromDatabase(paxIdSet) : paxMap;
		return paxMap;
	}

	public static Map<Id, Passenger__c> getPaxMapFromDatabase(Set<Id> paxIdSet){
		return new Map<Id, Passenger__c>([SELECT Id, AccountId__c, FFP_Tier__c, FFP_Number__c, FlightId__c, PNR__c, Checkin_Seat__c, Cabin_Code__c, VIP_VVIP_Flag__c FROM Passenger__c WHERE Id IN :paxIdSet]);
	}

	public Map<Id, Flight__c> getFlightMap(Set<Id> flightIdSet, Set<String> flightNameSet){
		Boolean isNeededQuery = true;
		if(flightMap != null){
			List<String> flightNameList = new List<String>(flightNameSet);
			Boolean isFlightNameContainInFlightMap = flightNameSet != null ? isContainFlightInMap(flightNameList) : true;
			Set<Id> flightMapIdSet = flightMap.keySet();
			if(flightMapIdSet.containsAll(flightIdSet) && isFlightNameContainInFlightMap){
				isNeededQuery = false;
			}
		}
		flightMap = isNeededQuery == true ? new Map<Id, Flight__c> ([SELECT Id, Name, Leg_Number__c, Departure_STN__c, AircraftId__r.Aircraft_Registration__c, Flight_Date_LT__c, Sector__c FROM Flight__c WHERE Id IN :flightIdSet OR Name IN :flightNameSet]) : flightMap;
		return flightMap;
	}

	public Map<Id, Flight__c> getFlightMap(Set<Id> flightIdSet){
		Boolean isNeededQuery = true;
		if(flightMap != null){
			Set<Id> flightMapIdSet = flightMap.keySet();
			if(flightMapIdSet.containsAll(flightIdSet)){
				isNeededQuery = false;
			}
		}
		flightMap = isNeededQuery == true ? new Map<Id, Flight__c> ([SELECT Id, Name, Leg_Number__c, Departure_STN__c, AircraftId__r.Aircraft_Registration__c, Flight_Date_LT__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet]) : flightMap;
		return flightMap;
	}

	public static Map<Id, Compensation__c> getCompensationMap(Set<Id> caseIdSet){
		Boolean isNeededQuery = true;
		if(compenMap != null){
			Set<Id> compenMapIdSet = compenMap.keySet();
			if(compenMapIdSet.containsAll(caseIdSet)){
				isNeededQuery = false;
			}
		}
		compenMap = isNeededQuery == true ? getCompenMapFromQueue(caseIdSet) : compenMap;
		System.debug('JK: ' + JSON.serialize(compenMap));
		return compenMap;
	}

	public static Map<Id, Compensation__c> getCompenMapFromQueue(Set<Id> caseIdSet){
		Map<Id, Compensation__c> returnMap = new Map<Id, Compensation__c>();
		List<Compensation__c> compenList = [SELECT Id, Name, CaseId__c FROM Compensation__c WHERE CaseId__c IN :caseIdSet];
		for(Compensation__c compen : compenList){
			returnMap.put(compen.CaseId__c, compen);
		}
		return returnMap;
	}

	public static Map<String, String> getAbroadStationQueueMap(){
		if(stationQMap == null){
			List<Case_Station_Mapping__mdt> stationQList = [SELECT Id, Queue_Name__c, User_Station__c FROM Case_Station_Mapping__mdt];
			stationQMap = new Map<String, String>();
			for(Case_Station_Mapping__mdt csm : stationQList){
				stationQMap.put(csm.User_Station__c, csm.Queue_Name__c);
			}	
		}
		return stationQMap;
	}

	public static Map<Id, Profile> getProfileMap(){
		ProfileData profileData = new ProfileData();
		profileMap = profileMap == null ? profileData.getProfileMap() : profileMap;
        return profileMap;
	}

	public static Map<Id, Task> getTaskMap(Set<Id> caseIdSet){
		Boolean isNeededQuery = true;
		if(taskMap != null){
			Set<Id> taskMapIdSet = taskMap.keySet();
			if(taskMapIdSet.containsAll(caseIdSet)){
				isNeededQuery = false;
			}
		}
		taskMap = isNeededQuery == true ? getTaskMapFromQuery(caseIdSet) : taskMap;
		return taskMap;
	}

	public static Map<Id, Task> getTaskMapFromQuery(Set<Id> caseIdSet){
		List<Task> tList = [SELECT Id, ActivityDate, ReminderDateTime, WhatId FROM Task WHERE WhatId IN :caseIdSet AND Status != 'Cancelled' AND Is_Expected_Flight__c = true];
		Map<Id, Task> returnMap = tList != null && !tList.isEmpty() ? new Map<Id, Task>() : null;
		
		for(Task t : tList){
			returnMap.put(t.WhatId, t);
		}
		return returnMap;
	}

	public static Map<String, RecordType> getRecordTypeMapByDevName(){
		recMap = recMap == null ? getRecordTypeMapByDevNameFromQuery() : recMap;
		return recMap;
	}

	public static Map<String, RecordType> getRecordTypeMapByDevNameFromQuery(){
		List<RecordType> recList = [SELECT Id, Name, DeveloperName FROM RecordType];
		Map<String, RecordType> returnMap = recList != null ? new Map<String, RecordType>() : null;
		for(RecordType rec : recList){
			returnMap.put(rec.DeveloperName, rec);
		}
		return returnMap;
	}

	public static Map<Id, String> getNoEscalateToS3RoleMap(){
		noEscalateToS3GroupMap = noEscalateToS3GroupMap == null ? getGroupRoleMapByGroupName(NOESCALATETOS3GROUPNAME) : noEscalateToS3GroupMap;
		return noEscalateToS3GroupMap;
	}

	public static Map<Id, String> getGroupRoleMapByGroupName(String groupName){
		Map<Id, String> returnMap = new Map<Id, String>();
		List<Group> groupList = [SELECT Id, Related.Name, RelatedId FROM Group WHERE Type = 'Role' AND Id IN (SELECT UserorGroupId FROM GroupMember WHERE Group.Name = :groupName)];
		if(groupList != null && !groupList.isEmpty()){
			for(Group g : groupList){
				if(g.RelatedId != null && g.Related.Name != null){
					returnMap.put(g.RelatedId, g.Related.Name);
				}
			}
		}
		return returnMap;
	}

	public static Map<String, CaseStatus> getCaseClosedStatusMap(){
		caseStatusClosedMap = caseStatusClosedMap == null ? createCaseClosedStatusMap() : caseStatusClosedMap;
		System.debug('caseClosedStatusMap: ' + JSON.serialize(caseStatusClosedMap));
		return caseStatusClosedMap;
	}

	public static Map<String, CaseStatus> createCaseClosedStatusMap() {
		Map<String, CaseStatus> returncs = null;
		List<CaseStatus> caseStatusList = [SELECT Id, MasterLabel FROM CaseStatus WHERE IsClosed = true];
		if(caseStatusList != null && !caseStatusList.isEmpty()){
			returncs = new Map<String, CaseStatus>();
			for(CaseStatus cs : caseStatusList) {
				returncs.put(cs.MasterLabel, cs);
			}
		}

		return returncs;
	}

/**
	Case Group Member Section
*/
	public static Map<Id, Case> getCaseMap(Set<Id> caseIdSet){
		Boolean isNeededQuery = true;
		if(caseMap != null){
			Set<Id> caseMapIdSet = caseMap.keySet();
			if(caseMapIdSet.containsAll(caseIdSet) && caseMapIdSet.size() == caseIdSet.size()){
				isNeededQuery = false;
			}
		}
		caseMap = isNeededQuery == true ? new Map<Id, Case>([SELECT Id, Condition_Multi__c, Position_Case_Group_Member__c, RecordTypeId, Case_Type__c, (SELECT Id, Position__c FROM Case_Group_Members__r) FROM Case WHERE Id IN :caseIdSet]) : caseMap;
		return caseMap;
	}

	public static List<Case> getCaseListByRecordType(Id recordTypeId){
		List<Case> caseList = new List<Case>();
		if(caseMap != null){
			for(Case c : caseMap.values()){
				if(c.RecordTypeId == recordTypeId){
					caseList.add(c);
				}
			}
		}
		return caseList;
	}
	public static Map<Id, Case> getCaseMapByRecordType(Id recordTypeId){
		Map<Id, Case> returnMap = new Map<Id, Case>();
		if(caseMap != null){
			for(Case c : caseMap.values()){
				if(c.RecordTypeId == recordTypeId){
					returnMap.put(c.Id, c);
				}
			}
		}
		return returnMap;
	}

	public static List<Case> getCaseListByExcludeRecordTypeId(Id recordTypeId){
		List<Case> caseList = new List<Case>();
		if(caseMap != null){
			for(Case c : caseMap.values()){
				if(c.RecordTypeId != recordTypeId){
					caseList.add(c);
				}
			}
		}
		return caseList;
	}

	public static Map<Id, Passenger__c> getPaxCGMList(Set<Id> paxIdSet){
		Boolean isNeededQuery = true;
		if(paxCGMMap != null){
			Set<Id> paxMapIdSet = paxCGMMap.keySet();
			if(paxMapIdSet.containsAll(paxIdSet)){
				isNeededQuery = false;
			}
		}
		paxCGMMap = isNeededQuery == true ? new Map<Id, Passenger__c>([SELECT Id, Name, Cabin_Code__c, Checkin_Seat__c, First_Name__c, Last_Name__c, PNR__c FROM Passenger__c WHERE Id IN :paxIdSet]) : paxCGMMap;
		return paxCGMMap;
	}

	public static List<Case_Group_Member__c> getCGMListPaxInfoWithCaseId(List<Case_Group_Member__c> caseGroupList, Map<Id, Passenger__c> inputPaxMap, Id recordTypeId){
		List<Case_Group_Member__c> returnList = new List<Case_Group_Member__c>();
		if(caseGroupList != null){
			for(Case_Group_Member__c cgm : caseGroupList){
				if(cgm.Master_Case_Recode_Type_Id__c != recordTypeId){
					Case_Group_Member__c cgmMember = new Case_Group_Member__c();
					cgmMember.Caseid__c = cgm.Caseid__c;
					cgmMember.Passengerid__r = inputPaxMap.get(cgm.Passengerid__c);
					returnList.add(cgmMember);
				}
			}
		}
		return returnList;
	}

	public static Boolean isContainFlightInMap(List<String> flightNameSet){
		Set<String> fltMapNameSet = BE8_GlobalUtility.getStringSet('Name', flightMap.values());
		return fltMapNameSet.containsAll(flightNameSet);
	}

	public static void updateLackFlag(){
		isUpdateLackReportFlag = true;
	}

	public static Boolean getIsUpdateLackReportFlag(){
		return isUpdateLackReportFlag;
	}
}