/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :CMN_CreateCorporateCifTest
@description       :Test Class for dealing with BCB_CreateCorporateCif api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25772 
***************************************************************************************/
@istest
public class CMN_CreateCorporateCifTest {
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    */
    @istest static void testCalloutMethod(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        insert lstofParticipants;
        String str='{"uuid": "20301168618","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_CreateCorporateCif.invocableMethod(lstApp,lstofParticipants);
    
        Test.stopTest();
        Assert.isNotNull(repStatus,'Test');
    }
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod1(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        insert lstofParticipants;
        String str='{"uuid": "","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_CreateCorporateCif.invocableMethod(lstApp,lstofParticipants);
      
        Test.stopTest();
        Assert.isNotNull(repStatus,'Test');
    }
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod2(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        insert lstApp;
        insert lstofParticipants;
        String str='{"uuid": "20301168618","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody=str;
        String repStatus;
        try{
            Test.startTest();
        	repStatus = CMN_CreateCorporateCif.invocableMethod(lstApp,lstofParticipants);       
        	Test.stopTest();
        }catch(Exception ex){
             Assert.isNull(repStatus,'Test');
        }
        
       
    }
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod3(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        insert lstofParticipants;
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CreateCorporateCif.mockHttpStatus='FAILED';
        CMN_CreateCorporateCif.mockHttpbody='';
        String repStatus;
        try{
            Test.startTest();
        		repStatus = CMN_CreateCorporateCif.invocableMethod(lstApp,lstofParticipants);       
        	Test.stopTest(); 
        }catch(Exception ex){
             Assert.isNull(repStatus,'Test');
        }
       
       
    }
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod4(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstApp;
        insert lstofParticipants;
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody='';
        String repStatus;
        try{
            Test.startTest();
        		repStatus = CMN_CreateCorporateCif.invocableMethod(lstApp,lstofParticipants);
        	Test.stopTest();
        }catch(exception ex){
            Assert.isNull(repStatus,'Test');
        }     
    }
    /**
    * @description TestMethod for invoking CMN_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod5(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c = '';
        insert lstApp;
        
        List<Application_Participant__c> lstofParticipants =  BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert lstofParticipants;
        
        lstofParticipants[0].Application__c = lstApp[0].Id;
        update lstofParticipants;
        CMN_CreateCorporateCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateCorporateCif.mockHttpStatus='OK';
        CMN_CreateCorporateCif.mockHttpbody='{"uuid": "20301168618","desc": "Corporate Customer successfully created with CIFID 20301168618","entity": "Corporate Customer","status": "SUCCESS"}';
        Test.startTest();
        String repStatus = BCB_FlowController.invokeCustomerCreationCorporate(lstofParticipants[0].Id);
       
        Test.stopTest();
        Assert.isNotNull(repStatus,'Test');
    }
}