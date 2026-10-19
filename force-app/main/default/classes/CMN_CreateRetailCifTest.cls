/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :June 2023
@ Name of the Class :CMN_CreateRetailCifTest
@description       :Test Class for CMN_CreateRetailCif api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-24866
***************************************************************************************/
@istest
public class CMN_CreateRetailCifTest {
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        
        insert lstApp;
         
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        
        String str='{ "CustId": "10302321195","Status": "SUCCESS","Description": "Retail Customer successfully created with CIFID 10302321195"}';
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody=str;
        Test.startTest(); 
        String repStatus = CMN_CreateRetailCif.invocableMethod(lstApp,lstOfParticipants,individuals);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.isNotNull(m,'Test');
    }
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod2(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        
        insert lstApp;
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        
        String str='{ "CustId": "","Status": "SUCCESS","Description": "Retail Customer successfully created with CIFID 10302321195"}';
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody=str;
        Test.startTest();
        String repStatus = CMN_CreateRetailCif.invocableMethod(lstApp,lstOfParticipants,individuals);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.isNotNull(m,'Test');
    }
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod3(){  

        
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Lead__c = l.id;
        insert lstApp;
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        String str='{ "CustId": "10302321195","Status": "SUCCESS","Description": "Retail Customer successfully created with CIFID 10302321195"}';
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody=str;
        try{
        Test.startTest();
         CMN_CreateRetailCif.invocableMethod(lstApp,lstOfParticipants,individuals);
        Test.stopTest();
    }catch(exception ex){
        Assert.areNotEqual(null, lstOfParticipants,'Test');
    } 
    }
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod4(){  
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Lead__c = l.id;
        insert lstApp;
          
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CreateRetailCif.mockHttpStatus='FAILED';
        CMN_CreateRetailCif.mockHttpbody='';
        try{
        Test.startTest();
       CMN_CreateRetailCif.invocableMethod(lstApp,lstOfParticipants,individuals);
        Test.stopTest();
    }catch(exception ex){
        Assert.areNotEqual(null, lstOfParticipants,'Test');
    } 
    }
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod5(){    
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        lstApp[0].AOB_Lead__c = l.id;
        insert lstApp;
        
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        Indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody='';
        try{
        Test.startTest();
         CMN_CreateRetailCif.invocableMethod(lstApp,lstOfParticipants,individuals);
        Test.stopTest();
    }catch(exception ex){
        Assert.areNotEqual(null, lstOfParticipants,'Test');
    } 
    }
    /**
    * @description Test method for CMN_CreateRetailCif
    */
    @istest static void testCalloutMethod6(){    
        List<Application__c> lstApp = BCB_DAL_TestFactory.createApplication(1);
        
        insert lstApp;
        
        List<Individual> individuals = new List<Individual>();
        
        List<Application_Participant__c> lstOfParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
         lstOfParticipants[0].AOB_Title__c='40';
        lstOfParticipants[0].AOB_CIFID__c = '';
        insert lstOfParticipants;
        
        lstOfParticipants[0].application__c =  lstApp[0].Id;
        update lstOfParticipants;
        
        Individual indivi= BCB_DAL_TestFactory.createIndividual();
        indivi.Application_Participant__c = lstOfParticipants[0].Id;
        individuals.add(indivi);
        insert individuals;
        CMN_CreateRetailCif.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateRetailCif.mockHttpStatus='OK';
        CMN_CreateRetailCif.mockHttpbody='{ "CustId": "10302321195","Status": "SUCCESS","Description": "Retail Customer successfully created with CIFID 10302321195"}';
        Test.startTest();
        String repStatus = BCB_FlowController.invokeCustomerCreation(lstOfParticipants[0].Id);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.isNotNull(m,'Test');
    }
}