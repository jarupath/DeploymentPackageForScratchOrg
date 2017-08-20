global class Genarate_Queue_Controller {
    
    WebService static string createqueue(string queuename,string rrgid){
        Group newqueue = new Group();
        newqueue.Name = queuename;
        newqueue.type='Queue';
        
        if(!checkdupqueuename(queuename)){
            insert newqueue;

            QueuesObject newqueueobj = new QueueSObject(QueueID = newqueue.id, SobjectType = 'Case');
            insert newqueueobj;
        }
        
        if(newqueue.id != null)
            update_case_team(rrgid,newqueue.id);
        else
            update_case_team(rrgid,null);
            
        return 'Success';
    }
    
    @future
    Private static void update_case_team(id rrgid,id newqueueid){
        Case_Team__c rrg = [Select id,queue_id__c,active__c from Case_Team__c Where id =: rrgid];
        if(newqueueid != null){rrg.queue_id__c = newqueueid + '';}   
        rrg.active__c = true;
        rrg.recordtypeid = getactiveid();
        update rrg;
    }
    
    private static id getactiveid(){
        return [Select id from RecordType where sobjecttype = 'Case_Team__c' and name = 'Active'].id;
    }
    
    private static boolean checkdupqueuename(string queuename){
        list<Group> listqueue = [Select id from Group where type = 'Queue' and name =: queuename];
        
        if(listqueue.size() > 0)
            return true;
        else
            return false;
    }
    
}