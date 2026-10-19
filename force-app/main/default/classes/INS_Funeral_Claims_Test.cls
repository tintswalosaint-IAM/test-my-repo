/**
 * @description  test class for INS_Quote_Conversion
 * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
 * @param
 * @return
 * @date Nov 07th 2023
 */
@isTest
public class INS_Funeral_Claims_Test {

	/**
     * @description  test method for execute
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param
     * @return
     * @date Nov 07th 2023
     */
    @isTest
    static void executeTest() {
        List<INS_Funeral_Claims.Request> reqList = new List<INS_Funeral_Claims.Request> ();
        INS_Funeral_Claims.Request req = new INS_Funeral_Claims.Request ();
        req.contractNumber ='123456';
        req.fullName = 'test Name';
        req.idNumber = '456789';
        req.relation = 'testName';
        req.emailAddress = 'testName';
        req.phoneNo = '8792345676';
        req.deathTime = Date.today();
        req.birthDate = '10 August 1996';
        req.headerCountry = 'SOUTH AFRICA';
        req.affectedLifeAssuredbirthdate = Date.today();
        reqList.add(req);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        List<INS_Funeral_Claims.Response> responseList = INS_Funeral_Claims.execute(reqList);
        Assert.areEqual(1, responseList.size());
        Test.stopTest();

    }

    /**
     * @description Mock HTTP response generator for the callout
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param .
     * @return .
     * @date Nov 07th 2023
     */
    // Mock HTTP response generator for the callout
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        /**
          * @description    : generating fake responses
          * @author         : Khaliq Abdul
          * @param request  : HTTPRequest object
          * @return         : HTTPResponse
          **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"FuneralFNOLResponse":{"ClaimEventNumber":"FLX23-001605","Status":"Success","Accepted":true,"Messages":[{"Code":"201","MessageType":"","Message":""}]}}}');
            response.setStatusCode(200);
            return response;
        }
    }

    /**
     * @description Mock HTTP response generator for the callout
     * @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
     * @param .
     * @return .
     * @date Nov 07th 2023
     */
    public class MockHttpResponseGeneratorForAccessToken implements HttpCalloutMock {

        /**
          * @description    : generating fake responses
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

}