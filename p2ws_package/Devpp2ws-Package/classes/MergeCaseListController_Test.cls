@isTest
private class MergeCaseListController_Test {
        @testSetup static void DataPreparation(){
                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();
        }
	
	/* Positive Case - Case with Sames Passenger */
	@isTest static void testWtihSamePassenger_Positive() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

                Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
		controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

		Assert.assertEquals(1, caseList.size());
		Assert.assertEquals(c.Id, caseList.get(0).Id);
	}

	/* Negative Case - Case with Sames Passenger */
	@isTest static void testWtihSamePassenger_Negative() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Account a2 = new Account();
		a2.Name = firstName + ' ' + lastName;
		a2.First_Name__c = firstName;
		a2.Last_Name__c = lastName;
		a2.ROP_Tier__c = 'Gold';
		insert a2;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a2.Id;
                p2.Class__c = 'C';
                insert p2;

        	Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p2.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
		controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

		Assert.assertEquals(0, caseList.size());
	}

	/* Positive Case - Case with Sames Account */
	@isTest static void testWtihSameAccount_Positive() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

                Passenger__c p2 = new Passenger__c();
                p2.SSR_Service__c = '';
                p2.First_Name__c = firstName;
                p2.Last_Name__c = lastName;
                p2.FlightId__c = f.Id;
                p2.AccountId__c = a.Id;
                p2.Class__c = 'C';
                insert p2;

        	Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.AccountId = a.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p2.Id;
                thisCase.AccountId = a.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
		controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

		Assert.assertEquals(1, caseList.size());
		Assert.assertEquals(c.Id, caseList.get(0).Id);
	}

	/* Positive Case - Assign Parent Success*/
	@isTest static void testAssignParent_Positive() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

        	Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                controller.parentId = c.Id;

		controller.assignParentCase();

		Assert.assertEquals(null, controller.msg);

		Case updatedCase = [Select Id, Status, ParentId from Case where Id = :thisCase.Id];
		Assert.assertEquals(c.Id, updatedCase.ParentId);
		Assert.assertEquals(MergeCaseListController.STATUS_DUPLICATE, updatedCase.Status);
	}

	/* Negative Case - Assign Parent Failed: Circular Parent Assignment*/
	@isTest static void testAssignParent_Negative() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

                Case thisCase = new Case();
                thisCase.Subject = 'Case1';
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';

                Case motherCase = new Case();
                motherCase.Subject = 'Case2';
                motherCase.PassengerId__c = p.Id;
                motherCase.FlightId__c = f.Id;
                motherCase.Status = 'New';
                motherCase.Channel__c = 'Phone';

                Case c = new Case();
                c.Subject = 'Case3';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';

                Case c2 = new Case();
                c.Subject = 'Case4';
                c2.PassengerId__c = p.Id;
                c2.FlightId__c = f.Id;
                c2.Status = 'New';
                c2.Channel__c = 'Phone';

                insert new List<Case> {thisCase, motherCase, c, c2};

                motherCase.ParentId = thisCase.Id;
                c.ParentId = motherCase.Id;

                update new List<Case> {motherCase, c};

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                // Assign this case to be child case of its own grandchildern, observe that the assignment would fail
                controller.parentId = c.Id;
		controller.assignParentCase();
		Assert.assertEquals(MergeCaseListController.ERROR_MESSAGE, controller.msg);

		Case updatedCase = [Select Id, Status, ParentId from Case where Id = :thisCase.Id];
		Assert.assertNotEquals(c.Id, updatedCase.ParentId);
		Assert.assertNotEquals(MergeCaseListController.STATUS_DUPLICATE, updatedCase.Status);

		// Assign other case, observe that the assignment would success
                controller.parentId = c2.Id;
		controller.assignParentCase();
		Assert.assertEquals(null, controller.msg);

		Case updatedCase2 = [Select Id, Status, ParentId from Case where Id = :thisCase.Id];
		Assert.assertEquals(c2.Id, updatedCase2.ParentId);
		Assert.assertEquals(MergeCaseListController.STATUS_DUPLICATE, updatedCase2.Status);
	}

	/* Nagative Case - Case with Status Duplicate */
	@isTest static void testWtihStatusDuplicate_Negative() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

        	Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = MergeCaseListController.STATUS_DUPLICATE;
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
		controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

		Assert.assertEquals(0, caseList.size());
	}

	/* Nagative Case - Case with Parent Case */
	@isTest static void testWtihParentCase_Negative() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

		String firstName = 'First Name';
		String lastName = 'Last Name';

		Account a = new Account();
		a.Name = firstName + ' ' + lastName;
		a.First_Name__c = firstName;
		a.Last_Name__c = lastName;
		a.ROP_Tier__c = 'Gold';
		insert a;

		Flight__c f = new Flight__c();
		f.Name = 'TG 1234';
		insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

		Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

        	Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.PassengerId__c = p.Id;
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                thisCase.ParentId = c.Id;
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
		ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

		ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
		controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

		Assert.assertEquals(0, caseList.size());
	}

        /* Negative Case - Passenger is null */
        @isTest static void testWtihSamePassenger_PassengerIsNull() {

                MockupData_Test.initializeWebServiceCustomSetting();
                MockupData_Test.initializeSystemConfigurationCustomSetting();

                String firstName = 'First Name';
                String lastName = 'Last Name';

                Account a = new Account();
                a.Name = firstName + ' ' + lastName;
                a.First_Name__c = firstName;
                a.Last_Name__c = lastName;
                a.ROP_Tier__c = 'Gold';
                insert a;

                Flight__c f = new Flight__c();
                f.Name = 'TG 1234';
                insert f;

                Flight__c fdummy = new Flight__c();
                fdummy.Name = 'TGXXX';
                insert fdummy;

                Passenger__c p = new Passenger__c();
                p.SSR_Service__c = '';
                p.First_Name__c = firstName;
                p.Last_Name__c = lastName;
                p.FlightId__c = f.Id;
                p.AccountId__c = a.Id;
                p.Class__c = 'C';
                insert p;

                Case c = new Case();
                c.Subject = 'Case1';
                c.PassengerId__c = p.Id;
                c.FlightId__c = f.Id;
                c.Status = 'New';
                c.Channel__c = 'Phone';
                insert c;

                Case thisCase = new Case();
                thisCase.Subject = 'Case2';
                thisCase.FlightId__c = f.Id;
                thisCase.Status = 'New';
                thisCase.Channel__c = 'Phone';
                insert thisCase;

                Test.setCurrentPage(Page.MergeCaseListPage);
                ApexPages.currentPage().getParameters().put('id', String.valueOf(thisCase.Id));

                ApexPages.StandardController sc = new ApexPages.StandardController(thisCase);
                MergeCaseListController controller = new MergeCaseListController(sc);

                //List<Case> caseList = controller.getCaseList();
                controller.getCaseList();
                List<Case> caseList = controller.possiblyMergeCases;

                Assert.assertEquals(true, caseList.isEmpty());
                //Assert.assertNotEquals(null, controller.msg);
                Assert.assertEquals(null, controller.msg);
        }

        @isTest static void test_addEmailToMap(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

        }

        @isTest static void test_getNewEmailId(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                Id newEmailId = emailAttachment.getNewEmailId(oldEmail.Id);
                System.assertEquals(newEmail.Id, newEmailId);
        }

        @isTest static void test_getNewEmailKey(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                String key = emailAttachment.getNewEmailKey(oldEmail.Id);
                System.assertEquals('0', key); 
        }

        @isTest static void test_addAttachmentMap(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                Attachment attach1 = new Attachment();
                attach1.Name = 't1';
                attach1.ParentId = oldEmail.Id;

                emailAttachment.addAttachmentMap(attach1);
                System.assertEquals(1, emailAttachment.attachMap.size());
        }
        
        @isTest static void test_getAttachmentsFromMap(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                Attachment attach1 = new Attachment();
                attach1.Name = 't1';
                attach1.ParentId = oldEmail.Id;

                emailAttachment.addAttachmentMap(attach1);
                List<Attachment> attachmentList = emailAttachment.getAttachmentsFromMap();
                System.assertEquals(1, attachmentList.size());
        }

        @isTest static void test_getAttachmentToDeleteFromMap(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                Attachment attach1 = new Attachment();
                attach1.Name = 't1';
                attach1.ParentId = oldEmail.Id;

                emailAttachment.addAttachmentMap(attach1);
                List<Attachment> attachmentList = emailAttachment.getAttachmentToDeleteFromMap();
                System.assertEquals(1, attachmentList.size());
        }

        @isTest static void test_isAttachMapEmpty(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Boolean isAttachmentMapEmpty = emailAttachment.isAttachMapEmpty();
                System.assertEquals(true, isAttachmentMapEmpty);
        }

        @isTest static void test_isAttachMapToBeDeleteEmpty(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Boolean isAttachmentMapToBeDeleteEmpty = emailAttachment.isAttachMapToBeDeleteEmpty();
                System.assertEquals(true, isAttachmentMapToBeDeleteEmpty);
        }

        @isTest static void test_replaceEmailBodyWithNewAttachment(){
                MergeCaseListController.EmailAttachment emailAttachment = new MergeCaseListController.EmailAttachment();
                Case parentCase = new Case();
                parentCase.Subject = 'Test 1';
                insert parentCase;
                Case childCase = new Case();
                childCase.Subject = 'Test 1';
                insert childCase;

                EmailMessage oldEmail = new EmailMessage();
                oldEmail.ParentId = parentCase.Id;
                insert oldEmail;

                Attachment attach1 = new Attachment();
                attach1.Name = 't1';
                attach1.ParentId = oldEmail.Id;
                attach1.Body = Blob.valueOf('Test1');
                insert attach1;

                oldEmail.HtmlBody = attach1.Id;
                update oldEmail;

                EmailMessage newEmail = oldEmail.clone(false, true, true, true);
                newEmail.ParentId = childCase.Id;
                insert newEmail;
                
                emailAttachment.addEmailToMap(oldEmail, newEmail);

                emailAttachment.addAttachmentMap(attach1);
                List<Attachment> attachList = emailAttachment.getAttachmentsFromMap();
                insert attachList;
                emailAttachment.replaceEmailBodyWithNewAttachment();
        }
	
}