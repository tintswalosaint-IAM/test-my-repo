/**
 * @description Mock class for INS_Leads_API test coverage
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-17
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
            when 'Queuefailure' {
                response.setBody(getQueueFailureResponse());
            }
            when 'ServerError' {
                response.setBody(getServerErrorResponse());
            }
            when '502Error' {
                response.setStatusCode(502);
                response.setStatus('Bad Gateway');
                response.setBody(get502ErrorResponse());
            }
            when else {
                response.setBody('{"status_code":500,"message":"Unknown mock scenario"}');
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
    
    private String getSuccessResponse(Boolean isPut) {
    if (isPut) {
        // LeadGenerationResponse must be an array — parsePutResponse loops over it.
        // No errorCode = success. id = the Dialler reference that gets written back.
        return '{'
            + '"LeadGenerationResponse": ['
            +   '{'
            +     '"id": "mock-ref-id",'
            +     '"message": "Lead updated successfully",'
            +     '"errorCode": ""'
            +   '}'
            + ']'
            + '}';
    }
    return '{ "status_code": 200, "LeadGenerationResponse": { "message": "[{'
        + '\\\"index\\\":0,'
        + '\\\"success\\\":true,'
        + '\\\"contact_data_id\\\":\\\"mock-ref-id\\\",'
        + '\\\"source_reference\\\":\\\"' + INS_Leads_API.testLeadId + '\\\",'
        + '\\\"errors\\\":[]}]"} }';
}

private String getFailureResponse(Boolean isPut) {
    if (isPut) {
        // Non-blank errorCode = failure. parsePutResponse sets Dialer_Failure_Reason__c.
        return '{'
            + '"LeadGenerationResponse": ['
            +   '{'
            +     '"id": "mock-ref-id",'
            +     '"message": "Lead not found",'
            +     '"errorCode": "PUT_FAILED"'
            +   '}'
            + ']'
            + '}';
    }
    return '{ "status_code": 200, "LeadGenerationResponse": { "message": "[{'
        + '\\\"index\\\":0,'
        + '\\\"success\\\":false,'
        + '\\\"contact_data_id\\\":null,'
        + '\\\"source_reference\\\":\\\"' + INS_Leads_API.testLeadId + '\\\",'
        + '\\\"errors\\\":[{\\\"message\\\":\\\"Invalid phone\\\"}]}]" } }';
}

    private String getQueueFailureResponse() {
        return '{ "status_code": 200, "LeadGenerationResponse": { "message": "[{' +
            '\\\"index\\\":0,' +
            '\\\"success\\\":false,' +
            '\\\"contact_data_id\\\":null,' +
            '\\\"source_reference\\\":\\\"' + INS_Leads_API.testLeadId + '\\\",' +
            '\\\"errors\\\":[{\\\"message\\\":\\\"Invalid Queue\\\"}]}]" } }';
    }
    
    private String get502ErrorResponse() {
        return '{"error":{"errorCode":"502","errorDescription":"{\\"error\\":{\\"errorCode\\":\\"502\\",\\"errorDescription\\":\\" "}}"}}';
    }
    
    private String getServerErrorResponse() {
        return '{ "status_code": 400, "status": "required", "message": "Something went wrong" }';
    }
}