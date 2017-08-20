global without sharing class CSE_SOAPCrewDutyAssignment_WS extends CSE_SOAP_WS {
	public static final String CLASS_NAME = 'CSE_SOAPCrewDutyAssignment_WS';
	
	public override String getEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_ENDPOINT);
	}

	public override String getUsername(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_USERNAME);
	}

	public override String getPassword(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_PASSWORD);
	}

	private static final String END_ENVALOPE = '</crew:InsertDutyAssignReq></soapenv:Body></soapenv:Envelope>';
	private static final String RESP_TYPE_START_MSG = '<ResCode>';
	private static final String RESP_TYPE_END_MSG = '</ResCode>';
	private static final String RESP_TEXT_START_MSG = '<return>';
	private static final String RESP_TEXT_END_MSG = '</return>';
	public class WS_CrewDutyAssignment_Model{
		public String cabinduty;
		public String fltDateLT; //EX. 26sep2016
		public String perno;
		public String remark;
		public String sector;
		public String updtstatus;
		public String fltno;
	}

	global class WS_CrewDutyAssignmentResponse_Model{
		public String status;
		public Integer recordNo;
	}

	public static String getXmlSoapBody(WS_CrewDutyAssignment_Model model){
		return getXmlSoapBody(new List<WS_CrewDutyAssignment_Model>{model});
	}

	public static String getXmlSoapBody(List<WS_CrewDutyAssignment_Model> modelList){
		String returnStr = '';
		for(WS_CrewDutyAssignment_Model model : modelList){
			returnStr += '<v1:arg0>'; //rootnode
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:cabinduty', model.cabinduty);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:fltDateUTC', model.fltDateLT);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:fltno', model.fltno);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:perno', model.perno);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:remarks', model.remark);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:sector', model.sector);
			returnStr += BE8_GlobalUtility.xmlGenerator('v1:updtstatus', model.updtstatus);
			returnStr += '</v1:arg0>';
		}
		returnStr += END_ENVALOPE;

		return returnStr;
	}

	public static String getXmlSoapHeader(String username, String password, String nonce, String created, String reqTxnId, String svcVer, String isLastTxn, String reqId){
		String returnStr = ''
				+ '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:head="http://xml.accenture.com/common/header" xmlns:crew="http://xml.thaiairways.com/crew/update/crewrecord" xmlns:v1="http://xml.thaiairways.com/crew/update/crewrecord/insertdutyassign/v1_0"> '
				+ '     <soapenv:Header> '
				+ '         <wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"> '
				+ '             <wsse:UsernameToken wsu:Id="UsernameToken-E70691ACBDEFEC750814238295617871"> '
				+ '                 <wsse:Username>' + username + '</wsse:Username> '
				+ '                 <wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">' + password + '</wsse:Password> '
				+ '                 <wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">' + nonce + '</wsse:Nonce> '
				+ '                 <wsu:Created>' + created + '</wsu:Created> '
				+ '             </wsse:UsernameToken> '
				+ '         </wsse:Security> '
				+ '         <head:ReqHeader> '
				+ '             <head:ReqDateTime>2017-01-18T13:20:00-05:00</head:ReqDateTime> '
				+ '             <head:ReqTxnID>' + reqTxnId + '</head:ReqTxnID> '
				+ '             <head:SvcVer>' + svcVer + '</head:SvcVer> '
				+ '             <head:IsLastTxn>' + isLastTxn + '</head:IsLastTxn> '
				+ '             <head:Credentials> '
				+ '                 <head:MWCredential> '
				+ '                     <head:ReqID>' + reqId + '</head:ReqID> '
				+ '                     <head:ReqPwd/> '
				+ '                     <head:UserID/> '
				+ '                 </head:MWCredential> '
				+ '             </head:Credentials> '
				+ '         </head:ReqHeader> '
				+ '     </soapenv:Header> '
				+ '     <soapenv:Body> '
				+ '         <crew:InsertDutyAssignReq> ';
		return returnStr;
	}

	public String getSoapRequest(List<WS_CrewDutyAssignment_Model> modelList){
		//AppLogger applogger = new Applogger();
		TG_UsernameToken_element token = new TG_UsernameToken_element(getUsername(), getPassword());
		String username = getUsername();
		String password = getPassword();
		String nonce = token.nonce;
		String created = token.created;
		String reqTxnId = BE8_GlobalUtility.generateTransactionId(BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_REQ_TXN_ID));
		String svcVer = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_SVC_VER);
		String isLastTxn = 'true';
		String reqId = BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_REQ_ID);
		String soapBody = '';
		soapBody += getXmlSoapHeader(username, password, nonce, created, reqTxnId, svcVer, isLastTxn, reqId);
		soapBody += getXmlSoapBody(modelList);
		return soapBody;
	}

	public WS_CrewDutyAssignmentResponse_Model callout(List<WS_CrewDutyAssignment_Model> modelList){
		String requestStr = getSoapRequest(modelList);
		String responseStr = '';
		WS_CrewDutyAssignmentResponse_Model responseModel = null;
		try{
			responseStr = BE8_GlobalUtility.makeSOAPRequestCallout(getEndPoint(), 'InsertDutyAssign', requestStr);
			System.debug('JK: requestStr: ' + requestStr);
			System.debug('JK: responseStr: ' + responseStr);

			//create application log
			Map<String, String> attachMap = new Map<String, String>();
			attachMap.put('request', requestStr);
			attachMap.put('response', responseStr);
			responseModel = getResponse(responseStr);
			if(responseModel != null){
				if(responseModel.status == 'ERROR'){
					AppLogger.addLogModel(BE8_GlobalConstants.LEVEL_ERROR, CLASS_NAME, 'callout', 'WS_CrewDutyAssignment_Model: ' + JSON.serialize(modelList), null, null, null, attachMap);	
				}
				else{
					AppLogger.addLogModel(BE8_GlobalConstants.LEVEL_INFO, CLASS_NAME, 'callout', 'WS_CrewDutyAssignment_Model: ' + JSON.serialize(modelList), null, null, null, attachMap);
				}
			}
			else{
				AppLogger.addLogModel(BE8_GlobalConstants.LEVEL_INFO, CLASS_NAME, 'callout', 'WS_CrewDutyAssignment_Model: ' + JSON.serialize(modelList), 'Response model is equal to NULL', null, null, attachMap);
			}
		}
		catch(Exception e){
			Map<String, String> attachMap = new Map<String, String>();
			attachMap.put('request', requestStr);
			if(responseStr != null && responseStr != ''){
				attachMap.put('response', responseStr);
			}
			AppLogger.addLogModel(BE8_GlobalConstants.LEVEL_ERROR, CLASS_NAME, 'callout', 'WS_CrewDutyAssignment_Model: ' + JSON.serialize(modelList), 'ERROR while callout', null, null, attachMap);
			return null;
		}
		return responseModel;
	}

	public static List<WS_CrewDutyAssignment_Model> getcrewDutyAssignmentModelListFromMBModel(List<MB_RESTRequestInfoModel.crewDutyAssignment_model> crewAssignmentMBModelList, String flightDateLT, String sector, String flightNo){
		List<WS_CrewDutyAssignment_Model> returnList = new List<WS_CrewDutyAssignment_Model>();
		for(MB_RESTRequestInfoModel.crewDutyAssignment_model crewAssignmentMBModel : crewAssignmentMBModelList){
			WS_CrewDutyAssignment_Model model = new WS_CrewDutyAssignment_Model();
			model.cabinduty = crewAssignmentMBModel.newDuty;
			model.fltno = flightNo.remove('TG');
			model.fltDateLT = BE8_DateUtility.convertToTGFlightDateformat(flightDateLT, '-');
			model.perno = crewAssignmentMBModel.perno;
			model.remark = 'Duty of crew no ' + crewAssignmentMBModel.perno + ' is changed from ' + crewAssignmentMBModel.oldDuty + ' to ' + crewAssignmentMBModel.newDuty;
			model.sector = sector.remove('-');
			model.updtstatus = crewAssignmentMBModel.updtstatus;

			returnList.add(model);
		}
		return returnList;
	}

	public static WS_CrewDutyAssignmentResponse_Model getResponse(String response){
		WS_CrewDutyAssignmentResponse_Model responseModel = null;
		if(!String.isBlank(response)){
			responseModel = new WS_CrewDutyAssignmentResponse_Model();
			if(response.indexOf(RESP_TYPE_START_MSG) != -1){
				responseModel.status = 'SUCCESS';
				responseModel.recordNo = Integer.valueOf(BE8_GlobalUtility.getMsgBetween(response, RESP_TEXT_START_MSG, RESP_TEXT_END_MSG));
			}
			else{
				responseModel.status = 'ERROR';
				responseModel.recordNo = -1;
			}
		}
		return responseModel;
	}
}