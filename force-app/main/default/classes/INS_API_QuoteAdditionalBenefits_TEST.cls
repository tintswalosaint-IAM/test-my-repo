/**
 * @description             : Test class for INS_API_QuoteAdditionalBenefits
 * @story                   : SFP-55708
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_QuoteAdditionalBenefits_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_PAYLOAD = '{"benefitCode": "ACC_DEATH", "coverAmount": 100000}';
    private static final String MOCK_SUCCESS_BODY =
        '{"quoteId": "' + TEST_QUOTE_ID + '", "additionalBenefits": [{"benefitCode": "ACC_DEATH", "status": "ADDED"}]}';
    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Benefits service unavailable"}';

    /**
     * @description Configurable mock for the additional benefits callouts.
     *   Verifies the expected HTTP method (POST for add, PUT for update).
     */
    private class AdditionalBenefitsMock implements HttpCalloutMock {
        private String expectedMethod;
        private final Integer statusCode;
        private final String body;

        AdditionalBenefitsMock(String expectedMethod, Integer statusCode, String body) {
            this.expectedMethod = expectedMethod;
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    // ---------- addAdditionalBenefits (POST) ----------

    @isTest
    static void addAdditionalBenefits_success() {
        INS_API_QuoteAdditionalBenefits.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new AdditionalBenefitsMock('POST', 200, MOCK_SUCCESS_BODY));

        Test.startTest();
        String result = new INS_API_QuoteAdditionalBenefits()
            .addAdditionalBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('ACC_DEATH'), 'Response should contain the benefit code');
        Assert.isTrue(result.contains(TEST_QUOTE_ID), 'Response should contain the quoteId');
    }

    @isTest
    static void addAdditionalBenefits_error() {
        INS_API_QuoteAdditionalBenefits.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new AdditionalBenefitsMock('POST', 500, MOCK_ERROR_BODY));

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteAdditionalBenefits()
                .addAdditionalBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }

    // ---------- updateAdditionalBenefits (PUT) ----------

    @isTest
    static void updateAdditionalBenefits_success() {
        INS_API_QuoteAdditionalBenefits.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new AdditionalBenefitsMock('PUT', 200, MOCK_SUCCESS_BODY));

        Test.startTest();
        String result = new INS_API_QuoteAdditionalBenefits()
            .updateAdditionalBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('ACC_DEATH'), 'Response should contain the benefit code');
        Assert.isTrue(result.contains(TEST_QUOTE_ID), 'Response should contain the quoteId');
    }

    @isTest
    static void updateAdditionalBenefits_error() {
        INS_API_QuoteAdditionalBenefits.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new AdditionalBenefitsMock('PUT', 500, MOCK_ERROR_BODY));

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteAdditionalBenefits()
                .updateAdditionalBenefits(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}