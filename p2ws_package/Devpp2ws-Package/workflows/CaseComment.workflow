<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Concatenate_Case_Description</fullName>
        <field>Description</field>
        <formula>Parent.Description  &amp; BR() &amp; BR() &amp; CreatedBy.FirstName &amp; &apos; &apos; &amp; CreatedBy.LastName &amp; &apos; &apos; &amp;  LEFT(Text(CreatedDate),LEN(Text(CreatedDate))-1) &amp;  BR() &amp; CommentBody</formula>
        <name>Concatenate Case Description</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>ParentId</targetObject>
    </fieldUpdates>
</Workflow>
