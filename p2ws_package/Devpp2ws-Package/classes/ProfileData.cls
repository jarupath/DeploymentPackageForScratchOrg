public with sharing class ProfileData {
    private static ProfileData instance = null;
    private Map<String, Profile> profileMapByName;
    private Map<Id, Profile> profileMapById;

    public ProfileData() {
        profileMapByName = new Map<String, Profile>();
        profileMapById = new Map<Id, Profile>();
    }

    public Profile getProfileByName(String profileName) {
    	if(profileMapByName.isEmpty()) {
            setupData();
        }
        if(profileMapByName.containsKey(profileName)) {
        	return profileMapByName.get(profileName);
        }
        return null;
    }

    public Map<String, Profile> getProfileMapByName() {
        if(profileMapByName.isEmpty()) {
            setupData();
        }
        return profileMapByName;
    }

    public Map<Id, Profile> getProfileMap() {
        if(profileMapById.isEmpty()) {
            setupData();
        }
        return profileMapById;
    }

    public void setupData() {
        String queryAllProfile = 'SELECT Id, Name FROM Profile';
        Map<Id, sObject> sObjectMap = BE8_CacheQuery.getInstance().query('All_Profile', queryAllProfile);
        profileMapById.clear();
        profileMapByName.clear();
        for(Id profileId : sObjectMap.keySet()) {
            Profile eachProfile = (Profile)sObjectMap.get(profileId);
            profileMapById.put(profileId, eachProfile);
            profileMapByName.put(eachProfile.Name, eachProfile);
        }
    }

    public static ProfileData getInstance() {
        if(instance == null) instance = new ProfileData();
        return instance;
    }
}