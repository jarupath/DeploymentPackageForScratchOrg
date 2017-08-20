trigger Case_Group_Member_Trigger on Case_Group_Member__c (after Insert, after update, before Insert, before update, before delete, after delete) {
    System.debug('enter Case_Group_Member__c');
    Integer noQueriesWhenStart = Limits.getQueries();
    String triggerStatus = Trigger.isBefore == true ? 'Before' : 'After';
    String triggerEvent = Trigger.isInsert == true ? 'Insert' : 'Update';
    Case_Management.PrintLimit('CG: 3', triggerEvent, triggerStatus);
    if (TriggerActivator.isTriggerActivated(TriggerActivator.CASE_GROUP_MEMBER_TRIGGER)) {

        Map<String, RecordType> caseRecordTypeMap = BE8_RecordTypeRepository.getInstance().getRecordTypeMapByDevName('Case');
        Id MAINTENANCE_RECORDTYPE = caseRecordTypeMap.get('Maintenance').Id;
        Id NEW_MAINTENANCE_RECORDTYPE = caseRecordTypeMap.get('New_Maintenance').Id;
        Id CFMSVIEW_RECORDTYPE = caseRecordTypeMap.get('Customer_Feedback_View').Id;

        Set<Id> caseIdSet = new Set<Id>();
        Set<Id> caseIdSetForDeleteCGM = new Set<Id>();
        if (!Trigger.isDelete) {
            for (Case_Group_Member__c newCaseGroupMember : Trigger.new) {
                if (newCaseGroupMember.Caseid__c != null) {
                    caseIdSet.add(newCaseGroupMember.Caseid__c);
                }
            }
        } else {
            for (Case_Group_Member__c oldCaseGroupMember : Trigger.old) {
                if (oldCaseGroupMember.Caseid__c != null) {
                    caseIdSet.add(oldCaseGroupMember.Caseid__c);
                    caseIdSetForDeleteCGM.add(oldCaseGroupMember.Caseid__c);
                }
            }
        }

        if (Trigger.isBefore && Trigger.isInsert) {
            Map<Id, Case> caseMap = Case_TriggerHandler.getCaseMap(caseIdSet);
            for (Case_Group_Member__c newCaseGroupMember : Trigger.new) {
                if (caseMap.containsKey(newCaseGroupMember.Caseid__c)) {
                    newCaseGroupMember.Defect_Type__c = caseMap.get(newCaseGroupMember.Caseid__c).Condition_Multi__c;
                }
            }
        }
        if(Trigger.isBefore && Trigger.isDelete){
            Case_TriggerHandler.getCaseMap(caseIdSet);
        }

        Map<Id, Set<String>> caseMemberMap = new Map<Id, Set<String>>();
        List<Case_Group_Member__c> inputCaseGroup = Trigger.new;

        /**
        
            PROCESS BUILDER SESSION

        */
        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){

            Set<Id> flightOrAircraftIdSet = new Set<Id>();
            for(Case_Group_Member__c eachCGM : Trigger.new) {
                Boolean needUpdateEquipment = eachCGM.Position__c != null && eachCGM.Equipment__c == null;
                if(needUpdateEquipment) {
                    if(String.isNotEmpty(eachCGM.FlightId__c)) {
                        flightOrAircraftIdSet.add(eachCGM.FlightId__c);
                    } else if(String.isNotEmpty(eachCGM.Aircraft__c)) {
                        flightOrAircraftIdSet.add(eachCGM.Aircraft__c);
                    }    
                }
            }

            Map<Id, Map<String, String>> positionListMap = LOPAService.getAllLOPAPositionsMapByEquipment(flightOrAircraftIdSet);
            for(Case_Group_Member__c eachCGM : Trigger.new) {
                Boolean needUpdateEquipment = eachCGM.Position__c != null && eachCGM.Equipment__c == null;
                if(needUpdateEquipment) {
                    if(String.isNotBlank(eachCGM.FlightId__c) && positionListMap.containsKey(eachCGM.FlightId__c)) {
                        Map<String, String> positionMap = positionListMap.get(eachCGM.FlightId__c);
                        eachCGM.Equipment__c = positionMap.get(eachCGM.Position__c);
                    } else if(String.isNotBlank(eachCGM.Aircraft__c) && positionListMap.containsKey(eachCGM.Aircraft__c)) {
                        Map<String, String> positionMap = positionListMap.get(eachCGM.Aircraft__c);
                        eachCGM.Equipment__c = positionMap.get(eachCGM.Position__c);
                    }
                }
            }

            System.debug('JK: Before PROCESS BUILDER SESSION');
            System.debug(JSON.serialize(inputCaseGroup));
            if(Trigger.isInsert){
                Set<Id> paxCGMIdSet = BE8_GlobalUtility.getIdSet('PassengerId__c', inputCaseGroup);
                Map<Id, Passenger__c> paxCGMMap = Case_TriggerHandler.getPaxCGMList(paxCGMIdSet);
                System.debug('paxMapIdSet: ' + JSON.serialize(paxCGMIdSet));
                System.debug('paxCGMMap: ' + JSON.serialize(paxCGMMap));
                for(Case_Group_Member__c cgm : inputCaseGroup){
                    if(cgm.PassengerId__c != null && paxCGMMap.containsKey(cgm.PassengerId__c)){
                        System.debug('JK: update CGM on insert');
                        cgm.Passenger_Class_Search__c = paxCGMMap.get(cgm.PassengerId__c).Cabin_Code__c;
                        cgm.Passenger_Name_Search__c = paxCGMMap.get(cgm.PassengerId__c).Name;
                        cgm.Passenger_Seat_Search__c = paxCGMMap.get(cgm.PassengerId__c).Checkin_Seat__c;
                    }
                }
            }
            else if(Trigger.isUpdate){
                Map<Id, Case_Group_Member__c> oldCaseGroupMap = Trigger.oldMap;
                Set<Id> paxCGMToBeUpdate = new Set<Id>();
                for(Case_Group_Member__c cgm : inputCaseGroup){
                    if(cgm.PassengerId__c != oldCaseGroupMap.get(cgm.Id).PassengerId__c){
                        paxCGMToBeUpdate.add(cgm.PassengerId__c);
                    }
                }

                if(!paxCGMToBeUpdate.isEmpty()){
                    Map<Id, Passenger__c> paxCGMMap = Case_TriggerHandler.getPaxCGMList(paxCGMToBeUpdate);
                    for(Case_Group_Member__c cgm : inputCaseGroup){
                        if(cgm.PassengerId__c != null && paxCGMMap.containsKey(cgm.PassengerId__c)){
                            cgm.Passenger_Class_Search__c = paxCGMMap.get(cgm.PassengerId__c).Cabin_Code__c;
                            cgm.Passenger_Name_Search__c = paxCGMMap.get(cgm.PassengerId__c).Name;
                            cgm.Passenger_Seat_Search__c = paxCGMMap.get(cgm.PassengerId__c).Checkin_Seat__c;
                        }
                    }
                }
            }
            System.debug('JK: Case Group Member - Process builder');
            System.debug(JSON.serialize(inputCaseGroup));
        }
        /**
            END PROCESS BUILDER SESSION
        */

        if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)) {
            Map<Id, Case> caseMapForUpdate = new Map<Id, Case>();
            if (Trigger.isInsert || Trigger.isUpdate) {
                for (Case_Group_Member__c member : inputCaseGroup) {
                    if (member.Master_Case_Recode_Type_Id__c == MAINTENANCE_RECORDTYPE && member.Position__c != null && !String.isEmpty(member.Position__c)) {
                        if (caseMemberMap.containsKey(member.Caseid__c)) {
                            caseMemberMap.get(member.Caseid__c).add(member.Position__c);
                        } else {
                            Set<String> positionSet = new Set<String>();
                            positionSet.add(member.Position__c);
                            caseMemberMap.put(member.Caseid__c, positionSet);
                        }
                    }
                }
                System.debug('caseMemberMap: ' + JSON.serialize(caseMemberMap));
                if (caseMemberMap.size() > 0) {
                    Map<Id, Case> caseMap = Case_TriggerHandler.getCaseMapByRecordType(MAINTENANCE_RECORDTYPE);
                    if(caseMap == null || caseMap.isEmpty()){
                        caseMap = Case_TriggerHandler.getCaseMap(BE8_GlobalUtility.getIdSet('Caseid__c', Trigger.new));
                    }
                    System.debug('caseMap: ' + caseMap);
                }
            }

            List<Case> caseListToBeUpdate = new List<Case>();

            Set<Id> paxCGMIdSet = BE8_GlobalUtility.getIdSet('PassengerId__c', inputCaseGroup);
            System.debug('inputCaseGroup: ' + inputCaseGroup);
            System.debug('paxCGMIdSet' + paxCGMIdSet);
            Map<Id, Passenger__c> paxCGMMap = Case_TriggerHandler.getPaxCGMList(paxCGMIdSet);
            List<Case_Group_Member__c> cgmList = Case_TriggerHandler.getCGMListPaxInfoWithCaseId(inputCaseGroup, paxCGMMap, MAINTENANCE_RECORDTYPE);

            //Map<String, List<SObject>> gcaseMap = BE8_GlobalUtility.getSObjectListMap('CaseId__c', [SELECT Id, CaseId__c, PassengerId__r.First_Name__c, PassengerId__r.Last_Name__c, PassengerId__r.PNR__c FROM Case_Group_Member__c WHERE CaseId__c IN :caseIdSet AND RecordTypeId != :MAINTENANCE_RECORDTYPE]);
            Map<String, List<SObject>> compenMap = BE8_GlobalUtility.getSObjectListMap('CaseId__c', [SELECT Id, Currency__c, Amount__c, Status__c, CaseId__c, Compensation_Detail__c, Compensation_Tools__c, Is_Individual__c, Case_Group_Member__c, Case_Group_Member__r.PassengerId__c FROM Compensation__c WHERE CaseId__c IN :caseIdSet AND RecordTypeId != :MAINTENANCE_RECORDTYPE AND Status__c != 'Obsolete']);
            Map<String, List<SObject>> gcaseMap = BE8_GlobalUtility.getSObjectListMap('CaseId__c', [SELECT Id, CaseId__c, PassengerId__c, PassengerId__r.Name, PassengerId__r.Cabin_Code__c, PassengerId__r.Checkin_Seat__c, PassengerId__r.First_Name__c, PassengerId__r.Last_Name__c, PassengerId__r.PNR__c, Passenger_Name_Search__c FROM Case_Group_Member__c WHERE CaseId__c IN :caseIdSet]);
            List<Case> caseList = Case_TriggerHandler.getCaseListByExcludeRecordTypeId(MAINTENANCE_RECORDTYPE);

            System.debug('JK: getCGMListPaxInfoWithCaseId');
            System.debug(JSON.serialize(cgmList));

            System.debug('email template');
            System.debug(compenMap);
            System.debug(gcaseMap);
            System.debug(caseList);

            if (gcaseMap != null && caseList != null && !gcaseMap.isEmpty() && !caseList.isEmpty()) {
                Map<String, String> caseEmailTemplateMap = Case_Management.getEmailTemplateString(gcaseMap, compenMap, caseList);
                for (String caseId : caseEmailTemplateMap.keySet()) {
                    caseMapForUpdate.put(caseId, new Case(Id = caseId, DGC_DBC_Email_Body__c = caseEmailTemplateMap.get(caseId)));
                }
            }
            if (!caseMapForUpdate.isEmpty()) {
                update caseMapForUpdate.values();
            }
        }
    }

    Case_Management.PrintLimit('CG: 128', triggerEvent, triggerStatus);

    Integer noQueriesWhenFinish = Limits.getQueries();
    String noQueriesDebug = 'noQueriesDebug : Case_Group_Member_Trigger';
    if (Trigger.isBefore)        noQueriesDebug += 'BEFORE ';
    else if (Trigger.isAfter)    noQueriesDebug += 'AFTER ';

    if (Trigger.isInsert)        noQueriesDebug += 'INSERT ';
    else if (Trigger.isUpdate)   noQueriesDebug += 'UPDATE ';
    else if (Trigger.isDelete)   noQueriesDebug += 'DELETE ';
    Integer noUsageQueries = noQueriesWhenFinish - noQueriesWhenStart;
    //noQueriesDebug += noUsageQueries;
    System.debug(noQueriesDebug + '[' + noUsageQueries + ']' + '-' + Limits.getQueries());
}