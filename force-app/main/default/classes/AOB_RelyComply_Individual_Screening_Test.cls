/***************************************************************************************
@ Author            :Jagadish Thummala.
@ Date              :July 2024
@ Name of the Class :AOB_RelyComply_Individual_Screening_Test
@ Description       : Test class to cover AOB_RelyComply_Individual_Screening
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :22/07/2024.
@ Modification Description : SFP-40417
***************************************************************************************/
@isTest
public with sharing class AOB_RelyComply_Individual_Screening_Test {
     /**
    * @description TestMethod to check the Positive Response
    */
    @istest static void testMethodPositiveResponse(){  
       
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        AOB_RelyComply_Individual_Screening.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_Individual_Screening.mockHttpStatus='OK';
        AOB_RelyComply_Individual_Screening.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_RelyComply_Individual_Screening.invokeRelyComplyScreening(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'SUCCESS', 'The status should be SUCCESS');
    }
      /**
    * @description TestMethod to check the Negative Response
    */
    @istest static void testMethodNegativeResponse(){  
       
        List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"httpCode": 401, "httpMessage": "Unauthorized","moreInformation": "Signature Validation Failed"}';
        AOB_RelyComply_Individual_Screening.mockHttpStatusCode=CMN_API_HttpBase.HTTP_UNAUTHORISED;
        AOB_RelyComply_Individual_Screening.mockHttpStatus='OK';
        AOB_RelyComply_Individual_Screening.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_RelyComply_Individual_Screening.invokeRelyComplyScreening(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'FAILED', 'The status should be FAILED');
    }
       /**
    * @description TestMethod to check the No Response Body
    */
    @istest static void testMethodNoResponse(){  
       
      List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
      insert lstApp;
        AOB_RelyComply_Individual_Screening.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_Individual_Screening.mockHttpStatus='OK';
        AOB_RelyComply_Individual_Screening.mockHttpBody='';
        Test.startTest();
        String repStatus = AOB_RelyComply_Individual_Screening.invokeRelyComplyScreening(lstApp);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'), 'NO_CONTENT', 'Expected no content in the response body');
    }
}