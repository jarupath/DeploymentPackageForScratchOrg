public class TG_WS_Header {
    public class dutyCodeDetails_element {
        public String referenceQualifier;
        public String referenceIdentifier;
        private String[] referenceQualifier_type_info = new String[]{'referenceQualifier','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] referenceIdentifier_type_info = new String[]{'referenceIdentifier','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'referenceQualifier','referenceIdentifier'};
    }
    public class passwordInfo_element {
        public String dataLength;
        public String dataType;
        public String binaryData;
        private String[] dataLength_type_info = new String[]{'dataLength','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] dataType_type_info = new String[]{'dataType','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] binaryData_type_info = new String[]{'binaryData','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'dataLength','dataType','binaryData'};
    }
    public class Credentials_element {
        public TG_WS_Header.MWCredential_element MWCredential;
        public TG_WS_Header.ProviderCredentials_element ProviderCredentials;
        private String[] MWCredential_type_info = new String[]{'MWCredential','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] ProviderCredentials_type_info = new String[]{'ProviderCredentials','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'MWCredential','ProviderCredentials'};
    }
    public class ResHeader {
        public DateTime ResDateTime;
        public String ReqTxnID;
        public String MWTxnID;
        public TG_WS_Header.AlteaSession_element AlteaSession;
        public Boolean IsLastTxn;
        public String ResCode;
        private String[] ResDateTime_type_info = new String[]{'ResDateTime','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] ReqTxnID_type_info = new String[]{'ReqTxnID','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] MWTxnID_type_info = new String[]{'MWTxnID','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] AlteaSession_type_info = new String[]{'AlteaSession','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] IsLastTxn_type_info = new String[]{'IsLastTxn','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] ResCode_type_info = new String[]{'ResCode','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'ResDateTime','ReqTxnID','MWTxnID','AlteaSession','IsLastTxn','ResCode'};
    }
    public class AlteaSession_element {
        public String SessionId;
        public String SequenceNumber;
        public String SecurityToken;
        private String[] SessionId_type_info = new String[]{'SessionId','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] SequenceNumber_type_info = new String[]{'SequenceNumber','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] SecurityToken_type_info = new String[]{'SecurityToken','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'SessionId','SequenceNumber','SecurityToken'};
    }
    public class fullLocation_element {
        public TG_WS_Header.workstationPos_element workstationPos;
        public TG_WS_Header.locationInfo_element locationInfo;
        private String[] workstationPos_type_info = new String[]{'workstationPos','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] locationInfo_type_info = new String[]{'locationInfo','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'workstationPos','locationInfo'};
    }
    public class Security_Authenticate_element {
        public TG_WS_Header.conversationClt_element conversationClt;
        public TG_WS_Header.userIdentifier_element[] userIdentifier;
        public TG_WS_Header.dutyCode_element dutyCode;
        public TG_WS_Header.systemDetails_element systemDetails;
        public TG_WS_Header.passwordInfo_element[] passwordInfo;
        public TG_WS_Header.fullLocation_element fullLocation;
        public TG_WS_Header.applicationId_element applicationId;
        private String[] conversationClt_type_info = new String[]{'conversationClt','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] userIdentifier_type_info = new String[]{'userIdentifier','http://xml.accenture.com/common/header',null,'1','2','false'};
        private String[] dutyCode_type_info = new String[]{'dutyCode','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] systemDetails_type_info = new String[]{'systemDetails','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] passwordInfo_type_info = new String[]{'passwordInfo','http://xml.accenture.com/common/header',null,'0','2','false'};
        private String[] fullLocation_type_info = new String[]{'fullLocation','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] applicationId_type_info = new String[]{'applicationId','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'conversationClt','userIdentifier','dutyCode','systemDetails','passwordInfo','fullLocation','applicationId'};
    }
    public class locationInfo_element {
        public TG_WS_Header.facilityDetails_element facilityDetails;
        private String[] facilityDetails_type_info = new String[]{'facilityDetails','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'facilityDetails'};
    }
    public class locationDescription_element {
        public String code;
        public String qualifier;
        private String[] code_type_info = new String[]{'code','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] qualifier_type_info = new String[]{'qualifier','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'code','qualifier'};
    }
    public class originIdentification_element {
        public String sourceOffice;
        private String[] sourceOffice_type_info = new String[]{'sourceOffice','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'sourceOffice'};
    }
    public class organizationDetails_element {
        public String organizationId;
        private String[] organizationId_type_info = new String[]{'organizationId','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'organizationId'};
    }
    public class firstLocationDetails_element {
        public String code;
        public String qualifier;
        private String[] code_type_info = new String[]{'code','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] qualifier_type_info = new String[]{'qualifier','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'code','qualifier'};
    }
    public class applicationId_element {
        public TG_WS_Header.applicationDetails_element applicationDetails;
        private String[] applicationDetails_type_info = new String[]{'applicationDetails','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'applicationDetails'};
    }
    public class facilityDetails_element {
        public String type_x;
        public String identifier;
        private String[] type_x_type_info = new String[]{'type','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] identifier_type_info = new String[]{'identifier','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'type_x','identifier'};
    }
    public class MWCredential_element {
        public String ReqID;
        public String ReqPwd;
        public String UserID;
        private String[] ReqID_type_info = new String[]{'ReqID','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] ReqPwd_type_info = new String[]{'ReqPwd','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] UserID_type_info = new String[]{'UserID','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'ReqID','ReqPwd','UserID'};
    }
    public class conversationClt_element {
        public String senderIdentification;
        public String recipientIdentification;
        public String senderInterchangeControlReference;
        public String recipientInterchangeControlReference;
        private String[] senderIdentification_type_info = new String[]{'senderIdentification','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] recipientIdentification_type_info = new String[]{'recipientIdentification','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] senderInterchangeControlReference_type_info = new String[]{'senderInterchangeControlReference','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] recipientInterchangeControlReference_type_info = new String[]{'recipientInterchangeControlReference','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'senderIdentification','recipientIdentification','senderInterchangeControlReference','recipientInterchangeControlReference'};
    }
    public class ProviderCredentials_element {
        public TG_WS_Header.ProviderCredential_element ProviderCredential;
        private String[] ProviderCredential_type_info = new String[]{'ProviderCredential','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'ProviderCredential'};
    }
    public class ReqHeader {
        public DateTime ReqDateTime;
        public String ReqTxnID;
        public String SvcVer;
        public TG_WS_Header.AlteaSession_element AlteaSession;
        public String MessageID;
        public String To;
        public String Action;
        public Boolean IsLastTxn;
        public TG_WS_Header.Credentials_element Credentials;
        public String MWTxnID;
        private String[] ReqDateTime_type_info = new String[]{'ReqDateTime','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] ReqTxnID_type_info = new String[]{'ReqTxnID','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] SvcVer_type_info = new String[]{'SvcVer','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] AlteaSession_type_info = new String[]{'AlteaSession','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] MessageID_type_info = new String[]{'MessageID','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] To_type_info = new String[]{'To','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] Action_type_info = new String[]{'Action','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] IsLastTxn_type_info = new String[]{'IsLastTxn','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] Credentials_type_info = new String[]{'Credentials','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] MWTxnID_type_info = new String[]{'MWTxnID','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'ReqDateTime','ReqTxnID','SvcVer','AlteaSession','MessageID','To','Action','IsLastTxn','Credentials','MWTxnID'};
    }
    public class applicationDetails_element {
        public String internalId;
        public String seqNumber;
        private String[] internalId_type_info = new String[]{'internalId','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] seqNumber_type_info = new String[]{'seqNumber','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'internalId','seqNumber'};
    }
    public class ProviderCredential_element {
        public TG_WS_Header.Security_Authenticate_element Security_Authenticate;
        public String Provider;
        private String[] Security_Authenticate_type_info = new String[]{'Security_Authenticate','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] Provider_att_info = new String[]{'Provider'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'Security_Authenticate'};
    }
    public class dutyCode_element {
        public TG_WS_Header.dutyCodeDetails_element dutyCodeDetails;
        private String[] dutyCodeDetails_type_info = new String[]{'dutyCodeDetails','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'dutyCodeDetails'};
    }
    public class systemDetails_element {
        public String workstationId;
        public TG_WS_Header.organizationDetails_element organizationDetails;
        public String idQualifier;
        private String[] workstationId_type_info = new String[]{'workstationId','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] organizationDetails_type_info = new String[]{'organizationDetails','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] idQualifier_type_info = new String[]{'idQualifier','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'workstationId','organizationDetails','idQualifier'};
    }
    public class workstationPos_element {
        public String locationType;
        public TG_WS_Header.locationDescription_element locationDescription;
        public TG_WS_Header.firstLocationDetails_element firstLocationDetails;
        private String[] locationType_type_info = new String[]{'locationType','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] locationDescription_type_info = new String[]{'locationDescription','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] firstLocationDetails_type_info = new String[]{'firstLocationDetails','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'locationType','locationDescription','firstLocationDetails'};
    }
    public class userIdentifier_element {
        public TG_WS_Header.originIdentification_element originIdentification;
        public String originatorTypeCode;
        public String originator;
        private String[] originIdentification_type_info = new String[]{'originIdentification','http://xml.accenture.com/common/header',null,'0','1','false'};
        private String[] originatorTypeCode_type_info = new String[]{'originatorTypeCode','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] originator_type_info = new String[]{'originator','http://xml.accenture.com/common/header',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://xml.accenture.com/common/header','true','false'};
        private String[] field_order_type_info = new String[]{'originIdentification','originatorTypeCode','originator'};
    }
}