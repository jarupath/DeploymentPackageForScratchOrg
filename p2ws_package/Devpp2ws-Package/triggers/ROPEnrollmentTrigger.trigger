trigger ROPEnrollmentTrigger on ROP_Enrollment__c (after update) {
    
    ROPEnrollmentService.sendEmailNotifyVoidedROPEnrollment(Trigger.oldMap, Trigger.new);
}