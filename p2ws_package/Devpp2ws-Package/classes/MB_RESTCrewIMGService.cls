@RestResource(urlMapping = '/crewimage/*')
global with sharing class MB_RESTCrewIMGService {

	@HttpGet
	global static List<MB_RESTRequestInfoModel.crewImage> doGet(){
		Id userId = UserInfo.getUserId();
		System.debug('In method User Id' + userId);
		Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(userId);
		System.debug('In method Flight Id: ' + flightIdSet);
		System.debug('In method Flight: ' + [SELECT Id, Name FROM Flight__c WHERE Id IN :flightIdSet]);
		List<Crew_List__c> crewlistList = [SELECT Id, Personnel_ID__c FROM Crew_List__c WHERE FlightId__c in :flightIdSet];
		System.debug('In method Crew list: ' + crewlistList);
		Set<String> crewlistSet = BE8_GlobalUtility.getStringSet('Personnel_ID__c', crewlistList);
		List<MB_RESTRequestInfoModel.crewImage> returnCrewImg = new List<MB_RESTRequestInfoModel.crewImage>();
		List<Document> doclist = [SELECT Id, Name, body FROM Document WHERE Name in :crewlistSet];
		System.debug('In method Document: ' + doclist);
		//List<MB_RESTRequestInfoModel.crewImage> crewimgList = new List<MB_RESTRequestInfoModel.crewImage>();
		for(Document doc : doclist){
			MB_RESTRequestInfoModel.crewImage crewimg = new MB_RESTRequestInfoModel.crewImage();
			//crewimg.image = doc.body.toString();
			crewimg.name = doc.Name;
			crewimg.image = EncodingUtil.base64Encode(doc.body);
			returnCrewImg.add(crewimg);
		}
		return returnCrewImg;
	}
	//@HttpGet
	//global static List<MB_RESTRequestInfoModel.crewImage> doGet(){
	//	Id userId = UserInfo.getUserId();
	//	Set<Id> flightIdSet = BE8_GlobalUtility.getFlightIdSetFromUserId(userId);
	//	List<Crew_List__c> crewlistList = [SELECT Id, Personnel_ID__c FROM Crew_List__c WHERE FlightId__c in :flightIdSet];
	//	Set<String> crewlistSet = BE8_GlobalUtility.getStringSet('Personnel_ID__c', crewlistList);
	//	List<MB_RESTRequestInfoModel.crewImage> returnCrewImg = new List<MB_RESTRequestInfoModel.crewImage>();
	//	StaticResource staticResource = [SELECT Id, Name, SystemModStamp, NamespacePrefix FROM StaticResource WHERE Name = 'CrewImgTest'];
	//	for(String crew : crewlistSet){
	//		MB_RESTRequestInfoModel.crewImage crewimg = new MB_RESTRequestInfoModel.crewImage();
	//		String url_file_ref = '/resource/'
 //                   			+ String.valueOf(((DateTime)staticResource.get('SystemModStamp')).getTime())
	//		                    + '/' 
	//		                    + staticResource.get('Name')
	//		                    + '/' + crew + '.jpg';
	//		PageReference pr = new PageReference(url_file_ref);
	//		crewimg.image = EncodingUtil.base64Encode(pr.getContent());
	//		crewimg.name = crew;
	//		returnCrewImg.add(crewimg);
	//	}
	//	return returnCrewImg;
	//} 
}