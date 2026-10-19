/**
 * @description : Dedicated HttpCalloutMock for Unit Tests
 */
@isTest
public class INS_Lead_API_Mock extends CMN_API_HttpBaseOutboundMock {

    public static String mockScenario = 'success';
    public static String testLeadId;

    protected override void setResponse(HttpRequest request, HttpResponse response) {
        super.setResponse(request, response);
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(200);

        if (request.getEndpoint().contains('/token.oauth2')) {
            response.setBody('{"access_token": "mocked_access_token"}');
            return;
        }

        Boolean isPut = request.getMethod().equalsIgnoreCase('PUT');

        if ('success'.equalsIgnoreCase(mockScenario)) {
            response.setBody(isPut ?
                '{"LeadGenerationResponse":{"id":"mock-id","message":"' + testLeadId + '"}}' :
                '{"status_code":200,"LeadGenerationResponse":{"message":"[{\\"index\\":0,\\"success\\":true,\\"contact_data_id\\":\\"mock-ref\\",\\"source_reference\\":\\"' + testLeadId + '\\",\\"errors\\":[]}]"}}'
            );
        } else {
            response.setStatusCode(400);
            response.setBody('{"status_code":400,"message":"Bad Request"}');
        }
    }
}