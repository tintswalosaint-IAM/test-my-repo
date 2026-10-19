/**
 * @description Test Class for ICS_FLOW_StoreDocuments
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_FLOW_StoreDocuments_Test {
     
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
        testContentVersion.DocumentType__c = 'CRA Report';
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
    static void testStoreDocuments() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        ContentDocumentLink link = [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.id];
        ContentVersion contentVersion = [SELECT Id, DocumentType__c, DocumentDate__c, Title, FileExtension, VersionData, ContentDocumentId 
                                         FROM ContentVersion WHERE ContentDocumentId=: link.ContentDocumentId AND Islatest = TRUE];
        
		ICS_FLOW_StoreDocuments.Requests testRequests = new ICS_FLOW_StoreDocuments.Requests();
       	testRequests.linkedEntityIds = testPartyProfile.id;
       	testRequests.contentVersion = contentVersion;
        List<ICS_FLOW_StoreDocuments.Requests> testRequestsList = new List<ICS_FLOW_StoreDocuments.Requests>();
        testRequestsList.add(testRequests);

        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.StoreDocumentMockResponse());
        ICS_FLOW_StoreDocuments.invokeStoreDocuments(testRequestsList);
     	Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM ContentVersion], 'Document stored in DSX');

    }
     
        @isTest
    static void testStoreDocumentsFail() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        ContentDocumentLink link = [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.id];
        ContentVersion contentVersion = [SELECT Id, DocumentType__c, DocumentDate__c, Title, FileExtension, VersionData, ContentDocumentId 
                                         FROM ContentVersion WHERE ContentDocumentId=: link.ContentDocumentId AND Islatest = TRUE];
        
        ICS_FLOW_StoreDocuments.Requests testRequests = new ICS_FLOW_StoreDocuments.Requests();
       	testRequests.linkedEntityIds = testPartyProfile.id;
       	testRequests.contentVersion = contentVersion;
        List<ICS_FLOW_StoreDocuments.Requests> testRequestsList = new List<ICS_FLOW_StoreDocuments.Requests>();
        testRequestsList.add(testRequests);
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        ICS_FLOW_StoreDocuments.invokeStoreDocuments(testRequestsList);
     	Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion], 'Document store failed');

    }


}