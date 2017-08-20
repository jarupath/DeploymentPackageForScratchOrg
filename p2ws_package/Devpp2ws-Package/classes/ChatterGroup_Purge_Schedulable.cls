global class ChatterGroup_Purge_Schedulable implements Schedulable {

	public ChatterGroup_Purge_Schedulable() {

	}

    global void execute(SchedulableContext sc) {
    	DateTime dtnow = System.now();
    	dtnow = dtnow.addHours(-24);
		//delete [SELECT Id,Name, CreatedDate From CollaborationGroup WHERE CreatedDate != LAST_N_DAYS:1 ORDER BY CreatedDate ASC LIMIT 10000];
		List<CollaborationGroup> groups = [SELECT Id,Name, CreatedDate From CollaborationGroup WHERE CreatedDate < :dtnow AND CollaborationType = 'Private' AND Name Like 'TG%' ORDER BY CreatedDate ASC LIMIT 10000];
		List<CollaborationGroup> groupIdsForDelete = new List<CollaborationGroup>();
		for(CollaborationGroup eachGroup : groups) {
			if(eachGroup.Name.length() == 17 || eachGroup.Name.length() == 18) {
				groupIdsForDelete.add(eachGroup);
			}
		}
		if(!groupIdsForDelete.isEmpty()) {
			Database.delete(groupIdsForDelete, false);
		}
	}
}