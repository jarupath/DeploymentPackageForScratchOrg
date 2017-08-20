public with sharing class InFlightIncidentStatusHandler implements MobileIncidentStatusHandler{
	Set<String> statusToBeVoidedSet;
	Map<String, String> incidentStatusMapFromSFDCToMobile;

	public static String INFLIGHT_INCIDENT_STATUS_PENDING = '1';
	public static String INFLIGHT_INCIDENT_STATUS_RESOLVED = '2';
	public static String INFLIGHT_INCIDENT_STATUS_DEFAULT = INFLIGHT_INCIDENT_STATUS_PENDING;
	//public static String INFLIGHT_INCIDENT_STATUS_CLOSED = '3';

	public InFlightIncidentStatusHandler() {
		statusToBeVoidedSet = new Set<String>();
		incidentStatusMapFromSFDCToMobile = new Map<String, String>();
		List<Case_Status_Mapping__mdt> caseStatusMappingList = [SELECT DeveloperName, SFDC_Value__c, Mobile_App_Value__c FROM Case_Status_Mapping__mdt WHERE Mobile_App_Type__c = 'In-flight'];
		for(Case_Status_Mapping__mdt eachCaseStatusMapping : caseStatusMappingList){
			if(eachCaseStatusMapping.Mobile_App_Value__c == BE8_GlobalConstants.CASE_STATUS_VOID){
				statusToBeVoidedSet.add(eachCaseStatusMapping.SFDC_Value__c);
			} else {
				incidentStatusMapFromSFDCToMobile.put(eachCaseStatusMapping.SFDC_Value__c, eachCaseStatusMapping.Mobile_App_Value__c);
			}
		}
		//statusToBeVoidedSet = new Set<String> { BE8_GlobalConstants.CASE_STATUS_VOID,  BE8_GlobalConstants.CASE_STATUS_DUPLICATE};
		//incidentStatusMapFromSFDCToMobile = new Map<String, String> {
		//	BE8_GlobalConstants.CASE_STATUS_RESOLVED => INFLIGHT_INCIDENT_STATUS_RESOLVED,
		//	BE8_GlobalConstants.CASE_STATUS_CLOSED => INFLIGHT_INCIDENT_STATUS_RESOLVED
		//};
	}

	public MB_RestResponseInfoModel.incident_model assignIncidentStatusFromSFDCToMobile(String status, MB_RestResponseInfoModel.incident_model incident) {
		incident.status = INFLIGHT_INCIDENT_STATUS_DEFAULT;
		incident.isVoided = 0;

		Boolean isVoided = statusToBeVoidedSet.contains(status);
		if (isVoided) {
			incident.isVoided = 1;
		} else {
			if (incidentStatusMapFromSFDCToMobile.containsKey(status)) {
				incident.status = incidentStatusMapFromSFDCToMobile.get(status);
			}
		}
		return incident;
	}
}