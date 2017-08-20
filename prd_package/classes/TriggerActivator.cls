public with sharing class TriggerActivator {

	static {
		if(Test.isRunningTest()) {
			initializeTriggerActivation(true);
		}
	}

	public static void initializeTriggerActivation(Boolean active){
		Trigger_Activation__c act = Trigger_Activation__c.getOrgDefaults();
		act.Job_Queue_Scheduler__c = active;
		act.Job_Queue_Trigger__c = active;
		act.Case_Trigger__c = active;
		act.Case_Group_Member_Trigger__c = active;
		act.Compensation_Trigger__c = active;
		act.Crew_List_Trigger__c = active;
		act.CTI_Trigger__c = active;
		act.Email_Trigger__c = active;
		act.Flight_Trigger__c = active;
		act.Passenger_Trigger__c = active;
		act.Task_Trigger__c = active;
		act.TempPassenger_Trigger__c = active;
		upsert act;
		//insert act;	
		
	}

	public static String CASE_TRIGGER = 'Case_Trigger__c';
	public static String CASE_GROUP_MEMBER_TRIGGER = 'Case_Group_Member_Trigger__c';
	public static String COMPENSATION_TRIGGER = 'Compensation_Trigger__c';
	public static String CREW_LIST_TRIGGER = 'Crew_List_Trigger__c';
	public static String CTI_TRIGGER = 'CTI_Trigger__c';
	public static String EMAIL_TRIGGER = 'Email_Trigger__c';
	public static String FLIGHT_TRIGGER = 'Flight_Trigger__c';
	public static String PASSENGER_TRIGGER = 'Passenger_Trigger__c';
	public static String TASK_TRIGGER = 'Task_Trigger__c';
	public static String TEMPPASSENGER_TRIGGER = 'TempPassenger_Trigger__c';


	public static Trigger_Activation__c triggerActivation = Trigger_Activation__c.getInstance();
	
	public static void overrideTriggerActivation(String triggerName, Boolean state){
		triggerActivation.put(triggerName, state);
	}

	public static Boolean isTriggerActivated(String triggerName){
		return (Boolean) triggerActivation.get(triggerName);
	}

}