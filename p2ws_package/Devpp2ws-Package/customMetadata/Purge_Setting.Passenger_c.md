<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Passenger__c</label>
    <protected>false</protected>
    <values>
        <field>Condition__c</field>
        <value xsi:type="xsd:string">Id NOT IN (SELECT Passengerid__c FROM Case_Group_Member__c WHERE PassengerId__c != NULL) AND Id NOT IN (SELECT PassengerId__c FROM Case WHERE PassengerId__c != NULL)</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Passenger__c</value>
    </values>
    <values>
        <field>Older_Than_N_Months__c</field>
        <value xsi:type="xsd:double">3.0</value>
    </values>
</CustomMetadata>
