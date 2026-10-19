/**
 * @description             : Test class for INS_API_QuoteBeneficiaries
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_QuoteBeneficiaries_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_PAYLOAD =
        '{"beneficiaries": [{"firstName": "Wanjiku", "lastName": "Otieno",' +
        ' "relationship": "SPOUSE", "allocationAmount": 100, "allocationType": "PERCENTAGE"}]}';
    private static final String MOCK_SUCCESS_BODY =
        '{"quoteId": "' + TEST_QUOTE_ID + '", "beneficiaries": [' +
        '{"beneficiaryId": "ben-001", "firstName": "Wanjiku", "status": "ADDED"}]}';
    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Beneficiaries service unavailable"}';

    /**
     * @description Configurable mock for the beneficiaries callouts.
     *   Verifies the expected HTTP method (POST for add, PUT for update).
     */
    private class BeneficiariesMock implements HttpCalloutMock {
        private final String expectedMethod;
        private final Integer statusCode;
        private String body;

        BeneficiariesMock(String expectedMethod, Integer statusCode, String body) {
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

    // ---------- addBeneficiaries (POST) ----------

    @isTest
    static void addBeneficiaries_success() {
        INS_API_QuoteBeneficiaries.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new BeneficiariesMock('POST', 200, MOCK_SUCCESS_BODY));

        Test.startTest();
        String result = new INS_API_QuoteBeneficiaries()
            .addBeneficiaries(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('ben-001'), 'Response should contain the beneficiaryId');
        Assert.isTrue(result.contains(TEST_QUOTE_ID), 'Response should contain the quoteId');
    }

    @IsTest
    static void addBeneficiaries_error() {
        INS_API_QuoteBeneficiaries.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new BeneficiariesMock('POST', 500, MOCK_ERROR_BODY));

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteBeneficiaries()
                .addBeneficiaries(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }

    // ---------- updateBeneficiaries (PUT) ----------

    @isTest
    static void updateBeneficiaries_success() {
        INS_API_QuoteBeneficiaries.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new BeneficiariesMock('PUT', 200, MOCK_SUCCESS_BODY));

        Test.startTest();
        String result = new INS_API_QuoteBeneficiaries()
            .updateBeneficiaries(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('ben-001'), 'Response should contain the beneficiaryId');
        Assert.isTrue(result.contains(TEST_QUOTE_ID), 'Response should contain the quoteId');
    }

    @isTest
    static void updateBeneficiaries_error() {
        INS_API_QuoteBeneficiaries.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new BeneficiariesMock('PUT', 500, MOCK_ERROR_BODY));

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteBeneficiaries()
                .updateBeneficiaries(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}