public class MultiRequestMock implements HttpCalloutMock {
	Map<String, HttpCalloutMock> requests;

	public MultiRequestMock(Map<String, HttpCalloutMock> requests) {
		this.requests = requests;
	}

	public HTTPResponse respond(HTTPRequest req) {
		HttpCalloutMock mock = requests.get(req.getEndpoint());
		if (mock != null) {
			return mock.respond(req);
		} else {
			System.debug('req.getEndpoint() :' + req.getEndpoint());
			throw new CustomException('HTTP callout not supported for test methods : ' + req.getEndpoint());
		}
	}

	public void addRequestMock(String url, HttpCalloutMock mock) {
		requests.put(url, mock);
	}
}