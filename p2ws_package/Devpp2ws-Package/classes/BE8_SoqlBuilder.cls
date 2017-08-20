/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description: Common SOQL Builder.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
28/09/2016  Charnun.T          First Create
------------------------------------------------------------*/
public with sharing class BE8_SoqlBuilder {
    List<String> conditionList;
    Set<String> selectFieldSet;
    List<String> orderList;
    String objectType;
    String conditionStr;
    String orderBy;
    Integer numberOfLimit;


    public BE8_SoqlBuilder(String objectType) {
        conditionList = new List<String>();     
        selectFieldSet = new Set<String>();
        orderList = new List<String>();
        this.objectType = objectType;
        conditionStr = 'AND';
    }

    public BE8_SoqlBuilder(String objectType, Set<String> selectFieldSet) {
        this(objectType);
        this.selectFieldSet = selectFieldSet;
    }

    public void clearCondition() {
        conditionList.clear();
    }

    public Boolean hasCondition() {
        return conditionList.size() > 0;
    } 

    public BE8_SoqlBuilder setCondition(String conditionStr) {
        this.conditionStr = conditionStr;
        return this;
    }

    public BE8_SoqlBuilder addField(Set<String> fieldSet) {
        selectFieldSet.addAll(fieldSet);
        return this;
    }

    public BE8_SoqlBuilder addField(String field) {
        selectFieldSet.add(field);
        return this;
    }

    public BE8_SoqlBuilder addCondition(String condition) {
        conditionList.add(condition);
        return this;
    }

    public BE8_SoqlBuilder addConditionNotIn(String field, Set<Id> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' NOT IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }
    public BE8_SoqlBuilder addConditionNotIn(String field, Set<String> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' NOT IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addConditionNotIn(String field, Set<Object> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' NOT IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addCondition(String field, Set<Object> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addCondition(String field, Set<String> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addConditionLike(String field, Set<String> keySet) {
        if(keySet.isEmpty()) return this;
        String conditionStr = '';
        for(String key : keySet) {
            if(conditionStr != '') conditionStr += ' OR ';
            conditionStr +=  field + ' LIKE \''+key+'\'';
        }
        conditionStr = '('+ conditionStr+')';
        addCondition(conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addCondition(String field, Set<Id> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = convertSetToStringWithEscapeSingleQuote(keySet);
        conditionStr = ' IN ('+ conditionStr+')';
        addCondition(field+conditionStr);
        return this;
    }

    public BE8_SoqlBuilder addCondition(String field, String value) {
        String escapeValue = String.escapeSingleQuotes(value);
        addCondition(field+' = \''+escapeValue+'\'');
        return this;
    }

    public BE8_SoqlBuilder addCondition(String field, Boolean value) {
        addCondition(field+' = '+value);
        return this;
    }

    public String getQueryStr() {
        String queryStr ='SELECT '+ String.join(new List<String>(selectFieldSet), ',') + ' FROM ' +objectType;
        if(!conditionList.isEmpty()) {
            queryStr = queryStr + ' WHERE ' +String.join(conditionList, ' '+conditionStr+' ');
        }

        if(orderBy != null && orderBy != '') {
            queryStr += ' ' + orderBy;
        }

        if(!orderList.isEmpty()) {
            queryStr += ' ORDER BY ' + String.join(orderList, ',');
        }

        if(numberOfLimit != null && numberOfLimit > 0) {
            queryStr += ' LIMIT ' + numberOfLimit;
        }

        return queryStr;
    }

    public BE8_SoqlBuilder addOrder(String orderStr) {
        orderList.add(orderStr);
        return this;
    }

    public BE8_SoqlBuilder setLimit(Integer nLimit) {
        this.numberOfLimit = nLimit;
        return this;
    }

    public String convertSetToString(Set<String> stringSet) {
        String str = '';
        for(String s : stringSet) {
            str += (str==''?'':',')+s;
        }
        return str;
    }

    public String convertSetToStringWithEscapeSingleQuote(Set<Object> stringSet) {
        String str = '';
        for(Object s : stringSet) {
            str += (str==''?'':',')+'\''+String.escapeSingleQuotes((String)s)+'\'';
        }
        return str;
    }

    public String convertSetToStringWithEscapeSingleQuote(Set<Id> stringSet) {
        String str = '';
        for(Id s : stringSet) {
            str += (str==''?'':',')+'\''+String.escapeSingleQuotes((String)s)+'\'';
        }
        return str;
    }

    public String convertSetToStringWithEscapeSingleQuote(Set<String> stringSet) {
        String str = '';
        for(String s : stringSet) {
            str += (str==''?'':',')+'\''+String.escapeSingleQuotes((String)s)+'\'';
        }
        return str;
    }
}