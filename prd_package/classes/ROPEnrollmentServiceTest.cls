@isTest
private class ROPEnrollmentServiceTest {
	private static String ROP_ENROLLMENT_SUCCESS_RESPONSE = '{"EnrollROPMemberRes":{"UpdateMemberCommunicationPreferenceRS":{"Success":{"Message":"Successfully Added","Code":"SUE01"},"Error":null},"UpdateCustomerSSRRS":{"Success":{"Message":"Successfully Updated","Code":"I120"},"Error":null},"AddPendingEnrolmentRS":null,"AddMainProfileRS":{"Success":{"Message":"ADD has been successfully completed.","Code":"I110"},"Error":null}}}';
	private static String ROP_ENROLLMENT_DUPLICATE_MEMBER_RESPONSE = '{"EnrollROPMemberRes":{"UpdateMemberCommunicationPreferenceRS":null,"UpdateCustomerSSRRS":null,"AddPendingEnrolmentRS":null,"AddMainProfileRS":{"Success":null,"Error":{"Type":"Web service.","Message":"Possible Duplicate Member","Code":"I850"}}}}';
	private static String ROP_ENROLLMENT_WRONG_EMAIL_FORMAT_RESPONSE = '{"EnrollROPMemberRes":{"UpdateMemberCommunicationPreferenceRS":{"Success":null,"Error":{"Type":null,"Message":"Please enter a correct e-mail.","Code":"E98"}},"UpdateCustomerSSRRS":{"Success":{"Message":"Successfully Updated","Code":"I120"},"Error":null},"AddPendingEnrolmentRS":null,"AddMainProfileRS":{"Success":{"Message":"ADD has been successfully completed.","Code":"I110"},"Error":null}}}';

	@isTest static void testGetUnregisteredROPNumberList() {
		insert MockupData_Test.createROPNumberInventoryList(1000);

		Integer numberOfROPNumber = 100;
		List<ROP_Number_Inventory__c> ropNumberList = ROPEnrollmentService.getUnregisteredROPNumberList(numberOfROPNumber);
		Assert.assertEquals(numberOfROPNumber, ropNumberList.size(), 'The number of ROP Number must be equals to ' + numberOfROPNumber + '.');
	}

	/*
		Scenario: Success response from THAI for ROP Enrollment. Every Success nodes are not null.
		Positive/Negative Case: Positive
		Expected Result: isErrorResponse should return false
	*/
	@isTest static void testIsErrorResponseNoError() {
		WS_ROPEnrollmentResponseModel response = (WS_ROPEnrollmentResponseModel) System.JSON.deserialize(ROP_ENROLLMENT_SUCCESS_RESPONSE, WS_ROPEnrollmentResponseModel.class);
		Assert.assert(!ROPEnrollmentService.isErrorResponse(response));
	}

	/*
		Scenario: Fail response from THAI for ROP Enrollment. Possible Duplicate Member due to First Name + Last Name + Birthdate collision.
		Positive/Negative Case: Positive
		Expected Result: isErrorResponse should return true
	*/
	@isTest static void testIsErrorResponsePossibleDuplicate() {
		WS_ROPEnrollmentResponseModel response = (WS_ROPEnrollmentResponseModel) System.JSON.deserialize(ROP_ENROLLMENT_DUPLICATE_MEMBER_RESPONSE, WS_ROPEnrollmentResponseModel.class);
		Assert.assert(ROPEnrollmentService.isErrorResponse(response));
	}

	/*
		Scenario: Fail response from THAI for ROP Enrollment. Wrong Email format
		Positive/Negative Case: Positive
		Expected Result: isErrorResponse should return true
	*/
	@isTest static void testIsErrorResponseWrongEmailFormat() {
		WS_ROPEnrollmentResponseModel response = (WS_ROPEnrollmentResponseModel) System.JSON.deserialize(ROP_ENROLLMENT_WRONG_EMAIL_FORMAT_RESPONSE, WS_ROPEnrollmentResponseModel.class);
		Assert.assert(ROPEnrollmentService.isErrorResponse(response));
	}

	/*
		Scenario: PIN Number must be generated with at least one Alphabet and any number of digits
		Positive/Negative Case: Positive
		Expected Result: No assertion error when checking the generated PIN Numbers against isAlphanumeric method
	*/
	@isTest static void testGeneratePINNumberShouldContainsAtLeastOneAlpha() {
		for (Integer i = 0; i < 1000; i++) {
			Assert.assert(ROPEnrollmentService.generatePINNumber().isAlphanumeric());
		}
	}

	private static ROP_Enrollment__c createROPEnrollmentForTest(String responseString, String enrollmentStatus) {
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;

		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'Y');
		insert passenger;

		String ropNumber = '19283u';
		ROP_Number_Inventory__c ropNumberInventory = new ROP_Number_Inventory__c(Name = ropNumber, ROP_Number__c = ropNumber);
		insert ropNumberInventory;

		MB_RestRequestInfoModel.ropEnrollment model = MockupData_Test.createROLEnrollmentMobileRequest(ropNumber, flight.Id, passenger.Id);
		model.paxKey = MB_RESTPassengerService.getPaxKey(passenger);
		model.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(enrollmentStatus);

		WS_ROPEnrollmentResponseModel response = (WS_ROPEnrollmentResponseModel) System.JSON.deserialize(responseString, WS_ROPEnrollmentResponseModel.class);

		ROP_Enrollment__c ropEnrollment = ROPEnrollmentService.createROPEnrollmentRecord(ropNumberInventory, model, response);
		return ropEnrollment;
	}

	/*
		Scenario: Create ROP Enrollment record with Success Response
		Positive/Negative Case: Positive
		Expected Result:
		- ROP Enrollment is created
		- No Integration Error
		- Status is Enroll
	*/
	@isTest static void testCreateROPEnrollmentRecordWithSuccessResponse() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, ROPEnrollmentService.STATUS_ENROLL);
		Assert.assert(ropEnrollment != null);
		Assert.assert(!ropEnrollment.Integration_Error__c);
		Assert.assertEquals(null, ropEnrollment.Integration_Error_Reason__c);
		Assert.assertEquals(ROPEnrollmentService.STATUS_ENROLL, ropEnrollment.Status__c);
	}

	/*
		Scenario: Create ROP Enrollment record with Duplicate Member Response
		Positive/Negative Case: Positive
		Expected Result:
		- ROP Enrollment is created
		- Has Integration Error
		- Integration Error Reason equals to REASON_DUPLICATE_MEMBER
		- Status is Enroll
	*/
	@isTest static void testCreateROPEnrollmentRecordWithDuplicateMemberResponse() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_DUPLICATE_MEMBER_RESPONSE, ROPEnrollmentService.STATUS_ENROLL);
		Assert.assert(ropEnrollment != null);
		Assert.assert(ropEnrollment.Integration_Error__c);
		Assert.assertEquals(ROPEnrollmentService.REASON_DUPLICATE_MEMBER, ropEnrollment.Integration_Error_Reason__c);
		Assert.assertEquals(ROPEnrollmentService.STATUS_ENROLL, ropEnrollment.Status__c);
	}

	/*
		Scenario: Create ROP Enrollment record with Wrong Email Response
		Positive/Negative Case: Positive
		Expected Result:
		- ROP Enrollment is created
		- Has Integration Error
		- Integration Error Reason equals to REASON_WRONG_EMAIL_FORMAT
		- Status is Enroll
	*/
	@isTest static void testCreateROPEnrollmentRecordWithWrongEmailFormatRespons() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_WRONG_EMAIL_FORMAT_RESPONSE, ROPEnrollmentService.STATUS_ENROLL);
		Assert.assert(ropEnrollment != null);
		Assert.assert(ropEnrollment.Integration_Error__c);
		Assert.assertEquals(ROPEnrollmentService.REASON_WRONG_EMAIL_FORMAT, ropEnrollment.Integration_Error_Reason__c);
		Assert.assertEquals(ROPEnrollmentService.STATUS_ENROLL, ropEnrollment.Status__c);
	}

	/*
		Scenario: Create ROP Enrollment record with Void status
		Positive/Negative Case: Positive
		Expected Result:
		- ROP Enrollment is created
		- Status is Void
	*/
	@isTest static void testCreateROPEnrollmentRecordWithStatusVoid() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, ROPEnrollmentService.STATUS_VOID);
		Assert.assert(ropEnrollment != null);
		Assert.assertEquals(ROPEnrollmentService.STATUS_VOID, ropEnrollment.Status__c);
	}

	/*
		Scenario: Create ROP Enrollment record with Null status
		Positive/Negative Case: Negative
		Expected Result:
		- ROP Enrollment is created
		- Status is null
	*/
	@isTest static void testCreateROPEnrollmentRecordWithStatusNull() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, null);
		Assert.assert(ropEnrollment != null);
		Assert.assertEquals(null, ropEnrollment.Status__c);
	}

	/*
		Scenario: Create ROP Enrollment record with Bad Input as status
		Positive/Negative Case: Negative
		Expected Result:
		- ROP Enrollment is created
		- Status is null
	*/
	@isTest static void testCreateROPEnrollmentRecordWithBadInputStatus() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, '0jr0af09');
		Assert.assert(ropEnrollment != null);
		Assert.assertEquals(null, ropEnrollment.Status__c);
	}

	/*
		Scenario: ROP Enrollment status had been changed from "Enroll" to "Void". An email must be sent to notify the admin.
		Positive/Negative Case: Positive
		Expected Result:
		- An email is sent.
	*/
	@isTest static void testSendEmailNotifyVoidedROPEnrollment() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, '0jr0af09');
		insert ropEnrollment;
		ropEnrollment.Status__c = ROPEnrollmentService.STATUS_VOID;
		update ropEnrollment;
		Assert.assertEquals(1, Limits.getEmailInvocations());
	}

	@isTest static void testSendEmailNotifyInsufficientNumberOfROPNumber() {
		ROPEnrollmentService.sendEmailNotifyInsufficientNumberOfROPNumber(0);
	}

	@isTest static void testEnrollROPMemberFromMobileModel() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockROPEnrollmentWSFactory.MockROPEnrollmentWSSUCCESS());

		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;

		Passenger__c passenger = MockupData_Test.createPassenger(flight.Id, 'Y');
		insert passenger;

		String ropNumber = '19283u';
		ROP_Number_Inventory__c ropNumberInventory = new ROP_Number_Inventory__c(Name = ropNumber, ROP_Number__c = ropNumber);
		insert ropNumberInventory;

		MB_RestRequestInfoModel.ropEnrollment model = MockupData_Test.createROLEnrollmentMobileRequest(ropNumber, flight.Id, passenger.Id);
		model.paxKey = MB_RESTPassengerService.getPaxKey(passenger);
		model.status = ROPEnrollmentService.ROP_ENROLLMENT_STATUS_FROM_MOBILE_MAP_BY_STRING.get(ROPEnrollmentService.STATUS_ENROLL);

		Test.startTest();
		ROPEnrollmentService.enrollROPMemberFromMobileModel(model);
		Test.stopTest();
		ROPEnrollmentService.getROPEnrollmentMobileList(new Set<Id> {flight.Id});
	}

	@isTest static void testConvertROPEnrollmentSObjectToResponseModel() {
		ROP_Enrollment__c ropEnrollment = createROPEnrollmentForTest(ROP_ENROLLMENT_SUCCESS_RESPONSE, '0jr0af09');
		ROPEnrollmentService.convertROPEnrollmentSObjectToResponseModel(new List<ROP_Enrollment__c> {ropEnrollment});
	}
}