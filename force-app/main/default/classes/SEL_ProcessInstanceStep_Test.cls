/**
 * @description       : Test class for SEL_ProcessInstanceStep
 * @author            : Tushar Walse
 * @last modified on  : 19-10-2024
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_ProcessInstanceStep_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account account = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(account.Id);
        ICS_DAL_TestFactory.createProcessInstanceStep(testOpportunity);
    }

    /**
     * @description Test the getSObjectType method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_ProcessInstanceStep testProcessInstanceStep = new SEL_ProcessInstanceStep();
        Test.startTest();
        Schema.SObjectType sObjectType = testProcessInstanceStep.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ProcessInstanceStep.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_ProcessInstanceStep testProcessInstanceStep = new SEL_ProcessInstanceStep();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = testProcessInstanceStep.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testselectByProcessInstanceId() {
        ProcessInstance testProcessInstance = [select id from ProcessInstance limit 1];
        SEL_ProcessInstanceStep testProcessInstanceStep = new SEL_ProcessInstanceStep();
        Test.startTest();
        List<ProcessInstanceStep> sObjectFieldList = testProcessInstanceStep.selectByProcessInstanceId(new Set<Id>{testProcessInstance.Id});
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the selectById method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testSelectById() {
        Id processInstanceStepId = [select Id from ProcessInstanceStep Limit 1].Id;

        SEL_ProcessInstanceStep processInstanceStepSelector = new SEL_ProcessInstanceStep();
        Test.startTest();
        ProcessInstanceStep processInstanceStep = processInstanceStepSelector.selectById(processInstanceStepId);
        Test.stopTest();
        Assert.areEqual(true, processInstanceStep != null, 'Expected 1 ProcessInstanceStep record to be returned.');
    }

    /**
     * @description Test the selectByIds method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testSelectByIds() {
        Set<Id> processInstanceStepIds = new Map<Id, ProcessInstanceStep>([select Id from ProcessInstanceStep Limit 1]).keySet();

        SEL_ProcessInstanceStep processInstanceStepSelector = new SEL_ProcessInstanceStep();
        Test.startTest();
        List<ProcessInstanceStep> processInstanceStep = processInstanceStepSelector.selectByIds(processInstanceStepIds);
        Test.stopTest();
        Assert.areEqual(true, processInstanceStep.size()>0, 'Expected at least 1 ProcessInstanceStep record to be returned.');
    }

    /**
     * @description Test the selectByIds method of SEL_ProcessInstanceStep class
     */
    @isTest
    static void testSelectByTargetObjectTypeTargetObjectRecordTypeAndStatus() {
        SEL_ProcessInstanceStep processInstanceStepSelector = new SEL_ProcessInstanceStep();
        Test.startTest();
        List<ProcessInstanceStep> processInstanceStep = processInstanceStepSelector.selectByTargetObjectTypeTargetObjectRecordTypeAndStatus('Opportunity', 'ICS Applicant', 'Pending');
        Test.stopTest();
        Assert.areEqual(true, processInstanceStep.size()>0, 'Expected at least 1 ProcessInstanceStep record to be returned.');
    }
}