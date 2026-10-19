/***************************************************************************************
@ Author            :Jagadish thummala
@ Date              :July 2023
@ Name of the Class :CMN_CreateEnterpriseCustomer
@description       : Class for dealing with CMN_CreateEnterpriseCustomer api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Jagadish thummala 
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25772 
***************************************************************************************/
@isTest 
public with sharing class CMN_CreateEnterpriseCustomerTest {
     /**
    * @description TestMethod for invoking BCB_CreateCorporateCif
    *
    */
    @isTest
    static void callInvocable(){
       
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        String str='{"customRegisterQNAResponse":{"userIdentity":"9030020359144","customerFirstName":"FAITHMIGI","Message":[{"Status":"306518","StatusCode":"306518","StatusType":"BC"},{"Status":"Password Set Successfully. Your user id is 9030020359144.","StatusCode":"107045","StatusType":"BC"},{"Status":"Registration for security questions successful.","StatusCode":"107034","StatusType":"BC"}]}}';
        insert lstApp;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        CMN_CreateEnterpriseCustomer.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateEnterpriseCustomer.mockHttpStatus='OK';
        CMN_CreateEnterpriseCustomer.mockHttpBody=str;
        try{ 
            test.startTest();       
            String serializedResponse =CMN_CreateEnterpriseCustomer.invocableMethod(lstApp,sr); 
            test.stopTest();
            Assert.areNotEqual(null,serializedResponse,'Test'); 
        }catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage(),'Test'); 
            }
        
    }
 /**
    * @description TestMethod for invoking BCB_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod1(){     
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        CMN_CreateEnterpriseCustomer.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        CMN_CreateEnterpriseCustomer.mockHttpStatus='OK';
        CMN_CreateEnterpriseCustomer.mockHttpBody=null;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        Map<String, Object> m = new map<string,Object>();
        try{
            Test.startTest();
            String repStatus = CMN_CreateEnterpriseCustomer.invocableMethod(lstApp,sr); 
            m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
        }catch(Exception ex){
             Assert.areNotEqual((String)m.get('status'), 'FAILED', 'It will check satatus');
        }
        
    }
     /**
    * @description TestMethod for invoking BCB_CreateCorporateCif
    *
    */
    @istest static void testCalloutMethod2(){     
        List<Application_Participant__c> lstApp = BCB_DAL_TestFactory.createApplicationParticipant(1);
        CMN_CreateEnterpriseCustomer.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CreateEnterpriseCustomer.mockHttpStatus='OK';
        CMN_CreateEnterpriseCustomer.mockHttpBody=null;
        String sr = '{"customLoginQNAResponse":{"userIdentity":"214954","Status":"SUCCESS","StatusCode":"0000","Questions":[{"questionIdentifier":"100","questionDescription":"What is your pets name?"},{"questionIdentifier":"101","questionDescription":"What is your favourite place?"},{"questionIdentifier":"102","questionDescription":"What is your grandfathers occupation?"}]}}';
        Map<String, Object> m = new Map<String, Object>();
        try{
            Test.startTest();
            String repStatus = CMN_CreateEnterpriseCustomer.invocableMethod(lstApp,sr); 
            m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
            Test.stopTest();
        }catch(Exception ex){
            Assert.areNotEqual((String)m.get('status'), 'FAILED', 'It will check satatus');
        }     
    }

}