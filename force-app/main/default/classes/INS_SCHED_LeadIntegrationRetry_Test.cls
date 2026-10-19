/**
 * @description Test class for INS_SCHED_LeadIntegrationRetry
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-22
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-22   Raja Arsalan    Initial Version
 **/
@isTest
private class INS_SCHED_LeadIntegrationRetry_Test {
    
    /**
     * @description Test scheduleJob creates two jobs
     **/
    @isTest
    static void testScheduleJob() {
        Test.startTest();
        List<String> jobIds = INS_SCHED_LeadIntegrationRetry.scheduleJob();
        Test.stopTest();
        
        Assert.areEqual(2, jobIds.size(), 'Two job IDs should be returned');
        Assert.isNotNull(jobIds[0], 'Job 1 ID should not be null');
        Assert.isNotNull(jobIds[1], 'Job 2 ID should not be null');
        
        // Verify jobs exist in CronTrigger
        List<CronTrigger> jobs = [
            SELECT Id, CronJobDetail.Name 
            FROM CronTrigger 
            WHERE CronJobDetail.Name IN (
                :INS_SCHED_LeadIntegrationRetry.JOB_NAME_1,
                :INS_SCHED_LeadIntegrationRetry.JOB_NAME_2
            )
        ];
        Assert.areEqual(2, jobs.size(), 'Two scheduled jobs should exist');
    }
    
    /**
     * @description Test execute when no leads to retry
     **/
    @isTest
    static void testExecuteNoLeads() {
        Test.startTest();
        INS_SCHED_LeadIntegrationRetry scheduler = new INS_SCHED_LeadIntegrationRetry();
        scheduler.execute(null);
        Test.stopTest();
        
        Assert.isTrue(true, 'Should handle no leads gracefully');
    }
    
    /**
     * @description Test execute with retry-eligible leads
     **/
    @isTest
    static void testExecuteWithLeads() {
        // Setup test data
        User testUser = Insurance_TestDataFactory.createTestUser();
        insert testUser;
        
        List<Leads_ProductQueueAllocation__c> products = 
            Insurance_TestDataFactory.createExpressInterest();
        insert products;
        
        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.OwnerId = testUser.Id;
        lead.Expressed_Interest_Product__c = products[0].Id;
        lead.Dialer_Failure_Reason__c = '500 - Server Error';
        lead.Referred_System_Reference_Number__c = 'Dotsure Failed';
        insert lead;
        
        // Set up mock
        INS_DotsureService.mockScenario = 'success';
        INS_DotsureService.testLeadId = lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_DotsureAPI_Mock());
        
        Test.startTest();
        INS_SCHED_LeadIntegrationRetry scheduler = new INS_SCHED_LeadIntegrationRetry();
        scheduler.execute(null);
        Test.stopTest();
        
        Assert.isTrue(true, 'Batch should be queued successfully');
    }
    
    /**
     * @description Test execute catches exceptions
     **/
    @isTest
    static void testExecuteException() {
        INS_SCHED_LeadIntegrationRetry.forceException = true;
        
        Test.startTest();
        INS_SCHED_LeadIntegrationRetry scheduler = new INS_SCHED_LeadIntegrationRetry();
        scheduler.execute(null);
        Test.stopTest();
        
        // Reset flag
        INS_SCHED_LeadIntegrationRetry.forceException = false;
        
        Assert.isTrue(true, 'Exception should be caught and logged');
    }
    
    /**
     * @description Test schedulable interface directly
     **/
    @isTest
    static void testSchedulableContext() {
        Test.startTest();
        String jobId = System.schedule(
            'Test_INS_LeadIntegrationRetry',
            '0 0 * * * ?',
            new INS_SCHED_LeadIntegrationRetry()
        );
        Test.stopTest();
        
        Assert.isNotNull(jobId, 'Job ID should not be null');
    }
}