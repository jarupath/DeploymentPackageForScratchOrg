@isTest
private class BE8_RecordTypeRepository_Test {
    @isTest static void testRetrieveAllAccountRecordType() {
        Map<Id, RecordType> recordTypeMap1 = BE8_RecordTypeRepository.getInstance().getRecordType('Account', '');

        Integer expectNumberOfQuery = Limits.getQueries();
        Map<Id, RecordType> recordTypeMap2 = BE8_RecordTypeRepository.getInstance().getRecordType('Account', '');
        Integer actualNumberOfQuery = Limits.getQueries();

        System.assertEquals(recordTypeMap1, recordTypeMap2);
        System.assertEquals(expectNumberOfQuery, actualNumberOfQuery);
    }
    
    @isTest static void testRetrieveIndividualAccountRecordType() {
        Map<Id, RecordType> recordTypeMap1 = BE8_RecordTypeRepository.getInstance().getRecordType('Account', 'Individual');

        Integer expectNumberOfQuery = Limits.getQueries();
        Map<Id, RecordType> recordTypeMap2 = BE8_RecordTypeRepository.getInstance().getRecordType('Account', 'Individual');
        Integer actualNumberOfQuery = Limits.getQueries();

        List<RecordType> actualRecordTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName LIKE '%Individual%'];

        System.assertEquals(recordTypeMap1, recordTypeMap2);
        System.assertEquals(expectNumberOfQuery, actualNumberOfQuery);
        System.assertEquals(actualRecordTypeList.size(), recordTypeMap1.size());
    }

    //@isTest static void testRetrieveRecordTypeIdMapByDevName() {
    //    Map<String, Id> recordTypeIdMap1 = BE8_RecordTypeRepository.getInstance().getRecordTypeIdMapByDevName('Account');
    //    Integer expectNumberOfQuery = Limits.getQueries();
    //    Map<String, Id> recordTypeIdMap2 = BE8_RecordTypeRepository.getInstance().getRecordTypeIdMapByDevName('Account');
    //    Map<Id, RecordType> recordTypeMap = BE8_RecordTypeRepository.getInstance().getRecordType('Account', '');
    //    Integer actualNumberOfQuery = Limits.getQueries();

    //    List<RecordType> actualRecordTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Account'];

    //    System.assertEquals(recordTypeIdMap1, recordTypeIdMap2);
    //    System.assertEquals(expectNumberOfQuery, actualNumberOfQuery);
    //    System.assertEquals(actualRecordTypeList.size(), recordTypeIdMap1.size());

    //    for(Id recordTypeId : recordTypeMap.keySet()) {
    //        String developerName = recordTypeMap.get(recordTypeId).DeveloperName;
    //        System.assertEquals(recordTypeId, recordTypeIdMap1.get(developerName));
    //    }
    //}
}