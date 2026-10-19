/**
 * @description             : Test class for INS_API_QuoteConvert
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
private class INS_API_QuoteConvert_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_TOKEN    = 'TEST_TOKEN_123';

    private static final String TEST_PAYLOAD =
        '{"referenceNumber": "' + TEST_QUOTE_ID + '", "quoteNumber": "' + TEST_QUOTE_ID + '",' +
        ' "consultantCode": "12345", "otpNumber": "123456", "otpDate": "2026-08-24"}';

    private static final String MOCK_SUCCESS_BODY =
        '{"policyNumber": "KA5111905", "status": "Inactive",' +
        ' "saleReferenceId": "' + TEST_QUOTE_ID + '"}';

    private static final String MOCK_ERROR_BODY =
        '{"error": {"errorCode": 500, "errorDescription": "Conversion service unavailable"}}';

    /**
     * @description Configurable mock for the quote conversion callout. Captures
     *   the request; assertions live in the @IsTest methods (see
     *   sf:NonUnitTestContainsAsserts).
     */
    private class QuoteConvertMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedAuthHeader;
        public String capturedBusinessUnit;
        public String capturedChannelHeader;
        public String capturedTransactionId;

        QuoteConvertMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            this.capturedMethod        = req.getMethod();
            this.capturedEndpoint      = req.getEndpoint();
            this.capturedAuthHeader    = req.getHeader('Authorization');
            this.capturedBusinessUnit  = req.getHeader('business_unit');
            this.capturedChannelHeader = req.getHeader('channel');
            this.capturedTransactionId = req.getHeader('transaction_id');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    private static QuoteConvertMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteConvert.testAccessToken = TEST_TOKEN;
        QuoteConvertMock mock = new QuoteConvertMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    @IsTest
    static void quoteConversion_success() {
        QuoteConvertMock mock = registerMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteConvert().quoteConversion(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('KA5111905'), 'Response should contain the policy number');

        Assert.areEqual('POST', mock.capturedMethod, 'Expected POST method');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/conversion'),
            'Endpoint should contain quoteId and conversion path');
        Assert.areEqual('Bearer ' + TEST_TOKEN, mock.capturedAuthHeader,
            'Authorization header should carry the test access token');
        Assert.areEqual('Liberty', mock.capturedBusinessUnit, 'business_unit header missing');
        Assert.areEqual('salesforce', mock.capturedChannelHeader, 'channel header missing');
        Assert.isTrue(String.isNotBlank(mock.capturedTransactionId),
            'transaction_id header should be populated');
    }

    @IsTest
    static void quoteConversion_error() {
        registerMock(500, MOCK_ERROR_BODY);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteConvert().quoteConversion(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}