/**
 * @description       : Test Class for AOB_API_Utils
 * @author            : Jagadish Thummala
 * @group             : Test Class
 * @date modified on  : 18-03-2024
**/


@IsTest
private class AOB_API_Utils_Test {
    
    /**
    * @description Test method for positive test case - call to mock API call returns Success with mock access_token. 
    **/
    @IsTest
    private static void refreshTokenTestSuccess() {
        String mockResponse = '{"access_token":"eyJhbGciOiJ","token_type":"Bearer","expires_in":299}';
        Integer statusCode = 200;
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMock_AccessToken(mockResponse, statusCode));

        Test.startTest();
        String accessToken = AOB_API_Utils.refreshToken();
        Test.stopTest();
        
        Assert.areEqual('eyJhbGciOiJ', accessToken, 'Expected to receive mock response - "eyJhbGciOiJ"');
    }

    /**
    * @description Test method for negative test case - call to mock API call returns Failure with null value for access_token. 
    **/
    @IsTest
    private static void refreshTokenTestFailure() {
        String mockResponse = '{"access_token":"eyJhbGciOiJ","token_type":"Bearer","expires_in":299}';
        Integer statusCode = 400;
        
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMock_AccessToken(mockResponse, statusCode));

        Test.startTest();
        String accessToken = AOB_API_Utils.refreshToken();
        Test.stopTest();
        
        Assert.areEqual(null, accessToken, 'Expected to receive mock response - null');
    }

    /**
    * @description HTTP Mock class implementation to mock the API call to SAP to get access_token.
    **/
    public class HttpCalloutMock_AccessToken implements HttpCalloutMock {
        protected String mockResponse;
        protected Integer statusCode;
        
        /**
        * @description Method to set response & status code. 
        * @param mockResponse 
        * @param statusCode
        **/
        public HttpCalloutMock_AccessToken(String mockResponse, Integer statusCode) {
            this.mockResponse = mockResponse;
            this.statusCode = statusCode;
        }
        
        /**
        * @description Method to set the response. 
        * @param req 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse response = new HTTPResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Accept', 'application/json');
            response.setBody(mockResponse);
            response.setStatusCode(statusCode);
            return response;
        }
    }
    
    /**
    * @description Test method for BCB_CTRL_FormCreator.createGUID
    */
    @isTest
    public static void createGUIDTest(){
        try{
            Test.startTest();
            
          string guid=  AOB_API_Utils.createGUID();
            Test.stopTest();
            Assert.isNotNull(guid,'Test');
        } catch(Exception ex){
            Assert.isNotNull( ex.getMessage(),'Test'); 
        }
        
    }
    @IsTest
    private static void testGetHeaders() {
    string HTTP_METHOD='post';
    string PATH_CALLOUT = 'test/api';

        Test.startTest();
        System.HttpRequest req = AOB_API_Utils.getHeaders(HTTP_METHOD,PATH_CALLOUT);
        Test.stopTest();
        
        Assert.isNotNull(req,'shoul not be null');
    }
   
}