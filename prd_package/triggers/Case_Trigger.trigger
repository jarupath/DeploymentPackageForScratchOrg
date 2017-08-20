trigger Case_Trigger on Case (after Insert, after update, before Insert, before update) {
    for(Case eachCase : Trigger.new) {
        System.debug('Start OwnerId :' + eachCase.OwnerId);
    }

    public static final String CFMS_SDSR_PROFILE = 'CFMS SD/SR';
    public static final String CGM_QUEUE_NAME = 'Ground_Service_CGM';
    public static final String CASE_CLOSE_QUEUE_NAME = 'Ground_Service_Closed';
    public static final String GS_SDSR_PROFILE = 'Ground Customer Service Not BKK';

    String triggerStatus = Trigger.isBefore == true ? 'Before' : 'After';
    String triggerEvent = Trigger.isInsert == true ? 'Insert' : 'Update';
    Integer noQueriesWhenStart = Limits.getQueries();
    //Case_Management.PrintLimit('6', triggerEvent, triggerStatus);
    System_Configuration__c sysconfig = Case_Management.getSystemConfiguration();
    Map<String, Group> queueMap = Case_TriggerHandler.getQueueMap();

    //Map<String, RecordType> caseRecordTypeMap = BE8_RecordTypeRepository.getInstance().getRecordTypeMapByDevName('Case');
    Map<String, RecordType> caseRecordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
    Id MAINTENANCE_RECORDTYPE = caseRecordTypeMap.get('Maintenance').Id;
    Id NEW_MAINTENANCE_RECORDTYPE = caseRecordTypeMap.get('New_Maintenance').Id;
    Id CFMSVIEW_RECORDTYPE = caseRecordTypeMap.get('Customer_Feedback_View').Id;
    Id GS_RECORDTYPE = caseRecordTypeMap.get('Ground_Service').Id;
    Id CFMS_RECORDTYPE = caseRecordTypeMap.get('Customer_Feedback_Create').Id;
    Id GS_CLOSE_RECORDTYPE = caseRecordTypeMap.get('Ground_Service_Closed').Id;
    Id INFLIGHT_RECORDTYPE = caseRecordTypeMap.get('In_Flight').Id;
    Id CGM_RECORDTYPE = caseRecordTypeMap.get(CGM_QUEUE_NAME).Id;
    Id CASE_CLOSE_RECORDTYPE = caseRecordTypeMap.get(CASE_CLOSE_QUEUE_NAME).Id;
    Case_TriggerHandler handler = null;

    if (TriggerActivator.isTriggerActivated(TriggerActivator.CASE_TRIGGER)) {
        handler = Case_TriggerHandler.getInstanceWithSetup(Trigger.isInsert, Trigger.isUpdate, Trigger.isDelete, Trigger.oldMap);

        if(Trigger.isAfter) {
            System.debug('SJ After ' + Trigger.new);
            Set<Id> aircraftIdSet = new Set<Id>();
            for (Case newCase : Trigger.new) {
                if(newCase.RecordTypeId == MAINTENANCE_RECORDTYPE) {
                    if (handler.isChangeNumberOfImpact(newCase)) {
                        aircraftIdSet.add(newCase.A_C_REG_ID__c);
                    }    
                }

                
            }
            System.debug('SJ isChangeNumberOfImpact : aircraftIdSet: ' + aircraftIdSet);
            handler.setupAircraft(aircraftIdSet);
            handler.sumNumberOfImpactToAircraft();
            handler.updateAircraft();
        }
    }

    List<Case> listcase = new List<Case>();
    List<Case> listcasefordefaultvalue = new List<Case>();
    List<Case> listroundrobincase = new List<Case>();
    List<Case> listapprovalcase = new List<Case>();
    List<Case> listfindemailbodycase = new List<Case>();
    List<Case> listemailcase = new List<Case>();
    Set<Id> setMaintenanceCase = new Set<Id>();
    Set<id> setpassengerid = new Set<id>();
    Set<Id> setcaseid = new Set<id>();
    Set<Id> setcaseapprovalid = new Set<id>();
    Set<Id> setletterid = new Set<id>();
    Case_Management caseManagement = new Case_Management();
    String Status_Acknowledge = 'Acknowledge';
    String Status_Approved = 'Approved';
    String Status_Rejected = 'Rejected';
    String Status_Pending = 'Pending';
    String Status_Resolved = 'Resolved';
    String Status_Closed = 'Closed';
    String Compensation_Tools_UpgradeSeat = 'Upgrade Seat';
    String Compensation_Tools_DutyFree = 'Duty Free';
    String WebChannel = 'TGWebsite';
    Set<Id> caseCloseIdSet = new Set<Id>();
    Map<Id, User> roleMap = new Map<Id, User>();
    List<Case_Group_Member__c> cgmListToBeUpsert = new List<Case_Group_Member__c>();
    List<Task> taskList = new List<Task>();
    Map<String, Flight__c> flightMapByName = new Map<String, Flight__c>();
    Map<String, List<Flight__c>> flightMapListByName = new Map<String, List<Flight__c>>(); 
    Map<Id, String> previousFlightNameMap = null;
    Map<Id, String> expectedFlightNameMap = null;
    List<Case> caseToBeUpdateList = new List<Case>();
    
    if (TriggerActivator.isTriggerActivated(TriggerActivator.CASE_TRIGGER)) {
        List<Id> idComponent = new List<Id>();
        Set<Id> flightIdSet = new Set<Id>();
        Set<Id> aircraftIdSet = new Set<Id>();
        Set<Id> paxIdSet = new Set<Id>();
        //Set<Id> caseIdSet = new Set<Id>();

        for (Case newCase : Trigger.new) {
            if (newCase.EquipmentId__c != null) {
                idComponent.add(newCase.EquipmentId__c);
            }

            if (newCase.PartId__c != null) {
                idComponent.add(newCase.PartId__c);
            }

            if (newCase.Flightid__c != null) {
                flightIdSet.add(newCase.Flightid__c);
            }

            if (newCase.A_C_REG_ID__c != null) {
                aircraftIdSet.add(newCase.A_C_REG_ID__c);
            }

            if (newCase.Passengerid__c != null) {
                paxIdSet.add(newCase.Passengerid__c);
            }
        }

        Map<Id, Master_Map__c> masterMapMap = new Map<Id, Master_Map__c>();
        Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>();
        Map<Id, Aircraft__c> aircraftMap = new Map<Id, Aircraft__c>();
        Map<Id, Passenger__c> paxMap = null;
        Map<Id, Profile> profileMap = null;
        Map<Id, Compensation__c> compenMap = null;

        if (Trigger.isBefore) {
            //roleMap = new Map<Id, User>([SELECT Id, Name, UserRole.Name FROM User]);
            profileMap = Case_TriggerHandler.getProfileMap();
            System.debug('JK: profileMap - ' + JSON.serialize(profileMap));
            compenMap = Case_TriggerHandler.getCompensationMap(BE8_GlobalUtility.getIdSet('Id', Trigger.new));
            roleMap = handler.getRoleMap();
            Set<String> previousFlightNameSet = Case_Management.getPreviousFlightNumberSetFromCase(Trigger.new);
            Set<String> expectedFlightNameSet = Case_Management.getExpectedFlightNumberSetFromCase(Trigger.new);
            previousFlightNameMap = Case_Management.getPreviousFlightNumberMapFromCase(Trigger.new);
            expectedFlightNameMap = Case_Management.getExpectedFlightNumberMapFromCase(Trigger.new);

            Set<String> flightNameSet = new Set<String>();
            System.debug('JK: previousFlightNameSet - ' + JSON.serialize(previousFlightNameSet));
            System.debug('JK: expectedFlightNameSet - ' + JSON.serialize(expectedFlightNameSet));
            flightNameSet.addAll(previousFlightNameSet);
            flightNameSet.addAll(expectedFlightNameSet);
            System.debug('JK: flightNameSet - ' + JSON.serialize(flightNameSet));
            flightMap = flightNameSet.size() > 0 ? handler.getFlightMap(flightIdSet, flightNameSet) : handler.getFlightMap(flightIdSet);
            System.debug('JK: Flight Map - ' + JSON.serialize(flightMap));
            if (flightNameSet.size() > 0) {
                for (Flight__c flight : flightMap.values()) {
                    if (flight.Leg_Number__c == 1) {
                        flightMapByName.put(flight.Name, flight);
                    }
                    if(flightMapListByName.containsKey(flight.Name)){
                        flightMapListByName.get(flight.Name).add(flight);
                    }
                    else{
                        flightMapListByName.put(flight.Name, new List<Flight__c>{flight});
                    }
                }
            }
            System.debug('JK: Flight Map By Name');
            System.debug(JSON.serialize(flightMapByName));
            if (Trigger.isInsert) {
                masterMapMap = Case_Management.getMasterMapMap(idComponent);
                aircraftMap = new Map<Id, Aircraft__c> ([SELECT Id, Aircraft_Registration__c FROM Aircraft__c WHERE Id IN :aircraftIdSet]);
                if (!paxIdSet.isEmpty() && paxIdSet.size() > 0) {
                    paxMap = handler.getPaxList(paxIdSet);
                }
                //profileMap = Case_TriggerHandler.getProfileMap();
            }

        }

        if (Trigger.isAfter) {
            flightMap = handler.getFlightMap(flightIdSet);
            if (!paxIdSet.isEmpty() && paxIdSet.size() > 0) {
                paxMap = handler.getPaxList(paxIdSet);
            }
        }

        //Case_Management.PrintLimit('82', triggerEvent, triggerStatus);
        for (Case thisca : Trigger.new) {
            System.debug('JK: inputCase - ' + JSON.serialize(thisca));
            if (Trigger.Isinsert) {
                System.debug('Case Is insert :');

                if (Trigger.Isafter) {
                    // After insert
                    //System.debug('JK: Case Id: ' + thisca.Id);
                    //System.debug('JK: Case Action: ' + thisca.Action__c);
                    //System.debug('JK: Case Status: ' + thisca.Status);
                    //System.debug('JK: Case RecordType: ' + thisca.RecordTypeId);
                    //System.debug('JK: Maintenance RecordType: ' + MAINTENANCE_RECORDTYPE);
                    if (thisca.RecordTypeId == MAINTENANCE_RECORDTYPE && (thisca.Status == 'Closed' || thisca.Action__c == 'Completed')) {
                        caseCloseIdSet.add(thisca.Id);
                    }

                    /**

                        This session code is used to replace Case process builder

                    */

                    if (thisca.RecordTypeId == CFMSVIEW_RECORDTYPE || thisca.RecordTypeId == CFMS_RECORDTYPE) {
                        Boolean isTGXXX = flightMap.get(thisca.Flightid__c).Name == 'TGXXX' ? true : false;
                        if (thisca.Expected_Flight_Date__c != null && isTGXXX) {
                            taskList.add(Case_Management.AutomaticNewTaskonCaseforFutureFlight(thisca, sysconfig));
                        }
                    }

                    if (thisca.Origin != 'In-flight' && thisca.RecordTypeId != INFLIGHT_RECORDTYPE && thisca.RecordTypeId != NEW_MAINTENANCE_RECORDTYPE && thisca.RecordTypeId != MAINTENANCE_RECORDTYPE) {
                        if (thisca.Passengerid__c != null) {
                            cgmListToBeUpsert.add(Case_Management.CreateCGMonCaseCreation(thisca, paxMap.get(thisca.Passengerid__c), CGM_RECORDTYPE));
                        }
                    }

                    /**
                        end process builder session
                    */


                } else {
                    Boolean isOwnerChanged = false;
                    Case_Management.updateCaseFromWebMaster(thisca, sysconfig);
                    Case_Management.updateAuthorizeSignatureFieldSet(thisca);
                    /**

                        This session code is used to replace Case process builder

                    */
                    System.debug('JK: Profile Info: ' + profileMap.get(UserInfo.getProfileId()).Name);
                    if (thisca.RecordTypeId == GS_RECORDTYPE || thisca.RecordTypeId == CFMSVIEW_RECORDTYPE || thisca.RecordTypeId == CFMS_RECORDTYPE) {
                        if (thisca.Previous_Flight_Number__c != null && thisca.Previous_Flight_Number__c != '') {
                            if (thisca.Previous_Flight_Date__c != null) {
                                if (previousFlightNameMap != null && flightMapByName != null && flightMapByName.containsKey(Case_Management.getFlightNameFormat(thisca.Previous_Flight_Number__c, thisca.Previous_Flight_Date__c))) {
                                    thisca.Previous_Flight__c = flightMapByName.get(Case_Management.getFlightNameFormat(thisca.Previous_Flight_Number__c, thisca.Previous_Flight_Date__c)).Id;
                                } else {
                                    thisca.Previous_Flight_Number__c.addError('Flight not found.');
                                    thisca.Previous_Flight_Date__c.addError('Flight not found.');
                                }
                                Case_Management.AutomaticFlightNumberonCase(thisca, thisca.Previous_Flight_Date__c);
                            } else {
                                Case_Management.AutomaticFlightNumberonCase(thisca, Date.valueOf(flightMap.get(thisca.Flightid__c).Flight_Date_LT__c));
                            }
                        } else if ((thisca.Previous_Flight_Number__c == '' || thisca.Previous_Flight_Number__c == null) && thisca.Previous_Flight_txt__c != null) {
                            thisca.Previous_Flight_txt__c = null;
                            thisca.Previous_Flight_Number__c = null;
                            thisca.Previous_Flight_Date__c = null;
                            thisca.Previous_Flight__c = null;
                        }
                        System.debug('JK: Flight Map: ' + JSON.serialize(flightMap));
                        Case_Management.updateExpectedFlightOnCaseInsert(thisca, flightMap, flightMapListByName);
                    }

                    if (thisca.RecordTypeId == GS_CLOSE_RECORDTYPE && thisca.Status == 'Closed') {
                        Case_Management.ChangeCaseRecordTypeWhenStatusisClosed(thisca, CASE_CLOSE_RECORDTYPE);
                    }

                    if (thisca.RecordTypeId == MAINTENANCE_RECORDTYPE && thisca.SEQ_No_txt__c != null && thisca.SEQ_No_txt__c != '') {
                        Case_Management.CreateSEQNo(thisca, aircraftMap.get(thisca.A_C_REG_ID__c));
                    }

                    System.debug('JK: Profile Info: ' + UserInfo.getProfileId());
                    if (profileMap.containsKey(UserInfo.getProfileId())) {
                        if (profileMap.get(UserInfo.getProfileId()).Name != CFMS_SDSR_PROFILE && profileMap.get(UserInfo.getProfileId()).Name != GS_SDSR_PROFILE) {
                            //Escalate Case When Created
                            System.debug('JK: Case Before owner changed: ' + JSON.serialize(thisca));
                            if(thisca.RecordTypeId == INFLIGHT_RECORDTYPE && thisca.Status == Status_Resolved){
                                System.debug('compen jk: Case with compensation from in-flight');
                                System.debug('compen jk: case before remove upgrade seat and duty free - ' + thisca.Compensation_Tool__c);
                                String compensationtools = null;
                                if(thisca.Compensation_Tool__c != null && thisca.Compensation_Tool__c != ''){
                                    compensationtools = thisca.Compensation_Tool__c.replaceAll(',', '');
                                    compensationtools = compensationtools.replaceAll(Compensation_Tools_UpgradeSeat, '');
                                    compensationtools = compensationtools.replaceAll(Compensation_Tools_DutyFree, '');
                                }
                                System.debug('compen jk: case after remove upgrade seat and duty free - ' + compensationtools);
                                if(compensationtools != null && compensationtools != ''){
                                    Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S3 Tier 1', CFMSVIEW_RECORDTYPE);
                                    isOwnerChanged = true;
                                }
                                else {
                                    thisca.Status = Status_Closed;
                                    thisca.RecordTypeId = CFMSVIEW_RECORDTYPE;
                                }
                                System.debug('compen jk: case after escalate - ' + JSON.serialize(thisca));
                            }
                            
                            else if (thisca.Status == 'Resolved' && thisca.PassengerId__c != null && Case_Management.isCaseShouldEscalateToS3()) {
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S3 Tier 1', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }

                            else if ((thisca.Priority == 'Urgent' || thisca.Case_Type__c == 'Information') && thisca.RecordTypeId == INFLIGHT_RECORDTYPE && thisca.PassengerId__c != null) {
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S4 Level 8 IF', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }

                            else if(thisca.RecordTypeId == INFLIGHT_RECORDTYPE && thisca.Passengerid__c == null && thisca.SEQ_No_Display__c == null){
                                thisca.Status = Status_Closed;
                                thisca.RecordTypeId = CFMSVIEW_RECORDTYPE;
                            }

                            else if (thisca.Origin == 'In-Flight' && thisca.PassengerId__c != null && (thisca.ROP_Tier__c == 'PLAT' || thisca.ROP_Tier_F__c == 'PLAT' || thisca.Accepted_Class__c == 'F')) {
                                System.debug('JK: FP IF');
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S4 FP IF', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }

                            else if (thisca.RecordTypeId == GS_RECORDTYPE && thisca.Status == 'Escalated'  && thisca.Case_Type__c == 'Complaint' && (thisca.FFP_Tier__c != 'PLAT' || thisca.Accepted_Class__c != 'First')) {
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S4 Tier 2', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }

                            else if (thisca.RecordTypeId == INFLIGHT_RECORDTYPE && thisca.PassengerId__c != null && thisca.Status == 'Escalated') {
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'S4 Tier 1', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }
                            else if (thisca.Origin == 'TGWebsite' && thisca.SuppliedEmail != null) {
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'TGWebMaster', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }
                            else if(thisca.Origin == 'Email' && thisca.SuppliedEmail != null){
                                Case_Management.EscalationTierwhenCaseCreated(thisca, queueMap, 'Email', CFMSVIEW_RECORDTYPE);
                                isOwnerChanged = true;
                            }
                        } else {
                            if (thisca.RecordTypeId == GS_RECORDTYPE) {
                                System.debug('JK: escalate to AB ST');
                                Case_Management.EscalateCaseFlowForAbroadStation(thisca, roleMap, compenMap, caseRecordTypeMap);
                            }
                        }
                    }

                    //End Escalate Case When Created
                    /**
                        end process builder session
                    */

                    //thisca.Subject = !String.isEmpty(thisca.Subject) && !String.isEmpty(thisca.Case_Type__c) ? thisca.Subject + ' - ' + thisca.Case_Type__c : null;
                    if((thisca.recordTypeId == MAINTENANCE_RECORDTYPE || thisca.recordTypeId == NEW_MAINTENANCE_RECORDTYPE) && !String.isEmpty(thisca.Subject) && !String.isEmpty(thisca.Case_Type__c)){
                        thisca.Subject = null;
                    }
                    else{
                        if(thisca.Subject == null){
                            thisca.Subject = '';
                        }
                        thisca.Subject = thisca.Case_Type__c != null ? thisca.Subject + ' - ' + thisca.Case_Type__c : thisca.Subject;
                    }
                    
                    if (thisca.recordtypeid != MAINTENANCE_RECORDTYPE && thisca.recordtypeid != NEW_MAINTENANCE_RECORDTYPE) {
                        if (thisca.First_Handle_by__c == null && thisca.SuppliedEmail == null) {
                            thisca.First_Handle_by__c = userinfo.getname();
                            thisca.First_Handle_Time__c = system.now();
                            thisca.Acknowledge_on_24_hrs__c = 1;
                            caseManagement.Platinum_or_Firstclass(thisca);
                        }
                        if(thisca.SuppliedEmail != null) thisca.Acknowledge_on_24_hrs__c = 1;
                        System.debug('JK - before insert');
                        Case_Management.updateCaseOnWaitingforResponseStatus(thisca, roleMap);
                        thisca.Case_Owner_Changed_Time__c = Datetime.now();
                        Case_Management.updateCaseOnCaseClosed(thisca, roleMap);
                        Case_Management.updateCaseToS4T1GB(thisca, roleMap);
                        System.debug(JSON.serialize(thisca));
                        if (isOwnerChanged) {
                            listroundrobincase.add(thisca);
                        }
                        System.debug('JK: Status Changed: ' + isOwnerChanged);
                        System.debug('listroundrobin: ' + listroundrobincase);

                        if (thisca.Letter_Bodyid__c != null) {
                            listfindemailbodycase.add(thisca);
                            setletterid.add(thisca.Letter_Bodyid__c);
                        }

                        listcasefordefaultvalue.add(thisca);
                        setpassengerid.add(thisca.passengerid__c);
                    }

                    if (thisca.recordTypeId == MAINTENANCE_RECORDTYPE || thisca.recordTypeId == NEW_MAINTENANCE_RECORDTYPE) {

                        String strComponent = '';

                        if (masterMapMap != null && thisca.EquipmentId__c != null && masterMapMap.containsKey(thisca.EquipmentId__c)) {
                            strComponent += masterMapMap.get(thisca.EquipmentId__c).Name + ' ';
                        }

                        if (masterMapMap != null && thisca.PartId__c != null && masterMapMap.containsKey(thisca.PartId__c)) {
                            strComponent += masterMapMap.get(thisca.PartId__c).Name + ' ';
                        }

                        //thisca.Complaint_TXT_40__c = strComponent + thisca.Description;
                        //thisca.Complaint_TXT_40__c = thisca.Description != null ? strComponent + thisca.Description : strComponent;
                        if(thisca.Description != null){
                            Integer strlen = thisca.Description.length() + strComponent.length();
                            thisca.Complaint_TXT_40__c = strlen <= 255 ? strComponent + thisca.Description : (strComponent + thisca.Description).substring(0, 250) + '...';
                        }
                        else{
                            thisca.Complaint_TXT_40__c = strComponent.length() <= 255 ? strComponent : strComponent.substring(0, 250) + '...';
                        }
                        //thisca.Subject = thisca.Complaint_TXT_40__c;
                        if(thisca.Subject == null){
                            thisca.Subject = thisca.Complaint_TXT_40__c.length() <= 100 ? thisca.Complaint_TXT_40__c : thisca.Complaint_TXT_40__c.substring(0, 101) + '...';
                        }
                        // rkessom moved from above
                        if (thisca.Flightid__c != null) {
                            thisca.DEP_STN__c = flightMap.containsKey(thisca.Flightid__c) ? flightMap.get(thisca.Flightid__c).Departure_STN__c : null;
                            thisca.A_C_Reg_Search__c = flightMap.containsKey(thisca.Flightid__c) ? flightMap.get(thisca.Flightid__c).AircraftId__r.Aircraft_Registration__c : null;
                        } else if (thisca.A_C_REG_ID__c != null) {
                            thisca.A_C_Reg_Search__c = aircraftMap.containsKey(thisca.A_C_REG_ID__c) ? aircraftMap.get(thisca.A_C_REG_ID__c).Aircraft_Registration__c : null;
                        }

                    }

                    if (thisca.origin == WebChannel) {
                        thisca.recordtypeid = CFMSVIEW_RECORDTYPE;
                    }
                    
                    //22-3-2017 Defualt TGXXX for email case
                    if(thisca.SuppliedEmail != null) {
                        listemailcase.add(thisca);
                    }

                    /* Lack of part and Lack of  time values */
                    Case_Management.updateReportLackofPartandLackofTime(thisca);
                    Case_Management.updateLackofPartandLackofTimeWhenCaseComplete(thisca);
                    
                    listcase.add(thisca);
                    setcaseid.add(thisca.id);
                }
            }
            // Is update
            else {
                Case oldca = trigger.oldmap.get(thisca.Id);

                if (Trigger.Isafter) {
                    if (thisca.RecordTypeId == MAINTENANCE_RECORDTYPE && (thisca.Status == 'Closed' || thisca.Action__c == 'Completed')) {
                        caseCloseIdSet.add(thisca.Id);
                    }

                    if (thisca.recordtypeid != MAINTENANCE_RECORDTYPE && thisca.recordtypeid != NEW_MAINTENANCE_RECORDTYPE) {
                        if ((thisca.approval_status__c != oldca.approval_status__c) &&
                                (thisca.approval_status__c == Status_Approved ||
                                 thisca.approval_status__c == Status_Rejected ||
                                 thisca.approval_status__c == Status_Pending)) {
                            listapprovalcase.add(thisca);
                            setcaseapprovalid.add(thisca.id);
                        }
                    }

                    if ((thisca.recordtypeid != MAINTENANCE_RECORDTYPE && thisca.recordtypeid != NEW_MAINTENANCE_RECORDTYPE)) {
                        System.debug('JK - After update');
                        //Case_Management.updateCaseToS4T1GB(thisca, roleMap);
                        System.debug(JSON.serialize(thisca));
                    }

                    // After update, update cabin log, when its recordtype = 'Maintenance' and Action is not [Remail or Complete]
                    // and these specific fields below are changed
                    if (thisca.recordTypeId == MAINTENANCE_RECORDTYPE
                            && (thisca.Action__c != 'Remain' && thisca.Action__c != 'Completed')) {

                        //if (oldca.Aircraft_Registration_F__c != thisca.Aircraft_Registration_F__c
                        //        || oldca.DEP_STN__c != thisca.DEP_STN__c
                        //        || oldca.Status != thisca.Status
                        //        || oldca.SEQ_No_txt__c != thisca.SEQ_No_txt__c
                        //        || oldca.ATA_Chapter_2_F__c != thisca.ATA_Chapter_2_F__c
                        //        || oldca.Description != thisca.Description
                        //        || oldca.Position_Case_Group_Member__c != thisca.Position_Case_Group_Member__c
                        //        || oldca.Block_Name__c != thisca.Block_Name__c
                        //        || oldca.Authorize_Number__c != thisca.Authorize_Number__c) {
                        if (Trigger.isUpdate) {

                            System.debug('CASE ID :' + thisca.Id);

                            setMaintenanceCase.add(thisca.Id);
                        }
                    }
                    if (thisca.Origin != 'In-flight' && thisca.RecordTypeId != INFLIGHT_RECORDTYPE && thisca.RecordTypeId != NEW_MAINTENANCE_RECORDTYPE && thisca.RecordTypeId != MAINTENANCE_RECORDTYPE) {
                        if (thisca.Passengerid__c != null && oldca != null) {
                            Case_Group_Member__c cgmToBeUpsert = Case_Management.CreateCGMOnCaseUpdate(thisca, oldca, paxMap.get(thisca.Passengerid__c), CGM_RECORDTYPE);
                            if(cgmToBeUpsert != null){
                                cgmListToBeUpsert.add(cgmToBeUpsert);
                            }
                        }
                    }

                    /* clear Update_Passenger_By_Code__c flag */
                    if(thisca.Update_Passenger_By_Code__c == true){
                        Case caseTobeUpdate = new Case();
                        caseTobeUpdate.Id = thisca.Id;
                        caseTobeUpdate.Update_Passenger_By_Code__c = false;
                        caseToBeUpdateList.add(caseTobeUpdate);
                    }

                } else {
                    System.debug('JK: Profile info - ' + profileMap.get(UserInfo.getProfileId()).Name);
                    System.debug('JK: DEBUG Escalated');
                    System.debug(JSON.serialize(thisca));
                    Case oldCase = Trigger.oldMap.get(thisca.Id);
                    System.debug('JK: DEBUG old Case');
                    System.debug(JSON.serialize(oldCase));
                    Case_Management.updateAuthorizeSignatureFieldSet(thisca);

                    //If Case Status is changed to Closed, then Action should be changed to Completed. If Case Action is Complete, then Case Status should be Closed.
                    if(thisca.RecordTypeId == MAINTENANCE_RECORDTYPE && (thisca.Action__c == 'Completed' || thisca.Status == 'Closed')){
                        thisca.Action__c = 'Completed';
                        thisca.Status = 'Closed';
                    }

                    /**

                        This session code is used to replace Case process builder

                    */
                    if (thisca.RecordTypeId == GS_RECORDTYPE || thisca.RecordTypeId == CFMSVIEW_RECORDTYPE || thisca.RecordTypeId == CFMS_RECORDTYPE) {
                        if (thisca.Previous_Flight_Number__c != null) {
                            if (thisca.Previous_Flight_Date__c != null) {
                                if (previousFlightNameMap != null && flightMapByName != null && previousFlightNameMap.containsKey(thisca.Id) && flightMapByName.containsKey(previousFlightNameMap.get(thisca.Id))) {
                                    thisca.Previous_Flight__c = flightMapByName.get(previousFlightNameMap.get(thisca.Id)).Id;
                                } else {
                                    thisca.Previous_Flight_Number__c.addError('Flight not found.');
                                    thisca.Previous_Flight_Date__c.addError('Flight not found.');
                                }
                                Case_Management.AutomaticFlightNumberonCase(thisca, thisca.Previous_Flight_Date__c);
                            } else {
                                Case_Management.AutomaticFlightNumberonCase(thisca, Date.valueOf(flightMap.get(thisca.Flightid__c).Flight_Date_LT__c));
                            }
                        } else if ((thisca.Previous_Flight_Number__c == '' || thisca.Previous_Flight_Number__c == null) && thisca.Previous_Flight_txt__c != null) {
                            thisca.Previous_Flight_txt__c = null;
                            thisca.Previous_Flight_Number__c = null;
                            thisca.Previous_Flight_Date__c = null;
                            thisca.Previous_Flight__c = null;
                        }
                        System.debug('JK: Flight Map: ' + JSON.serialize(flightMap));
                        Boolean isValidate = true;
                        String flightName = thisca.Expected_Flight_Number__c != null && thisca.Expected_Flight_Date__c != null ? Case_Management.getFlightNameFormat(thisca.Expected_Flight_Number__c, thisca.Expected_Flight_Date__c) : null;
                        if(flightName != null){
                            System.debug('JK: Flight Name - ' + flightName);
                            System.debug('JK: FlightId__c - ' + thisca.FlightId__c);
                            System.debug('JK: Expected Flight Id - ' + JSON.serialize(flightMapListByName));
                            if(flightMapListByName.containsKey(flightName)){
                                Boolean isFlightInList = false;
                                for(Flight__c f : flightMapListByName.get(flightName)){
                                    if(thisca.FlightId__c == f.Id){
                                        isFlightInList = true;
                                        break;
                                    }
                                }
                                isValidate = isFlightInList == true ? false : true;
                            }
                        }
                        if(isValidate == true){
                            Task t = Case_Management.updateExpectedFlightOnCaseUpdate(thisca, flightMap, flightMapListByName, Trigger.oldMap.get(thisca.Id), sysconfig, Trigger.new);
                            if(t != null){
                                taskList.add(t);
                            }
                        }
                    }

                    if (thisca.RecordTypeId == GS_RECORDTYPE && thisca.Status == 'Closed') {
                        Case_Management.ChangeCaseRecordTypeWhenStatusisClosed(thisca, CASE_CLOSE_RECORDTYPE);
                    }
                    System.debug('JK: Profile info - ' + profileMap.get(UserInfo.getProfileId()).Name);
                    if (profileMap.containsKey(UserInfo.getProfileId())) {
                        System.debug('JK: DEBUG CASE' + JSON.serialize(thisca));
                        if (profileMap.get(UserInfo.getProfileId()).Name != CFMS_SDSR_PROFILE && profileMap.get(UserInfo.getProfileId()).Name != GS_SDSR_PROFILE) {
                            //Escalation Tier when change status to Escalated
                            if (thisca.Status != oldca.Status && thisca.Status == 'Resolved' && thisca.Passengerid__c != null && !thisca.Verified__c && Case_Management.isCaseShouldEscalateToS3()) {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S3 Tier 1', CFMSVIEW_RECORDTYPE);
                            }

                            else if (thisca.Verified__c != oldca.Verified__c && thisca.Verified__c) {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S3 Chief', CFMSVIEW_RECORDTYPE);
                            }

                            else if (thisca.RecordTypeId != INFLIGHT_RECORDTYPE && thisca.RecordTypeId != GS_RECORDTYPE && thisca.Priority == 'Urgent' && (thisca.Case_Type__c == 'Injury' || thisca.Case_Type__c == 'Court Case') && (thisca.Origin == 'Station' || thisca.Origin == 'E-Saraban') && thisca.Passengerid__c != null && thisca.Status == 'Escalated') {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S4 Level 8 CFMS', CFMSVIEW_RECORDTYPE);
                            }

                            else if (thisca.RecordTypeId == GS_RECORDTYPE && thisca.Priority == 'Urgent' && thisca.Passengerid__c != null && thisca.Status == 'Escalated') {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S4 Level 8 Ground', CFMSVIEW_RECORDTYPE);
                            }

                            else if (thisca.Status != oldca.Status && thisca.Status == 'Escalated' && thisca.Origin != 'E-Saraban' && thisca.Origin != 'Station' && thisca.Passengerid__c != null && (thisca.ROP_Tier__c == 'PLAT' || thisca.Accepted_Class__c == 'F')) {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S4 Tier 2 FP', CFMSVIEW_RECORDTYPE);
                            }
                            
                            else if (thisca.Status != oldca.Status && thisca.Status == 'Escalated' && thisca.Case_Type__c == 'Baggage Claim' && thisca.Passengerid__c != null && thisca.ROP_Tier__c != 'PLAT' && thisca.Accepted_Class__c != 'F') {
                                Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'AO Tier 2 BC', CFMSVIEW_RECORDTYPE);
                            }

                            else if (thisca.Status != oldca.Status && thisca.Status == 'Escalated') {
                                if (thisca.Case_Type__c == 'Complaint' || thisca.RecordTypeId == INFLIGHT_RECORDTYPE || thisca.RecordTypeId == GS_RECORDTYPE) {
                                    if (thisca.Passengerid__c != null && thisca.ROP_Tier__c != 'PLAT' && thisca.Accepted_Class__c != 'F') {
                                        Case_Management.EscalationTierwhenchangestatustoEscalated(thisca, queueMap, 'S4 Tier 2', CFMSVIEW_RECORDTYPE);
                                    }
                                }
                            }
                        } else {
                            if (thisca.RecordTypeId == GS_RECORDTYPE) {
                                Case_Management.EscalateCaseFlowForAbroadStation(thisca, roleMap, compenMap, caseRecordTypeMap);
                            }
                        }
                    }
                    //END Escalation Tier when change status to Escalated
                    /**
                        end process builder session
                    */

                    if ((thisca.recordtypeid != MAINTENANCE_RECORDTYPE && thisca.recordtypeid != NEW_MAINTENANCE_RECORDTYPE)) {
                        System.debug('JK - before update');
                        if(thisca.Status != oldca.Status){
                            Case_Management.updateCaseOnCaseClosed(thisca, roleMap);
                            Case_Management.updateCaseOnWaitingforResponseStatus(thisca, roleMap);    
                        }
                        Case_Management.updateCaseOnOwnerChanged(thisca, Trigger.oldMap);
                        Case_Management.updateCaseToS4T1GB(thisca, roleMap, Trigger.oldMap);
                        System.debug(JSON.serialize(thisca));
                        System.debug(JSON.serialize(oldca));
                        if (thisca.ownerid != oldca.ownerid) {
                            listroundrobincase.add(thisca);
                        }

                        if (thisca.status != oldca.status) {
                            setcaseid.add(thisca.id);

                            if (thisca.status == Status_Acknowledge && caseManagement.Acknowleageontime(thisca)) {
                                if (thisca.Acknowledge_on_24_hrs__c != null) {
                                    thisca.Acknowledge_on_24_hrs__c = thisca.Acknowledge_on_24_hrs__c + 1;
                                    caseManagement.Platinum_or_Firstclass(thisca);
                                } else {
                                    thisca.Acknowledge_on_24_hrs__c = 1;
                                    caseManagement.Platinum_or_Firstclass(thisca);
                                }
                            }
                        } else if (thisca.status == Status_Acknowledge && thisca.createdbyid != userinfo.getuserid() && thisca.First_Handle_by__c == null) {
                            if (thisca.origin != WebChannel) {
                                thisca.First_Handle_by__c = userinfo.getname();
                                thisca.First_Handle_Time__c = system.now();
                            }
                        }

                        if ((thisca.Letter_Bodyid__c != oldca.Letter_Bodyid__c) && thisca.Letter_Bodyid__c != null) {
                            listfindemailbodycase.add(thisca);
                            setletterid.add(thisca.Letter_Bodyid__c);
                        }

                        if ((thisca.passengerid__c != oldca.passengerid__c) && thisca.passengerid__c != null) {
                            listcasefordefaultvalue.add(thisca);
                            setpassengerid.add(thisca.passengerid__c);
                        }
                    }

                    /* Lack of part and Lack of  time values */
                    System.debug('JK: Lack BF - ' + thisca.Lack_of_Part__c + ' ' + thisca.Lack_of_Time__c);
                    System.debug('JK: Lack BF REPORT - ' + thisca.Report_Lack_of_Part__c + ' ' + thisca.Report_Lack_of_Time__c);
                    Case_Management.updateReportLackofPartandLackofTime(thisca);
                    System.debug('JK: Lack AF - ' + thisca.Lack_of_Part__c + ' ' + thisca.Lack_of_Time__c);
                    System.debug('JK: Lack AF REPORT - ' + thisca.Report_Lack_of_Part__c + ' ' + thisca.Report_Lack_of_Time__c);
                    Case_Management.updateLackofPartandLackofTimeWhenCaseComplete(thisca);
                    System.debug('JK: Lack COMPLETE - ' + thisca.Lack_of_Part__c + ' ' + thisca.Lack_of_Time__c);
                    System.debug('JK: Lack COMPLETE REPORT - ' + thisca.Report_Lack_of_Part__c + ' ' + thisca.Report_Lack_of_Time__c);
                    listcase.add(thisca);
                }
            }

        }

        //Case_Management.PrintLimit('261', triggerEvent, triggerStatus);

        if (listcasefordefaultvalue.size() > 0) {
            caseManagement.getdefaultvalue(listcasefordefaultvalue, setpassengerid);
        }
        
        if(listemailcase.size() > 0){ //22-3-2017 Defualt TGXXX for email case
            caseManagement.defaultflightforemail(listemailcase);
        }

        if (listcase.size() > 0) {
            //System.debug('JK: Round Robin');
            //System.debug('before round robin: ' + JSON.serialize(listroundrobincase));
            Round_Robin_Controller.roundrobin_method(listroundrobincase);
            Case_Management.updateCaseOnEscalatedStatus(listroundrobincase, roleMap, Trigger.oldMap);
            //System.debug('after round robin: ' + JSON.serialize(listroundrobincase));
        }

        if (listcase.size() > 0 && setcaseid.size() > 0) {
            caseManagement.StampActionTrail(listcase, setcaseid, Trigger.oldMap);
        }

        if (listapprovalcase.size() > 0 && setcaseapprovalid.size() > 0) {
            caseManagement.Changecompensationapproval(listapprovalcase, setcaseapprovalid);
        }

        if (listfindemailbodycase.size() > 0 && setletterid.size() > 0) {
            caseManagement.findletterbody(listfindemailbodycase, setletterid);
        }

        //System.debug('Maintenance case size :' + setMaintenanceCase.size());
        if (setMaintenanceCase.size() > 0) {
            //CSE_SOAPCABINLOG_WS.createCabinLogFromCaseListWithFuture(setMaintenanceCase);
        }

        if (caseCloseIdSet != null && !caseCloseIdSet.isEmpty()) {
            //System.debug('JK: caseCloseIdSet: ' + caseCloseIdSet);
            List<Case_Group_Member__c> cgmList = [SELECT Id, Impact__c FROM Case_Group_Member__c WHERE Caseid__c IN :caseCloseIdSet];
            //System.debug('JK: cgmList: ' + cgmList);
            Case_Management.setCaseGroupMemberStatusToCompleted(cgmList);
            cgmListToBeUpsert.addAll(cgmList);
            //update cgmList;
        }

        if (!cgmListToBeUpsert.isEmpty() && cgmListToBeUpsert.size() > 0) {
            Database.UpsertResult[] result = Database.upsert(cgmListToBeUpsert, false);
            //System.debug('Auto Create Case Group Result: ' + JSON.serialize(result));
        }

        if (!taskList.isEmpty() && taskList.size() > 0) {
            Database.UpsertResult[] result = Database.upsert(taskList, false);
            //System.debug('Auto Create Task List Result: ' + JSON.serialize(result));
        }

        if(!caseToBeUpdateList.isEmpty()){
            update caseToBeUpdateList;
        }

        if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
            for(Case eachCase : Trigger.new) {
                if(eachCase.Origin == 'Email') {
                    if(String.isNotBlank(eachCase.Subject)) {
                        eachCase.Email_To_Case_Key__c = eachCase.Subject.replaceAll(' ', '').toLowerCase();
                    } 
                }
            }
        }
    }
    //Case_Management.PrintLimit('297', triggerEvent, triggerStatus);
    //AppLogger.insertLogs();
    Integer noQueriesWhenFinish = Limits.getQueries();
    String noQueriesDebug = 'noQueriesDebug : Case_Trigger';
    if (Trigger.isBefore)        noQueriesDebug += 'BEFORE ';
    else if (Trigger.isAfter)    noQueriesDebug += 'AFTER ';

    if (Trigger.isInsert)        noQueriesDebug += 'INSERT ';
    else if (Trigger.isUpdate)   noQueriesDebug += 'UPDATE ';
    else if (Trigger.isDelete)   noQueriesDebug += 'DELETE ';
    Integer noUsageQueries = noQueriesWhenFinish - noQueriesWhenStart;
    //noQueriesDebug += noUsageQueries;
    System.debug(noQueriesDebug + '[' + noUsageQueries + ']' + '-' + Limits.getQueries());


    for(Case eachCase : Trigger.new) {
        System.debug('End OwnerId :' + eachCase.OwnerId);
    }
}