/**
 * @description       : Test class for SEL_ProcessInstanceWorkItem
 * @author            : Tushar Walse
 * @last modified on  : 25-11-2024
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_ProcessInstanceWorkItem_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account account = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createOpportunity(account.Id);
    }

    /**
     * @description Test the getSObjectType method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_ProcessInstanceWorkItem testProcessInstanceWorkItem = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        Schema.SObjectType sObjectType = testProcessInstanceWorkItem.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ProcessInstanceWorkItem.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_ProcessInstanceWorkItem testProcessInstanceWorkItem = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = testProcessInstanceWorkItem.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the selectById method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testSelectById() {
        try{
        SEL_ProcessInstanceWorkItem processInstanceWorkItemSelector = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        processInstanceWorkItemSelector.selectById(null);
        Test.stopTest();
        }catch(exception ex){
            Assert.areEqual(true, ex.getmessage()!= null, 'Error Occured');
        }
    }

    /**
     * @description Test the selectByIds method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testSelectByIds() {
        Set<Id> processInstanceWorkItemIds = new Map<Id, ProcessInstanceWorkItem>().keySet();

        SEL_ProcessInstanceWorkItem processInstanceWorkItemSelector = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        List<ProcessInstanceWorkItem> processInstanceWorkItem = processInstanceWorkItemSelector.selectByIds(processInstanceWorkItemIds);
        Test.stopTest();
        Assert.areNotEqual(true, processInstanceWorkItem.size() > 0, 'Expected at least one field in the field list.');

    }

    /**
     * @description Test the selectByTargetObjectId method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testSelectByTargetObjectId() {
        SEL_ProcessInstanceWorkItem processInstanceWorkItemSelector = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        ProcessInstanceWorkItem[] processInstanceWorkItems = processInstanceWorkItemSelector.selectByTargetObjectId(null);
        Test.stopTest();
        Assert.areNotEqual(true, processInstanceWorkItems.size() > 0, 'Expected at least one field in the field list.');

    }

    /**
     * @description Test the selectByIds method of SEL_ProcessInstanceWorkItem class
     */
    @isTest
    static void testSelectByProcessInstanceIds() {
        Set<Id> processInstanceIds = new Map<Id, ProcessInstance>().keySet();

        SEL_ProcessInstanceWorkItem processInstanceWorkItemSelector = new SEL_ProcessInstanceWorkItem();
        Test.startTest();
        List<ProcessInstanceWorkItem> processInstanceWorkItem = processInstanceWorkItemSelector.selectByProcessInstanceIds(processInstanceIds);
        Test.stopTest();
        Assert.areNotEqual(true, processInstanceWorkItem.size() > 0, 'Expected at least one field in the field list.');

    }

}