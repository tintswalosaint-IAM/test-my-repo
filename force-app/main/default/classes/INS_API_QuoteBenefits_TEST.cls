/**
 * @description             : Test class for INS_API_QuoteBenefits
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_QuoteBenefits_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_PAYLOAD =
        '{"QuoteNumber": "' + TEST_QUOTE_ID + '", "paymentFrequency": "Monthly",' +
        ' "additionalBenefits": [{"benefitType": "CashBackOption", "benefitValue": "true"}]}';
    private static final String MOCK_SUCCESS_BODY =
        '{"monthlyPremium": 250.50, "annualPremium": 3006.00}';
    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Benefits service unavailable"}';

    /**
     * @description Configurable mock for the quote benefits callout.
     *   Captures the request only - assertions live in the @IsTest methods
     *   (see sf:NonUnitTestContainsAsserts).
     */
    // NOSONAR sf:Integration_to_use_API_Framework_Two - false positive: rule's isTest
    // exclusion is case-sensitive (@Image='isTest' vs actual @IsTest) and does not
    // account for inner HttpCalloutMock classes nested inside test classes. Rule's own
    // COMPLIANT PATTERNS section explicitly allows "Test classes using HttpRequest/Http
    // for mocking".
    private class QuoteBenefitsMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedAuthHeader;
        public String capturedChannelHeader;
        public String capturedTransactionId;

        QuoteBenefitsMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedMethod        = req.getMethod();
            this.capturedEndpoint      = req.getEndpoint();
            this.capturedAuthHeader    = req.getHeader('Authorization');
            this.capturedChannelHeader = req.getHeader('channel');
            this.capturedTransactionId = req.getHeader('transaction_id');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    @IsTest
    static void putQuoteBenefits_success() {
        INS_API_QuoteBenefits.testAccessToken = 'TEST_TOKEN_123';
        QuoteBenefitsMock mock = new QuoteBenefitsMock(200, MOCK_SUCCESS_BODY);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        String result = new INS_API_QuoteBenefits()
            .putQuoteBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        // Response assertions
        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('monthlyPremium'), 'Response should contain premiums');

        // Request-construction assertions (moved out of the mock)
        Assert.areEqual('PUT', mock.capturedMethod, 'Expected PUT method');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/benefits'),
            'Endpoint should contain quoteId and benefits path');
        Assert.areEqual('Bearer TEST_TOKEN_123', mock.capturedAuthHeader,
            'Authorization header should carry the test access token');
        Assert.areEqual('salesforce', mock.capturedChannelHeader, 'channel header missing');
        Assert.isTrue(String.isNotBlank(mock.capturedTransactionId),
            'transaction_id header should be populated');
    }

    @IsTest
    static void putQuoteBenefits_error() {
        INS_API_QuoteBenefits.testAccessToken = 'TEST_TOKEN_123';
        QuoteBenefitsMock mock = new QuoteBenefitsMock(500, MOCK_ERROR_BODY);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteBenefits()
                .putQuoteBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');

        // Request was still built correctly before the framework threw on the 500
        Assert.areEqual('PUT', mock.capturedMethod, 'Expected PUT method even on error path');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/benefits'),
            'Endpoint should contain quoteId and benefits path');
    }
}