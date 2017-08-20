global class CSE_SOAPCABINLOG_WS extends CSE_SOAP_WS {

	private static final String CLASS_NAME = 'CSE_SOAPCABINLOG_WS';

	public static final String EXCEPTION_MSG = 'SOAP-ENV:Fault';
	public static final String ERR_CAT_START_MSG = '<mwerror:ErrCat>';
	public static final String ERR_CAT_END_MSG = '</mwerror:ErrCat>';
	public static final String ERR_CAT_DESC_START_MSG = '<mwerror:ErrCatDesc>';
	public static final String ERR_CAT_DESC_END_MSG = '</mwerror:ErrCatDesc>';
	public static final String ERR_CODE_START_MSG = '<mwerror:ErrCode>';
	public static final String ERR_CODE_END_MSG = '</mwerror:ErrCode>';
	public static final String ERR_DESC_START_MSG = '<mwerror:ErrDesc>';
	public static final String ERR_DESC_END_MSG = '</mwerror:ErrDesc>';
	public static final String ERR_SEV_START_MSG = '<mwerror:ErrSev>';
	public static final String ERR_SEV_END_MSG = '</mwerror:ErrSev>';
	public static final String SUCCESS_MSG = 'SUCCESS';
	public static final String RESP_TYPE_START_MSG = '<Responsetype>';
	public static final String RESP_TYPE_END_MSG = '</Responsetype>';
	public static final String RESP_TEXT_START_MSG = '<Responsetext>';
	public static final String RESP_TEXT_END_MSG = '</Responsetext>';
	private static final String RESP_TYPE_SAVE_SUCCESS = 'S';
	private static final String RESP_TXT_CLOSE_CASE = 'SEQ has been completed';
	private static final String CASE_STATUS_CLOSE = 'Closed';

	global class CabinLogModel {
		public String flightNo;	// TG0111
		public String flightDate; // 20161001
		public String aircraftReg; // HS-TUA
		public String departure; // BKK
		public String defectType; //DEFECT
		public String caseStatus; //OPEN
		public String seqNo; // UA007C011016
		public String ata; // 24
		public String complaintText; // Update Void
		public String positionNo; // A24, A26
		public String blockname; // APISIT
		public String auth; // 1134
	}

	global class CabinLogResponseModel {
		public String responseText;
		public String responseType;
		public boolean status; // true = success, false = fail
		public String errorMessage; // Error message
	}

	public override String getEndPoint() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_ENDPOINT);
	}

	public override String getUsername() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_USERNAME);
	}

	public override String getPassword() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_PASSWORD);
	}

	public String getReqTxnID() {
		return BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_REQ_TXN_ID));
	}

	public String getSvcVer() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_SVC_VER);
	}

	public String getReqID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_REQ_ID);
	}

	public String getReqPwd() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_REQ_PWD);
	}

	public String getUserID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_REQ_USER_ID);
	}

	public String getMWTxnID() {
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_SAP_MW_TXN_ID);
	}

	@Future(callout = true)
	public static void createCabinLogFromCaseListWithFuture(Set<Id> caseIdSet) {
		createCabinLogFromCaseList(caseIdSet);
	}

	public static CabinLogResponseModel createCabinLogFromCaseList(Set<Id> caseIdSet) {
		System.debug('Create cabin log from case :' + caseIdSet);
		List<Case> caseListToBeUpdate = new List<Case>();

		List<String> reqString = new List<String>();
		List<String> resString = new List<String>();

		CabinLogResponseModel response;
		List<Case> caseList = [SELECT Id,
		                       Flightid__r.Flight_Number__c,
		                       Flightid__r.Flight_Date_UTC__c,
		                       Aircraft_Registration_F__c,
		                       Flightid__c,
		                       Flightid__r.Departure_STN__c,
		                       Status,
		                       DEP_STN__c,
		                       SEQ_No_Display__c,
		                       SEQ_No_txt__c,
		                       ATA_Chapter_2_F__c,
		                       Description,
		                       Position_Case_Group_Member__c,
		                       Block_Name__c,
		                       Authorize_Number__c,
		                       Complaint_TXT_40__c
		                       FROM Case WHERE Id IN: caseIdSet];
		for (Case c : caseList) {
			System.debug('Case Data :Case ID :' + c.Id +
			             ' / Flight Number :' + c.Flightid__r.Flight_Number__c + // flightNo = TG0600
			             ' / Flight Date :' + c.Flightid__r.Flight_Date_UTC__c + // flightDate = 20161001
			             ' / Aircraft :' + c.Aircraft_Registration_F__c +	// aircraftReg = HSTUA
			             ' / DEP :' + c.DEP_STN__c + 		// departure = BKK
			             ' / Status :' + c.Status + 			// caseStatus(VOID/OPEN), defectType(VOID/DEFECT)
			             ' / SEQ :' + c.SEQ_No_Display__c + 		// seqNo = UA007C011016
			             ' / ATA :' + c.ATA_Chapter_2_F__c + // ata = 24
			             ' / Description :' + c.Description + 	// complaintText = XXX
			             ' / Position Case Group Member :' + c.Position_Case_Group_Member__c + // positionNo = A24, A26
			             ' / Block Name :' + c.Block_Name__c + 	// blockname = APISIT
			             ' / Auth :' + c.Authorize_Number__c);	// auth = 1133
			try {
				CSE_SOAPCABINLOG_WS.CabinLogModel cabinLogModel = new CSE_SOAPCABINLOG_WS.CabinLogModel();

				cabinLogModel.flightNo = c.Flightid__r != null && c.Flightid__r.Flight_Number__c != null ? c.Flightid__r.Flight_Number__c.capitalize() : '';
				cabinLogModel.flightDate = c.Flightid__r != null && c.Flightid__r.Flight_Date_UTC__c != null ? c.Flightid__r.Flight_Date_UTC__c.replaceAll('-', '').capitalize() : '';

				if (c.Aircraft_Registration_F__c != null) {
					if (c.Aircraft_Registration_F__c.contains('-')) {
						cabinLogModel.aircraftReg = c.Aircraft_Registration_F__c.capitalize();
					} else {
						cabinLogModel.aircraftReg = (c.Aircraft_Registration_F__c.substring(0, 2) + '-' +
						                             c.Aircraft_Registration_F__c.substring(2)).capitalize();
					}
				}
				if (c.DEP_STN__c != null) {
					cabinLogModel.departure = c.DEP_STN__c.capitalize();
				} else if (c.Flightid__r != null && c.Flightid__r.Departure_STN__c != null) {
					cabinLogModel.departure = c.Flightid__r.Departure_STN__c.capitalize();
				}
				cabinLogModel.defectType = (c.Status == 'Void') ? 'VOID' : 'DEFECT';
				cabinLogModel.caseStatus = (c.Status == 'Void') ? 'VOID' : 'OPEN';
				cabinLogModel.seqNo = c.SEQ_No_Display__c != null ? c.SEQ_No_Display__c.capitalize() : '';
				cabinLogModel.ata = c.ATA_Chapter_2_F__c != null ? c.ATA_Chapter_2_F__c.capitalize() : '';
				//cabinLogModel.ata = '25';	 // Test only in case ATA chapter not sent as number
				//cabinLogModel.complaintText = c.Description != null ? c.Description.capitalize() : '';
				cabinLogModel.complaintText = c.Complaint_TXT_40__c != null ? c.Complaint_TXT_40__c.capitalize() : '';
				cabinLogModel.positionNo = c.Position_Case_Group_Member__c != null ? c.Position_Case_Group_Member__c.capitalize() : '';
				cabinLogModel.blockname = c.Block_Name__c != null ? c.Block_Name__c.capitalize() : '';
				cabinLogModel.auth = c.Authorize_Number__c != null ? c.Authorize_Number__c.capitalize() : null;

				response = new CSE_SOAPCABINLOG_WS().insertCabinLog(cabinLogModel);
				if (response != null && response.responseText != null && response.responseText.contains(RESP_TXT_CLOSE_CASE)) {
					c.Status = CASE_STATUS_CLOSE;
					caseListToBeUpdate.add(c);
				}

				reqString.add(JSON.serialize(cabinLogModel));
				resString.add(JSON.serialize(response));
				if (response.status == true) {
					AppLogger.debug(CLASS_NAME, 'createCabinLogFromCaseList', c.Id != null ? c.Id : null, 'req: ' + JSON.serialize(cabinLogModel) + '\nres: ' + JSON.serialize(response), null);
				} else {
					AppLogger.error(CLASS_NAME, 'createCabinLogFromCaseList', c.Id != null ? c.Id : null, 'req: ' + JSON.serialize(cabinLogModel) + '\nres: ' + JSON.serialize(response), null);
				}
			} catch (System.Exception e) {
				AppLogger.error(CLASS_NAME, 'createCabinLogFromCaseList', c.Id, 'Fail to integrate with TG', e);
			}
		}

		//CSE_SOAPCABINLOG_WS.logApplicationLog('request: ' + String.valueOf(reqString));
		//CSE_SOAPCABINLOG_WS.logApplicationLog('response: ' + String.valueOf(resString));
		if (!caseListToBeUpdate.isEmpty()) {
			Database.SaveResult[] result = Database.update(caseListToBeUpdate, false);
			System.debug('JK: DEBUG update case');
			System.debug('result: ' + JSON.serialize(result));
			System.debug('case to be update: ' + JSON.serialize(caseListToBeUpdate));
			System.debug('req string list: ' + JSON.serialize(reqString));
			System.debug('res string list: ' + JSON.serialize(resString));
		}

		//AppLogger.insertLogs();
		return response;
	}


	/** Test via developer console
		CSE_SOAPCABINLOG_WS.CabinLogModel c = new CSE_SOAPCABINLOG_WS.CabinLogModel();
		c.flightNo = 'TG0111';
		c.flightDate = '20161001';
		c.aircraftReg = 'HS-TUA';
		c.departure = 'BKK';
		c.defectType = 'DEFECT';
		c.caseStatus = 'OPEN';
		c.seqNo = 'UA007C011016';
		c.ata = '24';
		c.complaintText = 'Update Void';
		c.positionNo = 'A24, A26';
		c.blockname = 'APISIT';
		c.auth = '1134';
		CSE_SOAPCABINLOG_WS.CabinLogResponseModel m = new CSE_SOAPCABINLOG_WS().insertCabinLog(c);
		System.debug(m.responseType + ' - ' + m.responseText + ' - ' + m.status);
	**/
	public CabinLogResponseModel insertCabinLog(CabinLogModel pCabinLog) {
		TG_UsernameToken_element token = new TG_UsernameToken_element(getUsername(), getPassword());
		String nonce = token.nonce;
		String created = token.created;
		String soapResponse = '';

		String soapBody = '' +
		                  '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:cus="http://xml.thaiairways.com/sapdt/update/customercomplaint" xmlns:v1="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0">' +
		                  '<soapenv:Header>' +
		                  '<wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">' +
		                  '<wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871">' +
		                  '<wsse:Username>FB_SICSE</wsse:Username>' +
		                  '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">tgfbtgfb1</wsse:Password>' +
		                  '<wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce>' +
		                  '<wsu:Created>' + created + '</wsu:Created>' +
		                  '</wsse:UsernameToken>' +
		                  '</wsse:Security>' +
		                  '<head:ReqHeader>' +
		                  '<head:ReqDateTime>' + created + '</head:ReqDateTime>' +
		                  '<head:ReqTxnID>' + getReqTxnID() + '</head:ReqTxnID>' +
		                  '<head:SvcVer>' + getSvcVer() + '</head:SvcVer>' +
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
		                  '<cus:UpdateCustomerComplaintReq>' +
		                  '<v1:Customercomplaint>' +
		                  '<v1:Flightno>' + BE8_GlobalUtility.str(pCabinLog.flightNo) + '</v1:Flightno>' +
		                  '<v1:Flightdate>' + BE8_GlobalUtility.str(pCabinLog.flightDate) + '</v1:Flightdate>' +
		                  '<v1:Acreg>' + BE8_GlobalUtility.str(pCabinLog.aircraftReg) + '</v1:Acreg>' +
		                  '<v1:From>' + BE8_GlobalUtility.str(pCabinLog.departure) + '</v1:From>' +
		                  '<v1:Defecttype>' + BE8_GlobalUtility.str(pCabinLog.defectType) + '</v1:Defecttype>' +
		                  '<v1:Casestatus>' + BE8_GlobalUtility.str(pCabinLog.caseStatus) + '</v1:Casestatus>' +
		                  '<v1:Seqno>' + BE8_GlobalUtility.str(pCabinLog.seqNo) + '</v1:Seqno>' +
		                  '<v1:Ata>' + BE8_GlobalUtility.str(pCabinLog.ata) + '</v1:Ata>' +
		                  '<v1:Complainttxt>' + BE8_GlobalUtility.str(pCabinLog.complaintText) + '</v1:Complainttxt>' +
		                  '<v1:Positionno>' + BE8_GlobalUtility.str(pCabinLog.positionNo) + '</v1:Positionno>' +
		                  '<v1:Blockname>' + BE8_GlobalUtility.str(pCabinLog.blockname) + '</v1:Blockname>' +
		                  '<v1:Auth>' + BE8_GlobalUtility.str(pCabinLog.auth) + '</v1:Auth>' +
		                  '</v1:Customercomplaint>' +
		                  '</cus:UpdateCustomerComplaintReq>' +
		                  '</soapenv:Body>' +
		                  '</soapenv:Envelope>';

		System.debug('Request XML :' + soapBody);
		try {
			soapResponse = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), 'UpdateCustomerComplaint', soapBody);
		} catch (Exception e) {

			CabinLogResponseModel m = new CabinLogResponseModel();
			m.status = false;
			m.errorMessage = e.getMessage();
			return m;
		}

		return getResponseModel(soapResponse);
	}

	public static CabinLogResponseModel getResponseModel(String pXml) {
		CabinLogResponseModel m = new CabinLogResponseModel();

		System.debug(CLASS_NAME + ' response :' + pXml);

		if (pXml != null) {
			if (pXml.indexOf(SUCCESS_MSG) > -1) {
				m.responseType = BE8_GlobalUtility.getMsgBetween(pXml, RESP_TYPE_START_MSG, RESP_TYPE_END_MSG);
				m.responseText = BE8_GlobalUtility.getMsgBetween(pXml, RESP_TEXT_START_MSG, RESP_TEXT_END_MSG);

				if (RESP_TYPE_SAVE_SUCCESS == m.responseType) {
					m.status = true;
					System.debug('Update cabin log successfully');
				} else {
					m.status = false;
				}
			} else if (pXml.indexOf(EXCEPTION_MSG) > -1) {
				m.errorMessage = BE8_GlobalUtility.getMsgBetween(pXml, ERR_DESC_START_MSG, ERR_DESC_END_MSG);
				m.status = false;
			} else {
				m.status = false;
				m.errorMessage = 'Error data has return invalid description.';
			}
		} else {
			m.status = false;
			m.errorMessage = 'Error no data response';
		}

		return m;
	}

	private static void logApplicationLog(String logText) {

		BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_DEBUG,
		                             CLASS_NAME,
		                             'getResponseModel',
		                             logText,
		                             '',
		                             null,
		                             System.currentTimeMillis());
	}
}