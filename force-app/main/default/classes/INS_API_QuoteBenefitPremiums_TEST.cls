/**
 * @description             : Test class for INS_API_QuoteBenefitPremiums
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_QuoteBenefitPremiums_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_PAYLOAD =
        '{"referenceNumber": "' + TEST_QUOTE_ID + '", "benefits": [' +
        '{"benefitKey": "1.MAINFUNERAL", "amount": 500000}]}';

    private static final String MOCK_SUCCESS_BODY =
        '{"benefits": [{"benefitKey": "1.MAINFUNERAL", "benefitAmountValue": "551.59"}]}';
    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Benefit premiums service unavailable"}';

    /**
     * @description Configurable mock for the benefit premiums callout. Captures
     *   the request; assertions live in the @IsTest methods (see
     *   sf:NonUnitTestContainsAsserts).
     */
    private class BenefitPremiumsMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedAuthHeader;
        public String capturedChannelHeader;
        public String capturedTransactionId;

        BenefitPremiumsMock(Integer statusCode, String body) {
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

    private static BenefitPremiumsMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteBenefitPremiums.testAccessToken = 'TEST_TOKEN_123';
        BenefitPremiumsMock mock = new BenefitPremiumsMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    @isTest
    static void getBenefitPremiums_success() {
        BenefitPremiumsMock mock = registerMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteBenefitPremiums()
            .getBenefitPremiums(TEST_QUOTE_ID, TEST_PAYLOAD);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('551.59'), 'Response should contain the calculated premium');

        // Request assertions
        Assert.areEqual('POST', mock.capturedMethod, 'Expected POST method');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/benefitPremiums'),
            'Endpoint should contain quoteId and benefitPremiums path');
        Assert.areEqual('Bearer TEST_TOKEN_123', mock.capturedAuthHeader,
            'Authorization header should carry the test access token');
        Assert.areEqual('salesforce', mock.capturedChannelHeader, 'channel header missing');
        Assert.isTrue(String.isNotBlank(mock.capturedTransactionId),
            'transaction_id header should be populated');
    }

    @isTest
    static void getBenefitPremiums_error() {
        registerMock(500, MOCK_ERROR_BODY);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteBenefitPremiums()
                .getBenefitPremiums(TEST_QUOTE_ID, TEST_PAYLOAD);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}