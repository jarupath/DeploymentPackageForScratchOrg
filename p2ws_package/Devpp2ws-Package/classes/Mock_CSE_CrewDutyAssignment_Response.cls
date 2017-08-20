public with sharing class Mock_CSE_CrewDutyAssignment_Response {
	public Mock_CSE_CrewDutyAssignment_Response() {
	
	}

	public static String getCrewDutyAssignmentEndPoint(){
		return BE8_GlobalUtility.getSetting(BE8_GlobalConstants.SETTING_CREW_DUTY_ASSIGNMENT_ENDPOINT);
	}

	public static SingleRequestMock getCrewDutyAssignmentResponseSuccess(Integer recordNo){
		String response = '' +
					 '<?xml version="1.0" encoding="UTF-8"?> ' +
					 '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"> ' +
					 '    <SOAP-ENV:Header> ' +
					 '        <ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/crew/update/crewrecord/insertdutyassign/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/crew/update/crewrecord/v1_0" xmlns:tns1="http://ws.thaiairways.com/crew/update/crewrecord" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"> ' +
					 '            <ResDateTime>2017-01-31T15:58:56.971+07:00</ResDateTime> ' +
					 '            <ReqTxnID>SFDC_SICSE</ReqTxnID> ' +
					 '            <MWTxnID>SY_TGAIP_1485853136566</MWTxnID> ' +
					 '            <IsLastTxn>true</IsLastTxn> ' +
					 '            <ResCode>SUCCESS</ResCode> ' +
					 '        </ResHeader> ' +
					 '    </SOAP-ENV:Header> ' +
					 '    <SOAP-ENV:Body> ' +
					 '        <ns0:InsertDutyAssignRes xmlns="http://xml.thaiairways.com/crew/update/crewrecord/insertdutyassign/v1_0" xmlns:ns0="http://xml.thaiairways.com/crew/update/crewrecord" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/crew/update/crewrecord/v1_0" xmlns:tns1="http://ws.thaiairways.com/crew/update/crewrecord"> ' +
					 '            <return>' + recordNo + '</return> ' +
					 '        </ns0:InsertDutyAssignRes> ' +
					 '    </SOAP-ENV:Body> ' +
					 '</SOAP-ENV:Envelope> ';
		return new SingleRequestMock(200, 'Complete', response, null);
	}

	public static SingleRequestMock getCrewDutyAssignmentResponseFailure(){
		String response = '' +
					 '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"> ' +
					 '   <SOAP-ENV:Body> ' +
					 '      <SOAP-ENV:Fault> ' +
					 '         <faultcode>SOAP-ENV:Server</faultcode> ' +
					 '         <faultstring>Internal Error</faultstring> ' +
					 '         <faultactor>PROVIDER</faultactor> ' +
					 '         <detail> ' +
					 '            <mwerror:ErrList xmlns:mwerror="http://xml.accenture.com/common/fault" xmlns:tns="http://ws.thaiairways.com/crew/update/crewrecord"> ' +
					 '               <mwerror:Err> ' +
					 '                  <mwerror:ErrCat>40</mwerror:ErrCat> ' +
					 '                  <mwerror:ErrCatDesc>Application Errors</mwerror:ErrCatDesc> ' +
					 '                  <mwerror:ErrCode>soapenv:Server</mwerror:ErrCode> ' +
					 '                  <mwerror:ErrDesc>No Data Insert</mwerror:ErrDesc> ' +
					 '                  <mwerror:ErrSev>Severity-3</mwerror:ErrSev> ' +
					 '                  <mwerror:ErrSrc>FB_SICSE</mwerror:ErrSrc> ' +
					 '                  <mwerror:ErrTgt>CREW</mwerror:ErrTgt> ' +
					 '                  <mwerror:ErrDateTime>2017-01-31T16:36:55.083+07:00</mwerror:ErrDateTime> ' +
					 '                  <mwerror:ErrDetail/> ' +
					 '                  <mwerror:MWErrDetails> ' +
					 '                     <mwerror:ErrHeader> ' +
					 '                        <mwerror:ServiceProvider>CREW</mwerror:ServiceProvider> ' +
					 '                        <mwerror:MWTxnID>SY_TGAIP_1485855415039</mwerror:MWTxnID> ' +
					 '                        <mwerror:ReqTxnID>SFDC_SICSE20170119-092800</mwerror:ReqTxnID> ' +
					 '                        <mwerror:ReqID>FB_SICSE</mwerror:ReqID> ' +
					 '                        <mwerror:MWProcess>ServiceImplementation/ws.thaiairways.com/CREW/Update/CrewRecord/Operations/InsertDutyAssign.process</mwerror:MWProcess> ' +
					 '                        <mwerror:MWActivity>AppError – Fault</mwerror:MWActivity> ' +
					 '                     </mwerror:ErrHeader> ' +
					 '                  </mwerror:MWErrDetails> ' +
					 '               </mwerror:Err> ' +
					 '            </mwerror:ErrList> ' +
					 '         </detail> ' +
					 '      </SOAP-ENV:Fault> ' +
					 '   </SOAP-ENV:Body> ' +
					 '</SOAP-ENV:Envelope> ';
		return new SingleRequestMock(200, 'Complete', response, null);
	}
}