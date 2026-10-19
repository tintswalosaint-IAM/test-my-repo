/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :CMN_CustomerRiskAssessmentTest
@description       :Test Class for dealing with CustomerRiskAssessmentTest api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa 
@ Last Modified On  :20-07-2023
@ Modification Description : SFP-26349
***************************************************************************************/
@isTest
public class CMN_CustomerRiskAssessmentTest {
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants); 
             Assert.areNotEqual(serializedResponse, null,'It should Not be null');
        }catch(exception e){
             Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable1(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        
        CMN_CustomerRiskAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerRiskAssessment.mockHttpStatus='OK';
        CMN_CustomerRiskAssessment.mockHttpBody = '{"RiskScoreStatus": "48.33","RiskScoreRating": "MEDIUM"}';
        
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants); 
                         Assert.areNotEqual(serializedResponse, null,'It should Not be null');           
        }catch(exception e){
            Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable2(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_CustomerRiskAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerRiskAssessment.mockHttpStatus='OK';
        CMN_CustomerRiskAssessment.mockHttpBody = '{"RiskScoreStatus": "","RiskScoreRating": "MEDIUM"}';
        
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants);
                         Assert.areNotEqual(serializedResponse, null,'It should Not be null');
            
        }catch(exception e){
            Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable3(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_CustomerRiskAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CustomerRiskAssessment.mockHttpStatus='OK';
        CMN_CustomerRiskAssessment.mockHttpBody = '{"RiskScoreStatus": "48.33","RiskScoreRating": "MEDIUM"}';
        
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants);   
                         Assert.areNotEqual(serializedResponse, null,'It should Not be null');
         
        }catch(exception e){
            Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable4(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_CustomerRiskAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_CustomerRiskAssessment.mockHttpStatus='FAILED';
        CMN_CustomerRiskAssessment.mockHttpBody = '';
        
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants);  
                         Assert.areNotEqual(serializedResponse, null,'It should Not be null');
          
        }catch(exception e){
            Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking Customer Risk Assessment
*
*/
    @isTest
    static void callInvocable5(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<Product2> productList = BCB_DAL_TestFactory.createProduct();
        insert productList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        CMN_CustomerRiskAssessment.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        CMN_CustomerRiskAssessment.mockHttpStatus='OK';
        CMN_CustomerRiskAssessment.mockHttpBody = '';
        
        test.startTest();
        try{        
            String serializedResponse =CMN_CustomerRiskAssessment.invocableMethod(applicationList,productList,appParticipants);   
                         Assert.areNotEqual(serializedResponse, null,'It should Not be null');
         
        }catch(exception e){
            Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
}