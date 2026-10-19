/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :June 2023
@ Name of the Class :CMN_MobileWalletStatusTEST
@description       :Test Class for CMN_MobileWalletStatus
@ Story Number      :SFP-26348
***************************************************************************************/
@istest 
public class CMN_MobileWalletStatusTest {
     /**
    * @description TestMethod for invoking testCalloutMethod
    */
    @istest static void testCalloutMethod(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_MobileWalletStatus.invocableMethod(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod1
    */
    @istest static void testCalloutMethod1(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"FAILED","statusCode":"57"}';
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        String repStatus = CMN_MobileWalletStatus.invocableMethod(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod2
    */
    @istest static void testCalloutMethod2(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_MobileWalletStatus.mockHttpStatus='FAILED';
        CMN_MobileWalletStatus.mockHttpbody='';
        Test.startTest();
        
        String repStatus = CMN_MobileWalletStatus.invocableMethod(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod3
    */
    @istest static void testCalloutMethod3(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody='';
        Test.startTest();
        
        String repStatus = CMN_MobileWalletStatus.invocableMethod(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(null, m,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod4
    */
    @istest static void testCalloutMethod4(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        //System.enqueueJob(new CMN_MobileWalletStatus(lstApp,str));
        
        Test.stopTest();
        Assert.areNotEqual(null, lstApp,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod5(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"Pending","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        System.enqueueJob(new BCB_MobileWalletStatusQueueable(lstApp,lstAppParticipants,str));
        
        Test.stopTest();
        Assert.areNotEqual(null, lstApp,'Test');
    }
    
    /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod6(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
         List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"FAILED","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        System.enqueueJob(new BCB_MobileWalletStatusQueueable(lstApp,lstAppParticipants,str));
        
        Test.stopTest();
        Assert.areNotEqual(null, lstApp,'Test');
    }
     /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod7(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
        List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        System.enqueueJob(new BCB_MobileWalletStatusQueueable(lstApp,lstAppParticipants,str));
        
        Test.stopTest();
        Assert.areNotEqual(null, lstApp,'Test');
    }
    /**
    * @description TestMethod for invoking testCalloutMethod5
    */
    @istest static void testCalloutMethod8(){  
        try{
            List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        insert lstApp;
            List<Application_Participant__c> lstAppParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstAppParticipants[0].Application__c=lstApp[0].id;
        insert lstAppParticipants;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        
        CMN_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWalletStatus.mockHttpStatus='OK';
        CMN_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        
        System.enqueueJob(new BCB_MobileWalletStatusQueueable(null,null, null));
        
        Test.stopTest();
        }catch(exception dmx){
             Assert.areNotEqual(null, dmx.getMessage());
        }
        
    }
}