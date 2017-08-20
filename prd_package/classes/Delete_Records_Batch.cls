/******************************************************************   
    Delete_Records_Batch bat = new Delete_Records_Batch();
    bat.query  = 'SELECT Id FROM FCD__c LIMIT 2';
    Database.executeBatch(bat);
*****************************************************************************/
global class Delete_Records_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global String query;
    global String toEmail;
    global Delete_Records_Batch() {
        
    }    

    global Database.QueryLocator start(Database.BatchableContext BC) {  
        system.debug('>>>soql ' + query);
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
        system.debug('>>>size ' + scope.size());
        delete scope;
    }
    global void finish(Database.BatchableContext BC) {
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,  
                          TotalJobItems, CreatedBy.Email, ExtendedStatus  
                          from AsyncApexJob where Id = :BC.getJobId()];

        if(!String.isBlank(toEmail)) {
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        	string[] toAddress = new String[]{toEmail};
        	email.setSubject('Delete_Records_Batch Status: ' + a.Status);
        	email.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +' batches with '+ a.NumberOfErrors + ' failures. ExtendedStatus: ' + a.ExtendedStatus);   
        	email.setToAddresses(toaddress);
	      	Messaging.sendEmail(New Messaging.SingleEmailMessage[]{email});
        } 
    }
    
}