/**
 * @description             : Test class for INS_CTRL_QuoteAdditionalBenefits
 * @story                   : SFP-55750
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
// NOSONAR sf:Integration_to_use_API_Framework_Two - false positive: rule's isTest
// exclusion is case-sensitive (@Image='isTest' vs actual @IsTest) and does not
// account for inner HttpCalloutMock classes nested inside test classes. Rule's own
// COMPLIANT PATTERNS section explicitly allows "Test classes using HttpRequest/Http
// for mocking".
private class INS_CTRL_QuoteAdditionalBenefits_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String ACTION_WITH_CASHBACK    = 'AdditionalBenefitsWithCashback';
    private static final String ACTION_WITHOUT_CASHBACK = 'AdditionalBenefitsWithoutCashback';
    private static final String KEY_HAS_ERROR           = 'hasError';

    private static final String BODY_PREMIUMS =
        '{"monthlyPremium": 250.50, "monthlyCashbackPremium": 25.05,' +
        ' "monthlyCashbackBenefitPremium": 12.50, "annualPremium": 3006.00,' +
        ' "annualCashbackPremium": 300.60, "annualCashbackBenefitPremium": 150.00}';

    private static final String BODY_PUT_RESULT =
        '{"result": "Additional benefits updated"}';

    private static final String BODY_ERROR_WITH_MAP =
        '{"error": {"errorDescription": "Benefit not available for this product"}}';

    private static final String BODY_ERROR_NO_MAP =
        '{"message": "Gateway timeout"}';

    private static final String BODY_NOT_JSON = 'this is not json <<<';

    /**
     * @description Configurable mock. Captures method, endpoint and request body
     *   so the @IsTest methods can assert on the outbound request after the call
     *   (see sf:NonUnitTestContainsAsserts).
     */
    private class BenefitsMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedRequestBody;

        BenefitsMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedMethod      = req.getMethod();
            this.capturedEndpoint    = req.getEndpoint();
            this.capturedRequestBody = req.getBody();

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    // =========================================================================
    // TEST HELPERS
    // =========================================================================

    private static BenefitsMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteAdditionalBenefits.testAccessToken = 'TEST_TOKEN_123';
        BenefitsMock mock = new BenefitsMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static Map<String, Object> invokeAction(String action, Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteAdditionalBenefits().call(action,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static Map<String, Object> inputWithPersonalisedQuote(String cashbackBenefit) {
        return new Map<String, Object>{
            'quoteId' => TEST_QUOTE_ID,
            'PersonalisedQuote' => new Map<String, Object>{
                'CashbackBenefit'  => cashbackBenefit,
                'PaymentFrequency' => 'Annually',
                'AutomaticBenefit' => '10'
            }
        };
    }

    private static Map<String, Object> inputWithoutPersonalisedQuote() {
        return new Map<String, Object>{ 'quoteId' => TEST_QUOTE_ID };
    }

    // =========================================================================
    // WITH CASHBACK - PUT PATH (personalised quote present)
    // =========================================================================

    /*------------------------------------------------------------
     *  Merges the former putCall_success and cashbackNo_sendsFalse
     *  tests: both exercise the same PUT path, just asserting
     *  different aspects of the same call. Reduces method count
     *  while keeping both assertions.
     *------------------------------------------------------------*/
    @IsTest
    static void withCashback_personalised_putCall() {
        BenefitsMock mock = registerMock(200, BODY_PUT_RESULT);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            ACTION_WITH_CASHBACK, inputWithPersonalisedQuote('No'));
        Test.stopTest();

        // Routing + response mapping
        Assert.areEqual('PUT', mock.capturedMethod,
            'Personalised quote should route to updateAdditionalBenefits (PUT)');
        Assert.areEqual(false, output.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual('Additional benefits updated', output.get('result'),
            'result should be mapped from PUT response');

        // Outbound payload
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual('Annually', payload.get('paymentFrequency'),
            'paymentFrequency should come from PersonalisedQuote');

        List<Object> benefits = (List<Object>) payload.get('additionalBenefits');
        
        Boolean cashbackValue = null;
        
        for (Object b : benefits) {
            Map<String, Object> benefit = (Map<String, Object>) b;
        
            if ('CashBackOption'.equals(benefit.get('benefitType'))) {
                cashbackValue = (Boolean) benefit.get('benefitValue');
            }
        }
        
        Assert.areEqual(
            false,
            cashbackValue,
            'CashbackBenefit = No should send Boolean false'
        );

    }

    // =========================================================================
    // WITH CASHBACK - POST PATH (no personalised quote)
    // =========================================================================

    @IsTest
    static void withCashback_notPersonalised_postCall_populatesPremiums() {
        BenefitsMock mock = registerMock(200, BODY_PREMIUMS);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            ACTION_WITH_CASHBACK, inputWithoutPersonalisedQuote());
        Test.stopTest();

        Assert.areEqual('POST', mock.capturedMethod,
            'No personalised quote should route to addAdditionalBenefits (POST)');
        Assert.areEqual(false, output.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(250.50, output.get('monthlyPremium'), 'monthlyPremium should be mapped');
        Assert.areEqual(3006.00, output.get('annualPremium'), 'annualPremium should be mapped');
        Assert.areEqual(300.60, output.get('annualCashbackPremium'),
            'annualCashbackPremium should be mapped');
    }

    // =========================================================================
    // WITHOUT CASHBACK - POST PATH
    // =========================================================================

    @IsTest
    static void withoutCashback_postCall_populatesPremiums() {
        BenefitsMock mock = registerMock(200, BODY_PREMIUMS);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            ACTION_WITHOUT_CASHBACK, inputWithoutPersonalisedQuote());
        Test.stopTest();

        Assert.areEqual('POST', mock.capturedMethod, 'Should always POST');
        Assert.areEqual(false, output.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(250.50, output.get('monthlyPremium'), 'monthlyPremium should be mapped');

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual('Monthly', payload.get('paymentFrequency'),
            'Default payment frequency should be Monthly');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    /*------------------------------------------------------------
     *  Merges the three former error tests (error map present,
     *  error map absent, unparseable body) into one data-driven
     *  method to reduce method count without losing coverage.
     *------------------------------------------------------------*/
    @IsTest
    static void errorPaths_surfaceExpectedMessages() {

        // Scenario 1: 500 with structured error map
        registerMock(500, BODY_ERROR_WITH_MAP);
        Map<String, Object> withMapOutput = invokeAction(
            ACTION_WITHOUT_CASHBACK, inputWithoutPersonalisedQuote());
        Assert.areEqual(true, withMapOutput.get(KEY_HAS_ERROR),
            'hasError should be true for 500 with error map');
        Assert.areEqual('Benefit not available for this product',
            withMapOutput.get('populatePremiumsError'),
            'errorDescription should be surfaced when present');

        // Scenario 2: 500 without structured error map
        registerMock(500, BODY_ERROR_NO_MAP);
        Map<String, Object> noMapOutput = invokeAction(
            ACTION_WITHOUT_CASHBACK, inputWithoutPersonalisedQuote());
        Assert.areEqual(true, noMapOutput.get(KEY_HAS_ERROR),
            'hasError should be true for 500 without error map');
        Assert.areEqual('API returned status: 500', noMapOutput.get('populatePremiumsError'),
            'Status code should be surfaced when no error map present');

        // Scenario 3: 200 with unparseable body
        registerMock(200, BODY_NOT_JSON);
        Map<String, Object> parseErrorOutput = invokeAction(
            ACTION_WITHOUT_CASHBACK, inputWithoutPersonalisedQuote());
        Assert.areEqual(true, parseErrorOutput.get(KEY_HAS_ERROR),
            'hasError should be true for unparseable response');
        Assert.isTrue(String.valueOf(parseErrorOutput.get('populatePremiumsError'))
            .startsWith('Failed to parse API response'),
            'Parse failure should be surfaced');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    /*------------------------------------------------------------
     *  Merges unsupportedAction and missingInputMap into one
     *  method - both assert the same AuraHandledException contract
     *  for a malformed Callable invocation.
     *------------------------------------------------------------*/
    @IsTest
    static void callableContract_invalidInvocations_throw() {

        Boolean unsupportedActionThrown = false;
        try {
            invokeAction('wrongAction', inputWithoutPersonalisedQuote());
        } catch (AuraHandledException ex) {
            unsupportedActionThrown = true;
        }
        Assert.isTrue(unsupportedActionThrown,
            'Unsupported action should throw AuraHandledException');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_QuoteAdditionalBenefits().call(ACTION_WITH_CASHBACK,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown,
            'Missing input map should throw AuraHandledException');
    }
}