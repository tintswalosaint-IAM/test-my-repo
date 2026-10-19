/**
* @description       : Test class for INS_CTRL_CaseElapsedTimeInBusinessHours
* @author            : Given Khupai
* @last modified on  : 07-16-2026
* @LastModified by   : Given Khupai
* @LastModifiedReason: SFP-55625 Initial test class with full coverage
*                      including catch block paths via mockForceException
**/
@isTest
private class INS_CTRL_CaseElapsedTimeBusinessHr_TEST {

    private static final String TEST_CASE_SUBJECT = 'Test Controller Case';

    @testSetup
    static void setup() {
        /* Guard arrange-phase Case DML with the TaT access mock so the real SVC_TRH_Case
           afterUpdate processing can't create a competing CMN_CaseMilestoneMetric__c
           record if the SIT org's own automation issues an update DML on the new Case. */
        INS_UTIL_BusinessHoursCalcHelper.mockHasAccessResult = false;

        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = testAccount.Id);
        insert testContact;

        Case testCase = new Case(Subject = TEST_CASE_SUBJECT, Status = 'New', ContactId = testContact.Id, AccountId = testAccount.Id);
        insert testCase;

        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c(CMN_Case__c = testCase.Id);
        insert metric;
    }

    // ─── retrieveCaseDetails tests ─────────────────────────────

    @isTest
    static void retrieveCaseDetailsPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        Test.startTest();
        Case result = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(testCase.Id);
        Test.stopTest();
        Assert.isNotNull(result, 'Should return the Case record');
        Assert.areEqual(testCase.Id, result.Id, 'Returned Case Id should match');
    }

    @isTest
    static void retrieveCaseDetailsNullIdPositiveOutcome() {
        Test.startTest();
        Case result = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(null);
        Test.stopTest();
        Assert.isNull(result, 'Should return null for null caseId');
    }

    @isTest
    static void retrieveCaseDetailsExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseDetails(testCase.Id);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── retrieveCaseMetricsDetails tests ──────────────────────

    @isTest
    static void retrieveCaseMetricsDetailsPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        Test.startTest();
        CMN_CaseMilestoneMetric__c result = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseMetricsDetails(testCase.Id);
        Test.stopTest();
        Assert.isNotNull(result, 'Should return a metric record');
        Assert.areEqual(testCase.Id, result.CMN_Case__c, 'Metric should reference correct Case');
    }

    @isTest
    static void retrieveCaseMetricsDetailsNoMetricPositiveOutcome() {
        INS_UTIL_BusinessHoursCalcHelper.mockHasAccessResult = false;

        Account acc = new Account(Name = 'No Metric Account');
        insert acc;
        Case noMetricCase = new Case(Subject = 'No Metric', Status = 'New', AccountId = acc.Id);
        insert noMetricCase;
        Test.startTest();
        CMN_CaseMilestoneMetric__c result = INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseMetricsDetails(noMetricCase.Id);
        Test.stopTest();
        Assert.isNull(result, 'Should return null when no metric exists');
    }

    @isTest
    static void retrieveCaseMetricsDetailsExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.retrieveCaseMetricsDetails(testCase.Id);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── calculateCaseSlaMetrics tests ─────────────────────────

    @isTest
    static void calculateCaseSlaMetricsPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData rd = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        rd.BusinessHoursId = bh.Id;
        rd.CreatedDate = DateTime.now().addHours(-2);
        rd.ClosedDate = DateTime.now();
        Test.startTest();
        INS_UTIL_BusinessHoursCalcHelper.SlaMetricsInBusinessHours result = INS_CTRL_CaseElapsedTimeInBusinessHours.calculateCaseSlaMetrics(rd);
        Test.stopTest();
        Assert.isNotNull(result, 'Should return SLA metrics');
        Assert.isNotNull(result.printFormattedTAT, 'Formatted TAT should not be null');
    }

    @isTest
    static void calculateCaseSlaMetricsExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData rd = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.calculateCaseSlaMetrics(rd);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── elapsedMilliSeconds tests ─────────────────────────────

    @isTest
    static void elapsedMilliSecondsPositiveOutcome() {
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = true LIMIT 1];
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData rd = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        rd.BusinessHoursId = bh.Id;
        rd.CreatedDate = DateTime.now().addHours(-1);
        rd.ClosedDate = DateTime.now();
        Test.startTest();
        Long result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(rd);
        Test.stopTest();
        Assert.isTrue(result >= 0, 'Should return non-negative milliseconds');
    }

    @isTest
    static void elapsedMilliSecondsExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData rd = new INS_CTRL_CaseElapsedTimeInBusinessHours.RequestData();
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMilliSeconds(rd);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── elapsedHoursTAT tests ─────────────────────────────────

    @isTest
    static void elapsedHoursTATPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(7200000L);
        Test.stopTest();
        Assert.areEqual(2, result, 'Should return 2 hours');
    }

    @isTest
    static void elapsedHoursTATNullPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void elapsedHoursTATExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedHoursTAT(7200000L);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── elapsedMinutesTAT tests ───────────────────────────────

    @isTest
    static void elapsedMinutesTATPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(5400000L);
        Test.stopTest();
        Assert.areEqual(30, result, 'Should return 30 minutes');
    }

    @isTest
    static void elapsedMinutesTATNullPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void elapsedMinutesTATExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedMinutesTAT(5400000L);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── elapsedSecondsTAT tests ───────────────────────────────

    @isTest
    static void elapsedSecondsTATPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(105000L);
        Test.stopTest();
        Assert.areEqual(45, result, 'Should return 45 seconds');
    }

    @isTest
    static void elapsedSecondsTATNullPositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(null);
        Test.stopTest();
        Assert.areEqual(0, result, 'Should return 0 for null input');
    }

    @isTest
    static void elapsedSecondsTATExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.elapsedSecondsTAT(105000L);
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    // ─── getMetaDataType tests ─────────────────────────────────

    @isTest
    static void getMetaDataTypePositiveOutcome() {
        Test.startTest();
        Integer result = INS_CTRL_CaseElapsedTimeInBusinessHours.getMetaDataType();
        Test.stopTest();
        Assert.isTrue(result > 0, 'Should return a positive frequency value');
    }

    @isTest
    static void getMetaDataTypeExceptionPositiveOutcome() {
        INS_CTRL_CaseElapsedTimeInBusinessHours.mockForceException = true;
        Test.startTest();
        try {
            INS_CTRL_CaseElapsedTimeInBusinessHours.getMetaDataType();
            Assert.fail('Should have thrown AuraHandledException');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
}