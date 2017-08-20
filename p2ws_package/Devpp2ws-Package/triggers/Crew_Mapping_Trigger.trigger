trigger Crew_Mapping_Trigger on Crew_Mapping__c (after insert, after update) {
	List<Crew_Mapping__c> crewmapList = Trigger.new;
	if(Trigger.isInsert || Trigger.isUpdate){
		Crew_Mapping_Management.addCrewToChatter(crewmapList);
	}
}