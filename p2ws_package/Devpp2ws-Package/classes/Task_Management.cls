public without sharing class Task_Management {
    
    public static string FUTUREFLIGHT = 'Future Flight';
    
    public static void findinvestigationstaff(list<task> listtask){
        map<String,Case_Member__c> Mapinvestigationmember = new map<String,Case_Member__c>();
        
        Mapinvestigationmember = getMapinvestigationmember(); 
        
        if(listtask.size() > 0){
            for(task thistask : listtask){
                if(thistask.Task_Type__c != FUTUREFLIGHT){
                    if(thistask.Investigation_Department__c != null && thistask.Investigation_Category__c != null){
                        String criteriatask = thistask.Investigation_Department__c.Trim().ToUpperCase() + thistask.Investigation_Category__c.Trim().ToUpperCase();
                        if(Mapinvestigationmember.Containskey(criteriatask)){
                            Case_Member__c istaff = Mapinvestigationmember.get(criteriatask);
                            thistask.To_Investigation_Staff__c = getfirstemail(istaff.Email__c);
                            thistask.Investigation_Other__c = istaff.Email__c;
                        }
                    }
                }
            }
        }
        
    }
    
    private static string getfirstemail(string emailstr){
        
        string emailresult = '';
        
        if(emailstr != null){
            list<string> listemail = new list<string>();
            listemail = emailstr.split(',',-2);
            
            if(listemail.size() > 0)
                emailresult = listemail.get(0);
        }
        
        return emailresult;
    }
    
    private static Map<String,Case_Member__c> getMapinvestigationmember(){
        
        map<String,Case_Member__c> Mapinvestigationmember = new map<String,Case_Member__c>();
        list<Case_Member__c> listinvestigationmember = new list<Case_Member__c>();
        
        listinvestigationmember = [Select id, name, Type__c,Tier__c, Department__c, Email__c 
                                   from Case_Member__c 
                                   where RecordType.name = 'Investigation Staff'];
        
        if(listinvestigationmember.size() > 0){
            
            for(Case_Member__c invstaff : listinvestigationmember){
                String criteriainv = invstaff.Department__c.Trim().ToUpperCase() + invstaff.Tier__c.Trim().ToUpperCase();
                Mapinvestigationmember.put(criteriainv , invstaff);
            }
        }
        
        return Mapinvestigationmember;
    }
}