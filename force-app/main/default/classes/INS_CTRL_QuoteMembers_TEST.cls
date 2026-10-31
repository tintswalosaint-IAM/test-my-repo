/**
 * @description             : Test class for INS_CTRL_QuoteMembers
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_CTRL_QuoteMembers_TEST {

    private static final String TEST_QUOTE_ID = 'fb79d641-5a9c-4a72-b03f-46589af93a33';
    private static final String HASERROR     = 'hasError';
    private static final String BENEFITS      = 'benefits';

    private static final String BODY_MEMBER_SUCCESS =
        '{"ValidationResult": {"ResultStatus": "Success"},' +
        ' "members": [{"memberId": "mem-002", "firstName": "Njeri"}]}';

    private static final String BODY_MEMBER_VALIDATION_FAILED =
        '{"ValidationResult": {"ResultStatus": "Failed", "Message": "Member age exceeds limit"}}';

    private static final String BODY_MEMBER_NO_VALIDATION = '{"members": []}';

    private static final String BODY_CALC_SUCCESS =
        '{"benefits": [{"benefitKey": "2.SPOUSE", "premium": 120.75}],' +
        ' "members": [{"memberId": "mem-002"}]}';

    private static final String BODY_ERROR = '{"error": "boom"}';

    private static final String BODY_NOT_JSON = 'not json <<<';
    private static final String QUOTE_REFERENCE = 'fb79d641-5a9c-4a72-b03f-46589af93a33';

    /**
     * @description Configurable mock capturing method, endpoint and body.
     */
    private class MembersMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;
        public String capturedMethod;
        public String capturedEndpoint;
        public String capturedRequestBody;

        MembersMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedMethod = req.getMethod();
            this.capturedEndpoint = req.getEndpoint();
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

    private static MembersMock registerMembersMock(Integer statusCode, String body) {
        MembersMock mock = new MembersMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static MembersMock registerPremiumsMock(Integer statusCode, String body) {
        
        MembersMock mock = new MembersMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static MembersMock registerBenefitsMock(Integer statusCode, String body) {
        INS_API_QuoteBenefits.testAccessToken = 'TEST_TOKEN_123';
        MembersMock mock = new MembersMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static Map<String, Object> buildMemberInput() {
        return new Map<String, Object>{
            'prospectAccountId'    => String.valueOf(getTestAccountId()),
            'firstName'            => 'Njeri',
            'surname'              => 'Otieno',
            'relationship'         => 'DAUGHTER',
            'memberType'           => 'DEPENDANT',
            'memberId'             => 'mem-002',
            'idNumber'             => '11223344',
            'identityDocumentType' => 'SAIDENTITYDOCUMENT',
            'gender'               => 'Female',
            'dateOfBirth'          => '2010-03-01',
            'bpid'                 => 'bp-001',
            BENEFITS             => new List<Object>{
                new Map<String, Object>{
                    'benefitKey'         => '2.SPOUSE',
                    'benefitType'        => 'SPOUSEFUNERAL',
                    'benefitId'          => '2',
                    'benefitAmountValue' => 100000,
                    'prefix'             => 'KES'
                },
                // Zero-amount benefit - must be skipped by mapBenefits
                new Map<String, Object>{
                    'benefitKey' => '3.CHILD',
                    'benefitType' => 'CHILDFUNERAL',
                    'amount' => 0
                }
            }
        };
    }

    private static Map<String, Object> parseResult(String jsonResult) {
        return (Map<String, Object>) JSON.deserializeUntyped(jsonResult);
    }
    
        

    @TestSetup
    static void setup() {
        Pricebook2 customPricebook = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert customPricebook;

        Account acc = new Account(Name = 'Quote Members Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId    = acc.Id,
            Name         = 'Quote Members Test Opportunity',
            StageName    = 'Quoting',
            CloseDate    = Date.today(),
            Pricebook2Id = customPricebook.Id
        );
        insert opp;

        insert new Quote(
            OpportunityId                      = opp.Id,
            Name                               = 'Quote Members Test Quote',
            Status                             = 'Quote In-Progress',
            ExpirationDate                     = Date.today().addDays(30),
            UnderwriterQuoteReferenceNumber__c = QUOTE_REFERENCE
        );
    }

    private static Id getTestAccountId() {
        return [SELECT Id FROM Account WHERE Name = 'Quote Members Test Account' LIMIT 1].Id;
    }

    // =========================================================================
    // ADD MEMBER
    // =========================================================================

    @IsTest
    static void addMember_success() {
        MembersMock mock = registerMembersMock(200, BODY_MEMBER_SUCCESS);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.addMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);        
        Assert.isNotNull(parsed.get('members'), 'members should be passed through');

        // Outbound payload checks
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        Assert.areEqual(TEST_QUOTE_ID, payload.get('referenceNumber'),
            'referenceNumber should be quoteId');
        List<Object> members = (List<Object>) payload.get('members');
        Map<String, Object> sentMember = (Map<String, Object>) members[0];
        Assert.areEqual('Njeri', sentMember.get('firstName'), 'Member fields should map');

        List<Object> sentBenefits = (List<Object>) sentMember.get(BENEFITS);
        Assert.areEqual(1, sentBenefits.size(),
            'Zero-amount benefit should be skipped by mapBenefits');
        Map<String, Object> sentBenefit = (Map<String, Object>) sentBenefits[0];
        Assert.areEqual('2', sentBenefit.get('benefitId'),
            'benefitId should be included when includeMember = true');
        Assert.areEqual('NORMALPREMIUM', sentBenefit.get('premiumType'),
            'Default premiumType should be applied');
        Assert.areEqual('MONTHLY', sentBenefit.get('benefitFrequencyValue'),
            'Missing frequency should default to MONTHLY');
    }

    @IsTest
    static void addMember_validationFailed() {
        registerMembersMock(200, BODY_MEMBER_VALIDATION_FAILED);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.addMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        
        Assert.areEqual('Member age exceeds limit', parsed.get('error'),
            'Validation message should be surfaced');
    }

    @IsTest
    static void addMember_missingValidationResult_isError() {
        registerMembersMock(200, BODY_MEMBER_NO_VALIDATION);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.addMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        Assert.areEqual(true, parsed.get(HASERROR),
            'Missing ValidationResult should be treated as error');
    }

    @IsTest
    static void addMember_non2xx_surfacesStatus() {
        registerMembersMock(500, BODY_ERROR);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.addMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        Assert.areEqual(true, parsed.get(HASERROR), 'hasError should be true');
       
    }

    @IsTest
    static void addMember_unparseableResponse_isError() {
        registerMembersMock(200, BODY_NOT_JSON);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.addMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        Assert.areEqual(true, parsed.get(HASERROR), 'hasError should be true');
        Assert.isTrue(String.valueOf(parsed.get('error')).startsWith('Failed to parse'),
            'Parse failure should be surfaced');
    }

    // =========================================================================
    // EDIT MEMBER
    // =========================================================================

    @IsTest
    static void editMember_success() {
        registerMembersMock(200, BODY_MEMBER_SUCCESS);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.editMember(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        Assert.areEqual(false, parsed.get(HASERROR), 'hasError should be false');
    }

    // =========================================================================
    // CALCULATE BENEFITS
    // =========================================================================

    @IsTest
    static void calculateBenefits_success() {
        MembersMock mock = registerPremiumsMock(200, BODY_CALC_SUCCESS);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.calculateBenefits(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Map<String, Object> parsed = parseResult(result);
        Assert.areEqual(false, parsed.get(HASERROR), 'hasError should be false');
        Assert.isNotNull(parsed.get(BENEFITS), 'benefits should be passed through');
        Assert.isNotNull(parsed.get('members'), 'members should be passed through');

        // Calc payload maps only the minimal member fields, no benefitId/premiumType
        Map<String, Object> payload =
            (Map<String, Object>) JSON.deserializeUntyped(mock.capturedRequestBody);
        List<Object> sentBenefits = (List<Object>) payload.get(BENEFITS);
        Map<String, Object> sentBenefit = (Map<String, Object>) sentBenefits[0];
        Assert.isFalse(sentBenefit.containsKey('premiumType'),
            'premiumType should be omitted when includeMember = false (nulls suppressed)');
    }

    @IsTest
    static void calculateBenefits_non2xx_surfacesStatus() {
        registerPremiumsMock(500, BODY_ERROR);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.calculateBenefits(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Assert.areEqual(true, parseResult(result).get(HASERROR), 'hasError should be true');
    }

    // =========================================================================
    // EDIT MAIN MEMBER BENEFITS
    // =========================================================================

    @IsTest
    static void editMainMemberBenefits_success() {
        MembersMock mock = registerBenefitsMock(200, BODY_CALC_SUCCESS);

        Test.startTest();
        String result = INS_CTRL_QuoteMembers.editMainMemberBenefits(TEST_QUOTE_ID, buildMemberInput());
        Test.stopTest();

        Assert.areEqual(false, parseResult(result).get(HASERROR), 'hasError should be false');
       
        Assert.isTrue(mock.capturedEndpoint.contains(TEST_QUOTE_ID),
            'Endpoint should contain the quoteId - fails while putQuoteBenefits args are swapped');
        
    }
}