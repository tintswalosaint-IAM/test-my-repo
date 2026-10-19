/**
 * @description       : 
 * @author            : jagadish Thummala
 * @group             : 
 * @last modified on  : 11-03-2025
 * @last modified by  : jagadish Thummala
**/
@isTest
public with sharing class AOBCreateCIF_TEST {
   
 /** 
     *@description TestMethod for AOBCreateCIF to cover the success response
     */
	 @istest static void testSuccessResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= null;
        insert lstApp; 
        String str='{"CustId":"10302196858","Status":"SUCCESS","Description":"Retail Customer successfully created with CIFID 10302196858"}';
        AOBCreateCIF.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOBCreateCIF.mockHttpStatus ='OK';
        AOBCreateCIF.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOBCreateCIF.invokeCustomerCreate(lstApp[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('Status'), 'SUCCESS', 'It will return status'); 
    }
    /** 
     *@description TestMethod for AOBCreateCIF to cover the FAILED response
     */
     @istest static void testFailedResponse(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= '';
        insert lstApp;   
        AOBCreateCIF.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOBCreateCIF.mockHttpStatus ='OK';
        AOBCreateCIF.mockHttpBody = '';
        Test.startTest();
        String repStatus = AOBCreateCIF.invokeCustomerCreate(lstApp[0]);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');  
    }
    
}