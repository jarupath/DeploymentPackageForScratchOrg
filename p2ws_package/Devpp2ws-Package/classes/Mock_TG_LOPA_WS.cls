@isTest
global class Mock_TG_LOPA_WS {
	global class MockLOPAErrorTestLog implements WebServiceMock {
		global void doInvoke(
		    Object stub,
		    Object request,
		    Map<String, Object> response,
		    String endpoint,
		    String soapAction,
		    String requestName,
		    String responseNS,
		    String responseName,
		    String responseType) {

			TG_LOPA_Req.GetSeatMapRes result = new TG_LOPA_Req.GetSeatMapRes();
			result.seatmapInfo = new List<TG_LOPA_Req.seatmapInfo_element>();
			result.seatmapInfo.add(new TG_LOPA_Req.seatmapInfo_element());
			response.put('response_x', result);
		}
	}
}