/**
 * @description Test class for the SEL_CMN_HistoryTracker selector.
 *              <br/>SFP-51816
 *
 * @author Given Khupai
 *
 * @date September 2026
 */
@isTest
private class SEL_CMN_HistoryTracker_TEST {

    private static final String TEST_CASE_SUBJECT = 'Test History Tracker Case';

    /**
     * @description Creates a Case with one History Tracker record
     */
    @testSetup
    static void setup() {
        Account testAccount = new Account(Name = 'Test Account History Tracker');
        insert testAccount;

        Case testCase = new Case(
            Subject = TEST_CASE_SUBJECT,
            Status = 'New',
            AccountId = testAccount.Id
        );
        insert testCase;

        CMN_History_Tracker__c tracker = new CMN_History_Tracker__c(
            CMN_Case__c = testCase.Id,
            CMN_TransferDate__c = System.now(),
            CMN_PreviousOwnerType__c = 'User',
            CMN_PreviousOwnerUser__c = UserInfo.getUserId(),
            CMN_CurrentOwnerType__c = 'User',
            CMN_CurrentOwnerUser__c = UserInfo.getUserId(),
            CMN_TransferCount__c = 1
        );
        insert tracker;
    }

    /**
     * @description Verifies newInstance() returns a selector
     */
    @isTest
    static void newInstancePositiveOutcome() {
        Test.startTest();
            SEL_CMN_HistoryTracker selector = SEL_CMN_HistoryTracker.newInstance();
        Test.stopTest();

        Assert.isNotNull(selector, 'Selector instance should not be null');
    }

    /**
     * @description Verifies the selector reports CMN_History_Tracker__c as its SObject type
     */
    @isTest
    static void getSObjectTypePositiveOutcome() {
        Test.startTest();
            Schema.SObjectType sObjType = SEL_CMN_HistoryTracker.newInstance().getSObjectType();
        Test.stopTest();

        Assert.areEqual(
            CMN_History_Tracker__c.SObjectType,
            sObjType,
            'SObject type should be CMN_History_Tracker__c'
        );
    }

    /**
     * @description Verifies the default field list includes the fields the service reads
     */
    @isTest
    static void getSObjectFieldListPositiveOutcome() {
        Test.startTest();
            List<Schema.SObjectField> fields = SEL_CMN_HistoryTracker.newInstance().getSObjectFieldList();
        Test.stopTest();

        Assert.isFalse(fields.isEmpty(), 'Field list should not be empty');
        Assert.isTrue(
            fields.contains(CMN_History_Tracker__c.CMN_Case__c),
            'Field list should contain CMN_Case__c'
        );
        // Regression guard: INS_SRV_CaseTransferHistory reads CMN_TransferDate__c and
        // CMN_TransferCount__c directly off selector-queried records to calculate
        // the next transfer's count/duration. If either is ever missing from this
        // list, that read silently returns null instead of throwing, which would
        // reset every subsequent transfer's count back to 1.
        Assert.isTrue(
            fields.contains(CMN_History_Tracker__c.CMN_TransferDate__c),
            'Field list should contain CMN_TransferDate__c'
        );
        Assert.isTrue(
            fields.contains(CMN_History_Tracker__c.CMN_TransferCount__c),
            'Field list should contain CMN_TransferCount__c'
        );
    }

    /**
     * @description Verifies selectByCaseIds() returns the tracker for the given Case
     */
    @isTest
    static void selectByCaseIdsPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        Test.startTest();
            List<CMN_History_Tracker__c> results =
                SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(new Set<Id>{ testCase.Id });
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return one tracker for the test case');
        Assert.areEqual(testCase.Id, results[0].CMN_Case__c, 'Returned tracker should reference the correct Case');
    }

    /**
     * @description Verifies a null input returns an empty list
     */
    @isTest
    static void selectByCaseIdsNullInputPositiveOutcome() {
        Test.startTest();
            List<CMN_History_Tracker__c> results =
                SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(null);
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for null input');
    }

    /**
     * @description Verifies an empty set returns an empty list
     */
    @isTest
    static void selectByCaseIdsEmptySetPositiveOutcome() {
        Test.startTest();
            List<CMN_History_Tracker__c> results =
                SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(new Set<Id>());
        Test.stopTest();

        Assert.isTrue(results.isEmpty(), 'Should return empty list for empty set');
    }

    /**
     * @description Verifies results are ordered by Transfer Date, latest first
     */
    @isTest
    static void selectByCaseIdsOrderingPositiveOutcome() {
        Case testCase = [SELECT Id FROM Case WHERE Subject = :TEST_CASE_SUBJECT LIMIT 1];

        CMN_History_Tracker__c secondTracker = new CMN_History_Tracker__c(
            CMN_Case__c = testCase.Id,
            CMN_TransferDate__c = System.now().addHours(1),
            CMN_PreviousOwnerType__c = 'User',
            CMN_PreviousOwnerUser__c = UserInfo.getUserId(),
            CMN_CurrentOwnerType__c = 'User',
            CMN_CurrentOwnerUser__c = UserInfo.getUserId(),
            CMN_TransferCount__c = 2
        );
        insert secondTracker;

        Test.startTest();
            List<CMN_History_Tracker__c> results =
                SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(new Set<Id>{ testCase.Id });
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Should return two trackers');
        Assert.isTrue(
            results[0].CMN_TransferDate__c >= results[1].CMN_TransferDate__c,
            'Results should be ordered by CMN_TransferDate__c descending'
        );
    }
}