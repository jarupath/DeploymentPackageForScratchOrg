public class Approval_Email_Templete_Controller {
    private final List<Compensation__c> listcomp;
    private final String THB = 'THB';
    private final String USD = 'USD';

    public Boolean isAbroad {get; set;}
    public Decimal totalAmount {get; set;}
    public String casecurrency {get; set;}
    public String totalamountField {get; set;}
    //public Decimal totalAmountEachPassenger {get; set;}
    public Decimal totalAmountTHB {get; set;}
    public String debugString {get; set;}
    public Integer caseGroupMemberSize {get; set;}
    public Map<String, Decimal> summaryMap {get; set;}
    public Map<String, String> summaryUnitMap {get; set;}
    public List<String> summaryKeyList {get; set;}

    public Approval_Email_Templete_Controller() {
        BE8_MasterData profileData = new BE8_MasterData('Profile');
        Profile actualProfile = (Profile)profileData.getObjectByName('CFMS SD/SR');
        isAbroad = (UserInfo.getProfileId() == actualProfile.Id);
        casecurrency = isAbroad ? USD : THB;
        totalamountField = isAbroad ? 'Total_USD__c' : 'Total_THB__c';
        Id caseId = Apexpages.Currentpage().getParameters().get('id');
        //totalAmountEachPassenger = 0;
        listcomp = [SELECT Compensation_Type__c, Compensation_Tools__c, Status__c,
                    Total__c, Amount__c, Unit__c, Currency__c, Total_THB__c, Total_USD__c, Is_Individual__c, Passenger_Name__c, Name
                    FROM Compensation__c
                    WHERE Caseid__c = :caseId AND status__c = : BE8_GlobalConstants.CASE_STATUS_PENDING];
        System.debug('List Compensation :: ' + listcomp.size());
        debugString = caseId + ' ' + listcomp.size();

        List<Case_Group_Member__c> caseGroupMembers = [SELECT Id FROM Case_Group_Member__c WHERE Caseid__c = :caseId];
        caseGroupMemberSize = caseGroupMembers.size();
        summaryMap = new Map<String, Decimal>();
        summaryUnitMap = new Map<String, String>();
        summaryKeyList = new List<String>();
        for (Compensation__c compensation : listcomp) {
            updateSummary(compensation);
        }
    }

    public void updateSummary(Compensation__c comp){
        if(comp != null){
            if(comp != null && summaryMap.containsKey(comp.Compensation_Tools__c)){
                if(isCompensationToolsIsCashOrEMD(comp)){
                    Decimal total = summaryMap.get(comp.Compensation_Tools__c) + getTotalCurrency(comp, totalamountField);
                    summaryMap.put(comp.Compensation_Tools__c, total);
                }
                else{
                    Decimal total = summaryMap.get(comp.Compensation_Tools__c) + getTotal(comp);
                    summaryMap.put(comp.Compensation_Tools__c, total);
                }
            }
            else{
                if(isCompensationToolsIsCashOrEMD(comp)){
                    summaryMap.put(comp.Compensation_Tools__c, getTotalCurrency(comp, totalamountField));
                    summaryUnitMap.put(comp.Compensation_Tools__c, casecurrency);
                }
                else{
                    summaryMap.put(comp.Compensation_Tools__c, getTotal(comp));
                    summaryUnitMap.put(comp.Compensation_Tools__c, comp.Unit__c);
                }
                summaryKeyList.add(comp.Compensation_Tools__c);
            }
        }
    }

    public Boolean isCompensationToolsIsCashOrEMD(Compensation__c comp){
        return comp.Compensation_Tools__c == 'Cash' || comp.Compensation_Tools__c == 'EMD';
    }

    public Decimal getTotal(Compensation__c comp){
        if(comp.Is_Individual__c) return comp.Total__c;
        else return comp.Total__c * caseGroupMemberSize;
    }   

    public Decimal getTotalCurrency(SObject comp, String fieldname){
        if(Boolean.valueOf(comp.get('Is_Individual__c'))) return Decimal.valueOf(String.valueOf(comp.get(fieldname)));
        else return Decimal.valueOf(String.valueOf(comp.get(fieldname))) * caseGroupMemberSize;
    }

    public List<Compensation__c> getCompensations() {
        return listcomp;
    }

}