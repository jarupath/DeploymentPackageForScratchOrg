public with sharing class Case_NewEditSLDS_Controller {
    public Case myCase {get; set;}
    public Boolean isEditMode {get; set;}

    public String errorLevel {get; set;}
    public String messageName {get; set;}
    public Boolean isSF1Theme {get; set;}
    //private Id flightId;

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public Case_NewEditSLDS_Controller(ApexPages.StandardController stdController) {
        Set<String> fieldList = BE8_GlobalUtility.getFieldsFromFieldSet(getFieldSets());
        if(!Test.isRunningTest()) {
            stdController.addFields(new List<String>(fieldList));
        }

        this.myCase = (Case)stdController.getRecord();
        this.myCase.OwnerId = UserInfo.getUserId();
        String flightIdStr = ApexPages.currentPage().getParameters().get('flightId');
        if (!String.isBlank(flightIdStr)) {
            processFlightId(flightIdStr);
        } else {
            String aircraftIdStr = ApexPages.currentPage().getParameters().get('aircraftId');
            if (!String.isBlank(aircraftIdStr)) {
                this.myCase.A_C_REG_ID__c = aircraftIdStr;
            }
        }

        isEditMode = this.myCase.Id != null;

        if (isEditMode) {

        }
        String theme = UserInfo.getUiThemeDisplayed();
        if (theme == 'Theme4t') {
            isSF1Theme = true;
        } else {
            isSF1Theme = false;
        }

        //Id recordId = ApexPages.currentPage().getParameters().get('id');
        //if (recordId != null) {
        //    String objectType = recordId = BE8_GlobalUtility.getObjectNameFromRecordIdPrefix(recordId);
        //    if (objectType == 'Flight__c') {
        //        this.myCase = new Case();
        //    } else if (objectType == 'Aircraft__c') {
        //        this.myCase = new Case();
        //        //Id aircraftId = ApexPages.currentPage().getParameters().get('aircraftId');
        //        this.myCase.A_C_REG_ID__c = recordId;
        //    } else if (objectType == 'Case') {
        //        this.myCase  = (Case)stdController.getRecord();
        //    }
        //}
    }

    public void processFlightId(Id flightId) {
        Flight__c flight = [SELECT Id, AircraftId__c, Departure_STN__c FROM Flight__c WHERE Id = :flightId];
        this.myCase.A_C_REG_ID__c = flight.AircraftId__c;
        this.myCase.DEP_STN__c = flight.Departure_STN__c;
        this.myCase.Flightid__c = flight.Id;
    }

    public List<Schema.FieldSet> getFieldSets() {
        //Map<String, Schema.FieldSet> fieldSetMap = Schema.SObjectType.Case.FieldSets.getMap();
        List<String> fiedSetNames = new List<String> {'NewEdit_FlightInformation', 'NewEdit_CaseInformation', 'NewEdit_DefectInformation', 'NewEdit_Referece', 'NewEdit_Maintenance'};
        List<Schema.FieldSet> fieldSets = new List<Schema.FieldSet>();
        Map<String, Schema.FieldSet> fieldSetMap = Schema.getGlobalDescribe().get('Case').getDescribe().fieldSets.getMap();
        for (String fieldSetName : fiedSetNames) {
            fieldSets.add(fieldSetMap.get(fieldSetName));
        }
        return fieldSets;
    }

    //public String getJSONLopa() {
    //    (MB_RestResponseInfoModel.lopaInfo_model)System.JSON.deserialize(lopaFile.Body.toString(), MB_RestResponseInfoModel.lopaInfo_model.class)
    //}

    public String getJSONCaseGroupMembers() {
        if (isEditMode) {
            List<Case_Group_Member__c> caseGroupMembers = [SELECT Id, Equipment__c, Position__c, Impact__c FROM Case_Group_Member__c WHERE Caseid__c = :this.myCase.Id];
            return JSON.serialize(caseGroupMembers);
        }
        return '{}';
    }

    public String getJSONEquipmentValue() {
        List<Master_Map__c> masterMaps = [SELECT Id, Name FROM Master_Map__c WHERE Name IN ('GALLEY AREA', 'LAVATORY (TOILET)', 'PASSENGER SEAT')];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for (Master_Map__c masterMap : masterMaps) {
            gen.writeStartObject();
            gen.writeStringField('label', masterMap.Name);
            gen.writeStringField('value', masterMap.Id);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }

    public String getJSONImpactValue() {
        Schema.DescribeFieldResult fieldResult = Case_Group_Member__c.Impact__c.getDescribe();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        List<Schema.PicklistEntry> picklists = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry picklist : picklists) {
            gen.writeStartObject();
            gen.writeStringField('label', picklist.getLabel());
            gen.writeStringField('value', picklist.getValue());
            gen.writeEndObject();
        }
        gen.writeEndArray();
        return gen.getAsString();
    }

    public String getJSONCaseFieldToSave() {
        Map<String, Schema.SObjectField> allFieldMap = Case.sObjectType.getDescribe().fields.getMap();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        for (Schema.FieldSet fieldSet :  getFieldSets()) {
            for (Schema.FieldSetMember field : fieldSet.getFields()) {
                gen.writeStartObject();
                gen.writeStringField('apiname', field.getFieldPath());
                if (allFieldMap.get(field.getFieldPath()).getDescribe().getType() == Schema.DisplayType.Reference) {
                    gen.writeStringField('type', 'reference');
                } else if (allFieldMap.get(field.getFieldPath()).getDescribe().getType() == Schema.DisplayType.MultiPicklist) {
                    gen.writeStringField('type', 'multipicklist');
                } else {
                    gen.writeStringField('type', 'text');
                }
                gen.writeEndObject();
            }
        }
        gen.writeStartObject();
        gen.writeStringField('type', 'text');
        gen.writeStringField('apiname', 'id');
        gen.writeEndObject();

        gen.writeEndArray();
        return gen.getAsString();
    }

    public List<Case_Group_Member__c> getCaseGroupMembers() {
        List<Case_Group_Member__c> caseGroupMembers = new List<Case_Group_Member__c>();
        caseGroupMembers.add(new Case_Group_Member__c(Position__c = '1234'));
        return caseGroupMembers;
    }

    public void showMessage() {
        if (errorLevel == 'WARNING') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, messageName));
        } else if (errorLevel == 'ERROR') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, messageName));
        }
    }

    public PageReference validatePage() {
        System_Configuration__c systemConfig = System_Configuration__c.getOrgDefaults();
        Profile dtAdminProfile = ProfileData.getInstance().getProfileByName('DT Admin');
        Profile dtStaffProfile = ProfileData.getInstance().getProfileByName('DT Staff');
        Profile systemIntegrationProfile = ProfileData.getInstance().getProfileByName('System Integration');
        if (UserInfo.getProfileId() != dtAdminProfile.Id
                && UserInfo.getProfileId() != dtStaffProfile.Id
                && UserInfo.getProfileId() != systemIntegrationProfile.Id) {
            String urlString;
            System.debug('this.myCase.Id :' + this.myCase.Id);
            if (this.myCase.Id != null) {
                urlString = '/' + this.myCase.Id + '/e?nooverride=1';
            } else {
                urlString = '/500/e?nooverride=1';
            }

            //for (String key : ApexPages.currentPage().getParameters().keySet()) {
            //  urlString += generateURI(key);
            //}

            System.debug('getParameters ' + ApexPages.currentPage().getParameters());
            String retURL = ApexPages.currentPage().getParameters().get('retURL');
            if (String.isBlank(retURL)) {
                if (this.myCase.Id != null) {
                    urlString += '&retURL=' + this.myCase.Id;
                }
            } else {
                urlString += '&retURL=' + retURL;
            }

            urlString += generateURI('RecordType');
            urlString += generateURI('def_account_id');
            urlString += generateURI('ekp');
            urlString += generateURI('ent');
            urlString += generateURI('nooverride');
            urlString += generateURI(systemConfig.Case_Flight_Name_SFDC_ID__c);
            urlString += generateURI(systemConfig.Case_Flight_Id_SFDC_ID__c);
            urlString += generateURI(systemConfig.Case_Passenger_Name_SFDC_ID__c);
            urlString += generateURI(systemConfig.Case_Passenger_Id_SFDC_ID__c);
            urlString += generateURI(systemConfig.Case_Record_Type_ID_Ground_Service__c);
            urlString += generateURI(systemConfig.Customer_Feedback_Create__c);
            System.debug('urlString :' + urlString);
            PageReference returnPage = new PageReference(urlString);
            returnPage.setRedirect(true);

            PageReference testPage = new PageReference('/500/e?nooverride=1');
            testPage.setRedirect(true);
            return returnPage;
        }
        //UserInfo.getProfileId();
        //return null;


        //if (true) { //isSF1Theme
        //  Map<String, String> mapParam = ApexPages.currentPage().getParameters();
        //  PageReference salesforce1Page = new PageReference('/apex/Case_NewEditSLDS_Page');
        //  for (String key : mapParam.keySet()) {
        //      salesforce1Page.getParameters().put(key, mapParam.get(key));
        //  }
        //  System.debug('SW Debug : Enter Redirect to Salesforce1 Page :' + salesforce1Page);
        //  return salesforce1Page;
        //}
        //UserInfo.getProfileId();
        return null;
    }

    public String generateURI(String parameter) {
        String uri = '';
        String value = ApexPages.currentPage().getParameters().get(parameter);
        if (!String.isBlank(value)) {
            uri = '&' + parameter + '=' + value;
        }
        return uri;
    }
}