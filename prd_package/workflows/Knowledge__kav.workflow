<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <knowledgePublishes>
        <fullName>AutoPublishKnowledge</fullName>
        <action>Publish</action>
        <label>AutoPublishKnowledge</label>
        <language>en_US</language>
        <protected>false</protected>
    </knowledgePublishes>
    <rules>
        <fullName>AutoPublishKnowledge</fullName>
        <actions>
            <name>AutoPublishKnowledge</name>
            <type>KnowledgePublish</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>equals</operation>
            <value>System Administrator,TG System Administrator,System Integration</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
