public class Approval_Email_Templete_Controller {
    private final List<Compensation__c> listcomp;

    public Decimal totalAmount {get; set;}
    //public Decimal totalAmountEachPassenger {get; set;}
    public String currencyWord {get; set;}
    public Decimal totalAmountTHB {get; set;}
    public String debugString {get; set;}
    public Integer caseGroupMemberSize {get; set;}

    public Approval_Email_Templete_Controller() {
        Id caseId = Apexpages.Currentpage().getParameters().get('id');
        //totalAmountEachPassenger = 0;
        listcomp = [SELECT Compensation_Type__c, Compensation_Tools__c, Status__c,
                    Total__c, Amount__c, Unit__c, Currency__c, Total_THB__c, Is_Individual__c, Passenger_Name__c, Name
                    FROM Compensation__c
                    WHERE Caseid__c = :caseId AND status__c = : BE8_GlobalConstants.CASE_STATUS_PENDING];
        System.debug('List Compensation :: ' + listcomp.size());
        debugString = caseId + ' ' + listcomp.size();

        List<Case_Group_Member__c> caseGroupMembers = [SELECT Id FROM Case_Group_Member__c WHERE Caseid__c = :caseId];
        caseGroupMemberSize = caseGroupMembers.size();
        totalAmount = 0;
        totalAmountTHB = 0;
        for (Compensation__c compensation : listcomp) {
            if (compensation.Compensation_Tools__c == 'Cash') {
                currencyWord = compensation.Currency__c;
            } else {
                currencyWord = compensation.Unit__c;
            }

            if (!compensation.Is_Individual__c) {
                totalAmount += (compensation.Amount__c * caseGroupMemberSize);
                totalAmountTHB += (compensation.Total_THB__c * caseGroupMemberSize);
            } else {
                totalAmount += compensation.Amount__c;
                totalAmountTHB += compensation.Total_THB__c;
            }
            //totalAmountEachPassenger += compensation.Amount__c;
        }
    }

    public List<Compensation__c> getCompensations() {
        return listcomp;
    }

}