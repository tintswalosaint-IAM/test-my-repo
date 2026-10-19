/**
* @description TestClass for AOB_BOTS_CTRL_Identifii_Applicant
* @author Nagendraprasad Mylavarapu
* @date Feb 15th, 2023
*/
@isTest
public class AOB_IdentifiiApplicant_TEST {
    
  /**
* @description Test data for AOB_BOTS_CTRL_Identifii_Applicant.getAuthToken
*/
    @isTest static void getAuthTokenTest() {
        Application__c applicationRecord = AOB_BOTS_TestDataFactory.createApplication();
        insert applicationRecord; 

        Map<String, Object> inflightDataMap = new Map<String, Object>();
        inflightDataMap.put('OmangId', 'ABC12345');
        inflightDataMap.put('FullName', 'ABC12345');
        inflightDataMap.put('CIPA REGISTRATION NUMBER', '12345');
        inflightDataMap.put('EMAIL ADDRESS', 'xyz@test.com');

        Application_Participant__c participantRecord = AOB_BOTS_TestDataFactory.createApplicationParticipant(applicationRecord.Id, JSON.serialize(inflightDataMap));
        insert participantRecord;

        Test.startTest();
        String repStatus = AOB_IdentifiiApplicant.getAuthToken(new List<Application_Participant__c>{participantRecord});
        Test.stopTest();

        Map<String, Object> rep = (Map<String, Object>) JSON.deserializeUntyped(repStatus);
        Assert.areEqual((String)rep.get('status'), 'Success', 'Status Check against the response');
    }
/**
* @description Test data for AOB_BOTS_CTRL_Identifii_Applicant.createApplicationParticipant
*/
    @isTest static void invokeIdentifiiCalloutTestException() {
        Application__c applicationRecord = AOB_BOTS_TestDataFactory.createApplication();
        insert applicationRecord; 

        Map<String, Object> inflightDataMap = new Map<String, Object>();
        inflightDataMap.put('OmangId', 'ABC12345');
        inflightDataMap.put('FullName', 'ABC12345');
        inflightDataMap.put('CIPA REGISTRATION NUMBER', '12345');
        inflightDataMap.put('EMAIL ADDRESS', 'xyz@test.com');

        Application_Participant__c participantRecord = AOB_BOTS_TestDataFactory.createApplicationParticipant(applicationRecord.Id, JSON.serialize(inflightDataMap));
        insert participantRecord;

        AOB_AccessTokenGenerator.mockHttpStatusCode = CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;
        AOB_AccessTokenGenerator.mockHttpStatus = 'OK';
        AOB_AccessTokenGenerator.mockHttpbody = '';

        Test.startTest();
        try {
            String repStatus = AOB_IdentifiiApplicant.getAuthToken(new List<Application_Participant__c>{participantRecord});
        } catch(Exception e) {
            System.assert(e.getMessage().contains('Attempt to de-reference a null object'), 'Exception Handling Check');
        }        
        Test.stopTest();
    }
/**
* @description Test data for AOB_BOTS_CTRL_Identifii_Applicant.getUploadedDocuments
*/
    @isTest static void invokeIdentifiiGETDocumentsCalloutTest() {
        Application__c applicationRecord = AOB_BOTS_TestDataFactory.createApplication();
        insert applicationRecord; 
        Map<String, Object> inflightDataMap = new Map<String, Object>();
        inflightDataMap.put('OmangId', 'ABC12345');
        inflightDataMap.put('FullName', 'ABC12345');
        inflightDataMap.put('CIPA REGISTRATION NUMBER', '12345');
        inflightDataMap.put('EMAIL ADDRESS', 'xyz@test.com');

        Application_Participant__c participantRecord = AOB_BOTS_TestDataFactory.createApplicationParticipant(applicationRecord.Id, JSON.serialize(inflightDataMap));
        insert participantRecord;

        Test.startTest();
        String repStatus = AOB_IdentifiiApplicant.getUploadedDocuments(new List<Application_Participant__c>{participantRecord}, 'testrecordid');
        Test.stopTest();

        AOB_Identify_BodyBean.Response responseMap = (AOB_Identify_BodyBean.Response) JSON.deserialize(repStatus, AOB_Identify_BodyBean.Response.class);
        Assert.areEqual(responseMap.IdentityImages.isEmpty(), false, 'Size Check against the Images');

    }
}