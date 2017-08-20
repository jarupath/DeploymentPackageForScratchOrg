@isTest
public class MockCabinLOGWSFactory {

public class MockCABINLOGWSResponseGeneratorSUCCESS  implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

  	public MockCABINLOGWSResponseGeneratorSUCCESS() {
  		this.code = 200;
          this.status = 'SUCCESS';
          this.body = '' +
          	'<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
     			'<SOAP-ENV:Header>' +
        			'<ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
       				'<ResDateTime>2016-11-01T15:14:17.676+07:00</ResDateTime>' +
           			'<ReqTxnID>AEK11111111112</ReqTxnID>' +
           			'<MWTxnID>SY_TGAIP_1477988056718</MWTxnID>' +
           			'<ResCode>SUCCESS</ResCode>' +
        			'</ResHeader>' +
     			'</SOAP-ENV:Header>' +
     			'<SOAP-ENV:Body>' +
        			'<ns0:UpdateCustomerComplaintRes xmlns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://xml.thaiairways.com/sapdt/update/customercomplaint" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint">' +
           			'<Customercomplaintreply>' +
              			'<Responsetype>S</Responsetype>' +
              			'<Responsetext>Order UA007C011016 saved with notification UA007C011016</Responsetext>' +
       				'</Customercomplaintreply>' +
        			'</ns0:UpdateCustomerComplaintRes>' +
     			'</SOAP-ENV:Body>' +
  		'</SOAP-ENV:Envelope>';
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

public class MockCABINLOGWSResponseGeneratorDUP  implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockCABINLOGWSResponseGeneratorDUP() {
      this.code = 200;
          this.status = 'SUCCESS';
          this.body = '' +
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
          '<SOAP-ENV:Header>' +
              '<ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
              '<ResDateTime>2016-11-01T15:14:17.676+07:00</ResDateTime>' +
                '<ReqTxnID>AEK11111111112</ReqTxnID>' +
                '<MWTxnID>SY_TGAIP_1477988056718</MWTxnID>' +
                '<ResCode>SUCCESS</ResCode>' +
              '</ResHeader>' +
          '</SOAP-ENV:Header>' +
          '<SOAP-ENV:Body>' +
              '<ns0:UpdateCustomerComplaintRes xmlns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://xml.thaiairways.com/sapdt/update/customercomplaint" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint">' +
                '<Customercomplaintreply>' +
                    '<Responsetype>S</Responsetype>' +
                    '<Responsetext>SEQ has been completed</Responsetext>' +
              '</Customercomplaintreply>' +
              '</ns0:UpdateCustomerComplaintRes>' +
          '</SOAP-ENV:Body>' +
      '</SOAP-ENV:Envelope>';
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

  public class MockCABINLOGWSResponseGeneratorERROR  implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockCABINLOGWSResponseGeneratorERROR() {

      this.code = 500;
          this.status = 'ERROR';
          this.body = '' +
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
          '<SOAP-ENV:Header>' +
              '<ResHeader xmlns="http://xml.accenture.com/common/header" xmlns:ns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
              '<ResDateTime>2016-11-01T15:14:17.676+07:00</ResDateTime>' +
                '<ReqTxnID>AEK11111111112</ReqTxnID>' +
                '<MWTxnID>SY_TGAIP_1477988056718</MWTxnID>' +
                '<ResCode>ERROR</ResCode>' +
              '</ResHeader>' +
          '</SOAP-ENV:Header>' +
          '<SOAP-ENV:Body>' +
              '<ns0:UpdateCustomerComplaintRes xmlns="http://xml.thaiairways.com/sapdt/update/customercomplaint/UpdateCustomerComplaint/v1_0" xmlns:ns0="http://xml.thaiairways.com/sapdt/update/customercomplaint" xmlns:ns2="http://xml.accenture.com/common/header" xmlns:tns="http://ws.thaiairways.com/sapdt/update/customercomplaint/v1_0" xmlns:tns1="http://ws.thaiairways.com/sapdt/update/customercomplaint">' +
                '<Customercomplaintreply>' +
                    '<Responsetype>E</Responsetype>' +
                    '<Responsetext>Error from SAP</Responsetext>' +
              '</Customercomplaintreply>' +
              '</ns0:UpdateCustomerComplaintRes>' +
          '</SOAP-ENV:Body>' +
      '</SOAP-ENV:Envelope>';
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

  public class MockCABINLOGWSResponseGeneratorNULL  implements HttpCalloutMock{
    protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockCABINLOGWSResponseGeneratorNULL() {}

    public HTTPResponse respond(HTTPRequest req) {

          HttpResponse res = new HttpResponse();
          for (String key : this.responseHeaders.keySet()) {
              res.setHeader(key, this.responseHeaders.get(key));
          }
          res.setBody(null);
          res.setStatusCode(500);
          res.setStatus('ERROR');
          return res;
      }
  }
}