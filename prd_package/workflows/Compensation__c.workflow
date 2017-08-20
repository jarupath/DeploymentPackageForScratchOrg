<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Compensation_Status_Update</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Compensation Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Compensation Status Update</fullName>
        <actions>
            <name>Compensation_Status_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>User.Port__c</field>
            <operation>equals</operation>
            <value>BKK</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
