// Author: [Mthandeni Gumede]
// Date: [24/22/2023]
// Description: Test class for ScheduleBatchPOPIAOpportunityCleanUp, ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIALeadCleanUp, ScheduleBatchPOPIAConversationCleanUp.

@isTest
public class ScheduleBatchPOPIACleanUpTEST {
    private static final String JOB_CASE_NAME = 'DeleteExpiredCaseRecordsZA';
    private static final String JOB_CONV_NAME = 'DeleteExpiredConversationRecords';
    private static final String JOB_OPP_NAME = 'DeleteExpiredOpportunityRecords';
    private static final String JOB_LEAD_NAME = 'DeleteExpiredLeadRecords';
   
   /**
   * @description testSetUp to insert data needed to test
   */
    @TestSetup
    static void testSetUp() {
        
        
        User adminUser = [
            SELECT Id, Country
            FROM User
            WHERE id = :UserInfo.getUserId()
            LIMIT 1
        ];
        
        adminUser.Country = 'South Africa';
        update adminUser;
      
        System.runAs(adminUser) {
            Account acc = new Account();
            acc.name = 'accTest';
            acc.ExternalSystemId__c='01';
            acc.ExternalCIFCountry__c = 'ZA';
            
            insert acc;
            
            List<Case> testCases = new List<Case>();
            for (Integer i = 0; i < 20; i++) {
                Case testCase = new Case();
                testCase.Status = 'Closed';
                testCase.DR_Retain_Until_Date__c = Date.today();
                testCase.AccountId = acc.Id;
                testCases.add(testCase);
            }
            
            List<CMN_Conversation__c> testConversations = new List<CMN_Conversation__c>();
            for (Integer i = 0; i < 10; i++) {
                CMN_Conversation__c testConversation = new CMN_Conversation__c();
                testConversation.Account__c = acc.Id;
                testConversation.Status__c = 'Actioned';
                testConversation.DR_Retain_Until_Date__c = Date.today();
                testConversations.add(testConversation);
            }
            
            List<Opportunity> testOpps = new List<Opportunity>();
            for (Integer i = 0; i < 20; i++) {
                Opportunity testOpp = new Opportunity();
                testOpp.AccountId = acc.Id;
                testOpp.Name ='testOpp'+ i;
                testOpp.StageName ='Closed Lost';
                testOpp.Loss_Reason__c='TEST';
                testOpp.DR_Retain_Until_Date__c = Date.today();
                testOpp.CloseDate = Date.today();
                testOpps.add(testOpp);
            }
            
            List<Lead> testLeads = new List<Lead>();
            for (Integer i = 0; i < 20; i++) {
                Lead testLead = new Lead();
                testLead.Company ='testLead'+ i;
                testLead.Status ='Unqualified';
                testLead.LastName ='testLead'+ i;
                testLead.DR_Retain_Until_Date__c = Date.today();
                testLeads.add(testLead);
            }
            
            insert testConversations;
            insert testOpps;
            insert testCases;
            insert testLeads;
        }
    }
    
    
   /**
   * @description Test Batch jobs for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp,ScheduleBatchPOPIALeadCleanUp
   */
    @isTest
    static void testBatchPOPIACleanUpJobs() {
        
        Test.startTest();
        Database.executeBatch(new ScheduleBatchPOPIACaseCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIAConversationCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIAOpportunityCleanUp());
        Database.executeBatch(new ScheduleBatchPOPIALeadCleanUp());
        Test.stopTest();
        
        // Verify that the records were deleted
        Integer caseCount = [SELECT COUNT() FROM Case WHERE Status = 'Closed' AND Account.ExternalCIFCountry__c = 'ZA' AND  Account.ExternalSystemId__c='01'
                             AND DR_Retain_Until_Date__c <= TODAY];
        
        Integer conversationCount = [SELECT COUNT() FROM CMN_Conversation__c WHERE Status__c = 'Actioned' AND Account__r.ExternalCIFCountry__c= 'ZA'AND 
                                     Account__r.ExternalSystemId__c='01' AND DR_Retain_Until_Date__c <= TODAY];
        
        Integer oppCount = [SELECT COUNT() FROM Opportunity WHERE (StageName = 'Closed Won' OR StageName = 'Closed Lost') AND Account.ExternalCIFCountry__c = 'ZA' 
                            AND Account.ExternalSystemId__c='01' AND DR_Retain_Until_Date__c <= TODAY];
        
        Integer leadCount = [SELECT COUNT() FROM Lead WHERE (Status = 'Qualified' OR Status = 'Unqualified') AND DR_Retain_Until_Date__c = TODAY];
        
        Assert.areEqual(0, leadCount);
        Assert.areEqual(0, oppCount);
        Assert.areEqual(0, caseCount);
        Assert.areEqual(0, conversationCount);
        
    }
    
    /**
     * @description Test unschedule method for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp,ScheduleBatchPOPIALeadCleanUp
    */
    @isTest
    static void testPOPIACleanUpUnschedule() {
        Test.startTest();
        ScheduleBatchPOPIACaseCleanUp.schedule();
        ScheduleBatchPOPIACaseCleanUp.unschedule();
        
        ScheduleBatchPOPIAConversationCleanUp.schedule();
        ScheduleBatchPOPIAConversationCleanUp.unschedule();  
        
        ScheduleBatchPOPIAOpportunityCleanUp.schedule();
        ScheduleBatchPOPIAOpportunityCleanUp.unschedule();
        
        ScheduleBatchPOPIALeadCleanUp.schedule();
        ScheduleBatchPOPIALeadCleanUp.unschedule();
        
        Test.stopTest();
        
        // Verify that the batch job is unscheduled
        Integer cronJobCaseCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CASE_NAME];
        Assert.areEqual(0, cronJobCaseCount, 'failure message: The values are not equal.');
        
        Integer cronJobConvCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CONV_NAME];
        Assert.areEqual(0, cronJobCaseCount, 'failure message: The values are not equal.');
        
        Integer cronJobOppCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_OPP_NAME];
        Assert.areEqual(0, cronJobCaseCount, 'failure message: The values are not equal.');
        
        Integer cronJobLeadCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_LEAD_NAME];
        Assert.areEqual(0, cronJobCaseCount, 'failure message: The values are not equal.');
    }
    
     /**
     * @description Test schedule method for classes ScheduleBatchPOPIACaseCleanUp, ScheduleBatchPOPIAConversationCleanUp, ScheduleBatchPOPIAOpportunityCleanUp,ScheduleBatchPOPIALeadCleanUp
    */
    @isTest
    static void testPOPIACleanUpschedule() {
        Test.startTest();
        ScheduleBatchPOPIACaseCleanUp.schedule();
        ScheduleBatchPOPIAConversationCleanUp.schedule();
        ScheduleBatchPOPIAOpportunityCleanUp.schedule();
        ScheduleBatchPOPIALeadCleanUp.schedule();
        Test.stopTest();
        
        // Verify that the batch job is scheduled
        Integer cronJobCaseCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CASE_NAME];
        Assert.areEqual(1, cronJobCaseCount);
        
        Integer cronJobConvCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_CONV_NAME];
        Assert.areEqual(1, cronJobConvCount);
        
        Integer cronJobOppCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_OPP_NAME];
        Assert.areEqual(1, cronJobOppCount);
        
        Integer cronJobLeadCount = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = :JOB_LEAD_NAME];
        Assert.areEqual(1, cronJobLeadCount);
    }
}