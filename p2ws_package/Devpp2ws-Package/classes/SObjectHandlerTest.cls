@isTest
private class SObjectHandlerTest {

	@isTest static void testGetFieldOnFieldSet() {
		SObjectHandler.getFieldOnFieldSet('Case', 'NewEdit_FlightInformation');
	}

	@isTest static void testGetAllCustomObjects() {
		SObjectHandler.getAllCustomSObjects();
	}

	@isTest static void testGetFieldDescribe() {
		SObjectHandler.getFieldDescribe('Case', 'Subject');
	}

	@isTest static void testInstantOf(){
		SObject obj = SObjectHandler.instantOf('Case');
		Assert.assert(obj instanceof Case);
	}

}