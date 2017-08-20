public with sharing class CSE_SOAPCREWONFLIGHT_WS extends CSE_SOAP_WS{
	public override String getEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_ENDPOINT);
	}

	public override String getUsername(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_USERNAME);
	}

	public override String getPassword(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_PASSWORD);
	}

	public WS_CrewonFlightModel getCrewonFlight(String flightDateUTC, String flightNo, String fromStation, String toStation) {
		//set of parameter
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = tgToken.generateNounce();
		String created = tgToken.generateTimestamp();
		String reqDateTime = tgToken.generateTimestamp();
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_TXN_ID));
		String scvVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_SCV_VERSION);
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_ID);
		String reqPwd = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_PASSWORD);
		String userId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_USER_ID);
		String mwTxnId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.MW_TXN_ID);
		String soapBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:crew="http://xml.thaiairways.com/crew/enquiry/crewonflight" xmlns:v1="http://xml.thaiairways.com/crew/enquiry/crewonflight/CrewOnFlightQuery/v1_0">   <soapenv:Header>	<wsse:Security soapenv:mustUnderstand="1"            xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"            xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">                <wsse:Username>' + getUsername() +'</wsse:Username>                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>                                              <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>                <wsu:Created>' + created + '</wsu:Created>            	            </wsse:UsernameToken>      </wsse:Security>   <head:ReqHeader>         <head:ReqDateTime>' + reqDateTime + '</head:ReqDateTime>         <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>         <head:SvcVer>' + scvVer +'</head:SvcVer>         <head:Credentials>            <head:MWCredential>               <head:ReqID>' + reqId +'</head:ReqID>               <head:ReqPwd>' + reqPwd + '</head:ReqPwd>               <head:UserID>' + userId + '</head:UserID>            </head:MWCredential>         </head:Credentials>         <!--Optional:-->         <head:MWTxnID>' + mwTxnId + '</head:MWTxnID>      </head:ReqHeader>   </soapenv:Header>      <soapenv:Body>      <crew:CrewOnFlightQueryReq>         <v1:arg0>            <v1:fltDateUTC>' + flightDateUTC + '</v1:fltDateUTC>            <v1:fltNo>' + flightNo + '</v1:fltNo>            <v1:fromStation>' + fromStation + '</v1:fromStation>            <v1:toStation>' + toStation + '</v1:toStation>         </v1:arg0>      </crew:CrewOnFlightQueryReq>   </soapenv:Body></soapenv:Envelope>';
		System.debug('Soap Body:---' + soapBody);
		String wrapNode = 'ns0:CrewOnFlightQueryRes';
		Set<String> nodeArray = new Set<String>{'return'};
		String soapAction = 'CrewOnFlightQuery';
		String removeTxt = null;
		return (WS_CrewonFlightModel)super.wsCalloutWithoutCDATA(soapBody, wrapNode, nodeArray, soapAction, WS_CrewonFlightModel.class, removeTxt);
	}
}