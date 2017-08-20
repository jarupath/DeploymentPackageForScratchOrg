public without sharing class Emailmsg_Controller {
    
    public static String WAITINGINV = 'Waiting for Investigation';
    public static String WAITINGCUS = 'Waiting for Response';
    public static String INVESTIGATED = 'Investigated';
    public static String ACKNOWLEDGE = 'Acknowledge';
    public static String CUSTOMERRESPONSE = 'Customer Response';
    public static String TGWEBSITE = 'TGWebsite';
    public static String EMAIL = 'Email';
    public static String SNEW = '0';
    public static String SENT = '3';
    public static Id GROUNDSERVICE = BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', 'Ground_Service');

    public static void changecasestatus(list<EmailMessage> listemailmsg , set<id> setcaseid){
        Set<Id> emailIdSet = BE8_GlobalUtility.getIdSet('Id', listemailmsg);
        list<Case> listupdatecase = new list<Case>();
        map<id,Case> maplistcase = getmapcaselist(setcaseid);
        Map<Id, List<EmailMessage>> emailListMap = getEmailListMapByCaseId(setcaseid);
        Case_TriggerHandler handler = new Case_TriggerHandler();
        Map<String, List<SObject>> emailMapByCaseId = BE8_GlobalUtility.getSObjectListMap('RelatedToId', [SELECT Id, Incoming, RelatedToId FROM EmailMessage WHERE RelatedToId IN :setcaseid AND Id NOT IN :emailIdSet AND Incoming = false]);
        system.debug('map list case :: ' + maplistcase.size());
        
        if(maplistcase.size() > 0){
            for(EmailMessage thisemailmsg : listemailmsg ){
                Boolean isAutoResponseEmail = thisemailmsg.Headers != null && thisemailmsg.Headers.contains('SFDC-AutoResponse');
                if(maplistcase.Containskey(thisemailmsg.relatedtoid) && !isAutoResponseEmail){
                    Case thisupdatecase = maplistcase.get(thisemailmsg.relatedtoid);
                    Boolean isEmailToCase = (emailListMap.isEmpty() || !emailListMap.containsKey(thisupdatecase.Id) || (emailListMap.get(thisupdatecase.Id).size() == 1 && maplistcase.get(thisupdatecase.Id).Status != 'Duplicate')) && thisupdatecase.SuppliedEmail != null;
                    if(thisupdatecase.recordtypeid != GROUNDSERVICE){
                        if(thisemailmsg.status == SNEW && !isEmailToCase){
                            if(thisemailmsg.Internal__c){
                                thisupdatecase.status = INVESTIGATED;
                                /*this code is move from case management - StampActionTrail*/
                                thisupdatecase.Investigated_by__c = thisemailmsg.FromName;
                                thisupdatecase.Investigated_Time__c = System.now();
                                listupdatecase.add(thisupdatecase);
                            }
                            else{
                                if(thisupdatecase.Status == ACKNOWLEDGE){
                                    thisupdatecase.Follow_up__c = true;
                                    listupdatecase.add(thisupdatecase);
                                }
                                else {
                                    thisupdatecase.status = CUSTOMERRESPONSE;
                                    thisupdatecase.Follow_up__c = false;
                                    listupdatecase.add(thisupdatecase);
                                }
                            } 
                        }
                        else if(thisemailmsg.status == SENT){
                            if(thisemailmsg.To_Internal__c){
                                thisupdatecase.status = WAITINGINV;
                                listupdatecase.add(thisupdatecase);
                            }
                            else{
                                thisupdatecase.status = WAITINGCUS ;
                                listupdatecase.add(thisupdatecase);
                            }                       
                        }
                    }
                }
            }
            
            if(listupdatecase.size() > 0){
                update listupdatecase;
            }
        }
    }
    
    public static void setdefaultbccaddress(list<EmailMessage> listemailmsg){
        String ccaddress = System_Configuration__c.getInstance().Email_Services_Address__c;
        
        for(EmailMessage emsg : listemailmsg){
            emsg.ccaddress = ccaddress;
        }
    }
    
    private static map<id,Case> getmapcaselist(set<id> setcaseid){
        map<id,Case> mapresult = new map<id,Case>();
        list<Case> listcase = [Select id,status,origin,recordtypeid, SuppliedEmail, Follow_up__c from Case where Id  IN: setcaseid];
        
        if(listcase.size() > 0){
            for(Case thiscase : listcase){
                mapresult.put(thiscase.id,thiscase);
            }
        }
        
        return mapresult;
    }

    private static Map<Id, List<EmailMessage>> getEmailListMapByCaseId(Set<Id> caseIdSet){
        Map<Id, List<EmailMessage>> returnListMap = new Map<Id, List<EmailMessage>>();
        List<EmailMessage> emailList = [SELECT Id, RelatedToId FROM EmailMessage WHERE RelatedToId IN :caseIdSet AND Incoming = true];
        if(emailList != null && !emailList.isEmpty()){
            for(EmailMessage eachEmail : emailList){
                if(returnListMap.containsKey(eachEmail.RelatedToId)){
                    returnListMap.get(eachEmail.RelatedToId).add(eachEmail);
                }
                else{
                    returnListMap.put(eachEmail.RelatedToId, new List<EmailMessage>{eachEmail});
                }
            }
        }
        return returnListMap;
    }
    
    /* not being used anymore @rkessom
    private static map<id,list<emailMessage>> getmapemailmsglist(set<id> setcaseid){
        
        map<id,list<emailMessage>> mapemailmsg = new map<id,list<emailMessage>>();
        list<EmailMessage> listemsg = new list<EmailMessage>();
        listemsg = [Select id,RelatedToid from EmailMessage where RelatedToid IN: setcaseid];
        
        if(listemsg.size() > 0){
            for(EmailMessage emsg : listemsg){
                if(mapemailmsg.Containskey(emsg.RelatedToid)){
                    list<EmailMessage> listnewemsg = new list<EmailMessage>();
                    listnewemsg = mapemailmsg.get(emsg.RelatedToid);
                    listemsg.add(emsg);
                    mapemailmsg.put(emsg.RelatedToid , listemsg);
                }
                else{
                    list<EmailMessage> listnewemsg = new list<EmailMessage>();
                    listnewemsg.add(emsg);
                    mapemailmsg.put(emsg.RelatedToid , listnewemsg);
                }
            }
        }
        
        return mapemailmsg;
    }
    */
}