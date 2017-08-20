@isTest
public class MockCabinReportWSResponseGenerator implements HttpCalloutMock{
	protected Integer code;
    protected String status;
    protected String body;
    protected Map<String, String> responseHeaders;

    public MockCabinReportWSResponseGenerator(){
    	this.code = 200;
        this.status = 'SUCCESS';
        this.body = '' +
        	'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">' +
				'<soapenv:Body>' +
					'<ns2:InsertCabinReportResponse xmlns:ns2="http://bean.crmsinterface.cw.tg/">' +
  						'<return>T00061/2016</return>' +
					'</ns2:InsertCabinReportResponse>' +
  				'</soapenv:Body>' +
			'</soapenv:Envelope>';
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