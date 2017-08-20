public with sharing class CSE_SOAPROPEnrollment_WS extends CSE_SOAP_WS {
	public override String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_ENROLLMENT_ENDPOINT);
	}

	public override String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_USERNAME);
	}

	public override String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_PASSWORD);
	}

	public WS_ROPEnrollmentResponseModel enrollROPMember(WS_ROPEnrollmentRequestModel request) {
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = tgToken.nonce;
		String created = tgToken.created;
		String reqDatetime = tgToken.generateTimestamp();
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_ROP_REQ_TXN_ID));
		String svcVer = BE8_GlobalConstants.SETTING_ROP_SVC_VER;
		String isLastTxn = BE8_GlobalConstants.SETTING_ROP_IS_LAST_TXN;
		String mWTxnID = BE8_GlobalConstants.SETTING_ROP_MW_TXN_ID;
		String reqId = BE8_GlobalUtility.generateTransactionId();
		String soapBody =
		    //'<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:head="http://xml.accenture.com/common/header" xmlns:mem="http://xml.thaiairways.com/rop/enroll/member" xmlns:v1="http://xml.thaiairways.com/rop/enroll/member/enrollropmember/v1_0">   <soapenv:Header>        <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">                <wsse:Username>FB_SICSE</wsse:Username>                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">tgfbtgfb1</wsse:Password>                <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">LTM0Mzk1OTE1NTI3MjkyNDM4MDA==</wsse:Nonce>                <wsu:Created>2017-03-16T06:46:30Z</wsu:Created>            </wsse:UsernameToken>        </wsse:Security>        <head:ReqHeader>            <head:ReqDateTime>2017-03-16T06:46:30Z</head:ReqDateTime>            <head:ReqTxnID>ROP_REQ_TXN_ID20170316-134630</head:ReqTxnID>            <head:SvcVer>v1_0</head:SvcVer>            <head:Credentials>                <head:MWCredential>                    <head:ReqID>FB_SICSE</head:ReqID>                    <head:ReqPwd/>                    <head:UserID>FB_SICSE</head:UserID>                </head:MWCredential>            </head:Credentials>            <!--Unique every request-->            <head:MWTxnID>ExxQy0FqLCuRbxxxxxxOBFodJ0QaPXeF6vc=</head:MWTxnID>        </head:ReqHeader>    </soapenv:Header>   <soapenv:Body>      <mem:EnrollROPMemberReq>         <v1:MemberID>GR90220</v1:MemberID>         <v1:Salutation>Mr.</v1:Salutation>         <v1:FirstName>som</v1:FirstName>         <v1:Middle/>         <v1:LastName>jaideedee</v1:LastName>         <v1:Suffix/>         <v1:Address>            <v1:AddressType>H</v1:AddressType>            <v1:BusinessTitle/>            <v1:CompanyName1/>            <v1:CompanyName2/>            <v1:AddressLine1>89 vibha</v1:AddressLine1>            <v1:AddressLine2>jomphol</v1:AddressLine2>            <v1:AddressLine3/>            <v1:City>Bangkok</v1:City>            <v1:State/>            <v1:CountryCode>TH</v1:CountryCode>            <v1:PostalCode>10800</v1:PostalCode>         </v1:Address>         <v1:PhoneType1>H</v1:PhoneType1>         <v1:CountryCode1>66</v1:CountryCode1>         <v1:AreaCode1>02</v1:AreaCode1>         <v1:Number1>5453587</v1:Number1>         <v1:Extension1/>         <v1:PhoneType2/>         <v1:AreaCode2/>         <v1:Number2/>         <v1:Extension2/>         <v1:CountryCode2/>         <v1:PhoneType3/>         <v1:AreaCode3/>         <v1:Number3/>         <v1:Extension3/>         <v1:CountryCode3/>         <v1:PhoneType4/>         <v1:AreaCode4/>         <v1:Number4/>         <v1:Extension4/>         <v1:CountryCode4/>         <v1:EmailAddress>a@a.com</v1:EmailAddress>         <v1:BirthDate>1985-02-02</v1:BirthDate>         <v1:Gender>M</v1:Gender>         <v1:EnrollSource>IFLIGHT</v1:EnrollSource>         <v1:Language>TH</v1:Language>         <v1:EnrollDate>2017-01-19</v1:EnrollDate>         <v1:SponsorID/>         <v1:SSRSeat>NSSW</v1:SSRSeat>         <v1:SSRMeal>LSML</v1:SSRMeal>         <v1:EnewsIndicator>Y</v1:EnewsIndicator>         <v1:ThaiOfferIndicator>D</v1:ThaiOfferIndicator>         <v1:PartnerOfferIndicator>D</v1:PartnerOfferIndicator>         <v1:Nationality>TH</v1:Nationality>         <v1:IdentificationNumber/>         <v1:PassportNumber/>         <v1:Religion/>         <v1:PinNumber>test1234</v1:PinNumber>      </mem:EnrollROPMemberReq>   </soapenv:Body></soapenv:Envelope>';
		    '   <soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope" xmlns:head="http://xml.accenture.com/common/header" xmlns:mem="http://xml.thaiairways.com/rop/enroll/member" xmlns:v1="http://xml.thaiairways.com/rop/enroll/member/enrollropmember/v1_0">  '  +
		    '      <soapenv:Header>  '  +
		    '         <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">  '  +
		    '            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">  '  +
		    '               <wsse:Username>' + getUsername() + '</wsse:Username>  '  +
		    '               <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>  '  +
		    '               <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>  '  +
		    '               <wsu:Created>' + created + '</wsu:Created>  '  +
		    '            </wsse:UsernameToken>  '  +
		    '         </wsse:Security>  '  +
		    '         <head:ReqHeader>  '  +
		    '            <head:ReqDateTime>' + reqDatetime + '</head:ReqDateTime>  '  +
		    '            <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>  '  +
		    '            <head:SvcVer>v1_0</head:SvcVer>  '  +
		    '            <head:Credentials>  '  +
		    '               <head:MWCredential>  '  +
		    '                  <head:ReqID>FB_SICSE</head:ReqID>  '  +
		    '                  <head:ReqPwd/>  '  +
		    '                  <head:UserID>FB_SICSE</head:UserID>  '  +
		    '               </head:MWCredential>  '  +
		    '            </head:Credentials>  '  +
		    '            <!--Unique every request-->  '  +
		    '            <head:MWTxnID>' + mWTxnID + '</head:MWTxnID>  '  +
		    '         </head:ReqHeader>  '  +
		    '     </soapenv:Header>  ' +
		    '   <soapenv:Body> ' +
		    '      <mem:EnrollROPMemberReq> ' +
		    '         ' + new XMLSerializer().JsonToXML(request.EnrolROPMemberRQ.toJsonString(), true, 'v1') +
		    '      </mem:EnrollROPMemberReq> ' +
		    '   </soapenv:Body> ' +
		    '</soapenv:Envelope> ';
		String wrapNode = 'EnrollROPMemberRes';
		Set<String> nodeArray = new Set<String> ();
		String soapAction = 'enrollROPMember';
		String removeTxt = null;
		System.debug(soapBody);
		return (WS_ROPEnrollmentResponseModel)super.wsCallout(soapBody, wrapNode, nodeArray, soapAction, WS_ROPEnrollmentResponseModel.class, removeTxt, 'EnrollROPMember');
	}
}