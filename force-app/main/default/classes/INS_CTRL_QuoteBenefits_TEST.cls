/**
 * @description             : Test class for INS_CTRL_QuoteBenefits
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_QuoteBenefits_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String BODY_PREMIUMS =
        '{"monthlyPremium": 250.50, "monthlyCashbackPremium": 25.05,' +
        ' "monthlyCashbackBenefitPremium": 12.50, "annualPremium": 3006.00,' +
        ' "annualCashbackPremium": 300.60, "annualCashbackBenefitPremium": 150.00}';

    private static final String BODY_PUT_RESULT = '{"result": "Benefits updated"}';

    private static final String BODY_ERROR_WITH_MAP =
        '{"error": {"errorDescription": "Benefit not available for this product"}}';

    private static final String BODY_ERROR_NO_MAP = '{"message": "Gateway timeout"}';

    private static final String BODY_NOT_JSON = 'not json <<<';

    /**
     * @description Configurable mock. Captures method and outbound payload.
     *   NOTE: asserts PUT unconditionally because the controller currently
     *   always calls putQuoteBenefits (the computed 'verb' is unused).
     */
    private class BenefitsMock implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        public String capturedMethod;
        public String capturedRequestBody;

        BenefitsMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            this.capturedMethod = req.getMethod();
            this.capturedRequestBody = req.getBody();

            Assert.isTrue(req.getEndpoint().contains(TEST_QUOTE_ID),
                'Endpoint should contain the quoteId');

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
        INS_API_QuoteBenefits.testAccessToken = 'TEST_TOKEN_123';
        BenefitsMock mock = new BenefitsMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static Map<String, Object> inputPersonalised(String cashbackBenefit) {
        return new Map<String, Object>{
            'quoteId' => TEST_QUOTE_ID,
            'PersonalisedQuote' => new Map<String, Object>{
                'CashbackBenefit'  => cashbackBenefit,
                'PaymentFrequency' => 'Annually',
                'AutomaticBenefit' => '10'
            }
        };
    }

    private static Map<String, Object> inputNotPersonalised() {
        return new Map<String, Object>{ 'quoteId' => TEST_QUOTE_ID };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteBenefits().call('AdditionalBenefitsWithCashback',
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    // =========================================================================
    // SUCCESS PATHS
    // =========================================================================

    @IsTest
    static void personalised_success_mapsResult() {
        BenefitsMock mock = registerMock(200, BODY_PUT_RESULT);

        Test.startTest();
        Map<String, Object> output = invokeAction(inputPersonalised('Yes'));
        Test.stopTest();

        Assert.areEqual('PUT', mock.capturedMethod, 'Controller always PUTs');
        Assert.areEqual('Benefits updated', output.get('result'),
            'result should be mapped from PUT response');

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual('Annually', payload.get('paymentFrequency'),
            'paymentFrequency should come from PersonalisedQuote');
        Assert.areEqual(TEST_QUOTE_ID, payload.get('QuoteNumber'),
            'QuoteNumber should be the quoteId');
    }

    @IsTest
    static void personalised_cashbackNo_sendsFalse() {
        BenefitsMock mock = registerMock(200, BODY_PUT_RESULT);

        Test.startTest();
        invokeAction(inputPersonalised('No'));
        Test.stopTest();

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        List<Object> benefits = (List<Object>) payload.get('additionalBenefits');

        String cashbackValue;
        for (Object b : benefits) {
            Map<String, Object> benefit = (Map<String, Object>) b;
            if ('CashBackOption'.equals(benefit.get('benefitType'))) {
                cashbackValue = (String) benefit.get('benefitValue');
            }
        }
        Assert.areEqual('false', cashbackValue,
            'CashbackBenefit = No should send benefitValue false');
    }

    @IsTest
    static void notPersonalised_success_populatesPremiums() {
        BenefitsMock mock = registerMock(200, BODY_PREMIUMS);

        Test.startTest();
        Map<String, Object> output = invokeAction(inputNotPersonalised());
        Test.stopTest();

        // Documents current behaviour: non-personalised also goes out as PUT
        // because the computed 'verb' variable is never used.
        Assert.areEqual('PUT', mock.capturedMethod, 'Controller always PUTs (verb unused)');
        Assert.areEqual(false, output.get('hasError'), 'hasError should be false');
        Assert.areEqual(250.50, output.get('monthlyPremium'), 'monthlyPremium should be mapped');
        Assert.areEqual(3006.00, output.get('annualPremium'), 'annualPremium should be mapped');

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual('Monthly', payload.get('paymentFrequency'),
            'Default payment frequency should be Monthly');
    }

    @IsTest
    static void notPersonalised_emptyResponse_noErrorNoPremiums() {
        registerMock(200, '');

        Test.startTest();
        Map<String, Object> output = invokeAction(inputNotPersonalised());
        Test.stopTest();

        // Documents current behaviour: blank body is treated as non-error
        Assert.areEqual(false, output.get('hasError'),
            'Blank response is currently treated as success');
        Assert.isFalse(output.containsKey('monthlyPremium'),
            'No premiums should be populated from a blank response');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void error_withErrorMap_surfacesDescription() {
        registerMock(500, BODY_ERROR_WITH_MAP);

        Test.startTest();
        Map<String, Object> output = invokeAction(inputNotPersonalised());
        Test.stopTest();

        Assert.areEqual(true, output.get('hasError'), 'hasError should be true');
        Assert.areEqual('Benefit not available for this product',
            output.get('populatePremiumsError'), 'errorDescription should be surfaced');
    }

    @IsTest
    static void error_withoutErrorMap_surfacesStatusCode() {
        registerMock(500, BODY_ERROR_NO_MAP);

        Test.startTest();
        Map<String, Object> output = invokeAction(inputNotPersonalised());
        Test.stopTest();

        Assert.areEqual(true, output.get('hasError'), 'hasError should be true');
        Assert.areEqual('API returned error status: 500', output.get('populatePremiumsError'),
            'Status code should be surfaced when no error map present');
    }

    @IsTest
    static void error_unparseableResponse_throwsInTestContext() {
        registerMock(200, BODY_NOT_JSON);

        // The controller rethrows JSONException when Test.isRunningTest() -
        // so in tests this branch surfaces as a thrown exception, not an error map.
        Boolean thrown = false;
        Test.startTest();
        try {
            invokeAction(inputNotPersonalised());
        } catch (System.JSONException ex) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown,
            'Unparseable response rethrows JSONException in test context');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_QuoteBenefits().call('wrongAction',
                new Map<String, Object>{
                    'input'  => inputNotPersonalised(),
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }
}