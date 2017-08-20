@RestResource(urlMapping = '/compensation/attachment/*')
global class MB_RESTCompensationAttachment {

	@HttpPost
	global static MB_RestRequestInfoModel.attachment_response doPost(MB_RestRequestInfoModel.attachment_list receiveAttachment) {
		Compensation__c compensation = [SELECT Id FROM Compensation__c WHERE Mobile_App_Key__c = : receiveAttachment.parentId LIMIT 1];
		return AttachmentService.createAttachmentFromMobile(compensation, receiveAttachment);
	}
}