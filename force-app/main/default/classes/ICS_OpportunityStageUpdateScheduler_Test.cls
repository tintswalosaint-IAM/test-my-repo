/**
 * @description       : Test class for ICS_OpportunityStageUpdateScheduler
 * @author            : Ramya Gurram
 * @last modified on  : 10-17-2025
 * @modification description: SFP-52492 Updated to cover logic of schedule automatically
 **/
@isTest
private class ICS_OpportunityStageUpdateScheduler_Test {
    
    @TestSetup
    static void setupTestData() {
         Account acc = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createPartyProfile(acc.id);
        Opportunity opp=ICS_DAL_TestFactory.createOpportunity(acc.id);
        opp.StageName='Risk Rating';
        update opp;
        ICS_DAL_TestFactory.createApplicationForm(acc.id, opp.id);
    }
    
    @isTest
    static void testSchedulerWithAllDocsUploaded() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        // Ensure all ApplicationForms are in 'Awaiting Document Upload' stage
        List<ApplicationForm> forms = [SELECT Id, Stage FROM ApplicationForm WHERE OpportunityId = :testOpp.Id];
        for(ApplicationForm form : forms) {
            form.Stage = 'Awaiting Document Upload';
        }
        update forms;
        
        Test.startTest();
        // Schedule the job - it will execute immediately in test context
        String cronExp = '0 0 0 * * ?'; // Run at midnight every day
        String jobId = System.schedule(
            'Test ICS OpportunityStageUpdateScheduler',
            cronExp,
            new ICS_OpportunityStageUpdateScheduler(testOpp.Id)
        );
        Test.stopTest(); // This forces the scheduled job to execute
        
        // Query the opportunity again to get the updated stage
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        Assert.areEqual('Documents upload', updatedOpp.StageName, 
            'Opportunity stage should be updated to Documents upload');
    }
    
    @isTest
    static void testSchedulerWithNotAllDocsUploaded() {
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        testOpp.StageName = 'Risk Rating';
        update testOpp;

        List<ApplicationForm> forms = [SELECT Id, Stage FROM ApplicationForm WHERE OpportunityId = :testOpp.Id];
        if (!forms.isEmpty()) {
            forms[0].Stage = 'In Progress';
            update forms[0];
        }

        String initialStage = testOpp.StageName;

        Test.startTest();
        new ICS_OpportunityStageUpdateScheduler(testOpp.Id).execute(null);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        Assert.areEqual(initialStage, updatedOpp.StageName,
            'Stage should not update when not all docs are uploaded.');
    }
    
    @isTest
    static void testSchedulerWithNoApplicationForms() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opp No Forms',
            AccountId = testAcc.Id,
            StageName = 'Risk Rating',
            CloseDate = Date.today().addDays(10)
        );
        insert opp;

        Test.startTest();
        new ICS_OpportunityStageUpdateScheduler(opp.Id).execute(null);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT StageName FROM Opportunity WHERE Id = :opp.Id];
        Assert.areEqual('Documents upload', updatedOpp.StageName,
            'Stage should update to Documents upload when no forms exist (allDocsUploaded = true).');
    }

    
    @isTest
    static void testConstructor() {
        // Use a real opportunity ID from test setup
        Opportunity testOpp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        ICS_OpportunityStageUpdateScheduler scheduler = new ICS_OpportunityStageUpdateScheduler(testOpp.Id);
        Test.stopTest();
        
      Assert.isNotNull(scheduler, 'Scheduler should be instantiated successfully');
    }
    
    @isTest
    static void testSchedulerExecuteMethod() {
        // Get test opportunity
        Opportunity testOpp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        
        // Ensure all ApplicationForms are in 'Awaiting Document Upload' stage
        List<ApplicationForm> forms = [SELECT Id, Stage FROM ApplicationForm WHERE OpportunityId = :testOpp.Id];
        for(ApplicationForm form : forms) {
            form.Stage = 'Awaiting Document Upload';
        }
        update forms;
        
        Test.startTest();
        // Create scheduler instance and execute directly
        ICS_OpportunityStageUpdateScheduler scheduler = new ICS_OpportunityStageUpdateScheduler(testOpp.Id);
        scheduler.execute(null); // Execute the scheduled logic directly
        Test.stopTest();
        
        // Verify the opportunity stage was updated
        Opportunity updatedOpp = [SELECT Id, StageName FROM Opportunity WHERE Id = :testOpp.Id];
        Assert.areEqual('Documents upload', updatedOpp.StageName, 
            'Opportunity stage should be updated to Documents upload');
    }
}