public with sharing class MailList_Repository{
    private static MailList_Repository instance = null;
    private Map<String, Map<String, String>> mailMap = new Map<String, Map<String,String>>();
    private static String defaultEmail = 'somwut.j@beryl8.com';
    public static Map<String, String> getEmailList(String type) {
        Map<String, Map<String, String>> mailMap = getInstance().mailMap;
        if(!mailMap.containsKey(type)) {
            Map<String, String> mailMapByDevName = new Map<String, String>();
            List<Custom_Mail_List__mdt> mails = [SELECT Id, DeveloperName, Email_Address__c, Email_Type__c FROM Custom_Mail_List__mdt WHERE Email_Type__c = :type];
            for(Custom_Mail_List__mdt eachMail : mails) {
                mailMapByDevName.put(eachMail.DeveloperName, eachMail.Email_Address__c);
            }
            mailMap.put(type, mailMapByDevName);
        } 
        return mailMap.get(type);
    }
    
    public static String getEmailAddress(String type, String key) {
        Map<String, String> mailMapByType = getEmailList(type);
        if(mailMapByType.containsKey(key)) {
            return mailMapByType.get(key);
        } else {
            return defaultEmail;
        }        
    }

    public static MailList_Repository getInstance() {
        if(instance == null) instance = new MailList_Repository();
        return instance;
    }
}