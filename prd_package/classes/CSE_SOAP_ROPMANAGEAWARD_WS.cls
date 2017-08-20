/*
    try {
        new CSE_SOAP_ROPMANAGEAWARD_WS().burnMileage('asdasd','asdasd','asdasd');
    } catch (Exception e) {

    }
*/

public with sharing class CSE_SOAP_ROPMANAGEAWARD_WS extends CSE_SOAP_WS {

    public CSE_SOAP_ROPMANAGEAWARD_WS() {
        this.needNonce = false;
    }

    public override String getEndPoint() {
        return BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_ENDPOINT');
        //return BE8_GlobalUtility.getSetting('TG_BASEURL') + BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_ENDPOINT');
        //return 'http://dev-wsgw.thaiairways.com/rop/manage/award';
        //return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_ENDPOINT);
    }

    public override String getUsername() {
        return BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_USERNAME');
        //return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_USERNAME);
    }

    public override String getPassword() {
        return BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_PASSWORD');
        //return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_PASSWORD);
    }

    //public String getRequestBody(String memberId) {
    //    //TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
    //    //String reqDatetime = tgToken.generateTimestamp();
    //    String prefixReqTxnId = BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_PREFIX_REQ_TXN_ID');
    //    String reqTxnId = BE8_GlobalUtility.generateTransactionId(prefixReqTxnId);
    //    String svcVer = BE8_GlobalUtility.getSetting('ROP_MANAGEAWARD_SVC_VER');
    //    //String isLastTxn = 'true';
    //    String mWTxnID = '';
    //    String reqId = '';
    //    //String soapBody = '';

    //    String soapBodyStr = '<soapenv:Body>';
    //    soapBodyStr += '<awar:IssueAwardReq><v2:inputXML>';
    //    soapBodyStr += '<![CDATA[<?xml version="1.0" encoding="UTF-8"?>';
    //    soapBodyStr += '<IssueAwardRQ>';
    //    soapBodyStr += '<MemberID>' + memberId + '</MemberID>'; //NA00001
    //    soapBodyStr += '<PromotionCode>HAS</PromotionCode>';
    //    soapBodyStr += '<AwardPackage>HS1</AwardPackage>';
    //    soapBodyStr += '<Method>SM</Method>';
    //    soapBodyStr += '</IssueAwardRQ>]]>';
    //    soapBodyStr += '</v2:inputXML></awar:IssueAwardReq>';
    //    soapBodyStr += '</soapenv:Body>';
    //    //String additionalHeader = '';
    //    String envelopeAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:awar="http://xml.accenture.com/rop/manage/award" xmlns:v2="http://xml.accenture.com/rop/manage/award/issueaward/v2_0"';

    //    String soapRequestStr = super.createSOAPBody(envelopeAttribute, reqTxnId, svcVer, 'true', reqId, mWTxnID, soapBodyStr);
    //    return soapRequestStr;
    //}

    public String getRequestBody(String memberId, String promotionCode, String awardPackage) {
        TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
        String nonce = tgToken.nonce;
        String created = tgToken.created;
        String reqDatetime = tgToken.generateTimestamp();
        String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_TXN_ID));
        String svcVer = BE8_GlobalConstants.SETTING_ROP_SVC_VER;
        String isLastTxn = BE8_GlobalConstants.SETTING_ROP_IS_LAST_TXN;
        String mWTxnID = BE8_GlobalConstants.SETTING_ROP_MW_TXN_ID;
        String reqId = BE8_GlobalUtility.generateTransactionId();

        String soapBodyStr =
        '   <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:awar="http://xml.accenture.com/rop/manage/award" xmlns:v2="http://xml.accenture.com/rop/manage/award/issueaward/v1_0">  '  + 
        '      <soapenv:Header>  '  + 
        '           <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">  '  + 
        '               <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">  '  + 
        '                   <wsse:Username>' + getUsername() + '</wsse:Username>  '  + 
        '                   <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>  '  + 
        '                   <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>  '  + 
        '                   <wsu:Created>' + created + '</wsu:Created>  '  + 
        '               </wsse:UsernameToken>  '  + 
        '           </wsse:Security>  '  + 
        '           <head:ReqHeader>  '  + 
        '               <head:ReqDateTime>' + reqDatetime + '</head:ReqDateTime>  '  + 
        '               <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>  '  + 
        '               <head:SvcVer>v1_0</head:SvcVer>  '  + 
        '               <head:Credentials>  '  + 
        '                   <head:MWCredential>  '  + 
        '                       <head:ReqID>FB_SICSE</head:ReqID>  '  + 
        '                       <head:ReqPwd/>  '  + 
        '                       <head:UserID>FB_SICSE</head:UserID>  '  + 
        '                   </head:MWCredential>  '  + 
        '               </head:Credentials>  '  + 
        '               <!--Unique every request-->  '  + 
        '               <head:MWTxnID>' + mWTxnID + '</head:MWTxnID>  '  + 
        '           </head:ReqHeader>  '  + 
        '       </soapenv:Header>  '  + 
        '      <soapenv:Body>  '  + 
        '         <awar:IssueAwardReq>  '  + 
        '            <v2:inputXML><![CDATA[<?xml version="1.0" encoding="UTF-8"?><IssueAwardRQ><MemberID>' + memberId + '</MemberID><PromotionCode>' + promotionCode + '</PromotionCode><AwardPackage>' + awardPackage + '</AwardPackage></IssueAwardRQ>]]></v2:inputXML>  '  + 
        '         </awar:IssueAwardReq>  '  + 
        '      </soapenv:Body>  '  + 
        '  </soapenv:Envelope>  ' ; 
        //String additionalHeader = '';
        //String envelopeAttribute = 'xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:awar="http://xml.accenture.com/rop/manage/award" xmlns:v2="http://xml.accenture.com/rop/manage/award/issueaward/v2_0"';

        //String soapRequestStr = super.createSOAPBody(envelopeAttribute, reqTxnId, svcVer, 'true', reqId, mWTxnID, soapBodyStr);
        return soapBodyStr;
    }

    public WS_ROPManageAward_Model burnMileageWithRequestBody(String soapRequestStr) {
        Set<String> nodeArray = new Set<String>();
        String soapAction = '"IssueAward"';
        String wrapNode = '';
        String removeTxt = null;
        System.debug('soapRequestStr: ' + soapRequestStr);
        WS_ROPManageAward_Model responseModel = (WS_ROPManageAward_Model)super.wsCallout(soapRequestStr, wrapNode, nodeArray, soapAction, WS_ROPManageAward_Model.class, removeTxt);
        return responseModel;
    }

    public WS_ROPManageAward_Model burnMileage(String memberId, String promotionCode, String awardPackage) {
        String soapRequestStr = getRequestBody(memberId, promotionCode, awardPackage);
        AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_SOAP_ROPMANAGEAWARD_WS', 'burnMileage', '', '', 'request from SFDC to THAI ', soapRequestStr, null, System.currentTimeMillis());

        WS_ROPManageAward_Model responseModel = burnMileageWithRequestBody(soapRequestStr);
        if (responseModel.hasError()) {
            //Monitoring.notifyError('Error: Submit CrewAppraisalAnswer To THAI', responseModel.getErrorMessage(), 'ROPManageAward');
            String bodyMsg = responseModel.getErrorMessage();
            bodyMsg = 'MemberId :' + memberId + '\n' + bodyMsg;
            AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_SOAP_ROPMANAGEAWARD_WS', 'burnMileage', memberId, 'MemberID', bodyMsg, JSON.serializePretty(responseModel), null, System.currentTimeMillis());
        } else {
            AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'CSE_SOAP_ROPMANAGEAWARD_WS', 'burnMileage', memberId, 'MemberID', 'response from THAI to SFDC ', JSON.serializePretty(responseModel), null, System.currentTimeMillis());
        }
        //AppLogger.insertLogs();
        return responseModel;
    }
}