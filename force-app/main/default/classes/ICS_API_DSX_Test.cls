/**
 * @description Test Class for ICS_API_DSX
 * @author Gnitsevich Anton
 * @date March 2023
 */
@IsTest
public with sharing class ICS_API_DSX_Test {
    private static final Id CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('ICS_Onboarding_Document').getRecordTypeId();
    
    @TestSetup
    private static void setup() {

        Account testAccount = ICS_TestDataFactory.createAccount();
        testAccount.ExternalCIFId__c = '123456';
        testAccount.ICS_Country_of_Residence__c = 'ZA';
        update testAccount;

        Opportunity testOpportunity = ICS_TestDataFactory.createOpportunity(testAccount.Id);
        testOpportunity.StageName = 'Closed Won';
        testOpportunity.CloseDate = Date.today();
        
        
		testOpportunity =[select id,Account.ExternalCIFId__c from opportunity limit 1];
        ApplicationForm testApplicationForm = ICS_TestDataFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        PartyProfile testPartyProfile = ICS_TestDataFactory.createPartyProfile(testAccount.Id);
        ICS_DAL_TestFactory.createPartyProfileAddress(testPartyProfile.id,'Residential Address',date.today(),null);
        Applicant testApplicant =  ICS_TestDataFactory.createApplicant(testAccount.Id, testApplicationForm.Id, testPartyProfile.Id);
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
    static void testUpdateRetentionDate() {
		
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.UpdateMockResponse());
        Integer updateRetentionDateStatusCode = ICS_API_DSX.updateRetention(testAccount.Id, retentionDate);
        Test.stopTest();
        Assert.areEqual(200, updateRetentionDateStatusCode, 'Retention date successfully updated');
    }

    @isTest
    static void testUpdateRetentionDateFail() {
		
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        Integer updateRetentionDateStatusCode = ICS_API_DSX.updateRetention(testAccount.Id, retentionDate);
        Test.stopTest();
        Assert.areEqual(400, updateRetentionDateStatusCode, 'Retention date failed to updated');
    }


    @isTest
    static void testSearchDocuments() {
        
	    Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];

        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails clientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.SearchDocumentsMockResponse());
        List<ICS_CTRL_Documents.DocumentData> storedDocuments = new List<ICS_CTRL_Documents.DocumentData>();
        storedDocuments  = ICS_API_DSX.searchDocuments(testAccount.Id, clientNumberDetails.clientNumber , clientNumberDetails.sectorCode, 50);
        Test.stopTest();
        Assert.areEqual(1, storedDocuments.size(), 'Number of DSX documents' );
    }

    @isTest
    static void testSearchDocumentsFail() {
         
        Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];

        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails clientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        List<ICS_CTRL_Documents.DocumentData> storedDocuments = new List<ICS_CTRL_Documents.DocumentData>();
        storedDocuments  = ICS_API_DSX.searchDocuments(testAccount.Id, clientNumberDetails.clientNumber , clientNumberDetails.sectorCode, 50);
        Test.stopTest();
        Assert.areEqual(0, storedDocuments.size(), 'Number of DSX documents' );
    }

    @isTest
    static void testDownloadDocument() {
		String documentId = 'abhgieirj049454';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DownloadDocumentMockResponse());
        ICS_CTRL_Documents.DocumentData document = ICS_API_DSX.downloadDocument(documentId);
        Test.stopTest();
        Assert.areEqual('ProofOfLoan Text Contents', EncodingUtil.base64Decode(document.base64).toString(), 'Downloaded document from DSX');
    }

    @isTest
    static void testDownloadDocumentFail() {
		String documentId = 'abhgieirj049454';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        ICS_CTRL_Documents.DocumentData document = ICS_API_DSX.downloadDocument(documentId);
        Test.stopTest();
        Assert.areEqual(true, String.isEmpty(document.documentName), 'Failed document download from DSX failed');
    }

   @isTest
    static void testStoreDocuments() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion testContentVersion  = [SELECT Id, DocumentType__c, DocumentDate__c, Title, VersionData, FileExtension FROM ContentVersion LIMIT 1];
       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.StoreDocumentMockResponse());
        Integer storeDocumentStatusCode  = ICS_API_DSX.storeDocument(testAccount.Id, testContentVersion);
        Test.stopTest();
        Assert.areEqual(200, storeDocumentStatusCode, 'Document sent to DSX');
    }

    @isTest
    static void testStoreDocumentsFail() {

	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ContentVersion testContentVersion  = [SELECT Id, DocumentType__c, DocumentDate__c, Title, VersionData, FileExtension FROM ContentVersion LIMIT 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        Integer storeDocumentStatusCode  = ICS_API_DSX.storeDocument(testAccount.Id, testContentVersion);
        Test.stopTest();
        Assert.areEqual(400, storeDocumentStatusCode, 'Document failed sendDSX to DSX');
    }

    @isTest
    static void testUpdateClientNumber() {
        
	    Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];

        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails clientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.UpdateMockResponse());
        Integer updateRetentionDateStatusCode = ICS_API_DSX.updateClientNumber(testAccount.Id,  clientNumberDetails.clientNumber, clientNumberDetails.sectorCode);
     	Test.stopTest();
        Assert.areEqual(200, updateRetentionDateStatusCode, 'Status code from DSX after client number update');
    }

    @isTest
    static void testUpdateClientNumberFail() {
        
	    Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];

        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails clientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        Integer updateRetentionDateStatusCode = ICS_API_DSX.updateClientNumber(testAccount.Id, clientNumberDetails.clientNumber, clientNumberDetails.sectorCode);
     	Test.stopTest();
        Assert.areEqual(400, updateRetentionDateStatusCode, 'Status code from DSX after client number update failure');
    }

}