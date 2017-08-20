@RestResource(urlMapping = '/lopa/*')
global class MB_RESTLOPAService {
	@HttpGet
	global static List<MB_RestResponseInfoModel.lopaInfo_model> retrieveLOPAInfo() {
		Id currentUserId = UserInfo.getUserId();
		User currentUser = [SELECT Id, Name FROM User WHERE Id = :currentUserId LIMIT 1];
		Crew__c currentCrew = [SELECT Id, Name FROM Crew__c WHERE Id = :BE8_GlobalUtility.getCrewIdByUserId(currentUserId) LIMIT 1];
		List<MB_RestResponseInfoModel.lopaInfo_model> result = new List<MB_RestResponseInfoModel.lopaInfo_model>();
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(currentUserId);
		List<Flight__c> flightList = [SELECT Id, AircraftId__c, Flight_External_ID__c, Leg_Number__c FROM Flight__c WHERE Id IN :flightIdSet];

		//Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('Id', flightList);
		Set<Id> aircrafIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', flightList);

		Map<String, SObject> attachmentMap = BE8_GlobalUtility.getSObjectMap('ParentId', [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN :flightIdSet AND Name LIKE 'Master%']);
		Map<String, SObject> passengerMapByFlightIdAndSeatNumber = BE8_GlobalUtility.getSObjectMap(new Set<String> {'FlightId__c', 'Checkin_Seat__c'}, [SELECT Id, Checkin_Seat__c , Booking_Seat__c, FFP_Tier__c, FFP_Carrier__c, FlightId__c, Cabin_Code__c, AccountId__r.Last_Name__c, AccountId__r.Date_Of_Birth__c, Last_Name__c, Date_of_Birth_Input__c, Match_with_ROP__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet AND Checkin_Seat__c != null]);
		List<String> caseImpactList = new List<String> {BE8_GlobalConstants.IMPACT_BLOCK, BE8_GlobalConstants.IMPACT_MALFUNCTION};
		Set<String> caseStatusNotIncludedSet = new Set<String> {BE8_GlobalConstants.CASE_STATUS_CLOSED, BE8_GlobalConstants.CASE_STATUS_VOID};
		Map<String, List<SObject>> caseMapByAircraftIdAndPosition = BE8_GlobalUtility.getSObjectListMap(new Set<String> {'Aircraft__c', 'Position__c'}, [SELECT Id, Impact__c, Position__c, Aircraft__c FROM Case_Group_Member__c WHERE Aircraft__c IN :aircrafIdSet AND Impact__c IN :caseImpactList AND Position__c != null AND CaseId__r.Status NOT IN :caseStatusNotIncludedSet ORDER BY CreatedDate ASC]);

		Integer lopaSize = 0;
		String lopaFltId = '';
		for (Flight__c flight : flightList) {
			if (attachmentMap.containsKey(flight.Id)) {
				Attachment lopaFile = (Attachment) attachmentMap.get(flight.Id);
				MB_RestResponseInfoModel.lopaInfo_model lopaModel = (MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class);
				MB_RestResponseInfoModel.lopaInfo_model lopaModelWithStatus = LOPAService.assignStatusToLOPA(lopaModel, flight, passengerMapByFlightIdAndSeatNumber, caseMapByAircraftIdAndPosition, new InFlightLOPAStatusHandler());
				if (lopaModel != null && lopaModel.lopaPos != null) {
					lopaFltId += lopaModel.fltId + ',';
					lopaSize += lopaModel.lopaPos.size();
				}
				result.add(lopaModelWithStatus);
			}
		}
		Applogger.debug('MB_RESTLOPAService', 'retrieveLOPAInfo', '' + flightIdSet, 'User: ' + currentUser.Id + '-' + currentUser.Name + ' Crew: ' + currentCrew.Name + ' retrieved LOPA size: ' + lopaSize + ' from: ' + lopaFltId, null);
		AppLogger.insertLogs();
		return result;
	}


}