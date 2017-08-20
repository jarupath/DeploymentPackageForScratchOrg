<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Acknowledge_Email</fullName>
        <description>Acknowledge Email</description>
        <protected>false</protected>
        <recipients>
            <field>SuppliedEmail</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Acknowledge_Template</template>
    </alerts>
    <alerts>
        <fullName>Acknowledge_Email_Contact_Email</fullName>
        <description>Acknowledge Email (Contact Email)</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Email_txt__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Acknowledge_Template</template>
    </alerts>
    <alerts>
        <fullName>Approval_Result</fullName>
        <description>Approval_Result</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Compensation_Approval_Result</template>
    </alerts>
    <alerts>
        <fullName>Case_Overdue</fullName>
        <description>Case Overdue</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Overdue_Template</template>
    </alerts>
    <fieldUpdates>
        <fullName>Case_Delete</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Ground_Service_Delete</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Delete</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Case_Field_Update</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Maintenance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Case Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Case_Record_Type_to_Void</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Void_Maintenance</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change Case Record Type to Void</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Status_Pending</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Change Status Pending</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Compensation_Status_Update</fullName>
        <field>Compensation_Approval__c</field>
        <literalValue>1</literalValue>
        <name>Compensation Status Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Inactive_Send_Email</fullName>
        <field>Emergency_Send_Email__c</field>
        <literalValue>0</literalValue>
        <name>Inactive Send Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Isstop</fullName>
        <field>IsStopped</field>
        <literalValue>1</literalValue>
        <name>Isstop</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Not_Send_Acknowledgement</fullName>
        <field>Not_Send_Acknowledge_Email__c</field>
        <literalValue>1</literalValue>
        <name>Not Send Acknowledgement</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Undelete_Case</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Ground_Service</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Undelete Case</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_AC_REG_SEARCH</fullName>
        <field>A_C_Reg_Search__c</field>
        <formula>Aircraft_Registration_F__c</formula>
        <name>Update AC REG SEARCH</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Approval Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Submission_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Approval Submission Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Case_Status_to_Void</fullName>
        <field>Status</field>
        <literalValue>Void</literalValue>
        <name>Update Case Status to Void</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Rejection_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Rejection Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Approved</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_Rejected</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>๊Update Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
