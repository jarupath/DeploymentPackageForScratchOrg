/*------------------------------------------------------------
Author: Charnun Thaweethamwitthaya
Company : Beryl8
Description: Common SOQL Condition Builder.

History : 
<Date>      <Authors Name>     <Brief Description of Change> 
28/09/2016  Charnun.T          First Create
------------------------------------------------------------*/
public with sharing class BE8_SoqlConditionBuilder {
    String conditionType;
    List<String> conditionStringList;

    public BE8_SoqlConditionBuilder(String conditionType) {
        this.conditionType = conditionType;
        conditionStringList = new List<String>();
    }

    public BE8_SoqlConditionBuilder add(String conditionStr) {
        conditionStringList.add(conditionStr);
        return this;
    }

    public BE8_SoqlConditionBuilder add(String field, String value) {
        add(field+' = \''+value+'\'');
        return this;
    }

    public BE8_SoqlConditionBuilder add(String field, Set<String> keySet) {
        if(keySet.isEmpty()) return this;

        String conditionStr = ' IN (';
        for(String key : keySet) {
            if(!conditionStr.equals(' IN (')) {
                conditionStr += ',';
            }
            conditionStr += '\''+key+'\'';
        }

        conditionStr += ')';

        add(field+ conditionStr);
        return this;
    }

    public Boolean isEmpty() {
        return conditionStringList.isEmpty();
    }

    public String getString() {
        String conditionString = '';
        if(!conditionStringList.isEmpty()) {
            conditionString = '(' + String.join(conditionStringList, ' '+conditionType+' ')+')';
        }
        return conditionString;
    }
}