/**
 * @description             : Test class for INS_CTRL_QuoteDetails
 * @story                   : SFP-50909
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_QuoteDetails_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    private static final String ACTION_GET_QUICK_QUOTE = 'getQuickQuote';
    private static final String KEY_QUOTE_ID  = 'quoteId';
    private static final String KEY_HAS_ERROR = 'hasError';

    /**
     * Main member (Salman Khan) with funeral + catering, one beneficiary
     * (Father Khan) repeated across both benefits, plus a spouse life assured.
     */
    private static final String BODY_SUCCESS =
        '{"saleReferenceId": "' + TEST_QUOTE_ID + '",' +
        ' "saleData": {' +
        '   "status": "Inactive",' +
        '   "policyNettPremium": "674.39",' +
        '   "premiumFrequency": "Monthly",' +
        '   "thirdPartyPolicy": "0",' +
        '   "benefitArray": [' +
        '     {"benefitId": "1", "benefitSumAssured": 500000, "benefitPremium": 496.25,' +
        '      "benefitRoleplayerArray": [' +
        '        {"benefitRoleplayerType": "Life Assured", "benefitRoleplayerFirstname": "Salman",' +
        '         "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-01",' +
        '         "benefitRoleplayerGender": "M", "benefitRoleplayerIdNumber": "78678688",' +
        '         "benefitRoleplayerRelationshipToOwner": "Main"},' +
        '        {"benefitRoleplayerType": "Beneficiary", "benefitRoleplayerFirstname": "Father",' +
        '         "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-01",' +
        '         "benefitRoleplayerGender": "M", "benefitRoleplayerPercentage": "100",' +
        '         "benefitRoleplayerRelationshipToOwner": "FATHER"}]},' +
        '     {"benefitId": "7", "benefitSumAssured": 50000, "benefitPremium": 35.51,' +
        '      "benefitRoleplayerArray": [' +
        '        {"benefitRoleplayerType": "Life Assured", "benefitRoleplayerFirstname": "Salman",' +
        '         "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-01",' +
        '         "benefitRoleplayerRelationshipToOwner": "Main"},' +
        '        {"benefitRoleplayerType": "Beneficiary", "benefitRoleplayerFirstname": "Father",' +
        '         "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-01",' +
        '         "benefitRoleplayerPercentage": "100",' +
        '         "benefitRoleplayerRelationshipToOwner": "FATHER"}]},' +
        '     {"benefitId": "2", "benefitSumAssured": 50000, "benefitPremium": 25.30,' +
        '      "benefitRoleplayerArray": [' +
        '        {"benefitRoleplayerType": "Life Assured", "benefitRoleplayerFirstname": "Aunt",' +
        '         "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-17",' +
        '         "benefitRoleplayerGender": "F",' +
        '         "benefitRoleplayerRelationshipToOwner": "SPOUSE"}]}' +
        '   ]}}';

    /** Benefit id with no INS_MemberRelation__mdt mapping — should be skipped */
    private static final String BODY_UNMAPPED_BENEFIT =
        '{"saleReferenceId": "' + TEST_QUOTE_ID + '",' +
        ' "saleData": {"benefitArray": [' +
        '   {"benefitId": "999", "benefitSumAssured": 50000, "benefitPremium": 10.00,' +
        '    "benefitRoleplayerArray": [' +
        '      {"benefitRoleplayerType": "Life Assured", "benefitRoleplayerFirstname": "Salman",' +
        '       "benefitRoleplayerLastname": "Khan", "benefitRoleplayerDateOfBirth": "2000-08-01",' +
        '       "benefitRoleplayerRelationshipToOwner": "Main"}]}]}}';

    /** Roleplayer with no last name — memberId cannot be derived, so skipped */
    private static final String BODY_UNIDENTIFIABLE_ROLEPLAYER =
        '{"saleReferenceId": "' + TEST_QUOTE_ID + '",' +
        ' "saleData": {"benefitArray": [' +
        '   {"benefitId": "1", "benefitSumAssured": 50000, "benefitPremium": 10.00,' +
        '    "benefitRoleplayerArray": [' +
        '      {"benefitRoleplayerType": "Life Assured", "benefitRoleplayerFirstname": "NoSurname",' +
        '       "benefitRoleplayerRelationshipToOwner": "Main"}]}]}}';

    private static final String BODY_NO_SALE_DATA =
        '{"saleReferenceId": "' + TEST_QUOTE_ID + '"}';

    private static final String BODY_ERROR =
        '{"error": {"errorCode": 500, "errorDescription": "Quote service unavailable"}}';

    private static final String BODY_NOT_JSON = 'not json <<<';

    /**
     * @description Configurable mock for the quote details callout.
     */
    private class QuoteDetailsMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        QuoteDetailsMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(this.statusCode);
            res.setBody(this.body);
            return res;
        }
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static void registerMock(Integer statusCode, String body) {
        INS_API_QuoteDetails.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new QuoteDetailsMock(statusCode, body));
    }

    private static Map<String, Object> invokeAction(String quoteId) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteDetails().call(ACTION_GET_QUICK_QUOTE,
            new Map<String, Object>{
                'input'  => new Map<String, Object>{ KEY_QUOTE_ID => quoteId },
                'output' => output
            });
        return output;
    }

    @SuppressWarnings('PMD.UnusedLocalVariable')
    private static Map<String, Object> findMember(Map<String, Object> output, String memberId) {
        for (Object memberObj : (List<Object>) output.get('members')) {
            Map<String, Object> member = (Map<String, Object>) memberObj;
            if (memberId == member.get('memberId')) {
                return member;
            }
        }
        return null;
    }

    // =========================================================================
    // SUCCESS — MEMBERS
    // =========================================================================

    @IsTest
    static void getQuickQuote_success_groupsMembersByRoleplayer() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        Assert.areEqual(false, output.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(TEST_QUOTE_ID, output.get('saleReferenceId'),
            'saleReferenceId should be mapped');
        Assert.areEqual('Inactive', output.get('policyStatus'), 'policyStatus should be mapped');

        List<Object> members = (List<Object>) output.get('members');
        Assert.areEqual(2, members.size(),
            'Benefits should be grouped into one record per roleplayer');

        Map<String, Object> mainMember = findMember(output, 'Salman-Khan-20000801');
        Assert.isNotNull(mainMember, 'The main member should be present');
        Assert.areEqual('Myself', mainMember.get('RelationshipToInsured'),
            'The API relationship Main should be translated to Myself');
        Assert.areEqual('Salman Khan', mainMember.get('fullName'), 'fullName should be built');
        Assert.areEqual(2, ((List<Object>) mainMember.get('benefits')).size(),
            'Both of the main member benefits should be attached');
        Assert.areEqual(true, mainMember.get('Add_additional_benefits__c'),
            'More than one benefit means additional benefits are enabled');
        Assert.areEqual(550000, mainMember.get('Cover__c'), 'Cover should sum the benefits');
        Assert.areEqual(531.76, mainMember.get('Monthly_Premium__c'),
            'Monthly premium should sum the benefits');
    }

    @IsTest
    static void getQuickQuote_success_mapsBenefitsFromMetadata() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        Map<String, Object> mainMember = findMember(output, 'Salman-Khan-20000801');
        Map<String, Object> funeral =
            (Map<String, Object>) ((List<Object>) mainMember.get('benefits'))[0];

        Assert.areEqual('1', funeral.get('id'), 'Benefit id should be carried through');
        Assert.isNotNull(funeral.get('type'), 'Benefit type should come from the metadata mapping');
        Assert.isNotNull(funeral.get('name'), 'Benefit name should come from the metadata mapping');
        Assert.areEqual(500000, funeral.get('amount'), 'Sum assured should be mapped to amount');
        Assert.areEqual(496.25, funeral.get('monthlyPremium'), 'Premium should be mapped');
    }

    @IsTest
    static void getQuickQuote_success_totalsAcrossMembers() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        Assert.areEqual(600000, output.get('membersTotalAmount'),
            'Totals should sum across every member');
        Assert.areEqual(557.06, output.get('membersTotalMonthlyAmount'),
            'Monthly totals should sum across every member');
    }

    // =========================================================================
    // SUCCESS — BENEFICIARIES
    // =========================================================================

    @IsTest
    static void getQuickQuote_success_deduplicatesBeneficiaries() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        List<Object> beneficiaries = (List<Object>) output.get('beneficiaries');
        Assert.areEqual(1, beneficiaries.size(),
            'A beneficiary repeated across benefits should appear once');

        Map<String, Object> beneficiary = (Map<String, Object>) beneficiaries[0];
        Assert.areEqual('Father', beneficiary.get('FirstName__c'), 'First name should be mapped');
        Assert.areEqual('Father Khan', beneficiary.get('fullName'), 'fullName should be built');
        Assert.areEqual('FATHER', beneficiary.get('RelationshipToInsured'),
            'Beneficiary relationship should be carried through unchanged');
        Assert.areEqual(100, beneficiary.get('Allocation__c'),
            'The percentage should be mapped to allocation');
        Assert.areEqual(1, beneficiary.get('key'), 'A positional key should be assigned');
    }

    // =========================================================================
    // TOLERANCE — UNMAPPED AND UNIDENTIFIABLE DATA
    // =========================================================================

    @IsTest
    static void getQuickQuote_unmappedBenefitId_skipsBenefit() {
        registerMock(200, BODY_UNMAPPED_BENEFIT);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        Assert.areEqual(false, output.get(KEY_HAS_ERROR),
            'An unmapped benefit should not fail the whole retrieval');

        List<Object> members = (List<Object>) output.get('members');
        Assert.areEqual(1, members.size(), 'The member should still be created');

        Map<String, Object> member = (Map<String, Object>) members[0];
        Assert.areEqual(0, ((List<Object>) member.get('benefits')).size(),
            'The unmapped benefit should be skipped');
    }

    @IsTest
    static void getQuickQuote_roleplayerWithoutLastName_skipped() {
        registerMock(200, BODY_UNIDENTIFIABLE_ROLEPLAYER);

        Test.startTest();
        Map<String, Object> output = invokeAction(TEST_QUOTE_ID);
        Test.stopTest();

        Assert.areEqual(false, output.get(KEY_HAS_ERROR),
            'An unidentifiable roleplayer should not fail the retrieval');
        Assert.areEqual(0, ((List<Object>) output.get('members')).size(),
            'A roleplayer with no last name cannot be identified and is skipped');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void getQuickQuote_errorScenarios_returnError() {
        Map<String, List<Object>> scenarios = new Map<String, List<Object>>{
            'non-2xx status'       => new List<Object>{ 500, BODY_ERROR },
            'empty response body'  => new List<Object>{ 200, '' },
            'unparseable response' => new List<Object>{ 200, BODY_NOT_JSON },
            'missing saleData'     => new List<Object>{ 200, BODY_NO_SALE_DATA }
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            List<Object> params = scenarios.get(scenario);
            registerMock((Integer) params[0], (String) params[1]);

            Map<String, Object> output = invokeAction(TEST_QUOTE_ID);

            Assert.areEqual(true, output.get(KEY_HAS_ERROR),
                'hasError should be true for: ' + scenario);
            Assert.isNotNull(output.get('ErrorResponse'),
                'An error message should be present for: ' + scenario);
        }
        Test.stopTest();
    }

    @IsTest
    static void getQuickQuote_blankQuoteId_throws() {
        Boolean thrown = false;
        try {
            INS_CTRL_QuoteDetails.getQuickQuote('', new Map<String, Object>());
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'A blank quote id should throw AuraHandledException');
    }

    @IsTest
    static void getQuickQuote_nullOutput_createsOne() {
        registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output =
            (Map<String, Object>) INS_CTRL_QuoteDetails.getQuickQuote(TEST_QUOTE_ID, null);
        Test.stopTest();

        Assert.isNotNull(output, 'A null output map should be replaced rather than failing');
        Assert.areEqual(false, output.get(KEY_HAS_ERROR), 'The response should still populate');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Boolean unsupportedThrown = false;
        try {
            new INS_CTRL_QuoteDetails().call('wrongAction',
                new Map<String, Object>{
                    'input'  => new Map<String, Object>{ KEY_QUOTE_ID => TEST_QUOTE_ID },
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedThrown = true;
        }
        Assert.isTrue(unsupportedThrown, 'Unsupported action should throw');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_QuoteDetails().call(ACTION_GET_QUICK_QUOTE,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown, 'Missing input map should throw');

        Boolean missingOutputThrown = false;
        try {
            new INS_CTRL_QuoteDetails().call(ACTION_GET_QUICK_QUOTE,
                new Map<String, Object>{
                    'input' => new Map<String, Object>{ KEY_QUOTE_ID => TEST_QUOTE_ID } });
        } catch (AuraHandledException ex) {
            missingOutputThrown = true;
        }
        Assert.isTrue(missingOutputThrown, 'Missing output map should throw');
    }
}