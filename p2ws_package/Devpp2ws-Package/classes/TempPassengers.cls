public class TempPassengers extends ApplicationDomain {
	public TempPassengers(List<TempPassenger__c> tempPassengers) {
		super(tempPassengers);
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords){
		
	}


}