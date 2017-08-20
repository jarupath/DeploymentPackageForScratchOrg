@isTest
private class InFlightIncidentStatusHandlerTest {
	
	@isTest static void testAssignIncidentStatusFromSFDCToMobile() {
		InFlightIncidentStatusHandler statusHandler = new InFlightIncidentStatusHandler();
		MB_RestResponseInfoModel.incident_model incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_RESOLVED, incidentModel);
		Assert.assertEquals(InFlightIncidentStatusHandler.INFLIGHT_INCIDENT_STATUS_RESOLVED, incidentModel.status);
		Assert.assertEquals(0, incidentModel.isVoided);

		incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_CLOSED, incidentModel);
		Assert.assertEquals(InFlightIncidentStatusHandler.INFLIGHT_INCIDENT_STATUS_RESOLVED, incidentModel.status);
		Assert.assertEquals(0, incidentModel.isVoided);

		incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_VOID, incidentModel);
		Assert.assertEquals(1, incidentModel.isVoided);

		incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_DUPLICATE, incidentModel);
		Assert.assertEquals(1, incidentModel.isVoided);

		incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_OPEN, incidentModel);
		Assert.assertEquals(InFlightIncidentStatusHandler.INFLIGHT_INCIDENT_STATUS_DEFAULT, incidentModel.status);
		Assert.assertEquals(0, incidentModel.isVoided);

		incidentModel = new MB_RestResponseInfoModel.incident_model();
		statusHandler.assignIncidentStatusFromSFDCToMobile(BE8_GlobalConstants.CASE_STATUS_ESCALATED, incidentModel);
		Assert.assertEquals(InFlightIncidentStatusHandler.INFLIGHT_INCIDENT_STATUS_DEFAULT, incidentModel.status);
		Assert.assertEquals(0, incidentModel.isVoided);
	}	
}