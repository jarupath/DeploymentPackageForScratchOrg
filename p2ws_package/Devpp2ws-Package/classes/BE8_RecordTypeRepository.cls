public with sharing class BE8_RecordTypeRepository {
    private static BE8_RecordTypeRepository instance = null;
    private Map<String, Map<String, RecordType>> recordTypeMapByDevName;
    private Map<String, Map<Id, RecordType>> recordTypeMapById;

    public BE8_RecordTypeRepository() {
        recordTypeMapByDevName = new Map<String, Map<String, RecordType>>();
        recordTypeMapById = new Map<String, Map<Id, RecordType>>();
    }

    public Map<String, RecordType> getRecordTypeMapByDevName(String sObjectType) {
        if (!recordTypeMapByDevName.containsKey(sObjectType)) {
            Map<Id, RecordType> recordTypeMap = getRecordType(sObjectType, '');
            Map<String, RecordType> eachRecordTypeMapByDevName = new Map<String, RecordType>();
            for (RecordType eachRecordType : recordTypeMap.values()) {
                eachRecordTypeMapByDevName.put(eachRecordType.DeveloperName, eachRecordType);
            }
            recordTypeMapByDevName.put(sObjectType, eachRecordTypeMapByDevName);
        }
        return recordTypeMapByDevName.get(sObjectType);
    }

    public Map<Id, RecordType> getRecordType(String sObjectType, String filter) {
        String key = filter + '_' + sObjectType;
        if (recordTypeMapById.containsKey(key)) {
            return recordTypeMapById.get(key);
        } else if (recordTypeMapById.containsKey(sObjectType)) {
            if (filter == '' || filter.toLowerCase().equals('all')) {
                return recordTypeMapById.get(sObjectType);
            } else {
                Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>();
                Map<Id, RecordType> allRecordTypeMap = recordTypeMapById.get(sObjectType);
                for (Id recordTypeId : allRecordTypeMap.keySet()) {
                    RecordType recordType = allRecordTypeMap.get(recordTypeId);
                    if (recordType.DeveloperName.containsIgnoreCase(filter)) {
                        recordTypeMap.put(recordTypeId, allRecordTypeMap.get(recordTypeId));
                    }
                }
                recordTypeMapById.put(key, recordTypeMap);
                return recordTypeMap;
            }
        } else {
            String queryAllRecordType = 'SELECT Id, DeveloperName FROM RecordType WHERE sObjectType =\'' + sObjectType + '\'';
            String cacheKey = 'All' + sObjectType + 'RecordType';
            Map<Id, sObject> sObjectMap = BE8_CacheQuery.getInstance().query(cacheKey, queryAllRecordType);
            Map<id, RecordType> recordTypeMap = new Map<Id, RecordType>();
            for (Id recordTypeId : sObjectMap.keySet()) {
                recordTypeMap.put(recordTypeId, (RecordType)sObjectMap.get(recordTypeId));
            }
            recordTypeMapById.put(sObjectType, recordTypeMap);
            return getRecordType(sObjectType, filter);
        }
    }

    public static BE8_RecordTypeRepository getInstance() {
        if (instance == null) instance = new BE8_RecordTypeRepository();
        return instance;
    }
}