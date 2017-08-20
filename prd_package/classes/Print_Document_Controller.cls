public class Print_Document_Controller {
    //public String documentName {get ; set;}
    public String pdfName = '';
    public String docName = '';
    public Case thisCase {get; set;}
    //public Case dummyField {get; set;}
    public User caseOwner {get; set;}
    public Id caseId {get; set;}
    public Boolean hasBody {get; set;}
    public Id letterBodyId {public get; public set;}
    public Map<String, Object> viewMap {get; set;}
    public Map<Id, Case_Group_Member__c> caseGroupMemberMap;
    public String selectedCaseGroupMemberId {get; set;}
    public String selectedOldVersion {get; set;}
    public String selectedCompensationTool {get; set;}
    public Boolean isTGXXX {get; set;}

    public List<CustomCompensation> customCompensations {get; set;}

    public class CustomCompensation {
        public Boolean isSelected {get; set;}
        public String compensationType {get; set;}
        public Decimal amountPerPassenger {get; set;}
        public Compensation__c compensation {get; set;}
        public Integer rowNo {get; set;}
    }

    public String selectedAccountNumberPartial {get; set;}
    public String selectedAccountNumber {
        get {
            return selectedAccountNumber;
        }
        set {
            selectedAccountNumber = value;
            if (!String.isBlank(selectedAccountNumber) && selectedAccountNumber.length() >= 6) {
                selectedAccountNumberPartial = selectedAccountNumber.left(6);
            } else {
                selectedAccountNumberPartial = selectedAccountNumber;
            }
            System.debug('selectedAccountNumber :' + selectedAccountNumber);
        }
    }

    public String selectedAccountCenterPartial {get; set;}
    public String selectedAccountCenter {
        get {
            return selectedAccountCenter;
        }
        set {
            selectedAccountCenter = value;
            if (!String.isBlank(selectedAccountCenter) && selectedAccountCenter.length() >= 7) {
                selectedAccountCenterPartial = selectedAccountCenter.left(7);
            } else {
                selectedAccountCenterPartial = selectedAccountCenter;
            }
            System.debug('selectedAccountCenter :' + selectedAccountCenter);
        }
    }

    public String runningNumber {get; set;}
    public String currencyWord {get; set;}
    public String subCurrencyWord {get; set;}
    //public Boolean allowPrint = false;

    public String ToQueryString(String key, String value) {
        String queryString = key + '=';
        if (!String.isBlank(value)) {
            queryString += EncodingUtil.urlEncode(value, 'UTF-8');
        }
        return queryString;
    }

    public String getPreviewURLForPrint() {
        return getPreviewURL(true);
    }

    public String getPreviewURLForDownload() {
        isDownload = true;
        return getPreviewURL(false);
    }

    public String getPreviewURL() {
        return getPreviewURL(false);
    }

    public String getPreviewURL(Boolean allowPrint) {
        String url = '/apex/' + FilterTemplate + '?';
        url += ToQueryString('id', CaseId);
        
        String commmentInEncoded = comment;
        if(String.isNotBlank(commmentInEncoded)) {
            commmentInEncoded = commmentInEncoded.replace('\n', '<br/>');
        }
        //commmentInEncoded = commmentInEncoded.replace('<br/>', '\n');
        if(!customCompensations.isEmpty()) {
            Set<Id> compensationIds = new Set<Id>();
            for(CustomCompensation eachCustomCompensation : customCompensations) {
                if(!eachCustomCompensation.isSelected) continue;
                compensationIds.add(eachCustomCompensation.compensation.Id);
                selectedAccountNumber = eachCustomCompensation.compensation.Compensation_Account_Number__c;
                selectedAccountCenter = eachCustomCompensation.compensation.Compensation_Account_Center__c;
            }
            url += '&' + ToQueryString('compensationIds', String.join(new List<Id>(compensationIds), ','));
        }

        url += '&' + ToQueryString('comment', commmentInEncoded);
        url += '&' + ToQueryString('referenceTo', referenceTo);
        url += '&' + ToQueryString('selectedCaseGroupMemberId', selectedCaseGroupMemberId);
        url += '&' + ToQueryString('selectedAccountNumberPartial', selectedAccountNumberPartial);
        url += '&' + ToQueryString('selectedAccountCenterPartial', selectedAccountCenterPartial);
        url += '&' + ToQueryString('selectedAccountNumber', selectedAccountNumber);
        url += '&' + ToQueryString('selectedAccountCenter', selectedAccountCenter);
        url += '&' + ToQueryString('passengerName', passengerName);
        url += '&' + ToQueryString('passengerEmail', passengerEmail);
        url += '&' + ToQueryString('passengerStreet1', passengerStreet1);
        url += '&' + ToQueryString('passengerStreet2', passengerStreet2);
        url += '&' + ToQueryString('passengerCity', passengerCity);
        url += '&' + ToQueryString('passengerCountry', passengerCountry);
        url += '&' + ToQueryString('passengerPostalCode', passengerPostalCode);
        url += '&' + ToQueryString('comment1', comment1);
        url += '&' + ToQueryString('comment2', comment2);
        url += '&' + ToQueryString('comment3', comment3);
        url += '&' + ToQueryString('comment4', comment4);
        url += '&' + ToQueryString('comment5', comment5);
        url += '&' + ToQueryString('isCheque', String.valueOf(isCheque));
        url += '&' + ToQueryString('isCash', String.valueOf(isCash));
        url += '&' + ToQueryString('subject', subject);
        url += '&' + ToQueryString('attachName', attachName);
        url += '&' + ToQueryString('travelType', travelType);
        url += '&' + ToQueryString('authorizedPhone', authorizedPhone);
        url += '&' + ToQueryString('authorizedFax', authorizedFax);
        url += '&' + ToQueryString('tgLetter', tgLetter);
        url += '&' + ToQueryString('needTGDoc', String.valueOf(needTGDoc));
        url += '&' + ToQueryString('isDownload', String.valueOf(isDownload));
        url += '&' + ToQueryString('displayTHB', String.valueOf(displayTHB));
        url += '&' + ToQueryString('currencyWord', String.valueOf(currencyWord));
        url += '&' + ToQueryString('subCurrencyWord', String.valueOf(subCurrencyWord));
        url += '&' + ToQueryString('issueDate', String.valueOf(thisCase.Issue_Date__c));
        url += '&' + ToQueryString('expiryDate', String.valueOf(thisCase.Expiry_Date__c));
        url += '&' + ToQueryString('pdfName', pdfName);
        url += '&' + ToQueryString('docName', docName);

        
        if (allowPrint || isDownload) {
            url += '&' + ToQueryString('runningNumber', runningNumber);
        } else {
            url += '&' + ToQueryString('runningNumber', 'XXXXXXXXXX');
        }

        if (!allowPrint) {
            url += '#toolbar=0&navpanes=0&scrollbar=0';
        }
        isDownload = false;
        return url;
    }

    public Boolean isNewVersion {get; set;}
    public Boolean isReplaceOldVersion {get; set;}
    public Boolean needTGDoc {get; set;}
    public String tgLetter {get; set;}
    public String authorizedPhone {get; set;}
    public String authorizedFax {get; set;}
    public String attachName {get; set;}
    public String comment {get; set;}
    public String subject {get; set;}
    public String travelType {get; set;}
    public Boolean isCheque {get; set;}
    public Boolean isCash {get; set;}
    public Boolean displayTHB {get; set;}
    public String comment1 {get; set;}
    public String comment2 {get; set;}
    public String comment3 {get; set;}
    public String comment4 {get; set;}
    public String comment5 {get; set;}
    public String referenceTo {get; set;}
    public String passengerName {get; set;}
    public String passengerEmail {get; set;}
    public String passengerStreet1 {get; set;}
    public String passengerStreet2 {get; set;}
    public String passengerCity {get; set;}
    public String passengerCountry {get; set;}
    public String passengerPostalCode {get; set;}
    public String templateBody {get; set;}
    public Boolean needToOpenAttachment {get; set;}
    public Boolean needToDownloadAttachment {get; set;}

    public String targetCurrency;
    //public String templateBody {get{
    //        System.debug('getTemplateBody');
    //        if (!String.isBlank(templateBody) && templateBody.length() > 0) {
    //            if (templateBody.left(1) == '|') {
    //                templateBody = templateBody.removeStart('|');
    //            }

    //            templateBody = templateBody.replace('<br>', '\n');
    //            templateBody = templateBody.replace('<br/>', '\n');
    //            templateBody = fillinFieldTokens(templateBody);
    //        }
    //        return templateBody;
    //    } set;
    //}

    public Integer templateBodyLineLength {get; set;}

    public final String LANGUAGE_ENGLISH = 'EN';
    public final String LANGUAGE_THAI = 'TH';
    public final String LETTER_EN_PAGE_NAME = 'LetterEN';
    public final String LETTER_TH_1_PAGE_NAME = 'LetterTH1';
    public final String LETTER_TH_2_PAGE_NAME = 'LetterTH2';
    public final String LCD_PAGE_NAME = 'LCD';
    public final String PV_PAGE_NAME = 'PV';
    public final String UPGRADE_CONFIRM_PAGE_NAME = 'UpgradeConfirmation';
    public final String UPGRADE_STANDBY_PAGE_NAME = 'UpgradeStandby';

    public Boolean hasUpgradeDocumentPermission;
    public String FilterTemplate {public get; public set;}
    public Boolean isDownload {get; set;}
    //public Map<Id, List<Attachment>> attachmentMapByCaseGroupMemberId = new Map<Id, List<Attachment>>();
    public Map<Id, Attachment> attchmentMap = new Map<Id, Attachment>();

    public Print_Document_Controller(ApexPages.StandardController controller) {
        runningNumber = 'XXXXXXXXXX';
        comment1 = 'customer@thaiairways.com'; comment2 = 'COMMENT2'; comment3 = 'COMMENT3'; comment4 = 'COMMENT4'; comment5 = 'COMMENT5';
        initDefaultValue();

        thisCase = [SELECT Id, Flightid__r.Origin__c, Flightid__r.Destination__c, Flight_Number_Manual__c, Flight_Date_Manual__c, Flight_From_Manual__c, Flight_To_Manual__c, OwnerId, Latest_Document__c, Latest_Template__c, Subject, Passengerid__c, Passengerid__r.Name, Description, Letter_Body__c, Passenger_Ticket_Number__c, Baggage_Check_Number__c, Excess_Bag_Ticket_Number__c, LCD_Detail__c, Account_Debited__c, CreatedDate, ClosedDate, Case_Number_Custom_F__c, Passengerid__r.PNR__c, FlightId__r.Name, FlightId__r.Sector__c, Authorize_Signature__c, Position__c, Department__c, Owner_Station__c, Passenger_Email__c, Passengerid__r.AccountId__r.Mailling_Address__c, PassengerId__r.Sector__c, FlightId__r.Flight_Date_LT__c, Upgrade_StandBy_Attachment_Amount__c, Upgrade_Confirmed_Attachment_Amount__c, LetterEN_Attachment_Amount__c, LetterTH1_Attachment_Amount__c, LetterTH2_Attachment_Amount__c, LCD_Attachment_Amount__c, PV_Attachment_Amount__c, Expiry_Date__c, Issue_Date__c, (SELECT Id, Currency__c, Compensation_Account_Number__c, Compensation_Account_Center__c, Compensation_Tools__c, Total__c, Is_Individual__c, Case_Group_Member__c FROM Compensations__r WHERE Status__c = 'Approved') FROM Case WHERE Id = : controller.getId() LIMIT 1];
        isTGXXX = thisCase.Flightid__r.Name == BE8_GlobalConstants.DUMMY_FLIGHT_NAME;
        thisCase.Issue_Date__c = System.today();
        thisCase.Expiry_Date__c = System.today().addYears(1);

        caseGroupMemberMap = new Map<Id, Case_Group_Member__c>([SELECT Id, Name, Passengerid__c, Passengerid__r.Name FROM Case_Group_Member__c WHERE Caseid__c = :thisCase.Id]);

        if (String.isBlank(selectedCaseGroupMemberId) && !caseGroupMemberMap.isEmpty()) {
            for (Case_Group_Member__c eachCGM : caseGroupMemberMap.values()) {
                if (eachCGM.Passengerid__c != null && eachCGM.Passengerid__c == thisCase.Passengerid__c) {
                    selectedCaseGroupMemberId = eachCGM.Id;
                }
            }
        }

        targetCurrency = 'THB';
        for (Compensation__c eachCompensation : thisCase.Compensations__r) {
            if (String.isNotBlank(eachCompensation.Currency__c)) {
                targetCurrency = eachCompensation.Currency__c;
            }
        }

        List<Currency_Unit__mdt> units = [SELECT Id, Currency__c, Sub_Currency__c, DeveloperName FROM Currency_Unit__mdt WHERE DeveloperName = :targetCurrency];
        if (units.isEmpty()) {
            currencyWord = '[CURRENCY]';
            subCurrencyWord = '[SUBCURRENCY]';
        } else {
            currencyWord = units.get(0).Currency__c;
            subCurrencyWord = units.get(0).Sub_Currency__c;
        }

        //retrieveAttachment();
        String ownerType = BE8_GlobalUtility.getObjectNameFromRecordIdPrefix(thisCase.OwnerId);
        if (ownerType == 'User') {
            User caseOwner = [SELECT Id, Phone, Fax, Name, Name_TH__c, Authorized_Position_EN__c, Authorized_Position_TH__c, Authorized_Department_EN__c, Alias, Authorized_Department_TH__c FROM User WHERE Id = :thisCase.OwnerId];
            authorizedPhone = caseOwner.Phone;
            authorizedFax = caseOwner.Fax;
        }

        if (!String.isBlank(thisCase.Latest_Document__c)) {
            FilterTemplate = thisCase.Latest_Document__c;
        }
        if (!String.isBlank(thisCase.Latest_Template__c)) {
            letterBodyId = thisCase.Latest_Template__c;
        }
        if (!String.isBlank(thisCase.Letter_Body__c)) {
            templateBody = parseTemplateBodyForDisplay(thisCase.Letter_Body__c);
        }

        setupValueToParseTemplateBody(thisCase, caseOwner);
        subject = thisCase.Subject;
        if (thisCase.Passengerid__c != null) {
            passengerName = thisCase.Passengerid__r.Name;
        }
        caseId = Apexpages.Currentpage().getParameters().get('id');
        System.debug('SJ :' + caseId + Apexpages.currentPage().getParameters());

        Config_Parameter__mdt upgradeDocumentParameter = [SELECT DeveloperName, Value__c FROM Config_Parameter__mdt WHERE DeveloperName = 'Upgrade_Document_Profile_Permission'];

        User currentUser = [SELECT Id, Profile.Name FROM User WHERE User.Id = :UserInfo.getUserId()];
        Set<String> upgradeDocumentPermissionSet = new Set<String>(upgradeDocumentParameter.Value__c.split(','));
        hasUpgradeDocumentPermission = false;
        if (upgradeDocumentPermissionSet.contains(currentUser.Profile.Name)) {
            hasUpgradeDocumentPermission = true;
        }

        //documentName = caseId;
        setDefaultTemplateBody();
        isNewVersion = true;
        isReplaceOldVersion = false;
        needToOpenAttachment = false;

        if(String.isBlank(selectedCompensationTool)) {
            selectedCompensationTool = 'Cash';
        }
        changeCompensationTool();
    }

    //public Map<Id, List<Attachment>> retrieveAttachment() {
    //    attchmentMap = new Map<Id, Attachment>([SELECT Id, Name, Description FROM Attachment WHERE ParentId = :thisCase.Id]);
    //    Map<Id, List<Attachment>> attachmentMapByCaseGroupMemberId = new Map<Id, List<Attachment>>();
    //    for (Attachment attachment : attchmentMap.values()) {
    //        Boolean isCaseGroupMemberAttachment = false;
    //        for (Case_Group_Member__c caseGroupMember : caseGroupMemberMap.values()) {
    //            if (attachment.Description != null && attachment.Description.contains(caseGroupMember.Id)) {
    //                isCaseGroupMemberAttachment = true;
    //                if (!attachmentMapByCaseGroupMemberId.containsKey(caseGroupMember.Id)) {
    //                    attachmentMapByCaseGroupMemberId.put(caseGroupMember.Id, new List<Attachment>());
    //                }
    //                attachmentMapByCaseGroupMemberId.get(caseGroupMember.Id).add(attachment);
    //                break;
    //            }
    //        }

    //        if (!isCaseGroupMemberAttachment) {
    //            if (!attachmentMapByCaseGroupMemberId.containsKey(thisCase.Id)) {
    //                attachmentMapByCaseGroupMemberId.put(thisCase.Id, new List<Attachment>());
    //            }
    //            attachmentMapByCaseGroupMemberId.get(thisCase.Id).add(attachment);
    //        }
    //    }

    //    return attachmentMapByCaseGroupMemberId;
    //}

    public void setupValueToParseTemplateBody(Case caseObj, User caseOwner) {
        Boolean isENDoc = false;
        Boolean isTHDoc = false;
        if (!String.isBlank(FilterTemplate)) {
            isENDoc = FilterTemplate.toUpperCase().contains('EN');
            isTHDoc = FilterTemplate.toUpperCase().contains('TH');
        } else {
            isENDoc = true;
        }

        addFieldValueMap('passengerName', caseObj.Passengerid__r.Name);
        if (caseOwner != null) addFieldValueMap('ownerRole', caseOwner.Alias);
        addFieldValueMap('dateIssue', String.valueOf(caseObj.CreatedDate));
        addFieldValueMap('dateExpire', String.valueOf(caseObj.Expiry_Date__c));
        addFieldValueMap('caseNumber', caseObj.Case_Number_Custom_F__c);
        if (caseObj.Passengerid__c != null) {
            addFieldValueMap('ticketNumber', caseObj.Passengerid__r.PNR__c);
            addFieldValueMap('sector', caseObj.PassengerId__r.Sector__c);
            if (caseObj.Passengerid__r.AccountId__c != null) {
                addFieldValueMap('passengerAddress', caseObj.Passengerid__r.AccountId__r.Mailling_Address__c);
            }
        }
        if (caseObj.FlightId__c != null) {
            addFieldValueMap('flightName', caseObj.FlightId__r.Name);
            addFieldValueMap('flightSector', caseObj.FlightId__r.Sector__c);
            String[] flightStrs = caseObj.FlightId__r.Name.split('/');
            addFieldValueMap('flightonly', flightStrs.size() > 0 ? flightStrs[0].trim() : '');

            String[] fDates = caseObj.FlightId__r.Flight_Date_LT__c != null ? caseObj.FlightId__r.Flight_Date_LT__c.split('-') : null;
            addFieldValueMap('flightdate', fDates != null && fDates.size() == 3 ? fDates[2] + '/' + fDates[1] + '/' + fDates[0] : '');
        }

        String authorizedBy = '';
        if (!String.isBlank(caseObj.Authorize_Signature__c)) {
            authorizedBy = caseObj.Authorize_Signature__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                authorizedBy = caseOwner.Name;
            } else if (isTHDoc) {
                authorizedBy = caseOwner.Name_TH__c;
            }
        }
        addFieldValueMap('authorizedBy', authorizedBy);

        String authorizedPosition = '';
        if (!String.isBlank(caseObj.Position__c)) {
            authorizedPosition = caseObj.Position__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                authorizedPosition = caseOwner.Authorized_Position_EN__c;
            } else if (isTHDoc) {
                authorizedPosition = caseOwner.Authorized_Position_TH__c;
            }
        }
        addFieldValueMap('authorizedPosition', authorizedPosition);

        String authorizedDepartment = '';
        if (!String.isBlank(caseObj.Department__c)) {
            authorizedDepartment = caseObj.Department__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                authorizedDepartment = caseOwner.Authorized_Department_EN__c;
            } else if (isTHDoc) {
                authorizedDepartment = caseOwner.Authorized_Department_TH__c;
            }
        }
        addFieldValueMap('authorizedDepartment', authorizedDepartment);

        addFieldValueMap('flightSector', caseObj.FlightId__r.Sector__c);
        addFieldValueMap('ownerStation', caseObj.Owner_Station__c);
        addFieldValueMap('passengerEmail', caseObj.Passenger_Email__c);
    }

    public void initDefaultValue() {
        travelType = 'round trip';
        FilterTemplate = 'LetterEN';
        needTGDoc = true;
        hasBody = true;
        isDownload = false;
        displayTHB = false;
    }

    public String fillinFieldTokens(String str) {
        if (String.isBlank(str)) {
            return '';
        }

        if (str.indexOf('@:') >= 0 && str.indexOf('@:') < str.length() && str.indexOf(':@') >= 0 && str.indexOf(':@') + 2 < str.length() ) {
            String stringToReplace = str.substring(str.indexOf('@:'), str.indexOf(':@') + 2);
            str = str.replaceAll(stringToReplace, String.valueOf(getFieldValue(stringToReplace.replace('@:view.', '').replace(':@', ''))));
            return fillinFieldTokens(str);

        } else {
            return str;
        }
    }

    public void addFieldValueMap(String fieldName, String val) {
        if (viewMap == null) {
            viewMap = new Map<String, Object>();
        }
        if (!String.isBlank(val)) {
            viewMap.put(fieldName, val);
        }
    }

    public Object getFieldValue(String fieldName) {

        if (viewMap != null && viewMap.containsKey(fieldName)) {
            //return viewMap.get(fieldName)!=null?viewMap.get(fieldName):fieldName.toUpperCase();
            return viewMap.get(fieldName) != null ? viewMap.get(fieldName) : fieldName;
        } else {
            return fieldName;
        }
    }

    public List<SelectOption> getCompensationTools() {
        Set<String> compensationTools = new Set<String>();
        for(Compensation__c eachCompensation : thisCase.Compensations__r) {
            if(eachCompensation.Is_Individual__c) {
                if(String.isBlank(selectedCaseGroupMemberId) || eachCompensation.Case_Group_Member__c != selectedCaseGroupMemberId) {
                    continue;
                }
            }
            compensationTools.add(eachCompensation.Compensation_Tools__c);
        }


        List<SelectOption> options = new List<SelectOption>();
        for(String compensationTool : compensationTools) {
            if(FilterTemplate == 'PV' && compensationTool != 'Cash' && compensationTool != 'EMD') {

            } else {
                if(!compensationTools.contains(selectedCompensationTool)) {
                    selectedCompensationTool = compensationTool;
                    refreshCustomCompensations();
                }

                options.add(new SelectOption(compensationTool, compensationTool));
            }
        }
        return options;
    }

    public List<SelectOption> getOldVersionSelectOptions() {
        attchmentMap = new Map<Id, Attachment>([SELECT Id, Name, Description FROM Attachment WHERE ParentId = :thisCase.Id ORDER BY CreatedDate DESC]);
        List<SelectOption> options = new List<SelectOption>();
        for (Attachment eachAttachment : attchmentMap.values()) {
            if (!String.isBlank(eachAttachment.Description)) {
                if (!eachAttachment.Description.contains(filterTemplate)) {
                    continue;
                }
                if (FilterTemplate == 'PV') {
                    if (!String.isBlank(selectedAccountCenter) && !eachAttachment.Description.contains(selectedAccountCenter)) {
                        continue;
                    }
                    if (!String.isBlank(selectedAccountNumber) && !eachAttachment.Description.contains(selectedAccountNumber)) {
                        continue;
                    }
                } else {
                    if (!String.isBlank(selectedCaseGroupMemberId)
                            && !eachAttachment.Description.contains(selectedCaseGroupMemberId)) {
                        continue;
                    }
                }
            }
            options.add(new SelectOption(eachAttachment.Id, eachAttachment.Name));
        }
        return options;

    }

    public List<SelectOption> getAccountCenterSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> accountCenterSet = new Set<String>();

        Schema.DescribeFieldResult fieldResult = Compensation__c.Compensation_Account_Center__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String, String> labelMapByValue = new Map<String, String>();
        for (Schema.PicklistEntry f : ple) {
            labelMapByValue.put(f.getValue(), f.getLabel());
        }

        for (Compensation__c compensation : thisCase.Compensations__r) {
            if (String.isBlank(compensation.Compensation_Account_Center__c)) continue;

            if (accountCenterSet.contains(compensation.Compensation_Account_Center__c)) continue;
            else accountCenterSet.add(compensation.Compensation_Account_Center__c);

            if (String.isBlank(selectedAccountCenter)) {
                selectedAccountCenter = compensation.Compensation_Account_Center__c;
            }
            options.add(new SelectOption(compensation.Compensation_Account_Center__c, labelMapByValue.get(compensation.Compensation_Account_Center__c)));
        }
        return options;
    }

    public List<SelectOption> getAccountNumberSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Set<String> accountNumberSet = new Set<String>();

        Schema.DescribeFieldResult fieldResult = Compensation__c.Compensation_Account_Number__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        Map<String, String> labelMapByValue = new Map<String, String>();
        for (Schema.PicklistEntry f : ple) {
            labelMapByValue.put(f.getValue(), f.getLabel());
        }

        for (Compensation__c compensation : thisCase.Compensations__r) {

            if (String.isBlank(compensation.Compensation_Account_Number__c)) continue;

            if (accountNumberSet.contains(compensation.Compensation_Account_Number__c)) continue;
            else accountNumberSet.add(compensation.Compensation_Account_Number__c);

            if (String.isBlank(selectedAccountNumber)) {
                selectedAccountNumber = compensation.Compensation_Account_Number__c;
            }
            options.add(new SelectOption(compensation.Compensation_Account_Number__c, labelMapByValue.get(compensation.Compensation_Account_Number__c)));
        }
        return options;
    }

    public List<SelectOption> getCaseGroupMemberSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('', ''));
        for (Case_Group_Member__c caseGroupMember : caseGroupMemberMap.values()) {
            if (caseGroupMember.Passengerid__c != null) {
                if (String.isBlank(selectedCaseGroupMemberId)
                        && caseGroupMember.Passengerid__c == thisCase.Passengerid__c) {
                    selectedCaseGroupMemberId = caseGroupMember.Id;
                }
                options.add(new SelectOption(caseGroupMember.Id, caseGroupMember.Passengerid__r.Name));
            }
        }
        return options;
    }

    public String parseTemplateBodyForDisplay(String body) {
        if (!String.isBlank(body) && body.length() > 0) {
            if (body.left(1) == '|') {
                body = body.removeStart('|');
            }
            body = body.replace('<br>', '\n');
            body = body.replace('<br/>', '\n');
            body = fillinFieldTokens(body);
        }
        return body;
    }

    public void setDefaultTemplateBody() {
        tgLetter = '... / .....';
        templateBodyLineLength = 10;
        List<Letter_Master__c> letterMasterList = getLetterMasterList(FilterTemplate);
        if (!letterMasterList.isEmpty()) {
            if (String.isBlank(letterBodyId)) {
                letterBodyId = letterMasterList.get(0).Id;
            }

            if (String.isBlank(templateBody)) {
                templateBody = parseTemplateBodyForDisplay(letterMasterList.get(0).Description__c);
            }
        }
    }

    public List<SelectOption> getTravelTypeList() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('one - way', 'one - way'));
        options.add(new SelectOption('round trip', 'round trip'));
        return options;
    }

    public List<SelectOption> getTemplatelist() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(LETTER_EN_PAGE_NAME, 'Letter EN'));
        options.add(new SelectOption(LETTER_TH_1_PAGE_NAME, 'Letter TH 1'));
        options.add(new SelectOption(LETTER_TH_2_PAGE_NAME, 'Letter TH 2'));
        options.add(new SelectOption(LCD_PAGE_NAME, 'LCD'));
        options.add(new SelectOption(PV_PAGE_NAME, 'PV'));

        if (hasUpgradeDocumentPermission) {
            options.add(new SelectOption(UPGRADE_CONFIRM_PAGE_NAME, 'Upgrade confirmed'));
            options.add(new SelectOption(UPGRADE_STANDBY_PAGE_NAME, 'Upgrade stand - by'));
        }
        return options;
    }

    public void refreshCustomCompensations() {
        customCompensations = new List<CustomCompensation>();
        if(String.isNotBlank(selectedCompensationTool)) {
            List<Compensation__c> compensations = [SELECT Id, Name, Amount__c, Currency__c, ROE__c, Compensation_Tools__c, Is_Individual__c, Case_Group_Member__c, Compensation_Account_Center__c, Compensation_Account_Number__c, Compensation_Type__c, Total__c FROM Compensation__c WHERE Compensation_Tools__c = :selectedCompensationTool AND Status__c = 'Approved' AND Caseid__c = :thisCase.Id];

            Integer currentRowNo = 1;
            targetCurrency = 'THB';
            for(Compensation__c eachCompensation : compensations) {
                CustomCompensation eachCustomCompensation = new CustomCompensation();

                if(eachCompensation.Is_Individual__c) {
                    if(eachCompensation.Case_Group_Member__c != selectedCaseGroupMemberId) {
                        continue;
                    }
                    eachCustomCompensation.compensationType = 'Individual';
                } else {
                    eachCustomCompensation.compensationType = 'Mass';
                }
                eachCustomCompensation.rowNo = currentRowNo;
                eachCustomCompensation.compensation = eachCompensation;
                eachCustomCompensation.isSelected = false;
                eachCustomCompensation.amountPerPassenger = Compensation_Service.getAmountPerPassenger(eachCompensation, false);
                customCompensations.add(eachCustomCompensation);
                currentRowNo++;

                if(String.isNotBlank(eachCompensation.Currency__c)) {
                    targetCurrency = eachCompensation.Currency__c;
                }
            }
        }
        changeDisplayTHB();
    }

    public PageReference changeCompensationTool() {
        refreshCustomCompensations();
        return null;
    }

    public PageReference changeDocument() {
        hasBody = FilterTemplate == LETTER_EN_PAGE_NAME || FilterTemplate == LETTER_TH_2_PAGE_NAME || FilterTemplate == LETTER_TH_1_PAGE_NAME;
        letterBodyId = null;
        templateBody = '';
        setDefaultTemplateBody();
        //updateBodyWithParam(false);
        return null;
    }

    public PageReference changeTemplate() {
        Letter_Master__c letterMaster = [SELECT Id, Description__c FROM Letter_Master__c WHERE Id = :letterBodyId LIMIT 1];
        templateBody = parseTemplateBodyForDisplay(letterMaster.Description__c);
        //updateBodyWithParam(false);
        //templateBodyLineLength = templateBody.countMatches('\n') + 1;
        return null;
    }

    public PageReference changePassenger() {
        System.debug('changePassenger : ' + selectedCaseGroupMemberId);
        if (!String.isBlank(selectedCaseGroupMemberId) && caseGroupMemberMap.containsKey(selectedCaseGroupMemberId)) {
            Case_Group_Member__c selectedCaseGroupMember = caseGroupMemberMap.get(selectedCaseGroupMemberId);
            passengerName = selectedCaseGroupMember.Passengerid__r.Name;

            //[SELECT Id, Total_THB__c, Compensation_Account_Center__c, Compensation_Account_Number__c, Compensation_Tools__c, ROE__c, Amount__c, Currency__c, Is_Individual__c, Case_Group_Member__c FROM Compensations__c WHERE Status__c = 'Approved' WHERE ];
            //customCompensations.add(ANY element)

        } else {
            passengerName = '';
        }

        getCompensationTools();
        changeCompensationTool();
        return null;
    }

    public PageReference changeDisplayTHB() {
        if (displayTHB) {
            List<Currency_Unit__mdt> units = [SELECT Id, Currency__c, Sub_Currency__c, DeveloperName FROM Currency_Unit__mdt WHERE DeveloperName = 'THB'];
            if (units.isEmpty()) {
                currencyWord = 'BAHT';
                subCurrencyWord = 'SATANG';
            } else {
                currencyWord = units.get(0).Currency__c;
                subCurrencyWord = units.get(0).Sub_Currency__c;
            }
        } else {
            List<Currency_Unit__mdt> units = [SELECT Id, Currency__c, Sub_Currency__c, DeveloperName FROM Currency_Unit__mdt WHERE DeveloperName = :targetCurrency];
            if (units.isEmpty()) {
                currencyWord = '[CURRENCY]';
                subCurrencyWord = '[SUBCURRENCY]';
            } else {
                currencyWord = units.get(0).Currency__c;
                subCurrencyWord = units.get(0).Sub_Currency__c;
            }
        }
        return null;

    }

    public List<Letter_Master__c> getLetterMasterList(String filterTemplate) {
        return [SELECT Id, Name, Letter_Language__c, Description__c FROM Letter_Master__c WHERE Letter_Language__c = :getLanguageFromPageName(FilterTemplate)];
    }

    public List<SelectOption> getLetterBodyList() {
        List<Letter_Master__c> letterMasterList = getLetterMasterList(FilterTemplate);

        List<SelectOption> options = new List<SelectOption>();
        for (Letter_Master__c each : letterMasterList) {
            options.add(new SelectOption(each.Id, each.Name));
        }
        return options;
    }

    public PageReference preview() {
        if (hasBody) {
            //thisCase = new Case(Id = caseId, Letter_Language__c = getLanguageFromPageName(FilterTemplate));
            thisCase.Letter_Language__c = getLanguageFromPageName(FilterTemplate);
            //thisCase.Id = caseId;
            List<Letter_Master__c> letterMasters = [SELECT Id, Description__c FROM Letter_Master__c WHERE Id = :letterBodyId];
            if (!letterMasters.isEmpty()) {
                Letter_Master__c letterMaster = letterMasters.get(0);
                thisCase.Letter_Body__c = letterMaster.Description__c;
            }
        }
        thisCase.Latest_Document__c = FilterTemplate;
        thisCase.Latest_Template__c = letterBodyId;
        update thisCase;
        return null;
    }

    //public PageReference updateBodyWithDownload() {
    //    isDownload = true;
    //    attachPDF();
    //    return null;
    //}

    public PageReference updateBody() {
        return updateBodyWithParam(false);
    }

    public PageReference updateBodyBeforeAttach() {
        return updateBodyWithParam(true);
    }

    public String getRunningNumber() {
        String runningNum;
        //if (isNewVersion) {
        Map<String, Integer> runningNumberMap = SFDCExternalKeyHandler.reservedExternalKey('Case_Group_Member__c', new Set<String> {FilterTemplate}, 1);
        runningNum = ('0000000000' + runningNumberMap.get(FilterTemplate)).right(10);
        //} else {
        //runningNum = selectedOldVersion;
        //}
        return runningNum;
    }

    public String generateRunningNumber() {
        if (!isNewVersion && !String.isBlank(selectedOldVersion)) {
            Attachment selectedAttach = attchmentMap.get(selectedOldVersion);
            Integer lastIndex = selectedAttach.Name.lastIndexOf('_');
            runningNumber = selectedAttach.Name.substring(lastIndex + 1, selectedAttach.Name.length() - 4);
            delete selectedAttach;
            updateBodyWithParam(false);
        } else  {
            runningNumber = getRunningNumber();
            updateBodyWithParam(true);
        }
        return runningNumber;
    }

    public PageReference attachPDF() {
        pdfName = '';
        String attachmentDescription = '';

        if (filterTemplate == 'PV') {
            attachmentDescription = selectedAccountCenterPartial + '_' + selectedAccountNumberPartial;
        } else if (!String.isBlank(selectedCaseGroupMemberId)) {
            attachmentDescription = selectedCaseGroupMemberId;
        }

        runningNumber = generateRunningNumber();
        //pdfName = filterTemplate + '_' + runningNumber;
        String bodyPdfName = '';
        if (filterTemplate == 'PV') {
            if (!String.isBlank(selectedAccountCenterPartial)) {
                bodyPdfName += selectedAccountCenterPartial;
            }
            if (!String.isBlank(selectedAccountNumberPartial)) {
                if(String.isBlank(bodyPdfName)) {
                    bodyPdfName += selectedAccountNumberPartial;
                } else {
                    bodyPdfName += '_' + selectedAccountNumberPartial;
                }
            }
        } else {
            if (selectedCaseGroupMemberId != null) {
                Case_Group_Member__c selectedCaseGroupMember = caseGroupMemberMap.get(selectedCaseGroupMemberId);
                if (selectedCaseGroupMember.Passengerid__c != null) {
                    bodyPdfName = selectedCaseGroupMember.Passengerid__r.Name;
                }
            }
        }
        pdfName = filterTemplate + '_' + bodyPdfName + '_' + runningNumber;
        docName = pdfName + '.doc';
        pdfName += '.pdf';
        attachmentDescription = attachmentDescription + '_' + filterTemplate;
        Attachment att = new Attachment(Name = pdfName, Description = attachmentDescription);
        PageReference pdfPage = new PageReference(getPreviewURL(true));

        if (!Test.isRunningTest()) {
            att.body = pdfPage.getContentAsPDF();
        } else {
            att.body = Blob.valueOf('TEST');
        }

        att.parentid = thisCase.Id;
        insert att;
        return pdfPage;
    }

    public Boolean validateCompensation(List<CustomCompensation> customCompensations) {
        if(FilterTemplate != 'PV' && FilterTemplate != 'LCD') {
            return true;
        }

        if(!isSelectCompensation(customCompensations)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select compensation'));
            needToOpenAttachment = false;
            needToDownloadAttachment = false;
            isDownload = false;
            return false;
        }

        if(!validateAccountNumberAndAccountCenter(customCompensations)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Account Number or Account Center'));
            needToOpenAttachment = false;
            needToDownloadAttachment = false;
            isDownload = false;
            return false;
        } else {
            for(CustomCompensation eachCustomCompensation : customCompensations) {
                selectedAccountNumber = eachCustomCompensation.compensation.Compensation_Account_Number__c;
                selectedAccountCenter = eachCustomCompensation.compensation.Compensation_Account_Center__c;
                selectedAccountNumberPartial = selectedAccountNumber;
                selectedAccountCenterPartial = selectedAccountCenter;
            }
        }

        return true;
    }

    public PageReference saveAndAttach() {
        if(!validateCompensation(customCompensations)) {
            return null;
        }
        needToOpenAttachment = true;
        attachPDF();            
        return null;
    }

    public PageReference saveAndDownload() {
        if(!validateCompensation(customCompensations)) {
            return null;
        }
        needToDownloadAttachment = true;
        attachPDF();
        isDownload = true;
        return null;
    }

    public PageReference updateBodyWithParam(Boolean newAttachment) {
        String templateBodyForSave = templateBody;
        if (hasBody) {
            if (!String.isBlank(templateBodyForSave)  && templateBodyForSave.length() > 0) {
                templateBodyForSave = '|' + templateBodyForSave;
                templateBodyForSave = templateBodyForSave.replace('\n', '<br/>');
            }
            thisCase.Letter_Body__c = templateBodyForSave;
            thisCase.Letter_Language__c = getLanguageFromPageName(FilterTemplate);
        }
        thisCase.Latest_Document__c = FilterTemplate;
        thisCase.Latest_Template__c = letterBodyId;

        if (newAttachment) {
            if (FilterTemplate == UPGRADE_CONFIRM_PAGE_NAME) {
                if (thisCase.Upgrade_Confirmed_Attachment_Amount__c == null) thisCase.Upgrade_Confirmed_Attachment_Amount__c = 0;
                thisCase.Upgrade_Confirmed_Attachment_Amount__c = thisCase.Upgrade_Confirmed_Attachment_Amount__c + 1;
            } else if (FilterTemplate == UPGRADE_STANDBY_PAGE_NAME) {
                if (thisCase.Upgrade_StandBy_Attachment_Amount__c == null) thisCase.Upgrade_StandBy_Attachment_Amount__c = 0;
                thisCase.Upgrade_StandBy_Attachment_Amount__c = thisCase.Upgrade_StandBy_Attachment_Amount__c + 1;
            } else if (FilterTemplate == LETTER_EN_PAGE_NAME) {
                if (thisCase.LetterEN_Attachment_Amount__c == null) thisCase.LetterEN_Attachment_Amount__c = 0;
                thisCase.LetterEN_Attachment_Amount__c = thisCase.LetterEN_Attachment_Amount__c + 1;
            } else if (FilterTemplate == LETTER_TH_1_PAGE_NAME) {
                if (thisCase.LetterTH1_Attachment_Amount__c == null) thisCase.LetterTH1_Attachment_Amount__c = 0;
                thisCase.LetterTH1_Attachment_Amount__c = thisCase.LetterTH1_Attachment_Amount__c + 1;
            } else if (FilterTemplate == LETTER_TH_2_PAGE_NAME) {
                if (thisCase.LetterTH2_Attachment_Amount__c == null) thisCase.LetterTH2_Attachment_Amount__c = 0;
                thisCase.LetterTH2_Attachment_Amount__c = thisCase.LetterTH2_Attachment_Amount__c + 1;
            } else if (FilterTemplate == LCD_PAGE_NAME) {
                if (thisCase.LCD_Attachment_Amount__c == null) thisCase.LCD_Attachment_Amount__c = 0;
                thisCase.LCD_Attachment_Amount__c = thisCase.LCD_Attachment_Amount__c + 1;
            } else if (FilterTemplate == PV_PAGE_NAME) {
                if (thisCase.PV_Attachment_Amount__c == null) thisCase.PV_Attachment_Amount__c = 0;
                thisCase.PV_Attachment_Amount__c = thisCase.PV_Attachment_Amount__c + 1;
            }
        }

        if(thisCase.Flight_Date_Manual__c == null){
            thisCase.Flight_Date_Manual__c = BE8_DateUtility.convertDateFormatToTraditionalFormat(thisCase.Flightid__r.Flight_Date_LT__c);
        }
        if(thisCase.Flight_Number_Manual__c == null){
            thisCase.Flight_Number_Manual__c = thisCase.Flightid__r.Name.split(' ')[0];
        }
        if(thisCase.Flight_From_Manual__c == null){
            thisCase.Flight_From_Manual__c = thisCase.Flightid__r.Origin__c;
        }
        if(thisCase.Flight_To_Manual__c == null){
            thisCase.Flight_To_Manual__c = thisCase.Flightid__r.Destination__c;
        }

        if(validateCompensation(customCompensations)) {
            if(String.isNotBlank(selectedAccountCenterPartial) && String.isNotBlank(selectedAccountNumberPartial)) {
                thisCase.Account_Debited__c = selectedAccountNumberPartial + ' - ' + selectedAccountCenterPartial;
            } else {

            }
            update thisCase;
        } else {
            update thisCase;
        }


        return null;
    }

    private String getLanguageFromPageName(String pageName) {
        Map<String, String> languageMap = new Map<String, String>();
        languageMap.put(LETTER_TH_1_PAGE_NAME, LANGUAGE_THAI);
        languageMap.put(LETTER_TH_2_PAGE_NAME, LANGUAGE_THAI);
        languageMap.put(LETTER_EN_PAGE_NAME, LANGUAGE_ENGLISH);

        return languageMap.get(pageName);
    }

    private Boolean isSelectCompensation(List<CustomCompensation> customCompensations) {
        for(CustomCompensation eachCustomCompensation : customCompensations) {
            if(eachCustomCompensation.isSelected) {
                return true;
            }
        }
        return false;
    }

    private Boolean validateAccountNumberAndAccountCenter(List<CustomCompensation> customCompensations) {
        List<Compensation__c> compensations = new List<Compensation__c>();
        for(CustomCompensation eachCustomCompensation : customCompensations) {
            if(eachCustomCompensation.isSelected) {
                compensations.add(eachCustomCompensation.compensation);
            }
        }

        return Compensation_Service.validateAccountNumberAndAccountCenter(compensations);
    }

    public Boolean getHasErrorMessage() {
        return ApexPages.hasMessages();
    }
}