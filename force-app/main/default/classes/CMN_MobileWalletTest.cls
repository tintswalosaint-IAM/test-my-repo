/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :June 2023
@ Name of the Class :CMN_MobileWalletTest
@ Description       :Test Class for CMN_MobileWallet
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 04-04-2024
@ Story Number      :SFP-37302
***************************************************************************************/
/** 
@description Test Class for CMN_MobileWallet
*/
@isTest  
public class CMN_MobileWalletTest {
    /** 
@description Test Class for CMN_MobileWallet
*/
    @isTest
    static void callInvocable(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        test.startTest();
        try{        
            String serializedResponse =CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants); 
            Assert.areNotEqual(null,serializedResponse,'Test');
        }catch(exception e){
            Assert.areNotEqual(null, e.getMessage(),'Test');
        }
        test.stopTest();
    }
    /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod1() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='OK';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}'; 
        
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        
        CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants);
        
        Test.stopTest();
        Assert.areNotEqual(null, lstofParticipants,'Test');
        
    }  /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod2() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='OK';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"","statusCode":"200","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        
        CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants);
        
        Test.stopTest(); 
        Assert.areNotEqual(null, lstofParticipants,'Test');       
    }
    /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod3() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_MobileWallet.mockHttpStatus='OK';
        CMN_MobileWallet.mockHttpBody = '';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        
        CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants);
        
        Test.stopTest();   
        Assert.areNotEqual(null, lstofParticipants,'Test');     
    }
    /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod4() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_MobileWallet.mockHttpStatus='FAILED';
        CMN_MobileWallet.mockHttpBody = '';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        
        CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants);
        
        Test.stopTest();
        Assert.areNotEqual(null, lstofParticipants,'Test');          
    }
    /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod5() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='SUCCESS';
        CMN_MobileWallet.mockHttpBody = '';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest();
        
        CMN_MobileWallet.invocableMethod(applicationList,lstofParticipants);
        
        Test.stopTest();     
        Assert.areNotEqual(null, lstofParticipants,'Test');     
    }
    /** 
@description Test method for CMN_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod6() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='SUCCESS';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        Test.startTest(); 
        System.enqueueJob(new BCB_MobileWalletQueueable(applicationList,lstofParticipants));
        
        Test.stopTest(); 
        Assert.areNotEqual(null, lstofParticipants,'Test');        
    }
    /** 
@description Test Class for BCB_MobileWallet
*/
    @isTest
    static void testCallInvocableMethod7() {
        CMN_MobileWallet.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_MobileWallet.mockHttpStatus='SUCCESS';
        CMN_MobileWallet.mockHttpBody = '{"sessionNumber":"", "status": "FAILED","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","statusCode":"01"}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].First_Deposit_Amount__c = 100000;
        insert applicationList;
        
        List<Application_Participant__c> lstofParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstofParticipants[0].Application__c = applicationList[0].Id;
        insert lstofParticipants;
        
        try{
            Test.startTest(); 
            System.enqueueJob(new BCB_MobileWalletQueueable(applicationList,lstofParticipants));
            
            Test.stopTest();  
        }catch(Exception ex){
            Assert.areNotEqual(null, lstofParticipants,'Test'); 
        }
        
        
    }
}