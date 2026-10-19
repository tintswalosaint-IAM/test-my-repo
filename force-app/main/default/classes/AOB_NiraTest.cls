/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_NIRATest
@ Description       :Test class for AOB_Nira
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
* @description Test class for AOB_Nira
*
*/
@isTest
public class AOB_NiraTest {   
    /**
    * @description TestMethod to check the verification List 
    *
    */
    @istest static void niraApiCalloutTest(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
        AOB_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_NIRA.mockHttpStatus='OK';
        AOB_NIRA.mockHttpBody=str;
        Test.startTest();
        AOB_NIRA.invokeNiraCallout(applicationList);
        Test.stopTest();
        List<Verification__c> verificationList=[SELECT Id FROM Verification__c];
        Assert.areEqual(1,verificationList.size(), 'It will check status');
       
    }
    /**
    * @description TestMethod to check the negative scenario of failing status
    *
    */   
    @istest static void niraApiCalloutTestNegative(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"false","cardStatus":"Valid"}}}';
        AOB_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_NIRA.mockHttpStatus='OK';
        AOB_NIRA.mockHttpBody=str;
        Test.startTest();
        String resultList=AOB_NIRA.invokeNiraCallout(applicationList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
       
        Assert.areEqual((String)m.get('status'), 'FAILED', 'It will check status');
       
    }
    /**
    * @description TestMethod to check the matchingStatus
    *
    */
    @istest static void niraApiCalloutStatusTest(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        String str ='{"verifyPersonInformationResponse":{"return":{"transactionStatus":{"transactionStatus":"Ok","passwordDaysLeft":"42","executionCost":"0.0"},"matchingStatus":"true","cardStatus":"Valid"}}}';
        AOB_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_NIRA.mockHttpStatus='OK';
        AOB_NIRA.mockHttpBody=str;
        Test.startTest();
        String resultList=AOB_NIRA.invokeNiraCallout(applicationList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        List<Verification__c> verificationList=[SELECT Id FROM Verification__c];
        Assert.areEqual(1,verificationList.size(), 'It will check status');
        Assert.areEqual((String)m.get('matchingStatus'), 'true', 'It will check status');
    }
    /**
    * @description TestMethod to check the negative status
    *
    */
    @istest static void niraApiCalloutStatusNegativeTest(){
        List<Application__c> applicationList=AOB_TestDataFactory.createApplication(1);
        insert applicationList; 
        AOB_NIRA.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_NIRA.mockHttpStatus='OK';
        AOB_NIRA.mockHttpBody=null;
        Test.startTest();
        String resultList=AOB_NIRA.invokeNiraCallout(applicationList);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(resultList);
        Test.stopTest();
        Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'It will check status');
    }
    @istest static void testException(){  
        Test.startTest();
        try {
            AOB_NIRA.invokeNiraCallout(null);
        } catch(Exception e) {
            Assert.areEqual('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();  
    }
}