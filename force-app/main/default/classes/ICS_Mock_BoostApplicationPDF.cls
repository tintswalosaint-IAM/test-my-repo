@isTest
public class ICS_Mock_BoostApplicationPDF implements HttpCalloutMock {
    /**
     * @description This method is used to return a mock HTTP response when testing HTTP callouts.
     * @param req The HTTPRequest that is sent in the test method.
     * @return HttpResponse A mock HTTPResponse.
     */
    @testVisible
    public HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint and method.
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"statusCode":200}');
        res.setStatusCode(200);
        return res;
    }
}