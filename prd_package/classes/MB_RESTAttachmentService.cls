@RestResource(urlMapping = '/attachment/*')
global class MB_RESTAttachmentService {

    @HttpPost
    global static MB_RestRequestInfoModel.attachment_response doPost(MB_RestRequestInfoModel.attachment_list receiveAttachment) {
        List<Case> caseList = [SELECT Id FROM Case WHERE Mobile_App_Key__c = :receiveAttachment.parentId];
        String attachmentId = '';
        String salesforceId = '';
        Integer loopcount = 1;
        Integer bodyLength = 0;
        Blob bodyBlob = EncodingUtil.base64Decode(receiveAttachment.body.get(0) + receiveAttachment.body.get(1) + receiveAttachment.body.get(2) + receiveAttachment.body.get(3) + receiveAttachment.body.get(4));
        List<Attachment> attachmentList = new List<Attachment>();
        for (Case parentCase : caseList) {
            Attachment newAttachment = new Attachment(
                Name = receiveAttachment.Name,
                Body = bodyBlob,
                ParentId = parentCase.Id,
                ContentType = receiveAttachment.contenttype,
                Description = receiveAttachment.description
            );
            System.debug('Attachment: ' + newAttachment);
            attachmentList.add(newAttachment);
        }
        insert attachmentList;
        System.debug('In Method: ' + attachmentList);
        MB_RestRequestInfoModel.attachment_response returnResponse = new MB_RestRequestInfoModel.attachment_response();
        returnResponse.attachmentId = receiveAttachment.attachmentId;
        Integer i = 1;
        List<String> sfdcId = new List<String>();
        for(Attachment attach : attachmentList){
            //returnResponse.salesforceId.add(attach.Id);
            sfdcId.add(attach.Id);
            i++;
        }
        returnResponse.salesforceId = sfdcId;
        return returnResponse;
    }
}