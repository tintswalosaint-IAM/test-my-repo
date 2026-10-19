/**
 * @description Mock class for Dotsure API test coverage
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-21
 **/
@isTest
public class INS_DotsureAPI_Mock extends CMN_API_HttpBaseOutboundMock {
    
    @TestVisible
    protected override void setResponse(HttpRequest request, HttpResponse response) {
        super.setResponse(request, response);
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        
        if (isTokenRequest(request)) {
            response.setBody(getTokenResponse());
            return;
        }
        
        switch on INS_DotsureService.mockScenario {
            when 'success' {
                response.setBody(getSuccessResponse());
            }
            when 'clientError' {
                response.setBody(getClientErrorResponse());
            }
            when 'serverError' {
                response.setStatusCode(502);
                response.setBody(getServerErrorResponse());
            }
            when else {
                response.setBody(getSuccessResponse());
            }
        }
    }
    
    private Boolean isTokenRequest(HttpRequest request) {
        return request.getEndpoint().contains('/token.oauth2') 
            || request.getEndpoint().contains('INS_InsuranceClaimsAccess');
    }
    
    private String getTokenResponse() {
        return '{ "access_token": "mocked_access_token" }';
    }
    
    /**
     * @description Success response (HTTP 200 with inner 201 + leadIds)
     **/
    private String getSuccessResponse() {
        return '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {' +
                '"message": "{\\"leadIds\\":[12345],\\"statusCode\\":201,\\"id\\":\\"' + 
                    INS_DotsureService.testLeadId + '\\",\\"message\\":\\"Lead created\\"}"' +
            '}}';
    }
    
    /**
     * @description Client error (business 400/401 inside HTTP 200)
     **/
    private String getClientErrorResponse() {
        return '{' +
            '"status_code": 400,' +
            '"status": "Duplicate lead",' +
            '"message": "Lead already exists in Dotsure"' +
            '}';
    }
    
    /**
     * @description Server error (HTTP 502)
     **/
    private String getServerErrorResponse() {
        return '{' +
            '"status_code": 502,' +
            '"message": "Bad Gateway - Dotsure service unavailable"' +
            '}';
    }
}