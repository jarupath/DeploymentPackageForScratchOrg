@isTest
private class TriggerActivatorTest {
	
	@isTest static void testIsTriggerActivated() {
		Trigger_Activation__c act = Trigger_Activation__c.getOrgDefaults();
		act.Case_Trigger__c = true;
		upsert act;
		Boolean isCaseTriggerActivated = TriggerActivator.isTriggerActivated(TriggerActivator.CASE_TRIGGER);
		Assert.assert(isCaseTriggerActivated);
	}

	@isTest static void testOverrideTriggerActivation() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		Boolean isCaseTriggerActivated = TriggerActivator.isTriggerActivated(TriggerActivator.CASE_TRIGGER);
		Assert.assert(!isCaseTriggerActivated);
	}
}