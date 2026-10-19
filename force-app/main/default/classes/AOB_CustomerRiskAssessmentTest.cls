/***************************************************************************************
@ Author            :Amarnath Reddy(amarnath.reddy@standardbank.co.za)
@ Date              :june 2022
@ Name of the Class :AOB_CustomerRiskAssessment
@ Description       :Test Class for AOB_CustomerRiskAssessmentTest.
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :20-03-2024
@ Modification Description : SFP-31036
***************************************************************************************/
/**
* @description Test Class for AOB_CustomerRiskAssessmentTest.
*/
@isTest
public class AOB_CustomerRiskAssessmentTest {
    /**
    * @description TestMethod to check the Positive Response
    */
    @istest static void testMethodPositiveResponse(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        List<Product2> products = AOB_TestDataFactory.createProduct();
        String str='{"RiskScoreStatus":"48.33","RiskScoreRating":"MEDIUM"}';
        AOB_CustomerRiskAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerRiskAssessment.mockHttpStatus='OK';
        AOB_CustomerRiskAssessment.mockHttpBody=str;
        Test.startTest();
        String repStatus = AOB_CustomerRiskAssessment.invokeRiskAssessment(lstApp,products);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'Success', 'It will return status');
    }
    /**
    * @description TestMethod to check the Negative Response
    */
    @istest static void testMethodServerError(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        List<Product2> products = AOB_TestDataFactory.createProduct();
        AOB_CustomerRiskAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_CustomerRiskAssessment.mockHttpStatus='OK';
        AOB_CustomerRiskAssessment.mockHttpBody=null;
        Test.startTest();
        String repStatus = AOB_CustomerRiskAssessment.invokeRiskAssessment(lstApp,products);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'Error', 'It will return status');
    }
    /**
    * @description TestMethod to check the Null Response
    */
    @istest static void testMethodNullBody(){     
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        lstApp[0].AOB_Nationality__c = 'UG';
        lstApp[0].AOB_PEP_Status__c  = 'ACTIVE';
        List<Product2> products = AOB_TestDataFactory.createProduct();
        AOB_CustomerRiskAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_CustomerRiskAssessment.mockHttpStatus='OK';
        AOB_CustomerRiskAssessment.mockHttpBody=null;
        Test.startTest();
        String repStatus = AOB_CustomerRiskAssessment.invokeRiskAssessment(lstApp,products);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'Error', 'It will return status');
    }
}