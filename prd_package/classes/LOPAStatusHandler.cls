public interface LOPAStatusHandler {
	String getLOPAPositionStatus(String position, String positionType, Passenger__c matchedPassenger, List<Case_Group_Member__c> matchedCaseList, MB_RestResponseInfoModel.lopaInfo_lopaPos lopaPos);
}