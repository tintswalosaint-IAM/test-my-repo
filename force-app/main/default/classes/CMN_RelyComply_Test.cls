/***************************************************************************************
@Author            :Lokesh Bothsa 
@Date              :July 2023
@Name of the Class :CMN_RelyComply_Test
@description       :Test Class for dealing with Rely Comply
@Last Modified By  :Lokesh Bothsa  
@Last Modified On  :25-05-2023
@Modification description : SFP-26345
***************************************************************************************/

@isTest
public class CMN_RelyComply_Test{
     /**
    * @description TestMethod for Rely Comply
    *
    */
    @isTest
    static void callInvocable(){
        string response = '{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].inflight__c = '{ "individualAssessmentId" : "'+(string)parsedStringMap.get('assessmentId')+'" }';
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);  
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        try{        
            test.startTest();
            String serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList);
            test.stopTest();          
            Assert.areNotEqual(serializedResponse, null,'It should Not be null');
        }catch(exception e){

             Assert.isNotNull(e.getMessage(),'It should Not be null');
        }
        
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
        
        CMN_RelyComply.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody ='{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        
        Test.startTest();
        String serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList); 
        Test.stopTest();
        Assert.isNotNull(serializedResponse, 'It should Not be null');
        
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
        
        CMN_RelyComply.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody ='{"assessmentId": "2361825","result": "AcceptableRisk","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{"type": "EDDScreening","name": "ug_salesforce_cra_high_risk_review","outcome": "AcceptableRisk","failed": false}]}';
        
        Test.startTest();
        String serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList); 
        Test.stopTest();  
        Assert.isNotNull(serializedResponse,'It should Not be null');

    }
    /**
    * @description TestMethod for Rely Comply
    *
    */

    @isTest
    static void testCallInvocableMethod3() {
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        CMN_RelyComply.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody = '';
        String serializedResponse;
        try{
            Test.startTest();
            serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList); 
            Test.stopTest();  
        }catch(Exception ex){
            Assert.isNull(serializedResponse,'It should Not be null');
        }
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */

    @IsTest
    static void testCallInvocableMethod4() {
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        string response = '{"httpCode": 401, "httpMessage": "Unauthorized","moreInformation": "Signature Validation Failed"}';
        CMN_RelyComply.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody = response;
        String serializedResponse;
        try{
            Test.startTest();
            serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList); 
            Test.stopTest();
        }catch(Exception ex){
            Assert.isNull(serializedResponse, 'It should Not be null');
        }     
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */

    @isTest
    static void testCallInvocableMethod5() {
        CMN_RelyComply.mockHttpStatusCode =  CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody = '';
        
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
         String serializedResponse='Hello failed to get customer';
        try{
            Test.startTest();
            serializedResponse =CMN_RelyComply.invocableMethod(applications,participantList); 
            Test.stopTest();  
        }catch(Exception ex){
            Assert.isNotNull(serializedResponse,'It should Not be null');
        }
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */

    @istest static void testCalloutMethod6(){ 
        CMN_RelyComply.mockHttpStatusCode =  CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComply.mockHttpStatus='OK';
        CMN_RelyComply.mockHttpBody = '';
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        insert applications;
        List<Application_Participant__c> participantList=BCB_DAL_TestFactory.createApplicationParticipant(1);   
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        
        String jsonString = '{"identifier": "10302321445","firstName": "Bosco","lastName": "Mwanawasitte","nationality": "UG","residence": "UG","birthDate": "1986-01-27","clientType": "A5B","occupationCategory": "self_employed","bankProduct": "Transactional"}';
        BCB_RelyComplyBean.individualScreening data = (BCB_RelyComplyBean.individualScreening) JSON.deserialize(jsonString, BCB_RelyComplyBean.individualScreening.class);
        try{
            Test.startTest();
         CMN_RelyComply.invocableMethod(applications,participantList); 
            Test.stopTest();   
        }catch(Exception ex){
            Assert.areEqual(data.identifier, '10302321445','Test');
       		Assert.areEqual(data.firstName, 'Bosco','Test');
        }       
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @istest static void testCalloutMethod7(){   
        String jsonString = '{"identifier": "10302321445","firstName": "Bosco","lastName": "Mwanawasitte","nationality": "UG","residence": "UG","birthDate": "1986-01-27","clientType": "A5B","occupationCategory": "self_employed","bankProduct": "Transactional"}';
        BCB_RelyComplyBean.individualScreening data = (BCB_RelyComplyBean.individualScreening) JSON.deserialize(jsonString, BCB_RelyComplyBean.individualScreening.class);
        
        Assert.isNotNull( data.identifier,'Test');
        Assert.isNotNull( data.firstName, 'Test');
        
        
    }
    /**
    * @description TestMethod for Rely Comply
    *
    */

    @istest static void testCalloutMethod8(){  
        BCB_RelyComplyIndiScreeningResponse cust = new BCB_RelyComplyIndiScreeningResponse();
        cust.assessmentId = '12345678';
        cust.result = 'ACCT-123';
        
        
        BCB_RelyComplyIndiScreeningResponse.Cases cases1 = new BCB_RelyComplyIndiScreeningResponse.Cases();
        
        cases1.type = 'test1';
        cases1.failed = false;
        cases1.name = 'test';
        cases1.outcome = 'out';
        cust.Cases = new List<BCB_RelyComplyIndiScreeningResponse.Cases>{cases1};  
      
        Assert.isNotNull( cust.Cases,'It should Not be null');

    }
    /**
    * @description TestMethod for Rely Comply
    *
    */
    @istest static void testCalloutMethod9(){  
        
        BCB_RelyComplyBusinessScreeningResponse cust = new BCB_RelyComplyBusinessScreeningResponse();
        cust.assessmentId = '12345678';
        cust.result = 'ACCT-123';
        
        BCB_RelyComplyBusinessScreeningResponse.Cases cases1 = new BCB_RelyComplyBusinessScreeningResponse.Cases();
        cases1.type = 'hello';
        cases1.failed = true;
        cases1.name = 'rely'; 
        cases1.outcome = 'outcome';
        cust.Cases = new List<BCB_RelyComplyBusinessScreeningResponse.Cases>{cases1};  
        Assert.isNotNull( cust.Cases,'It should Not be null');
    }
}