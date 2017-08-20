/*
  https://be8-sccc.atlassian.net/browse/TGSIC-133 - Custom Page on Case Creation Dialog to add Passenger before Save

  Controller Class of Visualforce page for adding passenger list to case and set case passenger when one of the passenger is the list is marked as
  primary passenger.

    As a ground customer service agent, I shall be able to select multiple passengers that have been affect by an issue and create a case for all of 
    them so that I can efficiently record cases.
    - Must also be able to select multiple Passenger (Visualforce Page)
    - Add search field on the top of the page
    -----------------------------------
    Estimation = 2 MD
*/

public with sharing class AddCasePassengerListController {

    public Case thisCase {get; set;}
    public String thisPassengerIds {get; set;}
    public List<Id> existingPassengerList = new List<Id>();
    public Id primaryPassenger {get; set;}
    public String retURL {get; set;}
    public String topURL {get; set;}

    public AddCasePassengerListController() {
        List<Case> caseList = [Select Passengerid__c, 
                                        Flightid__c, 
                                        Flightid__r.AircraftId__c, 
                                        ParentId, 
                                        AccountId, 
                                        Account.ROP_Tier__c, 
                                        Priority, 
                                        Subject, 
                                        Status, 
                                        Origin 
                                    from Case Where id = :Apexpages.Currentpage().getParameters().get('id')];
        if(caseList!=null && caseList.size()>0) {
            thisCase = caseList.get(0);
            primaryPassenger = thisCase.Passengerid__c;

            List<Case_Group_Member__c> existingCaseMemeberList = [Select Passengerid__c from Case_Group_Member__c where Caseid__c = :thisCase.Id];
            for(Case_Group_Member__c m : existingCaseMemeberList) {
                existingPassengerList.add(m.Passengerid__c);
            }

        }

        retURL = Apexpages.Currentpage().getParameters().get('ret');
        topURL = Apexpages.Currentpage().getParameters().get('top');
    }

    public List<Passenger__c> getPassengerList(){

        if(thisCase==null){return null;}

        List<Passenger__c> passengerList = [Select  id,
                                Name, 
                                PNR__c, 
                                FFP_Number__c, 
                                FFP_Tier__c, 
                                Seat__c, 
                                VIP_VVIP_Flag__c, 
                                Cabin_Code__c 
                       from  Passenger__c 
                       Where FlightId__c = :thisCase.FlightId__c 
                       AND id not in :existingPassengerList
                       Order by Name asc];
          
      return passengerList;
    }

    public List<List<Passenger__c>> getPassengerListList() {
        if(thisCase==null){return null;}
        List<List<Passenger__c>> paxListList = null;

        List<Passenger__c> passengerList = [Select  id,
                                Name, 
                                PNR__c, 
                                FFP_Number__c, 
                                FFP_Tier__c, 
                                Seat__c, 
                                VIP_VVIP_Flag__c, 
                                Cabin_Code__c 
                       from  Passenger__c 
                       Where FlightId__c = :thisCase.FlightId__c 
                       AND id not in :existingPassengerList
                       Order by Name asc];
        if(passengerList != null && !passengerList.isEmpty()) {
            paxListList = new List<List<Passenger__c>>();
            Integer loopcount = 1;
            List<Passenger__c> tempPaxList = new List<Passenger__c>();
            for(Passenger__c pax : passengerList){
                tempPaxList.add(pax);
                if(math.mod(loopcount, 1000) == 0 || loopcount == passengerList.size()) {
                    paxListList.add(tempPaxList);
                    tempPaxList = new List<Passenger__c>();
                }
                loopcount++;
            }
        }

        return paxListList;
    }

    public void addToPassengerList() {

        if(thisCase==null){return;}

        String query = 'Select  id,' +
                            'Name, ' +
                            'AccountId__c, ' +
                            'PNR__c, ' + 
                            'FFP_Number__c, ' + 
                            'FFP_Tier__c, ' +
                            'Seat__c, ' +
                            'VIP_VVIP_Flag__c, ' +
                            'Cabin_Code__c ' +
                   'from  Passenger__c ' + 
                   'Where Id in (\'' + thisPassengerIds.replaceAll(',', '\',\'') + '\') Order by Name asc';
            
        List<Passenger__c> passengerList = Database.query(query);

        List<Case_Group_Member__c> caseMemeberList = new List<Case_Group_Member__c>();

        for(Passenger__c p : passengerList){

            Case_Group_Member__c caseMember = new Case_Group_Member__c();
            
            caseMember.AccountId__c = p.AccountId__c;
            caseMember.Aircraft__c = thisCase.Flightid__r.AircraftId__c;
            caseMember.Caseid__c = thisCase.Id;
            caseMember.FFP_Number__c = p.FFP_Number__c;
            caseMember.FFP_Tier__c = p.FFP_Tier__c;
            caseMember.FlightId__c = thisCase.FlightId__c;
            caseMember.Passengerid__c = p.Id;
            caseMember.PNR__c = p.PNR__c;
            caseMember.Position__c = p.Seat__c;
            caseMember.Travel_Class__c = p.Cabin_Code__c;
            caseMember.VIP__c = p.VIP_VVIP_Flag__c;

            caseMemeberList.add(caseMember);
        }

        insert caseMemeberList;

        if(primaryPassenger==null && (thisCase.Passengerid__c==null || String.valueOf(thisCase.Passengerid__c).length()==0)){
            primaryPassenger = passengerList.size()>0?passengerList.get(0).Id:null;
        }
        
        if(primaryPassenger!=null && String.valueOf(primaryPassenger).length()>0){
            Case updateCase = new Case();
            updateCase.Id = thisCase.Id;
            updateCase.PassengerId__c = primaryPassenger;
            updateCase.Update_Passenger_By_Code__c = true;
            update updateCase;
        }
        
    }

}