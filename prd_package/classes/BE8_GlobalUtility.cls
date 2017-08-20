/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global utility class for common functions
Test Class:    GlobalUtility_Test
History :
<Date>      <Authors Name>     <Brief Description of Change>
05/28/2015  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class BE8_GlobalUtility {
    public static Boolean runOnce = false;
    public static Boolean accounFromYearend = false;
    public static Boolean initialMonthly = false;
    public static Boolean resetStatement = false;

    public static List<String> CABIN_CLASS_TWO_DIGIT = new List<String> {'F', 'C', 'U'};
    public static List<String> CABIN_CLASS_THREE_DIGIT = new List<String> {'Y'};

    public static Map<String, Map<String, String>> recordTypeMapMapBySObject;

    public static final String LOG_NAME_PREFIX = 'ALOG-';
    public static final Map<Integer, String> MONTH_STR_MAP = new Map<Integer, String> {1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};

    public static BE8_ApplicationLogWrapper createAppLog(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {
        BE8_ApplicationLogWrapper msg = new BE8_ApplicationLogWrapper();
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = null;
        msg.referenceInfo = '';
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;
        return msg;
    }

    public static BE8_ApplicationLogWrapper createAppLog(String logLevel, String sourceClass, String sourceFunction, String  referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {
        BE8_ApplicationLogWrapper msg = new BE8_ApplicationLogWrapper();
        msg.source = sourceClass;
        msg.logMessage = logMessage;
        msg.sourceFunction = sourceFunction;
        msg.referenceId = referenceId;
        msg.referenceInfo = referenceInfo;
        msg.payload = payLoad;
        msg.debugLevel = logLevel;
        msg.ex = ex;
        msg.Timer = timeTaken;
        return msg;
    }

    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String logMessage, String payLoad, Exception ex, long timeTaken) {
        BE8_ApplicationLogWrapper msg = createAppLog(logLevel, sourceClass, sourceFunction, logMessage, payLoad, ex, timeTaken);
        logMessage(msg);
    }

    public static void logMessage(String logLevel, String sourceClass, String sourceFunction, String referenceId, String referenceInfo, String logMessage, String payLoad, Exception ex, long timeTaken) {
        BE8_ApplicationLogWrapper msg = createAppLog(logLevel, sourceClass, sourceFunction, referenceId, referenceInfo, logMessage, payload, ex, timeTaken);
        logMessage(msg);
    }

    public static void logMessage(BE8_ApplicationLogWrapper appLog) {
        List<BE8_ApplicationLogWrapper> appLogs = new List<BE8_ApplicationLogWrapper>();
        appLogs.add ( appLog );
        logMessage ( appLogs );
    }

    public static String subStringByMaxLength(String str, Integer maxLength) {
        if (str != null && str.length() > maxLength) {
            return str.substring(0, maxLength);
        } else {
            return str;
        }
    }

    public static void logMessage(List<BE8_ApplicationLogWrapper> appLogs) {
        List<Application_Log__c> insertAppLogs = new List<Application_Log__c>();

        for (BE8_ApplicationLogWrapper appLog : appLogs) {
            Application_Log__c log = new Application_Log__c();
            Datetime dt = Datetime.now();
            String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
            log.Name = LOG_NAME_PREFIX + formattedDt;
            log.Source__c = appLog.source;
            log.Source_Function__c = appLog.sourceFunction;
            log.Reference_Id__c = appLog.referenceId;
            log.Reference_Information__c = appLog.referenceInfo;
            log.Message__c = appLog.logMessage;
            log.Integration_Payload__c = subStringByMaxLength(appLog.payload, Application_Log__c.Integration_Payload__c.getDescribe().getLength());

            if (appLog.ex != null) {
                log.Stack_Trace__c = appLog.ex.getStackTraceString();
                //log.Message__c = applog.ex.getMessage();
                log.Exception_Message__c = applog.ex.getMessage();
            }

            log.Debug_Level__c = appLog.debugLevel;
            log.Log_Code__c = appLog.logCode;
            log.Timer__c = appLog.timer;
            System.debug('Log: ' + log);
            System.debug('Is Valid Insert: ' + isValidInsert(appLog.debugLevel));
            if (isValidInsert(appLog.debugLevel)) {
                insertAppLogs.add(log);
            }
        }
        System.debug('Inserted App Log List Size: ' + insertAppLogs.size());
        if ( insertAppLogs.size() != 0) {
            insert insertAppLogs;
        }
    }

    public static Application_Log__c getAppLog(BE8_ApplicationLogWrapper appLog) {
        Application_Log__c log = new Application_Log__c();
        Datetime dt = Datetime.now();
        String formattedDt = dt.format('ddMMyyyy\'T\'hhmmss\'Z\'SSS');
        log.Name = LOG_NAME_PREFIX + formattedDt;
        log.Source__c = appLog.source;
        log.Source_Function__c = appLog.sourceFunction;
        log.Reference_Id__c = appLog.referenceId;
        log.Reference_Information__c = appLog.referenceInfo;
        log.Message__c = appLog.logMessage;
        log.Integration_Payload__c = appLog.payload;

        if (appLog.ex != null) {
            log.Stack_Trace__c = appLog.ex.getStackTraceString();
            log.Exception_Message__c = applog.ex.getMessage();
        }

        log.Debug_Level__c = appLog.debugLevel;
        log.Log_Code__c = appLog.logCode;
        log.Timer__c = appLog.timer;
        System.debug('Log: ' + log);
        System.debug('Is Valid Insert: ' + isValidInsert(appLog.debugLevel));
        if (isValidInsert(appLog.debugLevel)) {
            return log;
        }
        return null;
    }

    public static void cacheLogMessage(String sourceClass, String sourceFunction, String debugLevel, String message, String referenceId, List<Application_Log__c> cache) {
        Application_Log__c log = new Application_Log__c();
        log.Source__c = sourceClass;
        log.Source_Function__c = sourceFunction;
        log.Debug_Level__c = BE8_GlobalConstants.LEVEL_DEBUG;
        log.Message__c = message;
        log.Reference_Id__c = referenceId;
        cache.add(log);
    }

    public static Boolean isValidInsert(String debugLevel) {
        Boolean validInsert = false;

        if (debugLevel == BE8_GlobalConstants.LEVEL_DEBUG && System_Settings__c.getInstance().Debug__c) {
            validInsert = true;
        }

        System.Debug('Error Flag:' + System_Settings__c.getInstance().Error__c);
        if (debugLevel == BE8_GlobalConstants.LEVEL_ERROR && System_Settings__c.getInstance().Error__c) {
            validInsert = true;
        }

        if (debugLevel == BE8_GlobalConstants.LEVEL_INFO && System_Settings__c.getInstance().Info__c) {
            validInsert = true;
        }
        System.Debug('Warning Flag: ' + System_Settings__c.getInstance().Warning__c);
        if (debugLevel == BE8_GlobalConstants.LEVEL_WARNING && System_Settings__c.getInstance().Warning__c) {
            validInsert = true;
        }
        return validInsert;
    }

    public static Boolean isEmailValid(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher resutlMatcher = emailPattern.matcher(email);

        return resutlMatcher.matches();
    }

    //public static void sendTemplatedEmail(String[] toRecipients, String[] ccRecipients, String templateApiName,
    //                                      ID targetObjId, Id whatId, ID orgWideEmailId, Boolean saveAsActivity,
    //                                      Attachment[] attachList ) {

    //    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    //    Id templateId;

    //    try {
    //        templateId = [select id, name from EmailTemplate where developername = : templateApiName].id;
    //    } catch (Exception e) {
    //        e.setMessage('[U-03] Unable to locate EmailTemplate using name: ' + templateApiName +
    //                     ' refer to Setup | Communications Templates ' + templateApiName);
    //        throw e;
    //    }

    //    email.setToAddresses(toRecipients);
    //    email.setCcAddresses(ccRecipients);
    //    email.setTargetObjectId(targetObjId);
    //    email.setWhatId(whatId);
    //    email.setorgWideEmailAddressId(orgWideEmailId);
    //    email.setTemplateId(templateId);
    //    email.setSaveAsActivity(saveAsActivity);      // save email as activity on the targetObjId (i.e. Contact). Note activity can't be saved on Users

    //    try {
    //        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    //        return;
    //    } catch (EmailException e) {
    //        e.setMessage('[U-02] sendTemplatedEmail error. ' + e.getMessage());
    //        throw e;
    //    }
    //}

    private static Map<String, Map<String, Id>> getRecordTypeIdMapByDevName() {
        if (BE8_GlobalUtility.recordTypeMapMapBySObject == null) {
            BE8_GlobalUtility.recordTypeMapMapBySObject = new Map<String, Map<String, Id>>();
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName, SObjectType FROM RecordType]);
            for (RecordType eachRecordType : recordTypeMap.values()) {
                if (BE8_GlobalUtility.recordTypeMapMapBySObject.containsKey(eachRecordType.SObjectType)) {
                    BE8_GlobalUtility.recordTypeMapMapBySObject.get(eachRecordType.SObjectType).put(eachRecordType.DeveloperName, eachRecordType.Id);
                } else {
                    BE8_GlobalUtility.recordTypeMapMapBySObject.put(eachRecordType.SObjectType, new Map<String, Id> {eachRecordType.DeveloperName => eachRecordType.Id});
                }
            }
        }

        return BE8_GlobalUtility.recordTypeMapMapBySObject;
    }

    public static Map<String, Id> getRecordTypeMapByDevNameFromSObject(String sObjectName) {
        BE8_GlobalUtility.recordTypeMapMapBySObject = getRecordTypeIdMapByDevName();
        Map<String, Id> resultsMap = BE8_GlobalUtility.recordTypeMapMapBySObject.get(sObjectName);

        return resultsMap;
    }

    public static Map<Id, String> getRecordTypeDevNameMapByIdFromSObject(String sObjectName) {
        BE8_GlobalUtility.recordTypeMapMapBySObject = getRecordTypeIdMapByDevName();
        Map<Id, String> resultsMap = new Map<Id, String>();
        Map<String, Id> recIdMapByDevName = BE8_GlobalUtility.recordTypeMapMapBySObject.get(sObjectName);

        for (String recordTypeDevName : recIdMapByDevName.keySet()) {
            resultsMap.put(recIdMapByDevName.get(recordTypeDevName), recordTypeDevName);
        }

        return resultsMap;
    }

    public static Id getRecordTypeIdFromSObjectByDevName(String sObjectName, String recordTypeDevName) {
        BE8_GlobalUtility.recordTypeMapMapBySObject = getRecordTypeIdMapByDevName();
        Map<String, Id> resultsMap = BE8_GlobalUtility.recordTypeMapMapBySObject.get(sObjectName);
        return resultsMap.get(recordTypeDevName);
    }

    //public static Id getRecordTypeOpportunityIdByName(String name) {
    //    return (Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name) != null) ? Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(name).getRecordTypeId() : null;
    //}

    //public static Id getRecordTypeAccountIdByName(String name) {
    //    return (Schema.SObjectType.Account.getRecordTypeInfosByName().get(name) != null) ? Schema.SObjectType.Account.getRecordTypeInfosByName().get(name).getRecordTypeId() : null;
    //}

    //public static Id getRecordTypeCampaignIdByName(String name) {
    //    return (Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name) != null) ? Schema.SObjectType.Campaign.getRecordTypeInfosByName().get(name).getRecordTypeId() : null;
    //}

    //public static String getRecordTypeNameById(Id pRecordTypeId) {
    //    RecordType r = [Select Name From RecordType Where Id = :pRecordTypeId];
    //    if (r != null) {
    //        return r.Name;
    //    }
    //    return null;
    //}

    //public static map<string, sObject> toMap(string field_name, List<sObject> objects) {
    //    map<string, sObject> result = new map<string, sObject>();

    //    for (sObject obj : objects) {
    //        result.put(string.valueOf(obj.get(field_name)), obj);
    //    }
    //    return result;
    //}

    //public static map<string, sObject> toMapLookup(String field_name, String lookup_name, List<sObject> objects) {
    //    map<string, sObject> result = new map<string, sObject>();

    //    for (sObject obj : objects) {
    //        result.put(string.valueOf(obj.getsObject(field_name).get(lookup_name)), obj);
    //    }
    //    return result;
    //}

    // Encrypt Image path
    //public static String getEncryptedData(String cryptoKey, String dataToEncrypt) {
    //    Blob encryptedData = Crypto.encryptWithManagedIV('AES128', Blob.valueOf(cryptoKey), Blob.valueOf(dataToEncrypt));
    //    return EncodingUtil.base64Encode(encryptedData);
    //}

    //public static String getEncryptedDataWithTransform(String cryptoKey, String dataToEncrypt) {
    //    String encryptImgURL = getEncryptedData(cryptoKey, dataToEncrypt);
    //    String encodedHex = EncodingUtil.urlEncode(encryptImgURL, 'UTF-8');
    //    String transformEncodedHex = encodedHex.replace('%', '!');
    //    return transformEncodedHex;
    //}

    //public static Boolean isNumberAlphabet(String name) {
    //    Boolean isNumberAlphabet = false;
    //    String nameRegEx = '(\\d+)';
    //    Pattern myPattern = Pattern.compile(nameRegEx);
    //    Matcher myMatcher = myPattern.matcher(name);
    //    myMatcher.region(0, myMatcher.regionEnd());
    //    isNumberAlphabet = myMatcher.matches();
    //    return isNumberAlphabet;
    //}

    //public static String toCurrency(Object currencyObj) {
    //    String currencyStr = String.valueOf(currencyObj);
    //    String s = (Decimal.valueOf(currencyStr == null || currencyStr.trim() == '' ? '0' : currencyStr).setScale(2) + 0.001 ).format();
    //    return s.substring(0, s.length() - 1);
    //}

    //public static String toValue(Object val) {
    //    return val != null ? String.valueOf(val) : '';
    //}

    //public static Decimal toDecimal(String val) {
    //    return val != null && val != '' ? Decimal.valueOf(val) : 0;
    //}

    //public static Decimal toDecimal(Decimal val) {
    //    return val != null ? val : 0;
    //}

    public static String toNumber(Object val) {
        String numberString;
        try {
            numberString = String.valueOf(Integer.valueOf(val));
        } catch (Exception ex) {
            System.debug(ex);
            numberString = '0';
        }
        return val != null ? numberString : '0';
    }

    //public static String toDateFormat(String yearStr, String month, String day) {
    //    Integer year = Integer.valueOf(yearStr);
    //    if (year > 2400) year = year - 543;
    //    Date thisDate = Date.newInstance(year, Integer.valueOf(month), Integer.valueOf(day));
    //    String monthStr = (thisDate.month() < 10 ? '0' : '') + String.valueOf(thisDate.month());
    //    String dayStr = (thisDate.day() < 10 ? '0' : '') + String.valueOf(thisDate.day());
    //    return dayStr + '/' + monthStr + '/' + thisDate.year();
    //}

    public static String toExportDateFormat(Date inputDate) {
        String returnDate;
        String tempYear = String.valueOf(inputDate.year());
        if (String.valueOf(UserInfo.getLocale()) == 'th_TH') {
            tempYear = String.valueOf(Integer.valueOf(inputDate.year()) - 543);
        }
        returnDate = String.valueOf(tempYear) + '-' + String.valueOf('0' + String.valueOf(inputDate.month())).right(2) + '-' + String.valueOf('0' + String.valueOf(inputDate.day())).right(2);

        return returnDate;
    }

    public static  Map<String, String> getLocaleDateMap() {
        Map<String, String> locale_map = new Map<String, String>(); //holds the locale to timedate formats
        locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
        locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
        locale_map.put('bg_BG', 'yyyy-M-d H:mm');
        locale_map.put('ca', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
        locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('cs', 'd.M.yyyy H:mm');
        locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
        locale_map.put('da', 'dd-MM-yyyy HH:mm');
        locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
        locale_map.put('de', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
        locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
        locale_map.put('el_GR', 'd/M/yyyy h:mm a');
        locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
        locale_map.put('en_B', 'M/d/yyyy h:mm a');
        locale_map.put('en_BM', 'M/d/yyyy h:mm a');
        locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
        locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_GH', 'M/d/yyyy h:mm a');
        locale_map.put('en_ID', 'M/d/yyyy h:mm a');
        locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
        locale_map.put('en_SG', 'M/d/yyyy h:mm a');
        locale_map.put('en_US', 'M/d/yyyy h:mm a');
        locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
        locale_map.put('es', 'd/MM/yyyy H:mm');
        locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
        locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
        locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_ES', 'd/MM/yyyy H:mm');
        locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
        locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
        locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
        locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
        locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
        locale_map.put('et_EE', 'd.MM.yyyy H:mm');
        locale_map.put('fi', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI', 'd.M.yyyy H:mm');
        locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
        locale_map.put('fr', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
        locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
        locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
        locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
        locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
        locale_map.put('hu', 'yyyy.MM.dd. H:mm');
        locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
        locale_map.put('is_IS', 'd.M.yyyy HH:mm');
        locale_map.put('it', 'dd/MM/yyyy H.mm');
        locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
        locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
        locale_map.put('iw', 'HH:mm dd/MM/yyyy');
        locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
        locale_map.put('ja', 'yyyy/MM/dd H:mm');
        locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
        locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
        locale_map.put('km_KH', 'M/d/yyyy h:mm a');
        locale_map.put('ko', 'yyyy. M. d a h:mm');
        locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
        locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
        locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
        locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
        locale_map.put('nl', 'd-M-yyyy H:mm');
        locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
        locale_map.put('nl_NL', 'd-M-yyyy H:mm');
        locale_map.put('nl_SR', 'd-M-yyyy H:mm');
        locale_map.put('no', 'dd.MM.yyyy HH:mm');
        locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
        locale_map.put('pl', 'yyyy-MM-dd HH:mm');
        locale_map.put('pt', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
        locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
        locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
        locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
        locale_map.put('ru', 'dd.MM.yyyy H:mm');
        locale_map.put('sk_SK', 'd.M.yyyy H:mm');
        locale_map.put('sl_SI', 'd.M.y H:mm');
        locale_map.put('sv', 'yyyy-MM-dd HH:mm');
        locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
        locale_map.put('th', 'M/d/yyyy h:mm a');
        locale_map.put('th_TH', 'd/M/yyyy, H:mm');
        locale_map.put('tr', 'dd.MM.yyyy HH:mm');
        locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
        locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
        locale_map.put('zh', 'yyyy-M-d ah:mm');
        locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
        locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
        locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
        return locale_map; //return the map
    }

    public static String makeSOAPRequestCallout(String endpoint, String soapAction, String body) {
        //body = body.replaceAll('&', '&amp;');
        if(body.contains('&') && !body.contains('&amp;')) body = replaceAll(body, '&', '&amp;');
        //body = replaceAll(body, '&', '&amp;');
        System.debug('endpoint=[' + endpoint + ']');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setTimeout(120000);
        req.setEndpoint(endpoint);
        req.setHeader('Content-Type', 'text/xml;charset=utf-8');
        //req.setHeader('Content-Type', 'application/soap+xml;charset=UTF-8;action="EnrollROPMember"');
        req.setHeader('Content-Length', '' + body.length());
        req.setHeader('soapAction', soapAction);
        req.setHeader('Accept', 'text/xml');
        req.setMethod('POST');
        req.setBody(body);
        res = http.send(req);
        return res.getBody();
    }

    public static String makeSOAPRequestCallout(String endpoint, String soapAction, String body, String actionOnContentType) {
        System.debug('endpoint=[' + endpoint + ']');
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        req.setTimeout(120000);
        req.setEndpoint(endpoint);
        //req.setHeader('Content-Type', 'text/xml;charset=utf-8');
        req.setHeader('Content-Type', 'application/soap+xml;charset=UTF-8;action="' + actionOnContentType + '"');
        req.setHeader('Content-Length', '' + body.length());
        req.setHeader('soapAction', soapAction);
        req.setHeader('Accept', 'text/xml');
        req.setMethod('POST');
        req.setBody(body);
        res = http.send(req);
        return res.getBody();
    }

    public static String removeCDATAfromXMLString(String xml) {
        //String encoded = EncodingUtil.urlEncode(xml, 'UTF-8');
        //encoded = encoded.replaceAll('%3C%21%5BCDATA%5B', ''); // i.e. '<![CDATA['
        //encoded = encoded.replaceAll('%5D%5D%3E', ''); // i.e. ']]>'
        return xml.unescapeHtml4();
    }

    public static String getSetting(String key) {
        return TG_WS_SETTING__c.getValues(key).TG_WS_VALUE__c;
    }

    public static String getDateString(Date pDT, String pFormat) {
        if (pDT == null) return null;
        return String.valueOf(Datetime.newInstance(pDT.year(), pDT.month(), pDT.day()).format(pFormat));
    }

    //public static Integer getDifference(Datetime pBefore, Datetime pAfter) {
    //    if (pBefore == null || pAfter == null) return 0;

    //    return (pAfter.millisecond() - pBefore.millisecond());
    //}

    public static Integer toNumber(String pData) {
        if (pData == null) return null;

        pData = pData.replaceAll(',', '');

        Integer result = null;
        try {
            result = Integer.valueOf(pData);
        } catch (Exception e) {
            return null;
        }

        return result;
    }

    public static Set<Id> getIdSet(String fieldName, List<SObject> sObjectList) {
        Set<Id> idSet = new Set<Id>();
        if (sObjectList != null) {
            for (SObject obj : sObjectList) {
                Id eachId = (Id) obj.get(fieldName);
                if (eachId != null) {
                    idSet.add(eachId);
                }
            }
        }
        return idSet;
    }

    public static Set<String> getStringSet(String fieldName, List<SObject> sObjectList) {
        Set<String> stringSet = new Set<String>();
        if (sObjectList != null) {
            for (SObject obj : sObjectList) {
                String eachString = String.valueOf(obj.get(fieldName));
                if (eachString != null) {
                    stringSet.add(eachString);
                }
            }
        }
        return stringSet;
    }

    public static Map<String, SObject> getSObjectMap(String byFieldName, List<SObject> sObjectList) {
        Map<String, SObject> sObjectMap = new Map<String, SObject>();
        for (SObject obj : sObjectList) {
            String key = String.valueOf(obj.get(byFieldName));
            sObjectMap.put(key, obj);
        }
        return sObjectMap;
    }

    public static Map<String, SObject> getSObjectMap(Set<String> byFieldName, List<SObject> sObjectList) {
        if (byFieldName.size() > 0) {
            Map<String, SObject> sObjectMap = new Map<String, SObject>();
            for (SObject obj : sObjectList) {
                String key = '';
                for (String filedName : byFieldName) {
                    key += String.valueOf(obj.get(filedName));
                }
                sObjectMap.put(key, obj);
            }
            return sObjectMap;
        }
        return null;
    }

    public static Map<String, List<SObject>> getSObjectListMap(String byFieldName, List<SObject> sObjectList) {
        Map<String, List<SObject>> sObjectMap = new Map<String, List<SObject>>();
        for (SObject obj : sObjectList) {
            String key = String.valueOf(obj.get(byFieldName));
            if (sObjectMap.containsKey(key)) {
                List<SObject> tempList = sObjectMap.get(key);
                tempList.add(obj);
            } else {
                List<SObject> tempList = new List<SObject>();
                tempList.add(obj);
                sObjectMap.put(key, tempList);
            }
        }
        return sObjectMap;
    }

    public static Map<String, List<SObject>> getSObjectListMap(Set<String> byFieldName, List<SObject> sObjectList) {
        if (byFieldName.size() > 0) {
            Map<String, List<SObject>> sObjectMap = new Map<String, List<SObject>>();
            for (SObject obj : sObjectList) {
                String key = '';
                for (String filedName : byFieldName) {
                    key += String.valueOf(obj.get(filedName));
                }
                if (sObjectMap.containsKey(key)) {
                    List<SObject> tempList = sObjectMap.get(key);
                    tempList.add(obj);
                } else {
                    List<SObject> tempList = new List<SObject>();
                    tempList.add(obj);
                    sObjectMap.put(key, tempList);
                }
            }
            return sObjectMap;
        }
        return null;
    }
    /*
        Edit By: Jarupath Kulsiriruangyos Latest Modified: 13 Oct 09.15
    */

    //public static Map<String, SObject> getMapFromList(String keyField, List<SObject> objectList) {
    //    Map<String, SObject> returnMap = new Map<String, SObject>();
    //    for (SObject obj : objectList) {
    //        returnMap.put(String.valueOf(obj.get(keyField)), obj);
    //    }
    //    return returnMap;
    //}

    public static String convertDurationToMiniteUnit(String duration, String delimeter) {
        List<String> durationSplit = null;
        System.debug('duration: ' + duration);
        Integer minite = 0;
        if (duration != null) {
            if (delimeter != null) {
                durationSplit = duration.split('\\' + delimeter);
            } else {
                durationSplit = new List<String>();
                durationSplit.add(duration.substring(0, 2));
                durationSplit.add(duration.substring(2, duration.length()));
            }
            minite = Integer.valueOf(durationSplit.get(0)) * 60;
            minite += Integer.valueOf(durationSplit.get(1));
            return String.valueOf(minite);
        }
        return null;

    }

    public static Map<String, String> getExistingAccount(List<String> ropNoList) {
        System.debug('ropNoList:---' + ropNoList);
        Map<String, String> mappingList = new Map<String, String>();
        List<Membership__c> mem = [SELECT Id, Name, AccountId__c, Airline__c, EXTMember__c FROM Membership__c WHERE EXTMember__c in :ropNoList AND Status__c = :BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE];
        System.debug('mem size:---' + mem);
        for (Membership__c m : mem) {
            //String memNo = m.Airline__c + m.Name;
            String memNo = m.EXTMember__c;
            String accNo = m.AccountId__c;
            mappingList.put(memNo, accNo);
        }
        return mappingList;
    }

    public static Map<String, Membership__c> getExistingAccountMember(List<String> ropNoList) {
        System.debug('ropNoList:---' + ropNoList);
        Map<String, Membership__c> mappingList = new Map<String, Membership__c>();
        List<Membership__c> mem = [SELECT Id, Name, AccountId__c, Airline__c, EXTMember__c FROM Membership__c WHERE EXTMember__c in :ropNoList AND Status__c = :BE8_GlobalConstants.MEMBERSHIP_STATUS_ACTIVE];
        System.debug('mem size:---' + mem);
        for (Membership__c m : mem) {
            //String memNo = m.Airline__c + m.Name;
            String memNo = m.EXTMember__c;
            String accNo = m.AccountId__c;
            mappingList.put(memNo, m);
        }
        System.debug('Number of Existing Member:---' + mappingList.size());
        return mappingList;
    }

    public static void print(String pPrefix, List<Database.UpsertResult> results) {
        if (results != null) {
            for (Database.UpsertResult r : results) {
                if (!r.isSuccess()) {
                    List<Database.Error> errors = r.getErrors();
                    for (Database.Error e : errors) {
                        System.debug('Error upsert ' + pPrefix + ' :' + e.getMessage());
                    }
                }
            }
        }
    }

    public static void print(List<Database.UpsertResult> results) {
        if (results != null) {
            for (Database.UpsertResult r : results) {
                if (!r.isSuccess()) {
                    List<Database.Error> errors = r.getErrors();
                    for (Database.Error e : errors) {
                        System.debug('Error upsert :' + e.getMessage());
                    }
                }
            }
        }
    }

    public static String getErrorMessage(List<Database.UpsertResult> results) {
        if (results != null) {
            String error = '';
            for (Database.UpsertResult r : results) {
                if (!r.isSuccess()) {
                    List<Database.Error> errors = r.getErrors();
                    for (Database.Error e : errors) {
                        error += 'Error upsert :' + e.getMessage() + ' ' + r.getId() + '\n';
                    }
                }
            }
            return error;
        }
        return null;
    }

    public static String getErrorMessage(List<Database.SaveResult> results) {
        if (results != null) {
            String error = '';
            for (Database.SaveResult r : results) {
                if (!r.isSuccess()) {
                    List<Database.Error> errors = r.getErrors();
                    for (Database.Error e : errors) {
                        error += 'Error Save :' + e.getMessage() + ' ' + r.getId() + '\n';
                    }
                }
            }
            return error;
        }
        return null;
    }

    public static String getErrorMessage(List<Database.DeleteResult> results) {
        if (results != null) {
            String error = '';
            for (Database.DeleteResult r : results) {
                if (!r.isSuccess()) {
                    List<Database.Error> errors = r.getErrors();
                    for (Database.Error e : errors) {
                        error += 'Error Delete :' + e.getMessage() + ' ' + r.getId() + '\n';
                    }
                }
            }
            return error;
        }
        return null;
    }

    public static Boolean abortScheduledJob(String containName) {
        containName = '%' + containName + '%';
        List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
                                     FROM CronTrigger WHERE CronJobDetail.Name LIKE :containName];

        if (jobList.isEmpty()) {
            AppLogger.debug('BE8_GlobalUtility', 'abortScheduledJob', containName, containName + ' not found', null);
        }

        Boolean hasAbort = false;
        for (CronTrigger job : jobList) {
            if (job != null && job.Id != null) {
                System.abortJob(job.Id);
                hasAbort = true;
            }
        }
        return hasAbort;
    }

    public static Boolean abortScheduledJob(String containName, String state) {
        containName = '%' + containName + '%';
        List<CronTrigger> jobList = [SELECT Id, State, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType
                                     FROM CronTrigger WHERE CronJobDetail.Name LIKE :containName AND State = :state];

        if (jobList.isEmpty()) {
            AppLogger.debug('BE8_GlobalUtility', 'abortScheduledJob', containName, containName + ' not found', null);
        }

        Boolean hasAbort = false;
        for (CronTrigger job : jobList) {
            if (job != null && job.Id != null) {
                System.abortJob(job.Id);
                hasAbort = true;
            }
        }
        return hasAbort;
    }

    public static Set<String> abortScheduledJob(Set<String> containName) {
        Set<String> abortedJobs = new Set<String>();
        List<CronTrigger> jobList = CronTrigger_Repository.getInstance().getByName(containName);
        List<String> containNameList = new List<String>(containName);
        String referenceId = '';
        if (!containNameList.isEmpty()) {
            referenceId = containNameList.get(0) + '_' + containNameList.get(containNameList.size() - 1) + '_' + containNameList.size();
        }
        if (jobList.isEmpty()) {
            AppLogger.debug('BE8_GlobalUtility', 'abortScheduledJob', referenceId, containName + ' not found [set]', null);
        }

        for (CronTrigger job : jobList) {
            if (job != null && job.Id != null) {
                System.abortJob(job.Id);
                abortedJobs.add(job.CronJobDetail.Name);
            }
        }
        return abortedJobs;
    }

    @future
    public static void massDeleteJobs(List<ID> paramIDsToAbort) {
        Integer i = 0;
        while (i < 150 && paramIDsToAbort.size() > 0) {
            System.abortJob(paramIdsToAbort.remove(0));
            i++;
        }
        if (paramIDsToAbort.size() > 0) {
            BE8_GlobalUtility.massDeleteJobs(paramIDsToAbort);
        }
    }

    public static String getMsgBetween(String pMessage, String pStartText, String pEndText) {
        return pMessage.substring(pMessage.indexOf(pStartText) + pStartText.length(), pMessage.indexOf(pEndText));
    }

    public static Id getCrewIdByUserId(Id userId) {
        List<Crew_Mapping__c> crewMappingList = [SELECT Id, UserId__c, CrewId__c FROM Crew_Mapping__c WHERE UserId__c = :userId AND isActive__c = true ORDER BY CreatedDate DESC];
        if (crewMappingList.size() > 0) {
            Crew_Mapping__c crewMapping = crewMappingList.get(0);
            return crewMapping.CrewId__c;
        }
        return null;
    }

    public static Crew_Mapping__c getCurrentCrewMapping(Id userId) {
        List<Crew_Mapping__c> crewMappingList = [SELECT Id, UserId__c, CrewId__c, Last_Sync_Time__c FROM Crew_Mapping__c WHERE UserId__c = :userId AND isActive__c = true ORDER BY CreatedDate DESC];
        if (crewMappingList.size() > 0) {
            Crew_Mapping__c crewMapping = crewMappingList.get(0);
            return crewMapping;
        }
        return null;
    }

    public static void updateLastSyncTimeOfUser(DateTime syncTime, Id userId) {
        List<Crew_Mapping__c> crewMappingList = [SELECT Id, UserId__c, CrewId__c, Last_Sync_Time__c FROM Crew_Mapping__c WHERE UserId__c = :userId AND isActive__c = true ORDER BY CreatedDate DESC];
        if (crewMappingList.size() > 0) {
            Crew_Mapping__c crewMapping = crewMappingList.get(0);
            crewMapping.Last_Sync_Time__c = syncTime;
            update crewMapping;
        }
    }

    public static Set<Id> getFlightIdSetFromUserId(Id userId) {
        Id currentUserCrewId = BE8_GlobalUtility.getCrewIdByUserId(userId);
        List<Crew_List__c> crewList = [SELECT Id, FlightId__c FROM Crew_List__c WHERE CrewId__c = :currentUserCrewId AND FlightId__r.Landed__c = false AND FlightId__r.STD_UTC_DateTime__c != null AND FlightId__r.STA_UTC_DateTime__c != null ORDER BY FlightId__r.STD_UTC_DateTime__c ASC LIMIT 2];
        return BE8_GlobalUtility.getIdSet('FlightId__c', crewList);
    }

    // If data is NULL, replace with ''
    // If data is space, replace with ''
    public static String str(String data) {
        if (data == null) {
            return '';
        } else {
            return data.trim();
        }
    }

    public static String getObjectNameFromRecordIdPrefix(String recordIdOrPrefix) {
        String objectName = '';
        try {
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0, 3);
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();

            for (Schema.SObjectType stype : gd.values()) {
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();
                //System.debug('Prefix is ' + prefix);

                if (prefix != null && prefix.equals(myIdPrefix)) {
                    objectName = r.getName();
                    //System.debug('Object Name! ' + objectName);
                    break;
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
        return objectName;
    }

    public static String generateTransactionId() {
        return generateTransactionId(BE8_GlobalConstants.PREFIX_REQUEST_TRANSACTION_ID);
    }

    public static String generateTransactionId(String prefix) {
        return prefix + System.now().format('yyyyMMdd-HHmmss', 'Asia/Bangkok');
    }

    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static String xmlGenerator(String nodeName, String value) {
        return '<' + nodeName + '>' + value + '</' + nodeName + '>';
    }

    public static void sendEmail(String subject, String toEmails, String bodyMsg) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(toEmails.split(','));
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        mail.setPlainTextBody(bodyMsg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static String generateNonce() {
        Long randomLong = Crypto.getRandomLong();
        String nonce = EncodingUtil.base64Encode(Blob.valueOf(String.valueOf(randomLong)));
        if (nonce.length() > 28) {
            nonce = nonce.substring(0, 28);
        }
        return nonce;
    }

    public static Set<String> getFieldsFromFieldSet(List<Schema.FieldSet> fieldSets) {
        Set<String> customFieldSet = new Set<String>();
        for (Schema.FieldSet fieldSet : fieldSets) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                customFieldSet.add(field.getFieldPath());
            }
        }
        return customFieldSet;
    }

    public static Set<String> getFieldsFromFieldSet(String sObjectType, Set<String> fieldSetNameSet) {
        Map<String, Schema.FieldSet> fieldSetMap = Schema.getGlobalDescribe().get(sObjectType).getDescribe().fieldSets.getMap();

        Set<String> customFieldSet = new Set<String>();
        for (String fieldSetName : fieldSetNameSet) {
            for (Schema.FieldSetMember field : fieldSetMap.get(fieldSetName).getFields()) {
                customFieldSet.add(field.getFieldPath());
            }
        }

        return customFieldSet;
    }

    public static Integer randomWithLimit(Integer upperLimit) {
        Integer rand = Math.round(Math.random() * 1000);
        return Math.mod(rand, upperLimit);
    }

    public static void updateOverBookValueToCase(List<Flight__c> flightList){
        System.debug('JK: updateOverBookValueToCase - ' + JSON.serialize(flightList));
        for (Flight__c flight : flightList) {
            if (flight.Aircraft_Configuration__c != null && flight.Booking_Passengers__c != null) {
                Map<String, Integer> acconfigMap = getAircraftConfigMapByClass(flight.Aircraft_Configuration__c);
                Map<String, Integer> bookingpaxMap = getBookingPassengerMapByClass(acconfigMap, flight.Booking_Passengers__c);
                flight.Over_Booked_Amount_txt__c = getOverBook(acconfigMap, bookingpaxMap);
                updateAcConfigAndBookingPaxAmountToFlight(flight, acconfigMap, bookingpaxMap);
            } else {
                flight.Over_Booked_Amount_txt__c = null;
                Map<String, Integer> acconfigMap = new Map<String, Integer>();
                Map<String, Integer> bookingpaxMap = new Map<String, Integer>();
                if (flight.Aircraft_Configuration__c != null) {
                    updateAcConfigAndBookingPaxAmountToFlight(flight, getAircraftConfigMapByClass(flight.Aircraft_Configuration__c), bookingpaxMap);
                } else if (flight.Booking_Passengers__c != null) {
                    updateAcConfigAndBookingPaxAmountToFlight(flight, acconfigMap, getAircraftConfigMapByClass(flight.Booking_Passengers__c));
                }
            }
        }
    }

    public static Map<String, Integer> getAircraftConfigMapByClass(String acconfig) {
        Map<String, Integer> returnMap = new Map<String, Integer>();
        List<String> acconfigList = acconfig.split(' ');
        for (String str : acconfigList) {
            String cls = str.substring(0, 1);
            Integer amount = Integer.valueOf(str.substring(1, str.length()));
            System.debug('JK: class - ' + cls);
            System.debug('JK: amount - ' + amount);
            returnMap.put(cls, amount);
        }
        return returnmap;
    }

    public static Map<String, Integer> getBookingPassengerMapByClass(Map<String, Integer> acconfigMap, String bookingpax) {
        Map<String, Integer> returnMap = new Map<String, Integer>();
        Map<String, Integer> bookingpaxMap = getAircraftConfigMapByClass(bookingpax);
        for (String str : acconfigMap.keySet()) {
            if (bookingpaxMap.containsKey(str)) {
                returnMap.put(str, bookingpaxMap.get(str));
            }
            //else{
            //    returnMap.put(str, 0);
            //}
        }
        return returnMap;
    }

    public static String getOverBook(Map<String, Integer> acconfigMap, Map<String, Integer> bookingpaxMap) {
        String returnStr = '';
        Integer loopCount = 0;
        for (String str : acconfigMap.keySet()) {
            if (bookingpaxMap.containsKey(str)) {
                returnStr += acconfigMap.get(str) - bookingpaxMap.get(str) < 0 ? getOverBookFormat(str, (acconfigMap.get(str) - bookingpaxMap.get(str))) : getOverBookFormat(str, 0);
                returnStr += loopCount < acconfigMap.size() ? ' ' : '';
                loopCount++;
            }
        }
        System.debug('JK: overbook string - ' + returnStr);
        return returnStr;
    }

    public static void updateAcConfigAndBookingPaxAmountToFlight(Flight__c flight, Map<String, Integer> acconfigMap, Map<String, Integer> bookingpaxMap) {
        System.debug('JK: acconfigMap - ' + JSON.serialize(acconfigMap));
        System.debug('JK: bookingpaxMap - ' + JSON.serialize(bookingpaxMap));
        updateAcConfigToFlight(flight, acconfigMap);
        updateBookingPaxAmountToFlight(flight, bookingpaxMap);
    }

    public static void updateAcConfigToFlight(Flight__c flight, Map<String, Integer> acconfigMap) {
        flight.Aircraft_Configuration_First_Class__c = acconfigMap.containskey('F') ? acconfigMap.get('F') : 0;
        flight.Aircraft_Configuration_Business_Class__c = acconfigMap.containskey('C') ? acconfigMap.get('C') : 0;
        flight.Aircraft_Configuration_Premium_Economy__c = acconfigMap.containskey('U') ? acconfigMap.get('U') : 0;
        flight.Aircraft_Configuration_Economy_Class__c = acconfigMap.containskey('Y') ? acconfigMap.get('Y') : 0;
    }

    public static void updateBookingPaxAmountToFlight(Flight__c flight, Map<String, Integer> bookingpaxMap) {
        flight.Booking_Passenger_First_Class__c = bookingpaxMap.containskey('F') ? bookingpaxMap.get('F') : 0;
        flight.Booking_Passenger_Business_Class__c = bookingpaxMap.containskey('C') ? bookingpaxMap.get('C') : 0;
        flight.Booking_Passenger_Premium_Economy_Class__c = bookingpaxMap.containskey('U') ? bookingpaxMap.get('U') : 0;
        flight.Booking_Passenger_Economy_Class__c = bookingpaxMap.containskey('Y') ? bookingpaxMap.get('Y') : 0;
    }

    public static String getOverBookFormat(String cabinclass, Integer amount) {
        String amountformat = '';
        if (cabinclass == 'F' || cabinclass == 'C' || cabinclass == 'U') {
            if (String.valueOf(amount).remove('-').length() < 2) {
                amountformat = '0';
            }
        } else if (cabinclass == 'Y') {
            if (String.valueOf(amount).remove('-').length() < 3) {
                Integer loopamount = 3 - String.valueOf(amount).remove('-').length();
                for (Integer i = 0; i < loopamount; i++) {
                    amountformat += '0';
                }
            }
        }
        amountformat = String.valueOf(amount).contains('-') ? '-' + amountformat + String.valueOf(amount).remove('-') : amountformat + String.valueOf(amount);
        return cabinclass + amountformat;
    }

    public static String toCSVString(List<List<String>> datas) {
        String str = '';
        for (List<String> eachRow : datas) {
            str += String.join(eachRow, ',') + '\n';
        }
        return str;
    }

    public static String replaceCharToString(String sourceStr, String targetChar, String replaceStr) {
        if (targetChar.length() != 1) {
            return sourceStr;
        }
        String returnStr = '';
        Integer targetCharInt = targetChar.getChars()[0];
        List<Integer> chars = new List<Integer>();
        List<Integer> replaceChars = replaceStr.getChars();
        for (Integer i = 0; i < sourceStr.length(); i++) {
            if (sourceStr.charAt(i) == targetCharInt) {
                chars.addAll(replaceChars);
            } else {
                chars.add(sourceStr.charAt(i));
            }
        }
        return String.fromCharArray(chars);
    }

    public static String getSetToString(Set<String> setString){
        String returnStr = '';
        Integer loopcount = 1;
        if(setString != null && !setString.isEmpty()){
            for(String str : setString){
                returnStr += loopCount < setString.size() ? str + ', ' : str;
                loopcount++;
            }
        }
        return returnStr;
    }

    public static String replaceAll(String inputString, String removetxt, String replacetxt){
        if(inputString.contains(removetxt)){
            List<String> inputList = stringSplit(inputString, removetxt);
            return insertTargetintoString(inputList, replacetxt);
        }
        return inputString;

    }

    @testVisible
    private static List<String> stringSplit(String inputString, String target){
        List<String> returnList = new List<String>();
        while(inputString.contains(target)){
            String subString = inputString.substringBefore(target);
            inputString = inputString.substringAfter(target);
            returnList.add(subString);
            if(!inputString.contains(target)) returnList.add(inputString);
        }
        return returnList;
    }

    @testVisible
    private static String insertTargetintoString(List<String> inputString, String target){
        return String.join(inputString, target);
    }

    //public static Map<Id, sObject> getObjectWithAllFields(String objectName, Set<Id> objectIdSet) {
    //    SoqlBuilder soql = new SoqlBuilder(objectName);
    //    Set<String> fields = getAllCreateableFields(objectName);
    //    soql.addField(fields);
    //    soql.addCondition('Id', objectIdSet);
    //    System.debug('soql.getQueryStr()>>'+soql.getQueryStr());
    //    Map<Id, sObject> objMap = new Map<Id, sObject>(Database.query(soql.getQueryStr()));
    //    for(sObject obj : objMap.values()) {
    //        for(String field : fields) {
    //            if(obj.get(field) == null) {
    //                obj.put(field, null);
    //            }
    //        }
    //    }
    //    return objMap;
    //}

    //public static Map<Id, sObject> getObjectWithAllFields(String objectName, Set<Id> objectIdSet) {
    //    SoqlBuilder soql = new SoqlBuilder(objectName);
    //    Set<String> fields = getAllCreateableFields(objectName);
    //    soql.addField(fields);
    //    soql.addCondition('Id', objectIdSet);
    //    System.debug('soql.getQueryStr()>>'+soql.getQueryStr());
    //    Map<Id, sObject> objMap = new Map<Id, sObject>(Database.query(soql.getQueryStr()));
    //    for(sObject obj : objMap.values()) {
    //        for(String field : fields) {
    //            if(obj.get(field) == null) {
    //                obj.put(field, null);
    //            }
    //        }
    //    }
    //    return objMap;
    //} 

    public static Set<String> getAllCreateableFields(String objectName) {
        Set<String> fieldSet = new Set<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().Fields.getMap();
        for(Schema.SObjectField field : fieldMap.values()) {
            Schema.DescribeFieldResult describeField = field.getDescribe();
            if(describeField.isCreateable()) {
                fieldSet.add(describeField.getName());
            }
        }
        return fieldSet;
    }
}