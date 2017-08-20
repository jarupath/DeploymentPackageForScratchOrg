public with sharing class BE8_CacheQuery {

    private static BE8_CacheQuery instance = null;

    Map<String, Map<Id, sObject>> cacheMapByKey;
    static Map<String, Map<Id, sObject>> staticCacheMapByKey;

    public BE8_CacheQuery() {
        System.debug('Constuctor');
        cacheMapByKey = new Map<String, Map<Id, sObject>>();
    }

    public static Map<Id, sObject> staticQuery(String key, String queryString) {
        key = key.toLowerCase();
        MAp<Id, sObject> objectMap;
        if(staticCacheMapByKey == null) staticCacheMapByKey = new Map<String, Map<Id, sObject>>();

        if(staticCacheMapByKey.containsKey(key)) {
            objectMap = staticCacheMapByKey.get(key);
        } else {
            objectMap = new Map<Id, sObject>(Database.query(queryString));
            staticCacheMapByKey.put(key, objectMap);
        }
        return objectMap;
    }


    public static BE8_CacheQuery getInstance() {
        if(instance == null) instance = new BE8_CacheQuery();
        return instance;
    }

    public Map<Id, sObject> forceQuery(String key, String queryString) {
        key = key.toLowerCase();
        Map<Id, sObject> objectMap = new Map<Id, sObject>(Database.query(queryString));
        cacheMapByKey.put(key, objectMap);
        return objectMap;
    }

    public Map<Id, sObject> query(String key, String queryString) {
        key = key.toLowerCase();
        MAp<Id, sObject> objectMap;
        if(cacheMapByKey.containsKey(key)) {
            objectMap = cacheMapByKey.get(key);
        } else {
            objectMap = new Map<Id, sObject>(Database.query(queryString));
            cacheMapByKey.put(key, objectMap);
        }
        return objectMap;
    }

    public Map<Id, sObject> query(String key, String objectName, Set<String> fieldset) {
        key = key.toLowerCase();
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder(objectName, fieldset);
        return query(key, soql.getQueryStr());
    }

    public Map<Id, sObject> query(String key, String objectName, Set<String> fieldset, String condition) {
        key = key.toLowerCase();
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder(objectName, fieldset);
        soql.addCondition(condition);
        return query(key, soql.getQueryStr());
    }
}