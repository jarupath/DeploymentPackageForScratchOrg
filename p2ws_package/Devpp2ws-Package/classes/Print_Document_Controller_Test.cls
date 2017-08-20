@isTest
private class Print_Document_Controller_Test {
	@testSetup static void DataPreparation(){
		MockupData_Test.initializeWebServiceCustomSetting();
		System_Configuration__c sysconfig = (System_Configuration__c)JSON.deserialize('{"Case_Closed_Record_Type_ID__c":"01228000000iqFZ","Case_Group_Member_Record_Type_ID__c":"01228000000iqFf","S3_Tier_1_Queue_ID__c":"00G28000002ZcPZ","S4_First_Platinum_Queue_ID__c":"00G28000002ZcPa","S4_Tier_1_Queue_ID__c":"00G28000002ZcPe","S4_Tier_2_Queue_ID__c":"00G28000002ZcPf","S4_Level_8_In_Flight_Queue_ID__c":"00G28000002ZcPc","S3_Chief_Queue_ID__c":"00G28000002ZcPY","S4_Level_8_Ground_Queue_ID__c":"00G28000002ZcPb","S4_Level_8_Queue_ID__c":"00G28000002ZcPd","AO_Baggage_Claim__c":"00G28000002ZcPX","Reminder_Time__c":"08.00"}', System_Configuration__c.class);
		insert sysconfig;
	}

	static Print_Document_Controller getDefaultController() {
		return getDefaultController(false, false);
	}

	static Print_Document_Controller getDefaultController(Boolean setupAttachment, Boolean setupCaseGroupMember) {
		Flight__c flight = MockupData_Test.createFlight('0680', '30Sep16', 1);
		insert flight;

		Case newCase = MockupData_Test.createCase('UA007C011016', 'Open', 'CTI');
		newCase.Flightid__c = flight.Id;
		newCase.Case_Type__c = 'DBC';
		insert newCase;

		Compensation__c compensation = MockupData_Test.createCompensation(newCase.Id);
		compensation.Compensation_Account_Center__c = '1030100';
		compensation.Compensation_Account_Number__c = '631070';
		insert compensation;

		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'C');
		insert passenger;

		String attachmentName = 'version1';
		if (setupCaseGroupMember) {
			Case_Group_Member__c caseGroupMember = new Case_Group_Member__c();
			caseGroupMember.Caseid__c = newCase.Id;
			caseGroupMember.Passengerid__c = passenger.Id;
			insert caseGroupMember;
			attachmentName += caseGroupMember.Id;
		}
		attachmentName += 'PV';

		if (setupAttachment) {
			Attachment attachment = new Attachment(
			    ParentId = newCase.Id,
			    Description = attachmentName,
			    Name = attachmentName,
			    Body = Blob.valueOf('BodyVersion1'));
			insert attachment;
		}

		ApexPages.currentPage().getParameters().put('id', newCase.Id);

		ApexPages.StandardController stdCaseController = new ApexPages.StandardController(newCase);
		return new Print_Document_Controller(stdCaseController);
	}

	static List<Letter_Master__c> mockLetterMasterList() {
		List<Letter_Master__c> letterMasterList = new List<Letter_Master__c>();
		letterMasterList.add(MockupData_Test.createLetterMaster('EN', 'Letter EN 1'));
		letterMasterList.add(MockupData_Test.createLetterMaster('TH', 'Letter TH 1'));
		letterMasterList.add(MockupData_Test.createLetterMaster('TH', 'Letter TH 2'));
		return letterMasterList;
	}

	@isTest
	static void testGetTemplateList() {
		Print_Document_Controller ctrl = getDefaultController();
		ctrl.hasUpgradeDocumentPermission = false;
		List<SelectOption> options = ctrl.getTemplatelist();
		Assert.assertEquals(5, options.size());

		ctrl.hasUpgradeDocumentPermission = true;
		options = ctrl.getTemplatelist();
		Assert.assertEquals(7, options.size());
	}

	@isTest
	static void testGetTravelTypeList() {
		Print_Document_Controller ctrl = getDefaultController();
		List<SelectOption> options = ctrl.getTravelTypeList();
		Assert.assertEquals(2, options.size());
	}

	@isTest
	static void testSaveAndAttachWithNewVersion() {
		List<Attachment> initAttachments = [SELECT Id, Name, Description FROM Attachment];
		System.assertEquals(0, initAttachments.size());

		Print_Document_Controller ctrl = getDefaultController(true, true);
		ctrl.FilterTemplate = 'PV';
		ctrl.getOldVersionSelectOptions();
		ctrl.isNewVersion = true;
		ctrl.saveAndAttach();

		List<Attachment> attachments = [SELECT Id, Name, Description FROM Attachment];
		System.assertEquals(ctrl.attchmentMap.size(), attachments.size());
		System.assertEquals(ctrl.attchmentMap.values(), attachments);
	}

	@isTest
	static void testSaveAndAttachWithOldVersion() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		//ctrl.selec
		ctrl.FilterTemplate = 'PV';
		ctrl.getOldVersionSelectOptions();
		ctrl.isNewVersion = false;
		ctrl.selectedOldVersion = ctrl.attchmentMap.values().get(0).Id;
		ctrl.saveAndAttach();

		List<Attachment> attachments = [SELECT Id FROM Attachment];
		System.assertEquals(ctrl.attchmentMap.size(), attachments.size());
	}

	@isTest
	static void testGetOldVersionSelectOptions() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		List<SelectOption> options = ctrl.getOldVersionSelectOptions();
		Assert.assertEquals(0, options.size());
		ctrl.selectedCaseGroupMemberId = (new List<Id>(ctrl.caseGroupMemberMap.keySet())).get(0);
		ctrl.FilterTemplate = 'PV';
		options = ctrl.getOldVersionSelectOptions();
		Assert.assertEquals(1, options.size());
	}

	@isTest
	static void testGetPreviewURL() {
		Print_Document_Controller ctrl = getDefaultController();
		ctrl.comment = 'comment';
		String actualPreviewUrl = ctrl.getPreviewURL();
		Assert.assert(actualPreviewUrl.contains('/apex/LetterEN?id=' + ctrl.caseId));
		Assert.assert(actualPreviewUrl.contains('comment=comment'));
	}

	@isTest
	static void testAttachmentMapByCaseGroupMemberId() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
	}

	@isTest
	static void testGetSelectOptions() {
		Print_Document_Controller ctrl = getDefaultController();
		List<SelectOption> travelTypeOptions = ctrl.getTravelTypeList();
		Assert.assertEquals(2, travelTypeOptions.size());
	}

	@isTest
	static void testGetLetterBodyListOptions() {
		List<Letter_Master__c> letterMasterList = mockLetterMasterList();
		insert letterMasterList;

		Print_Document_Controller ctrl = getDefaultController();
		List<SelectOption> letterBodyOptions = ctrl.getLetterBodyList();
		Assert.assertEquals(1, letterBodyOptions.size());
	}

	@isTest
	static void testChangeDocument() {
		List<Letter_Master__c> letterMasterList = mockLetterMasterList();
		insert letterMasterList;

		Print_Document_Controller ctrl = getDefaultController();
		ctrl.changeDocument();
		Assert.assertEquals(true, ctrl.hasBody);
		Assert.assertEquals('Letter EN 1', ctrl.templateBody);

		ctrl.FilterTemplate = ctrl.LETTER_TH_2_PAGE_NAME;
		ctrl.changeDocument();
		Assert.assertEquals(true, ctrl.hasBody);
		Assert.assertEquals('Letter TH 1', ctrl.templateBody);
	}

	@isTest
	static void testChangeTemplate() {
		List<Letter_Master__c> letterMasterList = mockLetterMasterList();
		insert letterMasterList;

		Print_Document_Controller ctrl = getDefaultController();
		ctrl.letterBodyId = letterMasterList.get(0).Id;
		ctrl.changeTemplate();
		Assert.assertEquals(true, ctrl.hasBody);
		Assert.assertEquals('Letter EN 1', ctrl.templateBody);

		ctrl.letterBodyId = letterMasterList.get(2).Id;
		ctrl.changeTemplate();
		Assert.assertEquals(true, ctrl.hasBody);
		Assert.assertEquals('Letter TH 2', ctrl.templateBody);
	}

	@isTest
	static void testPreview() {
		List<Letter_Master__c> letterMasterList = mockLetterMasterList();
		insert letterMasterList;

		Print_Document_Controller ctrl = getDefaultController();
		ctrl.letterBodyId = letterMasterList.get(1).Id;
		ctrl.FilterTemplate = ctrl.LETTER_TH_1_PAGE_NAME;
		ctrl.changeTemplate();
		ctrl.templateBody = ctrl.templateBody += ' Edit';
		ctrl.updateBody();
		System.debug('SJ : ' + ctrl.caseId);
		Case actualCase = [SELECT Id, Letter_Body__c, Latest_Document__c, Latest_Template__c FROM Case WHERE Id = :ctrl.caseId];
		Assert.assertEquals('|Letter TH 1 Edit', actualCase.Letter_Body__c);
		Assert.assertEquals(ctrl.LETTER_TH_1_PAGE_NAME, actualCase.Latest_Document__c);
		Assert.assertEquals(ctrl.letterBodyId, actualCase.Latest_Template__c);
		ctrl.preview();
		actualCase = [SELECT Id, Letter_Body__c FROM Case WHERE Id = :ctrl.caseId];
		Assert.assertEquals(letterMasterList.get(1).Description__c , actualCase.Letter_Body__c);
	}

	@isTest 
	static void testSetSelectedAccountNumber() {
		Print_Document_Controller ctrl = getDefaultController();
		ctrl.selectedAccountNumber = '12345';
		System.assertEquals('12345', ctrl.selectedAccountNumberPartial);
		ctrl.selectedAccountNumber = '123456';
		System.assertEquals('123456', ctrl.selectedAccountNumberPartial);
		ctrl.selectedAccountNumber = '1234567';
		System.assertEquals('123456', ctrl.selectedAccountNumberPartial);
	}

	@isTest 
	static void testSetSelectedAccountCenter() {
		Print_Document_Controller ctrl = getDefaultController();
		ctrl.selectedAccountCenter = '123456';
		System.assertEquals('123456', ctrl.selectedAccountCenterPartial);
		ctrl.selectedAccountCenter = '1234567';
		System.assertEquals('1234567', ctrl.selectedAccountCenterPartial);
		ctrl.selectedAccountCenter = '12345678';
		System.assertEquals('1234567', ctrl.selectedAccountCenterPartial);
	}

	@isTest
	static void testGetAccountCenterSelectOptions() {
		Print_Document_Controller ctrl = getDefaultController();
		List<SelectOption> accountCenterSelectOptions = ctrl.getAccountCenterSelectOptions();
		Assert.assertEquals(1, accountCenterSelectOptions.size());
	}

	@isTest
	static void testGetAccountNumberSelectOptions() {
		Print_Document_Controller ctrl = getDefaultController();
		List<SelectOption> accountNumberSelectOptions = ctrl.getAccountNumberSelectOptions();
		Assert.assertEquals(1, accountNumberSelectOptions.size());
	}

	@isTest
	static void testGetCaseGroupMemberSelectOptions() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		List<SelectOption> cgmSelectOptions = ctrl.getCaseGroupMemberSelectOptions();
		Assert.assertEquals(1, cgmSelectOptions.size());
	}

	@isTest
	static void testChangePassenger() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		ctrl.selectedCaseGroupMemberId = ctrl.caseGroupMemberMap.values().get(0).Id;
		ctrl.changePassenger();
		Assert.assertNotEquals('', ctrl.passengerName);
	}

	@isTest
	static void testChangeToDisplayTHB() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		ctrl.displayTHB = true;
		ctrl.changeDisplayTHB();
		Assert.assertEquals('BAHT', ctrl.currencyWord);
		Assert.assertEquals('SATANG', ctrl.subCurrencyWord);
	}

	@isTest
	static void testChangeToDisplayNotTHB() {
		Print_Document_Controller ctrl = getDefaultController(true, true);
		ctrl.displayTHB = false;
		ctrl.targetCurrency = null;
		ctrl.changeDisplayTHB();
		System.debug('JK: targetCurrentcy - ' + ctrl.targetCurrency);
		Assert.assertEquals('[CURRENCY]', ctrl.currencyWord);
		Assert.assertEquals('[SUBCURRENCY]', ctrl.subCurrencyWord);
	}
}