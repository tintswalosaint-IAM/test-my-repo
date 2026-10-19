/**
 * @description       : 
 * @author            : jagadish Thummala
 * @group             : 
 * @last modified on  : 10-24-2025
 * @last modified by  : jagadish Thummala
**/
@isTest
public with sharing class AOB_Create_CIF_TEST {
   
 /** 
     *@description TestMethod for AOB_Create_CIF to cover the success response
     */
	 @istest static void testSuccessResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= null;
        insert lstApp; 
        String str='{"CustId":"10302196858","Status":"SUCCESS","Description":"Retail Customer successfully created with CIFID 10302196858"}';
        AOB_Create_CIF.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_Create_CIF.mockHttpStatus ='OK';
        AOB_Create_CIF.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOB_Create_CIF.invokeCustomerCreate(lstApp[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('Status'), 'SUCCESS', 'It will return status'); 
    }
    /** 
     *@description TestMethod for AOB_Create_CIF to cover the FAILED response
     */
     @istest static void testFailedResponse(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= '';
        insert lstApp;   
        AOB_Create_CIF.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_Create_CIF.mockHttpStatus ='OK';
        AOB_Create_CIF.mockHttpBody = '';
        Test.startTest();
        String repStatus = AOB_Create_CIF.invokeCustomerCreate(lstApp[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');  
    }
    
}