/**
* @description       : Test class for Leads_ProductQueueAllocation__c
* @author            : Raja Arsalan
* @group             : Tests
* @last modified on  : 07-07-2025

* Change Logs
*
* 20-07-2026   Raja Arsalan     Updated the test methods to have assert.equals
							    and added a new method getAvailableProducts_BlankInputs.
**/

@isTest
private class INS_SEL_ProductQueue_Test {
    
    
    
    /**
* @description Tests selectProductQueueAllocationById with a valid record
* @author Raja Arsalan | 15-10-2025 
*/
    
    @IsTest
    public static void testSelectProductQueueAllocationById() {
        List<Leads_ProductQueueAllocation__c> productQueue = Insurance_TestDataFactory.createExpressInterest();
        insert productQueue;
        
        Test.startTest();
        List<Leads_ProductQueueAllocation__c> result = 
            new INS_SEL_Leads_ProductQueueAllocation().selectProductQueueAllocationById(productQueue[0].Id);
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected one record returned');
        Assert.areEqual(productQueue[0].Id, result[0].Id, 'Returned record Id does not match');
    }
    
    /**
* @description Tests selectProductQueueByIds with a valid set of Ids
* @author Raja Arsalan | 15-10-2025 
*/
    
    
    @IsTest
    public static void testSelectProductQueueByIds() {
        List<Leads_ProductQueueAllocation__c> p1 = Insurance_TestDataFactory.createExpressInterest();
        insert p1;
        
        Set<Id> productQueueIds = new Set<Id>{ p1[0].Id};
            
            Test.startTest();
        List<Leads_ProductQueueAllocation__c> result = 
            new INS_SEL_Leads_ProductQueueAllocation().selectProductQueueByIds(productQueueIds);
        Test.stopTest();
        Assert.areEqual(1, result.size(), 'Expected 1 record');
        
    }
    
}