@RestResource(urlMapping = '/lopa/detail/*')
global class MB_RESTLOPADetailService {

	global class lopaPos {
		public String pos;
		public String fltId;
		public String acReg;
		public String tclass;
		public String sts;
	}

	@HttpPost
	global static List<lopaPos> getLOPADetail(List<String> flightIdList) {
		List<lopaPos> result = new List<lopaPos>();

		Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>([SELECT Id, A_C_Reg__c, AircraftId__r.Name, Flight_External_ID__c, Leg_Number__c FROM Flight__c WHERE Id IN :flightIdList]);
		Set<Id> aircrafIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', flightMap.values());
		Map<String, SObject> passengerMapByFlightIdAndSeatNumber = BE8_GlobalUtility.getSObjectMap(new Set<String> {'FlightId__c', 'Checkin_Seat__c'}, [SELECT Id, Checkin_Seat__c , Booking_Seat__c, FFP_Tier__c, FFP_Carrier__c, FlightId__c, Cabin_Code__c FROM Passenger__c WHERE FlightId__c IN :flightIdList AND Checkin_Seat__c != null]);
		Set<String> caseStatusNotIncludedSet = new Set<String> {BE8_GlobalConstants.CASE_STATUS_CLOSED, BE8_GlobalConstants.CASE_STATUS_VOID};
		Map<String, List<SObject>> caseMapByAircraftIdAndPosition = BE8_GlobalUtility.getSObjectListMap(new Set<String> {'Aircraft__c', 'Position__c'}, [SELECT Id, Impact__c, Position__c, Aircraft__c FROM Case_Group_Member__c WHERE Aircraft__c IN :aircrafIdSet AND Position__c != null AND CaseId__r.Status NOT IN :caseStatusNotIncludedSet ORDER BY CreatedDate ASC]);

		for (Attachment lopaFile : [SELECT Id, Body, ParentId FROM Attachment WHERE Name = 'Master_LOPA.txt' AND ParentId IN :flightIdList]) {
			Flight__c flight = flightMap.get(lopaFile.ParentId);
			System.debug(lopaFile.ParentId);
			flightMap.remove(lopaFile.ParentId);
			processLOPAAttachment(result, lopaFile, flight, passengerMapByFlightIdAndSeatNumber, caseMapByAircraftIdAndPosition);
		}

		if (flightMap.size() > 0) {
			Set<Id> aircraftIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', flightMap.values());
			Map<String, List<SObject>> flightMapByAircraftId = BE8_GlobalUtility.getSObjectListMap('AircraftId__c', flightMap.values());
			for (Attachment lopaFile : [SELECT Id, Body, ParentId FROM Attachment WHERE Name = 'Master_LOPA.txt' AND ParentId IN :aircraftIdSet]) {
				System.debug('aircraftId: ' + lopaFile.ParentId);
				if (flightMapByAircraftId.containsKey(lopaFile.ParentId)) {
					List<Flight__c> flightList = (List<Flight__c>) flightMapByAircraftId.get(lopaFile.ParentId);
					System.debug('flightList: ' + flightList);
					for(Flight__c flight : flightList){
						System.debug('flight: ' + flight);
						processLOPAAttachment(result, lopaFile, flight, passengerMapByFlightIdAndSeatNumber, caseMapByAircraftIdAndPosition);
					}
				}
			}
		}

		return result;
	}

	private static void processLOPAAttachment(List<lopaPos> result, Attachment lopaFile, Flight__c flight, Map<String, SObject> passengerMapByFlightIdAndSeatNumber, Map<String, List<SObject>> caseMapByAircraftIdAndPosition) {
		MB_RestResponseInfoModel.lopaInfo_model lopaModel = (MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class);
		MB_RestResponseInfoModel.lopaInfo_model lopaModelWithStatus = LOPAService.assignStatusToLOPA(lopaModel, flight, passengerMapByFlightIdAndSeatNumber, caseMapByAircraftIdAndPosition, new MaintenanceLOPAStatusHandler());

		if (lopaModelWithStatus.lopaPos != null) {
			for (MB_RestResponseInfoModel.lopaInfo_lopaPos each : lopaModelWithStatus.lopaPos) {
				//System.debug(each.pos + ' ' + each.sts);
				if (each.sts != BE8_GlobalConstants.LOPA_STATUS_OCCUPIED) {
					lopaPos pos = new lopaPos();
					pos.pos = each.pos;
					pos.fltId = flight.Id;
					pos.acReg = flight.AircraftId__r.Name;
					pos.tclass = each.tclass;
					pos.sts = each.sts;
					result.add(pos);
				}
			}
		}
	}
}