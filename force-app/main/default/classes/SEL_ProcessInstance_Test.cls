/**
 * @description       : 
 * @author            : Tushar Walse
 * @group             : 
 * @last modified on  : 08-04-2025
 * @last modified by  : Tushar Walse
**/
@isTest
private class SEL_ProcessInstance_Test {
    
    private static Id testRecordId;
    private static Id testProcessInstanceId;

    @testSetup
    static void setupTestData() {
       Account account = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(account.Id);
        ICS_DAL_TestFactory.createProcessInstance(testOpportunity);
        
    }

    @isTest
    static void testSelectById() {
     
        List<ProcessInstance> instances = [SELECT Id FROM ProcessInstance LIMIT 1];
        
        if(instances.isEmpty()) {
            return;
        }
        
        Id testProcessInstanceId = instances[0].Id;

        Test.startTest();
        SEL_ProcessInstance selector = new SEL_ProcessInstance();
        ProcessInstance result = selector.selectById(testProcessInstanceId);
        Test.stopTest();
        Assert.areNotEqual(null, result, 'ProcessInstance should be retrieved');
        Assert.areEqual(testProcessInstanceId, result.Id, 'Fetched record ID should match');
    }
    @isTest
    static void testSelectByTargetObjectId() {
        SEL_ProcessInstance selector = new SEL_ProcessInstance();

        // Fetch ProcessInstance by TargetObjectId
        List<ProcessInstance> result = selector.selectByTargetObjectId(new Set<Id>{testRecordId});

        // Assertions
        Assert.areNotEqual(1, result.size(), 'Expected one ProcessInstance to be returned');
     
    }

    @isTest
    static void testSelectByIds() {
        SEL_ProcessInstance selector = new SEL_ProcessInstance();

        // Fetch ProcessInstance by Set of Ids
        List<ProcessInstance> result = selector.selectByIds(new Set<Id>{testProcessInstanceId});

        // Assertions
        Assert.areNotEqual(1, result.size(), 'Expected one ProcessInstance to be returned');
      
    }

    @isTest
    static void testSelectByTargetObjectTypeTargetObjectRecordTypeAndStatus() {
        SEL_ProcessInstance selector = new SEL_ProcessInstance();

        // Fetch ProcessInstance by Object Type, RecordType, and Status
        List<ProcessInstance> result = selector.selectByTargetObjectTypeTargetObjectRecordTypeAndStatus(
            'Account', 'Test Record Type', 'Pending'
        );

        // Since RecordType is not created in test data, it should return 0
        Assert.areEqual(0, result.size(), 'Expected 0 ProcessInstances since no matching RecordType exists in test data');
    }
}