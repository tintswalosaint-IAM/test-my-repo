/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_FlowController
@ Description       :Test class to cover for  Mobile Fund Status
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :3/14/2024.
@ Modification Description : SFP-28286
***************************************************************************************/
/**
 * @description Test class to cover for  Mobile Fund Status
 * 
*/
@isTest
public class AOB_MobileWalletStatus_Test {
    /**
    * @description callout method for success 
    * 
    */
    @istest static void testSuccessResponse(){    
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"SUCCESS","statusCode":"57"}';
        AOB_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileWalletStatus.mockHttpStatus='OK';
        AOB_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        String repStatus = AOB_MobileWalletStatus.invokeWalletStatus(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'SUCCESS','It should be success');
    }
    /**
    * @description callout method for failed response
    * 
    */
    @istest static void testFailedResponse(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"FAILED","statusCode":"57"}';
        AOB_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_MobileWalletStatus.mockHttpStatus='OK';
        AOB_MobileWalletStatus.mockHttpbody=str;
        Test.startTest();
        String repStatus = AOB_MobileWalletStatus.invokeWalletStatus(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areNotEqual(m.size(), 0, 'It should have error response');
    }
     /**
    * @description callout method for failed response due to no content
    * 
    */
    @istest static void testFailedResponseNoContent(){    
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        String str='{"sessionNumber":"","transactionReference":"","aggregatorReference":"","payerTransactionId":"","collectionTime":"","confirmationTime":"2022-08-11 09:18:40","status":"FAILED","statusCode":"57"}';
        AOB_MobileWalletStatus.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_MobileWalletStatus.mockHttpStatus='OK';
        AOB_MobileWalletStatus.mockHttpbody=null;
        Test.startTest();
        String repStatus = AOB_MobileWalletStatus.invokeWalletStatus(lstApp, str);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest();
        Assert.areEqual((String)m.get('ErrorDescription'), 'No response body');
    }
}