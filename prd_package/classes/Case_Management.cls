public without sharing class Case_Management {
    public static final String COMPLETE = 'Completed';
    public static final String APPROVED = 'Approved';
    public static final String PENDING = 'Pending';
    public static final String REJECTED = 'Rejected';
    public static final String CASE_STATUS_NEW = 'New';
    public static final String ESCALATED = 'Escalated';
    public static final String INVESTIGATED = 'Investigated';
    public static final String DUPPLICATE = 'Duplicate';
    public static final String RESOLVED = 'Resolved';
    public static final String CLOSED = 'Closed';
    public static final String WAITINGCUS = 'Waiting for Response';
    public static final String WAITINGINV = 'Waiting for Investigation';
    public static final String CUSTOMER_RESPONSE = 'Customer Response';
    public static final String CFMSVIEW_RT = 'Customer Feedback View';
    public static final String CFMS_RT = 'Customer Feedback';
    public static final String CASE_ENTITLEMENTNAME = 'Case Entitlement';
    public static final String CASE_MILESTONENAME = 'Total Case Overdue 20 days';
    public static final String FIRSTCLASS = 'F';
    public static final String PLATINUMROP = 'PLAT';
    public static final String TGXXX = BE8_GlobalConstants.DUMMY_FLIGHT_NAME;
    public static final String TASK_SUBJECT_PREFIX_BF_FLTNO = 'Please update Expected Flight Number(';
    public static final String TASK_SUBJECT_PREFIX_AF_FLTNO = ') in Case field name \'Flight Number\'. ';
    public static final String Status_Waiting_For_Response = 'Waiting for Response';
    public static final String Status_Closed = 'Closed';
    public static final String Status_Escalated = 'Escalated';
    public static final String S4T1GBName = 'S4 Tier 1 Group B';
    public static final String S4T1GAName = 'S4 Tier 1 Group A';
    public static final String ABROAD_TYO_QUEUE = 'SD/SR TYO Team';
    public static final String GS_CLOSE_RECORDTYPE = 'Ground_Service_Closed';
    public static final String CFMSVIEW_RECORDTYPE = 'Customer_Feedback_View';
    public static final String ABROAD_COMPENSATION_RECORDTYPE = 'SD/SR Compensation';
    public static final String CFMS_COMPENSATION_RECORDTYPE = 'CFMS Compensation';
    public static final String ABROAD_COMPENSATION_FINAL_RECORDTYPE_DEVNAME = 'SD_SR_Compensation_Final';
    public static final String CFMS_COMPENSATION_FINAL_RECORDTYPE_DEVNAME = 'CFMS_Compensation_Final';


    Map<Id, CaseMilestone> Mapmilestone = new Map<Id, CaseMilestone>();
    Id CFMSRECORDTYPEID;
    Id CFMSRECORDTYPECREATEID;
    private static Map<Id, Master_Map__c> masterMapMap;

    public void Changecompensationapproval(List<Case> caseList, Set<Id> caseIdSet) {
        Map<Id, List<Compensation__c>> compensationMap = getmapcompensation(caseIdSet);
        List<Compensation__c> compensationToBeUpdatedList = new List<Compensation__c>();

        if (compensationMap.size() > 0) {
            for (Case thisCase : caseList) {
                if (compensationMap.containskey(thisCase.Id)) {
                    List<Compensation__c> retrievedCompensationList = compensationMap.get(thisCase.Id);
                    if (retrievedCompensationList != null && retrievedCompensationList.size() > 0) {
                        for (Compensation__c comp : retrievedCompensationList) {
                            //System.debug('SJ | Case Approval Status :' + thisCase.Approval_Status__c + ' ' + comp.Status__c);
                            comp.Status__c = thisCase.Approval_Status__c;
                            getlockcomp_recordtype(comp);
                            compensationToBeUpdatedList.add(comp);
                        }
                    }
                }
            }
        }
        system.debug('compensation before update');
        if (compensationToBeUpdatedList.size() > 0) {
            update compensationToBeUpdatedList;
        }
        system.debug('compensation complete');
    }

    @TestVisible
    private static Map<String, RecordType> getRecordTypeMapByName(){
        Map<String, RecordType> returnMap = new Map<String, RecordType>();
        for(RecordType rec : Case_TriggerHandler.getRecordTypeMapByDevName().values()){
            returnMap.put(rec.Name, rec);
        }

        return returnMap;
    }

    public void StampActionTrail(List<Case> listcase, Set<Id> setcaseid, Map<Id, Case> oldCaseMap) {
        List<Case> listmatchstatuscase = new List<Case>();
        Getlistmilestone(setcaseid);

        for (Case thiscase : listcase) {
            if (thiscase.Status == ESCALATED && thiscase.Escalate_by__c == null) {
                if (thiscase.First_Handle_by__c == null) {
                    thiscase.First_Handle_by__c = userinfo.getName();
                    thiscase.First_Handle_Time__c = System.Now();
                }
                thiscase.Escalate_by__c = Userinfo.getName();
                thiscase.Escalate_Time__c = System.Now();
                listmatchstatuscase.add(thiscase);
            } else if (thiscase.Status == INVESTIGATED && thiscase.Investigated_by__c == null) {
                thiscase.Investigated_by__c = Userinfo.getName();
                thiscase.Investigated_Time__c = System.Now();
                listmatchstatuscase.add(thiscase);
            } else if (thiscase.Status == WAITINGINV && thiscase.Send_to_Investigator_by__c == null) {
                thiscase.Send_to_Investigator_by__c = Userinfo.getName();
                thiscase.Send_to_Investigator_Time__c = System.Now();
                listmatchstatuscase.add(thiscase);
            } else if ((thiscase.Status == RESOLVED || thiscase.Status == CUSTOMER_RESPONSE || thiscase.Status == CLOSED) && thiscase.Closed_by__c == null) {
                thiscase.Closed_by__c = Userinfo.getName();
                thiscase.Closed_Time__c = System.Now();
                if(thiscase.First_Handle_by__c == null){
                    thiscase.First_Handle_by__c = UserInfo.getName();
                    thiscase.First_Handle_Time__c = System.now();
                } 
                listmatchstatuscase.add(thiscase);
            }

            if (thiscase.Status == RESOLVED || thiscase.Status == WAITINGCUS || thiscase.Status == CLOSED || thiscase.Status == CUSTOMER_RESPONSE || thiscase.Status == DUPPLICATE) {
                thiscase.IsStopped = true;
            } else {
                thiscase.IsStopped = false;
            }
        }
        system.debug('lis match status case size : ' + listmatchstatuscase.size());
        Calculateactiontraill_age(listmatchstatuscase, oldCaseMap);
    }

    private void Calculateactiontraill_age(List<Case> listmatchstatuscase, Map<Id, Case> oldCaseMap) {
        Map<Id, CaseMilestone> caseMilestonesMapByCaseId = new Map<Id, CaseMilestone>();
        Set<Id> caseMilestoneIdSet = new Set<Id>();
        AppLogger.debug('Case_Management', 'Calculateactiontraill_age', 'Mapmilestone', JSON.serialize(Mapmilestone), null);
        for (Case thiscase : listmatchstatuscase) {
            if (Mapmilestone.ContainsKey(thiscase.id)) {
                CaseMilestone thismilestone = Mapmilestone.get(thiscase.id);
                if(oldCaseMap != null)Assignmilestonedate(thiscase, thismilestone, oldCaseMap.get(thiscase.Id));
                else Assignmilestonedate(thiscase, thismilestone, null);
                caseMilestonesMapByCaseId.put(thiscase.Id, thismilestone);
                caseMilestoneIdSet.add(thismilestone.Id);
            }
        }
        if (!caseMilestonesMapByCaseId.isEmpty()) {
            update caseMilestonesMapByCaseId.values(); 
            
        }

        Map<Id, CaseMilestone> caseMileStoneMap = new Map<Id, CaseMileStone>([SELECT ActualElapsedTimeInMins, ElapsedTimeInMins FROM CaseMilestone WHERE Id = :caseMilestoneIdSet]);

        for (Case thiscase : listmatchstatuscase) {
            if (caseMilestonesMapByCaseId.containsKey(thiscase.Id)) {
                Id caseMileStoneId = caseMilestonesMapByCaseId.get(thiscase.Id).Id;
                if (caseMileStoneMap.containsKey(caseMileStoneId)) {
                    updateCaseByElapsedTimeInMins(thiscase, caseMileStoneMap.get(caseMileStoneId));
                }
            }
        }
    }

    @TestVisible
    private void updateCaseByElapsedTimeInMins(Case thiscase, CaseMilestone thisCaseMileStone) {
        if (thiscase.status == CLOSED) {
            if (thiscase.First_Handle_Time__c != null) {
                thiscase.First_Handled_to_Closed__c = thisCaseMileStone.ElapsedTimeInMins + '';
            }
            if (thiscase.Investigated_Time__c != null) {
                thiscase.Investigated_to_Closed__c = thisCaseMileStone.ElapsedTimeInMins + '';
            }
            if (thiscase.Escalate_Time__c != null) {
                thiscase.Escalate_to_Closed__c = thisCaseMileStone.ElapsedTimeInMins + '';
            }
        } else if (thiscase.status == Investigated) {
            if (thiscase.Escalate_Time__c != null) {
                thiscase.Escalate_to_Investigated__c = thisCaseMileStone.ElapsedTimeInMins + '';
            }
            if (thiscase.Send_to_Investigator_Time__c != null) {
                thiscase.Waiting_for_Inv_staff_to_Investigated__c = thisCaseMileStone.ElapsedTimeInMins + '';
            }
        }
    }

    @TestVisible
    private void Assignmilestonedate(Case thiscase, CaseMilestone thismilestone, Case oldCase) {
        Map<String, CaseStatus> caseStatusClosedMap = Case_TriggerHandler.getCaseClosedStatusMap();
        //string logmsg = 'before: ' + JSON.serialize(thismilestone) + '\n';
        if(oldCase == null || (oldCase != null && !caseStatusClosedMap.containsKey(oldCase.Status))){
            //if (thiscase.status == CLOSED || thiscase.status == CUSTOMER_RESPONSE || thiscase.status == DUPPLICATE || thiscase.status == RESOLVED) {
            if (caseStatusClosedMap.containsKey(thiscase.Status)) {
                if (thiscase.First_Handle_Time__c != null) {
                    thismilestone.Startdate = thiscase.First_Handle_Time__c;
                    thismilestone.CompletionDate = System.Now();
                }
                if (thiscase.Investigated_Time__c != null) {
                    thismilestone.Startdate = thiscase.Investigated_Time__c;
                    thismilestone.CompletionDate = System.Now();
                }
                if (thiscase.Escalate_Time__c != null) {
                    thismilestone.Startdate = thiscase.Escalate_Time__c;
                    thismilestone.CompletionDate = System.Now();
                }

                thiscase.IsStopped = true;
            } else if (thiscase.status == Investigated) {
                if (thiscase.Escalate_Time__c != null) {
                    thismilestone.Startdate = thiscase.Escalate_Time__c;
                    thismilestone.CompletionDate = System.Now();
                }
                if (thiscase.Send_to_Investigator_Time__c != null) {
                    thismilestone.Startdate = thiscase.Send_to_Investigator_Time__c;
                    thismilestone.CompletionDate = System.Now();
                }
            }
        }
        
        //logmsg += 'after: ' + JSON.serialize(thismilestone);
        //System.debug('Assignmilestonedate: \n' + logmsg);
        //AppLogger.debug('Case_Management', 'Assignmilestonedate', null, logmsg, null);
        //AppLogger.insertLogs();
    }

    private void Getlistmilestone(set<id> setcaseid) {
        list<CaseMilestone> listmilestone = [Select id, caseid, ActualElapsedTimeInDays, ActualElapsedTimeInHrs,
                                             ActualElapsedTimeInMins, ElapsedTimeInDays, ElapsedTimeInHrs,
                                             ElapsedTimeInMins, IsCompleted, CompletionDate, MilestoneTypeId
                                             From CaseMilestone
                                             Where MilestoneType.name = : CASE_MILESTONENAME AND CaseId IN :setcaseid];
        if (listmilestone.size() > 0) {
            for (CaseMilestone cms : listmilestone) {
                Mapmilestone.put(cms.Caseid , cms);
            }
        }
    }

    //private CaseMilestone getrealCaseMilestone(id CaseMilestoneid) {
    //    return [Select ActualElapsedTimeInMins, ElapsedTimeInMins From CaseMilestone Where id = : CaseMilestoneid];
    //}

    public void getdefaultvalue(list<case> listcasefordefaultvalue_insert, set<id> setpassengerid) {
            List<Entitlement> lisentitlement = getdefaultentitlement();
            Map<id, string> maprecordtype = getmaprecordtype();
            Map<id, passenger__c> Mappassenger = getmappassenger(setpassengerid);
            string dummyflight = getdummyflight();

        for (case thiscase : listcasefordefaultvalue_insert) {
            if (lisentitlement.size() > 0 && thiscase.Entitlementid == null)
                thiscase.Entitlementid = lisentitlement.get(0).id;
            if (thiscase.recordtypeid == CFMSRECORDTYPECREATEID) // Change record type when user manually create.
                thiscase.recordtypeid = CFMSRECORDTYPEID;
            
            if (thiscase.passengerid__c != null) {
                if (Mappassenger.containskey(thiscase.passengerid__c)) {
                    passenger__c thispassenger = Mappassenger.get(thiscase.passengerid__c);

                    thiscase.PNR__c = thispassenger.PNR__c;
                    if (thiscase.Passenger_Phone__c == null) {
                        thiscase.Passenger_Phone__c = thispassenger.Phone__c;
                    }
                    thiscase.Passenger_Mobile__c = thispassenger.Mobile__c;

                    if (thiscase.Passenger_Email__c == null) {
                        if (!String.isBlank(thispassenger.Email_1__c)) {
                            thiscase.Passenger_Email__c = thispassenger.Email_1__c;
                        } else if (!String.isBlank(thispassenger.Accountid__r.ROP_Email_1__c)) {
                            thiscase.Passenger_Email__c = thispassenger.Accountid__r.ROP_Email_1__c;
                        } else if (!String.isBlank(thispassenger.AccountId__r.ROP_Email_2__c)) {
                            thiscase.Passenger_Email__c = thispassenger.Accountid__r.ROP_Email_2__c;
                        }
                    }

                    thiscase.FFP__c = thispassenger.FFP_Number__c;
                    thiscase.ROP_Tier__c = thispassenger.FFP_Tier__c;
                    thiscase.Nationality__c = thispassenger.Nationality__c;

                    if (thispassenger.accountid__c != null) {
                        thiscase.accountid = thispassenger.AccountId__c;
                        thiscase.Local_Name__c = thispassenger.Accountid__r.Local_Name__c;
                        thiscase.ROP_Number__c = thispassenger.Accountid__r.ROP_Number__c;
                        thiscase.Passenger_Country_Code__c = thispassenger.Accountid__r.ROP_Business_Country_Code__c;

                    }
                }
            }
        }
    }
    
    //22-3-2017 Defualt TGXXX for email case
    public void defaultflightforemail(list<Case> listemailcase){
    
        string dummyflight = getdummyflight();
    
        for(Case thisemailcase : listemailcase){
            if (thisemailcase.SuppliedEmail != null) {
                thisemailcase.Flightid__c = dummyflight;
            }
        }
    }    

    public void findletterbody(list<case> listfindemailbodycase, set<id> setletterid) {
        Map<id, letter_Master__c> Mapletter = new Map<Id, Letter_Master__c>([Select id, description__c from letter_Master__c where id IN: setletterid]);

        for (Case thiscase : listfindemailbodycase) {
            if (Mapletter.Containskey(thiscase.Letter_Bodyid__c)) {
                thiscase.Email_Body_txt__c = Mapletter.get(thiscase.Letter_Bodyid__c).Description__c;
            } else {
                thiscase.Email_Body_txt__c = '';
            }
        }
    }

    private List<Entitlement> getdefaultentitlement() {
        return [Select id from entitlement where name = : CASE_ENTITLEMENTNAME];
    }

    private Map<id, string> getmaprecordtype() {
        Map<id, string> Maprecordtype = new Map<id, string>();
        List<RecordType> listcaserecordtype = [Select Id, name From RecordType where sobjecttype = 'Case'];

        if (listcaserecordtype.size() > 0) {
            for (RecordType rc : listcaserecordtype) {
                Maprecordtype.put(rc.id , rc.name);

                if (rc.name == CFMS_RT)
                    CFMSRECORDTYPECREATEID = rc.id;
                if (rc.name == CFMSVIEW_RT)
                    CFMSRECORDTYPEID = rc.id;
            }
        }

        return Maprecordtype;
    }

    private Map<id, list<Compensation__c>> getmapcompensation(set<id> setcaseid) {

        Map<id, list<Compensation__c>> mapcompensation = new Map<id, list<Compensation__c>>();
        List<Compensation__c> listcomp = new List<Compensation__c>();

        listcomp = [Select id, status__c, caseid__c, Record_Type_Name__c, RecordTypeId from Compensation__c where caseid__c IN : setcaseid and (Status__c = 'New' or Status__c = 'Pending')];

        if (listcomp.size() > 0) {
            for (Compensation__c comp : listcomp) {
                if (mapcompensation.containskey(comp.caseid__c)) {
                    list<Compensation__c> listcurrencomp = new list<Compensation__c>();
                    listcurrencomp = mapcompensation.get(comp.caseid__c);
                    listcurrencomp.add(comp);
                    mapcompensation.put(comp.caseid__c , listcurrencomp);
                } else {
                    list<Compensation__c> listcurrencomp = new list<Compensation__c>();
                    listcurrencomp.add(comp);
                    mapcompensation.put(comp.caseid__c , listcurrencomp);
                }
            }
        }

        return mapcompensation;
    }

    @TestVisible
    private Map<id, passenger__c> getmappassenger(set<id> setpassengerid) {

        Map<id, passenger__c> Mappassenger = new Map<id, passenger__c>();
        list<passenger__c> listpassenger = [Select id, PNR__c, Phone__c, Mobile__c, Email_1__c, FFP_Number__c, FFP_Tier__c, Nationality_fullname__c,
                                            AccountId__c, Accountid__r.Local_Name__c, Accountid__r.ROP_Number__c, Nationality__c,
                                            Accountid__r.ROP_Tier__c, Accountid__r.ROP_Business_Country_Code__c, Accountid__r.Nationality__c, Accountid__r.ROP_Email_1__c, AccountId__r.ROP_Email_2__c
                                            from passenger__c where id IN : setpassengerid];

        if (listpassenger.size() > 0) {
            for (passenger__c pass : listpassenger) {
                Mappassenger.put(pass.id, pass);
            }
        }

        return Mappassenger;
    }

    public Boolean Acknowleageontime(Case thiscase) {
        Boolean result = false;
        Datetime currentdate = System.Now();
        Datetime acknowleageontime = thiscase.createddate.adddays(1);

        if (currentdate < acknowleageontime) {
            result = true;
        }

        System.debug('acknowleageontime : ' + acknowleageontime );

        return result;
    }

    public void Platinum_or_Firstclass(Case thiscase) {

        System.debug(' CLASS : ' + thiscase.accepted_class__c  + ' ROP : ' + thiscase.ROP_Tier__c );

        if (thiscase.accepted_class__c == FIRSTCLASS) {
            thiscase.Acknowledge_First__c = 1;
        }
        if (thiscase.ROP_Tier_F__c == PLATINUMROP) {
            thiscase.Acknowledge_Platinum__c = 1;
        }

        System.debug(' F : ' + thiscase.Acknowledge_First__c + ' P : ' + thiscase.Acknowledge_Platinum__c);

    }

    @TestVisible
    private id getdummyflight() {
        List<Flight__c> flightList = [Select id from flight__c where Name = : TGXXX];
        Flight__c dummyFlight = null;
        if (flightList.size() == 0) {
            dummyFlight = new Flight__c(Name = TGXXX);
            Boolean previousFlightTriggerState = TriggerActivator.isTriggerActivated(TriggerActivator.FLIGHT_TRIGGER);
            TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, false);
            insert dummyFlight;
            TriggerActivator.overrideTriggerActivation(TriggerActivator.FLIGHT_TRIGGER, previousFlightTriggerState);
            return dummyflight.Id;
        } else {
            return flightList.get(0).Id;
        }
    }

    private void getlockcomp_recordtype(Compensation__c compen) {
        System.debug('JK: compenRecTypeName - ' + compen.Record_Type_Name__c);
        Map<String, RecordType> recMapByDevName = Case_TriggerHandler.getRecordTypeMapByDevName();
        System.debug('JK: is from abroad - ' + (compen.Record_Type_Name__c == ABROAD_COMPENSATION_RECORDTYPE));
        if(compen.Record_Type_Name__c == ABROAD_COMPENSATION_RECORDTYPE){
            System.debug('JK: abroad compen final');
            compen.RecordTypeId = recMapByDevName.containsKey(ABROAD_COMPENSATION_FINAL_RECORDTYPE_DEVNAME) ? recMapByDevName.get(ABROAD_COMPENSATION_FINAL_RECORDTYPE_DEVNAME).Id : compen.RecordTypeId;
        }
        else if(compen.Record_Type_Name__c == CFMS_COMPENSATION_RECORDTYPE){
            compen.RecordTypeId =  recMapByDevName.containsKey(CFMS_COMPENSATION_FINAL_RECORDTYPE_DEVNAME) ? recMapByDevName.get(CFMS_COMPENSATION_FINAL_RECORDTYPE_DEVNAME).Id : compen.RecordTypeId;
        }
        
    }

    public static void sendEmergencyEmail(Set<Id> caseIdSet) {
        List<Case> caseList = [SELECT Id, Flightid__r.ETD_LT_DateTime__c, Flightid__r.ETA_LT_DateTime__c, Flightid__r.STD_LT_DateTime__c, Flightid__r.STA_LT_DateTime__c, Emergency_Send_Email__c, Flightid__r.Name, Flightid__r.Aircraftid__r.Name, Flightid__r.STD_UTC__c, Flightid__r.ETD_UTC__c, Flightid__r.STA_UTC__c, Flightid__r.ETA_UTC__c, Flightid__r.Aircraft_Description__c, Flightid__r.Origin__c, Flightid__r.Destination__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Passengerid__r.AccountId__r.ROP_Number__c, Passengerid__r.AccountId__r.ROP_Tier__c, Passengerid__r.AccountId__r.Gender__c, Passengerid__r.AccountId__r.Nationality__c, Emergency_Type__c, Description, Reported_By_Crew__r.Name, Reported_By_Crew__r.Rank__c, Created_By_Crew__r.Name, Created_By_Crew__r.Rank__c, Passengerid__r.FFP_Number__c, Passengerid__r.FFP_Tier__c, Passengerid__r.Gender__c, Passengerid__r.Nationality_Fullname__c, CrewId__c, Passengerid__r.FFP_Carrier__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, (SELECT Id, Staff_Name__c, Staff_Personal_Number__c, Passengerid__r.FFP_Carrier__c, Passengerid__r.Name, Passengerid__r.Checkin_Seat__c, Role__c, CrewId__r.Name, CrewId__r.Rank__c, CrewId__r.Personel_Id__c, Detail__c FROM Case_Group_Members__r) FROM Case WHERE Id IN :caseIdSet];

        List<Custom_Mail_List__mdt> mailList = [SELECT Id, Email_Address__c, Email_Type__c FROM Custom_Mail_List__mdt WHERE Email_Type__c = :BE8_GlobalConstants.EMAIL_TYPE_EMERGENCY_CASE];
        Set<String> emailAddressSet = BE8_GlobalUtility.getStringSet('Email_Address__c', mailList);
        List<String> emailAddressList = new List<String>();
        if (emailAddressSet != null) {
            emailAddressList = new List<String>(emailAddressSet);
        }

        for (Case each : caseList) {
            if (each.Emergency_Send_Email__c) {
                Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
                String body = new EmergencyEmailController(each).getBody();
                System.debug('body' + body);
                mail.setHtmlBody(body);
                mail.setToAddresses(emailAddressList);
                mail.setSubject(each.Emergency_Type__c + ', ' + each.Flightid__r.Name);
                Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail});
                //BE8_GlobalUtility.sendTemplatedEmail(emailAddressList, null, BE8_GlobalConstants.EMAIL_TEMPLATE_EMERGENCY, each.OwnerId, each.Id, null, false, null);
            }
        }
    }

    public static Map<Id, Master_Map__c> getMasterMapMap(List<Id> idComponent) {
        if (masterMapMap == null) {
            masterMapMap = new Map<Id, Master_Map__c> ([Select Id, Name From Master_Map__c Where Id In :idComponent]);
        }
        return masterMapMap;
    }

    public static Map<String, String> getEmailTemplateString(Map<String, List<SObject>> gcaseMap, Map<String, List<SObject>>compenMap, List<Case> caseList) {
        Map<String, String> returnStrMap = new Map<String, String>();
        String caseType = '';
        for (Case c : caseList) {
            String emailTemplate = '';
            if(c.Case_Type__c != null){
                caseType = c.Case_Type__c.indexOf('DBC') != -1 ? 'DBC' : 'DGC';
            }
            if(gcaseMap.containsKey(c.Id)){
                for (Case_Group_Member__c gcase : (List<Case_Group_Member__c>)gcaseMap.get(c.Id)) {
                    Integer loopCount = 1;
                    //emailTemplate += (gcase.PassengerId__r.PNR__c + ' ' + gcase.PassengerId__r.Last_Name__c + '/' + gcase.PassengerId__r.First_Name__c + '      ' + caseType + ' PAID \n');
                    emailTemplate += (gcase.PassengerId__r.PNR__c + ' ' + gcase.PassengerId__r.Last_Name__c + '/' + gcase.PassengerId__r.First_Name__c + '\n');
                    System.debug('JK compenlist');
                    System.debug((List<Compensation__c>)compenMap.get(c.Id));
                    if(compenMap.containsKey(c.Id)){
                        for (Compensation__c compen : (List<Compensation__c>)compenMap.get(c.Id)) {
                            if (compen.Compensation_Tools__c == 'Cash') {
                                emailTemplate += caseType + ' PAID ' + compen.Amount__c + ' ' + compen.Currency__c;
                            } else {
                                emailTemplate += compen.Compensation_Detail__c;
                            }
                            if (loopcount < ((List<Compensation__c>)compenMap.get(c.Id)).size()) {
                                emailTemplate += '\n';
                            }
                            loopcount++;
                        }
                        emailTemplate += '\n';
                    }
                }
                returnStrMap.put(c.Id, emailTemplate);
            }
        }
        System.debug('JK return map');
        System.debug(JSON.serialize(returnStrMap));
        return returnStrMap;
    }

    public static Map<String, String> getCaseCompensationToolsString(List<Case> caseList, Map<String, List<SObject>>compenMap){
        Map<String, String> returnMap = new Map<String, String>();
         for(Case eachCase : caseList){
            Set<String> compenToolsSet = new Set<String>();
            if(compenMap.containsKey(eachCase.Id)){
                for(Compensation__c eachCompen : (List<Compensation__c>)compenMap.get(eachCase.Id)){
                    if(eachCompen.Compensation_Tools__c != null && eachCompen.Compensation_Tools__c != '' && eachCompen.Status__c == APPROVED){
                        compenToolsSet.add(eachCompen.Compensation_Tools__c);
                    }
                }
                returnMap.put(eachCase.Id, BE8_GlobalUtility.getSetToString(compenToolsSet));
            }
         }
         return returnMap;
    }

    public static void setCaseGroupMemberStatusToCompleted(List<Case_Group_Member__c> cgmList) {
        for (Case_Group_Member__c cgm : cgmList) {
            cgm.Impact__c = 'Complete';
        }
    }
    public static void updateCaseOnWaitingforResponseStatus(List<Case> caseList, Map<Id, User> roleMap) {
        //Map<String, SObject> roleMap = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id, Name, UserRole.Name FROM User]);
        for (Case eachCase : caseList) {
            if (eachCase.Status == Status_Waiting_For_Response) {
                if(eachCase.First_Reply_By__c == null){
                    eachCase.First_Reply_By__c = UserInfo.getName();
                    eachCase.First_Reply_By_Role__c = roleMap.get(UserInfo.getUserId()).UserRole.Name;
                    eachCase.First_Reply_Time__c = DateTime.now();
                }
                eachCase.Waiting_for_Response_by__c = UserInfo.getName();
                eachCase.Waiting_for_Response_Time__c = DateTime.now();
                eachCase.Waiting_for_Response_by_Role__C = roleMap.get(UserInfo.getUserId()).UserRole.Name;
            }
            else if(isNeededToUpdateCaseOnWaitingforResponseStatus(eachCase)){
                if(eachCase.First_Handle_By__c == null){
                    eachCase.First_Reply_By__c = UserInfo.getName();
                    eachCase.First_Reply_By_Role__c = roleMap.get(UserInfo.getUserId()).UserRole.Name;
                    eachCase.First_Reply_Time__c = DateTime.now();
                }
            }
        }
    }

    private static Boolean isNeededToUpdateCaseOnWaitingforResponseStatus(Case eachcase){
        return (eachcase.Status == CUSTOMER_RESPONSE || eachcase.Status == RESOLVED || eachcase.Status == CLOSED) && eachcase.Waiting_for_Response_by__c == null;
    }

    public static void updateCaseOnWaitingforResponseStatus(Case caseList, Map<Id, User> roleMap) {
        updateCaseOnWaitingforResponseStatus(new List<Case> {caseList}, roleMap);
    }

    public static void updateCaseOnEscalatedStatus(List<Case> caseList, Map<Id, User> roleMap, Map<Id, Case> oldCaseMap) {
        System.debug('JK: Case Management - Method');
        for (Case eachCase : caseList) {
            if (eachCase.Status == Status_Escalated) {
                if(oldCaseMap != null){
                    Case oldCase = oldCaseMap.get(eachCase.Id);
                    if (oldCase != null && roleMap.get(oldCase.OwnerId) != null) {
                        eachCase.Escalate_by_Role__c = roleMap.get(oldCaseMap.get(eachCase.Id).OwnerId).UserRole.Name;
                    }
                }
                if (roleMap.get(eachCase.OwnerId) != null) {
                    eachCase.Escalate_to_Role__c = roleMap.get(eachCase.OwnerId).UserRole.Name;
                    eachCase.Escalate_to__c = roleMap.get(eachCase.OwnerId).Name;
                }
            }
            System.debug(JSON.serialize(eachCase));
        }
    }

    public static void updateCaseOnEscalatedStatus(Case caseList, Map<Id, User> roleMap, Map<Id, Case> oldCaseMap) {
        updateCaseOnEscalatedStatus(new List<Case> {caseList}, roleMap, oldCaseMap);
    }

    public static void updateCaseToS4T1GB(List<Case> caseList, Map<Id, User> roleMap) {
        for (Case eachCase : caseList) {
            if (roleMap.get(eachCase.OwnerId) != null) {
                if (roleMap.get(eachCase.OwnerId).UserRole.Name == S4T1GBName) {
                    eachCase.S4_Tier1_Group_B_receive_time__c = DateTime.now();
                } else if (roleMap.get(eachCase.OwnerId).UserRole.Name == S4T1GAName) {
                    eachCase.S4_Tier_1_Group_A_receive_time__c = Datetime.now();
                }
            }
        }
    }

    public static void updateCaseToS4T1GB(Case caseList, Map<Id, User> roleMap) {
        updateCaseToS4T1GB(new List<Case> {caseList}, roleMap);
    }

    public static void updateCaseToS4T1GB(List<Case> caseList, Map<Id, User> roleMap, Map<Id, Case> oldCaseMap) {
        for (Case eachCase : caseList) {
            if (roleMap.get(eachCase.OwnerId) != null && oldCaseMap.get(eachCase.Id) != null) {
                if (eachCase.OwnerId != oldCaseMap.get(eachCase.Id).OwnerId) {
                    if (roleMap.get(eachCase.OwnerId).UserRole.Name == S4T1GBName) {
                        eachCase.S4_Tier1_Group_B_receive_time__c = DateTime.now();
                    } else if (roleMap.get(eachCase.OwnerId).UserRole.Name == S4T1GAName) {
                        eachCase.S4_Tier_1_Group_A_receive_time__c = Datetime.now();
                    }
                }
            }
        }
    }

    public static void updateCaseToS4T1GB(Case caseList, Map<Id, User> roleMap, Map<Id, Case> oldCaseMap) {
        updateCaseToS4T1GB(new List<Case> {caseList}, roleMap, oldCaseMap);
    }

    public static void updateCaseOnCaseClosed(List<Case> caseList, Map<Id, User> roleMap) {
        //Map<String, SObject> roleMap = BE8_GlobalUtility.getSObjectMap('Id', [SELECT Id, Name, UserRole.Name FROM User]);
        for (Case eachCase : caseList) {
            if (eachCase.Status == Status_Closed) {
                eachCase.Closed_by_Role__c = roleMap.get(UserInfo.getUserId()).UserRole.Name;
            }
        }
    }

    public static void updateCaseOnCaseClosed(Case caseList, Map<Id, User> roleMap) {
        updateCaseOnCaseClosed(new List<Case> {caseList}, roleMap);
    }

    public static void updateCaseOnOwnerChanged(List<Case> caseList, Map<Id, Case> oldCaseMap) {
        for (Case eachCase : caseList) {
            if (oldCaseMap != null && !oldCaseMap.isEmpty() && oldCaseMap.size() > 0) {
                Id oldCaseOwnerId = oldCaseMap.get(eachCase.Id).OwnerId;
                if (eachCase.OwnerId != oldCaseOwnerId) {
                    eachCase.Case_Owner_Changed_Time__c = DateTime.now();
                }
            }
        }
    }

    public static void updateCaseOnOwnerChanged(Case caseList, Map<Id, Case> oldCaseMap) {
        updateCaseOnOwnerChanged(new List<Case> {caseList}, oldCaseMap);
    }

    public static void sendApproval(Id objId, Id submitterId, Id approverId) {
        try {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(objId);
            //req.setSubmitterId(submitterId);
            req.setNextApproverIds(new List<Id> {approverId});
            //req.setSkipEntryCriteria(false);
            Approval.ProcessResult result = Approval.process(req);
            System.debug('Approval Result');
            System.debug(result);
        } catch (Exception e) {
            System.debug('Error on Approval');
            System.debug(e);
        }
    }

    public static void PrintLimit(String line, String event, String status) {
        System.debug('========================JK: CPU LIMIT (' + line + ') | ' + status + ' ' + event + ' : ' + Limits.getCpuTime() + ' / ' + Limits.getLimitCpuTime());
    }

    public static void AutomaticFlightNumberonCase(Case inputCase, Date fltDate) {
        System.debug('JK: AutomaticFlightNumberonCase');
        if (inputCase.Previous_Flight_Number__c.length() == 3 && inputCase.Previous_Flight_Number__c.isNumeric()) {
            System.debug('JK: AutomaticFlightNumberonCase - in if');
            inputCase.Previous_Flight_txt__c = 'TG' + inputCase.Previous_Flight_Number__c + ' / ' + BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(fltDate));
        } else {
            inputCase.Previous_Flight_Number__c.addError('Error: System will automatically populate the \'Previous Flight Number\'. Please enter a maximum of 3 digits that represent the Flight Number. E.g. Entering \'628\' will yield TG628 / DDMMMYY (based on the flight date from the initial flight number).');
        }

        System.debug(JSON.serialize(inputCase));
    }
    public static void AutomaticExpectedFlightNumberonCase(Case inputCase, Date fltDate) {
        System.debug('JK: AutomaticExpectedFlightNumberonCase');
        if (inputCase.Expected_Flight_Number__c.length() == 3 && inputCase.Expected_Flight_Number__c.isNumeric()) {
            System.debug('JK: AutomaticExpectedFlightNumberonCase - in if');
            inputCase.Expected_Flight_Display__c = 'TG' + inputCase.Expected_Flight_Number__c + ' / ' + BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(fltDate));
        } else {
            inputCase.Expected_Flight_Number__c.addError('Error: System will automatically populate the \'Previous Flight Number\'. Please enter a maximum of 3 digits that represent the Flight Number. E.g. Entering \'628\' will yield TG628 / DDMMMYY (based on the flight date from the initial flight number).');
        }

        System.debug(JSON.serialize(inputCase));
    }

    public static String getFlightNameFormat(String flightNumber, Date flightDate) {
        String fltNo = flightNumber.length() == 4 ? String.valueOf(Integer.valueOf(flightNumber)) : flightNumber;
        String fltDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(String.valueOf(flightDate));
        return 'TG' + fltNo + ' / ' + fltDate;
    }

    public static void updateCasePreviousFlight(Case inputCase, Flight__c previousFlight){
        inputCase.Previous_Flight__c = previousFlight.Id;
    }

    public static Task AutomaticNewTaskonCaseforFutureFlight(Case inputCase, System_Configuration__c sysconfig) {
        String priority = 'Medium';
        String status = 'Request';
        String taskType = 'Future Flight';
        Date expectedFlightDate = inputCase.Expected_Flight_Date__c - 3 > Date.today() ? inputCase.Expected_Flight_Date__c - 3 : inputCase.Expected_Flight_Date__c;
        Id currentUser = UserInfo.getUserId();
        String subject = TASK_SUBJECT_PREFIX_BF_FLTNO + inputCase.Expected_Flight_Display__c + TASK_SUBJECT_PREFIX_AF_FLTNO + inputCase.Subject;
        Id refId = inputCase.Id;
        Time reminderTime = getTimeInstance(sysconfig.Reminder_Time__c, '.');

        Task task = new Task();
        task.ActivityDate = expectedFlightDate;
        task.OwnerId = currentUser;
        task.Subject = subject;
        task.WhatId = refId;
        task.Priority = priority;
        task.Status = status;
        task.Task_Type__c = taskType;
        task.IsReminderSet = true;
        task.Is_Expected_Flight__c = true;
        System.debug('JK: expectedFlightDate - ' + expectedFlightDate);
        System.debug('JK: sysconfig.Reminder_Time__c - ' + sysconfig.Reminder_Time__c);
        System.debug('JK: reminderTime - ' + reminderTime);
        task.ReminderDateTime = Datetime.newInstance(expectedFlightDate, reminderTime);

        return task;
    }

    public static void ChangeCaseRecordTypeWhenStatusisClosed(Case inputCase, Id recordTypeId) {
        System.debug('JK: ChangeCaseRecordTypeWhenStatusisClosed');
        inputCase.RecordTypeId = recordTypeId;
        System.debug('recordTypeId: ' + recordTypeId);
        System.debug(JSON.serialize(inputCase));
    }

    public static Case_Group_Member__c CreateCGMonCaseCreation(Case inputCase, Passenger__c pax, Id cgmRecordTypeId) {
        System.debug('JK: CreateCGMonCaseCreation');
        System.debug('Pax: ' + JSON.serialize(pax.Id));
        System.debug('Pax: ' + JSON.serialize(pax));
        Case_Group_Member__c cgm = new Case_Group_Member__c();
        cgm.Caseid__c = inputCase.Id;
        cgm.AccountId__c = pax.AccountId__c;
        cgm.FFP_Number__c = pax.FFP_Number__c;
        cgm.FFP_Tier__c = pax.FFP_Tier__c;
        cgm.FlightId__c = pax.FlightId__c;
        cgm.PNR__c = pax.PNR__c;
        cgm.Passengerid__c = pax.Id;
        cgm.Position__c = pax.Checkin_Seat__c;
        cgm.Primary__c = true;
        cgm.RecordTypeId = cgmRecordTypeId;
        cgm.Travel_Class__c = pax.Cabin_Code__c;
        cgm.VIP__c = pax.VIP_VVIP_Flag__c;

        System.debug('CGM: ' + JSON.serialize(cgm));
        return cgm;
    }

    public static Case_Group_Member__c CreateCGMOnCaseUpdate(Case inputCase, Case oldCase, Passenger__c pax, Id cgmRecordTypeId){
        if(oldCase.PassengerId__c == null && !inputCase.Update_Passenger_By_Code__c){
            return CreateCGMonCaseCreation(inputCase, pax, cgmRecordTypeId);
        }
        return null;
    }

    public static void CreateSEQNo(Case inputCase, Aircraft__c aircraft) {
        System.debug('JK: CreateSEQNo');
        String seqNo = getSeqNoFormat(inputCase, aircraft);
        System.debug('seqNo: ' + seqNo);
        inputCase.SEQ_No_Display__c = seqNo;
        System.debug(JSON.serialize(inputCase));
    }

    public static void EscalationTierwhenCaseCreated(Case inputCase, Map<String, Group> queueMap, String escalateto, Id recordTypeId) {
        System.debug('JK: EscalationTierwhenchangestatustoEscalated');
        if (escalateto == 'S3 Tier 1') {
            inputCase.OwnerId = queueMap.get('S3 Tier 1 Team').Id;
        }

        else if (escalateto == 'S4 Level 8 IF') {
            inputCase.OwnerId = queueMap.get('S4 Level 8 In-Flight Team').Id;
            inputCase.Status = inputCase.Case_Type__c == 'Information' && inputCase.Priority != 'Urgent' ? CLOSED : ESCALATED;
        }

        else if (escalateto == 'S4 FP IF') {
            inputCase.OwnerId = queueMap.get('S4 First & Platinum Team').Id;
        }

        else if (escalateto == 'S4 Tier 2') {
            inputCase.OwnerId = queueMap.get('S4 Tier 2 Team').Id;
        }

        else if (escalateto == 'S4 Tier 1') {
            inputCase.OwnerId = queueMap.get('S4 Tier 1 Group A Team').Id;
            if(inputCase.Case_Type__c != 'Information'){
                inputCase.Status = 'Acknowledge';
            }
            if(inputCase.SuppliedEmail != null){
                inputCase.Origin = 'Email';
            }
        }

        else if (escalateto == 'TGWebMaster') {
            inputCase.OwnerId = queueMap.get('S4 Tier 1 Group A Team').Id;
            inputCase.Status = 'Acknowledge';
        }

        else if(escalateto == 'Email'){
            inputCase.OwnerId = queueMap.get('S4 Tier 1 Group A Team').Id;
            inputCase.Status = 'Acknowledge';
        }
        inputCase.RecordTypeId = recordTypeId != null ? recordTypeId : inputCase.RecordTypeId;
    }

    public static void EscalationTierwhenchangestatustoEscalated(Case inputCase, Map<String, Group> queueMap, String escalateto, Id recordTypeId) {
        System.debug('JK: EscalationTierwhenchangestatustoEscalated');
        if (escalateto == 'S3 Tier 1') {
            inputCase.OwnerId = queueMap.get('S3 Tier 1 Team').Id;
        }

        else if (escalateto == 'S3 Chief') {
            inputCase.OwnerId = queueMap.get('S3 Chief Team').Id;
        }

        else if (escalateto == 'S4 Level 8 CFMS') {
            inputCase.OwnerId = queueMap.get('S4 Level 8 Team').Id;
        }

        else if (escalateto == 'S4 Level 8 Ground') {
            inputCase.OwnerId = queueMap.get('S4 Level 8 Ground Team').Id;
        }

        else if (escalateto == 'S4 Tier 2 FP') {
            inputCase.OwnerId = queueMap.get('S4 First & Platinum Team').Id;
        }

        else if (escalateto == 'AO Tier 2 BC') {
            inputCase.OwnerId = queueMap.get('AO Tier 2 Team').Id;
        }

        else if (escalateto == 'S4 Tier 2') {
            inputCase.OwnerId = queueMap.get('S4 Tier 2 Team').Id;
        }
        inputCase.RecordTypeId = recordTypeId != null ? recordTypeId : inputCase.RecordTypeId;
    }

    public static String getSeqNoFormat(Case inputCase, Aircraft__c aircraft) {
        String twodigitsFromACReg = aircraft.Aircraft_Registration__c;
        twodigitsFromACReg = twodigitsFromACReg.substring(twodigitsFromACReg.length() - 2, twodigitsFromACReg.length());
        String seqNoTxt = inputCase.SEQ_No_txt__c;
        if (seqNoTxt.length() < 3) {
            seqNoTxt = seqNoTxt.length() == 2 ? '0' + seqNoTxt : '00' + seqNoTxt;
        }
        String incidentType = inputCase.Incident_Type__c == 'Cabin Log' ? 'C' : 'F';
        String seqNoDate = getSeqNoDateFormat(String.valueOf(inputCase.SEQ_No_Date__c));

        String seqNo = twodigitsFromACReg + seqNoTxt + incidentType + seqNoDate;

        return seqNo;
    }

    public static System_Configuration__c getSystemConfiguration() {
        return Case_TriggerHandler.getSysconfig();
    }

    public static String getSeqNoDateFormat(String d) {
        List<String> dateList = d.split('-');
        String day = dateList.get(2);
        String month = dateList.get(1);
        String year = dateList.get(0).substring(dateList.get(0).length() - 2, dateList.get(0).length());
        return day + month + year;
    }

    public static Time getTimeInstance(String timeInstance, String delimiter){
        Time returnTime = null;
        List<String> timeList = delimiter == '.' ? timeInstance.split('\\' + delimiter) : timeInstance.split(delimiter);
        System.debug('JK: timeInstance - ' + timeInstance);
        System.debug('JK: delimiter - ' + delimiter);
        System.debug('JK: timeList - ' + timeList);
        if(timeList.size() == 2){
            returnTime = Time.newInstance(Integer.valueOf(timeList.get(0)), Integer.valueOf(timeList.get(1)), 0, 0);
        }
        else if(timeList.size() == 3){
            returnTime = Time.newInstance(Integer.valueOf(timeList.get(0)), Integer.valueOf(timeList.get(1)), Integer.valueOf(timeList.get(2)), 0);
        }
        else if(timeList.size() == 4){
            returnTime = Time.newInstance(Integer.valueOf(timeList.get(0)), Integer.valueOf(timeList.get(1)), Integer.valueOf(timeList.get(2)), Integer.valueOf(timeList.get(3)));
        }

        return returnTime;
    }

    public static Set<String> getPreviousFlightNumberSetFromCase(List<Case> caseList){
        Set<String> returnList = new Set<String>();
        for(Case thisca : caseList){
            if(thisca.Previous_Flight_Number__c != null && thisca.Previous_Flight_Date__c != null){
                returnList.add(getFlightNameFormat(thisca.Previous_Flight_Number__c, thisca.Previous_Flight_Date__c));
            }
        }
        return returnList;
    }

    public static Set<String> getExpectedFlightNumberSetFromCase(List<Case> caseList){
        Set<String> returnList = new Set<String>();
        for(Case thisca : caseList){
            if(thisca.Expected_Flight_Number__c != null && thisca.Expected_Flight_Date__c != null){
                returnList.add(getFlightNameFormat(thisca.Expected_Flight_Number__c, thisca.Expected_Flight_Date__c));
            }
        }
        return returnList;
    }

    public static Map<Id, String> getPreviousFlightNumberMapFromCase(List<Case> caseList){
        Map<Id, String> returnMap = new Map<Id, String>();
        for(Case thisca : caseList){
            if(thisca.Id != null && thisca.Previous_Flight_Number__c != null && thisca.Previous_Flight_Date__c != null){
                returnMap.put(thisca.Id, getFlightNameFormat(thisca.Previous_Flight_Number__c, thisca.Previous_Flight_Date__c));
            }
        }
        return returnMap;
    }

    public static Map<Id, String> getExpectedFlightNumberMapFromCase(List<Case> caseList){
        Map<Id, String> returnMap = new Map<Id, String>();
        for(Case thisca : caseList){
            if(thisca.Id != null && thisca.Expected_Flight_Number__c != null && thisca.Expected_Flight_Date__c != null){
                returnMap.put(thisca.Id, getFlightNameFormat(thisca.Expected_Flight_Number__c, thisca.Expected_Flight_Date__c));
            }
        }
        return returnMap;
    }

    public static void EscalateCaseFlowForAbroadStation(Case inputCase, Map<Id, User> roleMap, Map<Id, Compensation__c> compensationMap, Map<String, RecordType> recordTypeMap){
        System.debug('JK: inputCase Status - ' + inputCase.Status);
        if(roleMap.containsKey(inputCase.OwnerId) && roleMap.get(inputCase.OwnerId).Station__c != 'BKK'){
            Boolean isCompen = getIsCompen(compensationMap, inputCase);
            if(inputCase.Status == 'Escalated' || (isCompen && inputCase.Status == 'Resolved')){
                /* change owner to SD/SR Queue */
                Map<String, Group> gMap = Case_TriggerHandler.getQueueMap();
                Map<String, String> stationQMap = Case_TriggerHandler.getAbroadStationQueueMap();
                String userStation = roleMap.get(inputCase.OwnerId).Station__c;
                String qName = stationQMap.get(userStation); 
                
                /* debug session */
                System.debug('JK: DEBUG EscalateCaseFlowForAbroadStation');
                System.debug('gMap: ' + JSON.serialize(gMap));
                System.debug('stationQMap: ' + JSON.serialize(stationQMap));
                System.debug('userStation: ' + JSON.serialize(userStation));
                System.debug('qName: ' + JSON.serialize(qName));
                /* END */

                if(gMap.containsKey(qName)){
                    inputCase.OwnerId = gMap.get(qName).Id;
                    inputCase.RecordTypeId = recordTypeMap.get(CFMSVIEW_RECORDTYPE).Id;
                }
            }
            else if(inputCase.Status == 'Resolved' && !isCompen){
                inputCase.Status = 'Closed';
                inputCase.RecordTypeId = recordTypeMap.get(GS_CLOSE_RECORDTYPE).Id;
            }
        }
    }

    public static Boolean getIsCompen(Map<Id, Compensation__c> compenMap, Case inputCase){
        return inputCase.Id != null && compenMap.containskey(inputCase.Id) ? true : false;
    }

    public static Task updateTask(Map<Id, Task> taskMap, Case inputCase, System_Configuration__c sysconfig){
        Task returnTask = null;
        if(taskMap != null && taskMap.containskey(inputCase.Id)){
            Date expectedFlightDate = inputCase.Expected_Flight_Date__c - 3 > Date.today() ? inputCase.Expected_Flight_Date__c - 3 : inputCase.Expected_Flight_Date__c;
            Time reminderTime = getTimeInstance(sysconfig.Reminder_Time__c, '.');
            String subject = TASK_SUBJECT_PREFIX_BF_FLTNO + inputCase.Expected_Flight_Display__c + TASK_SUBJECT_PREFIX_AF_FLTNO + inputCase.Subject;
            returnTask = taskMap.get(inputCase.Id);
            returnTask.Subject = subject;
            returnTask.ActivityDate = expectedFlightDate;
            returnTask.ReminderDateTime = Datetime.newInstance(expectedFlightDate, reminderTime);
        }
        else{
            returnTask = AutomaticNewTaskonCaseforFutureFlight(inputCase, sysconfig);
        }
        return returnTask;
    }

    public static Task cancelTask(Map<Id, Task> taskMap, Case inputCase, System_Configuration__c sysconfig){
        Task returnTask = null;
        if(taskMap != null && taskMap.containskey(inputCase.Id)){
            returnTask = taskMap.get(inputCase.Id);
            returnTask.Status = 'Cancelled';
        }
        return returnTask;
    }

    public static void updateExpectedFlightOnCaseInsert(Case inputCase, Map<Id, Flight__c> flightMap, Map<String, List<Flight__c>> flightMapByName){
        Boolean isError = false;
        Boolean isExist = false;
        Boolean isFlightError = false;
        System.debug('JK: BFIF');
        if(inputCase.Expected_Flight_Number__c != null || inputCase.Expected_Flight_Date__c != null){
            System.debug('JK: INIF');
            if(flightMap.get(inputCase.Flightid__c).Name != 'TGXXX'){
                Boolean iscontain = false;
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    String flightName = Case_Management.getFlightNameFormat(inputCase.Expected_Flight_Number__c, inputCase.Expected_Flight_Date__c);
                    if(flightMapByName.containsKey(flightName)){
                        inputCase.Expected_Flight_Date__c.addError('Please remove Expected Flight Date');
                        inputCase.Expected_Flight_Number__c.addError('Please remove Expected Flight Number');
                        iscontain = true;
                        isError = true;
                    }
                }
                if(!iscontain){
                    inputCase.FlightId__c.addError('Flight Number should be "TGXXX" when Expected Flight Number and/or Expected Flight Date are filled.');
                    isError = true;
                }
            }
            else if(flightMap.get(inputCase.Flightid__c).Name == 'TGXXX'){
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    String flightName = Case_Management.getFlightNameFormat(inputCase.Expected_Flight_Number__c, inputCase.Expected_Flight_Date__c);
                    if(flightMapByName.containsKey(flightName)){
                        inputCase.FlightId__c.addError('"' + flightName + '" was existed in salesforce, Please change Flight to be "' + flightName + '" instead of "TGXXX".');
                        isExist = true;
                        isError = true;
                    }
                }
                if(!isExist && inputCase.Expected_Flight_Date__c <= Date.today()){
                    inputCase.Expected_Flight_Date__c.addError('Expected Flight Date must not be in the past.');
                    isError = true;
                }
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c == null){
                    inputCase.Expected_Flight_Date__c.addError('Expected Flight Date must not be null while Expected Flight Number is filled.');
                    isError = true;
                }
                if(inputCase.Expected_Flight_Number__c == null && inputCase.Expected_Flight_Date__c != null){
                    inputCase.Expected_Flight_Number__c.addError('Expected Flight Number must not be null while Expected Flight Date is filled.');
                    isError = true;
                }
                if(!isError && flightMap.containsKey(inputCase.Flightid__c) && flightMap.get(inputCase.Flightid__c).Name == 'TGXXX' && inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    System.debug('JK: DEBUG stamp expected flight');
                    Case_Management.AutomaticExpectedFlightNumberonCase(inputCase, inputCase.Expected_Flight_Date__c);
                }
            }
        }
        else if ((inputCase.Expected_Flight_Number__c == '' || inputCase.Expected_Flight_Number__c == null) && inputCase.Expected_Flight_Display__c != null) {
            System.debug('JK: Clear variable');
            inputCase.Expected_Flight_Display__c = null;
            inputCase.Expected_Flight_Number__c = null;
            inputCase.Expected_Flight_Date__c = null;
            inputCase.Expected_Flight_Sector__c = null;
            inputCase.Expected_PNR__c = null;
        }
    }

    public static Task updateExpectedFlightOnCaseUpdate(Case inputCase, Map<Id, Flight__c> flightMap, Map<String, List<Flight__c>> flightMapByName, Case oldCase, System_Configuration__c sysconfig, List<Case> caseList){
        Task returnTask = null;
        Boolean isError = false;
        Boolean isExist = false;
        Boolean isFlightError = false;

        if(inputCase.Expected_Flight_Number__c != null || inputCase.Expected_Flight_Date__c != null){
            if(flightMap.get(inputCase.Flightid__c).Name != 'TGXXX'){
                Boolean iscontain = false;
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    String flightName = Case_Management.getFlightNameFormat(inputCase.Expected_Flight_Number__c, inputCase.Expected_Flight_Date__c);
                    if(flightMapByName.containsKey(flightName)){
                        inputCase.Expected_Flight_Date__c.addError('Please remove Expected Flight Date');
                        inputCase.Expected_Flight_Number__c.addError('Please remove Expected Flight Number');
                        iscontain = true;
                        isError = true;
                    }
                }
                if(!iscontain){
                    inputCase.FlightId__c.addError('Flight Number should be "TGXXX" when Expected Flight Number and/or Expected Flight Date are filled.');
                    isError = true;
                }
            }
            else if(flightMap.get(inputCase.Flightid__c).Name == 'TGXXX'){
                System.debug('JK: updateExpectedFlightOnCaseUpdate');
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    String flightName = Case_Management.getFlightNameFormat(inputCase.Expected_Flight_Number__c, inputCase.Expected_Flight_Date__c);
                    if(flightMapByName.containsKey(flightName)){
                        inputCase.FlightId__c.addError('"' + flightName + '" was existed in salesforce, Please change Flight to be "' + flightName + '" instead of "TGXXX".');
                        isExist = true;
                        isError = true;
                    }
                }
                if(!isExist && inputCase.Expected_Flight_Date__c <= Date.today()){
                    inputCase.Expected_Flight_Date__c.addError('Expected Flight Date must not be in the past.');
                    isError = true;
                }
                if(inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c == null){
                    inputCase.Expected_Flight_Date__c.addError('Expected Flight Date must not be blank while Expected Flight Number is filled.');
                    isError = true;
                }
                if(inputCase.Expected_Flight_Number__c == null && inputCase.Expected_Flight_Date__c != null){
                    inputCase.Expected_Flight_Number__c.addError('Expected Flight Number must not be blank while Expected Flight Date is filled.');
                    isError = true;
                }
                if(!isError && flightMap.containsKey(inputCase.Flightid__c) && flightMap.get(inputCase.Flightid__c).Name == 'TGXXX' && inputCase.Expected_Flight_Number__c != null && inputCase.Expected_Flight_Date__c != null){
                    if (inputCase.Expected_Flight_Number__c != oldCase.Expected_Flight_Number__c || inputCase.Expected_Flight_Date__c != oldCase.Expected_Flight_Date__c) {
                        System.debug('JK: DEBUG expected flight');
                        Case_Management.AutomaticExpectedFlightNumberonCase(inputCase, inputCase.Expected_Flight_Date__c);
                        Map<Id, Task> tMap = Case_TriggerHandler.getTaskMap(BE8_GlobalUtility.getIdSet('Id', caseList));
                        System.debug('JK: DEBUG caseIdSet: ' + JSON.serialize(BE8_GlobalUtility.getIdSet('Id', caseList)));
                        System.debug('JK: DEBUG tMap: ' + JSON.serialize(tMap));
                        System.debug('JK: DEBUG thisca: ' + JSON.serialize(inputCase));
                        System.debug('JK: DEBUG sysconfig: ' + JSON.serialize(sysconfig));

                        returnTask = Case_Management.updateTask(tMap, inputCase, sysconfig);
                        System.debug('JK: returnTask - ' + JSON.serialize(returnTask));
                    }
                }
            }

        }
        else if ((inputCase.Expected_Flight_Number__c == '' || inputCase.Expected_Flight_Number__c == null) && inputCase.Expected_Flight_Display__c != null) {
            System.debug('JK: Clear variable');
            inputCase.Expected_Flight_Display__c = null;
            inputCase.Expected_Flight_Number__c = null;
            inputCase.Expected_Flight_Date__c = null;
            inputCase.Expected_Flight_Sector__c = null;
            inputCase.Expected_PNR__c = null;
            Map<Id, Task> tMap = Case_TriggerHandler.getTaskMap(BE8_GlobalUtility.getIdSet('Id', caseList));
            System.debug('JK: DEBUG cancel task');
            System.debug('JK: DEBUG caseIdSet: ' + JSON.serialize(BE8_GlobalUtility.getIdSet('Id', caseList)));
            System.debug('JK: DEBUG tMap: ' + JSON.serialize(tMap));
            System.debug('JK: DEBUG thisca: ' + JSON.serialize(inputCase));
            System.debug('JK: DEBUG sysconfig: ' + JSON.serialize(sysconfig));

            returnTask = Case_Management.cancelTask(tMap, inputCase, sysconfig);
            System.debug('JK: returnTask - ' + JSON.serialize(returnTask));
        }
        return returnTask;
    }

    public static void updateCaseFromWebMaster(Case thisca, System_Configuration__c sysconfig){
        if(thisca.SuppliedEmail == sysconfig.TGWebMaster_Email__c){
            thisca.Origin = 'TGWebsite';
        }
    }

    public static void updateLackofPartandLackofTimeWhenCaseComplete(Case inputCase){
        if(inputCase.Action__c == COMPLETE){
            inputCase.Lack_of_Part__c = false;
            inputCase.Lack_of_Time__c = false;
        }
    }

    public static void updateReportLackofPartandLackofTime(Case inputCase){
        if(!Case_TriggerHandler.getIsUpdateLackReportFlag()){
            inputCase.Report_Lack_of_Part__c = inputCase.Lack_of_Part__c == true ? true : false;
            inputCase.Report_Lack_of_Time__c = inputCase.Lack_of_Time__c == true ? true : false;
            Case_TriggerHandler.updateLackFlag();
        }
    }

    public static Boolean isCaseShouldEscalateToS3(){
        Map<Id, String> noEscalateToS3RoleMap = Case_TriggerHandler.getNoEscalateToS3RoleMap();
        return noEscalateToS3RoleMap.containsKey(UserInfo.getUserRoleId()) ? false : true;
    }

    public static void updateAuthorizeSignatureFieldSet(Case inputCase){
        Case_TriggerHandler ct = new Case_TriggerHandler();
        Map<String, User> usermap = getUserMapByName(ct.getRoleMap().values());
        Map<String, User> usermapth = getUserMapByNameTH(ct.getRoleMap().values());
        User u = null;
        if(usermap != null && usermapth != null){
            if(usermap.containsKey(inputCase.Authorize_Signature__c)){
                u = usermap.get(inputCase.Authorize_Signature__c);
            }
            else if(usermapth.containsKey(inputCase.Authorize_Signature__c)){
                u = usermapth.get(inputCase.Authorize_Signature__c);
            }
            if(u != null){
                inputCase.Department_EN_txt__c = u.Authorized_Department_EN__c;
                inputCase.Department_TH_txt__c = u.Authorized_Department_TH__c;
                inputCase.Position_EN_txt__c = u.Authorized_Position_EN__c;
                inputCase.Position_TH_txt__c = u.Authorized_Position_TH__c;
            }
            else{
                inputCase.Department_EN_txt__c = null;
                inputCase.Department_TH_txt__c = null;
                inputCase.Position_EN_txt__c = null;
                inputCase.Position_TH_txt__c = null;   
            }
            if(inputCase.Authorize_Signature__c != null) AppLogger.debug('Case_Management', 'updateAuthorizeSignatureFieldSet', null, 'Case Number: '+ inputCase.CaseNumber + '\nAuthorize_Signature: ' + inputCase.Authorize_Signature__c, null);if(inputCase.Authorize_Signature__c != null) AppLogger.debug('Case_Management', 'updateAuthorizeSignatureFieldSet', null, JSON.serialize(u), null);
            else AppLogger.debug('Case_Management', 'updateAuthorizeSignatureFieldSet', null, JSON.serialize(u), null);if(inputCase.Authorize_Signature__c != null) AppLogger.debug('Case_Management', 'updateAuthorizeSignatureFieldSet', null, JSON.serialize(u), null);
        }
    }

    public static Map<String, User> getUserMapByName(List<User> userlist){
        Map<String, User> returnmap = new Map<String, User>();
        if(userlist != null && !userlist.isEmpty()){
            for(User u : userlist){
                returnmap.put(u.Name, u);
            }
        }
        AppLogger.debug('Case_Management', 'getUserMapByName', null, JSON.serialize(userlist), null);
        if(returnmap != null && !returnmap.isEmpty()) return returnmap;
        return null;
    }    

    public static Map<String, User> getUserMapByNameTH(List<User> userlist){
        Map<String, User> returnmap = new Map<String, User>();
        if(userlist != null && !userlist.isEmpty()){
            for(User u : userlist){
                returnmap.put(u.Name_TH__c, u);
            }
        }
        AppLogger.debug('Case_Management', 'getUserMapByNameTH', null, JSON.serialize(userlist), null);
        if(returnmap != null && !returnmap.isEmpty()) return returnmap;
        return null;
    }
}