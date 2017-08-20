/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description:   A global constants class for the project

History :
<Date>      <Authors Name>     <Brief Description of Change>
28/09/2016  Charnun.T           First Create
------------------------------------------------------------*/
public with sharing class BE8_GlobalConstants {
    public static final String DUMMY_FLIGHT_NAME = 'TGXXX';
    public static final String DOCUMENT_THAI_LOGO_EN = 'THAI_Logo';
    public static final String SFDC_THAI_LOCALE = 'th_TH';

    public static final String DEFAULT_TG_COMPANY = 'TG';

    public static final Integer JOB_QUEUE_LIMIT = 80;
    public static final Integer JOB_QUEUE_AGE_IN_DAYS = 1;

    public static final String PREFIX_REQUEST_TRANSACTION_ID = 'FB_SICSE';

    public static final Map<Integer, Boolean> INTEGER_TO_BOOLEAN = new Map<Integer, Boolean> {
        0 => false,
        1 => true
    };

    public static final Map<Boolean, Integer> BOOLEAN_TO_INTEGER = new Map<Boolean, Integer> {
        false => 0,
        true => 1
    };

    public static final String MEMBERSHIP_STATUS_ACTIVE = 'Active';
    public static final String MEMBERSHIP_STATUS_INACTIVE = 'Inactive';

    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';

    // SSR
    public static final Integer MAX_SSR_CODE = 5;
    public static final String SSR_TG_CARRIER = 'TG';
    public static final String SSR_CODE_BLND = 'BLND';
    public static final String SSR_CODE_DOCS = 'DOCS';
    public static final String SSR_CODE_FQTV = 'FQTV';
    public static final String SSR_CODE_SPML = 'SPML';
    public static final String SSR_CODE_XXML = '**ML';
    public static final String SSR_CODE_CTCM = 'CTCM';
    public static final String SSR_CODE_CTCE = 'CTCE';
    public static final String SSR_CODE_WCXX = 'WC**';
    public static final String SSR_CODE_MAAS = 'MAAS';
    public static final String SSR_CODE_LANG = 'LANG';
    public static final String SSR_CODE_WCHR = 'WCHR';
    public static final String SSR_CODE_UMNR = 'UMNR';
    public static final String SSR_CODE_DEAF = 'DEAF';
    public static final String SSR_CODE_MEDA = 'MEDA';
    public static final String SSR_CODE_DEPA = 'DEPA';
    public static final String SSR_CODE_DEPU = 'DEPU';
    public static final String SSR_CODE_AVIH = 'AVIH';
    public static final String SSR_CODE_PETC = 'PETC';
    public static final String SSR_CODE_WEAP = 'WEAP';
    public static final String SSR_CODE_CBBG = 'CBBG';
    public static final String SSR_CODE_EXST = 'EXST';
    public static final String SSR_CODE_COUR = 'COUR';
    public static final String SSR_CODE_INFT = 'INFT';
    public static final String SSR_CODE_CIP = 'CIP';
    public static final String SSR_CONFIRM = 'HK';
    public static final String SSR_NOT_CONFIRM = 'HN';
    //public static final String SSR_GURANTEED = '(Guaranteed)';
    //public static final String SSR_NOT_GURANTEED = '(Not Guaranteed)';
    public static final String SSR_GURANTEED = '(Confirmed)';
    public static final String SSR_NOT_GURANTEED = '(Not Confirmed)';

    public static final Integer SSR_DOCS_IDX_TRAVEL_DOC_TYPE = 0;
    public static final Integer SSR_DOCS_IDX_DOC_ISSUING_COUNTRY = 1;
    public static final Integer SSR_DOCS_IDX_DOC_NUMBER = 2;
    public static final Integer SSR_DOCS_IDX_NATIONALITY = 3;
    public static final Integer SSR_DOCS_IDX_DATE_OF_BIRTH = 4;
    public static final Integer SSR_DOCS_IDX_GENDER = 5;
    public static final Integer SSR_DOCS_IDX_DOC_EXPIRY_DATE = 6;
    public static final String SSR_MAAS_VIP = 'VIP';
    public static final String SSR_MAAS_VVIP = 'VVIP';

    // LOG_LEVEL
    public static final String LEVEL_DEBUG = 'Debug';
    public static final String LEVEL_ERROR = 'Error';
    public static final String LEVEL_INFO = 'Info';
    public static final String LEVEL_WARNING = 'Warning';

    //public static final Integer WS_CALLOUT_LIMIT = 100;
    //public static final Integer WS_ROP_CALLOUT_COUNT = 3;

    public static final Integer WS_CALLOUT_LIMIT = 10;
    public static final Integer WS_ROP_CALLOUT_COUNT = 2;
    public static final Integer WS_DEFAULT_TIMEOUT = 120000;

    public static final String DATE_FORMAT_FOR_HASHING = 'yyyy-MM-dd HH:mm:ss.SSS';
    public static final String DATE_FORMAT_FOR_PAX_FLIGHT_DATE = 'yyyyMMDD';
    public static final String DATE_FORMAT_FOR_GET_FLIGHT = 'ddMMMYY';
    public static final String DATE_FORMAT_FOR_GET_FLIGHT_SERVICE = 'yyyy-MM-dd';
    public static final String SCHEDULER_FORMAT = 'mm/HH/dd/MM/yyyy';

    // Custom setting passenger
    public static final String SETTING_PAX_REQ_TXN_ID = 'PAX_REQ_TXN_ID';
    public static final String SETTING_PAX_SVC_VER = 'PAX_SVC_VER';
    public static final String SETTING_PAX_MW_TXN_ID = 'PAX_MW_TXN_ID';
    public static final String SETTING_PAX_REQ_ID = 'PAX_REQ_ID';
    public static final String SETTING_PAX_REQ_PWD = 'PAX_REQ_PWD';
    public static final String SETTING_PAX_REQ_USER_ID = 'PAX_REQ_USER_ID';
    public static final String SETTING_PAX_ENDPOINT = 'PAX_ENDPOINT';
    public static final String SETTING_PAX_USERNAME = 'PAX_USERNAME';
    public static final String SETTING_PAX_PASSWORD = 'PAX_PASSWORD';
    public static final String SETTING_PAX_TIMEOUT = 'PAX_TIMEOUT';

    // Custom setting ROP Mileage
    public static final String SETTING_ROP_REQ_ID = 'ROP_REQ_ID';
    public static final String SETTING_ROP_REQ_PWD = 'ROP_REQ_PWD';
    public static final String SETTING_ROP_REQ_USER_ID = 'ROP_REQ_USER_ID';
    public static final String SETTING_ROP_ENDPOINT = 'ROP_ENDPOINT';
    public static final String SETTING_ROP_ENROLLMENT_ENDPOINT = 'ROP_ENROLLMENT_ENDPOINT';
    public static final String SETTING_ROP_MILEAGE_ENDPOINT = 'ROP_MILEAGE_ENDPOINT';
    public static final String SETTING_ROP_USERNAME = 'ROP_USERNAME';
    public static final String SETTING_ROP_PASSWORD = 'ROP_PASSWORD';
    public static final String SETTING_ROP_TIMEOUT = 'ROP_TIMEOUT';
    public static final String SETTING_ROPAP_ENDPOINT = 'ROPAP_ENDPOINT';
    public static final String SETTING_ROPAP_USERNAME = 'ROPAP_USERNAME';
    public static final String SETTING_ROPAP_PASSWORD = 'ROPAP_PASSWORD';
    public static final String SETTING_ROPAP_TIMEOUT  = 'ROPAP_TIMEOUT';

    // Custom setting ROP
    public static final String SETTING_ROP_REQ_TXN_ID = 'ROP_REQ_TXN_ID';
    public static final String SETTING_ROP_SVC_VER = 'ROP_SVC_VER';
    public static final String SETTING_ROP_MW_TXN_ID = 'ROP_MW_TXN_ID';
    public static final String SETTING_ROP_IS_LAST_TXN = 'ROP_IS_LAST_TXN';
    //public static final String SETTING_ROP_REQ_ID = 'ROP_REQ_ID';
    //public static final String SETTING_ROP_REQ_PWD = 'ROP_REQ_PWD';
    //public static final String SETTING_ROP_REQ_USER_ID = 'ROP_REQ_USER_ID';
    //public static final String SETTING_ROP_ENDPOINT = 'ROP_ENDPOINT';
    //public static final String SETTING_ROP_USERNAME = 'ROP_USERNAME';
    //public static final String SETTING_ROP_PASSWORD = 'ROP_PASSWORD';
    //public static final String SETTING_ROP_TIMEOUT = 'ROP_TIMEOUT';
    //public static final String SETTING_ROPAP_ENDPOINT = 'ROPAP_ENDPOINT';
    //public static final String SETTING_ROPAP_USERNAME = 'ROPAP_USERNAME';
    //public static final String SETTING_ROPAP_PASSWORD = 'ROPAP_PASSWORD';
    //public static final String SETTING_ROPAP_TIMEOUT  = 'ROPAP_TIMEOUT';

    // Custom setting ROP Additional Profile
    public static final String SETTING_ROPADD_REQ_TXN_ID = 'ROPADD_REQ_TXN_ID';
    public static final String SETTING_ROPADD_SVC_VER = 'ROPADD_SVC_VER';
    public static final String SETTING_ROPADD_MW_TXN_ID = 'ROPADD_MW_TXN_ID';
    public static final String SETTING_ROPADD_REQ_ID = 'ROPADD_REQ_ID';
    public static final String SETTING_ROPADD_REQ_PWD = 'ROPADD_REQ_PWD';
    public static final String SETTING_ROPADD_REQ_USER_ID = 'ROPADD_REQ_USER_ID';
    public static final String SETTING_ROPADD_ENDPOINT = 'ROPADD_ENDPOINT';
    public static final String SETTING_ROPADD_USERNAME = 'ROPADD_USERNAME';
    public static final String SETTING_ROPADD_PASSWORD = 'ROPADD_PASSWORD';
    public static final String SETTING_ROPADD_TIMEOUT = 'ROPADD_TIMEOUT';

    // Custom setting LOPA
    public static final String SETTING_LOPA_REQ_TXN_ID = 'LOPA_REQ_TXN_ID';
    public static final String SETTING_LOPA_SVC_VER = 'LOPA_SVC_VER';
    public static final String SETTING_LOPA_MW_TXN_ID = 'LOPA_MW_TXN_ID';
    public static final String SETTING_LOPA_REQ_ID = 'LOPA_REQ_ID';
    public static final String SETTING_LOPA_REQ_PWD = 'LOPA_REQ_PWD';
    public static final String SETTING_LOPA_REQ_USER_ID = 'LOPA_REQ_USER_ID';
    public static final String SETTING_LOPA_ENDPOINT = 'LOPA_ENDPOINT';
    public static final String SETTING_LOPA_USERNAME = 'LOPA_USERNAME';
    public static final String SETTING_LOPA_PASSWORD = 'LOPA_PASSWORD';
    public static final String SETTING_LOPA_TIMEOUT = 'LOPA_TIMEOUT';

    // Custom setting Cabin Report
    public static final String SETTING_CABINRPT_REQ_TXN_ID = 'CABINRPT_REQ_TXN_ID';
    public static final String SETTING_CABINRPT_SVC_VER = 'CABINRPT_SVC_VER';
    public static final String SETTING_CABINRPT_MW_TXN_ID = 'CABINRPT_MW_TXN_ID';
    public static final String SETTING_CABINRPT_REQ_ID = 'CABINRPT_REQ_ID';
    public static final String SETTING_CABINRPT_REQ_PWD = 'CABINRPT_REQ_PWD';
    public static final String SETTING_CABINRPT_REQ_USER_ID = 'CABINRPT_REQ_USER_ID';
    public static final String SETTING_CABINRPT_ENDPOINT = 'CABINRPT_ENDPOINT';
    public static final String SETTING_CABINRPT_USERNAME = 'CABINRPT_USERNAME';
    public static final String SETTING_CABINRPT_PASSWORD = 'CABINRPT_PASSWORD';
    public static final String SETTING_CABINRPT_TIMEOUT = 'CABINRPT_TIMEOUT';

    // Cabin Log
    public static final String SETTING_SAP_REQ_TXN_ID = 'SAP_REQ_TXN_ID';
    public static final String SETTING_SAP_SVC_VER = 'SAP_SVC_VER';
    public static final String SETTING_SAP_MW_TXN_ID = 'SAP_MW_TXN_ID';
    public static final String SETTING_SAP_REQ_ID = 'SAP_REQ_ID';
    public static final String SETTING_SAP_REQ_PWD = 'SAP_REQ_PWD';
    public static final String SETTING_SAP_REQ_USER_ID = 'SAP_REQ_USER_ID';
    public static final String SETTING_SAP_ENDPOINT = 'SAP_ENDPOINT';
    public static final String SETTING_SAP_USERNAME = 'SAP_USERNAME';
    public static final String SETTING_SAP_PASSWORD = 'SAP_PASSWORD';
    public static final String SETTING_SAP_TIMEOUT = 'SAP_TIMEOUT';

    // Custom setting Flight
    public static final String SETTING_FLIGHT_USERNAME = 'FLIGHT_USERNAME';
    public static final String SETTING_FLIGHT_PASSWORD = 'FLIGHT_PASSWORD';
    public static final String SETTING_FLIGHT_ENDPOINT = 'FLIGHT_ENDPOINT';
    public static final String SETTING_FLIGHT_REQ_TXN_ID = 'FLIGHT_REQ_TXN_ID';
    public static final String SETTING_FLIGHT_REQ_ID = 'FLIGHT_REQ_ID';
    public static final String SETTING_FLIGHT_USER_ID = 'FLIGHT_REQ_USER_ID';
    public static final String SETTING_FLIGHT_MW_TXN_ID = 'FLIGHT_MW_TXN_ID';
    public static final String SETTING_FLIGHT_SVC_VER = 'FLIGHT_SVC_VER';

    public static final String PAX_DOC_TYPE_PASSPORT = 'P';

    public static final String ACCOUNT_GENDER_MALE = 'M';
    public static final String ACCOUNT_GENDER_FEMALE = 'F';
    public static final Map<String, String> MAP_ACCOUNT_GENDER = new Map<String, String> {'M' => 'Male', 'F' => 'Female'};
    public static final Map<String, String> MAP_ROP_STATUS = new Map<String, String> {'AC' => 'Active', '?I' => 'Inactive', '?D' => 'Dead', '?C' => 'Closed', '?M' => 'Merge'};
    public static final Map<String, String> MAP_ROP_MARITIAL = new Map<String, String> {'S' => 'Single', 'M' => 'Marriage', 'D' => 'Divorced'};
    public static final Map<String, String> MAP_ROP_OCCUPATION = new Map<String, String> {
        'J1' => 'Bussiness',
        'J2' => 'Government Official',
        'J3' => 'Technician',
        'J4' => 'Sales/Marketing',
        'J5' => 'Self Employed',
        'J6' => 'Retired',
        'J7' => 'Student',
        'J8' => 'Unemployed',
        'J9' => 'Others'
    };

    public static final Integer MAX_ROP_CALLOUT = 30;

    public static final String AIRCRAFT_CLASS_Y = 'Y';
    public static final String AIRCRAFT_CLASS_C = 'C';
    public static final String AIRCRAFT_CLASS_F = 'F';
    public static final String AIRCRAFT_CLASS_U = 'U';

    public static final String SOURCE_DATA_WEB_SERVICE = 'WEB_SERVICE';

    public static final String EMAIL_TEMPLATE_EMERGENCY = 'EmergencyEmailTemplatePage';
    public static final String EMAIL_TYPE_EMERGENCY_CASE = 'Emergency Case';

    public static final String WS_TIME_OUT_CASE = 'Read timed out';
    public static final String WS_SERVICE_UNAVAILABLE_CASE = '503';
    public static final String WS_DATABASE_UNAVAILABLE_CASE = '504';
    public static final String WS_INCORRECT_USER_PASS_CASE = '401';
    public static final String WS_URI_UNAVAILABLE_CASE = '404';

    /*public static final Integer SEGMENT_SE_MAX_SALE_SIZE = 40000000;
    public static final Double SEGMENT_CB_MAX_SALE_SIZE = 5000000000.00;

    public static final String NORMAL_TASK = 'NormalTask';
    public static final String COMPLETED_TASK = 'Completed_Task';

    public static final String TARGET_LIST_TYPE = 'Target_List__c';*/

    /* Crew on Flight */
    public static final String SETTING_CREW_ON_FLIGHT_ENDPOINT = 'CREW_ON_FLIGHT_ENDPOINT';
    public static final String SETTING_CREW_ON_FLIGHT_USERNAME = 'CREW_ON_FLIGHT_USERNAME';
    public static final String SETTING_CREW_ON_FLIGHT_PASSWORD = 'CREW_ON_FLIGHT_PASSWORD';
    public static final String WS_REQUIRED_TXN_ID = 'CREW_ON_FLIGHT_REQ_TXN_ID';
    public static final String WS_SCV_VERSION = 'CREW_ON_FLIGHT_SVC_VER';
    public static final String WS_REQUIRED_ID = 'CREW_ON_FLIGHT_REQ_ID';
    public static final String WS_REQUIRED_PASSWORD = 'CREW_ON_FLIGHT_REQ_PWD';
    public static final String WS_USER_ID = 'CREW_ON_FLIGHT_USER_ID';
    public static final String MW_TXN_ID = 'CREW_ON_FLIGHT_MW_TXN_ID';

    public static final String SETTING_TG_BASEURL = 'TG_BASEURL';

    public static final String SETTING_CREW_DUTY_ASSIGNMENT_ENDPOINT = 'CREW_DUTY_ASSIGNMENT_ENDPOINT';
    public static final String SETTING_CREW_DUTY_ASSIGNMENT_USERNAME = 'CREW_DUTY_ASSIGNMENT_USERNAME';
    public static final String SETTING_CREW_DUTY_ASSIGNMENT_PASSWORD = 'CREW_DUTY_ASSIGNMENT_PASSWORD';
    public static final String SETTING_CREW_DUTY_ASSIGNMENT_REQ_TXN_ID = 'CREW_DUTY_ASSIGNMENT_REQ_TXN_ID';
    public static final String SETTING_CREW_DUTY_ASSIGNMENT_SVC_VER = 'CREW_DUTY_ASSIGNMENT_SVC_VER';
    public static final String SETTING_CREW_DUTY_ASSIGNMENT_REQ_ID = 'CREW_DUTY_ASSIGNMENT_REQ_ID';

    public static final String SETTING_NEW_PAX_LIST_ENDPOINT = 'NEW_PAX_LIST_ENDPOINT';
    public static final String SETTING_NEW_PAX_LIST_USERNAME = 'NEW_PAX_LIST_USERNAME';
    public static final String SETTING_NEW_PAX_LIST_PASSWORD = 'NEW_PAX_LIST_PASSWORD';
    public static final String SETTING_NEW_PAX_LIST_REQ_TXN_ID = 'NEW_PAX_LIST_REQ_TXN_ID';
    public static final String SETTING_NEW_PAX_LIST_MW_TXN_ID = 'NEW_PAX_LIST_MW_TXN_ID';
    public static final String SETTING_NEW_PAX_LIST_SVC_VER = 'NEW_PAX_LIST_SVC_VER';
    public static final String SETTING_NEW_PAX_LIST_REQ_PWD = 'NEW_PAX_LIST_REQ_PWD';
    public static final String SETTING_NEW_PAX_LIST_REQ_USER_ID = 'NEW_PAX_LIST_REQ_USER_ID';
    public static final String SETTING_NEW_PAX_LIST_REQ_ID = 'NEW_PAX_LIST_REQ_ID';
    public static final String SETTING_NEW_PAX_LIST_TIMEOUT = 'NEW_PAX_LIST_TIMEOUT';

    public static final String SETTING_SUBMIT_CREWAPPRAISAL_ENDPOINT = 'SUBMIT_CREWAPPRAISAL_ENDPOINT';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_USERNAME = 'SUBMIT_CREWAPPRAISAL_USERNAME';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_PASSWORD = 'SUBMIT_CREWAPPRAISAL_PASSWORD';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_REQ_TXN_ID = 'SUBMIT_CREWAPPRAISAL_REQ_TXN_ID';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_MW_TXN_ID = 'SUBMIT_CREWAPPRAISAL_MW_TXN_ID';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_SVC_VER = 'SUBMIT_CREWAPPRAISAL_SVC_VER';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_REQ_PWD = 'SUBMIT_CREWAPPRAISAL_REQ_PWD';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_REQ_USER_ID = 'SUBMIT_CREWAPPRAISAL_REQ_USER_ID';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_REQ_ID = 'SUBMIT_CREWAPPRAISAL_REQ_ID';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_TIMEOUT = 'SUBMIT_CREWAPPRAISAL_TIMEOUT';
    public static final String SETTING_SUBMIT_CREWAPPRAISAL_PREFIX_REQ_TXN_ID = 'SUBMIT_CREWAPPRAISAL_PREFIX_REQ_TXN_ID';

    public static final String USER_INTEGRATION_NAME = 'System Integration';
    public static final Set<String> USER_INTEGRATION_SET = new Set<String> {'System Integration', 'Custom System Administrator', 'System Administrator', 'TG System Administrator'};

    /* Case Channel */
    public static final String CASE_CHANNEL_IN_FLIGHT = 'In-flight';

    /* Case Priority */
    public static final String CASE_PRIORITY_MEDIUM = 'Medium';
    public static final String CASE_PRIORITY_URGENT = 'Urgent';

    /* Case Impact */
    public static final String CASE_IMPACT_MEDIUM = 'Medium';
    public static final String CASE_IMPACT_URGENT = 'Urgent';

    /* Incident Type */
    public static final String INCIDENT_TYPE_GENERAL = 'General';
    public static final String INCIDENT_TYPE_EMERGENCY = 'Emergency';

    /* Incident Category Mobile */
    public static final String INCIDENT_CATEGORY_MOBILE_EMERGENCY = '6';

    /* Case Log Type */
    public static final Integer CASE_LOG_TYPE_CABIN_LOG_INTEGER = 21;
    public static final Integer CASE_LOG_TYPE_DECK_LOG_INTEGER = 22;
    public static final String CASE_LOG_TYPE_CABIN_LOG = 'Cabin Log';
    public static final String CASE_LOG_TYPE_DECK_LOG = 'Flight Log';
    public static final Map<String, Integer> CASE_LOG_TYPE_MAP_STRING_TO_INTEGER = new Map<String, Integer> {
        CASE_LOG_TYPE_CABIN_LOG => CASE_LOG_TYPE_CABIN_LOG_INTEGER,
        CASE_LOG_TYPE_DECK_LOG => CASE_LOG_TYPE_DECK_LOG_INTEGER
    };
    public static final Map<Integer, String> CASE_LOG_TYPE_MAP_INTEGER_TO_STRING = new Map<Integer, String> {
        CASE_LOG_TYPE_CABIN_LOG_INTEGER => CASE_LOG_TYPE_CABIN_LOG,
        CASE_LOG_TYPE_DECK_LOG_INTEGER => CASE_LOG_TYPE_DECK_LOG
    };

    /* Case Status */
    public static final String CASE_STATUS_PENDING = 'Pending';
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_OPEN = 'Open';
    public static final String CASE_STATUS_ESCALATED = 'Escalated';
    public static final String CASE_STATUS_VOID = 'Void';
    public static final String CASE_STATUS_RESOLVED = 'Resolved';
    public static final String CASE_STATUS_DUPLICATE = 'Duplicate';
    public static final Map<Integer, String> INTEGER_TO_CASE_STATUS_FOR_MAINTENANCE_MAP = new Map<Integer, String> {
        1 => CASE_STATUS_OPEN,
        2 => CASE_STATUS_RESOLVED,
        3 => CASE_STATUS_CLOSED
    };
    public static final Map<String, Integer> CASE_STATUS_TO_INTEGER_MAP = new Map<String, Integer> {
        CASE_STATUS_OPEN => 1,
        CASE_STATUS_ESCALATED => 1,
        CASE_STATUS_RESOLVED => 2,
        CASE_STATUS_CLOSED => 3
    };
    public static final Map<Integer, String> INTEGER_TO_CASE_STATUS_FOR_INFLIGHT_MAP = new Map<Integer, String> {
        1 => CASE_STATUS_ESCALATED,
        2 => CASE_STATUS_RESOLVED,
        3 => CASE_STATUS_CLOSED
    };

    public static final String EMERGENCY_TYPE_PASSENGER_DECEASE = 'Passenger Decease';
    public static final Integer EMERGENCY_TYPE_PASSENGER_DECEASE_INTEGER = 10;
    public static final String EMERGENCY_TYPE_CREW_DECEASE = 'Crew Decease';
    public static final Integer EMERGENCY_TYPE_CREW_DECEASE_INTEGER = 11;
    public static final String EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY = 'Severe Passenger Injury';
    public static final Integer EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY_INTEGER = 12;
    public static final String EMERGENCY_TYPE_SEVERE_CREW_INJURY = 'Severe Crew Injury';
    public static final Integer EMERGENCY_TYPE_SEVERE_CREW_INJURY_INTEGER = 13;
    public static final String EMERGENCY_TYPE_SEVERE_TURBULENCE = 'Severe Turbulence';
    public static final Integer EMERGENCY_TYPE_SEVERE_TURBULENCE_INTEGER = 14;
    public static final String EMERGENCY_TYPE_SLIDER_DEPLOYMENT = 'Slide Deployment';
    public static final Integer EMERGENCY_TYPE_SLIDER_DEPLOYMENT_INTEGER = 15;
    public static final Map<Integer, String> INTEGER_TO_EMERGENCY_TYPE_MAP = new Map<Integer, String> {
        EMERGENCY_TYPE_PASSENGER_DECEASE_INTEGER => EMERGENCY_TYPE_PASSENGER_DECEASE,
        EMERGENCY_TYPE_CREW_DECEASE_INTEGER => EMERGENCY_TYPE_CREW_DECEASE,
        EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY_INTEGER => EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY,
        EMERGENCY_TYPE_SEVERE_CREW_INJURY_INTEGER => EMERGENCY_TYPE_SEVERE_CREW_INJURY,
        EMERGENCY_TYPE_SEVERE_TURBULENCE_INTEGER => EMERGENCY_TYPE_SEVERE_TURBULENCE,
        EMERGENCY_TYPE_SLIDER_DEPLOYMENT_INTEGER => EMERGENCY_TYPE_SLIDER_DEPLOYMENT
    };
    public static final Map<String, Integer> EMERGENCY_TYPE_TO_INTEGER_MAP = new Map<String, Integer> {
        EMERGENCY_TYPE_PASSENGER_DECEASE => EMERGENCY_TYPE_PASSENGER_DECEASE_INTEGER,
        EMERGENCY_TYPE_CREW_DECEASE => EMERGENCY_TYPE_CREW_DECEASE_INTEGER,
        EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY => EMERGENCY_TYPE_SEVERE_PASSENGER_INJURY_INTEGER,
        EMERGENCY_TYPE_SEVERE_CREW_INJURY => EMERGENCY_TYPE_SEVERE_CREW_INJURY_INTEGER,
        EMERGENCY_TYPE_SEVERE_TURBULENCE => EMERGENCY_TYPE_SEVERE_TURBULENCE_INTEGER,
        EMERGENCY_TYPE_SLIDER_DEPLOYMENT => EMERGENCY_TYPE_SLIDER_DEPLOYMENT_INTEGER
    };

    /* Case Record Type Name */
    public static final String CASE_RECORD_TYPE_MAINTENANCE = 'Maintenance';
    public static final String CASE_RECORD_TYPE_NEW_MAINTENANCE = 'New_Maintenance';
    public static final String CASE_RECORD_TYPE_VOID_MAINTENANCE = 'Void_Maintenance';
    public static final String CASE_RECORD_TYPE_IN_FLIGHT = 'In_Flight';

    /* Case Group Member Record Type Name */
    public static final String CASE_GROUP_MEMBER_RECORD_TYPE_GROUND_SERVICE = 'Ground_Service_CGM';
    public static final String IN_FLIGHT_COMPENSATION_RECORD_TYPE = 'In_flight_Compensation';

    /* Compensation Record Type Name */
    public static final String COMPENSATION_RECORD_TYPE = 'CFMS_Compensation';

    // Case Group Member
    public static final String IMPACT_SERVICABLE = 'Serviceable';
    public static final String IMPACT_MALFUNCTION = 'Malfunction';
    public static final String IMPACT_BLOCK = 'Block';
    public static final String IMPACT_COMPLETE = 'Complete';

    // Passenger WS
    public static final String FFP_TIER_GOLD = 'GOLD';
    public static final String FFP_TIER_PLATINUM = 'PLAT';

    // Job Name
    public static final String JOB_80H_BF_TAKEOFF = '80H_BF_TAKEOFF';
    public static final String JOB_24H_BF_TAKEOFF = '24H_BF_TAKEOFF';
    public static final String JOB_8H_BF_TAKEOFF = '8H_BF_TAKEOFF';
    public static final String JOB_3H_BF_TAKEOFF = '3H_BF_TAKEOFF';
    public static final String JOB_3H_1H_PERIOD_BF_TAKEOFF = '3H_1H_PERIOD_BF_TAKEOFF';
    public static final String JOB_1H_PERIOD_BF_TAKEOFF = '1H_PERIOD_BF_TAKEOFF';
    public static final String JOB_2H_BF_TAKEOFF = '2H_BF_TAKEOFF';
    public static final String JOB_30M_BF_TAKEOFF = '30M_BF_TAKEOFF';
    public static final String JOB_25M_BF_TAKEOFF = '25M_BF_TAKEOFF';

    public static final String JOB_1H_PERIOD_BF_LANDING = '1H_PERIOD_BF_LANDING';
    public static final String JOB_1H_BF_LANDING = '1H_BF_LANDING';
    public static final String JOB_1H_AF_LANDING = '1H_AF_LANDING';
    public static final String MANUAL_JOB = 'MANUAL_JOB';

    // LOPA Status
    /*
        @All Status of Seat :
        1. Occupied
        2. Available
        3. Blocked
        4. Malfunction
        5. Occupied + Gold
        6. Occupied + Platinum
        7. Block + Gold
        8. Block + Platinum
        9. Block Occupied
        10. Malfunction + Gold
        11. Malfunction + Platinum
        12. Malfunction + Occupied
        13. Blocked from LOPA
    */
    public static final String LOPA_STATUS_OCCUPIED = '1';
    public static final String LOPA_STATUS_AVAILABLE = '2';
    public static final String LOPA_STATUS_BLOCK = '3';
    public static final String LOPA_STATUS_MALFUNCTION = '4';
    public static final String LOPA_STATUS_OCCUPIED_GOLD = '5';
    public static final String LOPA_STATUS_OCCUPIED_PLATINUM = '6';
    public static final String LOPA_STATUS_BLOCK_GOLD = '7';
    public static final String LOPA_STATUS_BLOCK_PLATINUM = '8';
    public static final String LOPA_STATUS_BLOCK_OCCUPIED = '9';
    public static final String LOPA_STATUS_MALFUNCTION_GOLD = '10';
    public static final String LOPA_STATUS_MALFUNCTION_PLATINUM = '11';
    public static final String LOPA_STATUS_MALFUNCTION_OCCUPIED = '12';
    public static final String LOPA_STATUS_BLOCKED_FROM_LOPA = '13';

    // LOPA
    public static final String FIRST_CLASS = 'F';
    public static final String BUSINESS_CLASS = 'C';
    public static final String ECONOMY_CLASS = 'Y';
    public static final String PREMIUM_ECONOMY_CLASS = 'U';

    public static final String AISLE_SEAT = 'A';
    public static final String AISLE_SEAT_CODE = '*A*';
    public static final String NO_SEAT = '8';
    public static final String NO_ROW = 'Z';
    public static final String BLOCKED_SEAT = 'Z';

    public static final String TYPE_SEAT = 'seat';
    public static final String TYPE_LAVATORY = 'LA';
    public static final String TYPE_GALLEY = 'G';
    public static final String TYPE_GALLEY_IN_SEAT_ROW = 'GN';

    public static final String LOWER_DECK = 'L';
    public static final String MAIN_DECK = 'M';
    public static final String UPPER_DECK = 'U';

    public static final String OCCUPIED = '1';
    public static final String AVAILABLE = '2';

    public static final Map<String, String> TRAVEL_CLASS_MAP = new Map<String, String> {FIRST_CLASS => 'First', ECONOMY_CLASS => 'Economy', BUSINESS_CLASS => 'Business'};
    public static final Map<String, String> FLOOR_MAP = new Map<String, String> {LOWER_DECK => 'Lower Deck', MAIN_DECK => 'Main Deck', UPPER_DECK => 'Upper Deck'};

    public static final Set<String> SEAT_CHARACTERISTICS_NO_SEAT = new Set<String> {'701', '8', 'AR', 'BA', 'C', 'CL', 'EX', 'GN', 'LA', 'LG', 'SO', 'ST', 'TA'};
    public static final Set<String> SEAT_OCCUPATION_BLOCKED_SEAT = new Set<String> {'D', 'Q', 'Z'};

    /* variable to handle crewId set that used to prevent purge operation */
    public static Set<Id> CREW_LIST_ID = new Set<Id>();

    /* Crew Rank */
    public static final String CREW_RANK_CAPTAIN = 'FC';
    public static final String CREW_RANK_AIR_PURSER = 'AP';

    /* Cabin Report Incident Description */
    public static final Map<String, String> CABIN_REPORT_INCIDENT_DESCRIPTION = new Map<String, String> {
        '' => '08030801-General Case',
        'Severe Turbulence' => '15100101 -Severe Turbulence',
        'Slide Deployment' => '15100201 -Slide Deployment',
        'Passenger Decease' => '15060101 -Pax Decease',
        'Crew Decease' => '15060201-Crew Decease'
    };

    public static final Map<String, String> CABIN_REPORT_INCIDENT_DESCRIPTION_WITHOUT_NO = new Map<String, String> {
        '' => 'General Case',
        'Severe Turbulence' => 'Severe Turbulence',
        'Slide Deployment' => 'Slide Deployment',
        'Passenger Decease' => 'Pax Decease',
        'Crew Decease' => 'Crew Decease',
        'Servere Passenger Injury' => 'Servere Passenger Injury',
        'Servere Crew Injury' => 'Servere Crew Injury'
    };

    public static final Map<String, String> INCIDENT_CATEGORY = new Map<String, String> {
        '1' => 'Passenger',
        '2' => 'Service Equipment',
        '3' => 'Safety Equipment',
        '4' => 'Aircraft Maintenance',
        '5' => 'Other',
        '6' => 'Emergency',
        '7' => 'All'
    };

    public static final Map<String, String> EMERGENCY_TYPE = new Map<String, String> {
        '' => 'General Case',
        '10' => 'Passenger Decease',
        '11' => 'Crew Decease',
        '12' => 'Severe Passenger Injury',
        '13' => 'Severe Crew Injury',
        '14' => 'Severe Turbulence',
        '15' => 'Slide Deployment'
    };

    public static final Map<String, String> CABIN_REPORT_TYPE = new Map<String, String> {
        'Commendation' => 'CMD',
        'Complaint' => 'CMP',
        'Suggestion' => 'SUG',
        'Information' => 'INF'
    };
    public static final String CASE_TYPE_INFORMATION = 'Information';

    /* Master Map */
    public static String SERVICE_EQUIPMENT = 'SERVICE EQUIPMENT';

    /* Country code - name mapping */
    public static final Map<String, String> COUNTRY_CODE_NAME = new Map<String, String> {
        'HU' => 'Hungary',
        'ID' => 'Indonesia',
        'IE' => 'Ireland',
        'IL' => 'Israel',
        'IN' => 'India',
        'IO' => 'British Indian Ocean Territory',
        'IQ' => 'Iraq',
        'IR' => 'Iran',
        'IS' => 'Iceland',
        'IT' => 'Italy',
        'JM' => 'Jamaica',
        'JP' => 'Japan',
        'KE' => 'Kenya',
        'KG' => 'Kyrgyzstan',
        'KH' => 'Cambodia',
        'KI' => 'Kiribati',
        'KM' => 'Comoros',
        'KN' => 'Saint Kitts and Nevis',
        'KP' => 'Korea North',
        'KR' => 'Korea South',
        'KW' => 'Kuwait',
        'KY' => 'Cayman Isl.',
        'KZ' => 'Kazakhstan',
        'LA' => 'Lao P.Dem.Rep.',
        'LB' => 'Lebanon',
        'LC' => 'St.lucia',
        'LK' => 'Sri Lanka',
        'LR' => 'Liberia',
        'LS' => 'Lesotho',
        'LT' => 'Lithuania',
        'LU' => 'Luxembourg',
        'LV' => 'Latvia',
        'LY' => 'Libya',
        'MA' => 'Morocco',
        'MC' => 'Monaco',
        'MD' => 'Moldova',
        'MG' => 'Madagascar',
        'MH' => 'Marshall Islands',
        'MK' => 'Macedonia',
        'ML' => 'Mali',
        'MM' => 'Myanmar',
        'MN' => 'Mongolia',
        'MO' => 'Macau',
        'MP' => 'Northern Mariana Islands',
        'MQ' => 'Martinique',
        'MR' => 'Mauritania',
        'MS' => 'Montserrat',
        'MT' => 'Malta',
        'MV' => 'Maldives',
        'MW' => 'Malawi',
        'MX' => 'Mexico',
        'MY' => 'Malaysia',
        'MZ' => 'Mozambique',
        'NA' => 'Namibia',
        'NC' => 'New Caledonia',
        'NE' => 'Niger',
        'NF' => 'Norfolk Island',
        'NG' => 'Nigeria',
        'NI' => 'Nicaragua',
        'NL' => 'Netherlands',
        'NO' => 'Norway',
        'NP' => 'Nepal',
        'NR' => 'Nauru',
        'NU' => 'Niue',
        'OM' => 'Oman',
        'PA' => 'Panama',
        'PE' => 'Peru',
        'PF' => 'French Polynesia',
        'PH' => 'Philippines',
        'PK' => 'Pakistan',
        'PL' => 'Poland',
        'PN' => 'Pitcairn',
        'PR' => 'Puerto Rico',
        'PS' => 'Palestine',
        'PT' => 'Portugal',
        'PW' => 'Palau',
        'PY' => 'Paraguay',
        'QA' => 'Qatar',
        'RE' => 'Reunion',
        'RO' => 'Romania',
        'RS' => 'Serbia',
        'RU' => 'Russia',
        'RW' => 'Rwanda',
        'SA' => 'Saudi Arabia',
        'SB' => 'Solomon Islands',
        'SC' => 'Seychelles',
        'SD' => 'Sudan',
        'SE' => 'Sweden',
        'SG' => 'Singapore',
        'SH' => 'St. Helena',
        'SK' => 'Slovak Republic',
        'SL' => 'Sierra Leone',
        'SM' => 'San Marino',
        'SN' => 'Senegal',
        'SO' => 'Somalia',
        'SR' => 'Suriname',
        'ST' => 'Sao Tome And Principe',
        'SV' => 'El Salvador',
        'SY' => 'Syria',
        'SZ' => 'Swaziland',
        'TC' => 'Turks And Caicos Islands',
        'TD' => 'Chad',
        'TF' => 'French Southern Terr.',
        'TG' => 'Togo',
        'TH' => 'Thailand',
        'TJ' => 'Tajikistan',
        'TK' => 'Tokelau',
        'TM' => 'Turkmenistan',
        'TN' => 'Tunisia',
        'TO' => 'Tonga Island',
        'TP' => 'East Timor',
        'TR' => 'Turkey',
        'TT' => 'Trinidad And Tobago',
        'TV' => 'Tuvalu',
        'TW' => 'Taiwan',
        'TZ' => 'Tanzania',
        'UA' => 'Ukraine',
        'UG' => 'Uganda',
        'UM' => 'Minor U.S. Outlying Islands',
        'US' => 'United States',
        'UZ' => 'Uzbekistan',
        'VA' => 'Vatican',
        'VC' => 'St Vincent & Grenadines',
        'VE' => 'Venezuela',
        'VG' => 'British Virgin Islands',
        'VI' => 'Us Virgin Isl.',
        'VN' => 'Vietnam',
        'VU' => 'Vanuatu',
        'WF' => 'Wallis And Futuna Islands',
        'WS' => 'Samoa',
        'XA' => 'Gaza',
        'XB' => 'Northern Ireland',
        'XH' => 'Held Territories',
        'XU' => 'Khabarovsk Krai',
        'YD' => 'Yemen Democratic',
        'YE' => 'Yemen',
        'YT' => 'Mayotte',
        'YU' => 'Yugoslavia',
        'ZA' => 'South Africa',
        'ZM' => 'Zambia',
        'ZR' => 'Zaire',
        'ZW' => 'Zimbabwe',
        'DZ' => 'Algeria',
        'EC' => 'Ecuador',
        'EE' => 'Estonia',
        'EG' => 'Egypt',
        'ER' => 'Eritrea',
        'ES' => 'Spain',
        'ET' => 'Ethiopia',
        'FI' => 'Finland',
        'FJ' => 'Fiji',
        'FK' => 'Falkland Island',
        'FM' => 'Micronesia',
        'FO' => 'Faroe Islands',
        'FR' => 'France',
        'GA' => 'Gabon',
        'GB' => 'United Kingdom',
        'GD' => 'Grenada',
        'GE' => 'Georgia',
        'GH' => 'Ghana',
        'GI' => 'Gibraltar',
        'GL' => 'Greenland',
        'GM' => 'Gambia',
        'GN' => 'Guinea',
        'GP' => 'Guadeloupe',
        'GQ' => 'Eq Guinea',
        'GR' => 'Greece',
        'GT' => 'Guatemala',
        'GU' => 'Guam',
        'GW' => 'Guinea Bissau',
        'GY' => 'Guyana',
        'HK' => 'Hong Kong',
        'HN' => 'Honduras',
        'HR' => 'Croatia',
        'HT' => 'Haiti',
        'AD' => 'Andorra',
        'AE' => 'United Arab Emirates',
        'AF' => 'Afghanistan',
        'AG' => 'Antigua And Barbuda',
        'AI' => 'Anguilla',
        'AL' => 'Albania',
        'AM' => 'Armenia',
        'AN' => 'Antilles Nether',
        'AO' => 'Angola',
        'AQ' => 'Antarctica',
        'AR' => 'Argentina',
        'AS' => 'American Samoa',
        'AT' => 'Austria',
        'AU' => 'Australia',
        'AW' => 'Aruba',
        'AZ' => 'Azerbaijan',
        'BA' => 'Bosna And Herzegovina',
        'BB' => 'Barbados',
        'BD' => 'Bangladesh',
        'BE' => 'Belgium',
        'BF' => 'Burkina Faso',
        'BG' => 'Bulgaria',
        'BH' => 'Bahrain',
        'BI' => 'Burundi',
        'BJ' => 'Benin',
        'BM' => 'Bermuda',
        'BN' => 'Brunei Darussalam',
        'BO' => 'Bolivia',
        'BR' => 'Brazil',
        'BS' => 'Bahamas',
        'BT' => 'Bhutan',
        'BW' => 'Botswana',
        'BY' => 'Belarus',
        'BZ' => 'Belize',
        'CA' => 'Canada',
        'CD' => 'Congo Dem. Rep.',
        'CF' => 'Central Africa',
        'CG' => 'Congo',
        'CH' => 'Switzerland',
        'CI' => 'Cote D Ivorie',
        'CK' => 'Cook Island',
        'CL' => 'Chile',
        'CM' => 'Cameroon',
        'CN' => 'China',
        'CO' => 'Colombia',
        'CR' => 'Costa Rica',
        'CU' => 'Cuba',
        'CV' => 'Cape Verde Isl.',
        'CX' => 'Christmas Island',
        'CY' => 'Cyprus',
        'CZ' => 'Czech Republic',
        'DE' => 'Germany',
        'DJ' => 'Djibouti',
        'DK' => 'Denmark',
        'DM' => 'Dominica',
        'DO' => 'Dominican Rep.',
        'DS' => 'South Georgia & Sandwich Isl.',
        'NM' => 'Numan',
        'WK' => 'Wake Island',
        'SQ' => 'Bonaire, Sint Eustatius and Saba',
        'PC' => 'Pacific Islands, Trust Territory of The',
        'ME' => 'Montenegro',
        'FQ' => 'French Southern and Antartic Territories',
        'CT' => 'Canton and Enderbury Islands',
        'BV' => 'Bouvet Island',
        'CC' => 'Cocos (Keeling) Island',
        'GF' => 'French Guiana',
        'HM' => 'Heard and McDonald Terr.',
        'JO' => 'Jordan',
        'LI' => 'Liechtenstein',
        'MU' => 'Mauritius',
        'NZ' => 'New Zealand',
        'PG' => 'Papua New Guinea',
        'SI' => 'Slovenia',
        'PM' => 'St Pierre And Miquelon',
        'SJ' => 'Svalbard and Jan Mayen',
        'UY' => 'Uruguay',
        'EH' => 'Western Sahara',
        'HI' => 'Hawaii',
        'SX' => 'Sint Maarten',
        'SS' => 'South Sudan',
        'CW' => 'Curacao',
        'TL' => 'Timor Leste',
        'BL' => 'Saint Barthelemy',
        'GG' => 'Guernsey',
        'JE' => 'Jersey',
        'AX' => 'Aland Island',
        'CS' => 'Serbia and Montenegro',
        'BQ' => 'Bonaire',
        'MF' => 'Saint Martin',
        'IM' => 'Isle of Man'
    };

    public static final String MAINTENANCE_LOPA_STATUS_OCCUPIED = '1';
    public static final String MAINTENANCE_LOPA_STATUS_AVAILABLE = '2';
    public static final String MAINTENANCE_LOPA_STATUS_BLOCK = '3';
    public static final String MAINTENANCE_LOPA_STATUS_MALFUNCTION = '4';
    public static final String MAINTENANCE_LOPA_STATUS_BLOCK_OCCUPIED = '5';
    public static final String MAINTENANCE_LOPA_STATUS_MALFUNCTION_OCCUPIED = '6';
    public static final String MAINTENANCE_LOPA_STATUS_BLOCKED_FROM_LOPA = '7';
    public static final String MAINTENANCE_LOPA_STATUS_UNIDENTIFIED = '8';
    public static final String MAINTENANCE_LOPA_STATUS_NO_ACTION = '9';
    public static final String MAINTENANCE_LOPA_STATUS_SERVICEABLE = '10';

    public static final Map<String, String> IMPACT_MAP_BY_STRING = new Map<String, String> {
        null => MAINTENANCE_LOPA_STATUS_NO_ACTION,
        IMPACT_SERVICABLE => MAINTENANCE_LOPA_STATUS_SERVICEABLE,
        IMPACT_BLOCK => MAINTENANCE_LOPA_STATUS_BLOCK,
        IMPACT_MALFUNCTION => MAINTENANCE_LOPA_STATUS_MALFUNCTION,
        IMPACT_COMPLETE => MAINTENANCE_LOPA_STATUS_AVAILABLE
    };

    public static final Map<String, String> IMPACT_MAP_BY_INTEGER = new Map<String, String> {
        MAINTENANCE_LOPA_STATUS_NO_ACTION => null,
        MAINTENANCE_LOPA_STATUS_SERVICEABLE => IMPACT_SERVICABLE,
        MAINTENANCE_LOPA_STATUS_BLOCK => IMPACT_BLOCK,
        MAINTENANCE_LOPA_STATUS_MALFUNCTION => IMPACT_MALFUNCTION,
        MAINTENANCE_LOPA_STATUS_AVAILABLE => IMPACT_COMPLETE
    };

    public static final String CASE_ACTION_COMPLETE = 'Completed';
    public static final String CASE_ACTION_REMAIN = 'Remain';

    public static final Map<String, String> CASE_ACTION_MAP_INTEGER_TO_STRING = new Map<String, String> {
        '1' => CASE_ACTION_COMPLETE,
        '2' => CASE_ACTION_REMAIN
    };

    public static final Map<String, String> CASE_ACTION_MAP_STRING_TO_INTEGER = new Map<String, String> {
        CASE_ACTION_COMPLETE => '1',
        CASE_ACTION_REMAIN => '2'
    };
}