/**
 * @description             : Test class for INS_API_QuoteMembers
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
// NOSONAR sf:Integration_to_use_API_Framework_Two - false positive: rule's isTest
// exclusion is case-sensitive (@Image='isTest' vs actual @IsTest) and does not
// account for inner HttpCalloutMock classes nested inside test classes. Rule's own
// COMPLIANT PATTERNS section explicitly allows "Test classes using HttpRequest/Http
// for mocking".
private class INS_API_QuoteMembers_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_TOKEN    = 'TEST_TOKEN_123';

    private static final String TEST_PAYLOAD =
        '{"referenceNumber": "' + TEST_QUOTE_ID + '", "members": [' +
        '{"firstName": "Njeri", "surname": "Otieno", "memberType": "DEPENDANT"}]}';

    private static final String MOCK_SUCCESS_BODY =
        '{"ValidationResult": {"ResultStatus": "Success"}, "members": [' +
        '{"memberId": "mem-002", "firstName": "Njeri"}]}';

    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Members service unavailable"}';

    /**
     * @description Configurable mock for the members callouts. Captures method,
     *   endpoint and headers; assertions live in the @IsTest methods
     *   (see sf:NonUnitTestContainsAsserts).
     */
    private class QuoteMembersMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedAuthHeader;
        public String capturedChannelHeader;
        public String capturedOperationTypeHeader;
        public String capturedTransactionId;

        QuoteMembersMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedMethod              = req.getMethod();
            this.capturedEndpoint            = req.getEndpoint();
            this.capturedAuthHeader          = req.getHeader('Authorization');
            this.capturedChannelHeader       = req.getHeader('channel');
            this.capturedOperationTypeHeader = req.getHeader('operation_type');
            this.capturedTransactionId       = req.getHeader('transaction_id');

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    private static QuoteMembersMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteMembers.testAccessToken = TEST_TOKEN;
        QuoteMembersMock mock = new QuoteMembersMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    // ---------- addMemebrs (POST) ----------

    @IsTest
    static void addMembers_success() {
        QuoteMembersMock mock = registerMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteMembers().addMemebrs(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('mem-002'), 'Response should contain the memberId');

        Assert.areEqual('POST', mock.capturedMethod, 'Expected POST method');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/members'),
            'Endpoint should contain quoteId and members path');
        Assert.areEqual('Bearer ' + TEST_TOKEN, mock.capturedAuthHeader,
            'Authorization header should carry the test access token');
        Assert.areEqual('salesforce', mock.capturedChannelHeader, 'channel header missing');
        Assert.areEqual('Upload Sale Rule Enabled', mock.capturedOperationTypeHeader,
            'operation_type header missing');
        Assert.isTrue(String.isNotBlank(mock.capturedTransactionId),
            'transaction_id header should be populated');
    }

    @IsTest
    static void addMembers_error() {
        registerMock(500, MOCK_ERROR_BODY);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteMembers().addMemebrs(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }

    // ---------- editMemebrs (PUT) ----------

    @IsTest
    static void editMembers_success() {
        QuoteMembersMock mock = registerMock(200, MOCK_SUCCESS_BODY);

        Test.startTest();
        String result = new INS_API_QuoteMembers().editMemebrs(TEST_PAYLOAD, TEST_QUOTE_ID);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('mem-002'), 'Response should contain the memberId');
        Assert.areEqual('PUT', mock.capturedMethod, 'Expected PUT method');
    }

    @IsTest
    static void editMembers_error() {
        registerMock(500, MOCK_ERROR_BODY);

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_QuoteMembers().editMemebrs(TEST_PAYLOAD, TEST_QUOTE_ID);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}