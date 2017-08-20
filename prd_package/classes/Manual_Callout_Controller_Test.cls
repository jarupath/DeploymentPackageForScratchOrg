@isTest
private class Manual_Callout_Controller_Test
{
	@isTest
	static void testGetOptions() {
		Manual_Callout_Controller ctrl = new Manual_Callout_Controller();
		ctrl.getCalloutOptions();
		ctrl.getMethodOptions();
	}

	@isTest 
	static void testSelectCallout() {
		Manual_Callout_Controller ctrl = new Manual_Callout_Controller();
		ctrl.selectedCallout = 'Get_AllAppraisalForm';
		ctrl.selectCallout();

		Assert.assert(ctrl.requestUrl.contains('/services/apexrest/crewappraisal'));
	}

	@isTest
	static void testRun() {
		Manual_Callout_Controller ctrl = new Manual_Callout_Controller();
		ctrl.selectedCallout = 'Get_AllAppraisalForm';
		ctrl.selectCallout();
		Test.setMock(HttpCalloutMock.class, new Mock_Http_ResponseGenerator());
		ctrl.run();
		Assert.assert(!String.isBlank(ctrl.response));
	}
}