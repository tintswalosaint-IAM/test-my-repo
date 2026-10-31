/**
 * @description             : Test class for INS_CTRL_QuoteAcceptance
 * @story                   : SFP-55651
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_CTRL_QuoteAcceptance_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String QUOTE_ACCEPT_RESPONSE = 'quoteAcceptResponse';

    private static final String BODY_SUCCESS =
        '{"ValidationResult": {"ResultStatus": "Success"}, "policyNumber": "POL-000123456"}';

    private static final String BODY_ERROR_WITH_MAP =
        '{"error": {"errorDescription": "Wallet number failed validation"}}';

    private static final String BODY_ERROR_NO_MAP =
        '{"message": "Gateway timeout"}';

    private class AcceptanceMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        AcceptanceMock(Integer statusCode, String body) {
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

    private static Map<String, Object> buildValidInput() {
        return new Map<String, Object>{
            'quoteId' => TEST_QUOTE_ID,
            'INS_Products__mdt' => new Map<String, Object>{
                'Country__c'            => 'KE',
                'Country_of_Issue__c'   => 'KE',
                'MPESA_Branch_Code__c'  => '000000'
            },
            'PaymentDetails' => new Map<String, Object>{
                'CollectionDay' => '15',
                'WalletNumber'  => '712345678'
            },
            'MembersDetails' => new Map<String, Object>{
                'FirstName'      => 'Amina',
                'LastName'       => 'Otieno',
                'IdNumber'       => '12345678',
                'Gender'         => 'Female',
                'OS_DateOfBirth' => '1990-05-15'
            }
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteAcceptance().call('QuoteAcceptance',
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static void registerMock(Integer statusCode, String body) {
        INS_API_QuoteAcceptance.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new AcceptanceMock(statusCode, body));
    }

    // =========================================================================
    // SUCCESS PATH
    // =========================================================================

    @isTest
    static void quoteAcceptance_success() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildValidInput());
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(QUOTE_ACCEPT_RESPONSE);
        Assert.isNotNull(resp, 'quoteAcceptResponse should be present in output');
        Assert.areEqual('Success', resp.get('ResultStatus'), 'ResultStatus should be Success');
        Assert.areEqual(false, resp.get('hasError'), 'hasError should be false');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void quoteAcceptance_error_withErrorMap() {
        registerMock(500, BODY_ERROR_WITH_MAP);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildValidInput());
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(QUOTE_ACCEPT_RESPONSE);
        Assert.areEqual(true, resp.get('hasError'), 'hasError should be true');
        Assert.areEqual('Wallet number failed validation', resp.get(QUOTE_ACCEPT_RESPONSE),
            'errorDescription should be surfaced');
    }

    @IsTest
    static void quoteAcceptance_error_withoutErrorMap() {
        registerMock(500, BODY_ERROR_NO_MAP);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildValidInput());
        Test.stopTest();

        Map<String, Object> resp = (Map<String, Object>) output.get(QUOTE_ACCEPT_RESPONSE);
        Assert.areEqual(true, resp.get('hasError'), 'hasError should be true');
        Assert.areEqual(BODY_ERROR_NO_MAP, resp.get(QUOTE_ACCEPT_RESPONSE),
            'Raw response should be surfaced when no error map present');
    }

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_QuoteAcceptance().call('wrongAction',
                new Map<String, Object>{
                    'input' => buildValidInput(),
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }

    // =========================================================================
    // PAYLOAD BUILDER
    // =========================================================================

    @IsTest
    static void generateRequestPayload_mapsFieldsCorrectly() {
        String payloadJson = INS_CTRL_QuoteAcceptance.generateRequestPayload(TEST_QUOTE_ID, buildValidInput());
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);

        Assert.areEqual(TEST_QUOTE_ID, payload.get('policyNumber'), 'policyNumber should be quoteId');
        Assert.areEqual('15', payload.get('DebitOrderDate'), 'DebitOrderDate should pass through');

        Map<String, Object> banking = (Map<String, Object>) payload.get('BankingDetails');
        Assert.areEqual('254712345678', banking.get('contactNumber'),
            'KE wallet number should be prefixed with 254');
        Assert.areEqual('254712345678', banking.get('accountNumber'),
            'accountNumber should carry the prefixed wallet number');
        Assert.areEqual('Amina Otieno', banking.get('name'), 'name should concatenate first and last');
    }

    @IsTest
    static void generateRequestPayload_lastDayOfMonth() {
        Map<String, Object> input = buildValidInput();
        ((Map<String, Object>) input.get('PaymentDetails')).put('CollectionDay', 'LastdayofMonth');

        String payloadJson = INS_CTRL_QuoteAcceptance.generateRequestPayload(TEST_QUOTE_ID, input);
        Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(payloadJson);

        Assert.areEqual('-1', payload.get('DebitOrderDate'),
            'LastdayofMonth should map to -1');
    }
}