global class CSE_AttachmentToTHAI implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
   public static final String CLASS_NAME = 'CSE_AttachmentToTHAI';
   List<String> mobileAppKeyList = null;

   global CSE_AttachmentToTHAI(List<String> mobileAppKeyListBuffer) {
      this.mobileAppKeyList = mobileAppKeyListBuffer;
   }

   global List<Case> start(Database.BatchableContext BC) {
      System.debug('----------------START-----------------');
      System.debug('Mobile app key list: ' + mobileAppKeyList + ': End List');
      System.debug(mobileAppKeyList);

      if (mobileAppKeyList == null) {
         System.debug('RETURN NULL');
         return null;
      } else {
         List<Case> cabinReportList = [SELECT Id, Mobile_App_Key__c FROM Case WHERE Mobile_App_Key__c IN :mobileAppKeyList AND Mobile_App_Key__c != null AND Origin = 'In-Flight' AND RecordTypeId != :BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case', BE8_GlobalConstants.CASE_RECORD_TYPE_MAINTENANCE)];
         return cabinReportList;
      }
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
      try {
         execute(scope);
         AppLogger.debug('CSE_AttachmentToTHAI', 'execute', 'success', String.valueOf(scope), null);
         //BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_INFO, 'CSE_AttachmentToTHAI', 'execute', 'success', String.valueOf(scope), null, System.currentTimeMillis());
      } catch (Exception e) {
         AppLogger.debug('CSE_AttachmentToTHAI', 'execute', 'error', String.valueOf(scope) +  ': ' + e.getMessage(), e);
         //BE8_GlobalUtility.logMessage(BE8_GlobalConstants.LEVEL_ERROR, 'CSE_AttachmentToTHAI', 'execute', e.getMessage(), String.valueOf(scope), e, System.currentTimeMillis());
      }
      Applogger.insertLogs();
   }

   public void execute(List<sObject> scope) {
      System.debug('----------------EXECUTE-----------------');
      System.debug('Mobile app key list: ' + mobileAppKeyList + ': End List');
      Map<Id, String> caseLinkMap = new Map<Id, String>();
      Integer fileCountForALink = 1;
      Integer fileCountForAAttach = 1;
      CSE_SOAPCabinReport_WS ws = new CSE_SOAPCabinReport_WS();

      //List<CSE_SOAPCabinReport_WS.CabinReportResponseModel> returnError = new List<CSE_SOAPCabinReport_WS.CabinReportResponseModel>();
      //List<BE8_applicationLogWrapper> applogList = new List<BE8_applicationLogWrapper>();
      List<CSE_SOAPCabinReport_WS.tgIDMap> tgidMapList = new List<CSE_SOAPCabinReport_WS.tgIDMap>();
      List<CSE_SOAPCabinReport_WS.CabinReportResponseModel> cabinresponseList = new List<CSE_SOAPCabinReport_WS.CabinReportResponseModel>();

      Set<Id> caseIdSet = BE8_GlobalUtility.getIdSet('Id', scope);
      List<Attachment> attachmentList = [SELECT Id, Name, BodyLength, ParentId, ContentType FROM Attachment WHERE ParentId IN :caseIdSet ORDER BY ParentId];
      if (attachmentList.size() != 0 && attachmentList != null) {
         Map<String, List<Attachment>> attachmentMapList = BE8_GlobalUtility.getSObjectListMap('ParentId', attachmentList);
         List<Case> caseUpdateList = new List<Case>();
         for (List<Attachment> attachList : attachmentMapList.values()) {
            linkModel linkmodel = new linkModel();
            for (Attachment aLink : attachList) {
               if (aLink.BodyLength > 4194304) {
                  linkmodel.caseId = alink.ParentId;
                  if (linkModel.link == null) {
                     linkModel.link = linkModel.caseId + ',link:';
                  }
                  if (fileCountForALink < attachList.size()) {
                     linkModel.link += URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + aLink.Id + ',';
                  } else {
                     linkModel.link += URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + aLink.Id;
                  }
               }
               fileCountForALink++;
            }
            if (linkModel.caseId != null && linkModel.link != null) {
               caseLinkMap.put(linkModel.caseId, linkModel.link);
            }
            System.debug('Link Model: ' + linkmodel);

            Map<String, CSE_SOAPCabinReport_WS.tgIDMap> returnMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, caseLinkMap);

            for (CSE_SOAPCabinReport_WS.tgIDMap tgid : returnMap.values()) {
               if (tgid.caseId != null) {
                  caseUpdateList.add(new Case(Id = tgid.caseId, Cabin_Report_Ref_No__c = tgid.tgID));
               }
               tgidMapList.add(tgid);
            }
            System.debug('Return Map' + returnMap);
            System.debug('Return Map Size' + returnMap.size());

            for (Attachment aAttach : attachList) {
               CSE_SOAPCabinReport_WS.CabinReportModel cabinmodel = new CSE_SOAPCabinReport_WS.CabinReportModel();
               if (aAttach.BodyLength <= 4194304) {
                  List<Attachment> attList = [SELECT Id, ParentId, Body, BodyLength FROM Attachment WHERE Id = :aAttach.Id];
                  Map<String, SObject> tempAttach = BE8_GlobalUtility.getSObjectMap(new Set<String> {'ParentId', 'Id'}, attList);
                  cabinmodel.refNo = returnMap.get(aAttach.ParentId).tgid;
                  cabinModel.remark = MB_RESTFlightService.getAttachmentFileExtension(aAttach) + ',' + aAttach.ParentId;
                  String getStr = '' + aAttach.ParentId + aAttach.Id;
                  if (fileCountForAAttach == 1) {
                     cabinmodel.file1 = EncodingUtil.base64Encode(((Attachment)tempAttach.get(getStr)).Body);
                  } else if (fileCountForAAttach == 2) {
                     cabinmodel.file2 = EncodingUtil.base64Encode(((Attachment)tempAttach.get(getStr)).Body);
                  } else if (fileCountForAAttach == 3) {
                     cabinmodel.file3 = EncodingUtil.base64Encode(((Attachment)tempAttach.get(getStr)).Body);
                  }
                  if (fileCountForAAttach < 4) {
                     CSE_SOAPCabinReport_WS.CabinReportResponseModel responseModel = ws.upsertCabinReport(cabinmodel);
                     cabinresponseList.add(responseModel);
                  }
               }
               fileCountForAAttach++;
            }
         }
         update caseUpdateList;
         CSE_SOAPCabinReport_WS.logMessage(cabinresponseList);
         CSE_SOAPCabinReport_WS.logMessage(tgidMapList);
      } else {
         List<Case> caseUpdateList = new List<Case>();
         Map<String, CSE_SOAPCabinReport_WS.tgIDMap> returnMap = CSE_SOAPCabinReport_WS.sendCabinReportToThai(caseIdSet, null);
         for (CSE_SOAPCabinReport_WS.tgIDMap tgid : returnMap.values()) {
            if (tgid.caseId != null) {
               caseUpdateList.add(new Case(Id = tgid.caseId, Cabin_Report_Ref_No__c = tgid.tgID));
            }
            tgidMapList.add(tgid);
         }
         update caseUpdateList;
         CSE_SOAPCabinReport_WS.logMessage(tgidMapList);
         System.debug('Return Map: ' + returnMap);
      }
   }

   global void finish(Database.BatchableContext BC) {
      System.debug('----------------FINISH-----------------');
   }

   public class linkModel {
      String caseId;
      String link;
   }

}