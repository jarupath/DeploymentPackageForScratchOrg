public with sharing class PassengerCaseController {
    public String theme {get; set;}
    public ApexPages.StandardSetController con {get; set;}
    public PassengerCaseController (ApexPages.StandardController stdController) {
        Id flightId = Apexpages.currentpage().getparameters().get('id');
        //Flight__c flight = [SELECT Id, AircraftId__c FROM Flight__c WHERE Id = :flightId LIMIT 1];
        List<Case> caseList = [SELECT Id, PassengerId__r.Name, Case_Number_Custom__c, Case_Number_Custom_F__c,  Case_Number_Link_For_Console__c, Subject, Origin, Priority, Status, Case_Type__c, CreatedDate FROM Case WHERE FlightId__c =:flightId AND PassengerId__c != null ORDER BY CreatedDate DESC LIMIT 1000];
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(caseList);
        con = ssc;
        con.setPageSize(8);
        theme = UserInfo.getUiTheme().toLowerCase();
    }
    public List<Case> caseList {
        get
        {
            if (con != null)
                return (List<Case>)con.getRecords();
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