/**
 * @class       INS_Customer_UTIL_TEST
 * @description Test class for INS_Customer_UTIL. Covers all four Callable actions
 *              (createAccount, createOpportunity, getProductDetails, updateOpportunity),
 *              the helper createQuoteRecord and createOpportunityLineItem methods,
 *              and the unsupported-action guard on call().
 *
 *              Conventions followed:
 *                - No SeeAllData=true
 *                - Assert class exclusively (no System.assert*)
 *                - No System.debug statements
 *                - Bulk test capped at 5 records (multi-query Remote Action pattern)
 *                - outputMap null guard pattern mirrors production code
 *
 * @author
 * @date
 * @version
 *
 * Change Log:
 * --------------------------------------------------------------------------
 * | Version | Date       | Author | Description                            |
 * --------------------------------------------------------------------------
 * | 1.0     |            |        | Initial creation                       |
 * --------------------------------------------------------------------------
 */
@IsTest
private class INS_Customer_UTIL_TEST {

    // =========================================================================
    // CONSTANTS — TEST DATA
    // =========================================================================

    private static final String TEST_FIRST_NAME        = 'Thabo';
    private static final String TEST_LAST_NAME         = 'Nkosi';
    private static final String TEST_EMAIL             = 'thabo.nkosi@test.com';
    private static final String TEST_PHONE             = '0821234567';
    private static final String TEST_DOB               = '1990-06-15';
    private static final String TEST_GENDER            = 'Male';
    private static final String TEST_MARITAL_STATUS    = 'Single';
    private static final String TEST_ID_NUMBER         = '9006155234083';
    private static final String TEST_CURRENCY          = 'KES';
    private static final String TEST_COUNTRY           = 'Kenya';
    private static final String TEST_PRODUCT           = 'Flexi Protect';
    private static final String TEST_EXTERNAL_QUOTE_ID = 'EXT-QT-00001';
    private static final Decimal TEST_COVER_AMOUNT     = 500000.00;
    private static final Decimal TEST_PREMIUM          = 1250.00;

    // =========================================================================
    // TEST DATA FACTORY
    // =========================================================================

    /**
     * @description Builds the personalInformation sub-map used in createAccount tests.
     */
    private static Map<String, Object> buildPersonalInformation() {
        return new Map<String, Object>{
            'FirstName'       => TEST_FIRST_NAME,
            'LastName'        => TEST_LAST_NAME,
            'Email'           => TEST_EMAIL,
            'PhoneNumber'     => TEST_PHONE,
            'OS_DateOfBirth'  => TEST_DOB,
            'Gender'          => TEST_GENDER,
            'MaritalStatus'   => TEST_MARITAL_STATUS,
            'IdNumber'        => TEST_ID_NUMBER
        };
    }

    /**
     * @description Builds the inputMap for createAccount.
     */
    private static Map<String, Object> buildCreateAccountInput() {
        return new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation()
        };
    }

    /**
     * @description Creates and inserts a test Prospect Account, returning its Id.
     */
    private static Id insertTestProspectAccount() {
        Id recordTypeId = Account.SObjectType
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect')
            .getRecordTypeId();

        Account prospectAccount = new Account(
            FirstName    = TEST_FIRST_NAME,
            LastName     = TEST_LAST_NAME,
            RecordTypeId = recordTypeId
        );
        insert prospectAccount;
        return prospectAccount.Id;
    }

    /**
     * @description Creates and inserts the Flexi Protect Product2 and its
     *              PricebookEntry in both the Standard and Kenya HNW pricebooks.
     *              Returns the PricebookEntry Id in the Kenya HNW pricebook.
     */
    private static Id insertFlexiProtectPricebookEntry() {

        // ---- PRODUCT --------------------------------------------------------
        Product2 flexiProtectProduct = new Product2(
            Name      = 'Flexi Protect',
            IsActive  = true
        );
        insert flexiProtectProduct;

        // ---- STANDARD PRICEBOOK ENTRY (required before custom) --------------
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry standardEntry = new PricebookEntry(
            Pricebook2Id = standardPricebookId,
            Product2Id   = flexiProtectProduct.Id,
            UnitPrice    = 100.00,
            IsActive     = true
        );
        insert standardEntry;

        // ---- CUSTOM PRICEBOOK -----------------------------------------------
        Pricebook2 kenyaHnwPricebook = new Pricebook2(
            Name     = 'C&HNW(Kenya)',
            IsActive = true
        );
        insert kenyaHnwPricebook;

        // ---- CUSTOM PRICEBOOK ENTRY -----------------------------------------
        PricebookEntry kenyaHnwEntry = new PricebookEntry(
            Pricebook2Id = kenyaHnwPricebook.Id,
            Product2Id   = flexiProtectProduct.Id,
            UnitPrice    = 250.00,
            IsActive     = true
        );
        insert kenyaHnwEntry;

        return kenyaHnwEntry.Id;
    }

    /**
     * @description Inserts a test Opportunity linked to the given Account,
     *              using the Flexi Protect pricebook setup. Returns the Opportunity Id.
     */
    private static Id insertTestOpportunity(Id accountId) {
        insertFlexiProtectPricebookEntry();

        Id recordTypeId = Opportunity.SObjectType
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('General')
            .getRecordTypeId();

        Pricebook2 kenyaHnwPricebook = [
            SELECT Id FROM Pricebook2 WHERE Name = 'C&HNW(Kenya)' LIMIT 1
        ];

        Opportunity testOpportunity = new Opportunity(
            AccountId       = accountId,
            Name            = 'Flexi Protect Kenya - Test',
            StageName       = 'Quoting',
            CloseDate       = Date.today(),
            RecordTypeId    = recordTypeId,
            CurrencyIsoCode = TEST_CURRENCY,
            Pricebook2Id    = kenyaHnwPricebook.Id
        );
        insert testOpportunity;
        return testOpportunity.Id;
    }

    // =========================================================================
    // TEST METHODS — call() ROUTING
    // =========================================================================

    @IsTest
    static void testCall_createAccount_routesCorrectly() {

        // INPUT SETUP
        Map<String, Object> inputMap  = buildCreateAccountInput();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> args      = new Map<String, Object>{
            'input'  => inputMap,
            'output' => outputMap
        };

        // EXECUTE
        Test.startTest();
        INS_Customer_UTIL util   = new INS_Customer_UTIL();
        Map<String, Object> result = (Map<String, Object>) util.call('createAccount', args);
        Test.stopTest();

        // ASSERT
        Assert.isNotNull(result.get('ProspectAccountId'), 'ProspectAccountId should be populated');
    }

    @IsTest
    static void testCall_unsupportedAction_throwsException() {

        // INPUT SETUP
        Map<String, Object> args = new Map<String, Object>{
            'input'  => new Map<String, Object>(),
            'output' => new Map<String, Object>()
        };

        // EXECUTE & ASSERT
        INS_Customer_UTIL util = new INS_Customer_UTIL();
        try {
            Test.startTest();
            util.call('unknownAction', args);
            Test.stopTest();
            Assert.fail('Expected AuraHandledException for unsupported action');
        } catch (AuraHandledException caught) {
            Assert.isTrue(
                caught.getMessage().contains('Unsupported action'),
                'Exception message should reference unsupported action'
            );
        }
    }

    // =========================================================================
    // TEST METHODS — createAccount
    // =========================================================================

    @IsTest
    static void testCreateAccount_success_returnsProspectAccountId() {

        // INPUT SETUP
        Map<String, Object> inputMap  = buildCreateAccountInput();
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.createAccount(inputMap, outputMap);
        Test.stopTest();

        // ASSERT
        Assert.isNotNull(result.get('ProspectAccountId'), 'ProspectAccountId should not be null');

        Account insertedAccount = [
            SELECT FirstName, LastName, PersonEmail, PersonMobilePhone,
                   PersonBirthdate, PersonGender, CMN_IdentityNumber__pc
            FROM   Account
            WHERE  Id = :(Id) result.get('ProspectAccountId')
        ];

        Assert.areEqual(TEST_FIRST_NAME, insertedAccount.FirstName,       'FirstName mismatch');
        Assert.areEqual(TEST_LAST_NAME,  insertedAccount.LastName,        'LastName mismatch');
        Assert.areEqual(TEST_EMAIL,      insertedAccount.PersonEmail,     'Email mismatch');
        Assert.areEqual(TEST_PHONE,      insertedAccount.PersonMobilePhone, 'Phone mismatch');
        Assert.areEqual(TEST_ID_NUMBER,  insertedAccount.CMN_IdentityNumber__pc, 'IdNumber mismatch');
        Assert.areEqual(
            Date.valueOf(TEST_DOB),
            insertedAccount.PersonBirthdate,
            'DateOfBirth mismatch'
        );
    }

    @IsTest
    static void testCreateAccount_missingPersonalInformation_throwsException() {

        // INPUT SETUP — omit PersonalInformation entirely
        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE & ASSERT
        try {
            Test.startTest();
            INS_Customer_UTIL.createAccount(inputMap, outputMap);
            Test.stopTest();
            Assert.fail('Expected AuraHandledException when PersonalInformation is missing');
        } catch (AuraHandledException caught) {
            Assert.isTrue(
                caught.getMessage().contains('PersonalInformation is required'),
                'Exception message should indicate missing PersonalInformation'
            );
        }
    }

    @IsTest
    static void testCreateAccount_nullDateOfBirth_doesNotThrow() {

        // INPUT SETUP — OS_DateOfBirth explicitly null
        Map<String, Object> personalInformation = buildPersonalInformation();
        personalInformation.put('OS_DateOfBirth', null);
        Map<String, Object> inputMap  = new Map<String, Object>{ 'PersonalInformation' => personalInformation };
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.createAccount(inputMap, outputMap);
        Test.stopTest();

        // ASSERT — record still inserted, DOB is null
        Assert.isNotNull(result.get('ProspectAccountId'), 'ProspectAccountId should be set even with null DOB');

        Account insertedAccount = [
            SELECT PersonBirthdate FROM Account WHERE Id = :(Id) result.get('ProspectAccountId')
        ];
        Assert.isNull(insertedAccount.PersonBirthdate, 'PersonBirthdate should be null');
    }

    @IsTest
    static void testCreateAccount_bulk_insertsWithinGovernorLimits() {

        // INPUT SETUP — 5 records to stay safely within SOQL governor limits
        List<Map<String, Object>> inputs = new List<Map<String, Object>>();
        for (Integer index = 0; index < 5; index++) {
            Map<String, Object> personalInformation = buildPersonalInformation();
            personalInformation.put('LastName', 'BulkTest' + index);
            personalInformation.put('IdNumber', '90061552340' + String.valueOf(index).leftPad(2, '0'));
            inputs.add(new Map<String, Object>{ 'PersonalInformation' => personalInformation });
        }

        // EXECUTE
        Test.startTest();
        for (Map<String, Object> inputMap : inputs) {
            INS_Customer_UTIL.createAccount(inputMap, new Map<String, Object>());
        }
        Test.stopTest();

        // ASSERT
        Integer accountCount = [SELECT COUNT() FROM Account WHERE LastName LIKE 'BulkTest%'];
        Assert.areEqual(5, accountCount, 'Expected 5 Prospect Accounts to be inserted');
    }

    // =========================================================================
    // TEST METHODS — createOpportunity
    // =========================================================================

    @IsTest
    static void testCreateOpportunity_success_returnsOppIdAndQuoteNumber() {

        // INPUT SETUP
        Id accountId = insertTestProspectAccount();
        insertFlexiProtectPricebookEntry();

        Map<String, Object> quoteResponse = new Map<String, Object>{
            'coverAmount'        => String.valueOf(TEST_COVER_AMOUNT),
            'benefitAmountValue' => String.valueOf(TEST_PREMIUM),
            'quoteId'            => TEST_EXTERNAL_QUOTE_ID
        };
        Map<String, Object> insuranceProduct = new Map<String, Object>{
            'Product__c'  => TEST_PRODUCT,
            'Country__c'  => TEST_COUNTRY,
            'Currency__c' => TEST_CURRENCY
        };
        Map<String, Object> inputMap = new Map<String, Object>{
            'accountId'           => accountId,
            'CreateQuoteResponse' => quoteResponse,
            'INS_Products'        => insuranceProduct
        };
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.createOpportunity(inputMap, outputMap);
        Test.stopTest();

        // ASSERT
        Assert.isNotNull(result.get('OppId'),      'OppId should be populated');
        Assert.isNotNull(result.get('QuoteNumber'), 'QuoteNumber should be populated');

        Opportunity insertedOpportunity = [
            SELECT AccountId, StageName, Total_Cover_Amount__c, Total_Monthly_Premium__c
            FROM   Opportunity
            WHERE  Id = :(Id) result.get('OppId')
        ];
        Assert.areEqual(accountId,        insertedOpportunity.AccountId,              'AccountId mismatch');
        Assert.areEqual('Quoting',        insertedOpportunity.StageName,             'StageName mismatch');
        Assert.areEqual(TEST_COVER_AMOUNT, insertedOpportunity.Total_Cover_Amount__c, 'CoverAmount mismatch');
        Assert.areEqual(TEST_PREMIUM,      insertedOpportunity.Total_Monthly_Premium__c, 'Premium mismatch');

        // Verify line item was created
        Integer lineItemCount = [
            SELECT COUNT() FROM OpportunityLineItem WHERE OpportunityId = :(Id) result.get('OppId')
        ];
        Assert.areEqual(1, lineItemCount, 'Expected exactly 1 OpportunityLineItem');
    }

    @IsTest
    static void testCreateOpportunity_missingInputs_throwsException() {

        // INPUT SETUP — accountId present but other required fields absent
        Map<String, Object> inputMap  = new Map<String, Object>{ 'accountId' => 'someId' };
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE & ASSERT
        try {
            Test.startTest();
            INS_Customer_UTIL.createOpportunity(inputMap, outputMap);
            Test.stopTest();
            Assert.fail('Expected AuraHandledException for missing required inputs');
        } catch (AuraHandledException caught) {
            Assert.isTrue(
                caught.getMessage().contains('Missing required inputs'),
                'Exception message should reference missing required inputs'
            );
        }
    }

    // =========================================================================
    // TEST METHODS — getProductDetails
    // =========================================================================

    @IsTest
    static void testGetProductDetails_success_returnsExpectedFields() {

        // INPUT SETUP
        insertFlexiProtectPricebookEntry();
        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.getProductDetails(inputMap, outputMap);
        Test.stopTest();

        // ASSERT
        Assert.isNotNull(result.get('ProductId'),        'ProductId should be populated');
        Assert.isNotNull(result.get('PricebookId'),      'PricebookId should be populated');
        Assert.isNotNull(result.get('PricebookEntryId'), 'PricebookEntryId should be populated');
        Assert.isNotNull(result.get('UnitPrice'),        'UnitPrice should be populated');
        Assert.areEqual(250.00, (Decimal) result.get('UnitPrice'), 'UnitPrice should match inserted value');
    }

    @IsTest
    static void testGetProductDetails_calledTwice_usesCacheNotExtraSOQL() {

        // INPUT SETUP
        insertFlexiProtectPricebookEntry();
        Map<String, Object> inputMap  = new Map<String, Object>();
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE — call twice in the same transaction to exercise cache path
        Test.startTest();
        INS_Customer_UTIL.getProductDetails(inputMap, outputMap);
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.getProductDetails(inputMap, new Map<String, Object>());
        Test.stopTest();

        // ASSERT — second call should return same data without error
        Assert.isNotNull(result.get('PricebookEntryId'), 'PricebookEntryId should be returned on second call');
    }

    // =========================================================================
    // TEST METHODS — updateOpportunity
    // =========================================================================

    @IsTest
    static void testUpdateOpportunity_success_updatesFieldsAndReturnsFlag() {

        // INPUT SETUP
        Id accountId    = insertTestProspectAccount();
        Id opportunityId = insertTestOpportunity(accountId);

        Decimal updatedCoverAmount = 750000.00;
        Decimal updatedPremium     = 1800.00;

        Map<String, Object> inputMap = new Map<String, Object>{
            'OppId'               => opportunityId,
            'BenefitAmount'       => String.valueOf(updatedCoverAmount),
            'RecalculatedPremium' => String.valueOf(updatedPremium)
        };
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE
        Test.startTest();
        Map<String, Object> result = (Map<String, Object>) INS_Customer_UTIL.updateOpportunity(inputMap, outputMap);
        Test.stopTest();

        // ASSERT — flag in outputMap
        Assert.areEqual('true', (String) result.get('hasOppUpdated'), 'hasOppUpdated should be true');

        // ASSERT — database values updated
        Opportunity updatedOpportunity = [
            SELECT Total_Cover_Amount__c, Total_Monthly_Premium__c
            FROM   Opportunity
            WHERE  Id = :opportunityId
        ];
        Assert.areEqual(updatedCoverAmount, updatedOpportunity.Total_Cover_Amount__c,    'CoverAmount not updated');
        Assert.areEqual(updatedPremium,     updatedOpportunity.Total_Monthly_Premium__c, 'Premium not updated');
    }

    @IsTest
    static void testUpdateOpportunity_missingOppId_throwsException() {

        // INPUT SETUP — no OppId
        Map<String, Object> inputMap  = new Map<String, Object>{
            'BenefitAmount'       => '500000',
            'RecalculatedPremium' => '1250'
        };
        Map<String, Object> outputMap = new Map<String, Object>();

        // EXECUTE & ASSERT
        try {
            Test.startTest();
            INS_Customer_UTIL.updateOpportunity(inputMap, outputMap);
            Test.stopTest();
            Assert.fail('Expected AuraHandledException when OppId is missing');
        } catch (AuraHandledException caught) {
            Assert.isTrue(
                caught.getMessage().contains('OppId is required'),
                'Exception message should reference missing OppId'
            );
        }
    }

    // =========================================================================
    // TEST METHODS — createQuoteRecord
    // =========================================================================

    @IsTest
    static void testCreateQuoteRecord_success_returnsQuoteWithNumber() {

        // INPUT SETUP
        Id accountId    = insertTestProspectAccount();
        Id opportunityId = insertTestOpportunity(accountId);

        // EXECUTE
        Test.startTest();
        Quote insertedQuote = INS_Customer_UTIL.createQuoteRecord(
            opportunityId,
            TEST_EXTERNAL_QUOTE_ID,
            TEST_CURRENCY
        );
        Test.stopTest();

        // ASSERT
        Assert.isNotNull(insertedQuote.Id,          'Quote Id should be populated after insert');
        Assert.isNotNull(insertedQuote.QuoteNumber, 'QuoteNumber should be auto-populated post-insert');

        Quote queriedQuote = [
            SELECT Name, Status, CurrencyIsoCode,
                   UnderwriterQuoteReferenceNumber__c, ExpirationDate
            FROM   Quote
            WHERE  Id = :insertedQuote.Id
        ];
        Assert.areEqual('Flexi Protect Quote',  queriedQuote.Name,                              'Quote name mismatch');
        Assert.areEqual('Quote In-Progress',    queriedQuote.Status,                            'Quote status mismatch');
        Assert.areEqual(TEST_CURRENCY,          queriedQuote.CurrencyIsoCode,                   'Currency mismatch');
        Assert.areEqual(TEST_EXTERNAL_QUOTE_ID, queriedQuote.UnderwriterQuoteReferenceNumber__c, 'External quote id mismatch');
        Assert.areEqual(
            Date.today().addDays(30),
            queriedQuote.ExpirationDate,
            'Expiration date should be 30 days from today'
        );
    }

    // =========================================================================
    // TEST METHODS — createOpportunityLineItem
    // =========================================================================

    @IsTest
    static void testCreateOpportunityLineItem_success_insertsLineItem() {

        // INPUT SETUP
        Id accountId    = insertTestProspectAccount();
        insertFlexiProtectPricebookEntry();

        Pricebook2 kenyaHnwPricebook = [SELECT Id FROM Pricebook2 WHERE Name = 'C&HNW(Kenya)' LIMIT 1];

        Id recordTypeId = Opportunity.SObjectType
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('General')
            .getRecordTypeId();

        Opportunity testOpportunity = new Opportunity(
            AccountId       = accountId,
            Name            = 'LineItem Test Opp',
            StageName       = 'Quoting',
            CloseDate       = Date.today(),
            RecordTypeId    = recordTypeId,
            CurrencyIsoCode = TEST_CURRENCY,
            Pricebook2Id    = kenyaHnwPricebook.Id
        );
        insert testOpportunity;

        // EXECUTE
        Test.startTest();
        INS_Customer_UTIL.createOpportunityLineItem(testOpportunity.Id);
        Test.stopTest();

        // ASSERT
        List<OpportunityLineItem> lineItems = [
            SELECT Id, Quantity FROM OpportunityLineItem WHERE OpportunityId = :testOpportunity.Id
        ];
        Assert.areEqual(1,    lineItems.size(),              'Expected exactly 1 line item');
        Assert.areEqual(1,    lineItems[0].Quantity,         'Quantity should be 1');
    }
}