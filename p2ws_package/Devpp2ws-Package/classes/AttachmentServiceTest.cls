@isTest
private class AttachmentServiceTest {
	
	@isTest static void test_method_one() {
		Flight__c flight = MockupData_Test.getMockUpFlight();
		insert flight;
		MB_RestRequestInfoModel.attachment_list receiveAttachment = new MB_RestRequestInfoModel.attachment_list();
		receiveAttachment.body = new List<String> {'','','','',''};
        receiveAttachment.name = 'Test';
        receiveAttachment.contenttype = 'txt';
        receiveAttachment.parentId = flight.Id;
		AttachmentService.createAttachmentFromMobile(flight, receiveAttachment);
	}
}