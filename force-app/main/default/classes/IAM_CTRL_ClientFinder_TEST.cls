/**
 * @description             : Test class for IAM_CTRL_ClientFinder
 * @story                   : SFP-55927
 * @author                  : Preetham
 * @created date            : 2026-07-21
 */
@IsTest
private class IAM_CTRL_ClientFinder_TEST {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String TEST_ACCOUNT_NAME = 'ClientFinderTestAccount';
    private static final String TEST_CIF = 'CFTESTCIF001';
    private static final String TEST_REG_NUMBER = 'REG001';
    private static final Integer BULK_ACCOUNT_COUNT = 75;

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setupData() {
        // Minimal Account insert — avoid Person Account fields
        // (FirstName, LastName, PersonEmail) which require a
        // RecordTypeId in this org and cause INVALID_FIELD_FOR_INSERT_UPDATE.
        Account testAccount = new Account(
            Name = TEST_ACCOUNT_NAME,
            ExternalCIFId__c = TEST_CIF,
            Registration_number__c = TEST_REG_NUMBER,
            Phone = '1234567890'
        );
        insert testAccount;
    }

    // =========================================================================
    // TEST HELPERS
    // =========================================================================

    /**
     * @description Returns the developer name of the first available
     *              IAM record type on Account, or null if none exists.
     */
    private static String getAnyIamRecordTypeDevName() {
        for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (rtInfo.isAvailable() && !rtInfo.isMaster()
                && rtInfo.getDeveloperName().startsWith('IAM_')) {
                return rtInfo.getDeveloperName();
            }
        }
        return null;
    }

    /**
     * @description Builds a minimal SearchRequest with the given
     *              record type developer name and no search criteria.
     */
    private static IAM_CTRL_ClientFinder.SearchRequest buildEmptyRequest(
        String recordTypeDevName
    ) {
        IAM_CTRL_ClientFinder.SearchRequest req = new IAM_CTRL_ClientFinder.SearchRequest();
        req.recordTypeDeveloperName = recordTypeDevName;
        return req;
    }

    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================

    @IsTest
    static void getAvailableRecordTypes_returnsOnlyIamRecordTypes() {
        Test.startTest();
        List<IAM_CTRL_ClientFinder.RecordTypeOption> options =
            IAM_CTRL_ClientFinder.getAvailableRecordTypes();
        Test.stopTest();

        for (IAM_CTRL_ClientFinder.RecordTypeOption option : options) {
            Assert.isTrue(
                option.developerName.startsWith('IAM_')
                || option.developerName.startsWith('IAM'),
                'Expected only IAM-prefixed record types, got: '
                + option.developerName
            );
            Assert.isNotNull(option.id, 'Record type id should be populated');
            Assert.isNotNull(option.label, 'Record type label should be populated');
            Assert.isTrue(option.isIAM, 'isIAM flag should be true for IAM record types');
        }
    }

    @IsTest
    static void searchAccounts_byName_returnsResults() {
        String rtDevName = getAnyIamRecordTypeDevName();

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.accountName = TEST_ACCOUNT_NAME;

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a result list');
        Assert.isTrue(results.size() >= 1, 'Should find the test account by name');
        Assert.areEqual(
            TEST_ACCOUNT_NAME, results[0].name,
            'Result name should match the inserted account'
        );
    }

    @IsTest
    static void searchAccounts_byExternalCif_returnsResults() {
        String rtDevName = getAnyIamRecordTypeDevName();

        // Query the actual ExternalCIFId__c value post-insert because
        // org-level automation may overwrite it on save.
        Account insertedAcc = [SELECT ExternalCIFId__c FROM Account WHERE Name = :TEST_ACCOUNT_NAME LIMIT 1];

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.externalCIFId = insertedAcc.ExternalCIFId__c;

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a result list');
        Assert.isTrue(results.size() >= 1,
            'Should find the test account by its stored ExternalCIFId');
        Assert.areEqual(TEST_ACCOUNT_NAME, results[0].name,
            'Result name should match the inserted account');
    }

    @IsTest
    static void searchAccounts_byNameAndCif_returnsResults() {
        String rtDevName = getAnyIamRecordTypeDevName();

        // Use the name (which we control) alongside CIF; verify the
        // result count without asserting the exact CIF value since
        // org automation may alter it.
        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.accountName = TEST_ACCOUNT_NAME;
        request.externalCIFId = TEST_CIF;

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a result list');
        Assert.areEqual(1, results.size(),
            'Only the inserted test account should match combined Name + CIF filter');
        Assert.areEqual(TEST_ACCOUNT_NAME, results[0].name,
            'Result name should match');
    }

    @IsTest
    static void searchAccounts_resultFieldsArePopulated() {
        String rtDevName = getAnyIamRecordTypeDevName();

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.accountName = TEST_ACCOUNT_NAME;

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(results.size() > 0, 'Should return at least one result');
        IAM_CTRL_ClientFinder.AccountSearchResult first = results[0];

        Assert.isNotNull(first.id, 'Account Id should be populated');
        Assert.areEqual(TEST_ACCOUNT_NAME, first.name, 'Name should match');
        Assert.isNotNull(first.externalCIFId, 'ExternalCIFId should be populated');
        Assert.isNotNull(first.recordTypeId, 'RecordTypeId should be populated');
        Assert.isNotNull(first.accountRecordType, 'AccountRecordType should be populated');
    }

    @IsTest
    static void searchAccounts_byRegistrationNumber_returnsMatch() {
        String rtDevName = getAnyIamRecordTypeDevName();

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.registrationNumber = TEST_REG_NUMBER;

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(results.size() >= 1,
            'Should find the test account by registration number');
        Assert.areEqual(TEST_REG_NUMBER, results[0].registrationNumber,
            'Registration number should match');
    }

    @IsTest
    static void searchAccounts_byPhone_returnsMatch() {
        String rtDevName = getAnyIamRecordTypeDevName();

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.contactNumber = '1234567890';

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(results.size() >= 1,
            'Should find the test account by phone number');
        Assert.areEqual('1234567890', results[0].contactNumber,
            'Phone should match');
    }

    // =========================================================================
    // NEGATIVE TESTS
    // =========================================================================

    @IsTest
    static void searchAccounts_noSearchCriteria_throwsException() {
        String rtDevName = getAnyIamRecordTypeDevName();
        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);

        Test.startTest();
        try {
            IAM_CTRL_ClientFinder.searchAccounts(request);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }

    @IsTest
    static void searchAccounts_noRecordType_throwsException() {
        IAM_CTRL_ClientFinder.SearchRequest request = new IAM_CTRL_ClientFinder.SearchRequest();
        request.accountName = TEST_ACCOUNT_NAME;

        Test.startTest();
        try {
            IAM_CTRL_ClientFinder.searchAccounts(request);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }

    @IsTest
    static void searchAccounts_nullRequest_throwsException() {
        Test.startTest();
        try {
            IAM_CTRL_ClientFinder.searchAccounts(null);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }

    @IsTest
    static void searchAccounts_noResults_returnsEmptyList() {
        String rtDevName = getAnyIamRecordTypeDevName();

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.accountName = 'ZZZZZNoAccountShouldMatchThisZZZZZ';

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a list, not null');
        Assert.areEqual(0, results.size(),
            'No results should match an impossible search term');
    }

    // =========================================================================
    // BULK TEST
    // =========================================================================

    @IsTest
    static void searchAccounts_bulkTest_respectsResultLimit() {
        String rtDevName = getAnyIamRecordTypeDevName();

        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < BULK_ACCOUNT_COUNT; i++) {
            Account a = new Account(
                Name = 'BulkTest' + i,
                Phone = '9999999999'
            );
            bulkAccounts.add(a);
        }
        insert bulkAccounts;

        IAM_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(rtDevName);
        request.contactNumber = '9999999999';

        Test.startTest();
        List<IAM_CTRL_ClientFinder.AccountSearchResult> results =
            IAM_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a result list');
        Assert.isTrue(
            results.size() <= 50,
            'Results should be capped at 50, got: ' + results.size()
        );
        Assert.isTrue(results.size() > 0,
            'Should find at least some bulk test accounts');
    }
}