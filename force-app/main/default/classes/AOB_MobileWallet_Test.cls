/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_MobileWallet_Test
@ Description       :Class for dealing Mobile Funding
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :3/14/2024.
@ Modification Description : SFP-28286
***************************************************************************************/
/**
*  @description Test Class for dealing Mobile Funding
*/
@isTest
public class AOB_MobileWallet_Test {
    /**
     *  @description This method used to test the success response
     */
    @istest static void testSuccessResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}'; 
        AOB_MobileWallet.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileWallet.mockHttpStatus='OK';
        AOB_MobileWallet.mockHttpBody=str;
        Test.startTest();
        String repStatus = AOB_MobileWallet.invokeWalletFunding(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
         Assert.areEqual((string)m.get('statusCode'), '01', 'It will check status'); 
    }
    /**
     *  @description This method used to test the server error response
     */
    @istest static void testServerError(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"100000034903","payerTransactionId":"100000034903","collectionTime":"","confirmationTime":"2022-08-11 09:14:57","status":"Pending","statusCode":"01"}';
        AOB_MobileWallet.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_MobileWallet.mockHttpStatus='OK';
        AOB_MobileWallet.mockHttpBody=str;
        Test.startTest();
        String repStatus = AOB_MobileWallet.invokeWalletFunding(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
         Assert.areEqual((Integer)m.get('statusCode'), 500, 'It will check status');
    }
    /**
     *  @description This method used to test server error and null response
     */
    @istest static void testNullBody(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        AOB_MobileWallet.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_MobileWallet.mockHttpStatus='OK';
        AOB_MobileWallet.mockHttpBody= null;
        Test.startTest();
        String repStatus = AOB_MobileWallet.invokeWalletFunding(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
         Assert.areEqual((integer)m.get('statusCode'), 500, 'It will check status');
    }
    /**
     *  @description This method used to test the failed response
     */
    @istest static void testFailedResponse(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        AOB_MobileWallet.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileWallet.mockHttpStatus='OK';
        AOB_MobileWallet.mockHttpBody= null;
        Test.startTest();
        String repStatus = AOB_MobileWallet.invokeWalletFunding(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
         Assert.areEqual(Integer.valueOf(m.get('statusCode')), 204, 'It will check status');
    }
}