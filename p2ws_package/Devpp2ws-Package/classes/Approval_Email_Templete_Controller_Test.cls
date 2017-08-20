@isTest
private class Approval_Email_Templete_Controller_Test {
	
	@isTest static void testConstructor() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		Case testCase = MockupData_Test.createCase(null, BE8_GlobalConstants.CASE_STATUS_PENDING, BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		insert testCase;
		Compensation__c compensation = new Compensation__c(CaseId__c = testCase.Id);
		compensation.Compensation_Tools__c = 'Cash';
		compensation.Status__c = BE8_GlobalConstants.CASE_STATUS_PENDING;
		insert compensation;
		Compensation__c compensation2 = new Compensation__c(CaseId__c = testCase.Id);
		compensation2.Compensation_Tools__c = 'Miles';
		compensation2.Status__c = BE8_GlobalConstants.CASE_STATUS_PENDING;
		insert compensation2;
		Apexpages.currentpage().getparameters().put('id', testCase.Id);
		Approval_Email_Templete_Controller ctrl = new Approval_Email_Templete_Controller();
		ctrl.getCompensations();
	}
}