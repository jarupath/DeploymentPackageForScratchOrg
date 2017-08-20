/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description: Test Class Common SOQL Builder.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
28/09/2016  Charnun.T          First Create
------------------------------------------------------------*/
@isTest
private class BE8_SoqlBuilder_Test {
    
    @isTest static void test() {    
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account', new Set<String>{'Id'});
        String queryStr = soql.addCondition('FieldA','ValueA').addCondition('FieldB','ValueB').setCondition('OR').getQueryStr();
        System.assertEquals('SELECT Id FROM Account WHERE FieldA = \'ValueA\' OR FieldB = \'ValueB\'',queryStr);
    }

    @isTest static void testAddFieldBySet() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account');
        Set<String> fieldSet = new Set<String>{'Id', 'Name'};
        String queryStr = soql.addField(fieldSet).getQueryStr();
        System.assertEquals('SELECT Id,Name FROM Account', queryStr);
    }

    @isTest static void testConditionNotIn() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account', new Set<String>{'Id'});
        Set<String> fieldSet = new Set<String>{'Name'};
        String queryStr = soql.addConditionNotIn('Name', fieldSet).getQueryStr();
        System.assertEquals('SELECT Id FROM Account WHERE Name NOT IN (\'Name\')', queryStr);
    }

    @isTest static void testConditionNotInObject() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('User', new Set<String>{'Id','Name'});
        Set<Object> fieldSet = new Set<Object>{'Account'};
        String queryStr = soql.addConditionNotIn('Id', fieldSet).getQueryStr();
        System.assertEquals('SELECT Id,Name FROM User WHERE Id NOT IN (\'Account\')', queryStr);
    }

    @isTest static void testConditionNotInWithId() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('User', new Set<String>{'Id'});
        String queryStr = soql.addConditionNotIn('Id', new Set<Id>{UserInfo.getUserId()}).getQueryStr();
        System.assertEquals('SELECT Id FROM User WHERE Id NOT IN (\''+UserInfo.getUserId()+'\')', queryStr);
    }

    @isTest static void testConditionLike() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('User', new Set<String>{'Id'});
        Set<String> fieldSet = new Set<String>{'A%','B%'};
        String queryStr = soql.addConditionLike('Name', fieldSet).getQueryStr();
        System.assertEquals('SELECT Id FROM User WHERE (Name LIKE \'A%\' OR Name LIKE \'B%\')', queryStr);
    }

    @isTest static void testConditionIn() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account', new Set<String>{'Id'});
        Set<String> fieldSet = new Set<String>{'Name'};
        String queryStr = soql.addCondition('Name',fieldSet).getQueryStr();
        System.assertEquals('SELECT Id FROM Account WHERE Name IN (\'Name\')', queryStr);
    }

    @isTest static void testConditionInObject() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account', new Set<String>{'Id'});
        Set<Object> fieldSet = new Set<Object>{'Name'};
        String queryStr = soql.addCondition('Name',fieldSet).getQueryStr();
        System.assertEquals('SELECT Id FROM Account WHERE Name IN (\'Name\')', queryStr);
    }

    @isTest static void testConditionInSet() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account', new Set<String>{'Id'});
        Set<Id> fieldSet = new Set<Id>{UserInfo.getUserId()};
        String queryStr = soql.addCondition('Id',fieldSet).getQueryStr();
        System.assertEquals('SELECT Id FROM Account WHERE Id IN (\''+UserInfo.getUserId()+'\')', queryStr);
    }

    @isTest static void testOneCondition() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('User');
        String queryStr = soql.addField('Id').addCondition('IsActive', true).getQueryStr();
        System.assertEquals('SELECT Id FROM User WHERE IsActive = true', queryStr);

        soql.clearCondition();
        System.assertEquals(false, soql.hasCondition());

    }

    @isTest static void testQuery() {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id FROM User]);
        Set<String> userIdSetForQuery = new Set<String>();
        Integer expectNumber = 2;
        Integer index = 0;
        for(Id userId : userMap.keySet()) {
            index++;
            userIdSetForQuery.add(userId);
            if(expectNumber == index) {
                break;
            }
        }

        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('User');
        String queryStr = soql.addField('Id').addCondition('Id', userIdSetForQuery).getQueryStr();
        List<User> userList = Database.query(queryStr);
        System.assertEquals(2, userList.size());
    }

    @isTest static void testAddOrder() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account');
        String queryStr = soql.addField('Id').addOrder('CreatedDate DESC').setLimit(10).getQueryStr();
        System.assertEquals('SELECT Id FROM Account ORDER BY CreatedDate DESC LIMIT 10', queryStr);
    }

    @isTest static void testConvertSetToString() {
        BE8_SoqlBuilder soql = new BE8_SoqlBuilder('Account');
        Set<String> fieldSet = new Set<String>{'Id','Name','FirstName'};
        String queryStr = soql.convertSetToString(fieldSet);
        System.assertEquals('Id,Name,FirstName', queryStr);
    }

}