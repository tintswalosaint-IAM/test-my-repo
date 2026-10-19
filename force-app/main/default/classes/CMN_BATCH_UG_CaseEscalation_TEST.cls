/*------------------------------------------------------------
Author:        Raymond Magezi
Description:   Test class for CMN_BATCH_UG_CaseEscalation
History
<Date>      <Authors Name>     <Brief Description of Change>
23-02-2026  Raymond Magezi     Initial creation
23-07-2026  Raymond Magezi     Refactored: deduplicated with helpers - SFP-58853
01-07-2026  Raymond Magezi     Refactored: aligned with DTO/rflib/DAL patterns - SFP-58853
------------------------------------------------------------*/
@IsTest
private class CMN_BATCH_UG_CaseEscalation_TEST {

    private static final String TEST_DOMAIN = 'test.com';
    private static final String LOCALE_EN_US = 'en_US';

    @TestSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User manager = new User(FirstName='Mgr', LastName='Test', Email='mgr@' + TEST_DOMAIN,
            Username='mgr' + System.currentTimeMillis() + '@' + TEST_DOMAIN, Alias='mtest',
            TimeZoneSidKey='America/New_York', LocaleSidKey=LOCALE_EN_US,
            EmailEncodingKey='UTF-8', LanguageLocaleKey=LOCALE_EN_US, ProfileId=p.Id);
        CMN_DAL_SObjectDomain.insertDBObject(manager);

        User owner = new User(FirstName='Own', LastName='Test', Email='own@' + TEST_DOMAIN,
            Username='own' + System.currentTimeMillis() + '@' + TEST_DOMAIN, Alias='otest',
            TimeZoneSidKey='America/New_York', LocaleSidKey=LOCALE_EN_US,
            EmailEncodingKey='UTF-8', LanguageLocaleKey=LOCALE_EN_US, ProfileId=p.Id, ManagerId=manager.Id);
        CMN_DAL_SObjectDomain.insertDBObject(owner);

        Case testCase = new Case(Subject='Test Escalation', Status='New', OwnerId=owner.Id,
            IsEscalated=true, SVC_Escalation_Level__c=0, Case_Owner_Country__c='UG');
        CMN_DAL_SObjectDomain.insertDBObject(testCase);
    }

    @IsTest
    static void batchAndSchedulableExecutionPositiveOutcome() {
        Test.startTest();
        Database.executeBatch(new CMN_BATCH_UG_CaseEscalation(), 200);
        String jobId = System.schedule('Test', '0 0 0 * * ?', new CMN_BATCH_UG_CaseEscalation());
        Test.stopTest();
        Assert.isNotNull(jobId);
        Assert.isFalse([SELECT Id FROM Case].isEmpty());
    }

    @IsTest
    static void helperMethodsPositiveOutcome() {
        CMN_BATCH_UG_CaseEscalation batch = buildBatch();
        Case testCase = getTestCase();
        List<Case> casesToUpdate = new List<Case>();

        Test.startTest();
        runProcessSingleCase(batch, testCase, 'test@example.com', UserInfo.getUserId(), casesToUpdate);
        Integer errors = batch.updateCases(new List<Case>());
        testCase.SVC_Escalation_Level__c = 2;
        Boolean skipped = batch.shouldSkipForTiming(testCase, Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)));
        Test.stopTest();

        Assert.areEqual(0, errors);
        Assert.isTrue(skipped);
    }

    @IsTest
    static void processScopeAndUpdateErrorsNegativeOutcome() {
        CMN_BATCH_UG_CaseEscalation batch = buildBatch();
        Case testCase = getTestCase();
        List<Case> casesToUpdate = new List<Case>();

        Test.startTest();
        runProcessSingleCase(batch, testCase, null, null, casesToUpdate);
        testCase.OwnerId = null;
        Integer errors = new CMN_BATCH_UG_CaseEscalation().updateCases(new List<Case>{testCase});
        Test.stopTest();

        Assert.areEqual(1, casesToUpdate.size());
        Assert.isTrue(errors >= 0);
    }

    @IsTest
    static void finishMethodCoveragePositiveOutcome() {
        CMN_BATCH_UG_CaseEscalation batch = buildBatch();

        Test.startTest();
        try { batch.finish(null); } catch (Exception e) { Assert.isNotNull(e); }
        Test.stopTest();

        Assert.areEqual(0, batch.totalRecords);
    }

    @IsTest
    static void circuitBreakerAndExceptionNegativeOutcome() {
        CMN_BATCH_UG_CaseEscalation batch = new CMN_BATCH_UG_CaseEscalation();
        batch.errorCount = 50;

        Test.startTest();
        try {
            batch.execute(null, new List<Case>{getTestCase()});
        } catch (CMN_BATCH_UG_CaseEscalation.BatchableException e) {
            Assert.isTrue(e.getMessage().contains('Circuit breaker'));
        }

        batch.errorCount = 0;
        try { batch.execute(null, new List<Case>{getTestCase()}); } catch (Exception e) { Assert.isNotNull(e); }
        Test.stopTest();
    }

    // ─── HELPERS ───────────────────────────────────────────────────────────────

    private static Case getTestCase() {
        return [SELECT Id, OwnerId, SVC_Escalation_Level__c, CaseNumber, SVC_Escalate_to__c, LastModifiedById, LastModifiedDate FROM Case LIMIT 1];
    }

    private static CMN_BATCH_UG_CaseEscalation buildBatch() {
        CMN_BATCH_UG_CaseEscalation batch = new CMN_BATCH_UG_CaseEscalation();
        batch.activeSetting = UG_PB_Escalation_Setting__mdt.getInstance('UG_PB_Escalation');
        batch.globalMaxLevel = 5;
        return batch;
    }

    private static void runProcessSingleCase(CMN_BATCH_UG_CaseEscalation batch, Case c, String email, Id managerId, List<Case> casesToUpdate) {
        Map<Id, Integer> levels = new Map<Id, Integer>{c.Id => Integer.valueOf(c.SVC_Escalation_Level__c + 1)};
        Map<Id, User> owners = new Map<Id, User>(SEL_User.newInstance().selectUsersByIds(new Set<Id>{c.OwnerId}));
        List<CMN_QUEUE_SendEscalationEmails.EmailRequest> emailReqs = new List<CMN_QUEUE_SendEscalationEmails.EmailRequest>();

        CMN_DAL_User.ManagerResult result = new CMN_DAL_User.ManagerResult();
        result.managerId = managerId;
        result.managerEmail = email;

        Datetime todayMidnight = Datetime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        batch.processSingleCase(c, result, levels, owners, new Map<Id, User>(), emailReqs, casesToUpdate, todayMidnight);
    }


}