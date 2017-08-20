@RestResource(urlMapping = '/ropEnrollment/attachment/*')
global class MB_RESTROPEnrollmentAttachment {

	@HttpPost
	global static MB_RestRequestInfoModel.attachment_response doPost(MB_RestRequestInfoModel.attachment_list receiveAttachment) {
		ROP_Enrollment__c ropEnrollment = [SELECT Id FROM ROP_Enrollment__c WHERE PaxKey__c = : receiveAttachment.parentId LIMIT 1];
		return AttachmentService.createAttachmentFromMobile(ropEnrollment, receiveAttachment);
	}
}