public abstract without sharing class Record_Managable {

	public Map<String, Database.SaveResult[]> InsertReocords(List<SObject> records){
		Map<String, Database.SaveResult[]> returnMap = null;
		if(records != null && !records.isEmpty()){
			Database.SaveResult[] results = Database.insert(records, false);
			for(Database.SaveResult result : results){
				if(returnMap == null) returnMap = new Map<String, Database.SaveResult[]>();
			}	
		}
		
		return null;
	}
	//Map<String, Database.SaveResult[]> UpdateRecord(List<SObject> records);
	//Map<String, Database.UpsertResult[]> UpsertRecords(List<SObject> records, String key);
	//Map<String, Database.DeleteResult[]> DeleteRecords(List<SObject> records);

}