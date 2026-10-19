/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :CMN_CustomerAlertSubscriptionTest
@description       :Test Class for dealing with AlertSubscription api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-05-2023
@ Modification Description : SFP-26345
***************************************************************************************/
 
@istest
public class CMN_CustomerAlertSubscriptionTest {
    /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
	@istest static void testCalloutMethod(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            String str='{"customerAlert": {"CustomData": ""},"errorCode": "S000000001","statusMsg": "Record Added Successfully"}';
            CMN_CustomerAlertSubscription.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertSubscription.mockHttpStatus='OK';
            CMN_CustomerAlertSubscription.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertSubscription.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(m, null,'It should Not be null');
            Assert.areNotEqual(repStatus, null,'It should Not be null');

     }
    /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
    @istest static void testCalloutMethod1(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            String str='{"customerAlert": {"CustomData": ""},"errorCode": "","statusMsg": "Record Added Successfully"}';
            CMN_CustomerAlertSubscription.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertSubscription.mockHttpStatus='OK';
            CMN_CustomerAlertSubscription.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertSubscription.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(m, null,'It should Not be null');
            Assert.areNotEqual(repStatus, null,'It should Not be null');
     }
    /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
    @istest static void testCalloutMethod2(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            String str='{"customerAlert": {"CustomData": ""},"errorCode": "S000000001","statusMsg": "Record Added Successfully"}';
            CMN_CustomerAlertSubscription.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_CustomerAlertSubscription.mockHttpStatus='OK';
            CMN_CustomerAlertSubscription.mockHttpbody=str;
            Test.startTest();
            String repStatus = CMN_CustomerAlertSubscription.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(m, null,'It should Not be null');
            Assert.areNotEqual(repStatus, null,'It should Not be null');
     }
    /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @istest static void testCalloutMethod3(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            CMN_CustomerAlertSubscription.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
            CMN_CustomerAlertSubscription.mockHttpStatus='FAILED';
            CMN_CustomerAlertSubscription.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_CustomerAlertSubscription.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest(); 
            Assert.areNotEqual(m, null,'It should Not be null');
            Assert.areNotEqual(repStatus, null,'It should Not be null');
     }
    /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @istest static void testCalloutMethod4(){    
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
            CMN_CustomerAlertSubscription.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
            CMN_CustomerAlertSubscription.mockHttpStatus='OK';
            CMN_CustomerAlertSubscription.mockHttpbody='';
            Test.startTest();
            String repStatus = CMN_CustomerAlertSubscription.invocableMethod(lstApp);
            Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
            Assert.areNotEqual(m, null,'It should Not be null');
            Assert.areNotEqual(repStatus, null,'It should Not be null');
     }
         /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @isTest
    static void testCallInvocableMethod6() {
        
        CMN_CustomerAlertSubscription.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertSubscription.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertSubscription.mockHttpBody = '{"customerAlert": {"CustomData": ""},"errorCode": "S000000001","statusMsg": "Record Added Successfully"}';
       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
         
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;
        
        Test.startTest(); 
        System.enqueueJob(new BCB_AlertSubscriptionQueueable(applicationList,lstofParticipants));

        Test.stopTest(); 
        Assert.areNotEqual(lstofParticipants, null,'It should Not be null');      
    }
        /**
    * @description TestMethod for invoking Alert Subscription
    *
    */
     @isTest
    static void testCallInvocableMethod7() {
        
        CMN_CustomerAlertSubscription.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerAlertSubscription.mockHttpStatus='SUCCESS';
        CMN_CustomerAlertSubscription.mockHttpBody = '{"customerAlert": {"CustomData": ""},"ErrorDescription": "S000000001","statusMsg": "Record Added Successfully"}';
       
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
         
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
           lstofParticipants[0].Application__c = applicationList[0].Id;
           insert lstofParticipants;
        try{
            Test.startTest(); 
        System.enqueueJob(new BCB_AlertSubscriptionQueueable(applicationList,lstofParticipants));

        Test.stopTest();
        }catch(Exception ex){
            Assert.areNotEqual(lstofParticipants, null,'It should Not be null'); 
        }
         
              
    }
}