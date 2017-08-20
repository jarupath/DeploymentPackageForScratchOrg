@RestResource(urlMapping = '/topcase/*')
global without sharing class MB_RESTTopCaseInFlight {

	global class TopCase {
		public String issueType;
		public String type;
		public Decimal total;
		public String flightNumber;
		public String tClass;
	}

	@HttpGet
	global static List<TopCase> getTopCase() {
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(UserInfo.getUserId());
		Map<Id, Flight__c> flightMap = new Map<Id, Flight__c>([SELECT Id, Flight_Number__c FROM Flight__c WHERE Id IN :flightIdSet]);
		Set<String> flightNumberSet = BE8_GlobalUtility.getStringSet('Flight_Number__c', flightMap.values());
		Set<String> caseTypeSet = new Set<String> {'Commendation', 'Complaint'};
		List<AggregateResult> ctiList = [SELECT COUNT(Id) Total, Type_of_Issue__c, Type__c, Accepted_Class__c, FlightId__r.Flight_Number__c  FROM CTI__c WHERE Type_of_Issue__c IN: caseTypeSet AND FlightId__r.Flight_Number__c IN: flightNumberSet AND CreatedDate = LAST_N_DAYS:30 GROUP BY Type_of_Issue__c, Type__c, Accepted_Class__c, FlightId__r.Flight_Number__c ORDER BY COUNT(Id) DESC];
		List<TopCase> topCaseList = new List<TopCase>();
		for (AggregateResult eachCTI : ctiList) {
			TopCase topCase = new TopCase();
			topCase.issueType = (String) eachCTI.get('Type_of_Issue__c');
			topCase.type = (String) eachCTI.get('Type__c');
			topCase.total = (Decimal) eachCTI.get('Total');
			topCase.flightNumber = (String) eachCTI.get('Flight_Number__c');
			topCase.tClass = (String) eachCTI.get('Accepted_Class__c');
			topCaseList.add(topCase);
		}
		return topCaseList;
	}
}