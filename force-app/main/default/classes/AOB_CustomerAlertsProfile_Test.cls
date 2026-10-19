/***************************************************************************************
@ Author            :AmarNath Reddy
@ Date              :May 2022
@ Name of the Class :AOB_CustomerAlertsProfile_Test
@description        :test Class for AOB_CustomerAlertsProfile
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :29-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
@isTest
public class AOB_CustomerAlertsProfile_Test {
    /**
    * @description TestMethod to check when the internal server Error Response
    */   
    @isTest
    static void testFailedStateNull(){  
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        insert appList;
        AOB_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerAlertsProfile.mockHttpStatus='OK';
        AOB_CustomerAlertsProfile.mockHttpbody=null; 
        test.startTest();
        String repStatus = AOB_CustomerAlertsProfile.invokeAlertsProfile(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        test.stopTest();
       Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');
    }
     /**
    * @description TestMethod to check the Success Response
    */
        @istest static void testsuccessResponse(){  
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        String str = '{"Status":"S000000001","Description":"Record Added Successfully","ErrorDescription":"true"}';
        AOB_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerAlertsProfile.mockHttpStatus='OK';
        AOB_CustomerAlertsProfile.mockHttpbody=str; 
        Test.startTest();
        String repStatus1 =AOB_CustomerAlertsProfile.invokeAlertsProfile(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus1);
        test.stopTest();
       Assert.areEqual(m.size(), 3, 'It will return status');
             
     }
      /**
    * @description TestMethod to check the Failed Response
    */
        @istest static void testFailedState(){  
        List<Application__c> appList=AOB_TestDataFactory.createApplication(1);
        String str = '{"Status":"S000000001","Description":"Record Added Successfully"}';
        AOB_CustomerAlertsProfile.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerAlertsProfile.mockHttpStatus='OK';
        AOB_CustomerAlertsProfile.mockHttpbody=str; 
        Test.startTest();
        String repStatus1 =AOB_CustomerAlertsProfile.invokeAlertsProfile(appList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus1);
        test.stopTest();
       Assert.areEqual((String)m.get('status'), 'FAILED', 'It will return status');
             
     }
}