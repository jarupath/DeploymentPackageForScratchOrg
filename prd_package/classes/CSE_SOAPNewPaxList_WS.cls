public without sharing class CSE_SOAPNewPaxList_WS extends CSE_SOAP_WS {
	public static final String CLASS_NAME = 'CSE_SOAPNewPaxList_WS';
	public static final String CLOSE_ENVALOPE = '</pax:GetPaxListByFlightReq></soapenv:Body></soapenv:Envelope>';
	public static final String OPEN_BODY = '<soapenv:Body><pax:GetPaxListByFlightReq>';
	public static final String CLOSE_ORFILTER = '</v1:orFiltersQuery>';
	public static final String OPEN_ORFILTER = '<v1:orFiltersQuery><v1:dummy/>';

	public override String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_ENDPOINT);
	}

	public override String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_USERNAME);
	}

	public override String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_PASSWORD);
	}

	public String getPax(List<Map<String, String>> filterListMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint) {
		String username = getUsername();
		String password = getPassword();
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = tgToken.generateNounce();
		String created = tgToken.generateTimestamp();

		String response = '';
		String request = getSoapRequest(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint, username, password, nonce, created);
		System.debug('---REQUEST---');
		System.debug(request);
		response = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), 'GetPaxListByFlight', request);

		return response;
	}

	public WS_New_Pax_List_Model getPaxModel(List<Map<String, String>> filterListMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint) {
		String username = getUsername();
		String password = getPassword();
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = tgToken.generateNounce();
		String created = tgToken.generateTimestamp();

		String wrapNode = 'flightDetailsGroup';
		Set<String> nodeArray = new Set<String> {'customerLevel', 'timeData', 'otherFlightInfo'};
		String soapAction = 'GetPaxListByFlight';
		String removerTxt = null;

		String response = '';
		String request = getSoapRequest(filterListMap, groupIndicator, carrier, fltNo, departureDate, boardPoint, username, password, nonce, created);

		System.debug('---REQUEST---');
		System.debug(request);
		WS_New_Pax_List_Model newPaxListModel = (WS_New_Pax_List_Model)super.wsCalloutWithoutCDATA(request, wrapNode, nodeArray, soapAction, WS_New_Pax_List_Model.class, removerTxt);
		System.debug('JK: response model');
		System.debug(JSON.serialize(newPaxListModel));

		return newPaxListModel;
	}

	public static String getSoapRequest(List<Map<String, String>> filterMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint, String username, String password, String nonce, String created) {
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_REQ_TXN_ID));
		String svcver = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_SVC_VER);
		String isLastTxn = 'true';
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_REQ_ID);
		String mwTxnID = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_NEW_PAX_LIST_MW_TXN_ID);
		String soapReq = '';
		soapReq += getSoapReqHeader(reqTxnId, svcver, isLastTxn, reqId, mwTxnID, username, password, nonce, created);
		soapReq += getSoapReqBody(filterMap, groupIndicator, carrier, fltNo, departureDate, boardPoint);

		return soapReq;
	}

	public static String getSoapReqBody(List<Map<String, String>> filterMap, List<String> groupIndicator, String carrier, String fltNo, String departureDate, String boardPoint) {
		String soapBody = OPEN_BODY;
		soapBody += getFlightInfo(carrier, fltNo, departureDate, boardPoint);
		if (groupIndicator != null && groupIndicator.size() > 0) {
			soapBody += getDatagroupIndicator(groupIndicator);
		}
		if (filterMap != null && filterMap.size() > 0) {
			for (Map<String, String> orfilter : filterMap) {
				soapBody += getOrFilterQuery(orfilter);
			}
		}
		soapBody += CLOSE_ENVALOPE;

		return soapBody;
	}

	public static String getSoapReqHeader(String reqTxnId, String svcver, String isLastTxn, String reqId, String mwTxnID, String username, String password, String nonce, String created) {
		String soapHeader = ''
		                    + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:pax="http://xml.thaiairways.com/dcs/listing/pax" xmlns:v1="http://xml.thaiairways.com/dcs/listing/pax/getpaxlistbyflight/v1_0"> '
		                    + '    <soapenv:Header> '
		                    + '        <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> '
		                    + '            <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871"> '
		                    + '                <wsse:Username>' + username + '</wsse:Username> '
		                    + '                <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password> '
		                    + '                <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce> '
		                    + '                <wsu:Created>' + created + '</wsu:Created> '
		                    + '            </wsse:UsernameToken> '
		                    + '        </wsse:Security> '
		                    + '        <head:ReqHeader> '
		                    + '            <head:ReqDateTime>2015-09-11T07:00:00+07:00</head:ReqDateTime> '
		                    + '            <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID> '
		                    + '            <head:SvcVer>' + svcver + '</head:SvcVer> '
		                    + '            <head:IsLastTxn>' + isLastTxn + '</head:IsLastTxn> '
		                    + '            <head:Credentials> '
		                    + '                <head:MWCredential> '
		                    + '                    <head:ReqID>' + reqId + '</head:ReqID> '
		                    + '                    <head:ReqPwd/> '
		                    + '                    <head:UserID/> '
		                    + '                </head:MWCredential> '
		                    + '            </head:Credentials> '
		                    + '            <head:MWTxnID>' + mwTxnID + '</head:MWTxnID> '
		                    + '        </head:ReqHeader> '
		                    + '    </soapenv:Header> ';

		return soapHeader;
	}

	public static String getOrFilterQuery(Map<String, String> andfilterMap) {
		String filterbody = OPEN_ORFILTER;

		for (String attType : andfilterMap.keySet()) {
			if (andfilterMap.get(attType) != null) {
				filterbody += getAndFilterQuery(attType, andfilterMap.get(attType));
			} else {
				filterbody += getAndFilterQuery(attType);
			}
		}
		filterbody += CLOSE_ORFILTER;

		return filterbody;
	}

	public static String getAndFilterQuery(String attType) {
		String andFilter = ''
		                   + ' <v1:andFiltersQuery> '
		                   + '     <v1:PaxListFilterName> '
		                   + '         <v1:attributeDetails> '
		                   + '             <v1:attributeType>' + attType + '</v1:attributeType> '
		                   + '         </v1:attributeDetails> '
		                   + '     </v1:PaxListFilterName> '
		                   + ' </v1:andFiltersQuery>';

		return andFilter;
	}

	public static String getAndFilterQuery(String attType, String attValue) {
		String andFilter = ''
		                   + ' <v1:andFiltersQuery> '
		                   + '     <v1:PaxListFilterName> '
		                   + '         <v1:attributeDetails> '
		                   + '             <v1:attributeType>' + attType + '</v1:attributeType> '
		                   + '             <v1:attributeDesc>' + attValue + '</v1:attributeDesc> '
		                   + '         </v1:attributeDetails> '
		                   + '     </v1:PaxListFilterName> '
		                   + ' </v1:andFiltersQuery>';

		return andFilter;
	}

	public static String getFlightInfo(String carrier, String flightNo, String departureDate, String boardPoint) {
		String flightInfo = ''
		                    + ' <v1:flightInfo> '
		                    + '     <v1:carrierDetails> '
		                    + '         <v1:marketingCarrier>' + carrier + '</v1:marketingCarrier> '
		                    + '     </v1:carrierDetails> '
		                    + '     <v1:flightDetails> '
		                    + '         <v1:flightNumber>' + flightNo + '</v1:flightNumber> '
		                    + '     </v1:flightDetails> '
		                    + '     <v1:departureDate>' + departureDate + '</v1:departureDate> '
		                    + '     <v1:boardPoint>' + boardPoint + '</v1:boardPoint> '
		                    + ' </v1:flightInfo> ';

		return flightInfo;
	}

	public static String getDatagroupIndicator(List<String> indicatorList) {
		String groupIndicator = '';
		groupIndicator += '<v1:dataGroupIndicator>';
		for (String indicator : indicatorList) {
			groupIndicator += '<v1:statusInfo>';
			groupIndicator += '<v1:indicator>' + indicator + '</v1:indicator>';
			groupIndicator += '</v1:statusInfo>';
		}
		groupIndicator += '</v1:dataGroupIndicator>';

		return groupIndicator;
	}
}