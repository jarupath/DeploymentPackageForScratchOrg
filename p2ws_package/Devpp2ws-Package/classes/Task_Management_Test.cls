@isTest
private class Task_Management_Test {
	
	@isTest static void testTaskManagement() {
		UserRole uRole = new UserRole(name = 'TEST ROLE');
	    insert uRole;

	    User u1Q1 = new User(Alias = 'User1Q1', Email='User1Q1@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', UserName='User1Q1@testorg.com', userroleid=uRole.Id, 
        ProfileId = UserInfo.getProfileId(), TimeZoneSidKey='America/Los_Angeles');
        insert u1Q1;

        System.runAs(u1q1){

        	Case_Team__c q1 = new Case_Team__c(Queue_ID__c=String.valueof(u1Q1.Id), Active__c=true);
			insert q1;

	        Case_Member__c m1 = new Case_Member__c(Userid__c=u1q1.id, Case_Teamid__c=q1.id, Assigned__c=true,
	        	recordTypeId=BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case_Member__c', 'Investigation_Staff'), Email__c='m1@email.com',
	        	Department__c='Catering', Tier__c='Catering Dept.');
	        insert m1;

	        Case_Member__c m2 = new Case_Member__c(Userid__c=u1q1.id, Case_Teamid__c=q1.id, Assigned__c=true,
	        	recordTypeId=BE8_GlobalUtility.getRecordTypeIdFromSObjectByDevName('Case_Member__c', 'Investigation_Staff'), Email__c='m2@email.com',
	        	Department__c='Catering', Tier__c='Menu Planning Dept.');
	        insert m2;

	        Test.startTest();

	        Task newTask = new Task(Investigation_Department__c='Catering', Investigation_Category__c='Catering Dept.');
	        insert newTask;

	        Task updateTask = [Select To_Investigation_Staff__c from Task where Id=:newTask.Id limit 1];
	        Assert.assertEquals('m1@email.com', updateTask.To_Investigation_Staff__c);

	        newTask.Investigation_Category__c = 'Menu Planning Dept.';
	        update newTask;

	        Task updateTask2 = [Select To_Investigation_Staff__c from Task where Id=:newTask.Id limit 1];
	        Assert.assertEquals('m2@email.com', updateTask2.To_Investigation_Staff__c);

	        Test.stopTest();
        }
	}
	
}