/**
 * @description       : Test class for PER_API_BAS_Service and ALL its related sub-classes 
 * @author            : Sandile Mathe
 * @group             : Personalisation
 * @created On        : 13-05-2024
 * 
 * 2024-07-16   Derek       Updated to use the Integration Framework
**/

@isTest(seeAllData=false) 
public with sharing class PER_API_BAS_Service_Test {
      
    // Mock HTTP response generator
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response body
            String responseBody = '[{"eventID":"9","bpid":"0534649685","AE_NUMBER":"0534649685"}]'+ '[{"eventContent":"Dear [Clients Name],\n\nI hope this email finds you well. As your private banker at Standard Bank, I would like to inform you that a fraud case has been created due to a suspicious transaction on your account. The case number is 2024-554966187, and it was created on 2024-03-12"}]';
            
            // Create a mock HTTP response
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseBody);
            res.setStatusCode(CMN_API_Service.HTTP_OK);
            
            return res;
        }
    }

    @isTest
    static void testGetEventAlertsByAENumber() {
        // Create a mock HTTP response
        sbgplatform.ApiService.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator());

        // Call the method under test
        
        Test.startTest();
        
            List<BAS_DTO_EventAlertsResponse> response;
            
            response = new PER_API_BAS_Service().getEventAlertsByAENumber('0046383');
        
        Test.stopTest();

        // Assert that the results are not null
        Assert.areNotEqual(null, response,'Response should not be null after calling the API with valid parameters');
        Assert.areEqual(true, response.size()>=1, 'Atleast One Fraud Alert was returned');
        Assert.areEqual('9', response[0].eventId,'The Fraud Alert matches the response EventId');
        Assert.areEqual('0534649685', response[0].bpid,'The Fraud Alert matches the response bpId');
    }
    
    
}