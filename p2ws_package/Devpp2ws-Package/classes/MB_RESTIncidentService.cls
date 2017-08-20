@RestResource(urlMapping = '/incident/*')
global without sharing class MB_RESTIncidentService {

    @HttpGet
    global static List<MB_RestResponseInfoModel.incident_model> retrieveIncidentInfo() {
        Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
        List<Flight__c> flightList = [SELECT Id, Flight_Master__c FROM Flight__c WHERE Id IN: flightIdSet];
        Set<String> flightMasterSet = BE8_GlobalUtility.getStringSet('Flight_Master__c', flightList);

        Set<Id> aircraftIdSet = BE8_GlobalUtility.getIdSet('AircraftId__c', [SELECT Id, AircraftId__c FROM Flight__c WHERE Id IN :flightIdSet]);

        List<Passenger__c> passengerList = [SELECT Id, PaxKey__c, Checkin_Seat__c, Booking_Seat__c, AccountId__c, First_Name__c, Last_Name__c, PNR__c, Flight_Master__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet];
        Map<Id, Passenger__c> passengerMap = new Map<Id, Passenger__c>(passengerList);
        Set<Id> accountIdSet = BE8_GlobalUtility.getIdSet('AccountId__c', passengerList);

        Map<String, SObject> passengerMapByAccountId = BE8_GlobalUtility.getSObjectMap('AccountId__c', passengerList);
        //List<Case_Group_Member__c> caseGroupMemberOfAccountList = Database.query(caseGroupMemberQuery + ' WHERE AccountId__c IN :accountIdSet OR PassengerId__r.Flight_Master__c IN :flightMasterSet ORDER BY CreatedDate DESC');
        List<Case_Group_Member__c> caseGroupMemberOfAccountList = IncidentService.getCaseGroupMemberOfAccountList(accountIdSet,  flightMasterSet);
        System.debug('caseGroupMemberOfAccountList ' + caseGroupMemberOfAccountList);
        Set<Id> accountCaseIdSet = BE8_GlobalUtility.getIdSet('Caseid__c', caseGroupMemberOfAccountList);
        //List<Case> accountCaseList = Database.query(caseQuery + ' WHERE Id IN :accountCaseIdSet');
        List<Case> accountCaseList = IncidentService.getCaseList(accountCaseIdSet);
        System.debug('accountCaseList ' + accountCaseList);
        Map<Id, Case> accountCaseMap = new Map<Id, Case>(accountCaseList);

        Map<Id, Set<Case>> accountCaseMapByAccountId = new Map<Id, Set<Case>>();
        for (Case_Group_Member__c eachMember : caseGroupMemberOfAccountList) {
            Case accountCase = accountCaseMap.get(eachMember.Caseid__c);

            if (accountCase != null) {
                Set<Case> caseSet = accountCaseMapByAccountId.get(eachMember.AccountId__c);
                if (caseSet == null) {
                    caseSet = new Set<Case>();
                    accountCaseMapByAccountId.put(eachMember.AccountId__c, caseSet);
                }
                caseSet.add(accountCase);
            }
        }

        List<Case> allCaseList = new List<Case>();
        Integer accountCaseLimit = 10;
        System.debug('accountCaseMapByAccountId ' + accountCaseMapByAccountId);
        for (String key : accountCaseMapByAccountId.keySet()) {
            List<Case> caseListOfEachAccount = new List<Case>(accountCaseMapByAccountId.get(key));
            if (caseListOfEachAccount.size() > accountCaseLimit) {
                Integer exceedAmount = caseListOfEachAccount.size() - accountCaseLimit;
                for (Integer i = 0 ; i < exceedAmount; i++) {
                    caseListOfEachAccount.remove(accountCaseLimit);
                }
            }
            allCaseList.addAll(caseListOfEachAccount);
        }

        Set<Id> queriedCaseIdSet = new Set<Id>();
        queriedCaseIdSet.addAll(accountCaseIdSet);
        //List<Case> flightCaseList = Database.query(caseQuery + ' WHERE Id NOT IN :queriedCaseIdSet AND Flightid__c IN :flightIdSet ');

        Set<String> caseStatusNotIncludedSet = new Set<String> {BE8_GlobalConstants.CASE_STATUS_CLOSED, BE8_GlobalConstants.CASE_STATUS_VOID};
        //List<Case> flightCaseList = Database.query(caseQueryWithoutCGM + ' WHERE Id NOT IN :queriedCaseIdSet AND Flightid__c IN :flightIdSet AND Status NOT IN :caseStatusNotIncludedSet');
        List<Case> flightCaseList = IncidentService.getFlightCaseList(flightIdSet, caseStatusNotIncludedSet, queriedCaseIdSet);
        System.debug('flightCaseList: ' + flightCaseList);

        queriedCaseIdSet.addAll(BE8_GlobalUtility.getIdSet('Id', flightCaseList));
        Id maintenanceCaseRecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
        //List<Case> aircraftCaseList = Database.query(caseQuery + ' WHERE Id NOT IN :queriedCaseIdSet AND A_C_REG_ID__c IN :aircraftIdSet AND Status NOT IN :caseStatusNotIncludedSet AND RecordTypeId = :maintenanceCaseRecordTypeId');
        List<Case> aircraftCaseList = IncidentService.getAircraftCaseList(aircraftIdSet, caseStatusNotIncludedSet, queriedCaseIdSet);
        System.debug('aircraftCaseList: ' + aircraftCaseList);

        allCaseList.addAll(flightCaseList);
        allCaseList.addAll(aircraftCaseList);

        Set<Id> allCaseIdSet = BE8_GlobalUtility.getIdSet('Id', allCaseList);
        Map<Id, List<Case_Group_Member__c>> cgmListMapByCaseId = new Map<Id, List<Case_Group_Member__c>>();
        //for (Case_Group_Member__c eachCGM : Database.query('SELECT ' + caseGroupMemberFields + ' FROM Case_Group_Member__c WHERE Caseid__c IN :allCaseIdSet')) {
        for (Case_Group_Member__c eachCGM : IncidentService.getCaseGroupMemberFromCase(allCaseIdSet)) {
            if (!cgmListMapByCaseId.containsKey(eachCGM.Caseid__c)) {
                cgmListMapByCaseId.put(eachCGM.Caseid__c, new List<Case_Group_Member__c>());
            }
            cgmListMapByCaseId.get(eachCGM.Caseid__c).add(eachCGM);
        }

        List<MB_RestResponseInfoModel.incident_model> incidentList = IncidentService.createIncidentModelList(allCaseList, cgmListMapByCaseId, new InFlightIncidentStatusHandler());
        return incidentList;
    }

    @HttpPost
    global static List<MB_RestResponseInfoModel.incident_model> createIncident(List<MB_RestRequestInfoModel.incident_model> incidentList) { 
        InFlightAppIncidentFactory factory = new InFlightAppIncidentFactory(incidentList);
        factory.createIncident();
        factory.createCabinLogInSAP();
        factory.sendEmergencyEmail();
        List<MB_RestResponseInfoModel.incident_model> responseList = factory.generateResponseList();
        AppLogger.insertLogs();
        return responseList;
    }
}