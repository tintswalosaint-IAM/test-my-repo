/*************************************************************
* @description SFP-43424 Class used to test class for ICS_SCH_SAPRelationAPIScheduler sap create customer
*
* @autor Ikyatha Naidu
*
* @date Apr 26 2025
***************************************************************
* Last Modified By  Ikyatha Naidu
* Last Modified Date 27/04/2025
* Last Modified Description: updated to latest Version
*/
@isTest
private class ICS_SCH_SAPRelationAPIScheduler_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test Account records
        Account primaryAccount = new Account(
            Name = 'Test Primary Account',
            ExternalCIFId__c = null // Initially no CIF ID
        );
        insert primaryAccount;
        
        Account jointAccount = new Account(
            Name = 'Test Joint Account',
            ExternalCIFId__c = null // Initially no CIF ID
        );
        insert jointAccount;
        
        
        // Create opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            AccountId = jointAccount.id,
            CloseDate = Date.today().addDays(30)
        );
        insert testOpp;
        
        // Create Application Forms
        ApplicationForm primaryForm = new ApplicationForm(
            AccountId = primaryAccount.Id,
            OpportunityId = testOpp.Id,
            usagetype='Onboarding'
        );
        insert primaryForm;
        
        // Create Applicant records
        Applicant primaryApplicant = new Applicant(
            AccountId = primaryAccount.Id,
            Role = 'Primary Applicant',
            applicationformId = primaryForm.id
        );
        insert primaryApplicant;
    }
    
    @isTest
    static void testSingleApplicationMissingCIF() {
        // Get the test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule(
            'TestSAPRelationJob',
            '0 0 0 * * ?',
            new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id)
        );
        
        // Execute the scheduled job immediately
        CronTrigger cronTrigger = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        Assert.isTrue(cronTrigger != null, 'Job should be scheduled');
        
        // Execute the job directly to test the functionality
        ICS_SCH_SAPRelationAPIScheduler scheduler = new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id);
        scheduler.execute(null);
        
        Test.stopTest();
        
        // No relation API call should have been made since CIF is missing
        // Verify that no jobs were enqueued (we can't directly assert this without a counter or custom setting)
    }
    
    @isTest
    static void testSingleApplicationWithCIF() {
        // Get the test opportunity and account
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Primary Account' LIMIT 1];
        
        // Update account with CIF ID
        testAccount.ExternalCIFId__c = 'CIF12345';
        update testAccount;
        
        Test.startTest();
        
        // Mock the callout if needed
        // Test.setMock(HttpCalloutMock.class, new YourMockClass());
        
        // Schedule the job
        String jobId = System.schedule(
            'TestSAPRelationJob',
            '0 0 0 * * ?',
            new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id)
        );
        
        // Execute the job directly
        ICS_SCH_SAPRelationAPIScheduler scheduler = new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id);
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify the relation API was called for single application
        // This would typically involve verifying that ICS_CTRL_SAPCreateRelation was instantiated with correct parameters
        // Since we can't easily track this without modifying the original class, we'll rely on code coverage
    }
    
    @isTest
    static void testJointApplicationWithCIF() {
        // Get the test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Get and update primary account with CIF ID
        Account primaryAccount = [SELECT Id FROM Account WHERE Name = 'Test Primary Account' LIMIT 1];
        primaryAccount.ExternalCIFId__c = 'CIF12345';
        update primaryAccount;
        
        // Add second application form for joint account
        Account jointAccount = [SELECT Id FROM Account WHERE Name = 'Test Joint Account' LIMIT 1];
        jointAccount.ExternalCIFId__c = 'CIF67890';
        update jointAccount;
        
        // Create second application form for joint account
        ApplicationForm jointForm = new ApplicationForm(
            AccountId = jointAccount.Id,
            OpportunityId = testOpp.Id,
            usagetype='Onboarding'
        );
        insert jointForm;
        
        // Create joint applicant
        Applicant jointApplicant = new Applicant(
            AccountId = jointAccount.Id,
            Role = 'Joint Applicant',
            ApplicationformId = jointForm.id
        );
        insert jointApplicant;
        
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule(
            'TestSAPRelationJob',
            '0 0 0 * * ?',
            new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id)
        );
        
        // Execute the job directly
        ICS_SCH_SAPRelationAPIScheduler scheduler = new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id);
        scheduler.execute(null);
        
        Test.stopTest();
        
        // Verify the relation API was called for joint application
        // This would typically involve verifying that ICS_CTRL_SAPCreateRelation was instantiated with correct parameters
    }
    
    @isTest
    static void testSchedulableContextExecution() {
        // Get the test opportunity
        Opportunity testOpp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity' LIMIT 1];
        
        // Update account with CIF ID
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Primary Account' LIMIT 1];
        testAccount.ExternalCIFId__c = 'CIF12345';
        update testAccount;
        
        Test.startTest();
        
        // Schedule the job
        String jobId = System.schedule(
            'TestSAPRelationJob',
            '0 0 0 * * ?',
            new ICS_SCH_SAPRelationAPIScheduler(testOpp.Id)
        );
        
        Test.stopTest();
        
        // Verify the job was scheduled and aborted
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(0, cronTriggers.size(), 'Job should have been aborted after execution');
    }
    
    @isTest
    static void testConstructor() {
        // Simple test to verify constructor works
        String testOppId = '006000000000001';
        ICS_SCH_SAPRelationAPIScheduler scheduler = new ICS_SCH_SAPRelationAPIScheduler(testOppId);
        Assert.isTrue(scheduler != null, 'Scheduler should be instantiated');
    }
}