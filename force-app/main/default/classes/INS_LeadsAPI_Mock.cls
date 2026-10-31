/**
 * @description Mock class for INS_Leads_API test coverage
 *              Matches real Dotsure/Dialler API response structure:
 *              - LeadGenerationResponse is an ARRAY
 *              - Each item has leadId, id/errorCode, message
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-10-29
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-17   Raja Arsalan    Initial Version
 * 2026-10-29   Raja Arsalan    Updated to match real API response structure
 **/
@isTest
public class INS_LeadsAPI_Mock extends CMN_API_HttpBaseOutboundMock {
    
    @TestVisible
    protected override void setResponse(HttpRequest request, HttpResponse response) {
        super.setResponse(request, response);
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);
        
        if (isTokenRequest(request)) {
            response.setBody(getTokenResponse());
            return;
        }
        
        Boolean isPut = request.getMethod().equalsIgnoreCase('PUT');
        
        switch on INS_Leads_API.mockScenario {
            when 'success' {
                response.setBody(getSuccessResponse(isPut));
            }
            when 'failure' {
                response.setBody(getFailureResponse(isPut));
            }
            when 'mixed' {
                response.setBody(getMixedResponse());
            }
            when 'globalError' {
                response.setBody(getGlobalErrorResponse());
            }
            when '502Error' {
                response.setStatusCode(502);
                response.setStatus('Bad Gateway');
                response.setBody(get502ErrorResponse());
            }
            when else {
                response.setBody(getSuccessResponse(isPut));
            }
        }
    }
    
    private Boolean isTokenRequest(HttpRequest request) {
        return request.getEndpoint().contains('/token.oauth2') 
            || request.getEndpoint().contains('CHNW_IAM_INS_LibertyOAuthE');
    }
    
    private String getTokenResponse() {
        return '{ "access_token": "mocked_access_token" }';
    }
    
    /**
     * @description Success response — real API structure
     *              POST: array with 1 item (leadId + id + message)
     *              PUT:  array with 1 item (leadId + id + message)
     **/
    private String getSuccessResponse(Boolean isPut) {
        if (isPut) {
            return '{' +
                '"LeadGenerationResponse": [' +
                    '{' +
                        '"leadId": "' + INS_Leads_API.testLeadId + '",' +
                        '"id": "mock-ref-id",' +
                        '"message": "Success"' +
                    '}' +
                ']' +
            '}';
        }
        
        return '{' +
            '"LeadGenerationResponse": [' +
                '{' +
                    '"leadId": "' + INS_Leads_API.testLeadId + '",' +
                    '"id": "mock-ref-id",' +
                    '"message": "Success"' +
                '}' +
            ']' +
        '}';
    }
    
    /**
     * @description Failure response — real API structure (DUPLICATE_LEAD)
     *              POST/PUT: array with 1 item (leadId + errorCode + message)
     **/
    private String getFailureResponse(Boolean isPut) {
        return '{' +
            '"LeadGenerationResponse": [' +
                '{' +
                    '"leadId": "' + INS_Leads_API.testLeadId + '",' +
                    '"errorCode": "400",' +
                    '"message": "Invalid Phone"' +
                '}' +
            ']' +
        '}';
    }
    
    /**
     * @description Mixed response — partial success (2 success, 1 failure)
     *              Used to test per-item handling
     **/
    private String getMixedResponse() {
        return '{' +
            '"LeadGenerationResponse": [' +
                '{' +
                    '"leadId": "lead-1",' +
                    '"id": "ref-1",' +
                    '"message": "Success"' +
                '},' +
                '{' +
                    '"leadId": "lead-2",' +
                    '"errorCode": "400",' +
                    '"message": "DUPLICATE_LEAD"' +
                '},' +
                '{' +
                    '"leadId": "lead-3",' +
                    '"id": "ref-3",' +
                    '"message": "Success"' +
                '}' +
            ']' +
        '}';
    }
    
    /**
     * @description Global error response (auth/system failure)
     *              No LeadGenerationResponse array
     **/
    private String getGlobalErrorResponse() {
        return '{' +
            '"error": {' +
                '"errorCode": "401",' +
                '"errorDescription": "{\\"error\\":{\\"errorMessage\\":\\"Provided credentials are invalid\\"}}"' +
            '}' +
        '}';
    }
    
    /**
     * @description 502 Bad Gateway response
     **/
    private String get502ErrorResponse() {
        return '{' +
            '"error": {' +
                '"errorCode": "502",' +
                '"errorDescription": "{\\"error\\":{\\"errorMessage\\":\\"Bad Gateway\\"}}"' +
            '}' +
        '}';
    }
}