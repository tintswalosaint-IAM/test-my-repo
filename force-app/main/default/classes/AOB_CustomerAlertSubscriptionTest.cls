/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerAlertSubscriptionTest
@description        : Test Class for AOB_CustomerAlertSubscription
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
@isTest
public class AOB_CustomerAlertSubscriptionTest { 
    /**
    * @description TestMethod to check the Error Response
    */   
    @isTest static void testErrorResponse(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;  
        string mockResponse = '{"ErrorCode":"B000000051","ErrorDescription":"The user already subscribed for alerts","ErrorSource":" ","ErrorStatus":" "}';
        AOB_CustomerAlertSubscription.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerAlertSubscription.mockHttpStatus ='OK';
        AOB_CustomerAlertSubscription.mockHttpBody = mockResponse;
        Test.startTest();
        String repStatus = AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('ErrorDescription'), 'The user already subscribed for alerts', 'The user already subscribed for alerts');
    }
      /**
    * @description TestMethod to check the Error Response
    */   
    @isTest static void testErrorResponseEmptyContent(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;  
        AOB_CustomerAlertSubscription.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerAlertSubscription.mockHttpStatus ='OK';
        AOB_CustomerAlertSubscription.mockHttpBody = null;
        Test.startTest();
        String repStatus = AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('ErrorDescription'), 'No response body', 'No response body');
    }
     /**
    * @description TestMethod to check when the internal server error
    */  
    @isTest static void testinternalServerError(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        string mockResponse = '{"ErrorCode":"B000000051","ErrorDescription":"The user already subscribed for alerts.","ErrorSource":"","ErrorStatus":" "}';
        AOB_CustomerAlertSubscription.mockHttpStatusCode =CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerAlertSubscription.mockHttpStatus ='OK';
        AOB_CustomerAlertSubscription.mockHttpBody = mockResponse;
        Test.startTest();
        String repStatus = AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED','Will tell you status');
    }
     /**
    * @description TestMethod to check the No content Response
    */  
     @isTest static void testNoContentState(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;  
        AOB_CustomerAlertSubscription.mockHttpStatusCode =CMN_API_HttpBase.HTTP_NO_CONTENT;
        AOB_CustomerAlertSubscription.mockHttpStatus ='OK';
        AOB_CustomerAlertSubscription.mockHttpBody = null;
        Test.startTest();
        String repStatus = AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED','Will tell you status');
    }
     /**
    * @description TestMethod to check the Syccess Response
    */  
       @isTest static void testSuccessResponse(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        string mockResponse ='{"customerAlert":{"CustomData":""},"errorCode":"S000000001","statusMsg":"Record Added Successfully","status":"SUCCESS"}';
        AOB_CustomerAlertSubscription.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerAlertSubscription.mockHttpStatus ='OK';
        AOB_CustomerAlertSubscription.mockHttpBody = mockResponse;
        Test.startTest();
        String repStatus = AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'SUCCESS','Will tell you status');
   }
}