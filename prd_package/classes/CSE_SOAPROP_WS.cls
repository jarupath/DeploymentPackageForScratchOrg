public with sharing class CSE_SOAPROP_WS extends CSE_SOAP_WS{
	public override String getEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_ENDPOINT);
	}

	public override String getUsername(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_USERNAME);
	}

	public override String getPassword(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_PASSWORD);
	}

	public WS_ROPProfileModel getROPProfile(String memberId) {
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String reqDatetime = tgToken.generateTimestamp();
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_TXN_ID));
		String svcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_SVC_VER);
		String isLastTxn = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_IS_LAST_TXN);
		String mWTxnID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_MW_TXN_ID);
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_ID);
		String soapBody = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">	<env:Header>		<ReqHeader xmlns="http://xml.accenture.com/common/header">			<ReqDateTime>' + reqDatetime + '</ReqDateTime>         			<ReqTxnID>' + reqTxnId + '</ReqTxnID>         			<SvcVer>' + svcVer + '</SvcVer>         			<IsLastTxn>' + isLastTxn + '</IsLastTxn>         			<Credentials>            				<MWCredential>               					<ReqID>' + reqId + '</ReqID>               					<ReqPwd/>               					<UserID/>            				</MWCredential>         			</Credentials>         			<MWTxnID>' + mwTxnID + '</MWTxnID>      		</ReqHeader>      		<Security xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">      			<UsernameToken>         				<Username>' + getUsername() + '</Username>         				<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</Password>      			</UsernameToken>   		</Security>   	</env:Header>   	<env:Body>      		<n1:GetMemberProfileReq xmlns="http://xml.accenture.com/rop/enquiry/profile/getmemberprofile/v1_0" xmlns:n1="http://xml.accenture.com/rop/enquiry/profile">			<inputXML>				<![CDATA[<MemberProfileRQ>			<MemberID>' + memberId + '</MemberID>			</MemberProfileRQ>]]>			</inputXML>		</n1:GetMemberProfileReq>	</env:Body></env:Envelope>';
		String ropMemberId = memberId;
		String wrapNode = 'MemberProfileRS';
		Set<String> nodeArray = new Set<String>{'Phone'};
		String soapAction = 'GetMemberProfile';
		String removeTxt = null;
		return (WS_ROPProfileModel)super.wsCallout(soapBody, wrapNode, nodeArray, soapAction, WS_ROPProfileModel.class, removeTxt);
	}
}