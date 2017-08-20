public with sharing abstract class CSE_SOAP_WS {
	protected abstract String getUsername();
	protected abstract String getPassword();
	protected abstract String getEndPoint();
	public Boolean needNonce = true;
	private String actionOnContentType = null;

	public object wsCallout(final String soapBody, final String wrapNode, final Set<String> nodeArray, final String soapAction, final System.Type apextype, final String removerTxt, final String actionOnContentType) {
		this.actionOnContentType = actionOnContentType;
		return wsCallout(soapBody, wrapNode, nodeArray, soapAction, apextype, removerTxt);
	}

	public object wsCallout(final String soapBody, final String wrapNode, final Set<String> nodeArray, final String soapAction, final System.Type apextype, final String removerTxt) {
		String xml;
		if(this.actionOnContentType != null){
			xml = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), soapAction, soapBody, this.actionOnContentType);
		} else {
			xml = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), soapAction, soapBody);
		}

		//System.debug('Raw Response' + xml);
		if (xml != null) {
			//xml = xml.replaceAll('&lt;', '<');
			//xml = xml.replaceAll('&gt;', '>');
			//xml = xml.replaceAll('&amp;', '&');
			//System.debug('Convert XML :' + xml);
		}

		try {
			String xmlWithOutCDATA = BE8_GlobalUtility.removeCDATAfromXMLString(xml);
			xmlWithOutCDATA = xmlWithOutCDATA.replaceAll('&', '&amp;');

			String unwrapXmlString = xmlWithOutCDATA;
			//System.debug('xmlWithOutCDATA ' + xmlWithOutCDATA);

			if (!String.isBlank(wrapNode)) {
				TG_XmlDom dom = new TG_XmlDom(xmlWithOutCDATA);
				//System.debug('dom :' + dom);
				TG_XmlNode rootNode = dom.root;
				//System.debug('rootNode :' + rootNode);
				//System.debug('wrapNode :' + wrapNode);
				TG_XmlNode unwrapNode = rootNode.getElementByTagName(wrapNode);
				//System.debug('unwrapNode :' + unwrapNode);
				unwrapXmlString = unwrapNode.toXmlString();
				//System.debug('unwrapXmlString :' + unwrapXmlString);
			}
			//System.debug('removerTxt :' + removerTxt);
			if (removerTxt != null) {
				unwrapXmlString.remove(removerTxt);
				//System.debug('unwrapXmlString :' + unwrapXmlString);
			}
			return new XMLSerializer().deSerialize(unwrapXmlString, apextype, nodeArray);
		} catch (Exception e) {
			System.debug('ERROR while wsCallout :' + e);
			String msg = xml != null && xml.contains('<mwerror:ErrDesc>') ? BE8_GlobalUtility.getMsgBetween(xml, '<mwerror:ErrDesc>', '</mwerror:ErrDesc>') : e.getTypeName(); 
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_SOAP_WS', 'wsCallout',  msg, 'Exception', e.getMessage(), xml, e, System.currentTimeMillis());
			//Monitoring.notifyError(e, '');
		}
		return null;
	}

	public object wsCalloutWithoutCDATA(final String soapBody, final String wrapNode, final Set<String> nodeArray, final String soapAction, final System.Type apextype, final String removerTxt) {
		String xml = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), soapAction, soapBody);
		//System.debug('Return xml: ' + xml);
		//System.debug('get heap size xml:---' + Limits.getHeapSize());
		try {
			//xml = xml.replaceAll('&', '&amp;');
			xml = BE8_GlobalUtility.replaceCharToString(xml, '&', '&amp;');
			if (wrapNode != null) {
				TG_XmlDom dom = new TG_XmlDom(xml);
				xml = null;
				//System.debug('get heap size dom:---' + Limits.getHeapSize());
				TG_XmlNode rootNode = dom.root;
				//System.debug('get heap size rootNode:---' + Limits.getHeapSize());
				TG_XmlNode unwrapNode = rootNode.getElementByTagName(wrapNode);
				//System.debug('get heap size unwrapNode:---' + Limits.getHeapSize());
				xml = unwrapNode.toXmlString();
				//System.debug('get heap size xml:---' + Limits.getHeapSize());
				dom = null;
				rootNode = null;
				unwrapNode = null;
				//System.debug('get heap size after clear mem:---' + Limits.getHeapSize());
			}

			if (removerTxt != null) {
				xml.remove(removerTxt);
			}
			//System.debug('JK: debug response: ');
			//System.debug(JSON.serialize(xml));
			object temp = new XMLSerializer().deSerialize(xml, apextype, nodeArray);
			//System.debug('get heap size temp:---' + Limits.getHeapSize());
			return temp;
		} catch (Exception e) {
			System.debug('ERROR while wsCallout :' + e);
			String msg = xml != null && xml.contains('<mwerror:ErrDesc>') ? BE8_GlobalUtility.getMsgBetween(xml, '<mwerror:ErrDesc>', '</mwerror:ErrDesc>') : e.getTypeName(); 
			AppLogger.add(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_SOAP_WS', 'wsCallout',  msg, 'Exception', e.getMessage(), xml, e, System.currentTimeMillis());
			//Monitoring.notifyError(e, '');
		}
		return null;
	}

	public String createSOAPBody(String envelopeAttribute, String reqTxnId, String svcVer, String isLastTxn, String reqId, String mwTxnID, String body) {
		TG_UsernameToken_element tgToken = new TG_UsernameToken_element(getUsername(), getPassword());
		String reqDatetime = tgToken.generateTimestamp();
		String soapRequestStr = '<soapenv:Envelope ' + envelopeAttribute + '>';
		soapRequestStr += 	'<soapenv:Header>';
		soapRequestStr +=		'<ReqHeader xmlns="http://xml.accenture.com/common/header">';
		soapRequestStr += 		'<ReqDateTime>' + reqDatetime + '</ReqDateTime>';
		soapRequestStr +=		'<ReqTxnID>' + reqTxnId + '</ReqTxnID>';
		soapRequestStr +=			'<SvcVer>' + svcVer + '</SvcVer>';
		soapRequestStr +=			'<IsLastTxn>' + isLastTxn + '</IsLastTxn>';
		soapRequestStr +=			'<Credentials>';
		soapRequestStr +=				'<MWCredential>';
		soapRequestStr +=					'<ReqID>' + reqId + '</ReqID>';
		soapRequestStr +=					'<ReqPwd/>';
		soapRequestStr +=					'<UserID/>';
		soapRequestStr +=				'</MWCredential>';
		soapRequestStr +=			'</Credentials>';
		soapRequestStr +=		'<MWTxnID>' + mwTxnID + '</MWTxnID>';
		soapRequestStr +=		'</ReqHeader>';
		soapRequestStr +=		'<Security xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">';
		soapRequestStr +=			'<UsernameToken>';
		soapRequestStr +=				'<Username>' + getUsername() + '</Username>';
		soapRequestStr +=				'<Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + getPassword() + '</Password>';
		if (needNonce) {
			soapRequestStr += 				'<Nonce>' + BE8_GlobalUtility.generateNonce() + '</Nonce>';
		}
		soapRequestStr += 				'<Created>' + Datetime.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + '</Created>';
		soapRequestStr +=			'</UsernameToken>';
		soapRequestStr +=		'</Security>';
		soapRequestStr +=	'</soapenv:Header>';
		soapRequestStr += body;
		soapRequestStr +=  '</soapenv:Envelope>';
		return soapRequestStr;
	}
}