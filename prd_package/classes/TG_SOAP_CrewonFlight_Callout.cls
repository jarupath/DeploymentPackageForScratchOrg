public with sharing class TG_SOAP_CrewonFlight_Callout {

	public static String requestLabelbuf = '';
	public static String getresult = null;

	public static TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
	public static String nonce = tgToken.generateNounce();
	public static String created = tgToken.generateTimestamp();
	public static String reqDateTime = tgToken.generateTimestamp();
	public static String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_TXN_ID));
	public static String scvVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_SCV_VERSION);
	public static String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_ID);
	public static String reqPwd = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_REQUIRED_PASSWORD);
	public static String userId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.WS_USER_ID);
	public static String mwTxnId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.MW_TXN_ID);
	public static String wrapNode = 'ns0:CrewOnFlightQueryRes';
	public static Set<String> nodeArray = new Set<String> {'return'};
	public static String soapAction = 'CrewOnFlightQuery';

	public static String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_USERNAME);
	}
	public static String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_PASSWORD);
	}
	public static String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_ON_FLIGHT_ENDPOINT);
	}
	public static String getSoapBody(String flightDateUTC, String flightNo, String fromStation, String toStation) {
		String soapBody = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:crew="http://xml.thaiairways.com/crew/enquiry/crewonflight" xmlns:v1="http://xml.thaiairways.com/crew/enquiry/crewonflight/CrewOnFlightQuery/v1_0">   <soapenv:Header>	<wsse:Security soapenv:mustUnderstand="1"            xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd"            xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">                <wsse:Username>' + getUsername() + '</wsse:Username>                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</wsse:Password>                                              <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>                <wsu:Created>' + created + '</wsu:Created>            	            </wsse:UsernameToken>      </wsse:Security>   <head:ReqHeader>         <head:ReqDateTime>' + reqDateTime + '</head:ReqDateTime>         <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID>         <head:SvcVer>' + scvVer + '</head:SvcVer>         <head:Credentials>            <head:MWCredential>               <head:ReqID>' + reqId + '</head:ReqID>               <head:ReqPwd>' + reqPwd + '</head:ReqPwd>               <head:UserID>' + userId + '</head:UserID>            </head:MWCredential>         </head:Credentials>         <!--Optional:-->         <head:MWTxnID>' + mwTxnId + '</head:MWTxnID>      </head:ReqHeader>   </soapenv:Header>      <soapenv:Body>      <crew:CrewOnFlightQueryReq>         <v1:arg0>            <v1:fltDateUTC>' + flightDateUTC + '</v1:fltDateUTC>            <v1:fltNo>' + flightNo + '</v1:fltNo>            <v1:fromStation>' + fromStation + '</v1:fromStation>            <v1:toStation>' + toStation + '</v1:toStation>         </v1:arg0>      </crew:CrewOnFlightQueryReq>   </soapenv:Body></soapenv:Envelope>';
		return soapBody;
	}
	public static void CrewonFlightCallout(String fltDateUTC, String fltNo, String fromSta, String toSta) {
		String sbody = getSoapBody(fltDateUTC, fltNo, fromSta, toSta);
		Continuation con = (Continuation)makeSOAPRequestCalloutContinuation(getEndPoint(), soapAction, sbody);
		System.debug('check request: ' + con.getRequests());

	}
	public static Object makeSOAPRequestCalloutContinuation(String endpoint, String soapActions, String body) {
		HttpRequest req = new HttpRequest();
		Http http = new Http();
		req.setEndpoint(endpoint);
		req.setHeader('Content-Type', 'text/xml;charset=utf-8');
		req.setHeader('Content-Length', '' + body.length());
		req.setHeader('soapAction', soapActions);
		req.setHeader('Accept', 'text/xml');
		req.setMethod('POST');
		req.setBody(body);
		Continuation con = new Continuation(120);
		con.continuationMethod = 'callBackForCalloutContinuation';
		System.debug('Call back method:---' + con.continuationMethod);
		String requestLabel = con.addHttpRequest(req);
		System.debug('request label:---' + requestLabel);
		requestLabelbuf = requestLabel;
		return con;
	}

	public static Object callBackForCalloutContinuation() {
		HttpResponse res = Continuation.getResponse(requestLabelbuf);
		System.debug('print out res: ' + res);
		getresult = res.getBody();
		System.debug('get body: ' + getresult);
		insert new TempPassenger__c(Name = 'CallOut Test');
		return null;
	}
	/**/
}