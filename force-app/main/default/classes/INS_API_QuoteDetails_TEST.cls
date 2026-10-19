/**
 * @description             : Test class for INS_API_QuoteDetails
 * @story                   : SFP-50909
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_API_QuoteDetails_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_TOKEN    = 'TEST_TOKEN_123';

    private static final String MOCK_SUCCESS_BODY =
        '{"saleReferenceId": "' + TEST_QUOTE_ID + '",' +
        ' "saleData": {"status": "Inactive", "policyNettPremium": "674.39"}}';

    private static final String MOCK_ERROR_BODY =
        '{"error": {"errorCode": 500, "errorDescription": "Quote details service unavailable"}}';

    /**
     * @description Configurable mock for the quote details callout. Captures the
     *   request; assertions live in the @IsTest methods (see
     *   sf:NonUnitTestContainsAsserts).
     */
    private class QuoteDetailsMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedAuthHeader;
        public String capturedBusinessUnit;
        public String capturedChannelHeader;
        public String capturedCountryCode;
        public String capturedTransactionId;

        QuoteDetailsMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            this.capturedMethod        = req.getMethod();
            this.capturedEndpoint      = req.getEndpoint();
            this.capturedAuthHeader    = req.getHeader('Authorization');
            this.capturedBusinessUnit  = req.getHeader('business_unit');
            this.capturedChannelHeader = req.getHeader('channel');
            this.capturedCountryCode   = req.getHeader('country_code');
            this.capturedTransactionId = req.getHeader('transaction_id');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    private static QuoteDetailsMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteDetails.testAccessToken = TEST_TOKEN;
        QuoteDetailsMock mock = new QuoteDetailsMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    @IsTest
    static void getQuoteDetails_success() {
        QuoteDetailsMock mock = registerMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteDetails().getQuoteDetails(TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('saleData'), 'Response should contain the quote data');

        Assert.areEqual('GET', mock.capturedMethod, 'Expected GET method');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/quoteDetails'),
            'Endpoint should contain quoteId and quoteDetails path');
        Assert.areEqual('Bearer ' + TEST_TOKEN, mock.capturedAuthHeader,
            'Authorization header should carry the test access token');
        Assert.areEqual('Liberty', mock.capturedBusinessUnit, 'business_unit header missing');
        Assert.areEqual('salesforce', mock.capturedChannelHeader, 'channel header missing');
        Assert.isTrue(String.isNotBlank(mock.capturedCountryCode),
            'country_code header should be populated');
        Assert.isTrue(String.isNotBlank(mock.capturedTransactionId),
            'transaction_id header should be populated');
    }

    @IsTest
    static void getQuoteDetails_error() {
        registerMock(500, MOCK_ERROR_BODY);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteDetails().getQuoteDetails(TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}