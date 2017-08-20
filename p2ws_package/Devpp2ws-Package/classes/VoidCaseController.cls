global with sharing class VoidCaseController {

    public Case voidCase{get; set;}
    public String returl{get; set;}
    public String topurl{get; set;}
    public Id caseId{get; set;}
    public String seqNo{get; set;}
    public String fieldSetString{get; set;}

    public VoidCaseController() {
        caseId = Apexpages.currentpage().getparameters().get('id');
        voidCase = [SELECT Subject, Void_Time__c, Description, Void_Flag__c, Void_AUTH_NO__c, Void_Block_Name__c, Void_Reason__c, SEQ_No_Display__c FROM Case WHERE Id = :caseId];
        seqNo = voidCase.SEQ_No_Display__c;
        returl = Apexpages.Currentpage().getParameters().get('ret');
        topurl = Apexpages.Currentpage().getParameters().get('top');
        fieldSetString = JSON.serialize(Schema.SObjectType.Case.fieldSets.getMap().get('Void_Case').getFields());
    }

    @RemoteAction
    global static Case saveCase(Case inputCase, String voidCase){
        inputCase.Void_Time__c = System.now();
        inputCase.Description = voidCase != null ? voidCase + '\n\n' + inputCase.Void_AUTH_NO__c + ' ' + inputCase.Void_Block_Name__c + ' ' + inputCase.Void_Time__c  + ' \n' + inputCase.Void_Reason__c : inputCase.Void_AUTH_NO__c + ' ' + inputCase.Void_Block_Name__c + ' ' + inputCase.Void_Time__c  + ' \n' + inputCase.Void_Reason__c;
        inputCase.Void_Flag__c = true;
        update inputCase;
        return inputCase;
    }
}