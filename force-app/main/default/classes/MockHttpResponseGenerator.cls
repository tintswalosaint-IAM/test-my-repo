/***************************************************************************************
@ Author            :krishna.ranjan@standardbank.co.za
@ Date              :28 November 2024
@ Name of the Class :MockHttpResponseGenerator
@description       : Mock HTTP response generator for tests
@ Last Modified By  :krishna.ranjan@standardbank.co.za
@ Last Modified On  :28-11-2024
@ Jira Ticket       :SFP-42419
***************************************************************************************/
@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    private final Integer statusCode;
    private final String status;
    private final String body;
    
    public MockHttpResponseGenerator(Integer statusCode, String status, String body) {
        this.statusCode = statusCode;
        this.status = status;
        this.body = body;
    }
    
    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        response.setStatus(status);
        response.setBody(body);
        return response;
    }
}