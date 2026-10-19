/***************************************************************************************
@ Author            :Jagadish Thummala.
@ Date              :July 2024
@ Name of the Class :AOB_RelyComply_FetchAssessment
@ Description       : This class is used to cover the AOB_RelyComply_FetchAssessment class 
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :22/07/2024.
@ Modification Description : SFP-40417
***************************************************************************************/
@IsTest
public with sharing class AOB_RelyComply_FetchAssessment_Test {
   
     /**
    * @description TestMethod to check the Positive Response
    */
    @istest static void testMethodPositiveResponse(){  
       
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        string assessmentId = '2361825';
        AOB_RelyComply_FetchAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_FetchAssessment.mockHttpStatus='OK';
        AOB_RelyComply_FetchAssessment.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_RelyComply_FetchAssessment.invokeFetchAssessmentCallout(lstApp,assessmentId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual('SUCCESS', (String)m.get('status'), 'The status should be SUCCESS');
    }
    @istest static void testMethodPositiveResponse1(){  
       
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string assessmentId = '';
        AOB_RelyComply_FetchAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_FetchAssessment.mockHttpStatus='OK';
        AOB_RelyComply_FetchAssessment.mockHttpBody='';
        Test.startTest();
        String repStatus = AOB_RelyComply_FetchAssessment.invokeFetchAssessmentCallout(lstApp,assessmentId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual('NO_CONTENT', (String)m.get('status'), 'The status should be SUCCESS');
    }
      /**
    * @description TestMethod to check the Negative Response
    */
    @istest static void testMethodNegativeResponse(){  
       
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        string response = '{"httpCode": 401, "httpMessage": "Unauthorized","moreInformation": "Signature Validation Failed"}';
        string assessmentId = '2361825';
        AOB_RelyComply_FetchAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_UNAUTHORISED;
        AOB_RelyComply_FetchAssessment.mockHttpStatus='OK';
        AOB_RelyComply_FetchAssessment.mockHttpBody=response;
        Test.startTest();
        String repStatus = AOB_RelyComply_FetchAssessment.invokeFetchAssessmentCallout(lstApp,assessmentId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual('FAILED', (String)m.get('status'), 'The status should be FAILED');
    }
       /**
    * @description TestMethod to check the No Response Body
    */
    @istest static void testMethodNoResponse(){  
        string assessmentId = '2361825';
		List<Application__c> lstApp = AOB_TestDataFactory.createApplication(1);
        insert lstApp;
        AOB_RelyComply_FetchAssessment.mockHttpStatusCode=CMN_API_HttpBase.HTTP_OK;
        AOB_RelyComply_FetchAssessment.mockHttpStatus='OK';
        AOB_RelyComply_FetchAssessment.mockHttpBody='';
        Test.startTest();
        String repStatus = AOB_RelyComply_FetchAssessment.invokeFetchAssessmentCallout(lstApp,assessmentId);
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Test.stopTest(); 
        Assert.areEqual((String)m.get('status'),'NO_CONTENT', 'The status should be FAILED');
    }
}