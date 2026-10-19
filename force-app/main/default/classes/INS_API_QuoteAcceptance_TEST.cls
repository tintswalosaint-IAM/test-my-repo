/**
 * @description             : Test class for INS_API_QuoteAcceptance
 * @story                   : SFP-55651
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      :
 * @last modified by        :
 * @modification details    :
 */
@isTest
private class INS_API_QuoteAcceptance_TEST {

    private static final String TEST_QUOTE_ID =
        'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String TEST_ACCESS_TOKEN =
        'TEST_TOKEN_123';

    private static final String REQUEST_BODY =
        '{"paymentMethod": "DEBIT_ORDER"}';

    private static final String MOCK_SUCCESS_BODY =
        '{"policyNumber": "POL-000123456", "status": "ACCEPTED"}';

    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", ' +
        '"message": "Acceptance service unavailable"}';

    private static HttpRequest capturedRequest;

    /**
     * @description Configurable mock for the quote acceptance callout.
     */
    
    private class QuoteAcceptanceMock implements HttpCalloutMock {

        private final Integer statusCode;
        private final String responseBody;

        QuoteAcceptanceMock(
            Integer statusCode,
            String responseBody
        ) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HttpResponse respond(HTTPRequest request) {
            capturedRequest = request;

            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(statusCode);
            response.setBody(responseBody);

            return response;
        }
    }

    @isTest
    private static void quoteAcceptance_success() {
        configureMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteAcceptance().quoteAcceptance(
            REQUEST_BODY,
            TEST_QUOTE_ID
        );
        Test.stopTest();

        Assert.isNotNull(
            capturedRequest,
            'The callout request should have been captured'
        );
        Assert.areEqual(
            'POST',
            capturedRequest.getMethod(),
            'Expected POST method'
        );
        Assert.isTrue(
            capturedRequest.getEndpoint().contains(
                '/api/quotes/' + TEST_QUOTE_ID + '/acceptance'
            ),
            'Endpoint should contain the quote ID and acceptance path'
        );
        Assert.areEqual(
            'Bearer ' + TEST_ACCESS_TOKEN,
            capturedRequest.getHeader('Authorization'),
            'Authorization header should contain the access token'
        );
        Assert.areEqual(
            'salesforce',
            capturedRequest.getHeader('channel'),
            'Channel header should be populated'
        );
        Assert.isTrue(
            String.isNotBlank(
                capturedRequest.getHeader('transaction_id')
            ),
            'Transaction ID header should be populated'
        );
        Assert.isNotNull(
            result,
            'Response should not be null'
        );
        Assert.isTrue(
            result.contains('ACCEPTED'),
            'Response should contain acceptance status'
        );
        Assert.isTrue(
            result.contains('POL-000123456'),
            'Response should contain policy number'
        );
    }

    @isTest
    private static void quoteAcceptance_error() {
        configureMock(500, MOCK_ERROR_BODY);

        Test.startTest();
        try {
            new INS_API_QuoteAcceptance().quoteAcceptance(
                REQUEST_BODY,
                TEST_QUOTE_ID
            );

            Assert.fail(
                'Expected ServiceException for HTTP 500 response'
            );
        } catch (sbgplatform.ApiService.ServiceException exceptionValue) {
            Assert.isTrue(
                String.isNotBlank(exceptionValue.getMessage()),
                'Exception message should be populated'
            );
        }
        Test.stopTest();
    }

    /**
     * @description Configures the API mock and test access token.
     */
    private static void configureMock(
        Integer statusCode,
        String responseBody
    ) {
        capturedRequest = null;
        INS_API_QuoteAcceptance.testAccessToken = TEST_ACCESS_TOKEN;

        sbgplatform.ApiService.setMock(
            HttpCalloutMock.class,
            new QuoteAcceptanceMock(statusCode, responseBody)
        );
    }
}