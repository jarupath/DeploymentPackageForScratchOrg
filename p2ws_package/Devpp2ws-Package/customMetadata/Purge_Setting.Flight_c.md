<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Flight__c</label>
    <protected>false</protected>
    <values>
        <field>Condition__c</field>
        <value xsi:type="xsd:string">Id NOT IN (SELECT Flightid__c FROM Case)</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Flight__c</value>
    </values>
    <values>
        <field>Older_Than_N_Months__c</field>
        <value xsi:type="xsd:double">6.0</value>
    </values>
</CustomMetadata>
