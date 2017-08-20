<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Change_Passenger_Name</fullName>
        <field>Name</field>
        <formula>Last_Name__c + &quot; &quot; + First_Name__c</formula>
        <name>Change Passenger Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Passenger Name</fullName>
        <actions>
            <name>Change_Passenger_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>$Profile.Name &lt;&gt; &quot;System Integration&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
