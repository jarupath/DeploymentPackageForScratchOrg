trigger Email_Trigger on EmailMessage (before insert, after insert, after update) {
    private static final String CLASS_NAME = 'Email_Trigger';
    public static final Set<String> recset = new Set<String> {'Ground Service', 'Ground Service Closed', 'Ground Service Delete', 'Maintenance', 'New Maintenance', 'Void Maintenance'};
    Map<String, SObject> recordTypeMap = Be8_GlobalUtility.getSObjectMap('Id', [SELECT Id, Name FROM RecordType WHERE Name IN :recset]);
    if (TriggerActivator.isTriggerActivated(TriggerActivator.EMAIL_TRIGGER)) {
        list<EmailMessage> listemailmsg = new list<EmailMessage>();
        set<id> setcaseid = new set<id>();

        Set<Id> caseIdSetToQuery = new Set<Id>();
        for(EmailMessage eachEmail : Trigger.new) {
            if(eachEmail.RelatedToId != null) {
                Boolean relateToCase = eachEmail.RelatedToId.getSobjectType().getDescribe().getName() == 'Case';
                if(relateToCase) {
                    caseIdSetToQuery.add(eachEmail.RelatedToId);
                    if(Trigger.isBefore && Trigger.isInsert) {
                        if(eachEmail.Original_Case__c == null) eachEmail.Original_Case__c = eachEmail.RelatedToId;
                    }
                }
            }
        }

        if(Trigger.isAfter) {
            Map<Id, Case> caseRecordTypeMap = new Map<Id, Case>([SELECT Id, RecordTypeId FROM Case WHERE Id IN :caseIdSetToQuery]);
            for (EmailMessage thisemail : Trigger.new) {
                if(!thisemail.isMerge_Demerge__c){
                    if (caseRecordTypeMap.containsKey(thisemail.RelatedToId)) {
                        Id recordTypeId = caseRecordTypeMap.get(thisemail.RelatedToId).RecordTypeId;
                        if (recordTypeId != null && recordTypeMap.get(recordTypeId) == null) {
                            if (thisemail.relatedtoid != null && String.ValueOf(thisemail.relatedtoid).left(3) == '500') {
                                AppLogger.debug(CLASS_NAME, 'After Insert', thisemail.relatedtoid, System.JSON.serialize(thisemail), null);
                                listemailmsg.add(thisemail);
                                setcaseid.add(thisemail.relatedtoid);
                            }
                        }
                    }
                }
            }

            system.debug('map list email msg :: ' + listemailmsg.size());

            if (listemailmsg.size() > 0) {
                Emailmsg_Controller.changecasestatus(listemailmsg, setcaseid);
            }
        }
    }
}