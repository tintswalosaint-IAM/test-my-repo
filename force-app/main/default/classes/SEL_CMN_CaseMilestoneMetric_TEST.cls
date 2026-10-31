/**
* @description       : SFP-55625 Test class for SEL_CMN_CaseMilestoneMetric selector
* @author            : Given Khupai
* @last modified on  : 07-16-2026
* @LastModified by   : Given Khupai
* @LastModifiedReason: SFP-61347 Removed stale mockHasAccessResult reference (method removed from INS_UTIL_BusinessHoursCalcHelper)
**/
@isTest
private class SEL_CMN_CaseMilestoneMetric_TEST {

    private static final String TEST_CASE_SUBJECT = 'Test Milestone Metric Case';

    @testSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        Case testCase = new Case(
            Subject = TEST_CASE_SUBJECT,
            Status = 'New',
            ContactId = testContact.Id,
            AccountId = testAccount.Id
        );
        insert testCase;

        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c(
            CMN_Case__c = testCase.Id
        );
        insert metric;
    }

    @isTest
    static void newInstancePositiveOutcome() {
        Test.startTest();
            SEL_CMN_CaseMilestoneMetric selector = SEL_CMN_CaseMilestoneMetric.newInstance();
        Test.stopTest();

        Assert.isNotNull(selector, 'Selector instance should not be null');
    }

    @isTest
    static void getSObjectTypePositiveOutcome() {
        Test.startTest();
            Schema.SObjectType sObjType = SEL_CMN_CaseMilestoneMetric.newInstance().getSObjectType();
        Test.stopTest();

        Assert.areEqual(
            CMN_CaseMilestoneMetric__c.SObjectType,
            sObjType,
            'SObject type should be CMN_CaseMilestoneMetric__c'
        );
    }

    @isTest
    static void getSObjectFieldListPositiveOutcome() {
        Test.startTest();
            List<Schema.SObjectField> fields = SEL_CMN_CaseMilestoneMetric.newInstance().getSObjectFieldList();
        Test.stopTest();

        Assert.isFalse(fields.isEmpty(), 'Field list should not be empty');
        Assert.isTrue(
            fields.contains(CMN_CaseMilestoneMetric__c.CMN_Case__c),
            'Field list should contain CMN_Case__c'
        );
        // Regression guard: INS_SRV_CaseMilestoneMetrics.isReadyForClassificationUpdate() reads
        // these two fields directly off selector-queried records. If they are ever missing from
        // this list, that read throws SObjectException, which the caller's catch block swallows
        // silently - so existing metric records silently stop receiving classification/resolution
        // updates with no visible error.
        Assert.isTrue(
            fields.contains(CMN_CaseMilestoneMetric__c.CMN_CaseAllocationTurnaroundTime__c),
            'Field list should contain CMN_CaseAllocationTurnaroundTime__c'
        );
        Assert.isTrue(
            fields.contains(CMN_CaseMilestoneMetric__c.CMN_CreationToAllocationMillisecond__c),
            'Field list should contain CMN_CreationToAllocationMillisecond__c'
        );
    }

    @isTest
    static void selectByIdPositiveOutcome() {
        CMN_CaseMilestoneMetric__c metric = [
            SELECT Id FROM CMN_CaseMilestoneMetric__c LIMIT 1
        ];

        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectById(new Set<Id>{ metric.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return exactly one record');
        Assert.areEqual(metric.Id, results[0].Id, 'Returned record Id should match');
    }

    @isTest
    static void selectByIdExceptionIsLoggedAndRethrown() {
        CMN_CaseMilestoneMetric__c metric = [
            SELECT Id FROM CMN_CaseMilestoneMetric__c LIMIT 1
        ];
        SEL_CMN_CaseMilestoneMetric.forceSelectByIdException = true;
        Boolean exceptionThrown = false;

        Test.startTest();
            try {
                SEL_CMN_CaseMilestoneMetric.newInstance().selectById(new Set<Id>{ metric.Id });
            } catch (System.QueryException ex) {
                exceptionThrown = true;
            }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should have been re-thrown after logging');
    }

    @isTest
    static void selectByIdEmptySetPositiveOutcome() {
        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectById(new Set<Id>());
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for empty Id set');
    }

    @isTest
    static void selectByCaseIdsPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(new Set<Id>{ testCase.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one metric for the test case');
        Assert.areEqual(testCase.Id, results[0].CMN_Case__c, 'Returned metric should reference the correct Case');
    }

    @isTest
    static void selectByCaseIdsExceptionIsLoggedAndRethrown() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];
        SEL_CMN_CaseMilestoneMetric.forceSelectByCaseIdsException = true;
        Boolean exceptionThrown = false;

        Test.startTest();
            try {
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(new Set<Id>{ testCase.Id });
            } catch (System.QueryException ex) {
                exceptionThrown = true;
            }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Exception should have been re-thrown after logging');
    }

    @isTest
    static void selectByCaseIdsNullInputPositiveOutcome() {
        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(null);
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for null input');
    }

    @isTest
    static void selectByCaseIdsEmptySetPositiveOutcome() {
        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(new Set<Id>());
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for empty set');
    }

    @isTest
    static void selectByCaseIdsOrderingPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        CMN_CaseMilestoneMetric__c secondMetric = new CMN_CaseMilestoneMetric__c(
            CMN_Case__c = testCase.Id
        );
        insert secondMetric;

        Test.startTest();
            List<CMN_CaseMilestoneMetric__c> results =
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(new Set<Id>{ testCase.Id });
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Should return two metrics');
        Assert.isTrue(
            results[0].CreatedDate >= results[1].CreatedDate,
            'Results should be ordered by CreatedDate descending'
        );
    }
}