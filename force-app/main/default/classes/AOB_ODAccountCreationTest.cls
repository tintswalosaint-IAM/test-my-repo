/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_Customer
@ Description       : Test class for AOB_ODAccountCreation
@ Last Modified By  :Jagadish Thummala.
@ Last Modified On  :15/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
/** 
*@description Test class for AOB_ODAccountCreation
*/
@isTest
public class AOB_ODAccountCreationTest {
     /** 
     *@description TestMethod for Success Response
     */
    @isTest static void testSuccessResponseState(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        appList[0].WI_ClientType__c = 'Staff Assist';
        appList[0].AOB_Account_Number__c =null;
        insert appList;  
        string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
        AOB_ODAccountCreation.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_ODAccountCreation.mockHttpStatus ='OK';
        AOB_ODAccountCreation.mockHttpBody = mockResponse;
        Test.startTest();
        String resultList =AOB_ODAccountCreation.invokeAccountCreation(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        Assert.AreEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
    /** 
     *@description TestMethod for Success Response State
     */
    @isTest static void testSuccessResponseStateSelfAssist(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        appList[0].AOB_Account_Number__c =null;
        insert appList;  
        string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
        AOB_ODAccountCreation.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_ODAccountCreation.mockHttpStatus ='OK';
        AOB_ODAccountCreation.mockHttpBody = mockResponse;
        Test.startTest();
        String resultList =AOB_ODAccountCreation.invokeAccountCreation(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        Assert.AreEqual((String)m.get('status'), 'SUCCESS', 'It will return status'); 
    }
    /** 
     *@description TestMethod for  InternalServerErrorState
     */
    @isTest static void testInternalServerErrorState(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        appList[0].WI_ClientType__c = 'Staff Assist';
        appList[0].AOB_Account_Number__c = null;
        insert appList;  
        string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
        AOB_ODAccountCreation.mockHttpStatusCode =CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_ODAccountCreation.mockHttpStatus ='OK';
        AOB_ODAccountCreation.mockHttpBody = mockResponse;
        Test.startTest();
        String resultList =AOB_ODAccountCreation.invokeAccountCreation(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        Assert.AreEqual((String)m.get('status'), 'FAILED', 'It will return status');
    }
    /** 
     *@description TestMethod to cover the No content response
     */
     @isTest static void testNoContentState(){
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        appList[0].WI_ClientType__c = 'Staff Assist';
        appList[0].AOB_Account_Number__c = null;
        insert appList;  
        string mockResponse = '{"ODAccountAddRes":{"ODaccountNumber":{"accountNumber":"9030020820453","accountType":{"schemaCode":{},"schemaType":{}},"accountCurrency":{},"bankInfo":{"bankId":{},"name":{},"branchId":{},"branchName":{},"postalAddress":{"line1":{},"line2":{},"line3":{},"city":{},"stateProvince":{},"postalCode":{},"country":{},"addressType":{}}}}}}';
        AOB_ODAccountCreation.mockHttpStatusCode =CMN_API_HttpBase.HTTP_OK;
        AOB_ODAccountCreation.mockHttpStatus ='OK';
        AOB_ODAccountCreation.mockHttpBody = mockResponse;
        Test.startTest();
        String resultList =AOB_ODAccountCreation.invokeAccountCreation(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        Assert.AreEqual((String)m.get('status'), 'SUCCESS', 'It will return status');
    }
     
}