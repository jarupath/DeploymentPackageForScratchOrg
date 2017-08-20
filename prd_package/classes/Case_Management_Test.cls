@isTest
private without sharing class Case_Management_Test {

	@testSetup static void setUp(){
		MockupData_Test.initializeSystemConfigurationCustomSetting();
		
		List<Flight__c> flightList = new List<Flight__c>();
		
		Flight__c tgxxx = new Flight__c();
		tgxxx.Name = 'TGXXX';
		flightList.add(tgxxx);

		Flight__c f1 = new Flight__c();
		f1.Name = 'TG628 / 25MAR25';
		flightList.add(f1);

		insert flightList;
		List<Passenger__c> paxList = MockupData_Test.createPassengerList(f1.Id, 1);
		insert paxList;
	}

	@isTest static void testChangecompensationapproval() {
		Case_Management caseManagement = new Case_Management();
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		TriggerActivator.overrideTriggerActivation(TriggerActivator.COMPENSATION_TRIGGER, false);

		List<Case> caseList = new List<Case>();
		Set<Id> caseIdSet = new Set<Id>();


		Case approvedCase = new Case(Approval_Status__c = Case_Management.APPROVED);
		insert approvedCase;
		Compensation__c toBeApprovedCompensation = MockupData_Test.createCompensation(approvedCase.Id);
		toBeApprovedCompensation.Status__c = Case_Management.PENDING;
		insert toBeApprovedCompensation;

		Case pendingCase = new Case(Approval_Status__c = Case_Management.PENDING);
		insert pendingCase;
		Compensation__c pendingCompensation = MockupData_Test.createCompensation(pendingCase.Id);
		pendingCompensation.Status__c = Case_Management.CASE_STATUS_NEW;
		insert pendingCompensation;

		caseList.add(approvedCase);
		caseList.add(pendingCase);

		caseIdSet = BE8_GlobalUtility.getIdSet('Id', caseList);

		caseManagement.Changecompensationapproval(caseList, caseIdSet);

		toBeApprovedCompensation = [SELECT Id, Status__c FROM Compensation__c WHERE Id = : toBeApprovedCompensation.Id LIMIT 1];
		pendingCompensation = [SELECT Id, Status__c FROM Compensation__c WHERE Id = : pendingCompensation.Id LIMIT 1];

		Assert.assertEquals(Case_Management.APPROVED, toBeApprovedCompensation.Status__c, 'Compensation will have the value of Status as same as Approval Status in Case. [Approved]');
		Assert.assertEquals(Case_Management.PENDING, pendingCompensation.Status__c, 'Compensation will have the value of Status as same as Approval Status in Case. [Pending]');
	}

	@isTest static void testStampActionTrail() {
		TriggerActivator.overrideTriggerActivation(TriggerActivator.CASE_TRIGGER, false);
		Case_Management caseManagement = new Case_Management();

		Case escalatedCase = new Case(Status = Case_Management.ESCALATED);
		Case investigatedCase = new Case(Status = Case_Management.INVESTIGATED);
		Case waitingFoInvestigatorCase = new Case(Status = Case_Management.WAITINGINV);
		Case resolvedCase = new Case(Status = Case_Management.RESOLVED);
		Case customerResponseCase = new Case(Status = Case_Management.CUSTOMER_RESPONSE);
		Case closedCase = new Case(Status = Case_Management.CLOSED);

		List<Case> caseList = new List<Case>();
		caseList.add(escalatedCase);
		caseList.add(investigatedCase);
		caseList.add(waitingFoInvestigatorCase);
		caseList.add(resolvedCase);
		caseList.add(customerResponseCase);
		caseList.add(closedCase);
		insert caseList;

		Set<Id> caseIdSet = BE8_GlobalUtility.getIdSet('Id', caseList);

		caseManagement.StampActionTrail(caseList, caseIdSet, null);

		Assert.assertEquals(UserInfo.getName(), escalatedCase.First_Handle_by__c, 'At the first time when the Case is escalated, First_Handle_by__c will have the value of the name of the User who escalated the case.');
		Assert.assertEquals(UserInfo.getName(), escalatedCase.Escalate_by__c, 'Escalate_by__c will have the value of the name of the User who escalated the case.');
		//Assert.assertEquals(UserInfo.getName(), investigatedCase.Investigated_by__c, 'Investigated_by__c will have the value of the name of the User who investigated the case.');
		Assert.assertEquals(UserInfo.getName(), waitingFoInvestigatorCase.Send_to_Investigator_by__c, 'Send_to_Investigator_by__c will have the value of the name of the User who investigated the case.');
		//Assert.assertEquals(UserInfo.getName(), resolvedCase.Closed_by__c, 'Closed_by__c will have the value of the name of the User who closed the case.');
		//Assert.assertEquals(UserInfo.getName(), customerResponseCase.Closed_by__c, 'Closed_by__c will have the value of the name of the User who closed the case.');
		//Assert.assertEquals(UserInfo.getName(), closedCase.Closed_by__c, 'Closed_by__c will have the value of the name of the User who closed the case.');
	}

	@isTest static void testUpdateCaseByElapsedTimeInMins(){
		Case_Management caseManagement = new Case_Management();
		Case closedAndEscalatedCase = new Case(Status = Case_Management.CLOSED, First_Handle_Time__c = System.now(), Investigated_Time__c = System.now(), Escalate_Time__c = System.now());
		Case investigatedCase = new Case(Status = Case_Management.INVESTIGATED, Escalate_Time__c = System.now(), Send_to_Investigator_Time__c = System.now());
		CaseMilestone caseMilestone = new CaseMilestone();

		caseManagement.updateCaseByElapsedTimeInMins(closedAndEscalatedCase, caseMilestone);
		caseManagement.updateCaseByElapsedTimeInMins(investigatedCase, caseMilestone);
	}

	@isTest static void testFindletterbody(){
		Letter_Master__c letterMaster = MockupData_Test.createLetterMaster('TH', 'Test');
		insert letterMaster;
		Case testCase = MockupData_Test.createCase(null, BE8_GlobalConstants.CASE_STATUS_PENDING, BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		testCase.Letter_Bodyid__c = letterMaster.Id;
		insert testCase;
		new Case_Management().findletterbody(new List<Case>{testCase}, new Set<Id>{letterMaster.Id});
	}

	@isTest static void testGetSeqNoDateFormat(){
		String dateResult = Case_Management.getSeqNoDateFormat('2017-03-02');
		Assert.assertEquals('020317', dateResult);
	}

	@isTest static void testGetSeqNoFormat(){
		Aircraft__c aircraft = MockupData_Test.getMockUpAircraft();
		aircraft.Aircraft_Registration__c = 'HS-TAB';
		insert aircraft;
		Case testCase = MockupData_Test.createCase(null, BE8_GlobalConstants.CASE_STATUS_PENDING, BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE);
		testCase.SEQ_No_txt__c = '090';
		testCase.Incident_Type__c = 'Cabin Log';
		testCase.SEQ_No_Date__c = Date.valueOf('2017-03-02');
		testCase.A_C_REG_ID__c = aircraft.Id;
		insert testCase;
		String seqNo = Case_Management.getSeqNoFormat(testCase, aircraft);
		Assert.assertEquals('AB090C020317', seqNo);
	}

	@isTest static void testUpdateExpectedFlightOnCaseInsertSuccessScenario(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];
		Case c = new Case();
		c.Subject = 'test001';
		c.Status = 'New';
		c.FlightId__c = tgxxx.Id;
		c.Expected_Flight_Number__c = '628';
		c.Expected_Flight_Date__c = Date.newInstance(2025, 03, 30);

		System.runAs(runasUser){
			insert c;
		}
		Case thisca = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :c.Id].get(0);
		List<Task> taskList = [SELECT Id FROM Task];
		System.debug('JK: CFMS update expected flight - ' + JSON.serialize(thisca));
		System.assertEquals('TG628 / 30MAR25', thisca.Expected_Flight_Display__c, 'Expected Flight Display field should be equal to TG628 / 30MAR25');
		System.assertNotEquals(null, taskList, 'Task List should not be null');
		System.assertEquals(1, taskList.size(), 'Size of task list should be equal to 1');
	}

	@isTest static void testUpdateExpectedFlightOnCaseInsertFailureScenarioExistingFlight(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		String errorMsg = null;
		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];
		Case c = new Case();
		c.Subject = 'test001';
		c.Status = 'New';
		c.FlightId__c = tgxxx.Id;
		c.Expected_Flight_Number__c = '628';
		c.Expected_Flight_Date__c = Date.newInstance(2025, 03, 25);

		System.runAs(runasUser){
			try{
				insert c;
			}
			catch(Exception e){
				errorMsg = e.getMessage();
				if(errorMsg.contains('was existed in salesforce')){
					errorMsg = errorMsg.replace('Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, ', '');
					errorMsg = errorMsg.replace(': [Flightid__c]', '');
				}
			}
		}
		System.debug('JK: ERROR MSG Existing Flight - ' + errorMsg);
		System.assertEquals('"TG628 / 25MAR25" was existed in salesforce, Please change Flight to be "TG628 / 25MAR25" instead of "TGXXX".', errorMsg, 'Error Message should be "TG628 / 25MAR25" was existed in salesforce, Please change Flight to be "TG628 / 25MAR25" instead of "TGXXX".');
	}

	@isTest static void testUpdateExpectedFlightOnCaseInsertFailureScenarioExpectedFlightDateIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		String errorMsg = null;
		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];
		Case c = new Case();
		c.Subject = 'test001';
		c.Status = 'New';
		c.FlightId__c = tgxxx.Id;
		c.Expected_Flight_Number__c = '628';

		System.runAs(runasUser){
			try{
				insert c;
			}
			catch(Exception e){
				errorMsg = e.getMessage();
				if(errorMsg.contains('Expected Flight Date must not be null while Expected Flight Number is filled.')){
					errorMsg = 'Expected Flight Date must not be null while Expected Flight Number is filled.';
				}
			}
		}
		System.debug('JK: ERROR MSG Flight Date is Null - ' + errorMsg);
		System.assertEquals('Expected Flight Date must not be null while Expected Flight Number is filled.', errorMsg, 'Error Message should be "Expected Flight Date must not be null while Expected Flight Number is filled."');
	}

	@isTest static void testUpdateExpectedFlightOnCaseInsertFailureScenarioExpectedFlightNumberIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		String errorMsg = null;
		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];
		Case c = new Case();
		c.Subject = 'test001';
		c.Status = 'New';
		c.FlightId__c = tgxxx.Id;
		c.Expected_Flight_Date__c = Date.newInstance(2025, 03, 25);

		System.runAs(runasUser){
			try{
				insert c;
			}
			catch(Exception e){
				errorMsg = e.getMessage();
				if(errorMsg.contains('Expected Flight Number must not be null while Expected Flight Date is filled.')){
					errorMsg = 'Expected Flight Number must not be null while Expected Flight Date is filled.';
				}
			}
		}
		System.debug('JK: ERROR MSG Flight Number is Null - ' + errorMsg);
		System.assertEquals('Expected Flight Number must not be null while Expected Flight Date is filled.', errorMsg, 'Error Message should be "Expected Flight Number must not be null while Expected Flight Date is filled."');
	}

	@isTest static void testUpdateExpectedFlightOnCaseUpdateSuccessScenario(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;

		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];

		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = tgxxx.Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Expected_Flight_Number__c = '628';
			thiscaBFUpdate.Expected_Flight_Date__c = Date.newInstance(2025, 03, 30);
			update thiscaBFUpdate;
		}
		Case thiscaAFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);
		Test.stopTest();

		List<Task> taskList = [SELECT Id FROM Task];
		System.assertEquals(null, thiscaBFUpdate.Expected_Flight_Display__c, 'Expected Flight Display should be null');
		System.debug('JK: CFMS update expected flight - ' + JSON.serialize(thiscaAFUpdate));
		System.assertEquals('TG628 / 30MAR25', thiscaAFUpdate.Expected_Flight_Display__c, 'Expected Flight Display field should be equal to TG628 / 30MAR25');
		System.assertNotEquals(null, taskList, 'Task List should not be null');
		System.assertEquals(1, taskList.size(), 'Size of task list should be equal to 1');
	}

	@isTest static void testUpdateExpectedFlightOnCaseUpdateFailureScenarioExistingFlight(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		String errorMsg = null;

		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];

		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = tgxxx.Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Expected_Flight_Number__c = '628';
			thiscaBFUpdate.Expected_Flight_Date__c = Date.newInstance(2025, 03, 25);
			try{
				update thiscaBFUpdate;	
			}
			catch(Exception e){
				System.debug('JK: e - ' + e.getMessage());
				errorMsg = e.getMessage();
				if(errorMsg.contains('was existed in salesforce')){
					errorMsg = errorMsg.replace(': [Flightid__c]', '');
					errorMsg = errorMsg.substring(errorMsg.indexOf('"TG628 / 25MAR25" was existed in salesforce'), errorMsg.length());
				}
			}
			
		}
		Test.stopTest();

		System.debug('JK: ERROR MSG Existing Flight - ' + errorMsg);
		System.assertEquals('"TG628 / 25MAR25" was existed in salesforce, Please change Flight to be "TG628 / 25MAR25" instead of "TGXXX".', errorMsg, 'Error Message should be "TG628 / 25MAR25" was existed in salesforce, Please change Flight to be "TG628 / 25MAR25" instead of "TGXXX".');
	}

	@isTest static void testUpdateExpectedFlightOnCaseUpdateFailureScenarioExpectedFlightNumberIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		String errorMsg = null;

		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];

		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = tgxxx.Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Expected_Flight_Date__c = Date.newInstance(2025, 03, 25);
			try{
				update thiscaBFUpdate;	
			}
			catch(Exception e){
				System.debug('JK: e - ' + e.getMessage());
				errorMsg = e.getMessage();
				if(errorMsg.contains('Expected Flight Number must not be blank while Expected Flight Date is filled.')){
					errorMsg = 'Expected Flight Number must not be blank while Expected Flight Date is filled.';
				}
			}
			
		}
		Test.stopTest();

		System.debug('JK: ERROR MSG Flight Number is Null - ' + errorMsg);
		System.assertEquals('Expected Flight Number must not be blank while Expected Flight Date is filled.', errorMsg, 'Error Message should be "Expected Flight Number must not be blank while Expected Flight Date is filled."');
	}

	@isTest static void testUpdateExpectedFlightOnCaseUpdateFailureScenarioExpectedFlightDateIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		String errorMsg = null;

		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];

		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = tgxxx.Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Expected_Flight_Number__c = '628';
			try{
				update thiscaBFUpdate;	
			}
			catch(Exception e){
				System.debug('JK: e - ' + e.getMessage());
				errorMsg = e.getMessage();
				if(errorMsg.contains('Expected Flight Date must not be blank while Expected Flight Number is filled.')){
					errorMsg = 'Expected Flight Date must not be blank while Expected Flight Number is filled.';
				}
			}
			
		}
		Test.stopTest();

		System.debug('JK: ERROR MSG Flight Date is Null - ' + errorMsg);
		System.assertEquals('Expected Flight Date must not be blank while Expected Flight Number is filled.', errorMsg, 'Error Message should be "Expected Flight Date must not be null while Expected Flight Number is filled."');
	}

	@isTest static void testUpdateExpectedFlightOnCaseCreateClearVariableValueWhenExpectedDateAndNumberIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];
		Case c = new Case();
		c.Subject = 'test001';
		c.Status = 'New';
		c.FlightId__c = tgxxx.Id;
		c.Expected_Flight_Date__c = null;
		c.Expected_Flight_Number__c = null;
		c.Expected_Flight_Sector__c = 'BKK-HKG';
		c.Expected_PNR__c = '12345';
		c.Expected_Flight_Display__c = 'ppppp';

		System.runAs(runasUser){
			insert c;
		}
		Case thisca = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c, Expected_Flight_Sector__c, Expected_PNR__c FROM Case WHERE Id = :c.Id].get(0);
		List<Task> taskList = [SELECT Id FROM Task];
		System.debug('JK: CFMS update expected flight - ' + JSON.serialize(thisca));
		System.assertEquals(null, thisca.Expected_Flight_Display__c, 'Expected Flight Display field should be null');
		System.assertEquals(null, thisca.Expected_Flight_Date__c, 'Expected Flight Date field should be null');
		System.assertEquals(null, thisca.Expected_Flight_Number__c, 'Expected Flight Number field should be null');
		System.assertEquals(null, thisca.Expected_Flight_Sector__c, 'Expected Flight Sector field should be null');
		System.assertEquals(null, thisca.Expected_PNR__c, 'Expected Flight PNR field should be null');
		System.assert(taskList.isEmpty(), 'Task list should be null');
	}

	@isTest static void testUpdateExpectedFlightOnCaseUpdateClearVariableValueWhenExpectedDateAndNumberIsNull(){
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;

		Flight__c tgxxx = [SELECT Id FROM Flight__c WHERE Id =: new Case_Management().getdummyflight() LIMIT 1];

		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = tgxxx.Id;
			c.Expected_Flight_Number__c = '628';
			c.Expected_Flight_Date__c = Date.newInstance(2025, 03, 30);
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Expected_Flight_Number__c = null;
			thiscaBFUpdate.Expected_Flight_Date__c = null;
			update thiscaBFUpdate;
		}
		Case thiscaAFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c, Expected_Flight_Sector__c, Expected_PNR__c FROM Case WHERE Id = :caseId].get(0);
		Test.stopTest();

		List<Task> taskList = [SELECT Id, Status FROM Task];
		System.assertEquals(null, thiscaAFUpdate.Expected_Flight_Display__c, 'Expected Flight Display field should be null');
		System.assertEquals(null, thiscaAFUpdate.Expected_Flight_Date__c, 'Expected Flight Date field should be null');
		System.assertEquals(null, thiscaAFUpdate.Expected_Flight_Number__c, 'Expected Flight Number field should be null');
		System.assertEquals(null, thiscaAFUpdate.Expected_Flight_Sector__c, 'Expected Flight Sector field should be null');
		System.assertEquals(null, thiscaAFUpdate.Expected_PNR__c, 'Expected Flight PNR field should be null');
		System.assert(taskList.get(0).Status == 'Cancelled', 'Task list should be null');
	}

	@isTest static void testEscalationTierwhenCaseCreatedForS3Tier1(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		System.debug('JK: FlightList - ' + JSON.serialize(flightList));
		System.debug('JK: paxList - ' + JSON.serialize(paxList));
		Case c = new Case();
		c.Subject = 'Subject001';
		c.Status = 'Resolved';
		c.FlightId__c = flightList.get(0).Id;
		c.PassengerId__c = paxList.get(0).Id;

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		System.debug('JK: queueMap - ' + JSON.serialize(groupMap));
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S3 Tier 1 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S3 Tier 1 Team');

	}	

	@isTest static void testEscalationTierwhenCaseCreatedForS4Level8IF(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		System.debug('JK: recordTypeMap - ' + JSON.serialize(recordTypeMap));
		Case c = new Case();
		c.Subject = 'Subject001';
		c.Case_Type__c = 'Information';
		c.FlightId__c = flightList.get(0).Id;
		c.PassengerId__c = paxList.get(0).Id;
		c.RecordTypeId = recordTypeMap.get('In_Flight').Id;
		c.Not_Send_Acknowledge_Email__c = true;

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		System.debug('JK: queueMap - ' + JSON.serialize(groupMap));
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Level 8 In-Flight Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Level 8 In-Flight Team');
	}	

	@isTest static void testEscalationTierwhenCaseCreatedForS4FPIF(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		Case c = new Case();
		c.Subject = 'Subject001';
		c.Case_Type__c = 'Information';
		c.FlightId__c = flightList.get(0).Id;
		c.PassengerId__c = paxList.get(0).Id;
		c.Origin = 'In-Flight';
		c.ROP_Tier__c = 'PLAT';

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 First & Platinum Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 First & Platinum Team');
	}	

	@isTest static void testEscalationTierwhenCaseCreatedForS4Tier2(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		Case c = new Case();
		c.Subject = 'Subject001';
		c.Case_Type__c = 'Complaint';
		c.FlightId__c = flightList.get(0).Id;
		c.PassengerId__c = paxList.get(0).Id;
		c.Status = 'Escalated';
		c.Origin = 'In-Flight';
		c.RecordTypeId = recordTypeMap.get('Ground_Service').Id;

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Tier 2 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Tier 2 Team');
	}	

	@isTest static void testEscalationTierwhenCaseCreatedForS4Tier1(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		Case c = new Case();
		c.Subject = 'Subject001';
		c.FlightId__c = flightList.get(0).Id;
		c.PassengerId__c = paxList.get(0).Id;
		c.RecordTypeId = recordTypeMap.get('In_Flight').Id;
		c.Not_Send_Acknowledge_Email__c = true;
		c.Status = 'Escalated';

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Tier 1 Group A Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Tier 1 Group A Team');
		System.assertEquals('Acknowledge', caseList.get(0).Status, 'Case status should be equal to Acknowledge');
	}	

	@isTest static void testEscalationTierwhenCaseCreatedForTGWebMaster(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		Case c = new Case();
		c.Subject = 'Subject001';
		c.FlightId__c = flightList.get(0).Id;
		//c.PassengerId__c = paxList.get(0).Id;
		c.Origin = 'TGWebsite';
		c.SuppliedEmail = 'tg@tg.com';
		c.Not_Send_Acknowledge_Email__c = true;

		Test.startTest();
		insert c;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Tier 1 Group A Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Tier 1 Group A Team');
		System.assertEquals('Acknowledge', caseList.get(0).Status, 'Case status should be equal to Acknowledge');
	}

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS3Tier1(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Resolved';
			thiscaBFUpdate.Verified__c = false;
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S3 Tier 1 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S3 Tier 1 Team');
	}

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS3Chief(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Verified__c = false;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Verified__c = true;
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S3 Chief Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S3 Chief Team');
	}	

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS4Level8CFMS(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Priority = 'Urgent';
			c.Case_Type__c = 'Injury';
			c.Origin = 'Station';
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Escalated';
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Level 8 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Level 8 Team');
	}	

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS4Level8Ground(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Priority = 'Urgent';
			c.RecordTypeId = recordTypeMap.get('Ground_Service').Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Escalated';
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Level 8 Ground Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Level 8 Ground Team');
	}

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS4Tier2FP(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.Status = 'New';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.ROP_Tier__c = 'PLAT';
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Escalated';
			thiscaBFUpdate.ROP_Tier__c = 'PLAT';
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status, ROP_Tier__c FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 First & Platinum Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 First & Platinum Team');
	}

	@isTest static void EscalationTierwhenchangestatustoEscalatedForAOTier2BC(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Case_Type__c = 'Baggage Claim';
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Escalated';
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('AO Tier 2 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to AO Tier 2 Team');
	}

	@isTest static void EscalationTierwhenchangestatustoEscalatedForS4Tier2(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Case_Type__c = 'Complaint';
			c.RecordTypeId = recordTypeMap.get('Ground_Service').Id;
			insert c;
			caseId = c.Id;
		}
		Case thiscaBFUpdate = [SELECT Id, Subject, Status, Expected_Flight_Number__c, Expected_Flight_Date__c, Expected_Flight_Display__c FROM Case WHERE Id = :caseId].get(0);

		System.runAs(runasUser){
			thiscaBFUpdate.Status = 'Escalated';
			update thiscaBFUpdate;
		}
		Test.stopTest();

		List<Case> caseList = [SELECT Id, OwnerId, Status FROM Case];
		Map<Id, String> queueMap = new Map<Id, String>();
		Map<String, Group> groupMap = Case_TriggerHandler.getQueueMap();
		for(String name : groupMap.keySet()){
			queueMap.put(groupMap.get(name).Id, name);
		}
		System.assertEquals('S4 Tier 2 Team', queueMap.get(caseList.get(0).OwnerId), 'Case owner should be equal to S4 Tier 2 Team');
	}

	@isTest static void testGetCaseCompensationToolsString(){
		List<Flight__c> flightList = [SELECT Id, Name FROM Flight__c WHERE Name != 'TGXXX'];
		List<Passenger__c> paxList = [SELECT Id, FlightId__c FROM Passenger__c];
		Map<String, RecordType> recordTypeMap = Case_TriggerHandler.getRecordTypeMapByDevName();
		User runasUser = MockupData_Test.createUser('Khemarnusuk', 'Natchaporn@tg.com', 'CFMS Tier 1', 'S4 Tier 1 Group B');
		insert runasUser;
		Id caseId = null;
		Test.startTest();
		System.runAs(runasUser){
			Case c = new Case();
			c.Subject = 'Subject01';
			c.FlightId__c = flightList.get(0).Id;
			c.PassengerId__c = paxList.get(0).Id;
			c.Case_Type__c = 'Complaint';
			insert c;
			caseId = c.Id;

			Compensation__c comp = new Compensation__c();
			comp.CaseId__c = caseId;
			comp.Compensation_Account_Center__c = '1030100';
			comp.Compensation_Account_Number__c = '631080';
			comp.Compensation_Tools__c = 'Cash';
			comp.Amount__c = 1000.00;
			comp.Compensation_Type__c = 'Denied Boarding';
			comp.Unit__c = 'Currency';
			comp.Currency__c = 'THB';
			insert comp;

			comp.Status__c = 'Approved';
			update comp;
		}

		Case updatedCase = [SELECT Id, Compensation_Tool__c FROM Case WHERE Id = :caseId LIMIT 1];
		System.assertEquals('Cash', updatedCase.Compensation_Tool__c, 'Compensation Tool should be "Cash"');
	}

	@isTest static void testGetRecordTypeMapByName(){
		Map<String, RecordType> recordTypeMapByName = Case_Management.getRecordTypeMapByName();
		System.assertNotEquals(null, recordTypeMapByName, 'recordTypeMapByName should not be null');
	}

	@isTest static void testAcknowleageontime(){
		Case case1 = new Case();
		case1.Status = 'New';
		case1.First_Handle_Time__c = System.now();
		insert case1;
		Case caseFromQuery = [SELECT Id, CreatedDate FROM Case WHERE Id = :case1.Id].get(0);
		Case_Management cm = new Case_Management();
		Boolean isOnTime = cm.Acknowleageontime(caseFromQuery);
		System.assertEquals(true, isOnTime, '');
	}
}