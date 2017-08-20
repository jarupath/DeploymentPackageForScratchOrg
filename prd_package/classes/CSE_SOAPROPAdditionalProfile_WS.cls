public with sharing class CSE_SOAPROPAdditionalProfile_WS extends CSE_SOAP_WS{
	public override String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_ENDPOINT);
	}

	public override String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_USERNAME);
	}

	public override String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_PASSWORD);
	}

	public String getReqTxnID() {
		return BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_REQ_TXN_ID));
	}

	public String getSvcVer() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_SVC_VER);
	}

	public String getReqID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_REQ_ID);
	}

	public String getReqPwd() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_REQ_PWD);
	}

	public String getUserID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_REQ_USER_ID);
	}

	public String getMWTxnID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROPADD_MW_TXN_ID);
	}

	public WS_ROPAdditionalProfileModel getAdditionalProfile(String memberId){
		TG_UsernameToken_element token = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = token.nonce;
		String created = token.created;

		String soapBody = '' +
			'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:prof="http://xml.thaiairways.com/rop/display/profile" xmlns:v1="http://xml.thaiairways.com/rop/display/profile/getadditionalmemberprofile/v1_0">' +
   				'<soapenv:Header>' +
					'<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:UsernameToken wsu:Id="UsernameToken-4"><wsse:Username>' + getUsername() + '</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password></wsse:UsernameToken></wsse:Security>' +
   					'<head:ReqHeader>' +
         				'<head:ReqDateTime>' + created + '</head:ReqDateTime>' +
         				'<head:ReqTxnID>' + getReqTxnID() + '</head:ReqTxnID>' +
         				'<head:SvcVer>' + getSvcVer() + '</head:SvcVer>' +
         				'<head:IsLastTxn>true</head:IsLastTxn>' +
         
         				'<head:Credentials>' +
            				'<head:MWCredential>' +
	               				'<head:ReqID>' + getReqID() + '</head:ReqID>' +
	               				'<head:ReqPwd>' + getReqPwd() + '</head:ReqPwd>' +
	               				'<head:UserID>' + getUserID() + '</head:UserID>' +
            				'</head:MWCredential>' +
     					'</head:Credentials>' +
         				'<head:MWTxnID>' + getMWTxnID() + '</head:MWTxnID>' +
  					'</head:ReqHeader>' +
				'</soapenv:Header>' +
   				'<soapenv:Body>' +
      				'<prof:GetAdditionalMemberProfileReq>' +
         				'<v1:MemberID>' + memberId + '</v1:MemberID>' +
         				'<v1:IPAddress>192.168.0.1</v1:IPAddress>' +
  					'</prof:GetAdditionalMemberProfileReq>' +
   				'</soapenv:Body>' +
			'</soapenv:Envelope>';

		System.debug('GetAdditionalMemberProfile request :' + soapBody);

		String ropMemberId = memberId;
		String wrapNode = 'GetAdditionalMemberProfileRes';
		Set<String> nodeArray = new Set<String>{'TargetAudience'};
		String soapAction = 'GetAdditionalMemberProfile';

		return (WS_ROPAdditionalProfileModel)super.wsCallout(soapBody, wrapNode, nodeArray, soapAction, WS_ROPAdditionalProfileModel.class, '');
	}
}