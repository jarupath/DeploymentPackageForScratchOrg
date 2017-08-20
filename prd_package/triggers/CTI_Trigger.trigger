trigger CTI_Trigger on CTI__c (before insert, before update) {
    if (TriggerActivator.isTriggerActivated(TriggerActivator.CTI_Trigger)) {
        list<CTI__c> listgetctivalue = new list<CTI__c>();
        set<ID> setcaseid = new set<ID>();

        Set<Id> flightIdSet = BE8_GlobalUtility.getIdSet('FlightId__c', Trigger.new);
        Set<Id> caseIDSet = new Set<Id>();
        Map<String, SObject> flightMap = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id, Name, Sector__c, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet]);

        //TGSIC-821 Add PAX Flown Summary to CTI record
        Map<String, Date> summaryExtKeyMap = new Map<String, Date>();
        Map<String, PAX_Flown_Summary__c> paxFlownSummaryMap = new Map<String, PAX_Flown_Summary__c>();
        Map<ID, Case> casesRelateMap = new Map<ID, Case>();

        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) CTI_Management.updateCTIContinent(Trigger.new);

        if (Trigger.Isinsert) {
            for (CTI__c eachCTI : Trigger.new) {
                caseIDSet.add(eachCTI.caseid__c); //Cannot Retrieve Case CreateDate
            }

            List<Case> casesRelateList = [SELECT ID, CreatedDate FROM Case  WHERE ID IN :caseIDSet];

            for (Case  eachCases : casesRelateList) {
                Date tempDate = date.newInstance(eachCases.CreatedDate.year(), eachCases.CreatedDate.month(), 01);
                //summaryExtKeyMap.put(DateTime.newInstance(tempDate.year(), tempDate.month(), 01).format('YYYY-MM-dd'), tempDate);
                summaryExtKeyMap.put(DateTime.newInstance(tempDate.year(), tempDate.month(), 01).format('YYYY-MM'), tempDate);
                casesRelateMap.put(eachCases.ID, eachCases);
            }

            List<PAX_Flown_Summary__c> paxSummaryList = [SELECT ID, Data_Date_Key__c from PAX_Flown_Summary__c where Data_Date_Key__c IN :summaryExtKeyMap.keySet() ];
            List<PAX_Flown_Summary__c> insertPaxSummaryList = new List<PAX_Flown_Summary__c>();
            //AppLogger.debug('CTI_Trigger', 'paxSummaryList', null, JSON.serialize(paxSummaryList), null);
            if (!paxSummaryList.isEmpty()) {
                for (PAX_Flown_Summary__c eachPaxSum : paxSummaryList) {
                    if (summaryExtKeyMap.containsKey(eachPaxSum.Data_Date_Key__c)) {
                        paxFlownSummaryMap.put(eachPaxSum.Data_Date_Key__c, eachPaxSum);
                        summaryExtKeyMap.remove(eachPaxSum.Data_Date_Key__c);
                    }
                }
            }
            if (summaryExtKeyMap.size() > 0) {
                for (String eachExtKey : summaryExtKeyMap.keySet()) {
                    insertPaxSummaryList.add(new PAX_Flown_Summary__c(Name = (DateTime.newInstance(summaryExtKeyMap.get(eachExtKey).year(), summaryExtKeyMap.get(eachExtKey).month(), 01).format('YYYY-MM')), Data_Date_Key__c = eachExtKey, Data_Date__c = summaryExtKeyMap.get(eachExtKey)));
                }
                if (insertPaxSummaryList.size() > 0) {
                    insert insertPaxSummaryList;
                    for (PAX_Flown_Summary__c eachPaxSum : insertPaxSummaryList) {
                        paxFlownSummaryMap.put(eachPaxSum.Data_Date_Key__c, eachPaxSum);
                    }
                }
            }
            //AppLogger.debug('CTI_Trigger', 'insertPaxSummaryList', null, JSON.serialize(insertPaxSummaryList), null);
            //AppLogger.debug('CTI_Trigger', 'paxFlownSummaryMap', null, JSON.serialize(paxFlownSummaryMap), null);
        }

        for (CTI__c thiscti : Trigger.new) {

            if (Trigger.isBefore) {
                if (!String.isBlank(thiscti.CTI_Station__c)) {
                    thiscti.CTI_Station__c = thiscti.CTI_Station__c.toUpperCase();
                }
            }

            if (Trigger.Isinsert) {
                CTI_Management.setCTISectorFollowFlight(thiscti, flightMap);
                listgetctivalue.add(thiscti);
                setcaseid.add(thiscti.caseid__c);
                Date tempDate = date.newInstance(casesRelateMap.get(thiscti.caseid__c).CreatedDate.year(), casesRelateMap.get(thiscti.caseid__c).CreatedDate.month(), 01);
                String conditionDate = DateTime.newInstance(tempDate.year(), tempDate.month(), 01).format('YYYY-MM');
                thiscti.Passenger_Flown__c = (paxFlownSummaryMap.containsKey(conditionDate) ? paxFlownSummaryMap.get(conditionDate).ID : null);
            } else {
                CTI_Management.setCTISectorFollowFlight(thiscti, flightMap);

                CTI__c oldcti = trigger.oldmap.get(thiscti.Id);
                System.debug('JK: thiscti station: ' + thiscti.Station__c);
                System.debug('JK: oldcti station: ' + oldcti.Station__c);

                if ((thiscti.FlightId__c != null && thiscti.FlightId__c != oldcti.FlightId__c) || (thiscti.Station__c != oldcti.Station__c && thiscti.Station__c != null && thiscti.Station__c != '' && thiscti.Station__c != 'Unidentified') || (thiscti.Sector__c != null && thiscti.Sector__c != oldcti.Sector__c)) {
                    listgetctivalue.add(thiscti);
                    setcaseid.add(thiscti.caseid__c);
                }

                //if((thiscti.flightid__c != oldcti.flightid__c) && thiscti.flightid__c != null){
                //    listgetctivalue.add(thiscti);
                //    setcaseid.add(thiscti.caseid__c);
                //}
            }
        }

        if (listgetctivalue.size() > 0 && setcaseid.size() > 0) {
            CTI_Management.getctivalue(listgetctivalue, setcaseid, flightMap);
        }
        //AppLogger.insertLogs();

    }
}