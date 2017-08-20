public without sharing abstract class Mockup_WebService_Response {
	public String getEndpoint(String endpoint){
		BE8_GlobalConstants constant = new BE8_GlobalConstants();
		Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(constant));
		return BE8_GlobalUtility.getSetting((String)m.get(endpoint));
	}

	public SingleRequestMock getSeccessResponse(String response){
		return new SingleRequestMock(200, 'Complete', response, null);
	}

	public SingleRequestMock getErrorResponse(String response){
		return new SingleRequestMock(500, 'Internal Server Error', response, null);
	}
}