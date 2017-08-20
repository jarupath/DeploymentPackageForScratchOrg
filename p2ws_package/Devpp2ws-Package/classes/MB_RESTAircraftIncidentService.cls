@RestResource(urlMapping = '/aircraftincident/*')
global without sharing class MB_RESTAircraftIncidentService {

    @HttpGet
    global static List<MB_RestResponseInfoModel.incident_model> retrieveIncidentInfo() {
        Set<Id> allAircraftIdSet = new Map<Id, Aircraft__c>([SELECT Id FROM Aircraft__c]).keySet();
        Set<String> caseStatusNotIncludedSet = new Set<String> {BE8_GlobalConstants.CASE_STATUS_CLOSED, BE8_GlobalConstants.CASE_STATUS_VOID};
        List<Case> aircraftCaseList = IncidentService.getAircraftCaseList(allAircraftIdSet, caseStatusNotIncludedSet, new Set<Id>());
        return IncidentService.retrieveIncidentInfo(aircraftCaseList);
    }

    @HttpPut
    global static List<MB_RestResponseInfoModel.incident_model> retrievePartialIncidentInfo(String sync) {
        String lastSyncTimeString = sync;
        Set<String> acRegSet;
        Set<String> acTypeSet;
        User thisUser = [SELECT Id, A_C_REG__c, A_C_Type__c, Station__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String acQuery = 'SELECT Id FROM Aircraft__c ';
        //List<String> conditionList = new List<String>();
        //if (thisUser.A_C_REG__c != null) {
        //    acRegSet = new Set<String>(thisUser.A_C_REG__c.split(','));
        //    conditionList.add('Aircraft_Registration__c IN :acRegSet');
        //}
        //if (thisUser.A_C_Type__c != null) {
        //    acTypeSet = new Set<String>(thisUser.A_C_Type__c.split(','));
        //    conditionList.add('Aircraft_Main_Type__c IN :acTypeSet');
        //}
        //String condition = '';
        //if (!conditionList.isEmpty()) {
        //    condition += 'WHERE Id != null';
        //    for (String eachCondition : conditionList) {
        //        condition += ' AND ' + eachCondition;
        //    }
        //}
        //System.debug(acQuery + condition);
        //List<Aircraft__c> aircraftList = Database.query(acQuery + condition);
        List<Aircraft__c> aircraftList = Database.query(acQuery);
        System.debug('aircraftList: ' + aircraftList);
        DateTime lastSyncTime = null;
        if (lastSyncTimeString != null && !String.isEmpty(lastSyncTimeString)) {
            lastSyncTime = BE8_DateUtility.convertFromStringToDateTimeFromMobile(lastSyncTimeString);
        }

        Set<Id> allAircraftIdSet = new Map<Id, Aircraft__c>(aircraftList).keySet();
        Set<String> caseStatusNotIncludedSet = new Set<String> {BE8_GlobalConstants.CASE_STATUS_CLOSED, BE8_GlobalConstants.CASE_STATUS_VOID};
        List<Case> aircraftCaseList = IncidentService.getAircraftCaseList(allAircraftIdSet, caseStatusNotIncludedSet, new Set<Id>(), lastSyncTime);
        return IncidentService.retrieveIncidentInfo(aircraftCaseList);
    }

    @HttpPost
    global static List<MB_RestResponseInfoModel.incident_model> createIncident(List<MB_RestRequestInfoModel.incident_model> incidentList) {
        MaintenanceAppIncidentFactory factory = new MaintenanceAppIncidentFactory(incidentList);
        factory.createIncident();
        factory.createCabinLogInSAP();
        List<MB_RestResponseInfoModel.incident_model> responseList = factory.generateResponseList();
        AppLogger.insertLogs();
        return responseList;
    }
}