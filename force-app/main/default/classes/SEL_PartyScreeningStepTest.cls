/**
 * @description Test Class for SEL_PartyScreeningStep
 * @author Ofentse Sacha
 * @date August 2024
 */
@isTest
private class SEL_PartyScreeningStepTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account();
        acc.FirstName = 'John';
        acc.MiddleName = 'Michael';
        acc.LastName = 'Johns';
        insert acc;
        ICS_SEL_Account accountSelector = new ICS_SEL_Account();
        acc = accountSelector.getAccount(acc.Id);
        PartyProfile pprofile = new PartyProfile();
        pprofile.AccountId = acc.Id;
        pprofile.Name = 'record';
        insert pprofile;
        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = acc.Name;
        opp.StageName = 'New';
        opp.CloseDate = Date.today();
        insert opp;
        ApplicationForm application = new ApplicationForm();
        application.AccountId = acc.Id;
        application.OpportunityId = opp.Id;
        application.UsageType = 'Onboarding';
        insert application;
        PartyScreeningSummary summ = new PartyScreeningSummary();
        summ.PartyProfileId = pprofile.Id;
        summ.Name = 'Test Summ';
        insert summ;
        PartyScreeningStep testStep = new PartyScreeningStep(
            Name = 'Test Step',
            Status = 'SAFE',
            Type = 'World Check',
            ScreeningMatchCategory__c = 'Uncategorised',
            Comments__c = 'Test Comment',
            isWeakStatus__c = false,
            ScreeningSummaryId = summ.Id,
            Reason__c = 'Gender does not match',
            SubReason__c = 'None'
        );
        
        insert testStep;
    }

    @isTest
    static void testSelectById() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        
        PartyScreeningStep testStep = [SELECT Id, Status FROM PartyScreeningStep WHERE Name = 'Test Step' LIMIT 1];
        PartyScreeningStep retrievedStep = selector.selectById(testStep.Id);

        Assert.areNotEqual(null, retrievedStep, 'Expected to retrieve a PartyScreeningStep record');
        Assert.areEqual(testStep.Id, retrievedStep.Id, 'Retrieved record ID should match the test record ID');
        Assert.areEqual('SAFE', retrievedStep.Status, 'Retrieved Status should match the inserted Status');
    }
    
    @isTest
    static void testSelectByIdorSummaryIdUsingRecordId() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        
        PartyScreeningStep testStep = [SELECT Id FROM PartyScreeningStep WHERE Name = 'Test Step' LIMIT 1];
        List<PartyScreeningStep> stepsById = selector.selectByIdorSummaryId(testStep.Id, true);

        Assert.areNotEqual(0, stepsById.size(), 'Expected to retrieve at least one PartyScreeningStep record');
        Assert.areEqual(testStep.Id, stepsById[0].Id, 'Retrieved record ID should match the test record ID');
    }
    
    @isTest
    static void testSelectByIdorSummaryIdUsingSummaryId() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        
        PartyScreeningStep testStep = [SELECT ScreeningSummaryId FROM PartyScreeningStep WHERE Name = 'Test Step' LIMIT 1];
        List<PartyScreeningStep> stepsBySummaryId = selector.selectByIdorSummaryId(testStep.ScreeningSummaryId, false);
        
        Assert.areNotEqual(0, stepsBySummaryId.size(), 'Expected to retrieve at least one PartyScreeningStep record');
        Assert.areEqual(testStep.ScreeningSummaryId, stepsBySummaryId[0].ScreeningSummaryId, 'Retrieved ScreeningSummaryId should match the test ScreeningSummaryId');
    }
    
    @isTest
    static void testSelectBySummaryIds() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        PartyScreeningSummary summary = [SELECT Id FROM PartyScreeningSummary WHERE Name = 'Test Summ' LIMIT 1];
        Set<Id> summaryIds = new Set<Id>{ summary.Id };
        List<PartyScreeningStep> stepsBySummaryIds = selector.selectBySummaryIds(summaryIds);
        
        Assert.areEqual(1, stepsBySummaryIds.size(), 'Expected to retrieve exactly one PartyScreeningStep record');
        Assert.areEqual(summary.Id, stepsBySummaryIds[0].ScreeningSummaryId, 'Retrieved ScreeningSummaryId should match the test ScreeningSummaryId');
    }
}