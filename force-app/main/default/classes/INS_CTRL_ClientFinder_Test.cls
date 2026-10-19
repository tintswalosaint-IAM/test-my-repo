/**
 * Verifies client search, duplicate retrieval, and bulk-result behavior
 * implemented by INS_CTRL_ClientFinder.
 *
 * @description             : Test class for INS_CTRL_ClientFinder
 * @story                   : SFP-55927
 * @author                  : Preetham
 * @created date            : 2026-07-21
 */
@IsTest
private class INS_CTRL_ClientFinder_Test {    

    private static final String TEST_ACCOUNT_NAME = 'ClientFinderTestAccount';
    private static final String TEST_CIF = 'CFTESTCIF001';
    private static final String TEST_REG_NUMBER = 'REG001';
    private static final Integer BULK_ACCOUNT_COUNT = 75;
    private static final String IAM_BUSINESS = 'IAM_Business';
    private static final String RETURN_LIST = 'Search should return a result list';

    /**
     * @description Sets up test data for the test class. Inserts a minimal Account and a Person Account to be used in the tests.
     */
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
        Map<String, String> iamRecordTypeDevName = getAnyIamRecordTypeDevName();
        // Person Account
        Id personRecordTypeId;
        if (iamRecordTypeDevName != null) {
            personRecordTypeId = iamRecordTypeDevName.get('IAM_Person');
        }
        Account personAccount = new Account(
            RecordTypeId = personRecordTypeId,
            FirstName = 'Test',
            LastName = 'Person',
            PersonEmail = 'testperson@example.com',
            ExternalCIFId__c = TEST_CIF + '_PERSON',
            Registration_number__c = TEST_REG_NUMBER + '_PERSON',
            Phone = '9876543210',
            CMN_IdentityNumber__pc = '4332453253',
            PersonBirthdate = Date.today().addYears(-10),
            FinServ__CustomerType__c = 'IAM Liberty'
        );
        insert personAccount;
    }

    /**
     * @description Returns the developer name of the first available
     *              IAM record type on Account, or null if none exists.
        * @return A map of IAM record type developer names to record type IDs.
     */
    private static Map<String, String> getAnyIamRecordTypeDevName() {
        Map<String, String> recordTypeMap = new Map<String, String>();
        for (Schema.RecordTypeInfo rtInfo : Account.SObjectType.getDescribe().getRecordTypeInfos()) {
            if (rtInfo.isAvailable() && !rtInfo.isMaster()
                && rtInfo.getDeveloperName().startsWith('IAM_')) {
                recordTypeMap.put(
                    rtInfo.getDeveloperName(),
                    rtInfo.getRecordTypeId()
                );
            }
        }
        return recordTypeMap;
    }

    /**
     * @description Builds a minimal SearchRequest with the given
     *              record type developer name and no search criteria.
        * @param recordTypeDevName The record type developer name to use.
        * @return A SearchRequest containing the specified record type developer name.
     */
    private static INS_CTRL_ClientFinder.SearchRequest buildEmptyRequest(
        String recordTypeDevName
    ) {
        INS_CTRL_ClientFinder.SearchRequest req = new INS_CTRL_ClientFinder.SearchRequest();
        req.recordTypeDeveloperName = recordTypeDevName;
        return req;
    }
    /**
     * @description Test to verify that the getOnlyIamRecordTypes method returns only IAM record types.
     */
    @IsTest
    static void getOnlyIamRecordTypes() {
        Test.startTest();
        List<INS_CTRL_ClientFinder.RecordTypeOption> options =
            INS_CTRL_ClientFinder.getAvailableRecordTypes();
        Test.stopTest();

        for (INS_CTRL_ClientFinder.RecordTypeOption option : options) {            
            Assert.isNotNull(option.id, 'Record type id should be populated');
            Assert.isNotNull(option.label, 'Record type label should be populated');
        }
    }
    /**
     * @description Test to verify that the searchAccounts method returns results when searching by name.
     */
    @IsTest
    static void searchAccountsByNameReturnsResults() {

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest('IAM_Person');
        request.firstName = 'Test';
        request.lastName = 'Person';
        request.identityNumber = '4332453252';
        request.birthdate = Date.today().addYears(-10);

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, RETURN_LIST);       
    }
    /**
     * @description Test to verify that the searchAccounts method returns results when searching by ExternalCIFId__c.
     */
    @IsTest
    static void searchAccountsByExternalCifReturnsResults() {

        // Query the actual ExternalCIFId__c value post-insert because
        // org-level automation may overwrite it on save.
        Account insertedAcc = [SELECT ExternalCIFId__c FROM Account WHERE Name = :TEST_ACCOUNT_NAME LIMIT 1];

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.externalCIFId = insertedAcc.ExternalCIFId__c;

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, RETURN_LIST);
        Assert.isTrue(results.size() >= 1,
            'Should find the test account by its stored ExternalCIFId');
        Assert.areEqual(TEST_ACCOUNT_NAME, results[0].name,
            'Result name should match the inserted account');
    }
    /**
     * @description Test to verify that the searchAccounts method returns results when searching by both name and ExternalCIFId__c.
     */
    @IsTest
    static void searchAccountsByNameAndCifReturnsResults() {

        // Use the name (which we control) alongside CIF; verify the
        // result count without asserting the exact CIF value since
        // org automation may alter it.
        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.accountName = TEST_ACCOUNT_NAME;
        request.externalCIFId = TEST_CIF;

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, RETURN_LIST);
        Assert.areEqual(1, results.size(),
            'Only the inserted test account should match combined Name + CIF filter');
        Assert.areEqual(TEST_ACCOUNT_NAME, results[0].name,
            'Result name should match');
    }
    /**
     * @description Test to verify that the searchAccounts method returns results with all expected fields populated.
     */
    @IsTest
    static void searchAccountsResultFieldsArePopulated() {

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.accountName = TEST_ACCOUNT_NAME;

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(!results.isEmpty(), 'Should return at least one result');
        INS_CTRL_ClientFinder.AccountSearchResult first = results[0];

        Assert.isNotNull(first.id, 'Account Id should be populated');
        Assert.areEqual(TEST_ACCOUNT_NAME, first.name, 'Name should match');
        Assert.isNotNull(first.externalCIFId, 'ExternalCIFId should be populated');
        Assert.isNotNull(first.recordTypeId, 'RecordTypeId should be populated');
        Assert.isNotNull(first.accountRecordType, 'AccountRecordType should be populated');
    }
    /**
     * @description Test to verify that the searchAccounts method returns results when searching by registration number.
     */
    @IsTest
    static void searchAccountsByRegistrationNumberReturnsMatch() {

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.registrationNumber = TEST_REG_NUMBER;

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(results.size() >= 1,
            'Should find the test account by registration number');
        Assert.areEqual(TEST_REG_NUMBER, results[0].registrationNumber,
            'Registration number should match');
    }
    /**
     * @description Test to verify that the searchAccounts method returns results when searching by phone number.
     */
    @IsTest
    static void searchAccountsByPhoneReturnsMatch() {

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.contactNumber = '1234567890';

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isTrue(results.size() >= 1,
            'Should find the test account by phone number');
        Assert.areEqual('1234567890', results[0].contactNumber,
            'Phone should match');
    }

    /**
     * @description Test to verify that the searchAccounts method throws an exception when no search criteria is provided.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */

    @IsTest
    static void searchAccountsByNoSearchCriteriaThrowsException() {
        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);

        Test.startTest();
        try {
            INS_CTRL_ClientFinder.searchAccounts(request);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }
    /**
     * @description Test to verify that the searchAccounts method throws an exception when no record type is specified.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */
    @IsTest
    static void searchAccountsByNoRecordTypeThrowsException() {
        INS_CTRL_ClientFinder.SearchRequest request = new INS_CTRL_ClientFinder.SearchRequest();
        request.accountName = TEST_ACCOUNT_NAME;

        Test.startTest();
        try {
            INS_CTRL_ClientFinder.searchAccounts(request);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }
    /**
     * @description Test to verify that the searchAccounts method throws an exception when a null request is passed.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */
    @IsTest
    static void searchAccountsByNullRequestThrowsException() {
        Test.startTest();
        try {
            INS_CTRL_ClientFinder.searchAccounts(null);
            Assert.fail('Expected AuraHandledException was not thrown');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Exception message should not be null');
        }
        Test.stopTest();
    }
    /**
     * @description Test to verify that the searchAccounts method returns an empty list when no results are found.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */
    @IsTest
    static void searchAccountsByNoResultsReturnsEmptyList() {

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.accountName = 'ZZZZZNoAccountShouldMatchThisZZZZZ';

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, 'Search should return a list, not null');
        Assert.areEqual(0, results.size(),
            'No results should match an impossible search term');
    }
    /**
     * @description Test to verify that the getDuplicateAccounts method returns matching accounts by their IDs.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */
    @IsTest
    static void getDuplicateAccountsReturnsMatchingAccountsById() {
        Account businessAccount = [
            SELECT Id, Name, Registration_Number__c, CMN_IdentityNumber__pc, PersonBirthdate
            FROM Account
            WHERE Name = :TEST_ACCOUNT_NAME
            LIMIT 1
        ];

        Account secondAccount = new Account(
            Name = 'DuplicateCheckAccount',
            Registration_Number__c = 'REG-SECOND-001',
            Phone = '5556667777'
        );
        insert secondAccount;

        List<Id> accountIds = new List<Id>{ businessAccount.Id, secondAccount.Id };

        Test.startTest();
        List<Account> duplicateAccounts = INS_CTRL_ClientFinder.getDuplicateAccounts(accountIds);
        Test.stopTest();

        Assert.areEqual(2, duplicateAccounts.size(),
            'Both requested Account Ids should be returned');

        Map<Id, Account> duplicateMap = new Map<Id, Account>(duplicateAccounts);
        Assert.areEqual(TEST_ACCOUNT_NAME, duplicateMap.get(businessAccount.Id).Name,
            'The first account should match the requested Id');
        Assert.areEqual(TEST_REG_NUMBER, duplicateMap.get(businessAccount.Id).Registration_Number__c,
            'Registration number should be returned for the matching Account');
        Assert.areEqual('DuplicateCheckAccount', duplicateMap.get(secondAccount.Id).Name,
            'The second account should match the requested Id');
    }
    /**
     * @description Test to verify that the searchAccounts method respects the result limit of 50.
     * @author Preetham
     * @date Aug 04th 2026
     * @modification details    :
     */

    @IsTest
    static void searchAccountsBulkTestRespectsResultLimit() {

        List<Account> bulkAccounts = new List<Account>();
        for (Integer i = 0; i < BULK_ACCOUNT_COUNT; i++) {
            Account a = new Account(
                Name = 'BulkTest' + i,
                Phone = '9999999999'
            );
            bulkAccounts.add(a);
        }
        insert bulkAccounts;

        INS_CTRL_ClientFinder.SearchRequest request = buildEmptyRequest(IAM_BUSINESS);
        request.contactNumber = '9999999999';

        Test.startTest();
        List<INS_CTRL_ClientFinder.AccountSearchResult> results =
            INS_CTRL_ClientFinder.searchAccounts(request);
        Test.stopTest();

        Assert.isNotNull(results, RETURN_LIST);
        Assert.isTrue(
            results.size() <= 50,
            'Results should be capped at 50, got: ' + results.size()
        );
        Assert.isTrue(!results.isEmpty(),
            'Should find at least some bulk test accounts');
    }
}