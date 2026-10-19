/**
 * @description             : Test class for INS_CTRL_QuoteAccessValidator
 * @story                   : <story>
 * @author                  : Irshad
 * @created date            : <date>
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_QuoteAccessValidator_TEST {

    private static final String QUOTE_REFERENCE   = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String FOREIGN_REFERENCE = '9a5c0289-5def-481d-9c28-3317b9de7559';

    private static final String KEY_PROSPECT_ACCOUNT_ID = 'ProspectAccountId';
    private static final String KEY_ACCOUNT_ID          = 'accountId';
    private static final String KEY_EXISTING_ACCOUNT_ID = 'existingAccountId';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {
        Product2 prod = new Product2(Name = 'Flexi Protect', IsActive = true);
        insert prod;
        
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = prod.Id,
            UnitPrice    = 100.00,
            IsActive     = true,
            CurrencyIsoCode = 'KES'
        );
        insert stdPbe;
        
        Id rtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect')
            .getRecordTypeId();

        Account acc = new Account(FirstName = 'Test', LastName = 'Prospect', RecordTypeId = rtId);
        insert acc;
        
        

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name      = 'Quote Access Test Opportunity',
            StageName = 'Quoting',
            CloseDate = Date.today()
            
        );
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(
            PricebookEntryId = stdPbe.Id,
            Product2Id       = prod.Id,
            Quantity         = 1,
            UnitPrice        = 1,
            OpportunityId = opp.Id
        );
        insert oli;
        

        insert new Quote(
            OpportunityId                      = opp.Id,
            Name                               = 'Quote Access Test Quote',
            UnderwriterQuoteReferenceNumber__c = QUOTE_REFERENCE
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Id getTestAccountId() {
        return [SELECT Id FROM Account WHERE Name = 'Quote Access Test Account' LIMIT 1].Id;
    }

    /**
     * @description Runs the validator and returns the exception message, or an
     *              empty string when it passed. Assertions stay in the @IsTest
     *              methods (see sf:NonUnitTestContainsAsserts).
     */
    private static String captureFailure(String quoteId, String accountId) {
        try {
            INS_CTRL_QuoteAccessValidator.validate(quoteId, accountId);
            return '';
        } catch (AuraHandledException ex) {
            return 'THREW';
        }
    }

    private static String captureFailure(String quoteId, Map<String, Object> input) {
        try {
            INS_CTRL_QuoteAccessValidator.validate(quoteId, input);
            return '';
        } catch (AuraHandledException ex) {
            return 'THREW';
        }
    }

    // =========================================================================
    // MATCHING QUOTE — PASSES
    // =========================================================================

    @IsTest
    static void validate_matchingQuoteAndAccount_passes() {
        Id accountId = getTestAccountId();

        Test.startTest();
        String outcome = captureFailure(QUOTE_REFERENCE, String.valueOf(accountId));
        Test.stopTest();

        Assert.areEqual('', outcome,
            'A quote recorded against the supplied account should validate successfully.');
    }

    @IsTest
    static void validate_inputOverload_resolvesEachAccountKey() {
        String accountId = String.valueOf(getTestAccountId());

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            KEY_PROSPECT_ACCOUNT_ID => new Map<String, Object>{ KEY_PROSPECT_ACCOUNT_ID => accountId },
            KEY_ACCOUNT_ID          => new Map<String, Object>{ KEY_ACCOUNT_ID          => accountId },
            KEY_EXISTING_ACCOUNT_ID => new Map<String, Object>{ KEY_EXISTING_ACCOUNT_ID => accountId }
        };

        Test.startTest();
        for (String key : scenarios.keySet()) {
            Assert.areEqual('', captureFailure(QUOTE_REFERENCE, scenarios.get(key)),
                'Account id supplied under ' + key + ' should be resolved and validate.');
        }
        Test.stopTest();
    }

    // =========================================================================
    // MISMATCH AND MISSING VALUES — THROW
    // =========================================================================

    /**
     * @description The behaviour the pen test finding called for: a quote
     *              reference belonging to another customer must not validate.
     */
    @IsTest
    static void validate_foreignQuoteReference_throws() {
        Id accountId = getTestAccountId();

        Test.startTest();
        String outcome = captureFailure(FOREIGN_REFERENCE, String.valueOf(accountId));
        Test.stopTest();

        Assert.areEqual('THREW', outcome,
            'A quote reference not recorded against the account must be rejected.');
    }

    @IsTest
    static void validate_quoteBelongsToAnotherAccount_throws() {
        Account otherAccount = new Account(Name = 'Unrelated Account');
        insert otherAccount;

        Test.startTest();
        String outcome = captureFailure(QUOTE_REFERENCE, String.valueOf(otherAccount.Id));
        Test.stopTest();

        Assert.areEqual('THREW', outcome,
            'A valid quote reference paired with the wrong account must be rejected.');
    }

    @IsTest
    static void validate_missingOrMalformedValues_throw() {
        String accountId = String.valueOf(getTestAccountId());

        Map<String, List<String>> scenarios = new Map<String, List<String>>{
            'blank quoteId'     => new List<String>{ '',              accountId },
            'null quoteId'      => new List<String>{ null,            accountId },
            'blank accountId'   => new List<String>{ QUOTE_REFERENCE, ''        },
            'null accountId'    => new List<String>{ QUOTE_REFERENCE, null      },
            'malformed accountId' => new List<String>{ QUOTE_REFERENCE, 'not-an-id' }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            List<String> params = scenarios.get(scenario);
            Assert.areEqual('THREW', captureFailure(params[0], params[1]),
                'Validation should be rejected for: ' + scenario);
        }
        Test.stopTest();
    }

    @IsTest
    static void validate_inputOverloadWithNoAccountId_throws() {
        Test.startTest();
        String withoutKey = captureFailure(QUOTE_REFERENCE, new Map<String, Object>());
        String nullInput  = captureFailure(QUOTE_REFERENCE, (Map<String, Object>) null);
        String blankValue = captureFailure(QUOTE_REFERENCE,
            new Map<String, Object>{ KEY_ACCOUNT_ID => '' });
        Test.stopTest();

        Assert.areEqual('THREW', withoutKey,
            'Input with no account id key should be rejected.');
        Assert.areEqual('THREW', nullInput,
            'Null input should be rejected.');
        Assert.areEqual('THREW', blankValue,
            'A blank account id value should be rejected.');
    }
}