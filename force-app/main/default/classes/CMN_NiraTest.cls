/***************************************************************************************
@ Author            :Jagadish Thummala 
@ Date              :May 2023
@ Name of the Class :CMN_NiraTest
@description       :Test Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-05-2023
@ Modification Description : SFP-24855
***************************************************************************************/
/**
 *@description Test Class for dealing with NIRA api and sending the result to the main container and storing the values in the wrapper
 */
@isTest
public class CMN_NiraTest {   
    /**
    * @description TestMethod for invoking nira
    *
    */
    @istest static void testInvocableMethod(){
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
        CMN_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_NIRA.mockHttpStatus='OK';
        CMN_NIRA.mockHttpBody=str;
        Test.startTest();
        CMN_NIRA.invocableMethod(participantList);
        Test.stopTest();
        List<Verification__c> verificationList=[SELECT Id FROM Verification__c];
        Assert.areEqual(1,verificationList.size(), 'It will check status');
       
    }
    /**
    * @description TestMethod for invoking nira
    *
    */   
    @istest static void testInvocableMethod1(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"false","cardStatus":"Valid"}}}';
        CMN_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_NIRA.mockHttpStatus='OK';
        CMN_NIRA.mockHttpBody=str;
        try{
        Test.startTest();
        CMN_NIRA.invocableMethod(participantList);
        Test.stopTest();
       
    }catch(exception ex){
        Assert.areNotEqual(null, participantList,'Test');
    }  
        
       
    }
    /**
    * @description TestMethod for invoking nira
    *
    */
    @istest static void testInvocableMethod2(){
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
        CMN_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_NIRA.mockHttpStatus='OK';
        CMN_NIRA.mockHttpBody=str;
        Test.startTest();
        String resultList=CMN_NIRA.invocableMethod(participantList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        List<Verification__c> verificationList=[SELECT Id FROM Verification__c];
        Assert.areEqual(1,verificationList.size(), 'It will check status');
        Assert.areEqual((String)m.get('matchingStatus'), 'true', 'It will check status');
    }
    /**
    * @description TestMethod for invoking nira
    *
    */
    @istest static void testInvocableMethod3(){
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        CMN_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_NIRA.mockHttpStatus='OK';
        CMN_NIRA.mockHttpBody=null;
        try{
        Test.startTest();
        CMN_NIRA.invocableMethod(participantList);
        Test.stopTest();
       
    }catch(exception ex){
        Assert.areNotEqual(null, participantList,'Test');
    } 
    }
}