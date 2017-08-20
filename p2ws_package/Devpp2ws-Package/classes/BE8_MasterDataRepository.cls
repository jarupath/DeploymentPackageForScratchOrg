public with sharing class BE8_MasterDataRepository {
	private static BE8_MasterDataRepository instance = null;
	private Map<String, BE8_MasterData> masterDataMap = new Map<String, BE8_MasterData>();
	public BE8_MasterDataRepository() {
		
	}

	public SObject getObjectByName(String masterDataName, String objectName) {
		if(!masterDataMap.containsKey(masterDataName)) {
			BE8_MasterData masterData = new BE8_MasterData(masterDataName);
			masterDataMap.put(masterDataName, masterData);
		}

		if(masterDataMap.containsKey(masterDataName)) {
			BE8_MasterData masterData = masterDataMap.get(masterDataName);
			return masterData.getObjectByName(objectName);
		}

		return null;
	}

	public static BE8_MasterDataRepository getInstance() {
		if(instance == null) instance = new BE8_MasterDataRepository();
		return instance;
	}
}