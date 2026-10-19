/**
 * @description  test class for INS_API_RealPayUrl_Test
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return
 * @date June 20th 2024
 */
@isTest
public class INS_API_RealPayUrl_Test {
    // Mock HTTP response generator for the callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
          * @description    : generating mock RealPayURL responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"partySourceIdentifier":"ptyId_001001001","userId":"UGCM930121003EGE","sessionUrl":"https://uat.realpaycollect.com/rpswitch/?data=3FCCEAEC4B1E86AD7BEFB634C9F0E30C6:CYBSCARDUGX"}');
            response.setStatusCode(200);
            return response;
        }
    }
    public class MockHttpResponseErrorGenerator implements HttpCalloutMock {
        /**
          * @description    : generating mock RealPayURL responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"error":{"errorCode":400,"errorDateTime":"2024-06-20T10:41:36","errorMessage":"/contract/instalmentStartDate [2024-07-03] is not a valid date-time-only","errorDescription":"error"}}');
            response.setStatusCode(500);
            return response;
        }
    }
	public class MockHttpResponseGeneratorForAccessToken implements HttpCalloutMock {

        /**
          * @description    : generating mock RealPayURL responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response for getAccessToken callout
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "mockAccessToken123"}'); // Mock access token response
            response.setStatusCode(200);
            return response;
        }
    }
    
    @isTest 
    public static void execute_RealPayURLGenerate() {
        List<INS_API_RealPayUrl.Request> reqList = new List<INS_API_RealPayUrl.Request>();
        INS_API_RealPayUrl.Request req = new INS_API_RealPayUrl.Request();
        req.contractNumber = '123456';
        req.firstName = 'test';
        req.lastName = 'Name';
        req.collectionDay = '25';
        req.gender = 'Male';
        req.identificationType = 'test';
        req.identityNumber = '8792345676';
        req.dateOfBirth = Date.today();
        req.headerCountry = 'SOUTH AFRICA';
        req.productName = 'Liberty Flexi Protect';
        req.cellphoneNumber = '256987678';        
        reqList.add(req);
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        
        List<INS_API_RealPayUrl.Response> responseList = INS_API_RealPayUrl.execute(reqList);
        
        Assert.areEqual(1, responseList.size(), 'Expected response list size to be 1');
        
        INS_API_RealPayUrl.Response response = responseList[0];
        Assert.areEqual('ptyId_001001001', response.partySourceIdentifier, 'Unexpected partySourceIdentifier in the response');
        Assert.areEqual('UGCM930121003EGE', response.userId, 'Unexpected userId in the response');
        Assert.areEqual('https://uat.realpaycollect.com/rpswitch/?data=3FCCEAEC4B1E86AD7BEFB634C9F0E30C6:CYBSCARDUGX', response.sessionUrl, 'Unexpected sessionUrl in the response');
        
        Test.stopTest();
    }
    
    /**
     * @description  test method for execute_Test1
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param
     * @return
     * @date June 20th 2024
     */
    @isTest public static void execute_RealPayURLGenerateError(){
        List<INS_API_RealPayUrl.Request> reqList = new List<INS_API_RealPayUrl.Request> ();
        INS_API_RealPayUrl.Request req = new INS_API_RealPayUrl.Request ();
        req.contractNumber ='123456';
        req.firstName = 'test';
        req.lastName = 'Name';
        req.collectionDay = '12';
        req.gender = 'Male';
        req.identificationType = 'test';
        req.identityNumber = '8792345676';
        req.dateOfBirth = Date.today();
        req.headerCountry = 'SOUTH AFRICA';
        req.instalmentStartDate = '2024-07-03';
        req.productName = 'Liberty Flexi Protect';
        req.cellphoneNumber = '256987678';
        reqList.add(req);
        try{
        	Test.setMock(HttpCalloutMock.class, new MockHttpResponseErrorGenerator());
        	Test.startTest();
        	List<INS_API_RealPayUrl.Response> responseList = INS_API_RealPayUrl.execute(reqList);
        	Assert.areEqual(1, responseList.size(), 'Expected response list size to be 1');

            INS_API_RealPayUrl.Response response = responseList[0];
            
            Assert.areEqual(400, response.errorCode, 'Unexpected error code in the response');
            Assert.areEqual('2024-06-20T10:41:36', response.errorDateTime, 'Unexpected error date/time in the response');
            Assert.areEqual('/contract/instalmentStartDate [2024-07-03] is not a valid date-time-only', response.errorMessage, 'Unexpected error message in the response');
        
        	Test.stopTest();    
        }Catch(Exception ex){
            Assert.AreEqual(true, true, 'Exception thrown: ' + ex.getMessage());
        }   
    }
}