public with sharing class AttachmentService {
	
	public static MB_RestRequestInfoModel.attachment_response createAttachmentFromMobile(SObject parentObject, MB_RestRequestInfoModel.attachment_list receiveAttachment){
		Blob bodyBlob = EncodingUtil.base64Decode(receiveAttachment.body.get(0) + receiveAttachment.body.get(1) + receiveAttachment.body.get(2) + receiveAttachment.body.get(3) + receiveAttachment.body.get(4));
		Attachment newAttachment = new Attachment(
		    Name = receiveAttachment.Name,
		    Body = bodyBlob,
		    ParentId = parentObject.Id,
		    ContentType = receiveAttachment.contenttype,
		    Description = receiveAttachment.description
		);
		insert newAttachment;

		MB_RestRequestInfoModel.attachment_response returnResponse = new MB_RestRequestInfoModel.attachment_response();
		returnResponse.attachmentId = receiveAttachment.attachmentId;
		returnResponse.parentId = receiveAttachment.parentId;
		List<String> sfdcId = new List<String>();
		sfdcId.add(newAttachment.Id);
		returnResponse.salesforceId = sfdcId;
		return returnResponse;
	}
}