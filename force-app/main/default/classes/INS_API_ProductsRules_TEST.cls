/**
 * @description             : Test class for INS_API_ProductsRules
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@isTest
private class INS_API_ProductsRules_TEST {

    private static final String TEST_PRODUCT_CODE = '12';
    private static final String MOCK_SUCCESS_BODY =
        '{"ProductBenefitRules": [{"benefitType": "MAINFUNERAL", "SumAssuredLimits": [' +
        '{"minSumAssured": 50000, "maxSumAssured": 500000, "ageBand": "18-45"}]}]}';
    private static final String MOCK_ERROR_BODY =
        '{"error": "Internal Server Error", "message": "Rules service unavailable"}';

    /**
     * @description Configurable mock for the product rules callout
     */
    private class ProductRulesMock implements HttpCalloutMock {
        private final Integer statusCode;
        private final String body;

        ProductRulesMock(Integer statusCode, String body) {
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

    @isTest
    static void getProductRules_success() {
        INS_API_ProductsRules.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new ProductRulesMock(200, MOCK_SUCCESS_BODY));

        Test.startTest();
        String result = new INS_API_ProductsRules().getProductRules(TEST_PRODUCT_CODE);
        Test.stopTest();

        Assert.isNotNull(result, 'Response should not be null');
        Assert.isTrue(result.contains('ProductBenefitRules'), 'Response should contain rules');
        Assert.isTrue(result.contains('MAINFUNERAL'), 'Response should contain the benefit type');
    }

    @isTest
    static void getProductRules_error() {
        INS_API_ProductsRules.testAccessToken = 'TEST_TOKEN_123';
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,
            new ProductRulesMock(500, MOCK_ERROR_BODY));

        Boolean exceptionThrown = false;
        String exceptionMessage;

        Test.startTest();
        try {
            new INS_API_ProductsRules().getProductRules(TEST_PRODUCT_CODE);
        } catch (sbgplatform.ApiService.ServiceException ex) {
            exceptionThrown = true;
            exceptionMessage = ex.getMessage();
        }
        Test.stopTest();

        Assert.isTrue(exceptionThrown, 'Expected ServiceException for HTTP 500 response');
        Assert.isTrue(String.isNotBlank(exceptionMessage), 'Exception message should be populated');
    }
}