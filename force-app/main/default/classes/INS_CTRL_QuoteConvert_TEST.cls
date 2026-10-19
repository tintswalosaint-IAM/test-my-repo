/**
 * @description             : Test class for INS_CTRL_QuoteConvert
 * @story                   : SFP-56577
 * @author                  : Irshad
 * @created date            : 24-08-2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
// NOSONAR sf:Integration_to_use_API_Framework_Two - false positive: rule's isTest
// exclusion is case-sensitive (@Image='isTest' vs actual @IsTest) and does not
// account for inner HttpCalloutMock classes nested inside test classes. Rule's own
// COMPLIANT PATTERNS section explicitly allows "Test classes using HttpRequest/Http
// for mocking".
private class INS_CTRL_QuoteConvert_TEST {

    private static final String QUOTE_REFERENCE = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String POLICY_NUMBER   = 'KA5111905';

    private static final String ACTION_QUOTE_CONVERSION = 'QuoteConversion';
    private static final String KEY_QUOTE_ID            = 'quoteId';
    private static final String KEY_PROSPECT_ACCOUNT_ID = 'ProspectAccountId';
    private static final String KEY_RESPONSE            = 'quoteConversionResponse';
    private static final String KEY_HAS_ERROR           = 'hasError';

    private static final String BODY_SUCCESS =
        '{"policyPayload": {"policyNumber": "' + POLICY_NUMBER + '", "status": "Inactive"},' +
        ' "saleReferenceId": "' + QUOTE_REFERENCE + '"}';

    private static final String BODY_NO_POLICY_NUMBER =
        '{"policyPayload": {"status": "Inactive"},' +
        ' "saleReferenceId": "' + QUOTE_REFERENCE + '"}';

    private static final String BODY_ERROR =
        '{"error": {"errorCode": 500, "errorDescription": "Conversion service unavailable"}}';

    private static final String BODY_NOT_JSON = 'not json <<<';

    /**
     * @description Configurable mock for the quote conversion callout.
     */
    private class QuoteConvertMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        QuoteConvertMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {
        Pricebook2 customPricebook = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert customPricebook;

        Account acc = new Account(Name = 'Quote Convert Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId    = acc.Id,
            Name         = 'Quote Convert Test Opportunity',
            StageName    = 'Quoting',
            CloseDate    = Date.today(),
            Pricebook2Id = customPricebook.Id
        );
        insert opp;

        insert new Quote(
            OpportunityId                      = opp.Id,
            Name                               = 'Quote Convert Test Quote',
            Status                             = 'Quote In-Progress',
            UnderwriterQuoteReferenceNumber__c = QUOTE_REFERENCE
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Id getTestAccountId() {
        return [SELECT Id FROM Account WHERE Name = 'Quote Convert Test Account' LIMIT 1].Id;
    }

    private static void registerMock(Integer statusCode, String body) {
        INS_API_QuoteConvert.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new QuoteConvertMock(statusCode, body));
    }

    private static Map<String, Object> buildInput() {
        return new Map<String, Object>{
            KEY_QUOTE_ID            => QUOTE_REFERENCE,
            KEY_PROSPECT_ACCOUNT_ID => String.valueOf(getTestAccountId())
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteConvert().call(ACTION_QUOTE_CONVERSION,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    // =========================================================================
    // SUCCESS
    // =========================================================================

    @IsTest
    static void quoteConversion_success_returnsPolicyDetails() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildInput());
        Test.stopTest();
		System.debug('OUTPUT== ' + JSON.serializePretty(output));
		System.debug('QUOTE== ' + JSON.serialize([
            SELECT Id, Status, AccountId, UnderwriterQuoteReferenceNumber__c FROM Quote
        ]));
        Map<String, Object> response = (Map<String, Object>) output.get(KEY_RESPONSE);
        Assert.isNotNull(response, 'quoteConversionResponse should be present in output');
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(POLICY_NUMBER, response.get('policyNumber'),
            'Policy number should be read from the response');
        Assert.areEqual('Inactive', response.get('status'),
            'Status should be read from the response');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void quoteConversion_errorScenarios_returnError() {
        Map<String, List<Object>> scenarios = new Map<String, List<Object>>{
            'non-2xx status'       => new List<Object>{ 500, BODY_ERROR },
            'empty response body'  => new List<Object>{ 200, '' },
            'unparseable response' => new List<Object>{ 200, BODY_NOT_JSON },
            'missing policyNumber' => new List<Object>{ 200, BODY_NO_POLICY_NUMBER }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            List<Object> params = scenarios.get(scenario);
            registerMock((Integer) params[0], (String) params[1]);

            Map<String, Object> output = invokeAction(buildInput());
            Map<String, Object> response = (Map<String, Object>) output.get(KEY_RESPONSE);

            Assert.isNotNull(response, 'A response node should be present for: ' + scenario);
            Assert.areEqual(true, response.get(KEY_HAS_ERROR),
                'hasError should be true for: ' + scenario);
            Assert.isNotNull(response.get('errorMessage'),
                'An error message should be present for: ' + scenario);
        }
        Test.stopTest();
    }

    // =========================================================================
    // ACCESS VALIDATION
    // =========================================================================

    @IsTest
    static void quoteConversion_foreignQuoteReference_rejected() {
        registerMock(200, BODY_SUCCESS);

        Map<String, Object> input = buildInput();
        input.put(KEY_QUOTE_ID, '9a5c0289-5def-481d-9c28-3317b9de7559');

        Test.startTest();
        Map<String, Object> output = invokeAction(input);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) output.get(KEY_RESPONSE);
        Assert.areEqual(true, response.get(KEY_HAS_ERROR),
            'A quote reference not recorded against the account must be rejected');
    }

    @IsTest
    static void quoteConversion_missingQuoteId_rejected() {
        registerMock(200, BODY_SUCCESS);

        Map<String, Object> input = buildInput();
        input.put(KEY_QUOTE_ID, '');

        Test.startTest();
        Map<String, Object> output = invokeAction(input);
        Test.stopTest();

        Map<String, Object> response = (Map<String, Object>) output.get(KEY_RESPONSE);
        Assert.areEqual(true, response.get(KEY_HAS_ERROR),
            'A blank quote id should be rejected');
    }

    // =========================================================================
    // PAYLOAD BUILDER
    // =========================================================================

    @IsTest
    static void generateRequestPayload_mapsQuoteReference() {
        String payloadJson = INS_CTRL_QuoteConvert.generateRequestPayload(QUOTE_REFERENCE, buildInput());

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(payloadJson);

        Assert.areEqual(QUOTE_REFERENCE, payload.get('referenceNumber'),
            'referenceNumber should be the quote reference');
        Assert.areEqual(QUOTE_REFERENCE, payload.get('quoteNumber'),
            'quoteNumber should be the quote reference');
        Assert.isNotNull(payload.get('otpDate'), 'otpDate should be populated');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_QuoteConvert().call('wrongAction',
                new Map<String, Object>{
                    'input'  => buildInput(),
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }
}