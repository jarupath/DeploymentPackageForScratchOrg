public class Approval_Result_Templete_Controller {
	
	private final List<Compensation__c> listcomp;
	public List<ProcessInstanceStep> ProcessInstanceSteps;
	public String parametersid {get;set;}
	public ProcessInstanceStep processistep {get;set;}
 
 	public Approval_Result_Templete_Controller() {
		ProcessInstanceStep processistep = new ProcessInstanceStep();
		id appid = Apexpages.Currentpage().getParameters().get('id');
		
		list<ProcessInstanceWorkitem> listProcessInstanceworkitem = [SELECT Id,ProcessInstance.targetobjectid
															 FROM ProcessInstanceWorkitem 
															 where id =: appid];
		
		if(listProcessInstanceworkitem.size() > 0){

			listcomp = [select Compensation_Type__c, Compensation_Tools__c, Status__c, 
						   Total__c, Amount__c, Unit__c, Currency__c, Total_THB__c
				    	from Compensation__c 
				    	where Caseid__c =: listProcessInstanceworkitem.get(0).ProcessInstance.targetobjectid];
				    	
			processistep = [Select id,Comments from ProcessInstanceStep where ProcessInstanceId =: listProcessInstanceworkitem.get(0).ProcessInstanceid limit 1];		    	

		}

	}
 	
	public List<ProcessInstanceStep> getApprovalComments(){ 
		return ProcessInstanceSteps; 
	}
	
	public List<Compensation__c> getCompensations() {
		return listcomp;
	}
}