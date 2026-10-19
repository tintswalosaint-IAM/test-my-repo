/**
 * @description             : Test class for INS_API_QuoteCreation
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_QuoteCreation_TEST {

    private static final String MOCK_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String MOCK_SUCCESS_BODY = '{"quoteId": "' + MOCK_QUOTE_ID + '"}';

    /**
     * @description Mock for the quote creation callout - success response (200)
     */
    private class QuoteCreationSuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(MOCK_SUCCESS_BODY);
            res.setStatusCode(200);
            return res;
        }
    }

	/**
     * @description Mock for the quote creation callout - error response (500)
     */
    private class QuoteCreationErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "Internal Server Error", "message": "Quote engine unavailable"}');
            res.setStatusCode(500);
            return res;
        }
    }

    @isTest
    static void postQuickQuote_success() {
        // Bypass the real KYC token callout
		Test.startTest();
        INS_API_QuoteCreation.testAccessToken = 'TEST_TOKEN_123';

        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new QuoteCreationSuccessMock());
        String requestPayload = '{"age": 35, "coverAmount": 500000}';        
        String result = new INS_API_QuoteCreation().postQuickQuote(requestPayload);
        Test.stopTest();
        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains(MOCK_QUOTE_ID), 'Response should contain the quoteId');
    }

	 @IsTest
    static void postQuickQuote_error() {
        INS_API_QuoteCreation.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new QuoteCreationErrorMock());

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteCreation().postQuickQuote('{"age": 35, "coverAmount": 500000}');
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}