/**
 * @description Test Class for ICS_FLOW_ResetRetention
 * @author Sizwe November
 * @date September 2024
 */
@IsTest
public with sharing class ICS_FLOW_ResetRetention_Test {
     
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
    static void testResetRetention() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.id);
        
        ICS_FLOW_ResetRetention.Requests testRequests = new ICS_FLOW_ResetRetention.Requests();
        testRequests.accountIds = accountIdList;
        List<ICS_FLOW_ResetRetention.Requests> testRequestsList = new List<ICS_FLOW_ResetRetention.Requests>();
        testRequestsList.add(testRequests);
		List<Integer> responseDSXList = new List<Integer>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.UpdateMockResponse());
        responseDSXList = ICS_FLOW_ResetRetention.invokeResetRetentionDate(testRequestsList);
     	Test.stopTest();
        Assert.areEqual(200, responseDSXList[0], 'Status code from DSX after retention date update');

    }
     
        @isTest
    static void testResetRetentionFail() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Id> accountIdList = new List<Id>();
        accountIdList.add(testAccount.id);
        
        ICS_FLOW_ResetRetention.Requests testRequests = new ICS_FLOW_ResetRetention.Requests();
        testRequests.accountIds = accountIdList;
        List<ICS_FLOW_ResetRetention.Requests> testRequestsList = new List<ICS_FLOW_ResetRetention.Requests>();
        testRequestsList.add(testRequests);
		List<Integer> responseDSXList = new List<Integer>();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        responseDSXList = ICS_FLOW_ResetRetention.invokeResetRetentionDate(testRequestsList);
     	Test.stopTest();
        Assert.areEqual(400, responseDSXList[0], 'Status code from DSX after client number fail update');

    }


}