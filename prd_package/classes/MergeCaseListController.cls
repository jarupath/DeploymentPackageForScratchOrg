/*
  https://be8-sccc.atlassian.net/browse/TGSIC-224 - Create apex class for duplication page
  https://be8-sccc.atlassian.net/browse/TGSIC-232 - Create visualforce page for duplication

  Class for Merge Case List Left Highligt Panel on Case Service Console
  This class is for producing list of cases to be merged to case in the main panel
*/

public class MergeCaseListController {
  public Id parentId {get; set;}
  public Case parentCase {get; set;}
  public List<Case> relatedCases {get; set;}
  public List<Case> possiblyMergeCases {get; set;}
  public Case thisCase {get; set;}
  public String msg {get; set;}
  public Id testId {get; set;}

  public class EmailAttachment{
    public Map<String, EmailMessage> newEmailMessageMapByKey;
    public Map<Id, String> keyMapByOldEmailMessageId;
    public Map<String, List<Attachment>> attachMap;
    public Map<String, List<Attachment>> attachMapToDelete;
    public Integer key;
    public Map<String, Map<String, String>> mapOfNewAttachIdMapWithOldAttachId;

    public EmailAttachment(){
      key = 0;
    }

    public void addEmailToMap(EmailMessage oldEmail, EmailMessage newEmail){
      if(newEmailMessageMapByKey == null) newEmailMessageMapByKey = new Map<String, EmailMessage>();
      if(keyMapByOldEmailMessageId == null) keyMapByOldEmailMessageId = new Map<Id, String>();
      if(newEmailMessageMapByKey.containsKey(String.valueOf(key))) key++;
      newEmailMessageMapByKey.put(String.valueOf(key), newEmail);
      keyMapByOldEmailMessageId.put(oldEmail.Id, String.valueOf(key));
    }

    public Id getNewEmailId(Id parentId){
      Id returnId = null;
      String key = null;
      if(keyMapByOldEmailMessageId.containsKey(parentId)){
        key = keyMapByOldEmailMessageId.get(parentId);
        if(newEmailMessageMapByKey.containsKey(key)) returnId = newEmailMessageMapByKey.get(key).Id;
      }
      return returnId;
    }

    public String getNewEmailKey(Id parentId){
      String key = null;
      if(keyMapByOldEmailMessageId.containsKey(parentId)){
        key = keyMapByOldEmailMessageId.get(parentId);
      }
      return key;
    }

    public void addAttachmentMap(Attachment attach){
      Attachment attachment = null;
      if(attach != null){
        if(getNewEmailId(attach.ParentId) != null){
          attachment = attach.clone(false, true, true, true);
          attachment.ParentId = getNewEmailId(attach.ParentId);
          String key = getNewEmailKey(attach.ParentId);

          if(attachMap == null) attachMap = new Map<String, List<Attachment>>();

          if(attachMap.containsKey(key)) attachMap.get(key).add(attachment);
          else {
            attachMap.put(key, new List<Attachment>{attachment});
          }

          if(attachMapToDelete == null) attachMapToDelete = new Map<String, List<Attachment>>();

          if(attachMapToDelete.containsKey(key)) attachMapToDelete.get(key).add(new Attachment(Id = attach.Id));
          else {
            Attachment at = new Attachment();
            at.Id = attach.Id;
            attachMapToDelete.put(key, new List<Attachment>{at});
          }
        }
      }
    }

    public void log(){
      AppLogger.debug('MergeCaseListController', 'assignParentCase', null, 'new email: ' + JSON.serialize(newEmailMessageMapByKey), null);
      AppLogger.debug('MergeCaseListController', 'assignParentCase', null, 'key map: ' + JSON.serialize(keyMapByOldEmailMessageId), null);
      AppLogger.debug('MergeCaseListController', 'assignParentCase', null, 'attachMap: ' + JSON.serialize(attachMap), null);
      AppLogger.debug('MergeCaseListController', 'assignParentCase', null, 'attachMapToDelete: ' + JSON.serialize(attachMapToDelete), null);
    }

    public List<Attachment> getAttachmentsFromMap(){
      List<Attachment> attachs = null;
      if(attachMap != null && !attachMap.isEmpty()){
        for(List<Attachment> atts : attachMap.values()){
          if(attachs == null) attachs = new List<Attachment>();
          attachs.addAll(atts);
        }
      }
      return attachs;
    }

    public List<Attachment> getAttachmentToDeleteFromMap(){
      List<Attachment> attachs = null;
      if(attachMapToDelete != null && !attachMapToDelete.isEmpty()){
        for(List<Attachment> atts : attachMapToDelete.values()){
          if(attachs == null) attachs = new List<Attachment>();
          attachs.addAll(atts);
        }
      }
      return attachs;
    }

    public Boolean isAttachMapEmpty(){
      return (attachMap == null || attachMap.isEmpty());
    }

    public Boolean isAttachMapToBeDeleteEmpty(){
      return (attachMapToDelete == null || attachMapToDelete.isEmpty());
    }

    public void replaceEmailBodyWithNewAttachment(){
      if(!isAttachMapEmpty() && !isAttachMapToBeDeleteEmpty() && newEmailMessageMapByKey != null && !newEmailMessageMapByKey.isEmpty()){
        for(String key : attachMap.keySet()){
          for(Attachment attach : attachMap.get(key)){
            if(attachMapToDelete.containsKey(key)){
              for(Attachment attachDelete : attachMapToDelete.get(key)){
                if(newEmailMessageMapByKey.containsKey(key)){
                  EmailMessage email = newEmailMessageMapByKey.get(key);
                  String attachId = String.valueOf(attachDelete.Id).substring(0, 15);
                  String targetId = String.valueOf(attach.Id).substring(0, 15);
                  if(email.HtmlBody != null && email.HtmlBody.contains(attachId)){
                    email.HtmlBody = email.HtmlBody.replace(attachId, targetId);
                    break;
                  } 
                }
              }
            }
          }
        }
      }
    }
  }

  public Static String STATUS_DUPLICATE = 'Duplicate';
  public Static String ERROR_MESSAGE = 'Could not merge case to its own children. Please select other case.';
  
  public MergeCaseListController(ApexPages.StandardController stdController){
    Id caseId = Apexpages.Currentpage().getParameters().get('id');
    testId = caseId;

    List<Case> caseList = [Select Passengerid__c, Flightid__c, ParentId, AccountId,Case_Type__c, Status, Subject, SuppliedEmail from Case Where id = :caseid];
   	if(!caseList.isEmpty()) {
      thisCase = caseList.get(0);
    }

    getCaseList();
  }
  
  public void getCaseList(){
    msg = null;

    if(thisCase == null) {
      msg = 'Case not found';
      return;
    }

    //List<Case> cases = new List<Case>();
    Map<Id, Case> caseMap = new Map<Id, Case>();

    if(thisCase.Passengerid__c != null) {
      String query = 'Select  id,' +
                            'AccountId, ' +
                            'PassengerId__c, ' + 
                            'PassengerId__r.Name, ' + 
                            'CaseNumber, ' +
                            'Flightid__c, ' +
                            'Flightid__r.Name, ' +
                            'Description, ' +
                            'Status, ' +
                            'Case_Type__c, ' +
                            'CreatedBy.Station__c, ' +
                            'CreatedBy.Department, ' +
                            'ParentId ' + 
                   'from   Case ' + 
                   'Where ((Passengerid__c = \'' + thisCase.Passengerid__c + '\'' + 
                          (thisCase!=null && thisCase.AccountId!=null?' OR AccountId = \'' + thisCase.AccountId +'\'':'') +
                          ') AND Id != \'' + thisCase.Id + '\') ';
                          //'AND ParentId != \'' + thisCase.Id + '\' ' +
                          //(thisCase!=null && thisCase.ParentId!=null?'AND Id != \'' + thisCase.ParentId + '\' ': ' ') +
                          //'AND Status != \''+ STATUS_DUPLICATE +'\'' +
                   //'Order by LastModifiedDate desc';

      if(thisCase.ParentId != null) {
        query += ' OR Id = \'' + thisCase.ParentId +'\' ';
      }
      query += ' OR ParentId = \'' + thisCase.Id + '\'';
      query += ' Order by LastModifiedDate desc';
            
      System.debug('query :' + query);
      
      //List<Case> caseList =  Database.query(query);
      //cases.addAll(caseList);

      Map<Id, Case> possibleCaseMap = new Map<Id, Case>((List<Case>)Database.query(query));
      caseMap.putAll(possibleCaseMap);
    }

    if(thisCase.Subject != null){
      String subject = thisCase.Subject.replaceAll(' ', '').toLowerCase();
      while(subject.startsWith('re:')) {
        subject = subject.removeStart('re:');
      }
      String subjectCondition = '%' + subject + '%';
      System.debug('subjectCondition :' + subjectCondition);

      if(String.isNotBlank(thisCase.SuppliedEmail)) {
        //List<Case> caseList = [SELECT Id, AccountId, Passengerid__c, PassengerId__r.Name, CaseNumber, Flightid__c, Flightid__r.Name, Description, Status, Case_Type__c, CreatedBy.Station__c, CreatedBy.Department, Subject, ParentId FROM Case WHERE (SuppliedEmail = :thisCase.SuppliedEmail AND Id != :thisCase.Id AND Email_To_Case_Key__c LIKE :subjectCondition) OR ParentId = :thisCase.Id];
        //cases.addAll(caseList);

        Map<Id, Case> possibleCaseMap = new Map<Id, Case>([SELECT Id, AccountId, Passengerid__c, PassengerId__r.Name, CaseNumber, Flightid__c, Flightid__r.Name, Description, Status, Case_Type__c, CreatedBy.Station__c, CreatedBy.Department, Subject, ParentId FROM Case WHERE (SuppliedEmail = :thisCase.SuppliedEmail AND Id != :thisCase.Id AND Email_To_Case_Key__c LIKE :subjectCondition) OR ParentId = :thisCase.Id]);
        caseMap.putAll(possibleCaseMap);
      }
    }

    parentCase = null;
    relatedCases = new List<Case>();
    possiblyMergeCases = new List<Case>();

    //for(Case eachCase : cases) {
    for(Case eachCase : caseMap.values()) {
      if(parentCase == null && thisCase.ParentId != null) {
        if(eachCase.Id == thisCase.ParentId) {
          parentCase = eachCase;
          continue;
        }
      }

      if(eachCase.ParentId == thisCase.Id) {
        relatedCases.add(eachCase);
        continue;
      }

      if(eachCase.Status != STATUS_DUPLICATE) {
        possiblyMergeCases.add(eachCase);
      }
    }
    if(!relatedCases.isEmpty()) possiblyMergeCases = new List<Case>();
  }
    
    /*
      https://be8-sccc.atlassian.net/browse/TGSIC-224 - Create apex class for duplication page
      Create apex class for duplication page

      After click "Merge" icon, system will automatically merge parent-child case and case status will be changed as "Duplicated". The first case which is merged will be parent and case in detail page will be child.
      ------------------------------
      Estimated = 2 MD
      ------------------------------

      Confirming matching logic as below:
      1. Merge case in main panel (detail page) as child of the case being displayed in left high-light panel when merge icon is clicked.
      2. Mark case in main panel (detail page)'s Status as "Duplicate".
    */
    public PageReference assignParentCase() {
      msg = null;
    	thisCase.ParentId = parentId;
      thisCase.Status = STATUS_DUPLICATE;

      List<EmailMessage> newEmailMessages = new List<EmailMessage>();
      List<SObject> oldEmailMessages = getEmailMessagesByOriginalCaseId(thisCase.Id);
      if(oldEmailMessages != null && !oldEmailMessages.isEmpty()) AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(1)oldEmailMessages size: ' + oldEmailMessages.size() + '\noldEmailMessages: ' + JSON.serialize(oldEmailMessages), null);
      else AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(1)oldEmailMessages is null or empty', null);
      List<Attachment> attachmentList = null;
      if(oldEmailMessages != null && !oldEmailMessages.isEmpty()) attachmentList = getEmailMessageAttachmentByEmailList((List<EmailMessage>)oldEmailMessages);
      if(attachmentList != null && !attachmentList.isEmpty()) AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id,'(2)attachmentList size: ' + attachmentList.size(), null);
      else AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(2)attachmentList is null ', null);
      Map<String, Id> oldEmailMessagesIdMapByRunningNo = null;
      EmailAttachment emailAttachment = new EmailAttachment();
      for(SObject eachOldEmailMessage : oldEmailMessages) {
        EmailMessage eachEmailMessage = (EmailMessage)eachOldEmailMessage;
        EmailMessage newEmailMessage = eachEmailMessage.clone(false, true, true, true);
        newEmailMessage.ParentId = parentId;
        newEmailMessage.isMerge_Demerge__c = true;
        newEmailMessages.add(newEmailMessage);
        emailAttachment.addEmailToMap((EmailMessage)eachOldEmailMessage, newEmailMessage);
      }
      if(newEmailMessages != null && !newEmailMessages.isEmpty()) AppLogger.debug('MergeCaseListController', 'assignParentCase', null, '(3)newEmailMessages size: ' + newEmailMessages.size() + '\nnewEmailMessages: ' + JSON.serialize(newEmailMessages), null);
      else AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(3)newEmailMessages is null or empty', null);

      try {
        if(!newEmailMessages.isEmpty()) {
          Database.SaveResult[] newEmailMessagesInsertResults = Database.insert(newEmailMessages, true);
          AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(4)newEmailMessages insert result: ' + JSON.serialize(newEmailMessagesInsertResults), null);
          AppLogger.insertLogs();
          if(attachmentList != null && !attachmentList.isEmpty()){
            for(Attachment attach : attachmentList){
              if(emailAttachment.getNewEmailId(attach.ParentId) != null){
                emailAttachment.addAttachmentMap(attach);
              }
            }

            if(!emailAttachment.isAttachMapEmpty()){
              Database.SaveResult[] results = Database.insert(emailAttachment.getAttachmentsFromMap(), true);
              AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(5)attachMapTo insert result: ' + JSON.serialize(results), null);
              AppLogger.insertLogs();
            }
            
            emailAttachment.replaceEmailBodyWithNewAttachment();

            if(!emailAttachment.isAttachMapToBeDeleteEmpty()){
              Database.DeleteResult[] results = Database.delete(emailAttachment.getAttachmentToDeleteFromMap(), true);
              AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(6)attachMapToDelete delete result: ' + JSON.serialize(results), null);
              AppLogger.insertLogs();
            } 
            Database.SaveResult[] newEmailMessagesUpdateResults = Database.update(newEmailMessages, true);
            AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(7)newEmailMessages update result: ' + JSON.serialize(newEmailMessagesUpdateResults), null);
            AppLogger.insertLogs();
          }
        } 
        Database.DeleteResult[] oldEmailMessagesDeleteResults = Database.delete(oldEmailMessages, true);
        AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(8)oldEmailMessages delete result: ' + JSON.serialize(oldEmailMessagesDeleteResults), null);
        AppLogger.insertLogs();

        Database.SaveResult thisCaseUpdateResult = Database.update(thisCase, true);
        AppLogger.debug('MergeCaseListController', 'assignParentCase', thisCase.Id, '(9)thisCase update result: ' + JSON.serialize(thisCaseUpdateResult), null);
        AppLogger.insertLogs();
      } catch(Exception e) {
        msg = ERROR_MESSAGE;
        String errMsg = 'Child:' + thisCase.Id + '|Parent:' + parentId;
        AppLogger.error('MergeCaseListController', 'assignParentCase', thisCase.Id, errMsg, e);
        AppLogger.insertLogs();
      }
      return null;
    }

    public PageReference demerge() {
      List<EmailMessage> oldEmailMessages = getEmailMessagesByOriginalCaseId(thisCase.Id);
      if(oldEmailMessages != null && !oldEmailMessages.isEmpty()) AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(1)oldEmailMessages size: ' + oldEmailMessages.size() + '\noldEmailMessages: ' + JSON.serialize(oldEmailMessages), null);
      else AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(1)oldEmailMessages is null or empty', null);
      List<EmailMessage> newEmailMessages = new List<EmailMessage>();
      EmailAttachment emailAttachment = new EmailAttachment();
      for(SObject eachOldEmailMessage : oldEmailMessages) {
        EmailMessage eachEmailMessage = (EmailMessage)eachOldEmailMessage;
        EmailMessage newEmailMessage = eachEmailMessage.clone(false, true, true, true);
        newEmailMessage.ParentId = thisCase.Id;
        newEmailMessage.isMerge_Demerge__c = true;
        newEmailMessages.add(newEmailMessage);
        emailAttachment.addEmailToMap((EmailMessage)eachOldEmailMessage, newEmailMessage);
      }
      if(newEmailMessages != null && !newEmailMessages.isEmpty()) AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(2)newEmailMessages size: ' + newEmailMessages.size(), null);
      else AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(2)newEmailMessages is null or empty', null);
      updateEmailMessages(oldEmailMessages, newEmailMessages, emailAttachment);
      thisCase.ParentId = null;
      //update thisCase;
      Database.SaveResult thisCaseUpdateResult = Database.update(thisCase, true);
      AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(3)thisCase update result: ' + JSON.serialize(thisCaseUpdateResult), null);
      AppLogger.insertLogs();

      return null;
    }

    public void updateEmailMessages(List<EmailMessage> oldEmailMessages, List<EmailMessage> newEmailMessages, EmailAttachment emailAttachment) {
      try {
        List<Attachment> attachmentList = null;
        System.debug('oldEmailMessages: ' + oldEmailMessages.size());
        if(oldEmailMessages != null && !oldEmailMessages.isEmpty()) attachmentList = getEmailMessageAttachmentByEmailList((List<EmailMessage>)oldEmailMessages);
        if(!newEmailMessages.isEmpty()) {
          //insert newEmailMessages;
          Database.SaveResult[] newEmailMessagesInsertResults = Database.insert(newEmailMessages, true);
          AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(4)newEmailMessages insert result: ' + JSON.serialize(newEmailMessagesInsertResults), null);
          AppLogger.insertLogs();
          if(attachmentList != null && !attachmentList.isEmpty()){
            for(Attachment attach : attachmentList){
              if(emailAttachment.getNewEmailId(attach.ParentId) != null){
                emailAttachment.addAttachmentMap(attach);
              }
            }

            //if(!emailAttachment.isAttachMapEmpty()) insert emailAttachment.getAttachmentsFromMap();
            if(!emailAttachment.isAttachMapEmpty()){
              Database.SaveResult[] results = Database.insert(emailAttachment.getAttachmentsFromMap(), true);
              AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(5)attachMapTo insert result: ' + JSON.serialize(results), null);
              AppLogger.insertLogs();
            }
            emailAttachment.replaceEmailBodyWithNewAttachment();
            //if(!emailAttachment.isAttachMapToBeDeleteEmpty()) delete emailAttachment.getAttachmentToDeleteFromMap();
            if(!emailAttachment.isAttachMapToBeDeleteEmpty()){
              Database.DeleteResult[] results = Database.delete(emailAttachment.getAttachmentToDeleteFromMap(), true);
              AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(6)attachMapToDelete delete result: ' + JSON.serialize(results), null);
              AppLogger.insertLogs();
            } 
            //update newEmailMessages;
            Database.SaveResult[] newEmailMessagesUpdateResults = Database.update(newEmailMessages, true);
            AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(7)newEmailMessages update result: ' + JSON.serialize(newEmailMessagesUpdateResults), null);
            AppLogger.insertLogs();
          }
        } 
        //delete oldEmailMessages;
        Database.DeleteResult[] oldEmailMessagesDeleteResults = Database.delete(oldEmailMessages, true);
        AppLogger.debug('MergeCaseListController', 'demerge', thisCase.Id, '(8)oldEmailMessages delete result: ' + JSON.serialize(oldEmailMessagesDeleteResults), null);
        AppLogger.insertLogs();
      } catch(Exception e) {
        msg = ERROR_MESSAGE;
        String errMsg = 'Child:' + thisCase.Id + '|Parent:' + parentId;
        AppLogger.error('MergeCaseListController', 'demerge', thisCase.Id, errMsg, e);
      }
    }

    public List<EmailMessage> getEmailMessagesByOriginalCaseId(Id caseId) {
      Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('EmailMessage');
      BE8_SoqlBuilder soql = new BE8_SoqlBuilder('EmailMessage');
      soql.addField(fields);
      soql.addField('Id');
      soql.addCondition('Original_Case__c', thisCase.Id);      
      //soql.addCondition('RelatedToId', thisCase.Id);      
      List<EmailMessage> emailMessages = (List<EmailMessage>)Database.query(soql.getQueryStr());
      return emailMessages;
    }

    public Map<Id, List<Attachment>> getAttachmentMap(List<EmailMessage> emails){
      List<Attachment> attachments = getEmailMessageAttachmentByEmailList(emails);
      return getAttachmentListMapByEmailRelatedToId(attachments);

    }

    public List<Attachment> getEmailMessageAttachmentByEmailList(List<EmailMessage> emails){
      Set<String> fields = BE8_GlobalUtility.getAllCreateableFields('Attachment');
      Set<Id> emailIdSet = BE8_GlobalUtility.getIdSet('Id', emails);
      BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Attachment');
      soql.addField('Id');
      soql.addField(fields);

      soql.addCondition('ParentId', emailIdSet);
      List<Attachment> attachments = (List<Attachment>) Database.query(soql.getQueryStr());
      return attachments;
    }

    public Map<Id, List<Attachment>> getAttachmentListMapByEmailRelatedToId(List<Attachment> attachments){
      Map<Id, List<Attachment>> returnMap = null;
      if(attachments != null && !attachments.isEmpty()){
        for(Attachment attach : attachments){
          if(returnMap == null) returnMap = new Map<Id, List<Attachment>>();
          if(returnMap.containsKey(attach.ParentId)) returnMap.get(attach.ParentId).add(attach);
          else returnMap.put(attach.ParentId, new List<Attachment>{attach});
        }
      }
      return returnMap;
    }
}