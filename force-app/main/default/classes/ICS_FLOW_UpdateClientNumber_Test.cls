/**
 * @description Test Class for ICS_FLOW_UpdateClientNumber
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_FLOW_UpdateClientNumber_Test {
     
    /**
    * @description  Content Version record type for ICS Onboarding
    */     
    private static final Id CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('ICS_Onboarding_Document').getRecordTypeId();
    
    @TestSetup
    private static void setup() {

      	Account testAccount = ICS_TestDataFactory.createAccount();
        Opportunity testOpportunity = ICS_TestDataFactory.createOpportunity(testAccount.Id);
        testOpportunity.StageName = 'New';
        update testOpportunity;
        ApplicationForm testApplicationForm = ICS_TestDataFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        PartyProfile testPartyProfile = ICS_TestDataFactory.createPartyProfile(testAccount.Id);
        Applicant testApplicant = ICS_TestDataFactory.createApplicant(testAccount.Id, testApplicationForm.ID, testPartyProfile.ID);
        testApplicant.FirstName = testAccount.FirstName;
        testApplicant.LastName = testAccount.LastName;
        update testApplicant;
        ContentVersion testContentVersion = new ContentVersion();
        testContentVersion.RecordTypeId = CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT;
        testContentVersion.VersionData = Blob.valueOf('ProofOfLoan Text Contents');
        testContentVersion.Title = 'John-Johns-ProofofLoan-1';
        
        testContentVersion.PathOnClient = 'John-Johns-ProofofLoan-1.txt';
        testContentVersion.DocumentDate__c = Date.today();
        insert testContentVersion;

        ContentDocumentLink testContentDocumentLink = new ContentDocumentLink();
        testContentDocumentLink.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id =: testContentVersion.Id
        ].ContentDocumentId;
        testContentDocumentLink.LinkedEntityId = testPartyProfile.Id;
        testContentDocumentLink.ShareType = 'I';
        insert testContentDocumentLink;
    }

    @isTest
    static void testUpdateClientNumber() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        ICS_FLOW_UpdateClientNumber.Requests testRequests = new ICS_FLOW_UpdateClientNumber.Requests();
        testRequests.accountId = testAccount.Id;
       	testRequests.clientNumber = '123456';
        List<ICS_FLOW_UpdateClientNumber.Requests> testRequestsList = new List<ICS_FLOW_UpdateClientNumber.Requests>();
        testRequestsList.add(testRequests);
		List<ID> responseDSXList = new List<ID>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.UpdateMockResponse());
        responseDSXList = ICS_FLOW_UpdateClientNumber.invokeUpdateClientNumber(testRequestsList);
     	Id jobInfo = [SELECT ID FROM AsyncApexJob WHERE Id=:responseDSXList[0]].Id;
     	Test.stopTest();
        
        Assert.areEqual(jobInfo, responseDSXList[0], 'Job is added to the queue');


    }
     
        @isTest
    static void testUpdateClientNumberFail() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        ICS_FLOW_UpdateClientNumber.Requests testRequests = new ICS_FLOW_UpdateClientNumber.Requests();
        testRequests.accountId = testAccount.Id;
       	testRequests.clientNumber = '123456';
        List<ICS_FLOW_UpdateClientNumber.Requests> testRequestsList = new List<ICS_FLOW_UpdateClientNumber.Requests>();
        testRequestsList.add(testRequests);
		List<ID> responseDSXList = new List<ID>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        responseDSXList = ICS_FLOW_UpdateClientNumber.invokeUpdateClientNumber(testRequestsList);
     	Id jobInfo = [SELECT ID FROM AsyncApexJob WHERE Id=:responseDSXList[0]].Id;
     	Test.stopTest();
        
        Assert.areEqual(jobInfo, responseDSXList[0], 'Job is added to the queue');

    }


}