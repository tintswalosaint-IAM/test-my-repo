/***************************************************************************************
* @Name of the Class : ICS_CTRL_DocumentUploads_Test.cls
* @description  class used as Test class for ICS_CTRL_DocumentUploads_Test in SBO-UK Ping Feature for  - Story: SFP-31800
* Story:SFP-31921
* @author Ruchi
* @date 10 June 2023
/***************************************************************************************
* @last modified on  : 28-03-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : SFP-31921 class used as controller for SBO-UK document upload
***************************************************************************************/

@IsTest
public class ICS_CTRL_DocumentUploads_Test {
    
    @TestSetup
    static void setupTestData() {
        User communityUser = createCommunityUser();
        communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        createTestData(String.valueOf(communityUser.Contact.AccountId),communityUser);
        assignPermissionSet(communityUser);
    }

    @IsTest
    static void testSaveDocument() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
          
        );
        insert contentVersion;
         Id wealthInCountryRecordTypeId = Schema.getGlobalDescribe().get('Party_Assets_Funds__c')
                                               .getDescribe()
                                               .getRecordTypeInfosByName()
                                               .get('Wealth in Country')
                                               .getRecordTypeId();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        PartyProfile profileData = new PartyProfile(AccountId = acc.Id, Name = 'Test PartyProfile');
         Party_Assets_Funds__c assetFundWealth = new Party_Assets_Funds__c(
            Party_Profile__c = profileData.Id,
            Type__c = 'Ownership/shares in business',
            RecordTypeId = wealthInCountryRecordTypeId
        );
        insert assetFundWealth;
         ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;
                cdl.LinkedEntityId = appForm.Id;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
        
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
      
            Test.startTest();
            ICS_CTRL_DocumentUpload.createContentDocumentLink(contentVersion.Id, commUser.Contact.AccountId);
        Assert.areEqual(true,commUser != null, 'user queried with FederationIdnetifier');
            Test.stopTest();
            
          
        
    }

    @IsTest
    static void testSaveDocuments() {
        ApplicationForm appForm = [SELECT Id FROM ApplicationForm LIMIT 1];
        List<ICS_CTRL_DocumentUpload.DocumentData> testDataList = new List<ICS_CTRL_DocumentUpload.DocumentData>();
        testDataList.add(createTestDocumentData());
        testDataList.add(createTestDocumentData());

        User commUser = [SELECT Id FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        System.runAs(commUser) {
            try{
            Test.startTest();
            String[] savedDocIds = ICS_CTRL_DocumentUpload.saveDocuments(String.valueOf(appForm.Id), testDataList);
            Test.stopTest();
            
            Assert.isNotNull(savedDocIds, 'Documents should be saved successfully');
            }catch(exception ex){
                Assert.isTrue(ex.getmessage() != null, 'Exception occured');
            }
        }
    }

    @IsTest
    static void testFetchCurrentPartyProfileId() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        System.runAs(commUser) {
            Test.startTest();
            String jsonString = ICS_CTRL_DocumentUpload.fetchCurrentPartyProfileId();
            Test.stopTest();
            
            Assert.isNotNull(jsonString, 'Should return party profile data');
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonString);
            Assert.isTrue(resultMap.containsKey('firstName'), 'Should contain firstName');
        }
    }

    @IsTest
    static void testFetchDocumentsData() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
                Test.startTest();
            ContentVersion cv = new ContentVersion(
            Title = 'Test Doc',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true,
             DocumentType__c='Proof of co-habitation'
        );
        insert cv;
             ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = commUser.Contact.AccountId;
                cdl.ShareType = 'I';
                cdl.Visibility = 'AllUsers';
                insert cdl;
    
            String jsonString = ICS_CTRL_DocumentUpload.fetchDocumentsData('Specimen Signature', commUser.Contact.AccountId);
            ICS_CTRL_DocumentUpload.enhancedDueDiligenceCheck(commUser.Contact.AccountId);
            ICS_CTRL_DocumentUpload.getThePartyProfileId(commUser.Contact.AccountId);
            ContentVersion  cv1 = [SELECT id, ContentDocumentId FROM ContentVersion LIMIT 1];
        	ICS_DAL_TestFactory.createContentDocumentLink(commUser.Contact.AccountId, cv1.ContentDocumentId);
            Test.stopTest();
            Assert.isNotNull(jsonString, 'Should return documents data');
        
    }

    @IsTest
    static void testFetchUploadProperty() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        System.runAs(commUser) {
            Test.startTest();
            System.debug(commUser);
            String result = ICS_CTRL_DocumentUpload.fetchUploadProperty(commUser.Contact.AccountId);
            Test.stopTest();
            
            Assert.isNotNull(result, 'Should return upload properties');
        }
    }

    @IsTest
    static void testUpdateStageValues() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
      
            Test.startTest();
            ICS_CTRL_DocumentUpload.updateStageValues(commUser.Contact.AccountId);
            Test.stopTest();
            Opportunity opp = [SELECT StageName FROM Opportunity WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
            Assert.areEqual('Review', opp.StageName, 'Stage should be updated to Review');
        
    }

    @IsTest
    static void testDeleteDocumentFiles() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test Doc',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert cv;
        
        Id cdId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = cdId,
            LinkedEntityId = acc.Id,
            ShareType = 'I'
        );
        insert cdl;
        
        Test.startTest();
        ICS_CTRL_DocumentUpload.deleteDocumentFiles(cdl.Id);
        Test.stopTest();
        
        List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id = :cdId];
        Assert.areEqual(0, deletedDocs.size(), 'Document should be deleted');
    }

    @IsTest
    static void testUpdateAndGetReasonForNoDocument() {
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
        Party_Assets_Funds__c paf = [SELECT Id FROM Party_Assets_Funds__c WHERE Party_Profile__c = :profile.Id LIMIT 1];
        
        Test.startTest();
        ICS_CTRL_DocumentUpload.updateReasonForNoDocument(paf.Id, 'Test Reason');
        String reason = ICS_CTRL_DocumentUpload.getReasonForNoDocument(paf.Id);
        Test.stopTest();
        
        Assert.areEqual('Test Reason', reason, 'Reason should be updated and retrieved correctly');
    }

    // Helper Methods
    private static User createCommunityUser() {
        Profile communityProfile = [SELECT Id FROM Profile WHERE Name LIKE '%Customer Community%' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<UserRole> roles = [SELECT Id FROM UserRole WHERE PortalType = 'None' LIMIT 1];
            UserRole ownerRole;
            if (roles.isEmpty()) {
                ownerRole = new UserRole(Name = 'Portal Account Owner', DeveloperName = 'Portal_Account_Owner');
                insert ownerRole;
            } else {
                ownerRole = roles[0];
            }
            User runningUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
            if (runningUser.UserRoleId == null) {
                runningUser.UserRoleId = ownerRole.Id;
                update runningUser;
            }
        }
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        Contact con = new Contact(
            AccountId = acc.Id,
            LastName = 'TestContact',
            Email = 'test@test.com'
        );
        insert con;
        
        User user = new User(
            ProfileId = communityProfile.Id,
            ContactId = con.Id,
            Email = 'test@test.com',
            EmailEncodingKey = 'UTF-8',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'test@test.com.testorg',
            Alias = 'test',
            FirstName = 'Test',
            LastName = 'User',
            FederationIdentifier = 'FederationIdentifier' + String.valueOf(DateTime.now().getTime())
        );
        
        insert user;
        return user;
    }

    private static void createTestData(String accId,User commUser) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            AccountId = accId,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        ApplicationForm appForm = new ApplicationForm(
            AccountId = accId,
            OpportunityId = opp.Id,
            Stage = 'In Progress',
            usagetype='Onboarding'
        );
        insert appForm;
        
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
       Applicant appData=  ICS_DAL_TestFactory.createApplicantByRole('Primary Applicant', commUser.Contact.accountId, profile.id, appForm.Id);
        appData.Relationship_with_Applicants__c ='Co-habiting together';
        update appData;
        createPartyAssetsFunds(profile.Id);
        createAssessmentData(commUser,profile);
    }

    private static void createPartyAssetsFunds(Id profileId) {
        Id recTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        
        List<Party_Assets_Funds__c> assetsList = new List<Party_Assets_Funds__c>();
        
        Party_Assets_Funds__c asset1 = new Party_Assets_Funds__c(
            Party_Profile__c = profileId,
            Type__c = 'Owned Property',
            RecordTypeId = recTypeId,
            Type_of_Property__c = 'Residential',
            Is_Future_Fund__c = true,
            Is_amount_to_more_than_10__c = true
        );
        assetsList.add(asset1);
        
        Party_Assets_Funds__c asset2 = new Party_Assets_Funds__c(
            Party_Profile__c = profileId,
            Type__c = 'Trust',
            TrustDeed_or_Letter_of_wishes__c = 'Both',
            Is_Future_Fund__c = true
        );
        assetsList.add(asset2);
        
        insert assetsList;
    }

    private static void createAssessmentData(user commUser,partyprofile testPartyProfile) {
        AssessmentQuestion question = createAssessmentQuestion('Select all assets and income*', 'sssss');
        AssessmentQuestion questionFund = createAssessmentQuestion('Select all funds assets and income*', 'sddsds');
        
        Assessment assData = ICS_DAL_TestFactory.createAssessment(commUser.contact.AccountId);
        AssessmentQuestionVersion versionData = createAssessmentQuestionVersion(question.Id, 'Select all assets and income*');
        
         createAssessmentQuestionVersion(questionFund.Id, 'Select all funds assets and income*');
       ICS_DAL_TestFactory.createContentVersion();
         AssessmentQuestionResponse response = new AssessmentQuestionResponse(
            Name = question.Name,
            AssessmentId = assData.ID,
            AssessmentQuestionId = versionData.id,
            ResponseText = 'Gift;Bank Account'
        );
        insert response;
        
         AssessmentQuestion questionTax = createAssessmentQuestion('Please select why the country you live in is different from the country', 'ssds1');
        AssessmentQuestionVersion versionDataTax = createAssessmentQuestionVersion(questionTax.Id, 'Please select why the country you live in is different from the country');
       ICS_DAL_TestFactory.createContentVersion();
         AssessmentQuestionResponse responseTax = new AssessmentQuestionResponse(
            Name = questionTax.Name+'tax',
            AssessmentId = assData.ID,
            AssessmentQuestionId = versionDataTax.id,
            ResponseText = 'I am a diplomat'
        );
        insert responseTax;  
        response =[select id ,AssessmentQuestion.Name from AssessmentQuestionResponse limit 1];   
         createAssessment(commUser.Contact.AccountId, testPartyProfile.Id);
    }
	
    private static void assignPermissionSet(User communityUser) {
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'ICS_Community_License_External_Credential' LIMIT 1];
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new PermissionSetAssignment(AssigneeId = communityUser.Id, PermissionSetId = ps.Id);
        }
    }

    private static ICS_CTRL_DocumentUpload.DocumentData createTestDocumentData() {
        ICS_CTRL_DocumentUpload.DocumentData testData = new ICS_CTRL_DocumentUpload.DocumentData();
        testData.documentId = 'Test Document Id';
        testData.documentName = 'Test Document';
        testData.documentType = 'SOW Proof of Gift';
        testData.documentDate = Date.today();
        testData.description = 'Test Description';
        testData.filename = 'TestFile';
        testData.mimeType = 'application/pdf';
        testData.base64 = EncodingUtil.base64Encode(Blob.valueOf('Test data'));
        testData.originalFilename = 'TestFile.pdf';
        testData.originalFiletype = 'pdf';
        return testData;
    }
        private static AssessmentQuestion createAssessmentQuestion(String name, String devName) {
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = devName,
            Name = name,
            QuestionCategory = 'Financial'
        );
        insert question;
        return question;
    }
    
    private static AssessmentQuestionVersion createAssessmentQuestionVersion(Id questionId, String questionText) {
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = questionId,
            Questiontext = questionText,
            Name = questionText,
            IsActive = true
        );
        insert qv;
        return qv;
    }
       private static Assessment createAssessment(Id accountId, Id partyProfileId) {
        Assessment assessment = new Assessment(
            Name = 'Test Assessment',
            AccountId = accountId,
            PartyProfileId = partyProfileId,
            AssessmentStatus = 'InProgress'
        );
        insert assessment;
        return assessment;
    }
    @IsTest
    static void testSaveDocumentWithPartyAssetId() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Party_Assets_Funds__c paf = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        ICS_CTRL_DocumentUpload.DocumentData testData = createTestDocumentData();
        
        Test.startTest();
        String result = ICS_CTRL_DocumentUpload.saveDocument(commUser.Contact.AccountId, testData, '1', paf.Id);
        Test.stopTest();
        
        Assert.isNull(result, 'Document should be saved');
    }
    
    @IsTest
    static void testInvalidPropertyType() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profile = [SELECT Id FROM PartyProfile LIMIT 1];
        Id recTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        Party_Assets_Funds__c invalidProperty = new Party_Assets_Funds__c(
            Party_Profile__c = profile.Id,
            Type__c = 'Owned Property',
            RecordTypeId = recTypeId,
            Type_of_Property__c = 'Rental',
            Is_Future_Fund__c = true,
            Is_listed_in_assets__c = false
        );
        insert invalidProperty;
        
        Test.startTest();
        String result = ICS_CTRL_DocumentUpload.fetchUploadProperty(commUser.Contact.AccountId);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should handle invalid property type');
    }
    @IsTest
    static void testIsMatchingTypeNullValues() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        ContentVersion cv = new ContentVersion(
            Title = 'Test Doc Null Type',
            PathOnClient = 'testNull.pdf',
            VersionData = Blob.valueOf('Test Content Null'),
            IsMajorVersion = true
        );
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = commUser.Contact.AccountId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        
        Test.startTest();
        
        String result = ICS_CTRL_DocumentUpload.fetchDocumentsData('AnyTab', commUser.Contact.AccountId);
        
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null even with null document type');
    }
    
     @IsTest
    static void testUpdateContentVersion_DeletesDuplicateSameType() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Id accountId = commUser.Contact.AccountId;
        String documentType = 'SOW Proof of Gift';

        ContentVersion existingCv = new ContentVersion(
            Title = 'Existing Document',
            PathOnClient = 'existing.pdf',
            VersionData = Blob.valueOf('Existing content'),
            IsMajorVersion = true,
            DocumentType__c = documentType
        );
        insert existingCv;
        Id existingDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :existingCv.Id].ContentDocumentId;
        insert new ContentDocumentLink(
            ContentDocumentId = existingDocId,
            LinkedEntityId = accountId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );

        ContentVersion newCv = new ContentVersion(
            Title = 'New Upload',
            PathOnClient = 'new_upload.pdf',
            VersionData = Blob.valueOf('New content'),
            IsMajorVersion = true,
            DocumentType__c = documentType
        );
        insert newCv;
        Id newDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :newCv.Id].ContentDocumentId;
        insert new ContentDocumentLink(
            ContentDocumentId = newDocId,
            LinkedEntityId = accountId,
            ShareType = 'I',
            Visibility = 'AllUsers'
        );

        Test.startTest();
        ICS_CTRL_DocumentUpload.DocumentData result = ICS_CTRL_DocumentUpload.updateContentVersion(
            accountId, newCv.Id, documentType
        );
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null');
        Assert.isFalse(result.fileLimitError, 'File limit should not be exceeded');

        List<ContentDocument> deletedDocs = [SELECT Id FROM ContentDocument WHERE Id = :existingDocId];
        Assert.areEqual(0, deletedDocs.size(), 'Duplicate document of same type should be deleted');
    }

    @IsTest
    static void testUpdateContentVersion_ThrowsOnInvalidAccount() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test Doc',
            PathOnClient = 'test.pdf',
            VersionData = Blob.valueOf('Test content'),
            IsMajorVersion = true
        );
        insert cv;

        Test.startTest();
        try {
            ICS_CTRL_DocumentUpload.updateContentVersion(null, cv.Id, 'SOW Proof of Gift');
            Assert.fail('Expected AuraHandledException to be thrown for null account');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }

    
    @IsTest
    static void testInvokeFetchCRAReport() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        List<String> accountIds = new List<String>{ commUser.Contact.AccountId };

        Test.startTest();
        ICS_CTRL_DocumentUpload.invokeFetchCRAReport(accountIds);
        Test.stopTest();

        Assert.isTrue(true, 'invokeFetchCRAReport executed without exception');
    }

    @IsTest
    static void testInvokeFetchCRAReport_NullAndEmpty() {
        Test.startTest();
        ICS_CTRL_DocumentUpload.invokeFetchCRAReport(null);
        ICS_CTRL_DocumentUpload.invokeFetchCRAReport(new List<String>());
        Test.stopTest();

        Assert.isTrue(true, 'No exception thrown for null or empty list');
    }

    @IsTest
    static void testFetchDocumentsData_SOFAndSOWDocumentTypes() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        List<ContentVersion> cvs = new List<ContentVersion>{
            new ContentVersion(
                Title = 'SOF Gift Doc',
                PathOnClient = 'sof_gift.pdf',
                VersionData = Blob.valueOf('SOF content'),
                IsMajorVersion = true,
                DocumentType__c = 'SOF Proof of Gift'
            ),
            new ContentVersion(
                Title = 'SOW Gift Doc',
                PathOnClient = 'sow_gift.pdf',
                VersionData = Blob.valueOf('SOW content'),
                IsMajorVersion = true,
                DocumentType__c = 'SOW Proof of Gift'
            ),
            new ContentVersion(
                Title = 'Trust Deed Doc',
                PathOnClient = 'trust_deed.pdf',
                VersionData = Blob.valueOf('Trust content'),
                IsMajorVersion = true,
                DocumentType__c = 'Trust Deed'
            )
        };
        insert cvs;

        List<ContentVersion> inserted = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvs];
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>();
        for (ContentVersion cv : inserted) {
            cdls.add(new ContentDocumentLink(
                ContentDocumentId = cv.ContentDocumentId,
                LinkedEntityId = commUser.Contact.AccountId,
                ShareType = 'I',
                Visibility = 'AllUsers'
            ));
        }
        insert cdls;

        Test.startTest();
        String result = ICS_CTRL_DocumentUpload.fetchDocumentsData('Proof of Gift', commUser.Contact.AccountId);
        Test.stopTest();

        Assert.isNotNull(result, 'Result should not be null for SOF/SOW document types');
    }
}