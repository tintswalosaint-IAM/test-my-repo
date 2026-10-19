/***************************************************************************************
 * @description             : Test class for INS_SRV_QuickQuoteBenefits
 * @story                   : SFP-51843
 * @author                  : Preetham
 * @created date            : 2026-06-11
 * @last modified date      :
 * @last modified by        :
 * @modification details    :
 ***************************************************************************************/
@IsTest
private class INS_SRV_QuickQuoteBenefits_TEST {

    private static final String MOCK_QUOTE_ID = 'a0Q000000000001AAA';
    private static final String MOCK_JSON_BODY = '{"quoteId":"a0Q000000000001AAA","benefits":[{"code":"DEATH","sumAssured":1000000}]}';
    private static final String EXPECTED_RESPONSE = '{"documentStatus":"Success","documentStatusMessage":"Uploaded OK"}';

    @TestSetup
    static void setup() {
        // No SObject records required — service is invoked directly with a JSON body and quoteId.
        // Common data is established via static constants above.
    }

    // ─────────────────────────────────────────────────────────────
    // getBody
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void getBodyPositiveOutcome() {
        Test.startTest();
            // Arrange
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);

            // Act
            String body = service.getBody();
        Test.stopTest();

        // Assert
        Assert.areEqual(MOCK_JSON_BODY, body, 'getBody() should return the JSON body passed into the constructor.');
    }

    @IsTest
    static void getBodyNegativeOutcome() {
        Test.startTest();
            // Arrange — null body passed in to simulate missing payload
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(null, MOCK_QUOTE_ID);

            // Act
            String body = service.getBody();
        Test.stopTest();

        // Assert — body should be null/blank; service must not throw
        Assert.isTrue(String.isBlank(body), 'getBody() should return null/blank when no JSON body is supplied.');
    }

    // ─────────────────────────────────────────────────────────────
    // getVerb
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void getVerbPositiveOutcome() {
        Test.startTest();
            // Arrange
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);

            // Act
            String verb = service.getVerb();
        Test.stopTest();

        // Assert
        Assert.areEqual('PUT', verb, 'HTTP verb should be PUT for the Quick Quote Benefits service.');
    }

    // ─────────────────────────────────────────────────────────────
    // triggeringObjectRequired
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void triggeringObjectRequiredPositiveOutcome() {
        Test.startTest();
            // Arrange
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);

            // Act
            Boolean required = service.triggeringObjectRequired();
        Test.stopTest();

        // Assert
        Assert.isFalse(required, 'triggeringObjectRequired() must return false — the service does not need a triggering SObject Id.');
    }

    // ─────────────────────────────────────────────────────────────
    // getWebServiceEndPoint
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void getWebServiceEndPointPositiveOutcome() {
        Test.startTest();
            // Arrange
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);

            // Act
            String endpoint = service.getWebServiceEndPoint();
        Test.stopTest();

        // Assert — when settings is null the endpoint should be null (no NPE)
        Assert.isNull(endpoint, 'Endpoint should be null when CMN_WebserviceSetting__mdt is not configured in this context.');
    }

    // ─────────────────────────────────────────────────────────────
    // Mock callout — full HTTP round-trip via injectedMock
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void calloutWithMockPositiveOutcome() {
        // Arrange — inject the inner mock so the framework picks it up during Test.startTest()
        INS_SRV_QuickQuoteBenefits.injectedMock = new INS_SRV_QuickQuoteBenefits.QuickQuoteBenefitsMock();

        Test.startTest();
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);
        Test.stopTest();

        // Assert — the mock response body must be what the inner mock defines
        Assert.areEqual(
            EXPECTED_RESPONSE,
            service.getResponseBody(),
            'Response body returned from the mock callout should match the QuickQuoteBenefitsMock valid response.'
        );
    }

    @IsTest
    static void calloutWithMockNegativeOutcome() {
        // Arrange — inject a mock that returns an error status
        INS_SRV_QuickQuoteBenefits.injectedMock = new QuickQuoteBenefitsErrorMock();

        Test.startTest();
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);
        Test.stopTest();

        // Assert — the service should not throw; the response body should reflect the error payload
        Assert.isNotNull(
            service.getResponseBody(),
            'Service should gracefully capture error responses without throwing an unhandled exception.'
        );
        Assert.isTrue(
            service.getResponseBody().contains('Error'),
            'Error mock response body should contain an error indicator.'
        );
    }

    // ─────────────────────────────────────────────────────────────
    // setHeaders — exercised implicitly via process(); validated
    // through successful round-trip in the mock callout tests above.
    // Dedicated coverage for header-specific logic below.
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void setHeadersPositiveOutcome() {
        INS_SRV_QuickQuoteBenefits.injectedMock = new INS_SRV_QuickQuoteBenefits.QuickQuoteBenefitsMock();

        Test.startTest();
            // Arrange & Act — process() calls setHeaders() internally
            INS_SRV_QuickQuoteBenefits service = new INS_SRV_QuickQuoteBenefits(MOCK_JSON_BODY, MOCK_QUOTE_ID);
           
        Test.stopTest();

        // Assert — if setHeaders threw an exception, process() would have propagated it
        Assert.isNotNull(service.getResponseBody(), 'Headers were set without error and a response was received.');
    }

    // ─────────────────────────────────────────────────────────────
    // DTO_Response
    // ─────────────────────────────────────────────────────────────

    @IsTest
    static void dtoResponseGetObjectTypePositiveOutcome() {
        Test.startTest();
            // Arrange & Act
            INS_SRV_QuickQuoteBenefits.DTO_Response dto = new INS_SRV_QuickQuoteBenefits.DTO_Response();
            Type objectType = dto.getObjectType();
        Test.stopTest();

        // Assert
        Assert.areEqual(
            INS_SRV_QuickQuoteBenefits.DTO_Response.class,
            objectType,
            'getObjectType() must return DTO_Response.class for correct deserialization.'
        );
    }

    // ─────────────────────────────────────────────────────────────
    // Private helper — error mock
    // ─────────────────────────────────────────────────────────────

    private class QuickQuoteBenefitsErrorMock extends CMN_API_HttpBaseOutboundMock {
        protected override void setResponse(HttpRequest request, HttpResponse response) {
            super.setResponse(request, response);
            response.setStatusCode(500);
            response.setBody('{"documentStatus":"Error","documentStatusMessage":"Internal Server Error"}');
        }
    }
}