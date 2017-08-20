@isTest
private class Case_Trigger_Test {
	@isTest static void testClosedCaseShouldChangeRecordType() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();

		User groundUser = MockupData_User_Test.createUserIfNotExist('Ground Customer Service', 'KO_B_Ground_Flight_Manager_Controller_Gate');

		System.runAs(groundUser) {
		    Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'Ground_Service');
		    newCase.DEP_STN__c = 'BKK';
		    insert newCase;

		    Test.startTest();
		    newCase.Status = 'Closed';
		    update newCase;
		    Test.stopTest();
		}

		Id expectRecordTypeId = BE8_RecordTypeRepository.getInstance().getRecordTypeMapByDevName('Case').get('Ground_Service_Closed').Id;

		Case actualCase = [SELECT Id, Status, RecordTypeId FROM Case];
		Assert.assertEquals('Closed', actualCase.Status);
		Assert.assertEquals(expectRecordTypeId, actualCase.RecordTypeId);
	}

	@isTest static void testSumOfImpactWhenInsert() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
        Aircraft__c aircraft = MockupData_Test.createAircraft('HS-TUA', 'HS-TUA', '787');
        insert aircraft;

        List<Case> casesForInsert = new List<Case>();
		Case case1 = MockupData_Test.createCase('0001', 'New', 'Maintenance');
		case1.A_C_REG_ID__c = aircraft.Id;
		case1.DEP_STN__c = 'BKK';
		casesForInsert.add(case1);
		insert casesForInsert;

		List<Case_Group_Member__c> cgmsForInsert = new List<Case_Group_Member__c>();
		Case_Group_Member__c cgm1 = MockupData_Test.createCaseGroupMember(case1.Id);
		cgm1.Impact__c = 'Block';
		cgmsForInsert.add(cgm1);

		Case_Group_Member__c cgm3 = MockupData_Test.createCaseGroupMember(case1.Id);
		cgmsForInsert.add(cgm3);

		Test.startTest();
		insert cgmsForInsert;
		Test.stopTest();

		Aircraft__c actualAircraft = [SELECT Id, Number_Of_Completes__c, Number_Of_Blocks__c, Number_Of_NoActions__c FROM Aircraft__c WHERE Id = :aircraft.Id];
		System.assertEquals(1, actualAircraft.Number_Of_Blocks__c);
		System.assertEquals(1, actualAircraft.Number_Of_NoActions__c);
	}

	@isTest static void testSumOfImpact() {
		MockupData_Test.initializeSystemConfigurationCustomSetting();
        Aircraft__c aircraft = MockupData_Test.createAircraft('HS-TUA', 'HS-TUA', '787');
        insert aircraft;

        List<Case> casesForInsert = new List<Case>();
		Case case1 = MockupData_Test.createCase('0001', 'New', 'Maintenance');
		case1.A_C_REG_ID__c = aircraft.Id;
		casesForInsert.add(case1);
		insert casesForInsert;

		List<Case_Group_Member__c> cgmsForInsert = new List<Case_Group_Member__c>();
		Case_Group_Member__c cgm1 = MockupData_Test.createCaseGroupMember(case1.Id);
		cgm1.Impact__c = 'Block';
		cgmsForInsert.add(cgm1);

		Case_Group_Member__c cgm3 = MockupData_Test.createCaseGroupMember(case1.Id);
		cgmsForInsert.add(cgm3);
		insert cgmsForInsert;

		//Test.startTest();

		//Test.stopTest();

		Aircraft__c actualAircraft = [SELECT Id, Number_Of_Completes__c, Number_Of_Blocks__c, Number_Of_NoActions__c FROM Aircraft__c WHERE Id = :aircraft.Id];
		System.assertEquals(1, actualAircraft.Number_Of_Blocks__c);
		System.assertEquals(1, actualAircraft.Number_Of_NoActions__c);

		Case_Group_Member__c cgm2 = MockupData_Test.createCaseGroupMember(case1.Id);
		cgm2.Impact__c = 'Block';
		insert cgm2;

		actualAircraft = [SELECT Id, Number_Of_Blocks__c, Number_Of_NoActions__c FROM Aircraft__c WHERE Id = :aircraft.Id];
		System.assertEquals(2, actualAircraft.Number_Of_Blocks__c);
		System.assertEquals(1, actualAircraft.Number_Of_NoActions__c);

		cgm1.Impact__c = 'Complete';
		update cgm1;

		cgm3.Impact__c = 'Block';
		update cgm3;

		actualAircraft = [SELECT Id, Number_Of_Completes__c, Number_Of_Blocks__c, Number_Of_NoActions__c FROM Aircraft__c WHERE Id = :aircraft.Id];
		System.assertEquals(2, actualAircraft.Number_Of_Blocks__c);
		System.assertEquals(1, actualAircraft.Number_Of_Completes__c);
	}
}