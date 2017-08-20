public with sharing class CSE_SOAPFLIGHT_WS extends CSE_SOAP_WS{
	public override String getEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_ENDPOINT);
	}

	public override String getUsername(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_USERNAME);
	}

	public override String getPassword(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_PASSWORD);
	}

	public WS_FlightModel getFlight(String pFlightNumber, Date pFlightDate, String pTimemode) {
		pFlightNumber = pFlightNumber.replace('TG','');
		TG_UsernameToken_element token = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = token.nonce;
		String created = token.created;
		String reqDatetime = token.generateTimestamp();
		String soapResponse = '';
		String fDate = BE8_GlobalUtility.getDateString(pFlightDate, BE8_GlobalConstants.DATE_FORMAT_FOR_GET_FLIGHT_SERVICE);
		System.debug('ws converted date: ' + fDate);
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_REQ_TXN_ID));
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_REQ_ID);
		String userId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_USER_ID);
		String mwTxnId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_MW_TXN_ID);
		String svcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_FLIGHT_SVC_VER);
		//String soapBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:flig="http://xml.thaiairways.com/tops/enquiry/flight" xmlns:v1="http://xml.thaiairways.com/tops/enquiry/flight/getflight/v1_0">   <soapenv:Header>   	<wsse:Security soapenv:mustUnderstand="1"            xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"            xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">                <wsse:Username>' + getUsername() + '</wsse:Username>                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>                                              <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>                <wsu:Created>' + created + '</wsu:Created>            	            </wsse:UsernameToken>      </wsse:Security>            <head:ReqHeader>         <head:ReqDateTime>' + '2016-08-20T19:35:48.356+07:00' + '</head:ReqDateTime>         <head:ReqTxnID>AEK11111111112</head:ReqTxnID>         <head:SvcVer>v1_0</head:SvcVer>         <head:Credentials>            <head:MWCredential>               <head:ReqID>MWTESTER</head:ReqID>               <head:ReqPwd></head:ReqPwd>               <head:UserID>MWTESTER</head:UserID>            </head:MWCredential>         </head:Credentials>         <!--Optional:-->         <head:MWTxnID>ExxQy0FqLCuRbxxxxxxOBFodJ0QaPXeF6vc</head:MWTxnID>      </head:ReqHeader>   </soapenv:Header>      <soapenv:Body>      <flig:GetFlightReq>         <v1:arg0>            <v1:flightDate>2016-11-12</v1:flightDate>            <v1:flightNo>0600</v1:flightNo>            <v1:timemode>UTC</v1:timemode>         </v1:arg0>      </flig:GetFlightReq>   </soapenv:Body></soapenv:Envelope>';
		String soapBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:flig="http://xml.thaiairways.com/tops/enquiry/flight" xmlns:v1="http://xml.thaiairways.com/tops/enquiry/flight/getflight/v1_0">   <soapenv:Header>   	<wsse:Security soapenv:mustUnderstand="1"            xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"            xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">                <wsse:Username>' + getUsername() + '</wsse:Username>                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>                                              <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>                <wsu:Created>' + created + '</wsu:Created>            	            </wsse:UsernameToken>      </wsse:Security>            <head:ReqHeader>         <head:ReqDateTime>' + reqDatetime + '</head:ReqDateTime>         <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>         <head:SvcVer>' + svcVer + '</head:SvcVer>         <head:Credentials>            <head:MWCredential>               <head:ReqID>' + reqId + '</head:ReqID>               <head:ReqPwd></head:ReqPwd>               <head:UserID>' + userId + '</head:UserID>            </head:MWCredential>         </head:Credentials>                  <head:MWTxnID>' + mwTxnId + '</head:MWTxnID>      </head:ReqHeader>   </soapenv:Header>      <soapenv:Body>      <flig:GetFlightReq>         <v1:arg0>            <v1:flightDate>' + fDate + '</v1:flightDate>            <v1:flightNo>' + pFlightNumber + '</v1:flightNo>            <v1:timemode>' + pTimemode + '</v1:timemode>         </v1:arg0>      </flig:GetFlightReq>   </soapenv:Body></soapenv:Envelope>';
		System.debug(soapBody);
		return (WS_FlightModel)super.wsCallout(soapBody, 'return', new Set<String>{'legdetail'}, 'GetFlight', WS_FlightModel.class, null);
	}
}