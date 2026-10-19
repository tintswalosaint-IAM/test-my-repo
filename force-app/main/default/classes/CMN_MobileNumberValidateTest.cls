/***************************************************************************************
@Name of the Class : CMN_MobileNumberValidateTest
@Description       : Test class for CMN_MobileNumberValidate
@Author            : Jagadish Thummala 
@Date              : May 2023
@Last Modified By  : Ravi Myaka 
@Last Modified On  : 29-02-2024
@Modification Description : SFP-36156
***************************************************************************************/

@isTest
public class CMN_MobileNumberValidateTest {
 /**
    * @description TestMethod for invoking CMN_MobileNumberValidate
    *
    */
    @istest static void testCalloutMethod(){    
        List<Application_Participant__c> appList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appList; 
        String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful"},"Resultz":{"CustomerReference":"256782793556","Area":"WALLET","StatusCode":"0","StatusDescription":"ACTIVE","CustomerName":"DENNIS  STANLEY MBOGO","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileNumberValidate.mockHttpStatus='OK';
        CMN_MobileNumberValidate.mockHttpbody=str;
        Test.startTest();
        String resultList = CMN_MobileNumberValidate.invocableMethod(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('Description'), 'Successful','Test');
    }
    
     /**
    * @description TestMethod for invoking CMN_MobileNumberValidate
    *
    */
    @istest static void testCalloutwithAirtelMNMethod(){    
        List<Application_Participant__c> appList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        appList[0].CNGCU_Phone__c = '767654321';
        insert appList; 
        String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"0","Description":"Successful"},"Resultz":{"CustomerReference":"256767654321","Area":"WALLET","StatusCode":"0","StatusDescription":"ACTIVE","CustomerName":"DENNIS  STANLEY MBOGO","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileNumberValidate.mockHttpStatus='OK';
        CMN_MobileNumberValidate.mockHttpbody=str;
        Test.startTest();
        String resultList = CMN_MobileNumberValidate.invocableMethod(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('Description'), 'Successful','Test');
    }
    
    /**
    * @description TestMethod for invoking CMN_MobileNumberValidate
    *
    */
    @istest static void testCalloutMethod2(){    
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_MobileNumberValidate.mockHttpStatus='Ok';
        CMN_MobileNumberValidate.mockHttpbody= null;
        try{
        Test.startTest();
         CMN_MobileNumberValidate.invocableMethod(participantList);
        Test.stopTest(); 
    }catch(exception ex){
        Assert.areNotEqual(null, participantList,'Test');
    }  
        
    }
      /** 
* @description TestMethodCMN_MobileNumberValidate
*/
@istest static void mobileNumberValidateTest(){
     
    lead l = BCB_DAL_TestFactory.createLead();
    insert l;
    List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
    app[0].AOB_Lead__c = l.id;
    insert app;
    List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
    participantList[0].application__c = app[0].id;
    insert participantList; 
        String str='{"Body":{"ValidateCustomerResponse":{"ValidateCustomerResult":{"Details":{"Status":{"StatusCode":"100","Description":"UNABLE TO VERIFY CUSTOMER REFERENCE AT THE MOMENT"},"Resultz":{"CustomerReference":"","Area":"WALLET","StatusCode":"0","StatusDescription":"","CustomerName":"","Tin":"","CustomerType":"","OutstandingBalance":""}}}}}}'; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileNumberValidate.mockHttpStatus='OK';
        CMN_MobileNumberValidate.mockHttpbody=str;
        Test.startTest();
        String resultList = CMN_MobileNumberValidate.invocableMethod(participantList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();  
       Assert.areEqual((String)m.get('Description'), 'UNABLE TO VERIFY CUSTOMER REFERENCE AT THE MOMENT','Test');
}
  /**
    * @description TestMethod for invoking CMN_MobileNumberValidate
    *
    */
    @istest static void testCalloutMethod3(){    
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> app = BCB_DAL_TestFactory.createApplication(1);
        app[0].AOB_Lead__c = l.id;
        insert app;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);
        participantList[0].application__c = app[0].id;
        insert participantList; 
        CMN_MobileNumberValidate.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_MobileNumberValidate.mockHttpStatus='Ok';
        CMN_MobileNumberValidate.mockHttpbody= null;
        try{
        Test.startTest();
       CMN_MobileNumberValidate.invocableMethod(participantList);
        Test.stopTest(); 
    }catch(exception ex){
        Assert.areNotEqual(null, participantList,'Test');
    }  
 
    }

}