public with sharing class CSE_SOAP_SUBMITCREWAPPRAISAL_WS extends CSE_SOAP_WS {

    public override String getEndPoint() {
        String endpoint = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SUBMIT_CREWAPPRAISAL_ENDPOINT);
        if (!endpoint.contains('http://') && !endpoint.contains('https://')) {
            endpoint = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_TG_BASEURL) + endpoint;
        }
        return endpoint;
    }

    public override String getUsername() {
        return BE8_GlobalUtility.getSetting('SUBMIT_CREWAPPRAISAL_USERNAME');
        //return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_USERNAME);
    }

    public override String getPassword() {
        return BE8_GlobalUtility.getSetting('SUBMIT_CREWAPPRAISAL_PASSWORD');
        //return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_PASSWORD);
    }

    public String getRequestBody(List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> crewAppraisalAnswers) {
        Set<String> crewListExternalIdSet = new Set<String>();
        Set<String> flightIdSet = new Set<String>();
        for (MB_RESTRequestInfoModel.crewAppraisalFormAnswer crewAppraisalAnswer : crewAppraisalAnswers) {
            String flightExternalId = crewAppraisalAnswer.evaFltExtId;
            crewListExternalIdSet.add(crewAppraisalAnswer.staffNum + '_' + flightExternalId);
            crewListExternalIdSet.add(crewAppraisalAnswer.evaStaffNum + '_' + flightExternalId);
            flightIdSet.add(crewAppraisalAnswer.evaFltSfdcId);
        }

        List<Crew_List__c> crewLists = [SELECT Id, Rank__c, Acting_Rank__c, POS_Fly__c, Duty_Assignment__c, Duty_Code__c, Crew_External_ID__c FROM Crew_List__c WHERE Crew_External_ID__c = :crewListExternalIdSet];
        Map<String, Crew_List__c> crewListMap = new Map<String , Crew_List__c>();
        for (Crew_List__c crewList : crewLists) {
            crewListMap.put(crewList.Crew_External_ID__c, crewList);
        }

        Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>([SELECT Id, Airline_Code__c, Aircraft_Type__c, Arrival_STN__c, Block_Time__c, Departure_STN__c, Flight_Date_LT__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet]);

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
        return getRequestBody(crewAppraisalAnswers, crewListMap, flightMap, classMapByFlightId);
    }

    public String getRequestBody(String soapBodyStr) {
        String prefixReqTxnId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SUBMIT_CREWAPPRAISAL_PREFIX_REQ_TXN_ID);
        String reqTxnId = BE8_GlobalUtility.generateTransactionId(prefixReqTxnId);
        String svcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SUBMIT_CREWAPPRAISAL_SVC_VER);
        String mWTxnID = '';
        String reqId = '';
        String envelopeAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:crew="http://xml.thaiairways.com/crew/insert/crewappraisal" xmlns:v1="http://xml.thaiairways.com/crew/insert/crewappraisal/insertcrewappraisal/v1_0"';

        String soapRequestStr = super.createSOAPBody(envelopeAttribute, reqTxnId, svcVer, 'true', reqId, mWTxnID, soapBodyStr);
        return soapRequestStr;
    }

    public String getEvaluateDataRequestBody(String formNum, List<MB_RESTRequestInfoModel.crewAppraisalSubjectAnswer> subjectAnswers) {
        Integer dataSize = 0;
        String evaluateDataStr = '';
        Map<String, MD_Appraisal_Subject__c> subjectMap = MDAppraisalSubject_Repository.getSubjectMapByKey();
        for (MB_RESTRequestInfoModel.crewAppraisalSubjectAnswer subjAnswer : subjectAnswers) {
            MD_Appraisal_Subject__c mdSubject = subjectMap.get(formNum + subjAnswer.subjNum);
            dataSize++;
            String subjAnswerComment = String.isNotBlank(subjAnswer.comment) ? subjAnswer.comment : '';

            if (mdSubject.Type__c == 'Rating') {
                evaluateDataStr += '<v1:evaluateData>';
                evaluateDataStr += '<v1:comment>' + subjAnswerComment + '</v1:comment>';
                evaluateDataStr += '<v1:item_num>00</v1:item_num>';
                evaluateDataStr += '<v1:score_origin>' + subjAnswer.value + '</v1:score_origin>';
                evaluateDataStr += '<v1:subject_num>' + subjAnswer.subjNum + '</v1:subject_num>';
                evaluateDataStr += '</v1:evaluateData>';
            }

            for (MB_RESTRequestInfoModel.crewAppraisalItemAnswer itemAnswer : subjAnswer.items) {
                if (itemAnswer.mdType == 'Checkbox') {
                    //if (itemAnswer.value == '1') {
                    evaluateDataStr += '<v1:evaluateData>';
                    evaluateDataStr += '<v1:comment></v1:comment>';
                    evaluateDataStr += '<v1:item_num>' + itemAnswer.itemNum + '</v1:item_num>';
                    evaluateDataStr += '<v1:score_origin>' + subjAnswer.value + '</v1:score_origin>';
                    evaluateDataStr += '<v1:subject_num>' + subjAnswer.subjNum + '</v1:subject_num>';
                    evaluateDataStr += '</v1:evaluateData>';
                    //dataSize++;
                    //}
                } else {
                    evaluateDataStr += '<v1:evaluateData>';
                    evaluateDataStr += '<v1:comment></v1:comment>';
                    evaluateDataStr += '<v1:item_num>' + itemAnswer.itemNum + '</v1:item_num>';
                    evaluateDataStr += '<v1:score_origin>' + itemAnswer.value + '</v1:score_origin>';
                    evaluateDataStr += '<v1:subject_num>' + subjAnswer.subjNum + '</v1:subject_num>';
                    evaluateDataStr += '</v1:evaluateData>';
                    //dataSize++;
                }
            }
        }
        evaluateDataStr = '<v1:dataSize>' + dataSize + '</v1:dataSize>' + evaluateDataStr;
        return evaluateDataStr;
    }

    public String getRequestBody(List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers, Map<String, Crew_List__c> crewListMap, Map<Id, Flight__c> flightMap, Map<Id, Map<String, Integer>> classMapByFlightId) {

        String soapBodyStr = '<soapenv:Body>';
        soapBodyStr += '<crew:InsertCrewAppraisalReq>';

        for (MB_RESTRequestInfoModel.crewAppraisalFormAnswer eachForm : answers) {
            String staffExternalId = eachForm.staffNum + '_' + eachForm.evaFltExtId;
            String evaStaffExternalId = eachForm.evaStaffNum + '_' + eachForm.evaFltExtId;
            String eachFormComment = String.isNotBlank(eachForm.comment) ? eachForm.comment : '';

            Map<String, Integer> classMap;
            if(classMapByFlightId.containsKey(eachForm.evaFltSfdcId)) {
                classMap = classMapByFlightId.get(eachForm.evaFltSfdcId);
            }
            soapBodyStr += '<v1:arg0>';
            soapBodyStr += '<v1:createBy>' + eachForm.evaStaffNum + '</v1:createBy>';
            soapBodyStr += '<v1:createDate>' + eachForm.createdDate + '</v1:createDate>';

            if (crewListMap.containsKey(staffExternalId)) {
                Crew_List__c crewList = crewListMap.get(staffExternalId);
                soapBodyStr += '<v1:crewActingRank>' + crewList.Acting_Rank__c + '</v1:crewActingRank>';
                soapBodyStr += '<v1:crewDuty>' + crewList.Duty_Code__c + '</v1:crewDuty>';
                soapBodyStr += '<v1:crewPosition>' + crewList.POS_Fly__c + '</v1:crewPosition>';
                soapBodyStr += '<v1:crewRank>' + crewList.Rank__c + '</v1:crewRank>';
            }
            soapBodyStr += getEvaluateDataRequestBody(eachForm.formNum, eachForm.subjs);
            soapBodyStr += '<v1:evaluateStaffID>' + eachForm.evaStaffNum + '</v1:evaluateStaffID>';

            String evaCrewStr = '';
            if (crewListMap.containsKey(evaStaffExternalId)) {
                Crew_List__c evaCrewList = crewListMap.get(evaStaffExternalId);
                evaCrewStr += '<v1:evaluatedCrewActingRank>' + evaCrewList.Acting_Rank__c + '</v1:evaluatedCrewActingRank>';
                evaCrewStr += '<v1:evaluatedCrewPosition>' + evaCrewList.POS_Fly__c + '</v1:evaluatedCrewPosition>';
                evaCrewStr += '<v1:evaluatedCrewRank>' + evaCrewList.Rank__c + '</v1:evaluatedCrewRank>';
            }

            if (flightMap.containsKey(eachForm.evaFltSfdcId)) {
                Flight__c flight = flightMap.get(eachForm.evaFltSfdcId);
                soapBodyStr += '<v1:evaluatedAircraft>' + flight.Aircraft_Type__c + '</v1:evaluatedAircraft>';
                soapBodyStr += '<v1:evaluatedAirlineCode>' + flight.Airline_Code__c + '</v1:evaluatedAirlineCode>';
                soapBodyStr += '<v1:evaluatedArrPort>' + flight.Arrival_STN__c + '</v1:evaluatedArrPort>';
                soapBodyStr += '<v1:evaluatedBlockTime>' + flight.Block_Time__c + '</v1:evaluatedBlockTime>';
                if (classMap != null && classMap.containsKey('C')) {
                    soapBodyStr += '<v1:evaluatedBusinessPAX>' + classMap.get('C') + '</v1:evaluatedBusinessPAX>';
                } else {
                    soapBodyStr += '<v1:evaluatedBusinessPAX>0</v1:evaluatedBusinessPAX>';
                }
                soapBodyStr += '<v1:evaluatedComment>' + eachFormComment + '</v1:evaluatedComment>';
                soapBodyStr += evaCrewStr;
                soapBodyStr += '<v1:evaluatedDepPort>' + flight.Departure_STN__c + '</v1:evaluatedDepPort>';

                if (classMap != null && classMap.containsKey('Y')) {
                    soapBodyStr += '<v1:evaluatedEconomyPAX>' + classMap.get('Y') + '</v1:evaluatedEconomyPAX>';
                } else {
                    soapBodyStr += '<v1:evaluatedEconomyPAX>0</v1:evaluatedEconomyPAX>';
                }

                if (classMap != null && classMap.containsKey('F')) {
                    soapBodyStr += '<v1:evaluatedFirstPAX>' + classMap.get('F') + '</v1:evaluatedFirstPAX>';
                } else {
                    soapBodyStr += '<v1:evaluatedFirstPAX>0</v1:evaluatedFirstPAX>';
                }

                soapBodyStr += '<v1:evaluatedFlightDate>' + flight.Flight_Date_LT__c + '</v1:evaluatedFlightDate>';
                if (!String.isBlank(flight.Flight_Number__c)) {
                    soapBodyStr += '<v1:evaluatedFlightNumber>' + flight.Flight_Number__c.replaceAll('TG', '') + '</v1:evaluatedFlightNumber>';
                }

                if (classMap != null && classMap.containsKey('U')) {
                    soapBodyStr += '<v1:evaluatedPremiumPAX>' + classMap.get('U') + '</v1:evaluatedPremiumPAX>';
                } else {
                    soapBodyStr += '<v1:evaluatedPremiumPAX>0</v1:evaluatedPremiumPAX>';

                }
            }

            soapBodyStr += '<v1:flagDataComplete>Y</v1:flagDataComplete>';
            soapBodyStr += '<v1:formNumber>' + eachForm.formNum + '</v1:formNumber>';
            soapBodyStr += '<v1:staffID>' + eachForm.staffNum + '</v1:staffID>';
            soapBodyStr += '</v1:arg0>';
        }

        soapBodyStr += '</crew:InsertCrewAppraisalReq>';
        soapBodyStr += '</soapenv:Body>';
        return getRequestBody(soapBodyStr);
    }

    public WS_SUBMITCrewAppraisal_Model submit(List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers, Map<String, Crew_List__c> crewListMap, Map<Id, Flight__c> flightMap, Map<Id, Map<String, Integer>> classMapByFlightId) {
        String soapRequestStr = getRequestBody(answers, crewListMap, flightMap, classMapByFlightId);
        return submit(soapRequestStr);
    }

    public WS_SUBMITCrewAppraisal_Model submit(String soapRequestStr) {
        AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_SOAP_SUBMITCREWAPPRAISAL_WS', 'submit', '', '', 'request from SFDC to THAI ', soapRequestStr, null, System.currentTimeMillis());

        Set<String> nodeArray = new Set<String> {'return'};
        String soapAction = '""';
        String wrapNode = '';
        String removeTxt = null;
        WS_SUBMITCrewAppraisal_Model responseModel = (WS_SUBMITCrewAppraisal_Model)super.wsCallout(soapRequestStr, wrapNode, nodeArray, soapAction, WS_SUBMITCrewAppraisal_Model.class, removeTxt);

        if (responseModel == null || responseModel.hasError()) {
            String errMsg = responseModel == null ? 'null' : responseModel.getErrorMessage();
            String rawResponse = responseModel == null ? 'null' : JSON.serializePretty(responseModel);

            Monitoring.notifyError('Error: Submit CrewAppraisalAnswer To THAI', errMsg, 'CREWAPPRAISALANSWER');
            AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_SOAP_SUBMITCREWAPPRAISAL_WS', 'submit', '', '', 'error response from THAI to SFDC ', rawResponse, null, System.currentTimeMillis());
        } else {
            AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_SOAP_SUBMITCREWAPPRAISAL_WS', 'submit', '', '', 'response from THAI to SFDC ', JSON.serializePretty(responseModel), null, System.currentTimeMillis());
        }

        //System.debug(responseModel);
        return responseModel;
    }
}