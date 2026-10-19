/**
 * @description       : Test for PER_BAS_DataProviders
 * @author            : Sandile MAthe
 * @group             : PER: Personalisation
 * @Created on        : 13-05-2024
 * Helper classes     : PER_BAS_TestDataFactory
**/
@isTest
public class PER_BAS_DataProviders_Test {
    
     @isTest
    private static void notSupportedMethodsTest() { 
        sbgpers.RecommendedAction action = PER_BAS_TestDataFactory.getRecommendedActionInstance();
        PER_BAS_DataProviders rdp = new PER_BAS_DataProviders();
        Boolean exceptionSnooze = false;
        Boolean exceptionUnsnooze = false;
        Boolean exceptionOpportunity = false;
        Test.startTest();
            try{
                rdp.updateActionSnooze(action,'Test Reason',1);
            }
            catch(exception ex) {
                exceptionSnooze = true;
            }

            try{
                rdp.updateActionUnsnooze(action);
            }
            catch(exception ex){
                exceptionUnsnooze = true;
            }

            try{
                rdp.updateActionOpportunity(action,'TestId');
            }
            catch(exception ex){
                exceptionOpportunity = true;
            }
        Test.stopTest();
        Assert.isTrue(exceptionSnooze, 'updateActionSnooze method did not throw an exception');
        Assert.isTrue(exceptionUnsnooze, 'updateActionUnsnooze method did not throw an exception');
        Assert.isTrue(exceptionOpportunity, 'updateActionOpportunity method did not throw an exception');
    }
    
    @isTest
    private static void getActionsForPortfolioCodeTest() {
        // Create a mock HTTP response
         sbgplatform.ApiService.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator());
        
        List<sbgpers.RecommendedAction> actions;
        User testUser = PER_BAS_TestDataFactory.insertTestUser();
        sbgpers.RecommendationManagerConfig config = new sbgpers.RecommendationManagerConfig();
        config.configCountryCode = 'ZA';
        System.runAs(testUser) {
            PER_BAS_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_BAS_DataProviders rdp = new PER_BAS_DataProviders();
                rdp.setConfig(config);
                actions = rdp.getActionsForPortfolioCode(testUser.RM_AE_Code__c);
            Test.stopTest();
            
            Assert.areEqual(1, actions.size(), 'Expected 1 action records from the Mock response');
        }
    }
    
    @isTest
    private static void updateActionDismissTest() {
        User testUser = PER_BAS_TestDataFactory.insertTestUser();
        sbgpers.RecommendedAction actionUpdated;
        System.Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator());

        System.runAs(testUser) {
            sbgpers.RecommendedAction action = PER_BAS_TestDataFactory.getRecommendedActionInstance();
            sbgpers.RecommendedActionResult actionResult = PER_BAS_TestDataFactory.getActionResultInstance();
            PER_BAS_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_BAS_DataProviders rdp = new PER_BAS_DataProviders();
                actionUpdated = rdp.updateActionDismiss(action,actionResult);
            Test.stopTest();
        }
        Assert.areEqual('Dismissed', actionUpdated.status, 'The action was not updated to status "Dismissed"');
    }
    
       @isTest
    private static void updateActionCompleteTest() {
        User testUser = PER_BAS_TestDataFactory.insertTestUser();
        sbgpers.RecommendedAction actionUpdated;
        System.Test.setMock(HttpCalloutMock.class,  new MockHttpResponseGenerator());

        System.runAs(testUser) {
            sbgpers.RecommendedAction action = PER_BAS_TestDataFactory.getRecommendedActionInstance();
            sbgpers.RecommendedActionResult actionResult = PER_BAS_TestDataFactory.getActionResultInstance();
            PER_BAS_TestDataFactory.createTestAccount();
            Test.startTest();
                PER_BAS_DataProviders rdp = new PER_BAS_DataProviders();
                actionUpdated = rdp.updateActionComplete(action,actionResult);
            Test.stopTest();
        }
        Assert.areEqual('Completed', actionUpdated.status, 'The action was not updated to status "Completed"');
    }

    
    
      public class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock response body
            String responseBody = '[{"eventId":25,"eventType":"FRAUD_ALERT","aeNumber":"0046383","bpId":519079219,"eventContent":"Dear [Client],I hope this email finds you well.The case number is 2024-554593828 and it was created on March 12. Regards,[Your Name]Private Banker at Standard Bank","loadDate":"2024-03-26 12:53:02.618548","eventDetails":"Fraud case opened. Check in with client.","status":"outstanding"}]';
            // Create a mock HTTP response
            HTTPResponse res = new HTTPResponse();
            res.setBody(responseBody);
            res.setStatusCode(CMN_API_Service.HTTP_OK);
            
            return res;
        }
    }

}