/**
 * @description             : Test class for INS_CTRL_CallQuoteCreation
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
private class INS_CTRL_CallQuoteCreation_TEST {

    private static final String TEST_QUOTE_ID  = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String TEST_MEMBER_ID = 'mem-001';

    private static final String ACTION_CREATE_QUICK_QUOTE  = 'createQuickQuote';
    private static final String KEY_CREATE_QUOTE_RESPONSE  = 'CreateQuoteResponse';
    private static final String KEY_HAS_ERROR              = 'hasError';

    // Success body WITHOUT ValidationResult - exercises the validation == null branch
    private static final String BODY_SUCCESS_NO_VALIDATION =
        '{"quoteId": "' + TEST_QUOTE_ID + '", "members": [{"benefits": [' +
        '{"memberId": "' + TEST_MEMBER_ID + '", "benefitAmountValue": "250.50",' +
        ' "coverAmount": 500000.0, "duration": "Monthly", "benefitKey": "1.MAINFUNERAL"}]}]}';

    // Success body WITH ValidationResult.ResultStatus = Success
    private static final String BODY_SUCCESS_WITH_VALIDATION =
        '{"quoteId": "' + TEST_QUOTE_ID + '",' +
        ' "ValidationResult": {"ResultStatus": "Success"},' +
        ' "members": [{"benefits": [' +
        '{"memberId": "' + TEST_MEMBER_ID + '", "benefitAmountValue": "250.50",' +
        ' "coverAmount": 500000.0, "duration": "Monthly", "benefitKey": "1.MAINFUNERAL"}]}]}';

    // Validation failure body
    private static final String BODY_VALIDATION_FAILED =
        '{"ValidationResult": {"ResultStatus": "Failed", "Message": "Member age exceeds product limit"}}';

    // Error body - must still be valid JSON (controller parses it before checking status)
    private static final String BODY_SERVER_ERROR =
        '{"error": "Internal Server Error"}';

    /**
     * @description Configurable mock for the quote creation callout
     */
    private class QuoteCalloutMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        QuoteCalloutMock(Integer statusCode, String body) {
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

    // =========================================================================
    // TEST DATA HELPERS
    // =========================================================================

    /**
     * @description Real Account insert used purely to obtain a valid Id.
     *   Avoids sf:AvoidUsingHardCodedId - hardcoded 15/18-char Ids are
     *   fragile across orgs and don't reference a real record.
     */
    private static Id createTestAccountId() {
        Account acc = new Account(Name = 'Test Quote Account');
        insert acc;
        return acc.Id;
    }

    private static Map<String, Object> buildValidInput(Id accountId) {
        Map<String, Object> membersDetails = new Map<String, Object>{
            'FirstName'      => 'Amina',
            'LastName'       => 'Otieno',
            'IdNumber'       => '12345678',
            'Gender'         => 'Female',
            'Email'          => 'amina.otieno@example.com',
            'PhoneNumber'    => '712345678',
            'OS_DateOfBirth' => '1990-05-15'
        };

        // Default_Cover_Amount__c must be a Double - controller casts (Double)
        Double defaultCover = 500000;
        Map<String, Object> productsMetadata = new Map<String, Object>{
            'Product_Code__c'          => 'FLEXI_PROTECT',
            'Country__c'               => 'KE',
            'Default_Cover_Amount__c'  => defaultCover
        };

        return new Map<String, Object>{
            'MembersDetails' => membersDetails,
            'INS_Products'   => productsMetadata,
            'accountId'      => String.valueOf(accountId)
        };
    }

    private static Map<String, Object> invokeAction(String action, Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> args = new Map<String, Object>{
            'input'  => input,
            'output' => output
        };
        new INS_CTRL_CallQuoteCreation().call(action, args);
        return output;
    }

    private static void registerMock(Integer statusCode, String body) {
        INS_API_QuoteCreation.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new QuoteCalloutMock(statusCode, body));
    }

    // =========================================================================
    // SUCCESS PATHS
    // =========================================================================

    @IsTest
    static void createQuote_success_noValidationResult() {
        Id accountId = createTestAccountId();
        registerMock(200, BODY_SUCCESS_NO_VALIDATION);

        Test.startTest();
        Map<String, Object> output = invokeAction(ACTION_CREATE_QUICK_QUOTE, buildValidInput(accountId));
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(KEY_CREATE_QUOTE_RESPONSE);
        Assert.isNotNull(resp, 'CreateQuoteResponse should be present in output');
        Assert.areEqual('false', resp.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(TEST_QUOTE_ID, resp.get('quoteId'), 'quoteId should be mapped');
        Assert.areEqual(TEST_MEMBER_ID, resp.get('memberId'), 'memberId should be mapped from first benefit');
        Assert.areEqual('1.MAINFUNERAL', resp.get('benefitKey'), 'benefitKey should be mapped');
    }

    @IsTest
    static void createQuote_success_withValidationSuccess() {
        Id accountId = createTestAccountId();
        registerMock(200, BODY_SUCCESS_WITH_VALIDATION);

        Test.startTest();
        Map<String, Object> output = invokeAction(ACTION_CREATE_QUICK_QUOTE, buildValidInput(accountId));
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(KEY_CREATE_QUOTE_RESPONSE);
        Assert.areEqual('false', resp.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(TEST_QUOTE_ID, resp.get('quoteId'), 'quoteId should be mapped');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void createQuote_validationFailed() {
        Id accountId = createTestAccountId();
        registerMock(200, BODY_VALIDATION_FAILED);

        Test.startTest();
        Map<String, Object> output = invokeAction(ACTION_CREATE_QUICK_QUOTE, buildValidInput(accountId));
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(KEY_CREATE_QUOTE_RESPONSE);
        Assert.areEqual('true', resp.get(KEY_HAS_ERROR), 'hasError should be true on validation failure');
        Assert.areEqual('Member age exceeds product limit', resp.get('errorMessage'),
            'Validation message should be surfaced');
    }

    @IsTest
    static void createQuote_serverError() {
        Id accountId = createTestAccountId();
        registerMock(500, BODY_SERVER_ERROR);

        Test.startTest();
        Map<String, Object> output = invokeAction(ACTION_CREATE_QUICK_QUOTE, buildValidInput(accountId));
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(KEY_CREATE_QUOTE_RESPONSE);
        Assert.areEqual('true', resp.get(KEY_HAS_ERROR), 'hasError should be true for non-2xx status');
        Assert.areEqual('API returned status: 500', resp.get('errorMessage'),
            'Status code should be surfaced in error message');
    }

    // =========================================================================
    // CALLABLE CONTRACT / INPUT VALIDATION
    // =========================================================================

    @IsTest
    static void call_unsupportedAction_throws() {
        Id accountId = createTestAccountId();
        Boolean thrown = false;
        try {
            invokeAction('nonExistentAction', buildValidInput(accountId));
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }

    @IsTest
    static void call_missingInputMap_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_CallQuoteCreation().call(ACTION_CREATE_QUICK_QUOTE,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Missing input map should throw AuraHandledException');
    }

    @IsTest
    static void createQuote_invalidDateOfBirth_throws() {
        Id accountId = createTestAccountId();
        registerMock(200, BODY_SUCCESS_NO_VALIDATION);

        Map<String, Object> input = buildValidInput(accountId);
        ((Map<String, Object>) input.get('MembersDetails')).put('OS_DateOfBirth', 'not-a-date');

        Boolean thrown = false;
        try {
            invokeAction(ACTION_CREATE_QUICK_QUOTE, input);
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Invalid DOB should throw AuraHandledException');
    }
}