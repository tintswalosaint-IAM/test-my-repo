/**
 * @description  test class for CMN_Generate_Token_Helper
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @date  Feb 19th 2024
 */
@isTest
public class CMN_Generate_Token_Helper_Test {
    /**
 * @description  test method for testGetAccessToken
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date  Feb 19th 2024
 */
    @isTest
    static void testGetAccessToken() {
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForAccessToken());
        // Call the getAccessToken method
        Test.startTest();
        Final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
        Test.stopTest();
		Assert.areEqual('pingAccessToken111', accessTokenPing, 'Access token should be pingAccessToken111');
        
    }
    
    /**
 * @description  test method for testGetAccessToken error scenario
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date  Feb 19th 2024
 */
    @isTest
    static void testGetAccessTokenError() {
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpForAccessTokenError());
        // Call the getAccessToken method
        Test.startTest();
        Final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
        Test.stopTest();
		Assert.areEqual(null, accessTokenPing, 'Access token is null');
        
    }
    /**
 * @description  test method for testGetAccessToken catch block
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param 
 * @return 
 * @date  March 15th 2024
 */
    @isTest
    static void testGetAccessTokenCatch() {
        // Set mock callout response
        Test.setMock(HttpCalloutMock.class, new MockHttpAccessTokenCatch());

        // Call the getAccessToken method
        Test.startTest();
        Final String accessTokenPing = CMN_Generate_Token_Helper.getAccessToken();
 		Assert.areEqual(null, accessTokenPing, 'Access token should be null');        
        Test.stopTest();
    }
    

    /**
     * @description    : Mock Test Class for CMN_Generate_Token_Helper_Test Access Token, generating fake responses
     * @author         : Khaliq Abdul
     **/
    public class MockHttpResponseGeneratorForAccessToken implements HttpCalloutMock {

        /**
          * @description    : generating fake responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
         public HTTPResponse respond(HTTPRequest request) {
             // Create a mock HTTP response for getAccessToken callout
             Final HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"access_token": "pingAccessToken111"}'); // Mock access token response
             response.setStatusCode(200);
             return response;
         }
     } 
    
    /**
     * @description    : Mock Test Class for CMN_Generate_Token_Helper_Test Access Token, generating fake responses for error scenario
     * @author         : Khaliq Abdul
     **/
    public class MockHttpForAccessTokenError implements HttpCalloutMock {

        /**
          * @description    : generating fake responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
         public HTTPResponse respond(HTTPRequest request) {
             // Create a mock HTTP response for getAccessToken callout
             Final HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"access_token": null}'); // Mock access token response
             response.setStatusCode(400);
             return response;
         }
     } 
    /**
     * @description    : Mock Test Class for CMN_Generate_Token_Helper_Test Access Token, generating fake responses for catch scenario
     * @author         : Khaliq Abdul
     **/
    public class MockHttpAccessTokenCatch implements HttpCalloutMock {

        /**
          * @description    : generating fake responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
         public HTTPResponse respond(HTTPRequest request) {
             // Create a mock HTTP response for getAccessToken callout
             Final HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setBody('{"access_token": null}'); // Mock access token response
             response.setStatusCode(200);
             return response;
         }
     } 
    
    
}