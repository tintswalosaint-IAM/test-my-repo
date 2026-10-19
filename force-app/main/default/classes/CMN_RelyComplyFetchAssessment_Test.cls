/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :CMN_RelyComplyFetchAssessment_Test
@description       :Test Class for dealing with Rely Comply
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :25-05-2023
@Modification description : SFP-26345
***************************************************************************************/
@isTest
public class CMN_RelyComplyFetchAssessment_Test {
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @isTest
    static void callInvocable(){
        string response ='{"assessmentId": "2361823","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
         Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].Inflight__c = '{ "businessAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);  
        participantList[0].Application__c = applications[0].Id;
        participantList[0].Inflight__c = '{ "individualAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
        insert participantList;
        test.startTest();
        try{        
            String serializedResponse =CMN_RelyComplyFetchAssessment.invocableMethod(applications,participantList,'Uganda MVP2 Company Details');   
             Assert.areNotEqual(serializedResponse, null,'It should Not be null');         
        }catch(exception e){
             Assert.areNotEqual(e.getmessage(), null,'It should Not be null');
        }
        test.stopTest();
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @isTest
    static void testCallInvocableMethod1() {
               List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
         List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
   
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody ='{"assessmentId": "2361823","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';

        Test.startTest();
          String serializedResponse =CMN_RelyComplyFetchAssessment.invocableMethod(applications,participantList,'Uganda MVP2 Company Details');    
        Test.stopTest();
           Assert.areNotEqual(serializedResponse, null,'It should Not be null');         

        
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @IsTest
    static void testCallInvocableMethod2() {
         List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
         List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody ='{"assessmentId": "2361823","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
        
        Test.startTest();
                String serializedResponse =CMN_RelyComplyFetchAssessment.invocableMethod(applications,participantList,'Uganda MVP2 Company Details'); 
        Test.stopTest();  
                     Assert.areNotEqual(serializedResponse, null,'It should Not be null');         

    }

    /**
    * @description TestMethod for Rely Comply
    *
    */
     @isTest
    static void testCallInvocableMethod5() {
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode =  CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody = '';
        
       List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        Test.startTest();
        	String serializedResponse =CMN_RelyComplyFetchAssessment.invocableMethod(applications,participantList,'Uganda MVP2 Company Details'); 
        Test.stopTest(); 
          Assert.areNotEqual(serializedResponse, null,'It should Not be null');
    }
    
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @isTest
    static void testCallInvocableMethod7() {
       	List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        CMN_RelyComplyFetchAssessment.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComplyFetchAssessment.mockHttpStatus='OK';
        CMN_RelyComplyFetchAssessment.mockHttpBody = '{"assessmentId": "2361823","result": "AcceptableRisk","cases": [ {"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch", "failed": false},{ "type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk", "failed": false}]}';
        
        Test.startTest();
         String serializedResponse =CMN_RelyComplyFetchAssessment.invocableMethod(applications,participantList,'Uganda MVP2 Company Details'); 
        Test.stopTest();      
                     Assert.areNotEqual(serializedResponse, null,'It should Not be null');         

    }
}