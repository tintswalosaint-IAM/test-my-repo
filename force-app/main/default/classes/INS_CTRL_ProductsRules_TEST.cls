/**
 * @description             : Test class for INS_CTRL_ProductsRules
 * @story                   : SFP-51843
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date     : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_CTRL_ProductsRules_TEST {

    private static final String TEST_PRODUCT_CODE = '12';
    private static final String PRODUCT_CODE = 'Product_Code__c';


    // Two rules, one with two limits + one with one limit = 3 total flattened
    private static final String BODY_SUCCESS =
        '{"ProductBenefitRules": [' +
        '  {"benefitType": "MAINFUNERAL", "SumAssuredLimits": [' +
        '     {"minSumAssured": 50000, "maxSumAssured": 500000, "ageBand": "18-45"},' +
        '     {"minSumAssured": 50000, "maxSumAssured": 300000, "ageBand": "46-65"}]},' +
        '  {"benefitType": "SPOUSE", "SumAssuredLimits": [' +
        '     {"minSumAssured": 25000, "maxSumAssured": 250000, "ageBand": "18-65"}]}' +
        ']}';

    // ProductBenefitRules present but no SumAssuredLimits anywhere
    private static final String BODY_NO_LIMITS =
        '{"ProductBenefitRules": [{"benefitType": "MAINFUNERAL"}]}';

    // No ProductBenefitRules key at all
    private static final String BODY_NO_RULES = '{"someOtherKey": "value"}';

    private static final String BODY_NOT_JSON = 'not json <<<';

    /**
     * @description Configurable mock for the product rules callout
     */
    private class ProductRulesMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;
        public String capturedEndpoint;

        ProductRulesMock(Integer statusCode, String body) {
            this.statusCode = statusCode;
            this.body = body;
        }

        public HttpResponse respond(HTTPRequest req) {
            this.capturedEndpoint = req.getEndpoint();

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

    private static ProductRulesMock registerMock(Integer statusCode, String body) {
        INS_API_ProductsRules.testAccessToken = 'TEST_TOKEN_123';
        ProductRulesMock mock = new ProductRulesMock(statusCode, body);
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, mock);
        return mock;
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_ProductsRules().call('callProductsRulesAPI',
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    // =========================================================================
    // SUCCESS PATHS
    // =========================================================================

    @IsTest
    static void productRules_success_flattensAllLimits() {
        ProductRulesMock mock = registerMock(200, BODY_SUCCESS);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            new Map<String, Object>{ PRODUCT_CODE => TEST_PRODUCT_CODE });
        Test.stopTest();

        Assert.areEqual(200, output.get('statusCode'), 'statusCode should be mapped to output');

        List<Map<String, Object>> limits =
            (List<Map<String, Object>>) output.get('productRulesResponse');
        Assert.areEqual(3, limits.size(),
            'Limits from all benefit rules should be flattened into one list');
        Assert.areEqual('18-45', limits[0].get('ageBand'), 'First limit should be preserved in order');
        Assert.areEqual('18-65', limits[2].get('ageBand'), 'Limit from second rule should be included');

        Assert.isTrue(mock.capturedEndpoint.contains(TEST_PRODUCT_CODE),
            'Endpoint should contain the supplied product code');
    }

    @IsTest
    static void productRules_missingProductCode_usesDefault() {
        ProductRulesMock mock = registerMock(200, BODY_SUCCESS);

        Test.startTest();
        invokeAction(new Map<String, Object>());
        Test.stopTest();

        Assert.isTrue(mock.capturedEndpoint.contains('8'),
            'Blank product code should fall back to default code 8');
    }

    @IsTest
    static void productRules_noLimitsInResponse_returnsEmptyList() {
        registerMock(200, BODY_NO_LIMITS);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            new Map<String, Object>{ PRODUCT_CODE => TEST_PRODUCT_CODE });
        Test.stopTest();

        List<Map<String, Object>> limits =
            (List<Map<String, Object>>) output.get('productRulesResponse');
        Assert.areEqual(0, limits.size(), 'Missing SumAssuredLimits should yield empty list');
    }

    @IsTest
    static void productRules_noRulesKey_returnsEmptyList() {
        registerMock(200, BODY_NO_RULES);

        Test.startTest();
        Map<String, Object> output = invokeAction(
            new Map<String, Object>{ PRODUCT_CODE => TEST_PRODUCT_CODE });
        Test.stopTest();

        List<Map<String, Object>> limits =
            (List<Map<String, Object>>) output.get('productRulesResponse');
        Assert.areEqual(0, limits.size(), 'Absent ProductBenefitRules should yield empty list');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void productRules_emptyResponse_throws() {
        registerMock(500, '');

        Boolean thrown = false;
        Test.startTest();
        try {
            invokeAction(new Map<String, Object>{ PRODUCT_CODE => TEST_PRODUCT_CODE });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown, 'Empty response body should throw AuraHandledException');
    }

    @IsTest
    static void productRules_unparseableResponse_throws() {
        registerMock(200, BODY_NOT_JSON);

        Boolean thrown = false;
        Test.startTest();
        try {
            invokeAction(new Map<String, Object>{ PRODUCT_CODE => TEST_PRODUCT_CODE });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown, 'Unparseable response should throw AuraHandledException');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            invokeActionAsRaw('wrongAction');
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }

    @IsTest
    static void call_missingInputMap_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_ProductsRules().call('callProductsRulesAPI',
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Missing input map should throw AuraHandledException');
    }

    private static void invokeActionAsRaw(String action) {
        new INS_CTRL_ProductsRules().call(action,
            new Map<String, Object>{
                'input'  => new Map<String, Object>(),
                'output' => new Map<String, Object>() });
    }
}