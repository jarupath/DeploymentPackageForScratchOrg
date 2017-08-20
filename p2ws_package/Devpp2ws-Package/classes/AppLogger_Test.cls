@isTest
private class AppLogger_Test {
	@testSetup static void setup(){
		MockupData_Test.initialApplicationLogCustomSetting();
	}
	
	@isTest static void testReferenceID() {
		AppLogger.setReferenceId('testRefernceID');
		AppLogger.setReferenceId('testRefernceID2');
		System.assertEquals('testRefernceID', AppLogger.getReferenceId());
	}
	

	@isTest static void testLog() {
		AppLogger.error('sourceClass_error', 'sourceFunction_error', 'referenceId_error', 'logMessage', null);
		AppLogger.debug('sourceClass_debug', 'sourceFunction_debug', 'referenceId_debug', 'logMessage_debug', null);
		AppLogger.warn('sourceClass_warn', 'sourceFunction_warn', 'referenceId_warn', 'logMessage_warn', null);
		Test.startTest();
		AppLogger.insertLogs();
		Test.stopTest();

		List<Application_Log__c> logs = [SELECT Id FROM Application_Log__c];
		//Assert.assertEquals(2, logs.size());
	}

	@isTest static void testAdd() {
		AppLogger.add(BE8_GlobalConstants.LEVEL_DEBUG, 'sourceClass', 'sourceFunction', 'logMessage', 'payLoad', null, System.currentTimeMillis());
		Test.startTest();
		AppLogger.insertLogs();
		Test.stopTest();

		List<Application_Log__c> logs = [SELECT Id FROM Application_Log__c];
		Assert.assertEquals(1, logs.size());
	}	

	@isTest static void testDebugLog() {
		AppLogger.debug('sourceClass_debug', 'sourceFunction_debug', 'referenceId_debug', 'logMessage_debug', null);
		AppLogger.debugLogs();
	}

	@isTest static void testAddLogModel() {
        Map<String, String> contentMapByName = new Map<String, String>();
        contentMapByName.put('Attachment1', 'Content1');
		AppLogger.addLogModel(BE8_GlobalConstants.LEVEL_DEBUG, 'sourceClass', 'sourceFunction', 'logMessage', 'payLoad', null, System.currentTimeMillis(), contentMapByName);
		Map<String, Application_Log__c> logMap = AppLogger.getLogModel();
		Assert.assertEquals(1, logMap.size());

		Map<String, List<Attachment>> attachMap = AppLogger.getAttachModel();
		Assert.assertEquals(1, attachMap.size());

		AppLogger.insertLogModel();
		List<Application_Log__c> actualLogs = [SELECT Id FROM Application_Log__c];
		List<Attachment> actualAttachments = [SELECT Id FROM Attachment];
		Assert.assertEquals(1, actualLogs.size());
		Assert.assertEquals(1, actualAttachments.size());
	}

	@isTest static void testCreateAttachment() {
        Map<String, String> contentMapByName = new Map<String, String>();
        contentMapByName.put('Attachment1', 'Content1');
    	List<Attachment> attachList = AppLogger.createAttachment(contentMapByName, 'sourceClass', 'sourceFunction');
    	System.assertEquals(1, attachList.size());
	}
}