public with sharing class UpgradeConfirmationController {

    public UpgradeView view {get; set;}
    public Map<String, Object> viewMap {get; set;}
    private User caseOwner;
    public String pdfName {get; set;}
    public String docName {get; set;}

    public Boolean isDownload {get; set;}
    public String templateBody {get; set;}

    public class UpgradeView {
        public String referenceTo {get; set;}
        public String passengerName {get; set;}
        public String ownerRole {get; set;}
        public String ownerAlias {get; set;}
        public String ownerDepartment {get; set;}
        public Datetime dateIssue {get; set;}
        public Datetime dateExpire {get; set;}
        public String caseNumber {get; set;}
        public String ticketNumber {get; set;}
        public String flightName {get; set;}
        public String flightSector {get; set;}
        public String authorizedBy {get; set;}
        public String authorizedPosition {get; set;}
        public String authorizedDepartment {get; set;}
        public String authorizedPhone {get; set;}
        public String authorizedFax {get; set;}
        public String ownerStation {get; set;}
        public String passengerEmail {get; set;}
        public String passengerAddress {get; set;}
        public String passengerStreet1 {get; set;}
        public String passengerStreet2 {get; set;}
        public String passengerCity {get; set;}
        public String passengerCountry {get; set;}
        public String passengerPostalCode {get; set;}
        public String sector {get; set;}
        public String flightonly {get; set;}
        public String flightdate {get; set;}
        public String comment1 {get; set;}
        public String comment2 {get; set;}
        public String comment3 {get; set;}
        public String comment4 {get; set;}
        public String comment5 {get; set;}
        public Case caseObj {get; set;}
        public String letterBody {get; set;}
        public String subject {get; set;}
        public String travelType {get; set;}
        public String attachName {get; set;}
        public String tgLetter {get; set;}
        public Boolean needTGDoc {get; set;}
        public String runningNumber {get; set;}
    }

    public void addFieldValueMap(String fieldName, Object val) {
        if (viewMap == null) {
            viewMap = new Map<String, Object>();
        }
        viewMap.put(fieldName, val);
    }

    public Object getFieldValue(String fieldName) {

        if (viewMap != null && viewMap.containsKey(fieldName)) {
            //return viewMap.get(fieldName)!=null?viewMap.get(fieldName):fieldName.toUpperCase();
            return viewMap.get(fieldName) != null ? viewMap.get(fieldName) : '...' + fieldName.toUpperCase() + '...';
        } else {
            return '...' + fieldName.toUpperCase() + '...';
        }
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

    public UpgradeConfirmationController(ApexPages.StandardController stdController) {
        Case currentCase = [SELECT Id,
                            OwnerId,
                            Passengerid__r.Name,
                            Latest_Document__c,
                            Passenger_Email__c,
                            PassengerId__r.Sector__c,
                            Owner.UserRole.Name,
                            Owner.Alias,
                            CreatedDate,
                            ClosedDate,
                            Expiry_Date__c,
                            Case_Number_Custom_F__c,
                            Passengerid__r.PNR__c,
                            FlightId__r.Name,
                            FlightId__r.Sector__c,
                            FlightId__r.Flight_Date_LT__c,
                            //Authorize_Signature__c,
                            Authorize_Signature_Current__c,
                            Position__c,
                            Department__c,
                            Owner_Station__c,
                            Passengerid__r.AccountId__r.Mailling_Address__c,
                            Letter_Body__c
                            FROM Case WHERE Id = : stdController.getId() LIMIT 1];

        //if (String.isBlank(currentCase.Authorize_Signature_Current__c)) {
        if (currentCase.OwnerId != null) {
            String ownerType = BE8_GlobalUtility.getObjectNameFromRecordIdPrefix(currentCase.OwnerId);
            if (ownerType == 'User') {
                caseOwner = [SELECT Id, Station__c, Phone, Fax, Name, Name_TH__c, Authorized_Position_EN__c, Authorized_Position_TH__c,
                             Authorized_Department_EN__c, Authorized_Department_TH__c, Alias, Department, UserRole.Name
                             FROM User WHERE Id = :currentCase.OwnerId];
            }
        }

        //}
        //Letter_Master__c letter = [SELECT Id, Description__c FROM Letter_Master__c WHERE ID = 'a0KN000000635LyMAI'];
        //templateBody = letter.Description__c;

        String pName = Apexpages.Currentpage().getParameters().get('passengerName');
        String pEmail = Apexpages.Currentpage().getParameters().get('passengerEmail');
        String pStreet1 = Apexpages.Currentpage().getParameters().get('passengerStreet1');
        String pStreet2 = Apexpages.Currentpage().getParameters().get('passengerStreet2');
        String pCity = Apexpages.Currentpage().getParameters().get('passengerCity');
        String pCountry = Apexpages.Currentpage().getParameters().get('passengerCountry');
        String pPostalCode = Apexpages.Currentpage().getParameters().get('passengerPostalCode');

        String comment1 = Apexpages.Currentpage().getParameters().get('comment1');
        String comment2 = Apexpages.Currentpage().getParameters().get('comment2');
        String comment3 = Apexpages.Currentpage().getParameters().get('comment3');
        String comment4 = Apexpages.Currentpage().getParameters().get('comment4');
        String comment5 = Apexpages.Currentpage().getParameters().get('comment5');

        String isDownloadParam = Apexpages.Currentpage().getParameters().get('isDownload');
        if (isDownloadParam != null) {
            isDownload = Boolean.valueOf(isDownloadParam);
        }

        view = createUpdateConfirmationView(currentCase, pName, pEmail, pStreet1, pStreet2, pCity, pCountry, pPostalCode,
                                            comment1, comment2, comment3, comment4, comment5);
        view.runningNumber = Apexpages.CurrentPage().getParameters().get('runningNumber');
        view.travelType = Apexpages.Currentpage().getParameters().get('travelType');
        view.subject = Apexpages.Currentpage().getParameters().get('subject');
        view.attachName = Apexpages.Currentpage().getParameters().get('attachName');
        view.referenceTo = Apexpages.Currentpage().getParameters().get('referenceTo');

        view.authorizedPhone = Apexpages.Currentpage().getParameters().get('authorizedPhone');
        view.authorizedFax = Apexpages.Currentpage().getParameters().get('authorizedFax');
        if (caseOwner != null) {
            if (String.isBlank(view.authorizedPhone)) view.authorizedPhone = caseOwner.Phone;
            if (String.isBlank(view.authorizedFax)) view.authorizedFax = caseOwner.Fax;
        }

        view.tgLetter = Apexpages.CurrentPage().getParameters().get('tgLetter');

        String needTGDocStr = Apexpages.CurrentPage().getParameters().get('needTGDoc');
        if (!String.isBlank(needTGDocStr)) {
            view.needTGDoc = Boolean.valueOf(needTGDocStr);
        }

        pdfName = Apexpages.Currentpage().getParameters().get('pdfName');
        docName = Apexpages.Currentpage().getParameters().get('docName');
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfName);
    }

    private UpgradeView createUpdateConfirmationView(Case caseObj, String pName, String pEmail, String pStreet1, String pStreet2, String pCity,
            String pCountry, String pPostalCode, String comment1, String comment2, String comment3, String comment4, String comment5) {
        UpgradeView view = new UpgradeView();
        String pAddress = pStreet1 + pStreet2 + pCity + pCountry + pPostalCode;
        view.caseObj = caseObj;
        Boolean isENDoc = false;
        Boolean isTHDoc = false;
        if (!String.isBlank(caseObj.Latest_Document__c)) {
            isENDoc = caseObj.Latest_Document__c.toUpperCase().contains('EN');
            isTHDoc = caseObj.Latest_Document__c.toUpperCase().contains('TH');
        } else {
            isENDoc = true;
        }

        view.passengerName = pName != null && pName.length() > 0 ? pName : caseObj.Passengerid__r.Name;
        addFieldValueMap('passengerName', view.passengerName);

        if (caseOwner != null) {
            view.ownerRole = caseOwner.UserRole.Name;
            view.ownerAlias = caseOwner.Alias;
            view.ownerStation = caseOwner.Station__c;
            view.ownerDepartment = caseOwner.Department;
        }
        addFieldValueMap('ownerStation', view.ownerStation);
        addFieldValueMap('ownerRole', view.ownerRole);
        addFieldValueMap('ownerAlias', view.ownerAlias);
        addFieldValueMap('ownerDepartment', view.ownerDepartment);

        if (Apexpages.CurrentPage().getParameters().get('issueDate') != null) {
            String issueDate = Apexpages.CurrentPage().getParameters().get('issueDate');
            view.dateIssue = Date.valueOf(issueDate);
            addFieldValueMap('dateIssue', view.dateIssue);
        }

        //view.dateExpire = caseObj.ClosedDate;
        if (Apexpages.CurrentPage().getParameters().get('expiryDate') != null) {
            String expiryDate = Apexpages.CurrentPage().getParameters().get('expiryDate');
            view.dateExpire = Date.valueOf(expiryDate);
            addFieldValueMap('dateExpire', view.dateExpire);
        }

        view.caseNumber = caseObj.Case_Number_Custom_F__c;
        addFieldValueMap('caseNumber', view.caseNumber);

        view.ticketNumber = caseObj.Passengerid__r.PNR__c;
        addFieldValueMap('ticketNumber', view.ticketNumber);

        if (caseObj.FlightId__r != null) {
            if (!String.isBlank(caseObj.FlightId__r.Name)) {
                view.flightName = caseObj.FlightId__r.Name;
                addFieldValueMap('flightName', view.flightName);

                String[] flightStrs = caseObj.FlightId__r.Name.split('/');
                view.flightonly = flightStrs.size() > 0 ? flightStrs[0].trim() : '';
                addFieldValueMap('flightonly', view.flightonly);
            }
            view.flightSector = caseObj.FlightId__r.Sector__c;
            addFieldValueMap('flightSector', view.flightSector);
        }

        if (!String.isBlank(caseObj.Authorize_Signature_Current__c)) {
            view.authorizedBy = caseObj.Authorize_Signature_Current__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                view.authorizedBy = caseOwner.Name;
            } else if (isTHDoc) {
                view.authorizedBy = caseOwner.Name_TH__c;
            }
        }
        addFieldValueMap('authorizedBy', view.authorizedBy);

        if (!String.isBlank(caseObj.Position__c)) {
            view.authorizedPosition = caseObj.Position__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                view.authorizedPosition = caseOwner.Authorized_Position_EN__c;
            } else if (isTHDoc) {
                view.authorizedPosition = caseOwner.Authorized_Position_TH__c;
            }
        }
        addFieldValueMap('authorizedPosition', view.authorizedPosition);

        if (!String.isBlank(caseObj.Department__c)) {
            view.authorizedDepartment = caseObj.Department__c;
        } else if (caseOwner != null) {
            if (isENDoc) {
                view.authorizedDepartment = caseOwner.Authorized_Department_EN__c;
            } else if (isTHDoc) {
                view.authorizedDepartment = caseOwner.Authorized_Department_TH__c;
            }
        }
        addFieldValueMap('authorizedDepartment', view.authorizedDepartment);

        view.passengerEmail = pEmail != null && pEmail.length() > 0 ? pEmail : caseObj.Passenger_Email__c;
        addFieldValueMap('passengerEmail', view.passengerEmail);

        view.passengerAddress = pAddress != null && pAddress.trim().length() > 0 ? '' : caseObj.Passengerid__r.AccountId__r.Mailling_Address__c;
        addFieldValueMap('passengerAddress', view.passengerAddress);

        view.passengerStreet1 = pStreet1;
        addFieldValueMap('passengerStreet1', view.passengerStreet1);

        view.passengerStreet2 = pStreet2;
        addFieldValueMap('passengerStreet2', view.passengerStreet2);

        view.passengerCity = pCity;
        addFieldValueMap('passengerCity', view.passengerCity);

        view.passengerCountry = pCountry;
        addFieldValueMap('passengerCountry', view.passengerCountry);

        view.passengerPostalCode = pPostalCode;
        addFieldValueMap('passengerPostalCode', view.passengerPostalCode);

        view.sector = caseObj.PassengerId__r.Sector__c;
        addFieldValueMap('sector', view.sector);

        String[] fDates = caseObj.FlightId__r.Flight_Date_LT__c != null ? caseObj.FlightId__r.Flight_Date_LT__c.split('-') : null;
        view.flightdate = fDates != null && fDates.size() == 3 ? fDates[2] + '/' + fDates[1] + '/' + fDates[0] : '';
        addFieldValueMap('flightdate', view.flightdate);

        view.comment1 = comment1;
        addFieldValueMap('comment1', view.comment1);

        view.comment2 = comment2;
        addFieldValueMap('comment2', view.comment2);

        view.comment3 = comment3;
        addFieldValueMap('comment3', view.comment3);

        view.comment4 = comment4;
        addFieldValueMap('comment4', view.comment4);

        view.comment5 = comment5;
        addFieldValueMap('comment5', view.comment5);

        System.debug('view.caseObj.Letter_Body__c :' + view.caseObj.Letter_Body__c);
        String fullBody = fillinFieldTokens(view.caseObj.Letter_Body__c);

        if (!String.isEmpty(fullBody)) {
            if (fullBody.substring(0, 1) == '|') {
                fullBody = fullBody.substring(1);
            }
        }

        //view.letterBody = fullBody.replace(' ', '&nbsp;');
        view.letterBody = '';
        List<String> lines = fullBody.Split('<br>');
        for (String eachLine : lines) {
            for (Integer i = 0; i < eachLine.length(); i++) {
                if (eachLine.substring(i, i + 1) != ' ' || i == eachLine.length() - 1) {
                    String pad = '';
                    pad = pad.leftPad(i).replace(' ', '&nbsp;');
                    eachLine = pad + eachLine.substring(i);
                    view.letterBody += eachLine + '\n';
                    break;
                }
            }
        }
        return view;
    }
}