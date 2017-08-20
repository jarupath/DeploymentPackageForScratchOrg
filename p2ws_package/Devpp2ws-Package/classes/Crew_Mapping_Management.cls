public without sharing class Crew_Mapping_Management {
	public Crew_Mapping_Management() {
		
	}

	public static void addCrewToChatter(Crew_Mapping__c crewmap){
		addCrewToChatter(new List<Crew_Mapping__c>{crewmap});
	}

	public static void addCrewToChatter(List<Crew_Mapping__c> crewmapList){
		Map<String, List<User>> groupToBeAdd = new Map<String, List<User>>();
		Map<String, List<Flight__c>> flightListMap = getFlightListMap(crewmapList);
		Map<String, String> crewmapMap = getCrewmapMap(crewmapList);
		Map<String, Flight__c> listAllFlight = getAllFlightList(flightListMap);
		Map<Id, Boolean> existinggroupMap = isExistingGroup(listAllFlight.values());

		for(String crewId : flightListMap.keySet()){
			for(Flight__c flight : flightListMap.get(crewId)){
				String groupName = flight.Name + '_' + flight.Leg_Number__c;
				if(existinggroupMap.get(flight.Id)){
					User user = new User(Id=crewmapMap.get(crewId));
					if(groupToBeAdd.get(groupName) != null){
						groupToBeAdd.get(groupName).add(user);
					}
					else{
						groupToBeAdd.put(groupName, new List<User>{user});
					}
				}
			}
		}
		ChatterGroupHandler.addMemberToGroup(groupToBeAdd);
	}

	public static Map<Id, Boolean> isExistingGroup(List<Flight__c> flightList){
		Map<Id, Boolean> returnMap = new Map<Id, Boolean>();
		Set<String> flightNameSet = getGroupNameList(flightList);
		List<CollaborationGroup> chatterGroup = [SELECT Id, Name FROM CollaborationGroup WHERE Name IN :flightNameSet];
		System.debug('JK: Chatter group');
		System.debug(JSON.serialize(chatterGroup));
		for(Flight__c flight : flightList){
			Boolean isExist = false;
			String gName = flight.Name + '_' + flight.Leg_Number__c;
			for(CollaborationGroup g : chatterGroup){
				if(g.Name == gName){
					returnMap.put(flight.Id, true);
					isExist = true;
					break;
				}
			}
			if(isExist == false){
				returnMap.put(flight.Id, false);
			}
		}
		return returnMap;
	}

	public static Map<String, List<Flight__c>> getFlightListMap(List<Crew_Mapping__c> crewmapList){
		Map<String, List<SObject>> crewlistMap = getCrewListMap(crewmapList);
		Map<String, List<Flight__c>> returnMap = new Map<String, List<Flight__c>>();
		for(Id crewId : crewlistMap.keySet()){
			for(Crew_List__c crewlist : (List<Crew_List__c>)crewlistMap.get(crewId)){
				Flight__c flight = new Flight__c();
				flight.Id = crewlist.FlightId__c;
				flight.Name = crewlist.FlightId__r.Name;
				flight.Leg_Number__c = crewlist.FlightId__r.Leg_Number__c;
				if(returnMap.get(crewId)!= null){
					returnMap.get(crewId).add(flight);
				}
				else{
					returnMap.put(crewId, new List<Flight__c>{flight});
				}
			}
		}

		return returnMap;
	}

	public static Map<String, List<SObject>> getCrewListMap(List<Crew_Mapping__c> crewmapList){
		Set<Id> crewIdSet = BE8_GlobalUtility.getIdSet('CrewId__c', crewmapList);
		Map<String, List<SObject>> returnMap = BE8_GlobalUtility.getSObjectListMap('CrewId__c', [SELECT Id, CrewId__c, Name, FlightId__c, FlightId__r.Name, FlightId__r.Leg_Number__c FROM Crew_List__c WHERE CrewId__c IN :crewIdSet AND FlightId__r.Landed__c = false AND FlightId__r.STD_UTC_DateTime__c != null AND FlightId__r.STA_UTC_DateTime__c != null]);
		return returnMap;
	}

	public static Set<String> getGroupNameList(List<Flight__c> flightList){
		Set<String> flightNameSet = new Set<String>();
		for(Flight__c flight : flightList){
			flightNameSet.add(flight.Name + '_' + flight.Leg_Number__c);
		}
		return flightNameSet;
	}

	public static Map<String, String> getCrewmapMap(List<Crew_Mapping__c> crewmapList){
		Map<String, String> returnMap = new Map<String, String>();
		for(Crew_Mapping__c crewmap : crewmapList){
			returnMap.put((String)crewmap.CrewId__c, (String)crewmap.UserId__c);
		}

		return returnMap;
	}

	public static Map<String, Flight__c> getAllFlightList(Map<String, List<Flight__c>> flightMap){
		Map<String, Flight__c> returnMap = new Map<String, Flight__c>();
		for(String s : flightMap.keySet()){
			for(Flight__c flight : flightMap.get(s)){
				returnMap.put(flight.Id, flight);
			}
		}

		return returnMap;
	}

}