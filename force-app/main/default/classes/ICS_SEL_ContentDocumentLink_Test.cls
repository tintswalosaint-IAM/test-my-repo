/**
 * @description Test Class for ICS_SEL_ContentDocumentLink
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_SEL_ContentDocumentLink_Test {
     
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
    static void testContentDocumentLinksById() {
        
		PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        ContentDocumentLink testContentDocumentLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.Id];
       
        
        Test.startTest();
        ICS_SEL_ContentDocumentLink selectContentDocumentLink = new ICS_SEL_ContentDocumentLink ();
        List<ContentDocumentLink> contentDocumentLinks = selectContentDocumentLink.getContentDocumentLinks(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(contentDocumentLinks[0].Id, testContentDocumentLink.Id,'Content Document Link retrieved');
        Assert.areEqual(contentDocumentLinks[0].LinkedEntityId, testPartyProfile.Id,'Content Document Link retrieved');
    }
    
      @isTest
    static void testContentDocumentLinksByIdSet() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        ContentDocumentLink testContentDocumentLink = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.Id];
        Set<Id> testPartyProfileIds = new Set<Id>{testPartyProfile.Id};

        Test.startTest();
        ICS_SEL_ContentDocumentLink selectContentDocumentLink = new ICS_SEL_ContentDocumentLink ();
        List<ContentDocumentLink> contentDocumentLinks = selectContentDocumentLink.selectContentDocumentLinks(testPartyProfileIds);
        Test.stopTest();
        Assert.areEqual(contentDocumentLinks[0].Id, testContentDocumentLink.Id,'Content Document Link retrieved');
        Assert.areEqual(contentDocumentLinks[0].LinkedEntityId, testPartyProfile.Id,'Content Document Link retrieved');

    }
  
}