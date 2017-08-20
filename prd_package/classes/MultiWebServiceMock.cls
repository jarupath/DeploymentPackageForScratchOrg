public class MultiWebServiceMock implements WebServiceMock {
    Map<String, WebServiceMock> requests;

    public MultiWebServiceMock(Map<String, WebServiceMock> requests) {
        this.requests = requests;
    }

    public void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) {
        WebServiceMock mock = requests.get(endpoint);
        if (mock != null) {
            mock.doInvoke(stub, request, response, endpoint, soapAction, requestName, responseNS, responseName, responseType);
        } else {
            System.debug('req.getEndpoint() :' + endpoint);
            throw new CustomException('WebServiceMock not supported for test methods : ' + endpoint);
        }

        return;
    }

    public void addRequestMock(String url, WebServiceMock mock) {
        requests.put(url, mock);
    }
}