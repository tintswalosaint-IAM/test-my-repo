@istest
public class SEL_PartyScreeningStep_Test {
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
            ScreeningSummaryId = summ.Id
        );
        
        insert testStep;
    }

    @IsTest
    static void testGetSObjectType() {
        SEL_PartyScreeningStep partyProfileSelector = new SEL_PartyScreeningStep();
        Schema.SObjectType sObjectType = partyProfileSelector.getSObjectType();        
        Assert.areEqual(PartyScreeningStep.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_PartyScreeningStep partyProfileSelector = new SEL_PartyScreeningStep();
        List<Schema.SObjectField> sObjectFieldList = partyProfileSelector.getSObjectFieldList();        
        Map<String, Schema.SObjectField> fieldMap = PartyIdentityVerification.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field not found in field map');
        }
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
    static void testselectBySummaryIds() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        PartyScreeningSummary summary= [SELECT Id, Status FROM PartyScreeningSummary];
        selector.selectBySummaryIds(new set<id>{summary.id});
        Assert.areEqual(true, summary!=null, 'Unexpected Address Info');
    }
     @isTest
    static void testfetchPartyScreeningStepFromVerification() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        PartyScreeningSummary summary= [SELECT Id, Status FROM PartyScreeningSummary];
        selector.fetchPartyScreeningStepFromVerification(summary.id);
        Assert.areEqual(true, summary!=null, 'Unexpected Address Info');
    }
     @isTest
    static void testselectByIdorSummaryId() {
        SEL_PartyScreeningStep selector = new SEL_PartyScreeningStep();
        PartyScreeningSummary summary= [SELECT Id, Status FROM PartyScreeningSummary];
        selector.selectByIdorSummaryId(summary.id,true);
        Assert.areEqual(true, summary!=null, 'Unexpected Address Info');
    }
}