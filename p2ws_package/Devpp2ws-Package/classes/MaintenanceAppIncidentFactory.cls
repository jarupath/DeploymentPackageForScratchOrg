public without sharing class MaintenanceAppIncidentFactory extends IncidentMobileFactory {
	public MaintenanceAppIncidentFactory(List<MB_RestRequestInfoModel.incident_model> incidentList) {
		super(incidentList);
		instanceName = 'MaintenanceAppIncidentFactory';
		isCreateCabinReport = false;
	}

	public override List<MB_RestResponseInfoModel.incident_model> generateResponseList() {
		Set<Id> caseIdSetAfterInsert = BE8_GlobalUtility.getIdSet('Id', allCaseList);
		List<Case> caseListFromDatabase = Database.query(IncidentService.caseQueryWithoutCGM + ' WHERE Id IN :caseIdSetAfterInsert AND SEQ_No_Display__c != null');
		System.debug('caseListFromDatabase: ' + caseListFromDatabase);
		Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId = new Map<Id, List<Case_Group_Member__c>>();
		for (Case_Group_Member__c eachCGM : Database.query('SELECT ' + IncidentService.caseGroupMemberFields + ' FROM Case_Group_Member__c WHERE Caseid__c IN :caseIdSetAfterInsert')) {
			if (!cgmListMapByCaseId.containsKey(eachCGM.Caseid__c)) {
				cgmListMapByCaseId.put(eachCGM.Caseid__c, new List<Case_Group_Member__c>());
			}
			cgmListMapByCaseId.get(eachCGM.Caseid__c).add(eachCGM);
		}

		List<MB_RestResponseInfoModel.incident_model> responseList = IncidentService.createIncidentModelList(caseListFromDatabase, cgmListMapByCaseId);
		System.debug('caseSaveResultList: ' + caseSaveResultList);
		System.debug('caseWithSEQNoList: ' + caseWithSEQNoList);
		responseList.addAll(IncidentService.createIncidentModelListForErrorRecords(caseSaveResultList, caseWithSEQNoList, incidentRequestMapByMobileAppKey, flightMap));
		return responseList;
	}
}