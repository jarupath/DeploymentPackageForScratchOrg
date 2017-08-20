@isTest
private class MB_RESTeDocumentService_Test {
	@testSetup static void MockData(){
		List<Master_Map__c> mapList = new List<Master_Map__c>();
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
		    Flight_External_ID__c = 'TG0628_20Dec25_1',
		    Destination__c = 'ICN',
		    Departure_STN__c = 'BKK',
		    Aircraft_Type__c = '33H');
		insert flight1;

		Crew_List__c crew2 = new Crew_List__c(
			Name = 'Temp Crew2',
		    Flight_Temp__c = 'TG0628_20Dec25_1',
		    //FlightId__c = flight1.Id,
		    Crew_Temp__c = '01232',
		    Crew_External_ID__c = '01232_TG0628_20Dec25_1',
		    Acting_Rank__c = 'AP',
		    Rank__c = 'AP');
		insert crew2;

		List<Crew_List__c> crew = [SELECT Id, CrewId__c FROM Crew_List__c WHERE Name = 'Temp Crew2' LIMIT 1];
		Crew_Mapping__c crewMap = new Crew_Mapping__c(
			UserId__c = UserInfo.getUserId(),
			CrewId__c = crew.get(0).CrewId__c);
		insert crewMap;

		//Mock Master Map
		Master_Map__c map1 = new Master_Map__c(
			Name = 'eRouteFolder/Manual/',
			Location__c = 'Manual',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map2 = new Master_Map__c(
			Name = 'eRouteFolder/Function Info/',
			Location__c = 'Function Info',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map3 = new Master_Map__c(
			Name = 'eRouteFolder/Service/',
			Location__c = 'Service',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map4 = new Master_Map__c(
			Name = 'eRouteFolder/Safety/',
			Location__c = 'Safety',
			Field_Name__c = 'E-Document'
			);

		Master_Map__c map5 = new Master_Map__c(
			Name = 'eRouteFolder/service/MLP/Crew Meal/',
			Location__c = 'Crew Meal',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map6 = new Master_Map__c(
			Name = 'eRouteFolder/service/CAC/',
			Location__c = 'CAC',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map7 = new Master_Map__c(
			Name = 'eRouteFolder/service/IDF/IDF Page/IDF Page_tabstrip.htm',
			Location__c = 'IDF',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map8 = new Master_Map__c(
			Name = 'eRouteFolder/service/AAC/',
			Location__c = 'AAC',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map9 = new Master_Map__c(
			Name = 'eRouteFolder/Manual/CrewProcedure/',
			Location__c = 'Crew Procedure',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map10 = new Master_Map__c(
			Name = 'eRouteFolder/service/working routine/',
			Location__c = 'Working Routine',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map11 = new Master_Map__c(
			Name = 'eRouteFolder/service/Route Specialities/',
			Location__c = 'Route Specialities',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map12 = new Master_Map__c(
			Name = 'eRouteFolder/Manual/Minimum_Validity_of_Thai_PPT_2013.pdf',
			Location__c = 'Validity of Passport',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map13 = new Master_Map__c(
			Name = 'eRouteFolder/service/MLP/',
			Location__c = 'MLP',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map14 = new Master_Map__c(
			Name = 'eRouteFolder/service/LLP/',
			Location__c = 'LLP',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map15 = new Master_Map__c(
			Name = 'eRouteFolder/service/Standard Load/',
			Location__c = 'Standard Load',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map16 = new Master_Map__c(
			Name = 'eRouteFolder/service/LLP/AlcoholicDrinksTGFlights.pdf',
			Location__c = 'Alcoholic on board',
			Field_Name__c = 'E-Document'
			);
		Master_Map__c map17 = new Master_Map__c(
			Name = 'eRouteFolder/service/CEC/',
			Location__c = 'CEC',
			Field_Name__c = 'E-Document'
			);
		mapList.add(map1);
		mapList.add(map2);
		mapList.add(map3);
		mapList.add(map4);
		mapList.add(map5);
		mapList.add(map6);
		mapList.add(map7);
		mapList.add(map8);
		mapList.add(map9);
		mapList.add(map10);
		mapList.add(map11);
		mapList.add(map12);
		mapList.add(map13);
		mapList.add(map14);
		mapList.add(map15);
		mapList.add(map16);
		mapList.add(map17);

		insert mapList;
	}

	@isTest static void testHTTPGETForEdocument() {
		List<MB_RESTRequestInfoModel.allDoc> edoclist = MB_RESTeDocumentService.doGet();
		Integer loopCount = 1;
		System.assertNotEquals(0, edoclist.size(), 'Size of Return List should not be zero');
		for(MB_RESTRequestInfoModel.allDoc edoc : edoclist){	
			System.debug('---------LOOP Count ' + loopCount + '--------');
			System.debug('Flight Id: ' + edoc.flightId);
			System.debug('Manual: ' + edoc.manual);
			System.debug('Function Info: ' + edoc.functionInfo);
			System.debug('Safety: ' + edoc.safety);
			System.debug('Service: ' + edoc.service);
			for(MB_RESTRequestInfoModel.dynamicLink link : edoc.dynamicLinkList){
				System.debug('--------DYNAMIC LINK--------');
				System.debug('Link Name: ' + link.name);
				System.debug('Link Path: ' + link.link);
				System.debug('Link Multi Flag: ' + link.multiFlag);
				System.debug('Link Start With: ' + link.startWith);
			}
		}

	}
}