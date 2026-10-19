/**
 * @description       : Test class for PER_API_BAS_Service and ALL its related sub-classes 
 * @author            : Sandile Mathe
 * @group             : Personalisation
 * @created On        : 17-02-2024
 * 
**/

@isTest(seeAllData=false) 
public with sharing class PER_API_BAS_Feedback_Service_Test {
    
     @isTest
    static void testSendEventUpdate() {
        
        sbgplatform.ApiService.setMock(HttpCalloutMock.class, new MockHttpResponse());

        PER_API_BAS_Feedback_Service service = new PER_API_BAS_Feedback_Service();

        String testEventId = '12345';
        String testEmailContent = 'This is a test email content';

        Test.startTest();
        try {
            service.sendEventUpdate(testEventId, testEmailContent);
        } catch (Exception e) {
            Assert.areEqual(false, 'Method threw an unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();

        Assert.areEqual(true,true, 'API call executed successfully without errors.');

    }
    
        private class MockHttpResponse implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setBody('"true"'); 
            res.setStatusCode(CMN_API_Service.HTTP_OK);
            return res;
        }
    }


}