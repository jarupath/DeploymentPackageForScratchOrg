trigger Compensation_Trigger on Compensation__c (after insert, after update, before insert, before update, after delete) {
    if (TriggerActivator.isTriggerActivated(TriggerActivator.COMPENSATION_TRIGGER)) {
        list<Compensation__c> listauto_comp = new list<Compensation__c>();
        List<Compensation__c> compenList = Trigger.new;
        String SNEW = 'New';
        Map<String, RecordType> caseRecordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
  

        if (Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert || Trigger.isDelete)) {
            Set<Id> caseIdSet = new Set<Id>();
            if(!Trigger.isDelete){
                caseIdSet = BE8_GlobalUtility.getidset('CaseId__c', Trigger.new);
            }
            else{
                caseIdSet = BE8_GlobalUtility.getidset('CaseId__c', Trigger.old);
            }
            
            //List<Case> caseList = new List<Case>();
            //List<Case> caseListToBeUpdate = new List<Case>();
            Map<Id, Case> caseListToBeUpdate = new Map<Id, Case>();
            Map<String, List<SObject>> compenMap = BE8_GlobalUtility.getSObjectListMap('CaseId__c', [SELECT Id, Currency__c, Amount__c, Status__c, CaseId__c, Compensation_Detail__c, Compensation_Tools__c FROM Compensation__c WHERE CaseId__c IN :caseIdSet AND Status__c != 'Obsolete']);
            Map<String, List<SObject>> gcaseMap = BE8_GlobalUtility.getSObjectListMap('CaseId__c', [SELECT Id, CaseId__c, PassengerId__r.First_Name__c, PassengerId__r.Last_Name__c, PassengerId__r.PNR__c FROM Case_Group_Member__c WHERE CaseId__c IN :caseIdSet]);
            List<Case> caseList = [SELECT Id, Case_Type__c FROM Case WHERE Id IN :caseIdSet];
            System.debug('email template');
            System.debug('caseIdSet - ' + caseIdSet);
            System.debug('compenMap - ' + compenMap);
            System.debug('gcaseMap - ' + gcaseMap);
            System.debug('caseList' + caseList);
            if (compenMap != null && gcaseMap != null && caseList != null && !compenMap.isEmpty() && !gcaseMap.isEmpty() && !caseList.isEmpty()) {
                Map<String, String> caseEmailTemplateMap = Case_Management.getEmailTemplateString(gcaseMap, compenMap, caseList);
                for (String caseId : caseEmailTemplateMap.keySet()) {
                    //caseListToBeUpdate.add(new Case(Id = caseId, DGC_DBC_Email_Body__c = caseEmailTemplateMap.get(caseId)));
                    caseListToBeUpdate.put(caseId, new Case(Id = caseId, DGC_DBC_Email_Body__c = caseEmailTemplateMap.get(caseId)));
                }

                //update caseListToBeUpdate;
            }
            if(compenMap != null && !compenMap.isEmpty() && caseList != null && !caseList.isEmpty()){
                Map<String, String> caseCompensationTools = Case_Management.getCaseCompensationToolsString(caseList, compenMap);
                for (String caseId : caseCompensationTools.keySet()) {
                    if(!caseListToBeUpdate.isEmpty() && caseListToBeUpdate.containsKey(caseId)){
                        caseListToBeUpdate.get(caseId).Compensation_Tool__c = caseCompensationTools.get(caseId);
                    }
                    else{
                        caseListToBeUpdate.put(caseId, new Case(Id = caseId, Compensation_Tool__c = caseCompensationTools.get(caseId)));
                    }
                }

                //update caseListToBeUpdate;
            }
            if(!caseListToBeUpdate.isEmpty()){
                update caseListToBeUpdate.values();
            }
        }

        if(!Trigger.isDelete){
            for (Compensation__c comp : Trigger.new) {
                if (Trigger.Isinsert) {
                    if (Trigger.Isafter) {

                    } else {
                        if (comp.status__c == SNEW)
                            listauto_comp.add(comp);
                    }
                } else { //Isupdate
                    Compensation__c oldcomp = trigger.oldmap.get(comp.Id);

                    if (Trigger.Isafter) {

                    } else {
                        if ((comp.status__c != oldcomp.status__c) && comp.Status__c == SNEW) {
                            listauto_comp.add(comp);
                        }
                    }
                }
            }       
        }


        if (listauto_comp.size() > 0) {
            Compensation_Management.autoapprovecompensation(listauto_comp);
        }
    }
}