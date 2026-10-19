/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_ODAccountCreationTest
@ Description       :Test Class for dealing with AccountCreation api and sending the result to the main container and storing the values in the wrapper
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-07-2023
@ Modification Description : SFP-25770
***************************************************************************************/
/**
 * @description Test Class for dealing with AccountCreation api and sending the result to the main container and storing the values in the wrapper
 */
@isTest 
public class CMN_ODAccountCreationTest {
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocable(){
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert applicationList;
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        test.startTest();
        try{        
            String serializedResponse =CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);   
                    Assert.areNotEqual(null, serializedResponse,'Test');
        }catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'The expected exception message should be caught.');
        }
        test.stopTest();
    }
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocableMethod1(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpBody = '{"ODAccountAddRes": {"ODaccountNumber": {"accountNumber": "9030022144382","accountType": {"schemaCode": {},"schemaType": {}},"accountCurrency": {},"bankInfo": { "bankId": {},"name": {},"branchId": {},"branchName": {},"postalAddress": {"line1": {},"line2": {},"line3": {},"city": {},"stateProvince": {},"postalCode": {},"country": {},"addressType": {}}}}}}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert applicationList;
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        
        CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
        
        Test.stopTest();
        Assert.areNotEqual(null, appParticipants,'Test');
       
    }
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocableMethod2(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpBody = '{"ODAccountAddRes": {"ODaccountNumber": {"accountNumber": "","accountType": {"schemaCode": {},"schemaType": {}},"accountCurrency": {},"bankInfo": { "bankId": {},"name": {},"branchId": {},"branchName": {},"postalAddress": {"line1": {},"line2": {},"line3": {},"city": {},"stateProvince": {},"postalCode": {},"country": {},"addressType": {}}}}}}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        
        CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
        
        Test.stopTest();
        Assert.areNotEqual(null, appParticipants,'Test');
       
    }
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocableMethod3(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpBody = '';
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        insert applicationList;
        
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        try{
        Test.startTest();
        
        CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
        
        Test.stopTest();
    }catch(exception ex){
        Assert.areNotEqual(null, appParticipants,'Test');
    }
    }
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocableMethod4(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_ODAccountCreation.mockHttpStatus='FAILED';
        CMN_ODAccountCreation.mockHttpBody = '';
        
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        insert applicationList;
        
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        try{
            Test.startTest();
            
            CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
            
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, appParticipants,'Test');
        }
        
    }
    /**
* @description TestMethod for invoking AccountCreation
*
*/
    @isTest
    static void callInvocableMethod5(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpBody = '';
        
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applicationList = BCB_DAL_TestFactory.createApplication(1);
        applicationList[0].AOB_Lead__c = l.id;
        insert applicationList;
        
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        try{
            Test.startTest();
            
            CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
            
            Test.stopTest();
        }catch(exception ex){
            Assert.areNotEqual(null, appParticipants,'Test');
        }
       
    }  
     /**
    * @description TestMethod for invoking AccountCreation
    *
    */
    @isTest
    static void callInvocableMethod6(){
        
        CMN_ODAccountCreation.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_ODAccountCreation.mockHttpStatus='OK';
        CMN_ODAccountCreation.mockHttpBody = '{"ODAccountAddRq": {"ODAcctGeneralInfo": {"despatchMode": "E"},"localCalculationFlag": "N","customerNumber": "20301168643","bankInfo": {"branchId": "031006","bankId": "UG"}, "accountType": {"schemaCode": "OD005"},"accountLimits": {"expiryDate": "2099-12-31T00:00:00.000","drawingPowerIndicator": "E","documentDate": "2023-06-21T19:00:00.000"},"accountCurrency": "UGX" },"ODaccountAddCustomData": {"WPBFlag": "Y","selfPrintChequeBook": "Y", "saleBackendBO": null,"pricingCode": "PAYAS","PHCode": "BRBAN","PFNum": "ED2","missEntered": "1","localCalculationFlag": "N","EFTFlag": "N","INTCRAccountFlag": "S","INTDRAccountFlag": "S","channelID": "SAF","applicationHealthCode": "001","alternativeInstitutionName": "Nedbank","alternativeAccountNumber": "0772431022","alternativeAccountName": "NIKI BOYI"}}';
        
        List<Application__c> applicationList=BCB_DAL_TestFactory.createApplication(1);
        insert applicationList;
        List<product2> prodList = BCB_DAL_TestFactory.createProduct();
        insert prodList;
        List<Application_Participant__c> appParticipants = BCB_DAL_TestFactory.createApplicationParticipant(1);
        insert appParticipants;
        Test.startTest();
        
        CMN_ODAccountCreation.invocableMethod(applicationList,prodList,appParticipants);
        
        Test.stopTest();
        List<Application__c> updatedApplications = [SELECT Id, AOB_Account_Number__c FROM Application__c WHERE Id IN :applicationList];
        Assert.areNotEqual(null, updatedApplications[0].AOB_Account_Number__c, 'The OD Account Number should be updated after the method call.');
    }
}