@isTest
private class MB_RESTCrewIMGService_Test {
	@testSetup static void MockupData(){
		List<Flight__c> flightList = new List<Flight__c>();
		List<Crew_List__c> crewList = new List<Crew_List__c>();
		List<Document> documentList = new List<Document>();

		//Initiate Flight
		Flight__c flight1 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    STD_UTC__c = '20Dec25 0330',
		    STD_LT__c  = '20Dec25 1030',
		    STA_UTC__c = '20Dec25 0620',
		    STA_LT__c = '20Dec25 1420',
		    Block_Time__c = '170',
		    Integration_Source__c = '1',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_1');
		flightList.add(flight1);

		Flight__c flight2 = new Flight__c(
			Name = '0628',
		    Flight_Number__c = 'TG0628',
		    Flight_Date_UTC__c = '20Dec25',
		    Flight_Date_LT__c = '20Dec25',
		    STD_UTC__c = '20Dec25 0650',
		    STD_LT__c  = '20Dec25 1450',
		    STA_UTC__c = '20Dec25 0940',
		    STA_LT__c = '20Dec25 1730',
		    Block_Time__c = '170',
		    Integration_Source__c = '2',
		    Leg_Number__c = 1,
		    Flight_External_ID__c = 'TG0628_20Dec25_2');
		flightList.add(flight2);

		insert flightList;
		Set<Id> flightIdSet = new Set<Id>{flight1.Id, flight2.Id};
		//System.debug('Test Method Flight: ' + [SELECT Id, Name, STD_UTC_DateTime__c, STA_UTC_DateTime__c, Landed__c FROM Flight__c WHERE Id IN :flightIdSet]);

		//Initiate Crew List
		Crew_List__c crew1 = new Crew_List__c(
			Name = 'Temp Crew1',
		    Flight_Temp__c = 'TG0628_20Dec25_1',
		    //FlightId__c = flight1.Id,
		    Crew_Temp__c = '01231',
		    Crew_External_ID__c = '01231_TG0628_20Dec25_1',
		    Acting_Rank__c = 'FC',
		    Rank__c = 'FC');
		crewList.add(crew1);

		Crew_List__c crew2 = new Crew_List__c(
			Name = 'Temp Crew2',
		    Flight_Temp__c = 'TG0628_20Dec25_1',
		    //FlightId__c = flight1.Id,
		    Crew_Temp__c = '01232',
		    Crew_External_ID__c = '01232_TG0628_20Dec25_1',
		    Acting_Rank__c = 'AP',
		    Rank__c = 'AP');
		crewList.add(crew2);

		Crew_List__c crew3 = new Crew_List__c(
			Name = 'Temp Crew1',
		    Flight_Temp__c = 'TG0628_20Dec25_2',
		    //FlightId__c = flight2.Id,
		    Crew_Temp__c = '01231',
		    Crew_External_ID__c = '01233_TG0628_20Dec25_2',
		    Acting_Rank__c = 'FC',
		    Rank__c = 'FC');
		crewList.add(crew3);

		Crew_List__c crew4 = new Crew_List__c(
			Name = 'Temp Crew2',
		    Flight_Temp__c = 'TG0628_20Dec25_2',
		    //FlightId__c = flight2.Id,
		    Crew_Temp__c = '01232',
		    Crew_External_ID__c = '01234_TG0628_20Dec25_2',
		    Acting_Rank__c = 'AP',
		    Rank__c = 'AP');
		crewList.add(crew4);

		insert crewList;

		//initiate crew image (Document)
		List<Folder> folderList = [SELECT Id FROM Folder WHERE Name = 'Shared Documents' LIMIT 1];
		Document doc1 = new Document(
			Name = '01231',
			FolderId = folderList.get(0).Id,
			ContentType = 'Text',
			Body = EncodingUtil.base64Decode('Temp Crew1 IMG'));
		documentList.add(doc1);

		Document doc2 = new Document(
			Name = '01232',
			FolderId = folderList.get(0).Id,
			ContentType = 'Text',
			Body = EncodingUtil.base64Decode('Temp Crew2 IMG'));
		documentList.add(doc2);

		insert documentList;
		//Initiate Crew Mapping
		List<Crew_List__c> crew = [SELECT Id, CrewId__c FROM Crew_List__c WHERE Name = 'Temp Crew2' LIMIT 1];
		Crew_Mapping__c crewMap = new Crew_Mapping__c(
			UserId__c = UserInfo.getUserId(),
			CrewId__c = crew.get(0).CrewId__c);
		insert crewMap;

		List<Crew_Mapping__c> crewMapList = [SELECT Id, UserId__c, CrewId__c FROM Crew_Mapping__c WHERE UserId__c = :UserInfo.getUserId()];
		System.debug('Crew Mapping: ' + crewMapList.get(0));
		System.debug('Test Method Flight: ' + [SELECT Id, Name, STD_UTC_DateTime__c, STA_UTC_DateTime__c, Landed__c FROM Flight__c WHERE Id IN :flightIdSet]);
		System.debug('Test Method get CrewList: ' + [SELECT Id, FlightId__c FROM Crew_List__c WHERE (CrewId__c = :crewMapList.get(0).Id AND FlightId__r.Landed__c = FALSE AND FlightId__r.STD_UTC_DateTime__c != NULL AND FlightId__r.STA_UTC_DateTime__c != NULL) ORDER BY FlightId__r.STD_UTC_DateTime__c ASC LIMIT 2]);
		List<Crew_List__c> crewList2 = [SELECT Id, FlightId__c, FlightId__r.Name, CrewId__c FROM Crew_List__c];
		Set<String> flightSet = BE8_GlobalUtility.getStringSet('FlightId__c', crewList2);
		System.debug('Test Method flight from crewlist: ' + [SELECT Id, Name, STD_UTC_DateTime__c, STA_UTC_DateTime__c, Landed__c FROM Flight__c WHERE Id IN :flightSet]);
		System.debug('Test Method get all crew list' + crewList);


		//Set<Id> flightIdSet = new Set<Id>{flight1.Id, flight2.Id};
		List<Crew_List__c> crewlistList = [SELECT Id, Personnel_ID__c FROM Crew_List__c WHERE FlightId__c in :flightIdSet];
		Set<String> crewlistSet = BE8_GlobalUtility.getStringSet('Personnel_ID__c', crewlistList);
		System.debug([SELECT Id, Name, body FROM Document WHERE Name in :crewlistSet]);
	}

	@isTest static void testHTTPGETShouldReturnAllCrewImageFor2Flight() {
		List<MB_RESTRequestInfoModel.crewImage> returnList = MB_RESTCrewIMGService.doGet();
		System.debug('Return List: ' + returnList);
		System.assertEquals(2, returnList.size(), 'return list size should be equal to 2 according to the number of crew list on flight');
	}
}