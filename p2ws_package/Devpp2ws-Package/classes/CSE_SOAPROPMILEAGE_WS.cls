public with sharing class CSE_SOAPROPMILEAGE_WS extends CSE_SOAP_WS{
	public override String getEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_MILEAGE_ENDPOINT);
	}

	public override String getUsername(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_USERNAME);
	}

	public override String getPassword(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_PASSWORD);
	}

	public WS_ROPMileageModel getCurrentMileage(String memberId) {
		System.debug('SJ : getCurrentMileage :' + memberId);
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String reqDatetime = tgToken.generateTimestamp();
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_TXN_ID));
		String svcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_SVC_VER);
		String isLastTxn = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_IS_LAST_TXN);
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_ID);
		String soapBody = '<soapenv:Envelope xmlns:head="http://xml.accenture.com/common/header" xmlns:prof="http://xml.accenture.com/rop/enquiry/profile" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xml.accenture.com/rop/enquiry/profile/getcurrentmileage/v1_0">   <soapenv:Header>      <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">         <wsse:UsernameToken wsu:Id="UsernameToken-4">            <wsse:Username>' + getUsername() + '</wsse:Username>            <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>         </wsse:UsernameToken>     </wsse:Security>      <head:ReqHeader>         <head:ReqDateTime>' + reqDatetime + '</head:ReqDateTime>         <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>         <head:SvcVer>' + svcVer + '</head:SvcVer>         <head:IsLastTxn>' + isLastTxn + '</head:IsLastTxn>         <head:Credentials>            <head:MWCredential>               <head:ReqID>' + reqId + '</head:ReqID>               <head:ReqPwd></head:ReqPwd>               <head:UserID></head:UserID>            </head:MWCredential>         </head:Credentials>      </head:ReqHeader>   </soapenv:Header>   <soapenv:Body>      <prof:GetCurrentMileageReq>         <v1:inputXML><![CDATA[<?xml version="1.0" encoding="UTF-8"?> <CurrentMileageRQ> <MemberID>' + memberId + '</MemberID> </CurrentMileageRQ>]]> </v1:inputXML>      </prof:GetCurrentMileageReq>   </soapenv:Body></soapenv:Envelope>';
		String wrapNode = 'CurrentMileageRS';
		Set<String> nodeArray = new Set<String>{'MilesExpiry', 'ExtendablePoints'};
		String soapAction = 'GetCurrentMileage';
		String removeTxt = null;
		System.debug('SJ : before call out ');
		return (WS_ROPMileageModel)super.wsCallout(soapBody, wrapNode, nodeArray, soapAction, WS_ROPMileageModel.class, removeTxt);
	}
}