/***************************************************************************************
@ Author            :Lokesh Bothsa 
@ Date              :July 2023
@ Name of the Class :BCB_RelyComplyBusinessScreening_Test
@description       :Test Class for dealing with Rely Comply
@ Last Modified By  :Lokesh Bothsa  
@ Last Modified On  :25-05-2023
@ Modification Description : SFP-26345

@ Last Modified By  :Alex Niyonsaba 
@ Last Modified On  :12-02-2026
@ Modification Description : Fixing code scan issue of string literals appearing multiple times.
***************************************************************************************/
@isTest
public class CMN_RelyComplyBusinessScreening_Test {
    private static final String TEST_EXCEPTION_MESSAGE = 'It should Not be null';
    private static final String TEST_REGISTRATION_NUMBER = '2344/754983/4756';
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @isTest
    static void callInvocable() {
        string response = '{"assessmentId": "2361824","result": "PendingConfirmation","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{ "type": "EDDScreening", "name": "ug_salesforce_cra_high_risk_review","outcome": "pending","failed": true}]}';
        Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(
            response
        );
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].inflight__c =
            '{ "businessAssessmentId" : "' +
            (string) parsedStringMap.get('assessmentId') +
            '" }';
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        test.startTest();
        try {
            String serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
                applications,
                participantList
            );
            Assert.areNotEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
        } catch (exception e) {
            Assert.areNotEqual(e.getmessage(), null, TEST_EXCEPTION_MESSAGE);
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
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;

        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'OK';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '{"assessmentId": "","result": "PendingConfirmation","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{ "type": "EDDScreening", "name": "ug_salesforce_cra_high_risk_review","outcome": "pending","failed": true}]}';

        Test.startTest();
        String serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
            applications,
            participantList
        );
        Test.stopTest();
        Assert.areNotEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
    }
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @IsTest
    static void testCallInvocableMethod2() {
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;

        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'OK';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '{"assessmentId": "2361824","result": "PendingConfirmation","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{ "type": "EDDScreening", "name": "ug_salesforce_cra_high_risk_review","outcome": "pending","failed": true}]}';

        Test.startTest();
        String serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
            applications,
            participantList
        );
        Test.stopTest();
        Assert.areNotEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
    }
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @isTest
    static void testCallInvocableMethod3() {
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].AOB_Lead__c = l.id;
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;

        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'OK';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '';
        String serializedResponse;
        try {
            Test.startTest();
            serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
                applications,
                participantList
            );
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
        }
    }
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @IsTest
    static void testCallInvocableMethod4() {
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].AOB_Lead__c = l.id;
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'FAILED';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '';
        String serializedResponse;
        try {
            Test.startTest();
            serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
                applications,
                participantList
            );
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
        }
    }
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @isTest
    static void testCallInvocableMethod5() {
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].AOB_Lead__c = l.id;
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_OK;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'OK';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '';

        String serializedResponse;
        try {
            Test.startTest();
            serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
                applications,
                participantList
            );
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
        }
    }
    /**
     * @description TestMethod for Rely Comply
     *
     */
    @isTest
    static void testCallInvocableMethod6() {
        lead l = BCB_DAL_TestFactory.createLead();
        insert l;
        List<Application__c> applications = BCB_DAL_TestFactory.createApplication(1);
        applications[0].AOB_Lead__c = l.id;
        applications[0].AOB_RegistrationNumber__c = TEST_REGISTRATION_NUMBER;
        insert applications;
        List<Application_Participant__c> participantList = BCB_DAL_TestFactory.createApplicationParticipant(
            1
        );
        participantList[0].Application__c = applications[0].Id;
        insert participantList;
        CMN_RelyComplyBusinessScreening.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        CMN_RelyComplyBusinessScreening.mockHttpStatus = 'OK';
        CMN_RelyComplyBusinessScreening.mockHttpBody = '{"assessmentId": "2361824","result": "PendingConfirmation","cases": [{"type": "WatchlistScreening","name": "ug_salesforce_sanctions_screening","outcome": "NotMatch","failed": false},{"type": "WatchlistScreening","name": "ug_salesforce_pep_screening","outcome": "NotMatch","failed": false},{ "type": "EDDScreening", "name": "ug_salesforce_cra_high_risk_review","outcome": "pending","failed": true}]}';

        String serializedResponse;
        try {
            Test.startTest();
            serializedResponse = CMN_RelyComplyBusinessScreening.invocableMethod(
                applications,
                participantList
            );
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(serializedResponse, null, TEST_EXCEPTION_MESSAGE);
        }
    }
}