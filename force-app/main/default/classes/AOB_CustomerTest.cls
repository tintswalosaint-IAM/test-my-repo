/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :June 2022
@ Name of the Class :AOB_Customer
@ Description       : Test class for AOB_Customer
@ Last Modified By  :Jagadish Thummala.
@ Last Modified On  :15/02/2024.
@ Modification Description : SFP-31036
***************************************************************************************/
/** 
     *@description Test class for AOB_Customer
 */
@isTest
public class AOB_CustomerTest {
    /** 
     *@description TestMethod for AOB_Customer to cover the success response
     */
	 @istest static void testSuccessResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= null;
        insert lstApp; 
        String str='{"CustId":"10302196858","Status":"SUCCESS","Description":"Retail Customer successfully created with CIFID 10302196858"}';
        AOB_Customer.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_Customer.mockHttpStatus ='OK';
        AOB_Customer.mockHttpBody = str;
        Test.startTest();
        String repStatus = AOB_Customer.invokeCustomerCreate(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('Status'), 'SUCCESS', 'It will return status'); 
    }
    /** 
     *@description TestMethod for AOB_Customer to cover the FAILED response
     */
     @istest static void testFailedResponse(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Customer_Id__c= '';
        insert lstApp;   
        AOB_Customer.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_Customer.mockHttpStatus ='OK';
        AOB_Customer.mockHttpBody = '';
        Test.startTest();
        String repStatus = AOB_Customer.invokeCustomerCreate(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');  
    }
}