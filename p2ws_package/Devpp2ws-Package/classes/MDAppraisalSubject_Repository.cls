public with sharing class MDAppraisalSubject_Repository {
	private static MDAppraisalSubject_Repository instance = null;
	private Map<String, MD_Appraisal_Subject__c> subjectMap = new Map<String, MD_Appraisal_Subject__c>();
	public MDAppraisalSubject_Repository() {

	}

	public static Map<String, MD_Appraisal_Subject__c> getSubjectMapByKey() {
		if (getInstance().subjectMap.isEmpty()) {
			for (MD_Appraisal_Subject__c subject : [SELECT Id, Name, MD_Appraisal_Form__r.Name, MD_Appraisal_Subject_External_ID__c, Type__c FROM MD_Appraisal_Subject__c]) {
				getInstance().subjectMap.put(subject.MD_Appraisal_Form__r.Name + subject.Name, subject);
			}
		}
		return getInstance().subjectMap;
	}

	public static MDAppraisalSubject_Repository getInstance() {
		if (instance == null) instance = new MDAppraisalSubject_Repository();
		return instance;
	}
}