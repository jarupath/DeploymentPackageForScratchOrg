@isTest
private class CSE_SOAPROPEnrollment_WS_Test {
	public static WS_ROPEnrollmentRequestModel createMockUPSOAPROPEnrollmentRequest(){
		WS_ROPEnrollmentRequestModel model = new WS_ROPEnrollmentRequestModel();
		model.EnrolROPMemberRQ = new WS_ROPEnrollmentRequestModel.EnrolROPMemberRQ();
		model.EnrolROPMemberRQ.MemberID = 'GR89601';
		model.EnrolROPMemberRQ.Salutation = 'Mr.';
		model.EnrolROPMemberRQ.FirstName = 'Nutchaasdnon';
		model.EnrolROPMemberRQ.LastName = 'Phongdsoen';
		model.EnrolROPMemberRQ.PinNumber = '9sj30ans';
		model.EnrolROPMemberRQ.Address = new WS_ROPEnrollmentRequestModel.Address();
		model.EnrolROPMemberRQ.Address.AddressType = 'H';
		model.EnrolROPMemberRQ.Address.AddressLine1 = 'xxx';
		model.EnrolROPMemberRQ.Address.City = 'Bangkok';
		model.EnrolROPMemberRQ.Address.CountryCode = 'TH';
		model.EnrolROPMemberRQ.Address.PostalCode = '99999';
		model.EnrolROPMemberRQ.PhoneType1 = 'H';
		model.EnrolROPMemberRQ.CountryCode1 = '66';
		model.EnrolROPMemberRQ.AreaCode1 = '02';
		model.EnrolROPMemberRQ.Number1 = '12312321';
		model.EnrolROPMemberRQ.EmailAddress = 'sdfsdf@gmail.com';
		model.EnrolROPMemberRQ.BirthDate = '1962-04-01';
		model.EnrolROPMemberRQ.Gender = 'M';
		model.EnrolROPMemberRQ.EnrollSource = 'IFLIGHT';
		model.EnrolROPMemberRQ.Language = 'TH';
		model.EnrolROPMemberRQ.Nationality = 'TH';
		model.EnrolROPMemberRQ.EnrollDate = '2017-01-01';
		return model;
	}
	
	/*
		Scenario: Call Web Service to enroll ROP Member successfully
		Positive/Negative Case: Positive
		Expected Result:
		- Response is not null
		- Response has no error
	*/
	@isTest static void testEnrollROPMemberWithSuccessResponse() {
		MockupData_Test.initializeWebServiceCustomSetting();
		Test.setMock(HttpCalloutMock.class, new MockROPEnrollmentWSFactory.MockROPEnrollmentWSSUCCESS());
		Test.startTest();
		WS_ROPEnrollmentRequestModel model = createMockUPSOAPROPEnrollmentRequest();
		WS_ROPEnrollmentResponseModel response = new CSE_SOAPROPEnrollment_WS().enrollROPMember(model);
		Test.stopTest();
		Assert.assert(response != null);
		Assert.assert(!ROPEnrollmentService.isErrorResponse(response));
	}
	
}