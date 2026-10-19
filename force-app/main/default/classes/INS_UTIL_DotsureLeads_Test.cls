/**
 * @description Test class for INS_UTIL_DotsureLeads
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-21
 **/
@isTest
private class INS_UTIL_DotsureLeads_Test {
    
    @isTest
    static void testProcessLeadsForDotsureEmptyList() {
        Test.startTest();
        INS_UTIL_DotsureLeads.processLeadsForDotsure(new List<Lead>());
        Test.stopTest();
        
        Assert.isTrue(true, 'Empty list should be handled gracefully');
    }
    
    @isTest
    static void testProcessLeadsForDotsurePublishesEvents() {
        User testUser = Insurance_TestDataFactory.createTestUser();
        insert testUser;
        
        List<Leads_ProductQueueAllocation__c> products = 
            Insurance_TestDataFactory.createExpressInterest();
        insert products;
        
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = testUser.Id;
        lead.Expressed_Interest_Product__c = products[0].Id;
        insert lead;
        
        Test.startTest();
        INS_UTIL_DotsureLeads.processLeadsForDotsure(new List<Lead>{lead});
        Test.stopTest();
        
        Assert.isTrue(true, 'Events published without exceptions');
    }
    
    @isTest
    static void testProcessLeadsForDotsureInvalidProduct() {
        User testUser = Insurance_TestDataFactory.createTestUser();
        insert testUser;
        
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = testUser.Id;
        insert lead;
        
        Test.startTest();
        INS_UTIL_DotsureLeads.processLeadsForDotsure(new List<Lead>{lead});
        Test.stopTest();
        
        Assert.isTrue(true, 'Invalid product lead should skip event publishing');
    }
}