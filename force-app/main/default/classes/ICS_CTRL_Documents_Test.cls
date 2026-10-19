/**
 * @description Test Class for ICS_CTRL_Documents
 * @author Gnitsevich Anton
 * @date March 2023
 */
@IsTest
public with sharing class ICS_CTRL_Documents_Test{
     
    /**
    * @description  Content Version record type for ICS Onboarding
    */     
    private static final Id CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('ICS_Onboarding_Document').getRecordTypeId();
    /*
    * @description  DSX document storage   
    */     
    private static final String DSX_STORAGE = 'DSX';
    
    @TestSetup
    private static void setup() {

      	Account testAccount = ICS_TestDataFactory.createAccount();
        testAccount.ExternalCIFId__c  = '0098666827';
        update testAccount;
        Opportunity testOpportunity = ICS_TestDataFactory.createOpportunity(testAccount.Id);
		
        testOpportunity.CloseDate = Date.today();
        update testOpportunity;
        testOpportunity = [select id,Account.ExternalCIFId__c,StageName,CloseDate from opportunity where id =:testOpportunity.ID];
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
        testContentVersion.DocumentType__c = 'Trust Deed';
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
    static void testGetPartyProfileId() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        Set<id> testPartyProfileIdSet = new Set<id>();
        testPartyProfileIdSet = ICS_CTRL_Documents.getPartyProfileIds(testPartyProfile.AccountId);
        Test.stopTest();
        Assert.areEqual(true, testPartyProfileIdSet.contains(testPartyProfile.Id),'Account linked to Party Profile');
    }

    @isTest
    static void testGetAccountId() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        Id testAccountId = ICS_CTRL_Documents.getAccountId(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(testAccountId, testPartyProfile.AccountId,'Account linked to Party Profile');
    }
    
      @isTest
    static void testCheckClientNumber() {
        
        Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];
        testAccount.ExternalCIFId__c = '5656jhgtywA';
        testAccount.ICS_Country_of_Residence__c = 'AO';
		update testAccount;
                    
        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails testClientNumberDetails = new ICS_CTRL_Documents.ClientNumberDetails ();
        testClientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.stopTest();
        Assert.areEqual(testClientNumberDetails.clientNumber, '5656jhgtywA','BP number updated');
        Assert.areEqual(testClientNumberDetails.sectorCode, '1008','Sector code for Relationship Manager');

    }
    
    @isTest
    static void testGetApplication() {
        
         Id testPartyProfileId = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1].id;
        
        Test.startTest();
        PartyProfile testPartyProfile = ICS_CTRL_Documents.getPartyProfile(testPartyProfileId);
        Test.stopTest();
        Assert.areEqual('Jacob Steve Mulner', testPartyProfile.Account.Name,'Account linked to Party Profile');
    }
    
	@isTest
    static void testGetPartyProfileException() {
        
        
        Test.startTest();
        try {
        	ICS_CTRL_Documents.getPartyProfile('0xU9O0000000123ABC');
       	} catch (AuraHandledException ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'AuraHandledException Thrown');
      	}
        Test.stopTest();
    }
    
	@isTest
	static void testGetAccountException() {
        Test.startTest();
        try {
        	ICS_CTRL_Documents.getAccount('12U9O0000000123ABC');
       	} catch (AuraHandledException ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'AuraHandledException Thrown');
      	}
        Test.stopTest();
    }
    
	@isTest
	static void testGetOpportunityException() {
        
        Test.startTest();
        try {
        	 ICS_CTRL_Documents.getOpportunity('12U9O0000000123ABC');
       	} catch (Exception ex) {
            Assert.areEqual('Attempt to de-reference a null object', ex.getMessage(), 'No Opportunity found');
      	}
        Test.stopTest();
    }

    @isTest
	static void testGetPartyProfileIdException() {
        
        Test.startTest();
        try {
        	 ICS_CTRL_Documents.getPartyProfile('0xU9O0000000123ABC');
       	} catch (Exception ex) {
            Assert.areEqual('Attempt to de-reference a null object', ex.getMessage(), 'No Party Profile found');
      	}
        Test.stopTest();
    }
    
    @isTest
    static void testGetAccount() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];

        Test.startTest();
        Account testAccount = ICS_CTRL_Documents.getAccount(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(testAccount.Name, testPartyProfile.Account.Name,'Account linked to Party Profile');
    }
    
	@isTest
    static void testGetOpportunity() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
		Opportunity testOpportunity = [SELECT Id, IsClosed, StageName, CloseDate, Loss_Reason__c FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity opps = ICS_CTRL_Documents.getOpportunity(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(testOpportunity.Id,opps.Id, 'Opportunity linked to Party Profile' );
    }


    @isTest
    static void testSaveDocument() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        ICS_CTRL_Documents.DocumentData data = new ICS_CTRL_Documents.DocumentData();
        data.base64 = EncodingUtil.base64Encode(Blob.valueOf('ProofOfIncome Text Contents'));
        data.originalFilename = 'John-Johns-ProofOfIncome-2.txt';
        data.originalFiletype = 'text/plain';
        data.filename = 'John-Johns-ProofOfIncome-2';
        data.documentDate = Date.today();

        Test.startTest();
        ICS_CTRL_Documents.saveDocument(String.valueOf(testPartyProfile.Id), data);
        Test.stopTest();
        Assert.areEqual(2, [SELECT COUNT() FROM ContentVersion], 'Number of documents linked to the Party Profile');
        Assert.areEqual(1, [SELECT Id, PathOnClient FROM ContentVersion WHERE PathOnClient = 'John-Johns-ProofOfIncome-2.txt'].size(), 'Document uploaded successfully for Party Profile');
    }
  
    @isTest
    static void testSaveDocumentFail() {
        
        ICS_CTRL_Documents.DocumentData data = new ICS_CTRL_Documents.DocumentData();
        data.base64 = EncodingUtil.base64Encode(Blob.valueOf('ProofOfSalary Text Contents'));
        data.originalFilename = 'John-Johns-ProofOfSalary-2.txt';
        data.originalFiletype = 'text/plain';
        data.filename = 'John-Johns-ProofOfSalary-2';
        data.documentDate = Date.today();

        Test.startTest();
        ICS_CTRL_Documents.saveDocument(null, data);
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion], 'Number of documents linked to the Party Profile');
        Assert.areEqual(0, [SELECT Id, PathOnClient FROM ContentVersion WHERE PathOnClient = 'John-Johns-ProofOfSalary-2.txt'].size(), 'Document to failed upload for Party Profile');
    }
     

    @isTest
    static void testStoreDocuments() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        String expectedResult = 'ContentDocument delete successful for Account: '+testPartyProfile.AccountId;
       
        ContentDocumentLink link = [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.id];
        ContentVersion contentVersion = [SELECT Id, DocumentType__c, DocumentDate__c, Title, FileExtension, VersionData, ContentDocumentId 
                                         FROM ContentVersion WHERE ContentDocumentId=: link.ContentDocumentId AND Islatest = TRUE];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.StoreDocumentMockResponse());
        String result = ICS_CTRL_Documents.storeDocuments(testPartyProfile.Id, DSX_STORAGE,contentVersion);
        Test.stopTest();

        Assert.areEqual(expectedResult, result, 'Document sent to DSX and deleted');
    }

    @isTest
    static void testStoreDocumentsUpdate() {
        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        testPartyProfile.RecordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get('ICS_PartyProfile').getRecordTypeId();
        update testPartyProfile;

        Opportunity testOpportunity = [SELECT Id, IsClosed, StageName, CloseDate, Loss_Reason__c FROM Opportunity LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.StoreDocumentMockResponse());
        ICS_CTRL_Documents.storeDocumentsUpdate(testOpportunity.Id);
        Test.stopTest();

        try {
            ContentDocumentLink link = [SELECT Id,ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: testPartyProfile.id];
        } catch (Exception ex) {
           Assert.areEqual('List has no rows for assignment to SObject', ex.getMessage(), 'Document successfully deleted after DSX submission');
         }
    }

    @isTest
    static void testDeleteFail() {
        
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List <Id> testIdList = new List <Id>{'0019O00000y8JcP123'};
        String expectedResult = 'ContentDocument delete failed for Account: '+testAccount.Id ;
        
        Test.startTest();
        String result = ICS_CTRL_Documents.deleteStoredDocuments(testAccount.Id,testIdList);
        Test.stopTest();

        Assert.areEqual(expectedResult, result, 'Document sent to DSX and deleted');
    }
	
    @isTest
    static void testResetRetention() {

        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        List<Id> accountIds = new List<Id>();
        accountIds.add(testAccount.id);
        
        ICS_FLOW_ResetRetention.Requests testRequests = new ICS_FLOW_ResetRetention.Requests();
       	testRequests.accountIds = accountIds;
        List<ICS_FLOW_ResetRetention.Requests> testRequestsList = new List<ICS_FLOW_ResetRetention.Requests>();
        testRequestsList.add(testRequests);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.StoreDocumentMockResponse());
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        ICS_FLOW_ResetRetention.invokeResetRetentionDate(testRequestsList);
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion], 'Document to update retention date');

    }
    
    
    @isTest
    static void testResetRetentionDate() {
		
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Integer resetRetentionDateStatusCode;
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.UpdateMockResponse());
        resetRetentionDateStatusCode = ICS_CTRL_Documents.resetRetentionDates(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual(200, resetRetentionDateStatusCode, 'Retention date successfully updated');

    }
    
    @isTest
    static void testResetRetentionDateFail() {
		
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
                
        Test.startTest();
        Integer resetRetentionDateStatusCode;
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        resetRetentionDateStatusCode = ICS_CTRL_Documents.resetRetentionDates(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual(400, resetRetentionDateStatusCode, 'Retention date failed to updated');

    }

    @isTest
    static void testGetDocuments() {
  		Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];
        testAccount.ExternalCIFId__c = '5656jhgtywA';
        testAccount.ICS_Country_of_Residence__c = 'AO';
		update testAccount;        
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        
		Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.SearchDocumentsMockResponse());
        List<ContentVersion> localDocuments = ICS_CTRL_Documents.getLocalDocuments(testPartyProfile.Id);
        List<ICS_CTRL_Documents.DocumentData> storedDocuments = new List<ICS_CTRL_Documents.DocumentData>();
        storedDocuments  = ICS_CTRL_Documents.getStoredDocuments(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual(1, localDocuments.size(), 'Number of local documents');
        Assert.areEqual(1, storedDocuments.size(), 'Number of DSX documents' );
    }

    @isTest
    static void testDownloadDocument() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DownloadDocumentMockResponse());
        ICS_CTRL_Documents.DocumentData document = ICS_CTRL_Documents.downloadDocument(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual('ProofOfLoan Text Contents', EncodingUtil.base64Decode(document.base64).toString(), 'Downloaded document from DSX');
    }
    
        @isTest
    static void testDownloadDocumentFail() {
		Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        ICS_CTRL_Documents.DocumentData document = ICS_CTRL_Documents.downloadDocument(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual(null, document.salesForceId, 'Downloaded document from DSX failed');
    }

    @isTest
    static void testDSXStoreUnauthorized() {

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
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        ICS_FLOW_StoreDocuments.invokeStoreDocuments(testRequestsList);
        Test.stopTest();
        Assert.areEqual(1, [SELECT COUNT() FROM ContentVersion], 'Document store unauthorized');

    }
    
    @isTest
    static void testDSXAccessDocumentUnauthorized() {
         
        Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];
        testAccount.ExternalCIFId__c = null;
		update testAccount;        
        Opportunity testOpportunity = [SELECT Id, IsClosed, StageName, CloseDate, Loss_Reason__c FROM Opportunity LIMIT 1];
        testOpportunity.StageName = 'Closed Lost';
        testOpportunity.Loss_Reason__c = 'Price';
        testOpportunity.CloseDate = Date.today();
        update testOpportunity;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ICS_Mock_DSX.DSXMockResponseFail());
        List<ICS_CTRL_Documents.DocumentData> storedDocuments = ICS_CTRL_Documents.getStoredDocuments(testAccount.Id, DSX_STORAGE);
        Test.stopTest();
        Assert.areEqual(true, storedDocuments.isEmpty(), 'No document found');
    }
   
      
    @isTest
    static void testUpdateClientNumber() {
        
	    Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        ICS_FLOW_UpdateClientNumber.Requests testRequests = new ICS_FLOW_UpdateClientNumber.Requests();
        testRequests.accountId = testAccount.Id;
       	testRequests.clientNumber = '00966558';
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
      
    @isTest
    static void testCalculateRetentionDateClosedWon() {
        
       PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
      
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.stopTest();
         Assert.areEqual(true, retentionDate != null, 'Infinite retention date');
    }
    
        
    
    @isTest
    static void testGetLocalDocuments() {
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
        
        Test.startTest();
        List<ContentVersion> result = ICS_CTRL_Documents.getLocalDocuments(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(true, result.size()==1, 'Expected 1 ContentVersions');

    }
    
       @isTest
    static void testSearchPayload() {
         
        Account testAccount = [SELECT Id, ExternalCIFId__c, ICS_Country_of_Residence__c FROM Account LIMIT 1];

        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails clientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        String searchPayload  = ICS_CTRL_Documents.searchPayload(testAccount.Id, clientNumberDetails.clientNumber , clientNumberDetails.sectorCode, 50);
        JSONGenerator searchBody = JSON.createGenerator(true);
        	searchBody.writeStartObject();
            searchBody.writeStringField('salesforceid', testAccount.Id);
            searchBody.writeNumberField('page', 50);
           	searchBody.writeNumberField('pageSize', 50);
            if(String.IsNotBlank(clientNumberDetails.clientNumber)){
                searchBody.writeStringField('clientNo',clientNumberDetails.clientNumber);
            	searchBody.writeStringField('sectorCode',  clientNumberDetails.sectorCode );
            } 
		searchBody.writeEndObject();
        Test.stopTest();
        Assert.areEqual(searchBody.getAsString(), searchPayload, 'Search payload generated successfully' );
    }
    
     @isTest
    static void testCalculateRetentionDateClosedLost() {
        
       Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        testOpportunity.Name='tesstopp';         
        testOpportunity.StageName = 'Closed Lost';
        testOpportunity.Loss_Reason__c = 'Price';
        testOpportunity.CloseDate = Date.today();
        update testOpportunity;
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
		Date retentionDateTest = Date.today().addYears(1);
		String retentionDateTestString =
            retentionDateTest.year() + '-' +
            (retentionDateTest.month() < 10 ? '0' + retentionDateTest.month() : '' + retentionDateTest.month()) + '-' +
            (retentionDateTest.day() < 10 ? '0' + retentionDateTest.day() : '' + retentionDateTest.day());
        
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.stopTest();
         Assert.areEqual(retentionDateTestString, retentionDate, 'Retention date 1 year from Close Lost date');
    }
    
     @isTest
    static void testCalculateRetentionDateClosedDeclined() {
        
       Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        testOpportunity.Name='tesstopp';         
        testOpportunity.StageName = 'Closed Declined';
        testOpportunity.ICS_Decline_Reason__c = 'Confirmed PEP';
        testOpportunity.CloseDate = Date.today();
        update testOpportunity;
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
		Date retentionDateTest = Date.newInstance(9999, 12, 31);
		String retentionDateTestString =
            retentionDateTest.year() + '-' +
            (retentionDateTest.month() < 10 ? '0' + retentionDateTest.month() : '' + retentionDateTest.month()) + '-' +
            (retentionDateTest.day() < 10 ? '0' + retentionDateTest.day() : '' + retentionDateTest.day());
        
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.stopTest();
         Assert.areEqual(retentionDateTestString, retentionDate, 'Retention date infinite - Closed Decline Confirmed PEP');
    }
    
     @isTest
    static void testCalculateRetentionDateClosed() {
        
       Opportunity testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        testOpportunity.Name='tesstopp';         
        testOpportunity.StageName = 'Closed Declined';
        testOpportunity.ICS_Decline_Reason__c = 'Other Reasons';
        testOpportunity.CloseDate = Date.today();
 		testOpportunity.Other_Loss_Reason__c = 'No documents';
        update testOpportunity;
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile LIMIT 1];
		Date retentionDateTest = Date.today().addYears(1);
		String retentionDateTestString =
            retentionDateTest.year() + '-' +
            (retentionDateTest.month() < 10 ? '0' + retentionDateTest.month() : '' + retentionDateTest.month()) + '-' +
            (retentionDateTest.day() < 10 ? '0' + retentionDateTest.day() : '' + retentionDateTest.day());
        Test.startTest();
        String retentionDate = ICS_CTRL_Documents.calculateRetentionDate(testPartyProfile.Id);
        Test.stopTest();
         Assert.areEqual(retentionDateTestString, retentionDate, 'Retention date 1 year - Closed Decline Other');
    }
    
    @isTest
    static void testCheckDocumentType() {
                    
        Test.startTest();
        String testLetterOfWishes = ICS_CTRL_Documents.checkDocumentType('Letter of Wishes');
        String testBankStatements = ICS_CTRL_Documents.checkDocumentType('Bank Statements');
        String testOwnedProperty = ICS_CTRL_Documents.checkDocumentType('SOF Proof of Owned Property');
        String testInvestmentStock = ICS_CTRL_Documents.checkDocumentType('SOF Proof of Investment/Stock');
        String testDocumentType = ICS_CTRL_Documents.checkDocumentType('Trust Deed');
        String testInvestments = ICS_CTRL_Documents.checkDocumentType('SOF Proof of Sale of Investment');
        String testCaptainLetter = ICS_CTRL_Documents.checkDocumentType('Captain Letter');
        String testCRAReport = ICS_CTRL_Documents.checkDocumentType('CRA Report');

        Test.stopTest();

        Assert.areEqual(testLetterOfWishes, 'Trust Deed','Document type updated to Trust Deed ');
        Assert.areEqual(testBankStatements, '3 months of Bank Statements','Document type updated to 3 months of Bank Statements');
        Assert.areEqual(testOwnedProperty, 'SOF Proof of Sale of Property','Document type updated to Sale of Property');
        Assert.areEqual(testInvestmentStock, 'SOF Proof of Investment/Dividend','Document type updated to Investment/Dividend');
        Assert.areEqual(testDocumentType, 'Trust Deed','Document type not changed');
        Assert.areEqual(testInvestments, 'SOF Proof of Sale of Investments','Document type updated to SOF Proof of Sale of Investments');
        Assert.areEqual(testCaptainLetter, 'Proof of Address');
        Assert.areEqual(testCRAReport, 'KYC Files','Document type updated');

	}
              @isTest
    static void testCheckClientNumberJointAccount() {
        
        Account testAccount = ICS_TestDataFactory.createAccount();
        testAccount.ExternalCIFId__c  = '0098666829';
        update testAccount;
        Opportunity testOpportunity =[select id,Account.ExternalCIFId__c,AccountId, StageName,CloseDate from opportunity where Account.ExternalCIFId__c =:'0098666827'];
		
        ApplicationForm testApplicationForm = ICS_TestDataFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        PartyProfile testPartyProfile = ICS_TestDataFactory.createPartyProfile(testAccount.Id);
        Applicant testApplicant = ICS_TestDataFactory.createApplicant(testAccount.Id, testApplicationForm.ID, testPartyProfile.ID);
        testApplicant.FirstName = testAccount.FirstName;
        testApplicant.LastName = testAccount.LastName;
        update testApplicant;
        
        FinServ__FinancialAccount__c accountFin = new FinServ__FinancialAccount__c();
        accountFin.FinServ__PrimaryOwner__c = testOpportunity.AccountId;
        accountFin.Name='test';
        accountFin.ExternalCIFId__c ='0098666830';
        insert accountFin;
        
        SEL_FinServ_FinancialAccount selectFinancialAccount = new SEL_FinServ_FinancialAccount();     
		selectFinancialAccount.getSObjectFieldList();
            
        Test.startTest();
        ICS_CTRL_Documents.ClientNumberDetails testClientNumberDetails = new ICS_CTRL_Documents.ClientNumberDetails ();
        testClientNumberDetails = ICS_CTRL_Documents.checkClientNumber(testAccount.Id);
        Test.stopTest();
        Assert.areEqual(testClientNumberDetails.clientNumber, '98666830','BP number updated');

    }

}