global class Case_RemoteAction {
    public Case_RemoteAction() {
    }

    public Case_RemoteAction(ApexPages.StandardController stdController) {
    }

    public static List<String> listAllFieldSetName = new List<String> {
        'NewEdit_FlightInformation',
        'NewEdit_CaseInformation',
        'NewEdit_DefectInformation',
        'NewEdit_Referece',
        'NewEdit_Maintenance'
    };
    public static List<String> listAllFieldSetNameReadOnly = new List<String> {
        'NewEdit_FlightInformation',
        'NewEdit_CaseInformation',
        'NewEdit_DefectInformation',
        'NewEdit_Referece'
    };
    public static List<String> caseGroupMemberFieldSetNameList = new List<String> {
        'NewEdit_Maintenance'
    };

    @RemoteAction
    global static Map<String, Object> getMapDefaultValue(Boolean isEditMode) {
        Map<String, Object> mapVariable = new Map<String, Object>();
        // set Up Field Set Display Order
        Map<String, List<FieldDescribe>> mapFieldSet = getMapFieldDescByFieldSetName(listAllFieldSetName, 'Case');
        mapVariable.put('fieldSetName', listAllFieldSetName);
        mapVariable.put('fieldSetObj', mapFieldSet);
        mapVariable.put('caseGroupMemberFieldSetName', caseGroupMemberFieldSetNameList);
        mapVariable.put('caseGroupMemberFieldSetObj', getMapFieldDescByFieldSetName(caseGroupMemberFieldSetNameList, 'Case_Group_Member__c'));
        mapVariable.put('caseFieldSetLabel', getFieldSetLabelMapByFieldSetDeveloperName(listAllFieldSetName, 'Case'));

        Set<String> outputFields = new Set<String> {'OwnerId', 'Position_Case_Group_Member__c'};
        if (isEditMode) {
            Map<String, List<FieldDescribe>> readOnlyMapFieldSet = getMapFieldDescByFieldSetName(listAllFieldSetNameReadOnly, 'Case');
            for (List<FieldDescribe> eachFieldList : readOnlyMapFieldSet.values()) {
                for (FieldDescribe eachField : eachFieldList) {
                    outputFields.add(eachField.fieldAPI);
                }
            }
        }
        mapVariable.put('outputFields', outputFields);

        return mapVariable;
    }
    @RemoteAction
    global static Map<String, List<SObject>> getMapListDefaultSearchByObjectType(List<String> setObjectAPI) {
        Map<String, List<SObject>> mapDefault = new Map<String , List<SObject>>();
        String defaultField = 'Id, Name';
        Map<String, String> extraFieldByObjectAPI = new Map<String, String> {
            'Flight__c' => ',AircraftId__c,AircraftId__r.Name'
        };
        Map<String, String> extraConditionByObjectAPI = new Map<String, String> {
            'Master_Map__c' => 'WHERE Field_Name__c IN (\'SERVICE EQUIPMENT\', \'SERVICE EQUIPMENT\',\'PART\')'
        };
        for (String objectAPI : setObjectAPI) {
            String extraField = extraFieldByObjectAPI.get(objectAPI) != null ? extraFieldByObjectAPI.get(objectAPI) : '';
            String fields = defaultField + extraField;
            String extraCondition = extraConditionByObjectAPI.get(objectAPI) != null ? extraConditionByObjectAPI.get(objectAPI) : '';
            String stringSOQL = ' Select ' + fields + ' From ' + objectAPI + ' ' + extraCondition;
            stringSOQL += ' Limit 50 ';
            List<SObject> listSObject = Database.Query(stringSOQL);
            mapDefault.put(objectAPI, listSObject);
        }
        return mapDefault;
    }

    @RemoteAction
    global static List<SObject> getRecordFromSObject(String objectType, String criteria) {
        List<SObject> listSObject = new List<SObject>();
        if (objectType != null && objectType != '') {
            String stringSOQL = ' Select Id, Name From ' + objectType + ' ';
            if (criteria != null && criteria != '') {
                stringSOQL += ' Where Name like \'%' + criteria + '%\'';
            }
            stringSOQL += ' Limit 50 ';
            listSObject = Database.Query(stringSOQL);
        } else {
            // thrown error
        }
        return listSObject;
    }
    public static Map<String, List<FieldDescribe>> getMapFieldDescByFieldSetName(List<String> fieldSetNameList, String objectAPI) {
        Map<String, List<FieldDescribe>> mapFieldDescByFieldSet = new Map<String, List<FieldDescribe>>();
        for (String fieldSetName : fieldSetNameList) {
            List<FieldDescribe> listFieldDesc = SObjectHandler.getFieldOnFieldSet(objectAPI, fieldSetName);
            mapFieldDescByFieldSet.put(fieldSetName, listFieldDesc);
        }
        return mapFieldDescByFieldSet;
    }

    private static Map<String, String> getFieldSetLabelMapByFieldSetDeveloperName(List<String> fieldSetNameList, String objectAPI) {
        Map<String, Schema.FieldSet> mapFieldSet = Schema.getGlobalDescribe().get(objectAPI).getDescribe().fieldSets.getMap();
        Map<String, String> fieldSetLabelMapByFieldSetDeveloperName = new Map<String, String>();
        for (String fieldSetName : fieldSetNameList) {
            if (mapFieldSet.containsKey(fieldSetName)) {
                Schema.FieldSet fieldSet = mapFieldSet.get(fieldSetName);
                fieldSetLabelMapByFieldSetDeveloperName.put(fieldSetName, fieldSet.getLabel());
            }
        }
        return fieldSetLabelMapByFieldSetDeveloperName;
    }

    @RemoteAction
    global static Map<String, Object> saveCase(Case caseObj, List<Case_Group_Member__c> caseGroupMemberList, List<Case_Group_Member__c> caseGroupMemberListToBeDeleted) {
        System.debug('SJ: caseObj : ' + JSON.serialize(caseObj));
        System.debug('SJ: caseGroupMemberList : ' + JSON.serialize(caseGroupMemberList) + ' ' + caseGroupMemberList.isEmpty());
        System.debug('SJ: caseGroupMemberListToBeDeleted : ' + JSON.serialize(caseGroupMemberListToBeDeleted) + ' ' + caseGroupMemberListToBeDeleted.isEmpty());
        try {
            Boolean isInsert = caseObj.Id == null;
            if (isInsert) {
                Case_Group_Member__c primaryCGM = new Case_Group_Member__c();
                primaryCGM.Equipment__c = caseObj.EquipmentId__c;
                primaryCGM.Part__c = caseObj.PartId__c;
                primaryCGM.Primary__c = true;
                primaryCGM.Position__c = caseObj.Position_No__c;
                primaryCGM.Impact__c = caseObj.Impact_CGM__c;
                //caseObj.Impact_CGM__c = null;
                if (caseObj.A_C_REG_ID__c != null) {
                    primaryCGM.Aircraft__c = caseObj.A_C_REG_ID__c;
                }
                if (caseObj.FlightId__c != null) {
                    primaryCGM.FlightId__c = caseObj.FlightId__c;
                }
                caseGroupMemberList.add(primaryCGM);
            }

            caseObj.Position_Case_Group_Member__c = IncidentService.createCaseGroupMemberPositionSummaryString(caseGroupMemberList);
            caseObj.RecordTypeId = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
            upsert caseObj;

            for (Case_Group_Member__c eachMem : caseGroupMemberList) {
                if (eachMem.Caseid__c == null && eachMem.Id == null) {
                    eachMem.Caseid__c = caseObj.Id;
                }

                if (caseObj.Flightid__c != null) {
                    eachMem.FlightId__c = caseObj.FlightId__c;
                }

                if (caseObj.A_C_REG_ID__c != null) {
                    eachMem.Aircraft__c = caseObj.A_C_REG_ID__c;
                }
            }
            upsert caseGroupMemberList;

            if (!caseGroupMemberListToBeDeleted.isEmpty()) {
                List<Case_Group_Member__c> cgmListForDelete = new List<Case_Group_Member__c>();
                for (Case_Group_Member__c eachCGM : caseGroupMemberListToBeDeleted) {
                    if (eachCGM.Id != null) {
                        cgmListForDelete.add(eachCGM);
                    }
                }
                if (!cgmListForDelete.isEmpty()) {
                    delete cgmListForDelete;
                }
            }

            if (isInsert || caseObj.Action__c == null) {
                try {
                    Id jobId = System.enqueueJob(new CabinLogCallout_Queueable(caseObj.Id));
                    if (jobId != null) {
                        AppLogger.debug('Case_RemoteAction', 'saveCase', caseObj.Id, 'enqueueJob :' + jobId, null);
                    } else {
                        AppLogger.error('Case_RemoteAction', 'saveCase', caseObj.Id, 'error to enqueueJob', null);
                    }
                } catch (Exception e) {
                    AppLogger.error('Case_RemoteAction', 'saveCase', caseObj.Id, 'exception', e);
                }
            }
        } catch (System.DMLException e) {
            for (Integer i = 0; i < e.getNumDml(); i++) {
                // Process exception here
                System.debug(e.getDmlMessage(i));
            }
            AppLogger.insertLogs();
            return new Map<String, Object> {
                'status' => '500',
                'caseObj' => caseObj,
                'error' => e.getMessage()
            };
        } catch (Exception e) {
            AppLogger.insertLogs();
            return new Map<String, Object> {
                'status' => '500',
                'caseObj' => caseObj,
                'error' => e.getMessage()
            };
        }
        AppLogger.insertLogs();
        return new Map<String, Object> {
            'status' => '200',
            'caseId' => caseObj.Id
        };
    }

    @RemoteAction
    global static List<Map<String, String>> getAllLOPAPositions(Id aircraftId) {
        return LOPAService.getAllLOPAPositions(aircraftId);
    }

    @RemoteAction
    global static Map<String, Object> getCaseToEdit(Id caseId) {
        Map<String, List<FieldDescribe>> caseMapFieldSet = getMapFieldDescByFieldSetName(listAllFieldSetName, 'Case');
        Map<String, List<FieldDescribe>> caseGroupMemberMapFieldSet = getMapFieldDescByFieldSetName(caseGroupMemberFieldSetNameList, 'Case_Group_Member__c');
        String caseFields = 'Id';
        String caseGroupMemberFields = 'Id';
        for (String key : caseMapFieldSet.keySet()) {
            List<FieldDescribe> fieldList = caseMapFieldSet.get(key);
            for (FieldDescribe eachField : fieldList) {
                caseFields += ',' + eachField.fieldAPI;
            }
        }
        for (String key : caseGroupMemberMapFieldSet.keySet()) {
            List<FieldDescribe> fieldList = caseGroupMemberMapFieldSet.get(key);
            for (FieldDescribe eachField : fieldList) {
                caseGroupMemberFields += ',' + eachField.fieldAPI;
            }
        }
        caseFields += ',SEQ_No_Display__c,Flightid__r.Name, A_C_REG_ID__r.Name, EquipmentId__r.Name, PartId__r.Name,Owner.Name, Flightid__r.AircraftId__c, Flightid__r.A_C_Reg__c';
        caseGroupMemberFields += ',Equipment__r.Name, Primary__c';

        if (caseId == null) {
            User owner = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
            Case newCase = new Case();
            Map<String, Object> caseFieldMap = new Map<String, Object>();
            caseFieldMap.put('OwnerId', UserInfo.getUserId());
            caseFieldMap.put('Owner', new Map<String, String> {'Name' => owner.Name});
            return caseFieldMap;
        } else {
            Case existCase = Database.query('SELECT ' + caseFields + ', (SELECT ' + caseGroupMemberFields + ' FROM Case_Group_Members__r ORDER BY Primary__c DESC, CreatedDate ASC) FROM Case WHERE Id =:caseId LIMIT 1');
            return (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(existCase));
        }
    }

    //@RemoteAction
    //global static String saveCase(String jsonCase) {
    //    String jsonResult = '{\"code\": \"0\",\"message\" : \"success\"}';
    //    try {
    //        System.debug('jsonCase :' + jsonCase);
    //        Case caseToSave = (Case)JSON.deserialize(jsonCase, Case.class);
    //        String conditionMulti = caseToSave.Condition_Multi__c;
    //        if (!String.isBlank(caseToSave.Condition_Multi__c)) {
    //            String val = caseToSave.Condition_Multi__c;
    //            System.debug('val' + val);
    //            if (val.indexOf('[') == 0) val = val.substring(1);
    //            if (val.lastIndexOf(']') == val.length() - 1) val = val.substring(0, val.length() - 1);
    //            val = val.replace(',', ';');
    //            caseToSave.Condition_Multi__c = val;
    //            System.debug('caseToSave.Condition_Multi__c' + caseToSave.Condition_Multi__c);
    //        }
    //        System.debug('caseToSave :' + caseToSave);
    //        String idStr = caseToSave.Id;
    //        if (String.isBlank(idStr)) {
    //            caseToSave.Id = null;
    //            insert caseToSave;
    //        } else {
    //            update caseToSave;
    //            System.debug('caseToSave after update :' + caseToSave.Id);
    //        }

    //        Map<Id, Case_Group_Member__c> existCaseGroupMemberMap = new Map<Id, Case_Group_Member__c>([SELECT Id FROM Case_Group_Member__c WHERE Caseid__c = :caseToSave.Id]);

    //        List<Case_Group_Member__c> caseGroupMembersForInsert = new List<Case_Group_Member__c>();
    //        List<Case_Group_Member__c> caseGroupMembersForUpdate = new List<Case_Group_Member__c>();
    //        List<Case_Group_Member__c> caseGroupMembersForDelete = new List<Case_Group_Member__c>();
    //        for (Case_Group_Member__c caseGroupMember : caseToSave.Case_Group_Members__r) {
    //            caseGroupMember.RecordTypeId = BE8_RecordTypeRepository.getInstance().getRecordTypeMapByDevName('Case_Group_Member__c').get('Maintenance_Page_Layout').Id;
    //            if (String.isBlank(caseGroupMember.Id)) {
    //                caseGroupMember.Id = null;
    //                caseGroupMember.Caseid__c = caseToSave.Id;
    //                caseGroupMember.Defect_Type__c = caseToSave.Condition_Multi__c;
    //                if (caseToSave.Flightid__c != null) {
    //                    caseGroupMember.FlightId__c = caseToSave.Flightid__c;
    //                }
    //                caseGroupMembersForInsert.add(caseGroupMember);
    //            } else {
    //                if (existCaseGroupMemberMap.containsKey(caseGroupMember.Id)) {
    //                    existCaseGroupMemberMap.remove(caseGroupMember.Id);
    //                }
    //                caseGroupMembersForUpdate.add(caseGroupMember);
    //            }
    //        }

    //        if (!caseGroupMembersForUpdate.isEmpty()) {
    //            System.debug('caseGroupMembersForUpdate :' + caseGroupMembersForUpdate);
    //            update caseGroupMembersForUpdate;
    //        }
    //        if (!caseGroupMembersForInsert.isEmpty()) {
    //            System.debug('caseGroupMembersForInsert :' + caseGroupMembersForInsert);
    //            insert caseGroupMembersForInsert;
    //        }
    //        if (!existCaseGroupMemberMap.keySet().isEmpty()) {
    //            delete existCaseGroupMemberMap.values();
    //        }
    //        jsonResult = '{\"code\": \"0\",\"message\" : \"' + caseToSave.Id + '\"}';
    //        return jsonResult;
    //        //return String.valueOf(caseGroupMembers.size());
    //    } catch (Exception e) {
    //        System.debug(e);
    //        System.debug(e.getStackTraceString());
    //        JSONGenerator gen = JSON.createGenerator(true);
    //        gen.writeStartObject();
    //        gen.writeStringField('code', '1');
    //        gen.writeStringField('message', e.getMessage());
    //        gen.writeEndObject();
    //        return gen.getAsString();
    //    }
    //}
}