/**
 * @description       : SFP-26913 Class to return mock responses
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
public with sharing class INS_Quote_Application_MockHttpResponse implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    /**
     * @description       : HttpCalloutMock class to create fake responses 
     * @param requests
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 11-09-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public INS_Quote_Application_MockHttpResponse(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    /**
     * @description       : HttpCalloutMock class to create fake responses 
     * @param req
     * @return            : HTTPResponse
     * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
     * @group             : Cloudsmiths
     * @last modified on  : 11-09-2023
     * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
     */
    public HTTPResponse respond(HTTPRequest req) {

       // List<String> splittedURL = new List<String>();
        HttpCalloutMock mock;
        mock = requests.get(req.getEndpoint());
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new CustomException('HTTP callout not supported for test methods');
        }
    }

/**
 * @description       : SFP-26913 Class to return custom exception if occurs
 * @author            : Areeba Khan (areeba.khan@standardbank.co.za)
 * @group             : Cloudsmiths
 * @last modified on  : 11-09-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
**/
    private class CustomException extends Exception {
    }
}