@isTest
public class PreFlight_Mock {
	public PreFlight_Mock() {

	}

	//Map<String, WebServiceMock> webserviceMockMap = new Map<String, WebServiceMock>();
	//Map<String, HttpCalloutMock> httpCalloutMockMap = new Map<String, HttpCalloutMock>();

//responseMapByEndPoint.put(Mock_CSE_NewPaxList_Response.getNewPaxListEndPoint(), Mock_CSE_NewPaxList_Response.getNewPaxListResponseSuccess());

	public static Map<String, WebServiceMock> mockPassengerWS() {
		Map<String, WebServiceMock> responseMapByEndPoint = new Map<String, WebServiceMock>();
		String endpoint = CSE_SOAPUpdatePax_WS.getEndPoint();
		responseMapByEndPoint.put(endpoint, new Mock_TG_Pax_WS.MockPax());
		return responseMapByEndPoint;
	}

	public static Map<String, HttpCalloutMock> mockNewPassengerWS() {
		Map<String, HttpCalloutMock> httpCalloutMockMap = new Map<String, HttpCalloutMock>();
		String endpoint = (new CSE_SOAPNewPaxList_WS()).getEndPoint();
		httpCalloutMockMap.put(endpoint, Mock_CSE_NewPaxList_Response.getNewPaxListResponseSuccess());
		return httpCalloutMockMap;
	}

	public static Map<String, HttpCalloutMock> mockCrewOnFlight() {
		Map<String, HttpCalloutMock> responseMapByEndPoint = new Map<String, HttpCalloutMock>();
		String flightEndPoint = (new CSE_SOAPCREWONFLIGHT_WS()).getEndPoint();
		//responseMapByEndPoint.put(flightEndPoint, new MockFlightWSResponseGenerator());
		return responseMapByEndPoint;
	}

	public static Map<String, HttpCalloutMock> mockFlightWS() {
		Map<String, HttpCalloutMock> responseMapByEndPoint = new Map<String, HttpCalloutMock>();
		String flightEndPoint = (new CSE_SOAPFLIGHT_WS()).getEndPoint();
		responseMapByEndPoint.put(flightEndPoint, new MockFlightWSResponseGenerator());
		return responseMapByEndPoint;
	}

	public static void mockMultiCallout(Map<String, WebServiceMock> webServiceMockMap, Map<String, HttpCalloutMock> httpCalloutMockMap) {
		if (webserviceMockMap != null) {
			WebServiceMock multiWebServiceMock = new MultiWebServiceMock(webServiceMockMap);
			Test.setMock(WebServiceMock.class, multiWebServiceMock);
		}

		if (httpCalloutMockMap != null) {
			HttpCalloutMock multiHttpCalloutMock = new MultiHttpCalloutMock(httpCalloutMockMap);
			Test.setMock(HttpCalloutMock.class, multiHttpCalloutMock);
		}
	}
}