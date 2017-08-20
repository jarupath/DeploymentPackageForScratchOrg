@isTest
public class MockROPEnrollmentWSFactory {
	public class MockROPEnrollmentWSSUCCESS  implements HttpCalloutMock {
		protected Integer code;
		protected String status;
		protected String body;
		protected Map<String, String> responseHeaders;

		public MockROPEnrollmentWSSUCCESS() {
			this.code = 200;
			this.status = 'SUCCESS';
			this.body = '<soap-env:Envelope xmlns:soap-env="http://www.w3.org/2003/05/soap-envelope"><soap-env:Header><ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/rop/enroll/member/enrollropmember/v1_0" xmlns:ns0="http://www.w3.org/2003/05/soap-envelope" xmlns:tns="http://ws.thaiairways.com/rop/enroll/member/v1_0" xmlns:tns1="http://ws.thaiairways.com/rop/enroll/member" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><ResDateTime>2017-03-29T16:07:37.91+07:00</ResDateTime><ReqTxnID>ROP_REQ_TXN_ID20170329-160736</ReqTxnID><MWTxnID>SY_TGAIP_1490778456646</MWTxnID><ResCode>SUCCESS</ResCode></ResHeader></soap-env:Header><soap-env:Body><ns0:EnrollROPMemberRes xmlns="http://xml.thaiairways.com/rop/enroll/member/enrollropmember/v1_0" xmlns:ns0="http://xml.thaiairways.com/rop/enroll/member" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/rop/enroll/member/v1_0" xmlns:tns1="http://ws.thaiairways.com/rop/enroll/member"><AddMainProfileRS><Success><Code>I110</Code><Message>ADD has been successfully completed.</Message></Success></AddMainProfileRS><AddPendingEnrolmentRS/><UpdateCustomerSSRRS><Success><Code>I120</Code><Message>Successfully Updated</Message></Success></UpdateCustomerSSRRS><UpdateMemberCommunicationPreferenceRS><Success><Code>I120</Code><Message>Successfully Updated</Message></Success></UpdateMemberCommunicationPreferenceRS></ns0:EnrollROPMemberRes></soap-env:Body></soap-env:Envelope>';
			this.responseHeaders = new Map<String, String> {'Content-Type' => 'application/xml'};
		}

		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			for (String key : this.responseHeaders.keySet()) {
				res.setHeader(key, this.responseHeaders.get(key));
			}
			res.setBody(this.body);
			res.setStatusCode(this.code);
			res.setStatus(this.status);
			return res;
		}
	}
}