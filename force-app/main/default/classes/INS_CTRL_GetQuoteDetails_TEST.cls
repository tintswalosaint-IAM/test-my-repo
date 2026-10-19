/**
 * @description             : Test class for INS_CTRL_GetQuoteDetails
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_GetQuoteDetails_TEST {

    private static final String QUOTE_REFERENCE = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String ACTION_QUERY_QUOTE        = 'queryQuote';
    private static final String KEY_EXISTING_ACCOUNT      = 'existingAccount';
    private static final String KEY_EXISTING_ACCOUNT_ID   = 'existingAccountId';
    private static final String KEY_QUOTE_FOUND           = 'quoteFound';
    private static final String KEY_EXISTING_QUOTE_DETAILS = 'existingQuoteDetails';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {
        Pricebook2 customPricebook = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert customPricebook;

        List<Account> accounts = new List<Account>{
            new Account(Name = 'Quote Details Test Account'),
            new Account(Name = 'Account Without Quote')
        };
        insert accounts;

        Opportunity opp = new Opportunity(
            AccountId    = accounts[0].Id,
            Name         = 'Quote Details Test Opportunity',
            StageName    = 'Quoting',
            CloseDate    = Date.today(),
            Pricebook2Id = customPricebook.Id
        );
        insert opp;

        insert new Quote(
            OpportunityId                      = opp.Id,
            Name                               = 'Quote Details Test Quote',
            Status                             = 'Quote In-Progress',
            ExpirationDate                     = Date.today().addDays(30),
            UnderwriterQuoteReferenceNumber__c = QUOTE_REFERENCE
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Id getAccountId(String accountName) {
        return [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1].Id;
    }

    private static Map<String, Object> buildInput(Object accountId) {
        return new Map<String, Object>{
            KEY_EXISTING_ACCOUNT => new Map<String, Object>{
                KEY_EXISTING_ACCOUNT_ID => accountId
            }
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_GetQuoteDetails().call(ACTION_QUERY_QUOTE,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    /**
     * @description Invokes the action and reports whether it threw, so assertions
     *              stay in the @IsTest methods (see sf:NonUnitTestContainsAsserts).
     * @return 'THREW' when an AuraHandledException was raised, otherwise ''
     */
    private static String captureFailure(Map<String, Object> input) {
        try {
            invokeAction(input);
            return '';
        } catch (AuraHandledException ex) {
            return 'THREW';
        }
    }

    // =========================================================================
    // QUOTE FOUND
    // =========================================================================

    @IsTest
    static void queryQuote_quoteExists_returnsDetails() {
        Id accountId = getAccountId('Quote Details Test Account');

        Test.startTest();
        Map<String, Object> output = invokeAction(buildInput(String.valueOf(accountId)));
        Test.stopTest();

        Assert.areEqual(true, output.get(KEY_QUOTE_FOUND),
            'quoteFound should be true when the account has a quote');

        Map<String, Object> details =
            (Map<String, Object>) output.get(KEY_EXISTING_QUOTE_DETAILS);
        Assert.isNotNull(details.get('quoteId'), 'quoteId should be populated');
        Assert.areEqual(accountId, details.get('accountId'),
            'accountId should be the quote owner account');
        Assert.areEqual(QUOTE_REFERENCE, details.get('underwriterQuoteRefNum'),
            'The underwriter reference should be mapped');
        Assert.areEqual(Date.today().addDays(30), details.get('expirationDate'),
            'The expiration date should be mapped');
        Assert.isNotNull(details.get('opportunityId'), 'opportunityId should be populated');
    }

    // =========================================================================
    // NO QUOTE
    // =========================================================================

    @IsTest
    static void queryQuote_noQuoteForAccount_returnsEmptyDetails() {
        Id accountId = getAccountId('Account Without Quote');

        Test.startTest();
        Map<String, Object> output = invokeAction(buildInput(String.valueOf(accountId)));
        Test.stopTest();

        Assert.areEqual(false, output.get(KEY_QUOTE_FOUND),
            'quoteFound should be false when the account has no quote');

        Map<String, Object> details =
            (Map<String, Object>) output.get(KEY_EXISTING_QUOTE_DETAILS);
        Assert.isNotNull(details, 'An empty details map should still be returned');
        Assert.isTrue(details.isEmpty(), 'The details map should be empty');
    }

    // =========================================================================
    // INPUT VALIDATION
    // =========================================================================

    @IsTest
    static void queryQuote_invalidAccountIdValues_throw() {
        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'blank account id'     => buildInput(''),
            'null account id'      => buildInput(null),
            'malformed account id' => buildInput('not-an-id')
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Assert.areEqual('THREW', captureFailure(scenarios.get(scenario)),
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Id accountId = getAccountId('Quote Details Test Account');

        Boolean unsupportedActionThrown = false;
        try {
            new INS_CTRL_GetQuoteDetails().call('wrongAction',
                new Map<String, Object>{
                    'input'  => buildInput(String.valueOf(accountId)),
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedActionThrown = true;
        }
        Assert.isTrue(unsupportedActionThrown,
            'Unsupported action should throw AuraHandledException');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_GetQuoteDetails().call(ACTION_QUERY_QUOTE,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown,
            'Missing input map should throw AuraHandledException');

        Boolean missingOutputThrown = false;
        try {
            new INS_CTRL_GetQuoteDetails().call(ACTION_QUERY_QUOTE,
                new Map<String, Object>{ 'input' => buildInput(String.valueOf(accountId)) });
        } catch (AuraHandledException ex) {
            missingOutputThrown = true;
        }
        Assert.isTrue(missingOutputThrown,
            'Missing output map should throw AuraHandledException');
    }
}