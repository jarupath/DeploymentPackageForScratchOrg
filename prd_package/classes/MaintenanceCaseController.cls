public with sharing class MaintenanceCaseController {
    public String theme {get; set;}
    public ApexPages.StandardSetController con {get; set;}
    public MaintenanceCaseController (ApexPages.StandardController stdController) {
        Id flightId = Apexpages.currentpage().getparameters().get('id');
        Flight__c flight = [SELECT Id, AircraftId__c FROM Flight__c WHERE Id = :flightId LIMIT 1];
        List<Case_Group_Member__c> caseGroupMemberList = [SELECT Id, Impact_Status_Color__c, Name, CaseId__r.Case_Number_Custom_F__c, CaseId__r.Id, CaseId__r.SEQ_No_Display__c, CaseId__r.Case_Number_Link_For_Console__c, Case_Number_F__c, Position__c, Part_From_Case__c, Defect_Type__c, Impact__c, Equipment_From_Case__c FROM Case_Group_Member__c WHERE Equipment__r.Name = 'PASSENGER SEAT' AND CaseId__r.SEQ_No_Display__c != null AND CaseId__r.A_C_REG_ID__c = :flight.AircraftId__c And CaseId__r.Status = :BE8_GlobalConstants.CASE_STATUS_OPEN ORDER BY Position_Number_Only__c, Position_Alphabet_Only__c LIMIT 1000];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseGroupMemberList);
        con = ssc;
        con.setPageSize(8);
        theme = UserInfo.getUiTheme().toLowerCase();
    }
    public List<Case_Group_Member__c> caseGroupMemberList {
        get
        {
            if (con != null)
                return (List<Case_Group_Member__c>)con.getRecords();
            else
                return null ;
        }
        set;
    }
    public Boolean hasNext {
        get
        {
            return con.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get
        {
            return con.getHasPrevious();
        }
        set;
    }
    public Integer pageNumber {
        get
        {
            return con.getPageNumber();
        }
        set;
    }
    public void previous() {
        con.previous();
    }
    public void next() {
        con.next();
    }

}