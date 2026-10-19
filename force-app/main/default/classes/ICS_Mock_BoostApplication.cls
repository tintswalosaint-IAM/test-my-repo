@isTest
public class ICS_Mock_BoostApplication implements HttpCalloutMock {
	@testVisible
    public static String mockPayloadString = '{"IsSuccess":true,"BoostResponseStatusCode":202,"SessionId":null,"ApplicationReference":"SB656429741480P","ErrorMessage":null,"BoostResponseStatus":"OK"}';
	/**
     * @description This method is used to return a mock HTTP response when testing HTTP callouts.
     * @param req The HTTPRequest that is sent in the test method.
     * @return HttpResponse A mock HTTPResponse.
     */
    @testVisible
    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(mockPayloadString);
        res.setStatusCode(202);
        
        return res;
    }
}