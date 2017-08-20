public with sharing class AppLogger {
    private static AppLogger instance = null;
    public List<BE8_ApplicationLogWrapper> logs = new List<BE8_ApplicationLogWrapper>();
    public Map<String, List<Attachment>> attachModelMap = new Map<String, List<Attachment>>();
    public Map<String, Application_Log__c> logsModelMap = new Map<String, Application_Log__c>();
    private String mainReferenceId = '';

    public AppLogger() {

    }

    public static String getReferenceId() {
        return getInstance().mainReferenceId;
    }

    public static String setReferenceId(String referenceId) {
        if (String.isBlank(getInstance().mainReferenceId)) {
            getInstance().mainReferenceId = referenceId;
        }
        return getInstance().mainReferenceId;
    }

    public static BE8_ApplicationLogWrapper warn(String sourceClass, String sourceFunction, String referenceId, String logMessage, Exception ex) {
        return add(BE8_GlobalConstants.LEVEL_WARNING, sourceClass, sourceFunction, referenceId, '', logMessage, '', ex, System.currentTimeMillis());
    }

    public static BE8_ApplicationLogWrapper error(String sourceClass, String sourceFunction, String referenceId, String logMessage, Exception ex) {
        return add(BE8_GlobalConstants.LEVEL_ERROR, sourceClass, sourceFunction, referenceId, '', logMessage, '', ex, System.currentTimeMillis());
    }

    public static BE8_ApplicationLogWrapper debug(String sourceClass, String sourceFunction, String referenceId, String logMessage, Exception ex) {
        return add(BE8_GlobalConstants.LEVEL_DEBUG, sourceClass, sourceFunction, referenceId, '', logMessage, '', ex, System.currentTimeMillis());
    }

    public static BE8_ApplicationLogWrapper add(String logLevel, String sourceClass, String sourceFunction, String  referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {
        if (!String.isBlank(getInstance().mainReferenceId)) {
            referenceId = getInstance().mainReferenceId;
        }

        if(BE8_GlobalConstants.LEVEL_DEBUG == logLevel) {
            System.debug(referenceId+' '+logMessage);
        }

        BE8_ApplicationLogWrapper log = new BE8_ApplicationLogWrapper();
        log.source = sourceClass;
        log.logMessage = logMessage.length() > 131072 ? logMessage.substring(0, 131072) : logMessage;
        log.sourceFunction = sourceFunction;
        log.referenceId = referenceId;
        log.referenceInfo = referenceInfo;
        log.payload = payLoad;
        log.debugLevel = logLevel;
        log.ex = ex;
        log.timer = timeTaken;
        getInstance().logs.add(log);
        System.debug('AppLogger.add ' + log);
        return log;
    }

    public static BE8_ApplicationLogWrapper add(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {

        if(BE8_GlobalConstants.LEVEL_DEBUG == logLevel) {
            System.debug(logMessage);
        }

        BE8_ApplicationLogWrapper log = new BE8_ApplicationLogWrapper();
        log.source = sourceClass;
        log.logMessage = logMessage;
        log.sourceFunction = sourceFunction;
        log.referenceId = null;
        log.referenceInfo = '';
        log.payload = payLoad;
        log.debugLevel = logLevel;
        log.ex = ex;
        log.timer = timeTaken;
        getInstance().logs.add(log);
        System.debug('AppLogger.add ' + log);
        return log;
    }

    //public static void mailLogs(String subject, String toAddress) {
    //    String bodyMsg = '';
    //    for (BE8_ApplicationLogWrapper log : getInstance().logs) {
    //        bodyMsg += log.source + ' ' + log.sourceFunction + ' ' + log.logMessage + '\n';
    //    }

    //    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //    List<String> toAddresses = new List<String>();
    //    toAddresses.addAll(toAddress.split(','));
    //    mail.setToAddresses(toAddresses);
    //    mail.setSubject(subject);
    //    mail.setPlainTextBody(bodyMsg);
    //    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    //}

    public static void insertLogs() {
        if (!getInstance().logs.isEmpty()) {
            //debugLogs();
            BE8_GlobalUtility.logMessage(getInstance().logs);
            getInstance().logs.clear();
        }
    }

    public static void debugLogs() {
        System.debug('DEBUG Applogger :' + getInstance().logs.size());
        for (BE8_ApplicationLogWrapper eachLog : getInstance().logs) {
            System.debug(eachLog);
        }
    }

    //public static void insertLogsAndSendEmail() {
    //    insertLogs();
    //    Monitoring.sendEmail();
    //}

    public static AppLogger getInstance() {
        if (instance == null) instance = new AppLogger();
        return instance;
    }

    public static void addLogModel(String logLevel, String sourceClass, String sourceFunction, String  referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken, Map<String, String> attachMap) {
        BE8_ApplicationLogWrapper log = new BE8_ApplicationLogWrapper();
        log.source = sourceClass;
        log.logMessage = logMessage;
        log.sourceFunction = sourceFunction;
        log.referenceId = referenceId;
        log.referenceInfo = referenceInfo;
        log.payload = payLoad;
        log.debugLevel = logLevel;
        log.ex = ex;
        log.timer = timeTaken;

        Application_Log__c applog = BE8_GlobalUtility.getAppLog(log);

        if (applog != null) {
            List<Attachment> attachList = attachMap.isEmpty() ? null : createAttachment(attachMap, sourceClass, sourceFunction);
            System.debug('AttachList');
            System.debug(attachList);
            getInstance().logsModelMap.put(applog.Name, applog);
            getInstance().attachModelMap.put(applog.Name, attachList);
            System.debug('AppLogger.addLogModel: ' + log + ' | ' + attachList);
        } else {
            System.debug('Debug log level is not activated');
        }
    }

    public static void addLogModel(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken, Map<String, String> attachMap) {
        addLogModel(logLevel, sourceClass, sourceFunction, null, '', logMessage, payLoad, ex, timeTaken, attachMap);
    }

    public static void insertLogModel() {
        if (!getInstance().logsModelMap.isEmpty()) {
            List<Attachment> attachList = new List<Attachment>();
            insert getInstance().logsModelMap.values();
            for (Application_Log__c applog : getInstance().logsModelMap.values()) {
                if (getInstance().attachModelMap.get(applog.Name) != null) {
                    for (Attachment a : getInstance().attachModelMap.get(applog.Name)) {
                        a.ParentId = applog.Id;
                    }
                    attachList.addAll(getInstance().attachModelMap.get(applog.Name));
                }
            }
            Database.SaveResult[] result = Database.insert(attachList, false);
            System.debug('logsModelMap');
            System.debug(getInstance().logsModelMap.values());
            System.debug('Inserted AttachList');
            System.debug(JSON.serialize(attachList));
            System.debug('Insert Result');
            System.debug(JSON.serialize(result));
        }
    }

    public static List<BE8_ApplicationLogWrapper> getLogs() {
        return getInstance().logs;
    }

    public static Map<String, Application_Log__c> getLogModel() {
        return getInstance().logsModelMap;
    }

    public static Map<String, List<Attachment>> getAttachModel() {
        return getInstance().attachModelMap;
    }

    public static List<Attachment> createAttachment(Map<String, String> attachMap, String sourceClass, String sourceFunction) {
        List<Attachment> attachList = new List<Attachment>();
        for (String attachName : attachMap.keySet()) {
            Attachment attach = new Attachment();
            attach.Name = attachName + '_' + sourceClass + ' - ' + sourceFunction + '_' + System.currentTimeMillis();
            attach.Body = Blob.valueOf(attachMap.get(attachName));
            attach.ContentType = 'Text';
            attachList.add(attach);
        }
        return attachList;
    }
}