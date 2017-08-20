@RestResource(urlMapping = '/crewappraisal')
global with sharing class MD_CrewAppraisal_RestResource {

    //@HttpGet
    //global static List<Map<String, String>> get() {
    //    List<Map<String, String>> responseDatas = new List<Map<String, String>>();
    //    List<MD_Appraisal_Item__c> mdItems = [SELECT Id, MD_Appraisal_Item_External_ID__c, Form_Number__c, Form_Description__c, MD_Appraisal_Subject__r.Name, MD_Appraisal_Subject__r.Description__c, MD_Appraisal_Subject__r.Type__c, Version__c, Name, Condition__c, Description__c, Type__c FROM MD_Appraisal_Item__c ORDER BY MD_Appraisal_Item_External_ID__c ASC];

    //    for (MD_Appraisal_Item__c eachMDItem : mdItems) {
    //        Map<String, String> dataEachItem = new Map<String, String>();
    //        dataEachItem.put('id', eachMDItem.MD_Appraisal_Item_External_ID__c);
    //        dataEachItem.put('sfdcId', eachMDItem.Id);
    //        dataEachItem.put('version', eachMDItem.Version__c);
    //        dataEachItem.put('formNum', eachMDItem.Form_Number__c);
    //        dataEachItem.put('formDesc', eachMDItem.Form_Description__c);
    //        dataEachItem.put('subjType', String.isBlank(eachMDItem.MD_Appraisal_Subject__r.Type__c) ? '' : eachMDItem.MD_Appraisal_Subject__r.Type__c);
    //        dataEachItem.put('subjNum', eachMDItem.MD_Appraisal_Subject__r.Name);
    //        dataEachItem.put('subjDesc', eachMDItem.MD_Appraisal_Subject__r.Description__c);
    //        dataEachItem.put('itemNum', eachMDItem.Name);
    //        dataEachItem.put('condi', eachMDItem.Condition__c);
    //        dataEachItem.put('itemDesc', eachMDItem.Description__c);
    //        dataEachItem.put('type', eachMDItem.Type__c);
    //        dataEachItem.put('defaultValue', eachMDItem.Default_Value__c);
    //        responseDatas.add(dataEachItem);
    //    }
    //    return responseDatas;
    //}

    @HttpPost
    global static List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> submitAnswers(List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> crewAppraisalAnswers) {
        if(crewAppraisalAnswers == null || crewAppraisalAnswers.isEmpty()) {
            return crewAppraisalAnswers;
        }
        
        String refInfo = '';
        Set<String> crewListExternalIdSet = new Set<String>();
        Set<String> flightIdSet = new Set<String>();

        if (!crewAppraisalAnswers.isEmpty()) {
            refInfo += crewAppraisalAnswers.get(0).evaFltExtId;
            for (MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer : crewAppraisalAnswers) {
                refInfo += '|' + answer.evaStaffNum + ',' + answer.staffNum + ',' + answer.formNum;
                crewListExternalIdSet.add(answer.evaStaffNum + '_' + crewAppraisalAnswers.get(0).evaFltExtId);
                crewListExternalIdSet.add(answer.staffNum + '_' + crewAppraisalAnswers.get(0).evaFltExtId);
                flightIdSet.add(answer.evaFltSfdcId);
            }
        }

        Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>([SELECT Id, Airline_Code__c, Aircraft_Type__c, Arrival_STN__c, Block_Time__c, Departure_STN__c, Flight_Date_LT__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet]);
        List<Crew_List__c> crewLists = [SELECT Id, Rank__c, Acting_Rank__c, POS_Fly__c, Duty_Code__c, CrewId__r.Personel_Id__c, Crew_External_ID__c, Duty_Assignment__c FROM Crew_List__c WHERE Crew_External_ID__c IN :crewListExternalIdSet];
        Map<String, Crew_List__c> crewListMap = new Map<String, Crew_List__c>();
        for (Crew_List__c crewList : crewLists) {
            crewListMap.put(crewList.Crew_External_ID__c, crewList);
        }

        Map<Id, Map<String, Integer>> classMapByFlightId = new Map<Id, Map<String, Integer>>();
        for (Passenger__c  eachPassenger : [SELECT Id, Cabin_Code__c, Checkin_Seat__c, FlightId__c FROM Passenger__c WHERE FlightId__c IN :flightIdSet]) {
            if (!classMapByFlightId.containsKey(eachPassenger.FlightId__c)) {
                classMapByFlightId.put(eachPassenger.FlightId__c, new Map<String, Integer>());
            }

            String classCode = eachPassenger.Cabin_Code__c;
            if (!classMapByFlightId.get(eachPassenger.FlightId__c).containsKey(classCode)) {
                classMapByFlightId.get(eachPassenger.FlightId__c).put(classCode, 0);
            }

            if (eachPassenger.Checkin_Seat__c != null) {
                Integer count = classMapByFlightId.get(eachPassenger.FlightId__c).get(classCode);
                classMapByFlightId.get(eachPassenger.FlightId__c).put(classCode, count + 1);
            }
        }


        AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'MD_CrewAppraisal_RestResource', 'submitAnswers', '', refInfo, 'request from InflightApp to SFDC', JSON.serializePretty(crewAppraisalAnswers), null, System.currentTimeMillis());

        CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
        String requestBody = ws.getRequestBody(crewAppraisalAnswers, crewListMap, flightMap, classMapByFlightId);
        System.debug('requestBody :' + requestBody);
        WS_SUBMITCrewAppraisal_Model response = ws.submit(requestBody);
        System.debug('response WS_SUBMITCrewAppraisal_Model:' + response);

        List<Crew_Appraisal_Answer__c> logAnswers = new List<Crew_Appraisal_Answer__c>();
        for (MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer : crewAppraisalAnswers) {
            Crew_Appraisal_Answer__c logAnswer = new Crew_Appraisal_Answer__c();
            logAnswer.Evaluator_Personel_Id__c = answer.evaStaffNum;
            logAnswer.Evaluated_Personel_Id__c = answer.staffNum;
            logAnswer.Form_Number__C = answer.formNum;
            logAnswer.Flight_External_Id__c = answer.evaFltExtId;
            logAnswer.Raw__c = JSON.serialize(answer);
            logAnswer.Appraisal_Id__c = answer.appraisalId;

            if (response != null && !response.hasError()) {
                for (WS_SUBMITCrewAppraisal_Model.return_z eachReturn : response.Envelope.Body.InsertCrewAppraisalRes.return_z) {
                    if (eachReturn.evaluateStaffID == answer.evaStaffNum
                            && eachReturn.staffID == answer.staffNum
                            && eachReturn.formNumber == answer.formNum) {
                        if (eachReturn.description.toLowerCase() == 'complete') {
                            logAnswer.Status__c = 'complete';
                            answer.isSynced = 1;
                        } else {
                            logAnswer.Status__c = eachReturn.description;
                            answer.isSynced = 0;
                        }
                        break;
                    }
                }
            }
            logAnswers.add(logAnswer);
        }
        Database.SaveResult[] saveResults = Database.insert(logAnswers, false);
        for (Crew_Appraisal_Answer__c logAnswer : logAnswers) {
            if (logAnswer.Id != null) {
                for (MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer : crewAppraisalAnswers) {
                    if (answer.appraisalId == logAnswer.Appraisal_Id__c) {
                        answer.sfdcId = logAnswer.Id;
                        break;
                    }
                }
            }
        }

        if (response != null ) {
            AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'MD_CrewAppraisal_RestResource', 'submitAnswers', '', refInfo, 'response from SFDC to InflightApp', JSON.serializePretty(response), null, System.currentTimeMillis());
            AppLogger.insertLogs();
        } else {
            AppLogger.insertLogs();
            throw new CustomException('Unknow Exception: MD_CrewAppraisal_RestResource.submitAnswers');
        }
        return crewAppraisalAnswers;
    }
}