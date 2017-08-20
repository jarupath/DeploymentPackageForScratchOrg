public with sharing class LCDController {

    private final sObject mysObject;
    public LCDView view {get; set;}
    public String logoURL {get; set;}
    public String currencyWord;
    public String subCurrencyWord;
    public String selectedCaseGroupMemberId {get; set;}
    public String pdfName {get; set;}

    public class LCDView {
        public String passengerName {get; set;}
        public String flightDate {get; set;}
        public String flightNumber {get; set;}
        public String origin {get; set;}
        public String destination {get; set;}
        public String passengerTicketNumber {get; set;}
        public String baggageCheckNumber {get; set;}
        public String excessBagTicketNumber {get; set;}
        public String settlementAuthorizedBy {get; set;}
        public String amountInWords {get; set;}
        public Decimal amountInFigures {get; set;}
        public String detail {get; set;}
        public String accountDebited {get; set;}
        public Case caseObj {get; set;}
        public Boolean displayTHB {get; set;}
        public String displayCurrency {get; set;}
    }

    public LCDController(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
        Case currentCase;
        String compensationIds = Apexpages.Currentpage().getParameters().get('compensationIds');
        if(String.isBlank(compensationIds)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select compensation'));
            return;
        } else {
            List<Id> compensationIdList = compensationIds.split(',');
            currentCase = [SELECT Id, Flight_Number_Manual__c, Flight_Date_Manual__c, Flight_From_Manual__c, Flight_To_Manual__c, Passengerid__r.Name, Flightid__r.Flight_Date_LT__c, Flightid__r.Name, Flightid__r.Origin__c, Flightid__r.Destination__c, Case_Number_Custom_F__c, Passenger_Ticket_Number__c, Baggage_Check_Number__c, Excess_Bag_Ticket_Number__c, Account_Debited__c, LCD_Detail__c, (SELECT Id, Total_THB__c, Compensation_Tools__c, ROE__c, Amount__c, Currency__c, Is_Individual__c, Case_Group_Member__c, Compensation_Account_Number__c, Compensation_Account_Center__c FROM Compensations__r WHERE Id IN :compensationIdList AND Total_THB__c != null and Status__c = 'Approved') FROM Case WHERE Id = : stdController.getId() LIMIT 1];

            if(!Compensation_Service.validateAccountNumberAndAccountCenter(currentCase.Compensations__r)) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Account Number or Account Center'));
                return;
            }
        }
        
        selectedCaseGroupMemberId = Apexpages.CurrentPage().getParameters().get('selectedCaseGroupMemberId');
        List<Document> docList = [SELECT id FROM Document where name = 'THAI_Logo'];
        if (docList != null && docList.size() > 0) {
            logoURL = '/servlet/servlet.FileDownload?file=' + docList.get(0).Id;
        }

        view = createLCDView(currentCase);
        pdfName = Apexpages.Currentpage().getParameters().get('pdfName');
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfName);
    }

    private LCDView createLCDView(Case caseObj) {
        LCDView view = new LCDView();
        //view.passengerName = caseObj.Passengerid__r.Name;
        view.passengerName = Apexpages.Currentpage().getParameters().get('passengerName');
        String displayTHB = Apexpages.CurrentPage().getParameters().get('displayTHB');
        view.displayTHB = false;
        if (!String.isBlank(displayTHB)) {
            view.displayTHB = Boolean.valueOf(displayTHB);
        }
        currencyWord = Apexpages.Currentpage().getParameters().get('currencyWord');
        subCurrencyWord = Apexpages.Currentpage().getParameters().get('subCurrencyWord');
        //Date flightDate = Date.valueOf(caseObj.Flightid__r.Flight_Date_LT__c);
        //view.flightDate = BE8_DateUtility.convertDateFormatToTraditionalFormat(caseObj.Flightid__r.Flight_Date_LT__c);
        //view.flightNumber = caseObj.Flightid__r.Name.split(' ')[0];
        //view.origin = caseObj.Flightid__r.Origin__c;
        //view.destination = caseObj.Flightid__r.Destination__c;

        //if (view.flightNumber == BE8_GlobalConstants.DUMMY_FLIGHT_NAME) {
        view.flightNumber = caseObj.Flight_Number_Manual__c;
        view.flightDate = caseObj.Flight_Date_Manual__c;
        view.origin = caseObj.Flight_From_Manual__c;
        view.destination = caseObj.Flight_To_Manual__c;
        //}

        User currentUser = [SELECT Id, Alias, Department FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        view.settlementAuthorizedBy = currentUser.Department + '/' + caseObj.Case_Number_Custom_F__c + '-' + currentUser.Alias;

        Decimal totalAmount = 0;
        view.displayCurrency = 'THB';

        Boolean hasOtherCashEMD = false;
        for (Compensation__c each : caseObj.Compensations__r) {
            if (each.Compensation_Tools__c == 'Cash' || each.Compensation_Tools__c == 'EMD') {
                if (each.Amount__c != null) {
                    System.debug('Individual :' + each.Case_Group_Member__c + ' ' + selectedCaseGroupMemberId);
                    if (each.Is_Individual__c && each.Case_Group_Member__c != selectedCaseGroupMemberId) {
                        continue;
                    }

                    Decimal eachAmount = Compensation_Service.getAmountPerPassenger(each, view.displayTHB);
                    if (view.displayTHB) {
                        currencyWord = 'BAHT';
                        subCurrencyWord = 'SATANG';
                    } else {
                        view.displayCurrency = each.Currency__c;
                    }
                    totalAmount += eachAmount;
                }

            } else {
                hasOtherCashEMD = true;
            }
        }

        totalAmount = totalAmount.setScale(2);
        view.amountInFigures = totalAmount;
        if (totalAmount >= 0) {
            String amount = String.valueOf(totalAmount);
            String amountInFiguresDec = amount.substring(amount.indexOf('.') + 1);
            view.amountInWords = new NumbersToWordsClass().convert((Long)view.amountInFigures).toUpperCase();
            view.amountInWords += ' ' +  currencyWord + ' ' + (Long.valueOf(amountInFiguresDec) > 0 ? new NumbersToWordsClass().convert(Long.valueOf(amountInFiguresDec)).toUpperCase() + ' ' + subCurrencyWord : 'ONLY');
            //System.debug('SJ :amount :' + amount);
            //System.debug('SJ :amountInFiguresDec :' + amountInFiguresDec);
            //System.debug('SJ :Long.valueOf(amountInFiguresDec) :' + Long.valueOf(amountInFiguresDec));
            //if (view.displayTHB) {
            //    view.amountInWords += ' ' +  currencyWord + ' ' + (Long.valueOf(amountInFiguresDec) > 0 ? new NumbersToWordsClass().convert(Long.valueOf(amountInFiguresDec)).toUpperCase() + ' ' + subCurrencyWord : 'ONLY');
            //} else {
            //    view.amountInWords += ' ' + currencyWord;
            //}
        }
        view.passengerTicketNumber = caseObj.Passenger_Ticket_Number__c;
        view.baggageCheckNumber = caseObj.Baggage_Check_Number__c;
        view.excessBagTicketNumber = caseObj.Excess_Bag_Ticket_Number__c;
        view.accountDebited = caseObj.Account_Debited__c;
        view.detail = caseObj.LCD_Detail__c;

        if(hasOtherCashEMD) {
            view.displayCurrency = '';
            view.amountInWords = '';
            view.amountInFigures = null;
        }

        return view;
    }

}