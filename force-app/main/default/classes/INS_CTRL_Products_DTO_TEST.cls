/**
 * @description             : Test class for INS_CTRL_Products
 * @story                   : SFP-55635: for guest user this must run without sharing
 * 							  Selector class not working for Guest user
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *                          
 */
@IsTest
private class INS_CTRL_Products_DTO_TEST {

    // =========================================================================
    // TEST DATA CONSTANTS — must match what OmniScript passes at runtime
    // =========================================================================
    private static final String PRODUCT_NAME   = 'Flexi Protect';
    private static final String PRICEBOOK_NAME = 'C&HNW(Kenya)';
    private static final String CURRENCY_CODE  = 'KES';
    private static final Decimal UNIT_PRICE    = 250.00;

    private static final String ACTION_GET_PRODUCT_DETAILS = 'getProductDetails';
    private static final String KEY_PRODUCT_C   = 'Product__c';
    private static final String KEY_PRICEBOOK_C = 'PriceBook__c';
    private static final String KEY_CURRENCY_C  = 'Currency__c';

    private static final String OUT_PRODUCT_ID              = 'ProductId';
    private static final String OUT_PRICEBOOK_ID             = 'PricebookId';
    private static final String OUT_PRICEBOOK_ENTRY_ID       = 'PricebookEntryId';
    private static final String OUT_PRICEBOOK_ENTRY_UNIT_PRICE = 'PricebookEntryUnitPrice';

    // =========================================================================
    // TEST DATA FACTORY
    // =========================================================================

    /**
     * Creates Product2 + custom Pricebook2 + Standard PBE + custom PBE.
     * Returns a map with productId, pricebookId, pbeId for assertion use.
     */
    private static Map<String, Id> setupPricebookData() {
        Product2 prod = new Product2(Name = PRODUCT_NAME, IsActive = true);
        insert prod;

        // Standard PricebookEntry required before a custom pricebook entry
        insert new PricebookEntry(
            Pricebook2Id    = Test.getStandardPricebookId(),
            Product2Id      = prod.Id,
            UnitPrice       = UNIT_PRICE,
            IsActive        = true,
            CurrencyIsoCode = CURRENCY_CODE
        );

        Pricebook2 pb = new Pricebook2(
            Name            = PRICEBOOK_NAME,
            IsActive        = true,
            CurrencyIsoCode = CURRENCY_CODE
        );
        insert pb;

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id    = pb.Id,
            Product2Id      = prod.Id,
            UnitPrice       = UNIT_PRICE,
            IsActive        = true,
            CurrencyIsoCode = CURRENCY_CODE
        );
        insert pbe;

        return new Map<String, Id>{
            'productId'   => prod.Id,
            'pricebookId' => pb.Id,
            'pbeId'       => pbe.Id
        };
    }

    private static Map<String, Object> buildArgs(Map<String, Object> input, Map<String, Object> output) {
        return new Map<String, Object>{ 'input' => input, 'output' => output };
    }

    private static Map<String, Object> buildValidInput() {
        return new Map<String, Object>{
            KEY_PRODUCT_C   => PRODUCT_NAME,
            KEY_PRICEBOOK_C => PRICEBOOK_NAME,
            KEY_CURRENCY_C  => CURRENCY_CODE
        };
    }

    private static Map<String, Object> invoke(Map<String, Object> input, Map<String, Object> output) {
        return (Map<String, Object>) new INS_CTRL_Products_DTO().call(
            ACTION_GET_PRODUCT_DETAILS, buildArgs(input, output));
    }

    // =========================================================================
    // getProductDetails — POSITIVE
    // =========================================================================

    /*------------------------------------------------------------
     *  Covers: successful lookup with all four output keys correct,
     *  and pre-existing output map keys preserved (merged from the
     *  former separate outputMapPreservedOnSuccess test).
     *------------------------------------------------------------*/
    @IsTest
    static void testGetProductDetails_success() {
        Map<String, Id> setupData = setupPricebookData();

        Test.startTest();
        Map<String, Object> result = invoke(
            buildValidInput(),
            new Map<String, Object>{ 'PreExistingKey' => 'PreExistingValue' });
        Test.stopTest();

        Assert.areEqual(setupData.get('productId'), (Id) result.get(OUT_PRODUCT_ID),
            'ProductId should match inserted Product2');
        Assert.areEqual(setupData.get('pricebookId'), (Id) result.get(OUT_PRICEBOOK_ID),
            'PricebookId should match inserted Pricebook2');
        Assert.areEqual(setupData.get('pbeId'), (Id) result.get(OUT_PRICEBOOK_ENTRY_ID),
            'PricebookEntryId should match inserted PricebookEntry');
        Assert.areEqual(UNIT_PRICE, (Decimal) result.get(OUT_PRICEBOOK_ENTRY_UNIT_PRICE),
            'UnitPrice should match ' + UNIT_PRICE);

        Assert.areEqual('PreExistingValue', result.get('PreExistingKey'),
            'Pre-existing output map keys should be preserved');
    }

    // =========================================================================
    // getProductDetails — NEGATIVE
    // =========================================================================


    @IsTest
    static void testGetProductDetails_notFoundScenarios() {
        setupPricebookData();

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'product not found' => new Map<String, Object>{
                KEY_PRODUCT_C   => 'Non Existent Product',
                KEY_PRICEBOOK_C => PRICEBOOK_NAME,
                KEY_CURRENCY_C  => CURRENCY_CODE
            },
            'pricebook not found' => new Map<String, Object>{
                KEY_PRODUCT_C   => PRODUCT_NAME,
                KEY_PRICEBOOK_C => 'Wrong Pricebook Name',
                KEY_CURRENCY_C  => CURRENCY_CODE
            }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Boolean exceptionThrown = false;
            try {
                invoke(scenarios.get(scenario), new Map<String, Object>());
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Assert.isTrue(exceptionThrown,
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    /*------------------------------------------------------------
     *  Covers the required-field guard added to getProductDetails:
     *  blank Product__c and blank PriceBook__c should both throw
     *  before any SOQL runs. No pricebook data setup needed since
     *  the guard short-circuits first.
     *------------------------------------------------------------*/
    @IsTest
    static void testGetProductDetails_missingRequiredFields() {
        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'blank Product__c' => new Map<String, Object>{
                KEY_PRODUCT_C   => '',
                KEY_PRICEBOOK_C => PRICEBOOK_NAME
            },
            'blank PriceBook__c' => new Map<String, Object>{
                KEY_PRODUCT_C   => PRODUCT_NAME,
                KEY_PRICEBOOK_C => ''
            },
            'missing Product__c key' => new Map<String, Object>{
                KEY_PRICEBOOK_C => PRICEBOOK_NAME
            },
            'missing PriceBook__c key' => new Map<String, Object>{
                KEY_PRODUCT_C => PRODUCT_NAME
            }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Boolean exceptionThrown = false;
            try {
                invoke(scenarios.get(scenario), new Map<String, Object>());
            } catch (AuraHandledException e) {
                exceptionThrown = true;
            }
            Assert.isTrue(exceptionThrown,
                'AuraHandledException should be thrown for: ' + scenario);
        }
        Test.stopTest();
    }

    // =========================================================================
    // call() — guard clauses
    // =========================================================================

    @IsTest
    static void testCall_guardClauses() {
        INS_CTRL_Products_DTO sut = new INS_CTRL_Products_DTO();

        Test.startTest();

        Boolean unsupportedThrown = false;
        try {
            sut.call('unknownAction', buildArgs(new Map<String, Object>(), new Map<String, Object>()));
        } catch (AuraHandledException e) {
            unsupportedThrown = true;
        }

        Boolean invalidInputThrown = false;
        try {
            sut.call(ACTION_GET_PRODUCT_DETAILS, new Map<String, Object>{
                'input' => 'not-a-map', 'output' => new Map<String, Object>()
            });
        } catch (AuraHandledException e) {
            invalidInputThrown = true;
        }

        Boolean invalidOutputThrown = false;
        try {
            sut.call(ACTION_GET_PRODUCT_DETAILS, new Map<String, Object>{
                'input' => new Map<String, Object>(), 'output' => 12345
            });
        } catch (AuraHandledException e) {
            invalidOutputThrown = true;
        }

        Boolean nullInputThrown = false;
        try {
            sut.call(ACTION_GET_PRODUCT_DETAILS, new Map<String, Object>{
                'input' => null, 'output' => new Map<String, Object>()
            });
        } catch (AuraHandledException e) {
            nullInputThrown = true;
        }

        Test.stopTest();

        Assert.isTrue(unsupportedThrown, 'AuraHandledException should be thrown for unsupported action');
        Assert.isTrue(invalidInputThrown, 'AuraHandledException should be thrown when input is not a Map');
        Assert.isTrue(invalidOutputThrown, 'AuraHandledException should be thrown when output is not a Map');
        Assert.isTrue(nullInputThrown, 'AuraHandledException should be thrown when input is null');
    }
}