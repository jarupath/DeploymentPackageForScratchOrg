public without sharing class InFlightAppIncidentFactory extends IncidentMobileFactory{
	public InFlightAppIncidentFactory(List<MB_RestRequestInfoModel.incident_model> incidentList) {
		super(incidentList);
		instanceName = 'InFlightAppIncidentFactory';
		isCreateCabinReport = true;
	}

	public override List<MB_RestResponseInfoModel.incident_model> generateResponseList() {
		Set<Id> caseIdSetAfterInsert = BE8_GlobalUtility.getIdSet('Id', allCaseList);
		List<Case> caseListFromDatabase = Database.query(IncidentService.caseQueryWithoutCGM + ' WHERE Id IN :caseIdSetAfterInsert');
		Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId = new Map<Id, List<Case_Group_Member__c>>();
		for (Case_Group_Member__c eachCGM : Database.query('SELECT ' + IncidentService.caseGroupMemberFields + ' FROM Case_Group_Member__c WHERE Caseid__c IN :caseIdSetAfterInsert')) {
			if (!cgmListMapByCaseId.containsKey(eachCGM.Caseid__c)) {
				cgmListMapByCaseId.put(eachCGM.Caseid__c, new List<Case_Group_Member__c>());
			}
			cgmListMapByCaseId.get(eachCGM.Caseid__c).add(eachCGM);
		}

		List<MB_RestResponseInfoModel.incident_model> responseList = IncidentService.createIncidentModelList(caseListFromDatabase, cgmListMapByCaseId, new InFlightIncidentStatusHandler());
		responseList.addAll(IncidentService.createIncidentModelListForErrorRecords(caseSaveResultList, caseWithSEQNoList, incidentRequestMapByMobileAppKey, flightMap));
		return responseList;
	}
}