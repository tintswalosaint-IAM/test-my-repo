/**
 * @description             : Test class for INS_CTRL_QuoteBeneficiaries
 * @story                   : SFP-56009
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
private class INS_CTRL_QuoteBeneficiaries_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String KEY_HAS_ERROR     = 'hasError';
    private static final String KEY_BENEFICIARIES = 'beneficiaries';
    private static final String ACTION_CALL_BENEFICIARIES = 'CallBeneficiaries';

    private static final String BODY_PREFIX =
        '{"referenceNumber": "' + TEST_QUOTE_ID + '", "beneficiaries": ';

    private static final String BODY_SUCCESS =
        BODY_PREFIX + '[{"beneficiaryId": "ben-001"}, {"beneficiaryId": "ben-002"}]}';

    // One valid id, one missing - exercises the partial-error path
    private static final String BODY_PARTIAL =
        BODY_PREFIX + '[{"beneficiaryId": "ben-001"}, {"someOtherField": "x"}]}';

    private static final String BODY_NO_IDS =
        BODY_PREFIX + '[{"someOtherField": "x"}]}';

    private static final String BODY_EMPTY_LIST =
        BODY_PREFIX + '[]}';

    private static final String BODY_NO_KEY = '{"referenceNumber": "' + TEST_QUOTE_ID + '"}';

    private static final String BODY_NOT_JSON = 'not json <<<';

    /**
     * @description Configurable mock. Captures method, endpoint and outbound
     *   payload; assertions live in the @IsTest methods (see
     *   sf:NonUnitTestContainsAsserts).
     */
    private class BeneficiariesMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedRequestBody;

        BeneficiariesMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedMethod      = req.getMethod();
            this.capturedEndpoint    = req.getEndpoint();
            this.capturedRequestBody = req.getBody();

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    // =========================================================================
    // TEST HELPERS
    // =========================================================================

    private static BeneficiariesMock registerMock(Integer statusCode, String body) {
        INS_API_QuoteBeneficiaries.testAccessToken = 'TEST_TOKEN_123';
        BeneficiariesMock mock = new BeneficiariesMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static Map<String, Object> buildMember() {
        return new Map<String, Object>{
            'FirstName__c'          => 'Wanjiku',
            'LastName__c'           => 'Otieno',
            'title'                 => 'Mrs',
            'RelationshipToInsured' => 'SPOUSE',
            'IdentityNumber__c'     => '87654321',
            'IdType__c'             => 'SAIDENTITYDOCUMENT',
            'Gender__c'             => 'Female',
            'beneficiaryId'         => '',
            'memberId'              => 'mem-001',
            'Allocation__c'         => '100',
            'BirthDate__c'          => '1992-08-20T00:00:00.000Z',
            'EmailAddress__c'       => 'wanjiku@example.com',
            'PhoneNumber__c'        => '254712345678'
        };
    }

    private static Map<String, Object> buildValidInput() {
        return new Map<String, Object>{
            'quoteId' => TEST_QUOTE_ID,
            'BeneficiarySummary' => new Map<String, Object>{
                'members' => new List<Object>{ buildMember() }
            }
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteBeneficiaries().call(ACTION_CALL_BENEFICIARIES,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static Map<String, Object> getSummary(Map<String, Object> output) {
        return (Map<String, Object>) output.get('BeneficiarySummary');
    }

    // =========================================================================
    // SUCCESS PATHS
    // =========================================================================

    @IsTest
    static void callBeneficiaries_success() {
        BeneficiariesMock mock = registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildValidInput());
        Test.stopTest();

        Map<String, Object> summary = getSummary(output);
        Assert.areEqual(false, summary.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(TEST_QUOTE_ID, summary.get('referenceNumber'),
            'referenceNumber should be mapped');

        List<Object> ids = (List<Object>) summary.get(KEY_BENEFICIARIES);
        Assert.areEqual(2, ids.size(), 'Both beneficiaryIds should be returned');
        Assert.areEqual('ben-001',
            ((Map<String, Object>) ids[0]).get('beneficiaryId'), 'First id should be mapped');

        // Request assertions (moved out of the mock)
        Assert.areEqual('POST', mock.capturedMethod, 'Controller should always POST (addBeneficiaries)');
        Assert.isTrue(
            mock.capturedEndpoint.contains('/api/quotes/' + TEST_QUOTE_ID + '/beneficiaries'),
            'Endpoint should contain quoteId and beneficiaries path');

        // Outbound payload spot-checks (end-to-end through buildBeneficiaryPayload)
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual(TEST_QUOTE_ID, payload.get('referenceNumber'),
            'Payload referenceNumber should be the quoteId');
        List<Object> sent = (List<Object>) payload.get(KEY_BENEFICIARIES);
        Assert.areEqual(1, sent.size(), 'One beneficiary should be sent');
        Map<String, Object> ben = (Map<String, Object>) sent[0];
        Assert.areEqual('WO', ben.get('initials'), 'Initials should be built from names');
        Assert.areEqual(100, ben.get('allocationAmount'), 'Allocation should parse to Integer');
        Assert.areEqual(2, ((List<Object>) ben.get('contacts')).size(),
            'Email and mobile contacts should both be present');
    }

    @IsTest
    static void callBeneficiaries_partialIds_flagsErrorButReturnsIds() {
        registerMock(200, BODY_PARTIAL);

        Test.startTest();
        Map<String, Object> output = invokeAction(buildValidInput());
        Test.stopTest();

        Map<String, Object> summary = getSummary(output);
        Assert.areEqual(true, summary.get(KEY_HAS_ERROR),
            'hasError should be true when any beneficiary lacks an id');
        List<Object> ids = (List<Object>) summary.get(KEY_BENEFICIARIES);
        Assert.areEqual(1, ids.size(), 'Valid ids should still be returned');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    /*------------------------------------------------------------
     *  Data-driven: five distinct error scenarios (non-2xx, unparseable
     *  body, missing beneficiaries key, empty beneficiaries list, no
     *  beneficiaryId present) all assert hasError=true plus a message
     *  substring. Consolidated from five separate methods to address
     *  sf:TooManyMethods without losing any scenario.
     *------------------------------------------------------------*/
    @IsTest
    static void callBeneficiaries_errorScenarios_returnError() {
        Map<String, Object> scenarioBodies = new Map<String, Object>{
            'non-2xx response'          => new List<Object>{ 500, '{"error": "boom"}' },
            'unparseable body'          => new List<Object>{ 200, BODY_NOT_JSON },
            'missing beneficiaries key' => new List<Object>{ 200, BODY_NO_KEY },
            'empty beneficiaries list'  => new List<Object>{ 200, BODY_EMPTY_LIST },
            'no beneficiaryId present'  => new List<Object>{ 200, BODY_NO_IDS }
        };

        Map<String, String> expectedMessageFragments = new Map<String, String>{
            'non-2xx response'          => 'API error 500',
            'unparseable body'          => 'Failed to parse',
            'no beneficiaryId present'  => 'No beneficiaryId returned'
            // 'missing beneficiaries key' and 'empty beneficiaries list' only
            // assert hasError=true; both produce the same generic
            // "No beneficiaries returned" message and don't need a distinct check
        };

        Test.startTest();
        for (String scenario : scenarioBodies.keySet()) {
            List<Object> params = (List<Object>) scenarioBodies.get(scenario);
            registerMock((Integer) params[0], (String) params[1]);

            Map<String, Object> summary = getSummary(invokeAction(buildValidInput()));

            Assert.areEqual(true, summary.get(KEY_HAS_ERROR),
                'hasError should be true for: ' + scenario);

            if (expectedMessageFragments.containsKey(scenario)) {
                Assert.isTrue(
                    String.valueOf(summary.get('error')).contains(expectedMessageFragments.get(scenario)),
                    'Error message should contain "' + expectedMessageFragments.get(scenario)
                        + '" for: ' + scenario);
            }
        }
        Test.stopTest();
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Boolean unsupportedActionThrown = false;
        try {
            new INS_CTRL_QuoteBeneficiaries().call('wrongAction',
                new Map<String, Object>{
                    'input'  => buildValidInput(),
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedActionThrown = true;
        }
        Assert.isTrue(unsupportedActionThrown, 'Unsupported action should throw AuraHandledException');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_QuoteBeneficiaries().call(ACTION_CALL_BENEFICIARIES,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown, 'Missing input map should throw AuraHandledException');
    }

    // =========================================================================
    // PAYLOAD BUILDER (direct unit tests)
    // =========================================================================

    @IsTest
    static void buildPayload_missingSummary_returnsEmptyBeneficiaries() {
        String payloadJson = INS_CTRL_QuoteBeneficiaries.buildBeneficiaryPayload(
            TEST_QUOTE_ID, new Map<String, Object>{ 'quoteId' => TEST_QUOTE_ID });

        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
        Assert.areEqual(TEST_QUOTE_ID, payload.get('referenceNumber'),
            'referenceNumber should still be set');
        Assert.areEqual(0, ((List<Object>) payload.get(KEY_BENEFICIARIES)).size(),
            'Missing BeneficiarySummary should yield empty beneficiaries');
    }

    @IsTest
    static void buildPayload_memberWithoutContacts_sendsEmptyContactList() {
        Map<String, Object> member = buildMember();
        member.remove('EmailAddress__c');
        member.remove('PhoneNumber__c');
        member.put('Allocation__c', null);
        member.put('BirthDate__c', 'garbage-date');

        Map<String, Object> input = new Map<String, Object>{
            'quoteId' => TEST_QUOTE_ID,
            'BeneficiarySummary' => new Map<String, Object>{
                'members' => new List<Object>{ member }
            }
        };

        String payloadJson = INS_CTRL_QuoteBeneficiaries.buildBeneficiaryPayload(TEST_QUOTE_ID, input);
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(payloadJson);
        Map<String, Object> ben =
            (Map<String, Object>) ((List<Object>) payload.get(KEY_BENEFICIARIES))[0];

        Assert.areEqual(0, ((List<Object>) ben.get('contacts')).size(),
            'No email/phone should yield empty contacts');
        Assert.areEqual(0, ben.get('allocationAmount'),
            'Null allocation should default to 0');
        Assert.isNull(ben.get('dateOfBirth'),
            'Invalid DOB should serialize as null');
    }
}