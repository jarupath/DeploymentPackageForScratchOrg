public without sharing class Mock_CSE_DCSPax_Response extends Mockup_WebService_Response {

	public String getDCSPaxEndpoint(){
		String constansname = 'SETTING_NEW_PAX_LIST_ENDPOINT';
		return super.getEndpoint(constansname);
	}

	public SingleRequestMock getDCSPaxSuccessResponse(){
		String response = Mockup_DCS_Pax.getPSTDCSPaxResponse();
		return super.getSeccessResponse(response);
	}

	public SingleRequestMock getDCSPaxErrorResponse(){
		String response = Mockup_DCS_Pax.getDCSPaxErrorResponse();
		return super.getErrorResponse(response);
	}
}