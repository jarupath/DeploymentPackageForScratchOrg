trigger Task_Trigger on Task (after insert, after update, before insert, before update) {

    public string FUTUREFLIGHT = 'Future Flight';

    if (TriggerActivator.isTriggerActivated(TriggerActivator.TASK_TRIGGER)) {
        list<task> listtask = new list<task>();

        for (Task thistask : Trigger.new) {
            if (Trigger.Isinsert) {

                if (Trigger.Isafter) {

                } else {
                    if (thistask.To_Investigation_Staff__c == null)
                        listtask.add(thistask);
                    if(thistask.Task_Type__c != FUTUREFLIGHT){
                        thistask.ActivityDate = system.Today().adddays(10);
                        thistask.ReminderDateTime = system.Today().adddays(10);
                    }
                }
            }
            // Is update
            else {
                Task oldtask = trigger.oldmap.get(thistask.Id);

                if (Trigger.Isafter) {

                } else {
                    if (thistask.Investigation_Category__c != oldtask.Investigation_Category__c) {
                        listtask.add(thistask);
                    }
                }
            }
        }

        if (listtask.size() > 0) {
            Task_Management.findinvestigationstaff(listtask);
        }
    }
}