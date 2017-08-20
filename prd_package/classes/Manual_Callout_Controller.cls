public with sharing class Manual_Callout_Controller {
	public String requestUrl {get; set;}
	public String response {get; set;}
	public String request {get; set;}
	public String selectedCallout {get; set;}
	public String selectedMethod {get; set;}
	public String contentType {get; set;}
	public Boolean defaultRequest {get; set;}
	public Boolean isCalltoSFDC;
	public Boolean isSOAPFromSFDC;
	public Manual_Callout_Controller() {
		requestUrl = '';
		selectedMethod = 'GET';
		isCalltoSFDC = false;
		isSOAPFromSFDC = false;
	}

	public void run() {
		if (isSOAPFromSFDC) {
			if (selectedCallout == 'POST_ROPManageAward_To_THAI') {
				CSE_SOAP_ROPMANAGEAWARD_WS ws = new CSE_SOAP_ROPMANAGEAWARD_WS();
				if (defaultRequest) {
					response = JSON.serializePretty(ws.burnMileage('NA00001', '', ''));
				} else {
					response = JSON.serializePretty(ws.burnMileageWithRequestBody(request));
				}
			} else if (selectedCallout == 'POST_AppraisalFormAnswer_To_THAI') {
				CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
				response = JSON.serializePretty(ws.submit(request));
			} else if (selectedCallout.contains('Crew_Appraisal_Scenario')
			           && selectedCallout.contains('FROM_SFDC')) {
				CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
				response = JSON.serializePretty(ws.submit(request));
			} else if (selectedCallout.contains('ROPManageAward_Scenario')
			           && selectedCallout.contains('FROM_SFDC')) {
				CSE_SOAP_ROPMANAGEAWARD_WS ws = new CSE_SOAP_ROPMANAGEAWARD_WS();
				response = JSON.serializePretty(ws.burnMileageWithRequestBody(request));
			}
		} else {
			if (!String.isBlank(requestUrl)) {
				Http h = new Http();
				HttpRequest req = new HttpRequest();
				req.setEndpoint(requestUrl);
				req.setMethod(selectedMethod);
				if (!String.isBlank(contentType)) {
					req.setHeader('Content-Type', contentType);
				}

				if (!String.isBlank(request)) {
					req.setBody(request);
				}
				//req.setBody(request);
				if (isCalltoSFDC) {
					req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
				}
				HttpResponse res = h.send(req);
				response = res.getBody();
			}
		}
	}

	public void reset() {
		request = null;
		contentType = '';
		//response = '';
		requestUrl = '';
		selectedMethod = 'GET';
	}

	public void selectCallout() {
		reset();
		if (selectedCallout == 'Get_AllAppraisalForm') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/crewappraisal';
			selectedMethod = 'GET';
			contentType = '';
			request = null;
		} else if (selectedCallout == 'POST_AppraisalFormAnswer_To_SFDC') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/crewappraisal';
			selectedMethod = 'POST';
			contentType = 'application/json';
			//body = '{[{"staffNum":"12103","formNum":"02","evaStaffNum":"15791","evaArlnCd":"TG","evaFltNum":"930","evaFltDt":"10NOV16","comment":"","createdDate":"","subjs":[{"subjNum":"01","items":[{"itemNum":"01","value":""},{"itemNum":"02","value":""}]}]}]}';
			request = '{"crewAppraisalAnswers":[{"staffNum":"12103","formNum":"02","evaFltExtId":"TG0462_10Jan17_1","evaFltSfdcId":"a0IN0000004VSiJMAW", "evaStaffNum":"15791","comment":"","createdDate":"","subjs":[{"subjNum":"01","items":[{"itemNum":"01","value":""},{"itemNum":"02","value":""}]}]}]}';
		} else if (selectedCallout == 'POST_UpgradeSeat_To_SFDC') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/upgradeseat';
			selectedMethod = 'POST';
			contentType = 'application/json';
			request = '{"upgradeSeats":[{"memberId":"12103", "flightSfdcId":"a0IN0000004VSiJMAW", "upgradeFrom" : "Y", "upgradeTo" : "C"}]}';
		} else if (selectedCallout == 'Get_SessionId') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/sessionid';
			selectedMethod = 'GET';
			contentType = '';
			request = null;
		} else if (selectedCallout == 'Inflight_MasterData') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/masterdata/inflight/';
			selectedMethod = 'GET';
			contentType = '';
			request = null;
		} else if (selectedCallout == 'POST_ROPManageAward_To_THAI') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_ROPMANAGEAWARD_WS ws = new CSE_SOAP_ROPMANAGEAWARD_WS();
			request = ws.getRequestBody('NA00001', '', '');
			requestUrl = ws.getEndPoint();
		} else if (selectedCallout == 'POST_AppraisalFormAnswer_To_THAI') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
			List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers = new List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer>();
			MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer = (MB_RESTRequestInfoModel.crewAppraisalFormAnswer)JSON.deserialize('{"staffNum":"12103","formNum":"02","evaFltExtId":"TG0462_10Jan17_1","evaFltSfdcId":"a0IN0000004VSiJMAW", "evaStaffNum":"15791","comment":"","createdDate":"","subjs":[{"subjNum":"01","items":[{"itemNum":"01","value":""},{"itemNum":"02","value":""}]}]}', MB_RESTRequestInfoModel.crewAppraisalFormAnswer.class);
			answers.add(answer);
			request = ws.getRequestBody(answers);
			requestUrl = ws.getEndPoint();

			//ws.getRequestBody(LIST answers, Map crewListMap, Map flightMap);
		} else if (selectedCallout == 'Crew_Appraisal_Scenario1') {
			isCalltoSFDC = true;
			requestUrl = getSalesforceBaseUrl() + '/services/apexrest/crewappraisal';
			selectedMethod = 'POST';
			contentType = 'application/json';
			request = '{"crewAppraisalAnswers":[{"staffNum":"12103","formNum":"02","evaFltExtId":"TG0462_10Jan17_1","evaFltSfdcId":"a0IN0000004VSiJMAW", "evaStaffNum":"15791","comment":"","createdDate":"","subjs":[{"subjNum":"01","items":[{"itemNum":"01","value":""},{"itemNum":"02","value":""}]}]}]}';
		} else if (selectedCallout == 'Crew_Appraisal_Scenario0_FROM_SFDC') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
			request = ws.getRequestBody('<soapenv:Body><crew:InsertCrewAppraisalReq><v1:arg0></v1:arg0></crew:InsertCrewAppraisalReq></soapenv:Body>');
			requestUrl = ws.getEndPoint();
		} else if (selectedCallout == 'Crew_Appraisal_Scenario1_FROM_SFDC') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
			List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers = new List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer>();
			MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer = (MB_RESTRequestInfoModel.crewAppraisalFormAnswer)JSON.deserialize('{"staffNum":"29800","formNum":"02","evaFltExtId":"TG0628_06Feb17_1","evaFltSfdcId":"a0IN0000004X3va", "evaStaffNum":"37792","comment":"","createdDate":"","subjs":[{"subjNum":"01","items":[{"itemNum":"01","value":""},{"itemNum":"02","value":""}]}]}', MB_RESTRequestInfoModel.crewAppraisalFormAnswer.class);

			answers.add(answer);
			request = ws.getRequestBody(answers);
			requestUrl = ws.getEndPoint();
		} else if (selectedCallout == 'Crew_Appraisal_Scenario2_FROM_SFDC') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_SUBMITCREWAPPRAISAL_WS ws = new CSE_SOAP_SUBMITCREWAPPRAISAL_WS();
			List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer> answers = new List<MB_RESTRequestInfoModel.crewAppraisalFormAnswer>();
			String formNum = '02';
			String flightExternalId = 'TG0628_04Feb17_1';
			String staffNum = '29800';
			String evaStaffNum = '37792';
			MB_RESTRequestInfoModel.crewAppraisalFormAnswer answer = MockupData_Test.createCrewAppraisalAnswer(formNum, flightExternalId, evaStaffNum, staffNum);
			answers.add(answer);
			request = ws.getRequestBody(answers);
			requestUrl = ws.getEndPoint();
		} else if (selectedCallout == 'ROPManageAward_Scenario1_FROM_SFDC') {
			isSOAPFromSFDC = true;
			selectedMethod = 'POST';
			CSE_SOAP_ROPMANAGEAWARD_WS ws = new CSE_SOAP_ROPMANAGEAWARD_WS();
			request = ws.getRequestBody('NA00001', '', '');
			requestUrl = ws.getEndPoint();
		}
	}

	public String getSalesforceBaseUrl() {
		return System.URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'my.salesforce.com');
	}

	public List<SelectOption> getCalloutOptions() {
		List<SelectOption> listOption = new List<SelectOption>();
		listOption.clear();
		listOption.add(new SelectOption('----- TO SFDC ------', '----- TO SFDC ------') );
		listOption.add(new SelectOption('POST_UpgradeSeat_To_SFDC', 'Post UpgradeSeat To SFDC'));
		listOption.add(new SelectOption('Get_AllAppraisalForm', 'Get All Appraisal Form') );
		listOption.add(new SelectOption('POST_AppraisalFormAnswer_To_SFDC', 'Post Appraisal Form Answer To SFDC') );
		listOption.add(new SelectOption('Get_SessionId', 'Get SessionId') );
		listOption.add(new SelectOption('Inflight_MasterData', 'Inflight_MasterData') );
		listOption.add(new SelectOption('----- TO THAI ------', '----- TO THAI ------') );
		listOption.add(new SelectOption('POST_ROPManageAward_To_THAI', 'Post ROP Manage Award To THAI') );
		listOption.add(new SelectOption('POST_AppraisalFormAnswer_To_THAI', 'Post Appraisal Form Answer To THAI') );
		listOption.add(new SelectOption('-----             -----', '-----             -----'));
		listOption.add(new SelectOption('----- SIT: Crew Appraisal -----', '----- SIT: Crew Appraisal -----'));
		listOption.add(new SelectOption('----- SIT: Crew Appraisal Mobile -----', '----- SIT: Crew Appraisal Mobile-----'));
		listOption.add(new SelectOption('Crew_Appraisal_Scenario1_Mobile', 'Crew_Appraisal_Scenario1_Mobile'));
		listOption.add(new SelectOption('----- SIT: Crew Appraisal From SFDC -----', '----- SIT: Crew Appraisal From SFDC-----'));
		listOption.add(new SelectOption('Crew_Appraisal_Scenario0_FROM_SFDC', 'Crew_Appraisal_Scenario0_FROM_SFDC'));
		listOption.add(new SelectOption('Crew_Appraisal_Scenario1_FROM_SFDC', 'Crew_Appraisal_Scenario1_FROM_SFDC'));
		listOption.add(new SelectOption('Crew_Appraisal_Scenario2_FROM_SFDC', 'Crew_Appraisal_Scenario2_FROM_SFDC'));
		listOption.add(new SelectOption('----- SIT: ROP Manage Award From SFDC -----', '----- SIT: ROP Manage Award From SFDC-----'));
		listOption.add(new SelectOption('ROPManageAward_Scenario1_FROM_SFDC', 'ROPManageAward_Scenario1_FROM_SFDC'));


		return listOption;
	}

	public List<SelectOption> getMethodOptions() {
		List<SelectOption> listOption = new List<SelectOption>();
		listOption.clear();
		listOption.add(new SelectOption('GET', 'GET') );
		listOption.add(new SelectOption('POST', 'POST') );
		return listOption;

	}

	public String getAllAppraisalForm() {
		return 'getAllAppraisalForm';
	}
}