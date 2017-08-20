public with sharing class PVController {

    public PVView view {get; set;}
    public String logoURL {get; set;}
    public String selectedCaseGroupMemberId {get; set;}
    public String selectedAccountNumber {get; set;}
    public String selectedAccountCenter {get; set;}
    public String selectedAccountNumberPartial {get; set;}
    public String selectedAccountCenterPartial {get; set;}
    public Boolean displayTHB {get; set;}
    public String currencyWord;
    public String subCurrencyWord;
    public String targetCurrency {get; set;}
    public Integer noCaseGroupMember = 0;
    public String pdfName {get; set;}

    public class PVView {
        public String caseNumber {get; set;}
        public String caseNumberSTD {get; set;}
        public String position {get; set;}
        public String amountInWords {get; set;}
        public Decimal amountInFigures {get; set;}
        public String amountInFiguresDec {get; set;}
        public String freeTextComment {get; set;}
        public Boolean isCash {get; set;}
        public Boolean isCheque {get; set;}
        public Case caseObj {get; set;}
        public List<Compensation__c> compensations {get; set;}
    }

    public PVController(ApexPages.StandardController stdController) {
        System.debug('SJ : Case ID' + stdController.getId());
        selectedAccountNumber = Apexpages.Currentpage().getParameters().get('selectedAccountNumber');
        selectedAccountCenter = Apexpages.Currentpage().getParameters().get('selectedAccountCenter');
        pdfName = Apexpages.Currentpage().getParameters().get('pdfName');
        Case currentCase;

        String compensationIds = Apexpages.Currentpage().getParameters().get('compensationIds');
        if(String.isBlank(compensationIds)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select compensation'));
            return;
        } else {
            List<Id> compensationIdList = compensationIds.split(',');
            currentCase = [SELECT Id, CaseNumber, Case_Number_Custom_F__c, Position__c, A_C_Type__c, Flight_Number_txt__c, (SELECT Id, Total_THB__c, Compensation_Account_Center__c, Compensation_Account_Number__c, Compensation_Tools__c, ROE__c, Amount__c, Currency__c, Is_Individual__c, Case_Group_Member__c FROM Compensations__r WHERE Id IN :compensationIdList AND Status__c = 'Approved') FROM Case WHERE Id = : stdController.getId() LIMIT 1];


            if(!Compensation_Service.validateAccountNumberAndAccountCenter(currentCase.Compensations__r)) {
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Invalid Account Number or Account Center'));
                return;
            }
        }
        
        selectedAccountNumberPartial = Apexpages.Currentpage().getParameters().get('selectedAccountNumberPartial');
        selectedAccountCenterPartial = Apexpages.Currentpage().getParameters().get('selectedAccountCenterPartial');
        
        //System.debug('currentCase :' + currentCase);
        System.debug('currentCase :' + JSON.serialize(currentCase));
        List<Case_Group_Member__c> caseGroupMembers = [SELECT Id FROM Case_Group_Member__c WHERE CaseID__c = :currentCase.Id];
        noCaseGroupMember = caseGroupMembers.size();

        String comment = Apexpages.Currentpage().getParameters().get('comment');
        comment = comment.replaceAll('  ', '&nbsp;&nbsp;');
        selectedCaseGroupMemberId = Apexpages.Currentpage().getParameters().get('selectedCaseGroupMemberId');
        String displayTHBStr = Apexpages.Currentpage().getParameters().get('displayTHB');
        currencyWord = Apexpages.Currentpage().getParameters().get('currencyWord');
        subCurrencyWord = Apexpages.Currentpage().getParameters().get('subCurrencyWord');
        if (String.isBlank(displayTHBStr)) {
            displayTHB = false;
        } else {
            displayTHB = Boolean.valueOf(displayTHBStr);
        }
        //if (!String.isBlank(selectedCaseGroupMemberIdStr )) {
        //    selectedCaseGroupMemberId = selectedCaseGroupMemberIdStr ;
        //}
        view = createPVView(currentCase, comment);
        List<Document> docList = [SELECT id FROM Document where name = 'THAI_Logo'];
        if (docList != null && docList.size() > 0) {
            logoURL = '/servlet/servlet.FileDownload?file=' + docList.get(0).Id;
        }

        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + pdfName);
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename=' + pdfName);

        System.debug('ctrl.view.amountInFigures : ' + view.amountInFigures);
        System.debug('ctrl.view.amountInFiguresDec : ' + view.amountInFiguresDec);
    }

    private PVView createPVView(Case caseObj, String comment) {
        PVView view = new PVView();
        view.caseObj = caseObj;
        view.caseNumberSTD = caseObj.CaseNumber;
        view.caseNumber = caseObj.Case_Number_Custom_F__c;
        view.position = caseObj.Position__c;
        view.compensations = caseObj.Compensations__r;
        //if (!String.isBlank(comment)) {
        //    view.freeTextComment = comment.replace('\n', '<br/>').replace(' ', ' ');
        //}
        view.freeTextComment = comment;

        String isChequeStr = Apexpages.CurrentPage().getParameters().get('isCheque');
        if (!String.isBlank(isChequeStr)) {
            view.isCheque = Boolean.valueOf(isChequeStr);
        }

        String isCashStr = Apexpages.CurrentPage().getParameters().get('isCash');
        if (!String.isBlank(isCashStr)) {
            view.isCash = Boolean.valueOf(isCashStr);
        }

        Decimal totalAmount = 0;
        targetCurrency = 'THB';
        System.debug('caseObj.Compensations__r: ' + JSON.serialize(caseObj.Compensations__r));
        for (Compensation__c each : caseObj.Compensations__r) {
            if (each.Compensation_Tools__c == 'Cash' || each.Compensation_Tools__c == 'EMD') {
                if (each.Amount__c != null) {
                    if (each.Is_Individual__c && each.Case_Group_Member__c != selectedCaseGroupMemberId) {
                        continue;
                    }

                    totalAmount += Compensation_Service.getAmountPerPassenger(each, displayTHB);
                    if (displayTHB) {
                        currencyWord = 'BAHT';
                        subCurrencyWord = 'SATANG';
                    } else {
                        targetCurrency = each.Currency__c;
                    }
                }
            }
        }
        totalAmount = totalAmount.setScale(2);
        System.debug('totalAmount :' + totalAmount);
        if (totalAmount > 0) {
            String amount = String.valueOf(totalAmount);
            view.amountInFigures = Decimal.valueOf(amount.substring(0, amount.indexOf('.')));
            System.debug('view.amountInFigures :' + view.amountInFigures);
            view.amountInFiguresDec = amount.substring(amount.indexOf('.') + 1);
            view.amountInWords = new NumbersToWordsClass().convert((Long)view.amountInFigures).toUpperCase() + ' ' + currencyWord + ' ' + (Long.valueOf(view.amountInFiguresDec) > 0 ? new NumbersToWordsClass().convert(Long.valueOf(view.amountInFiguresDec)).toUpperCase() + ' ' + subCurrencyWord : 'ONLY');
        }

        return view;
    }
}