public class CrewHandler {
	public static Map<Id, Crew_Mapping__c> mapCrewMappingByCrewId;

	public static Map<Id, Crew_Mapping__c> getMapCrewMappingByCrewId(Set<Id> setCrewId){
		if(mapCrewMappingByCrewId==null){
			setMapCrewMappingByCrewId(setCrewId);
		}
		return mapCrewMappingByCrewId;
	}
	public static Map<Id, Crew_Mapping__c> getMapCrewMappingByCrewId(){
		if(mapCrewMappingByCrewId==null){
			setMapCrewMappingByCrewId();
		}
		return mapCrewMappingByCrewId;
	}
	public static void setMapCrewMappingByCrewId(){
		List<Crew_Mapping__c> listCrewMapping = [Select Id, 
														Name ,
														CrewId__c,
														Last_Sync_Time__c,
														UserId__c
													From Crew_Mapping__c
													Where isActive__c = true ];
		if(mapCrewMappingByCrewId==null)	mapCrewMappingByCrewId = new Map<Id, Crew_Mapping__c>();
		for(Crew_Mapping__c eachCrew :listCrewMapping){
			mapCrewMappingByCrewId.put(eachCrew.CrewId__c, eachCrew);
		}
	}
	public static void setMapCrewMappingByCrewId(Set<Id> setCrewId){
		List<Crew_Mapping__c> listCrewMapping = [Select Id, 
														Name ,
														CrewId__c,
														Last_Sync_Time__c,
														UserId__c
													From Crew_Mapping__c
													Where isActive__c = true 
													and CrewId__c in :setCrewId ];
		if(mapCrewMappingByCrewId==null)	mapCrewMappingByCrewId = new Map<Id, Crew_Mapping__c>();
		for(Crew_Mapping__c eachCrew :listCrewMapping){
			mapCrewMappingByCrewId.put(eachCrew.CrewId__c, eachCrew);
		}
	}

}