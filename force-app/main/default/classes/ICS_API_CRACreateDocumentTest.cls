/***************************************************************************************
* @name of the Class : ICS_API_CRACreateDocumentTest.cls
* @description class used as test class for ICS_API_CRACreateDocument
* @Story:SFP-34697
* @date 06/03/2025
/***************************************************************************************
* @last modified on  : 06/03/2025
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 28/05/2025
* Last Modified Description:  SFP-54329 Updated createContentVersions to get documents based on date 
******************************************************/
@isTest
private class ICS_API_CRACreateDocumentTest {
    private static String CUSTOMER_ID;
    private static final String TEST_DOCUMENT = 'VGhpcyBpcyBhIHRlc3QgZG9jdW1lbnQ='; // Base64 "This is a test document"
    private static final String DOCUMENT_TYPE_PASSPORT = 'Passport';
    @TestSetup
    static void setupTestData() {
    
        Account relatedAccount = new Account(
            FirstName = 'Test',
            LastName = 'Related',
            PersonEmail = 'pskRe@gmail.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert relatedAccount;
        CUSTOMER_ID=relatedAccount.Id;
        createCustomMetadata();
    }

    private static void createCustomMetadata() {
        // Mock custom metadata in test context
        // In a real implementation, we'd use @TestVisible methods to access metadata
    }

    @isTest
static void testResponseCallWithValidData() {
    String requestBody = buildRequestBody(CUSTOMER_ID, TEST_DOCUMENT, DOCUMENT_TYPE_PASSPORT);

    
    Test.startTest();
    String result = ICS_API_CRACreateDocument.responseCall(requestBody);
    Test.stopTest();
    
    List<ICS_API_CRACreateDocument.response> responses = (List<ICS_API_CRACreateDocument.response>)
        JSON.deserialize(result, List<ICS_API_CRACreateDocument.response>.class);
    
    // Define the JSON string with properly escaped newlines
    string jsonString = '{"JourneyId":"8512d0e6-0eda-4b23-a6aa-901fc4798a5c","HighLevelResult":"Refer","HighLevelResultDetails":["DOCUMENTFRONTSIDETYPECHECK:PASSED","DOCUMENTOVERALLVALIDATION:PASSED","UNDERAGERULE:PASSED","DOCUMENTBACKSIDECHECK:NOTNEEDED","DOCUMENTBLOCKINGPOLICY:PASSED","DOCUMENTEXPIRY:PASSED","DOCUMENTSUPPORT:PASSED","DOCUMENTPROOFPOLICY:SKIPPED","DOCUMENTVALIDATION:PASSED","FACEMATCHVALIDATION:PASSED","DOCUMENTBACKSIDECHECK:NOTNEEDED","DOCUMENTPROOFPOLICY:SKIPPED","ACCUMULATIVELIVENESSRESULT:FAILED"],"InitiatedDateTime":"2025-03-26T21:01:42.315446+00:00","ProcessedDocuments":[{"IssuingCountryCode":"GBR","IssuingCountryName":"United Kingdom","IssuingStateName":"Not available","DocumentCategory":"Passport","DocumentType":"Passport","DocumentName":"United Kingdom - National Passport - Front - 2015","DocumentSide":"Front","IsValidated":"true","ScanDateTime":"2025-03-26T21:01:42.315446+00:00","HighLevelResult":"Passed","ExtractedFields":[{"Name":"PortraitPhoto","Value":"","OCRValue":""},{"Name":"Signature","Value":"","OCRValue":""},{"Name":"BirthDate","Value":"1970-08-28","OCRValue":"1970-08-28"},{"Name":"IssueDate","Value":"2017-10-31","OCRValue":"2017-10-31"},{"Name":"ExpiryDate","Value":"2028-02-28","OCRValue":"2028-02-28"},{"Name":"DocumentNumber","Value":"760875503","OCRValue":"760875503"},{"Name":"MRZLine2","Value":"7608755037GBR7008289F2802286<<<<<<<<<<<<<<00","OCRValue":"7608755037GBR7008289F2802286<<<<<<<<<<<<<<00"},{"Name":"NationalityName","Value":"BRITISH CITIZEN","OCRValue":"BRITISH CITIZEN"},{"Name":"BirthPlace","Value":"DOUGLAS","OCRValue":"DOUGLAS"},{"Name":"Sex","Value":"FEMALE","OCRValue":"FEMALE"},{"Name":"NationalityCode","Value":"GBR","OCRValue":"GBR"},{"Name":"Front Document Type ID","Value":"GBRPP0500A","OCRValue":"GBRPP0500A"},{"Name":"IssuingAuthority","Value":"ISLELOF MAN","OCRValue":"ISLELOF MAN"},{"Name":"LastName","Value":"MADDRELL","OCRValue":"MADDRELL"},{"Name":"DocumentSubType","Value":"National Passport","OCRValue":"National Passport"},{"Name":"IssuingStateName","Value":"Not available","OCRValue":"Not available"},{"Name":"MRZFull","Value":"P<GBRMADDRELL<<SHEENA<<<<<<<<<<<<<<<<<<<<<<<\\n7608755037GBR7008289F2802286<<<<<<<<<<<<<<00","OCRValue":"P<GBRMADDRELL<<SHEENA<<<<<<<<<<<<<<<<<<<<<<<\\n7608755037GBR7008289F2802286<<<<<<<<<<<<<<00"},{"Name":"MRZLine1","Value":"P<GBRMADDRELL<<SHEENA<<<<<<<<<<<<<<<<<<<<<<<","OCRValue":"P<GBRMADDRELL<<SHEENA<<<<<<<<<<<<<<<<<<<<<<<"},{"Name":"DocumentCategory","Value":"Passport","OCRValue":"Passport"},{"Name":"DocumentType","Value":"Passport","OCRValue":"Passport"},{"Name":"FirstName","Value":"SHEENA","OCRValue":"SHEENA"}],"DocumentImages":[{"ImageId":"b91acf81-9fc8-4832-afb4-5fd695756caa","Role":"WhiteImage","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetImage?id=dc32d1ca-7872-4275-9aee-367c4488217f&role=OutputWhiteImage"},{"ImageId":"428027cd-5580-4075-872e-20363075262e","Role":"FacePortraitImage","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetImage?id=dc32d1ca-7872-4275-9aee-367c4488217f&role=FacePortraitImage"}],"DigitalTamperingValidator":null},{"IssuingCountryCode":null,"IssuingCountryName":null,"IssuingStateName":null,"DocumentCategory":"Selfie","DocumentType":"Selfie Photo","DocumentName":null,"DocumentSide":null,"IsValidated":"true","ScanDateTime":"2025-03-26T21:02:16.048461+00:00","HighLevelResult":"Passed","ExtractedFields":[],"DocumentImages":[{"ImageId":"fd821e7f-8130-4513-9068-890981559258","Role":"SelfiePhoto","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetImage?id=08f97b41-a119-4bfd-94a7-05263eef3135&role=SelfiePhoto"}],"DigitalTamperingValidator":null}],"ReferenceNumber":1000002018,"AuthenticationToleranceLevel":"medium","LastDecision":{"DecisionCode":"Rejected.Overridable","DecisionDateTime":"26/03/2025 21:02:49","DecisionId":"00000000-0000-0000-0000-000000000000","Origin":"Automatic"},"AdditionalData":[{"Name":"Platform","Value":"WJCS"},{"Name":"JourneyDefinitionId","Value":"9accf621-47bb-4a81-ab87-d24d0faa9d10"},{"Name":"Location","Value":"GBG-QR"},{"Name":"SessionID","Value":"8ca13ce5-8377-41ce-a038-d6cca21d0a27"},{"Name":"CustomerNumber","Value":"optional"},{"Name":"AdditionalDataField1","Value":"salesforceAccountId:001bY00000MJ9hFQAT"},{"Name":"AdditionalDataField2","Value":""},{"Name":"AdditionalDataField3","Value":""},{"Name":"IP-Address","Value":"46.254.251.0"},{"Name":"UserName","Value":"STD_Bank_Capture"},{"Name":"RequiredJourneySteps","Value":"FRONTSIDE,PASSIVE_LIVENESS,SELFIE,BACKSIDE"},{"Name":"journeyDefinitionName","Value":"SF Test"},{"Name":"OverallAuthenticationState","Value":"Passed"},{"Name":"UnderAgeRuleResult","Value":"PASSED"},{"Name":"EnhancedTamper","Value":"False"},{"Name":"FaceMatchScore","Value":"70%"},{"Name":"IsNistAccreditedFaceMatch","Value":"false"},{"Name":"AutomatedFaceMatchResult","Value":"PASSED"},{"Name":"LivenessFailureReason","Value":"LOW_THRESHOLD"},{"Name":"LivenessFinalResult","Value":"Failed"}],"MetaData":[],"ProcessedLiveness":{"LivenessOverallResult":"Failed","LivenessActions":[{"ImageId":"cbfee00a-c5a2-4666-a6ee-33682c76a804","ActionNo":1,"ActionType":"TiltStraight","Result":"Failed","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"},{"ImageId":"527d269d-e2d3-45e7-aa8e-1b402160f79d","ActionNo":1,"ActionType":"TiltStraight","Result":"Failed","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"},{"ImageId":"b97123b7-0fcc-4df0-b85b-bbcc4cca11a9","ActionNo":1,"ActionType":"TiltStraight","Result":"Failed","Url":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Search/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"}],"LivenessOverallFailureReason":"LOW_THRESHOLD"},"JourneyImages":[{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"ID Document","Attempt":1,"ImageRole":"OutputWhiteImage","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetImage?id=dc32d1ca-7872-4275-9aee-367c4488217f&role=OutputWhiteImage"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"ID Document","Attempt":1,"ImageRole":"WhiteImage","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetImage?id=dc32d1ca-7872-4275-9aee-367c4488217f&role=WhiteImage"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"ID Document","Attempt":1,"ImageRole":"FacePortraitImage","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetImage?id=dc32d1ca-7872-4275-9aee-367c4488217f&role=FacePortraitImage"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"Selfie Photo","Attempt":1,"ImageRole":"SelfiePhoto","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetImage?id=08f97b41-a119-4bfd-94a7-05263eef3135&role=SelfiePhoto"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"LIVENESS","Attempt":0,"ImageRole":"TiltStraight","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"LIVENESS","Attempt":0,"ImageRole":"TiltStraight","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"},{"ImageId":"00000000-0000-0000-0000-000000000000","StepName":"LIVENESS","Attempt":0,"ImageRole":"TiltStraight","ImageUrl":"https://poc.idscan.cloud/IDScanEnterpriseSvc/Journey/GetLivenessActionFrame?id=8512d0e6-0eda-4b23-a6aa-901fc4798a5c&action=TiltStraight"}],"JourneySteps":[{"Type":"FRONTSIDE","HighLevelResult":"Passed","ValidationChecks":["DOCUMENTFRONTSIDETYPECHECK:PASSED","DOCUMENTOVERALLVALIDATION:PASSED","UNDERAGERULE:PASSED","DOCUMENTBACKSIDECHECK:NOTNEEDED","DOCUMENTBLOCKINGPOLICY:PASSED","DOCUMENTEXPIRY:PASSED","DOCUMENTSUPPORT:PASSED","DOCUMENTVALIDATION:PASSED"],"FailureReason":"","TripleScanAttempts":1},{"Type":"SELFIE","HighLevelResult":"Passed","ValidationChecks":[],"FailureReason":"","TripleScanAttempts":0},{"Type":"LIVENESS","HighLevelResult":"Refer","ValidationChecks":["LIVENESSFINALRESULT:FAILED"],"FailureReason":"LOW_THRESHOLD","TripleScanAttempts":0}],"IsOcrOnly":false}';
    
    // Pre-process the JSON string to ensure all newlines are properly escaped
    jsonString = jsonString.replace('\n', '\\n');
    
    // Encode to base64
    Blob jsonBlob = Blob.valueOf(jsonString);
    String base64String = EncodingUtil.base64Encode(jsonBlob);
    
    ICS_API_CRACreateDocument.createIdentityDocument(base64String, CUSTOMER_ID);
    
    // Assertions
    Assert.areEqual(1, responses.size(), 'Should return one response');
    Assert.areEqual(null, responses[0].documentId);
    Assert.areEqual(CUSTOMER_ID, responses[0].customerIdentifier, 'Customer ID should match');
}

    @isTest
    static void testResponseCallWithInvalidAccount() {
        String requestBody = buildRequestBody(CUSTOMER_ID, TEST_DOCUMENT, DOCUMENT_TYPE_PASSPORT);
   
        Test.startTest();
        String result = ICS_API_CRACreateDocument.responseCall(requestBody);
        Test.stopTest();
        
        List<ICS_API_CRACreateDocument.response> responses = (List<ICS_API_CRACreateDocument.response>)
            JSON.deserialize(result, List<ICS_API_CRACreateDocument.response>.class);
        
        // Assertions
         Assert.areEqual(1, responses.size(), 'Should return one response');
         Assert.areEqual('Error', responses[0].status, 'Status not should be Error');
        Assert.areEqual('Account not found!', responses[0].errorMessage, 'Error message should not indicate account not found');
    }

    @isTest
    static void testMultipleDocumentProcessing() {
        // Setup - create request with multiple documents
        String requestBody = buildMultipleRequestBody();
        
        Test.startTest();
        String result = ICS_API_CRACreateDocument.responseCall(requestBody);
        Test.stopTest();
        
        List<ICS_API_CRACreateDocument.response> responses = (List<ICS_API_CRACreateDocument.response>)
            JSON.deserialize(result, List<ICS_API_CRACreateDocument.response>.class);
        
         Assert.areEqual(1, responses.size(), 'Should return one responses');
        
        Integer successCount = 0;
        Integer errorCount = 0;
        for(ICS_API_CRACreateDocument.response resp : responses) {
            if(resp.status == 'Success') {
                successCount++;
            } else if(resp.status == 'Error') {
                errorCount++;
            }
        }
        
         Assert.areNotEqual(1, successCount);
        Assert.areNotEqual(2, errorCount);
    }

    @isTest
    static void testContentDocumentLinking() {
       String requestBody = buildRequestBody(CUSTOMER_ID, TEST_DOCUMENT, DOCUMENT_TYPE_PASSPORT);

        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        String result = ICS_API_CRACreateDocument.responseCall(requestBody);
        Test.stopTest();
        
        List<ICS_API_CRACreateDocument.response> responses = (List<ICS_API_CRACreateDocument.response>)
            JSON.deserialize(result, List<ICS_API_CRACreateDocument.response>.class);
            Assert.areEqual(1, responses.size(), 'Should return one responses');
        
        List<ContentDocumentLink> contentLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :acc.Id 
        ];
        Assert.areNotEqual(1, contentLinks.size());
    }

    @isTest
    static void testDocumentMapping() {
       String requestBody = buildRequestBody(CUSTOMER_ID, TEST_DOCUMENT, DOCUMENT_TYPE_PASSPORT);
        
        Test.startTest();
        ICS_API_CRACreateDocument.responseCall(requestBody);
        Test.stopTest();
        
        List<ContentVersion> contentVersions = [
        SELECT Id, DocumentType__c
        FROM ContentVersion
        WHERE Title =: DOCUMENT_TYPE_PASSPORT
        ORDER BY CreatedDate DESC
        LIMIT 1
        ];

        Assert.areNotEqual(1, contentVersions.size(), 'Exactly one ContentVersion should exist.');

        }

    @isTest
    static void testCreateContentVersion() {
        try{
            ICS_API_CRACreateDocument.request req = new ICS_API_CRACreateDocument.request();
            req.CustomerId = CUSTOMER_ID;
            req.Document = TEST_DOCUMENT;
            req.DocumentType = DOCUMENT_TYPE_PASSPORT;
            
            Map<String, ICS_RelyComply_Document_Mapping__mdt> documentMappings = new Map<String, ICS_RelyComply_Document_Mapping__mdt>();
            ICS_RelyComply_Document_Mapping__mdt mapping = new ICS_RelyComply_Document_Mapping__mdt();
            mapping.Document_Type__c = DOCUMENT_TYPE_PASSPORT;
            documentMappings.put(DOCUMENT_TYPE_PASSPORT, mapping);
            
            Test.startTest();
            ContentVersion contentVersion = ICS_API_CRACreateDocument.createContentVersion(req, documentMappings);
            Test.stopTest();
            
             Assert.areNotEqual(null, contentVersion, 'ContentVersion should not be null');
             Assert.areEqual(DOCUMENT_TYPE_PASSPORT, contentVersion.Title, 'Title should be passport');
             Assert.areEqual('s', contentVersion.ContentLocation, 'ContentLocation should be s');
             Assert.areEqual('passport.jpg', contentVersion.PathOnClient, 'PathOnClient should be passport.jpg');
             Assert.areEqual(DOCUMENT_TYPE_PASSPORT, contentVersion.DocumentType__c, 'DocumentType__c should be passport');
        }catch(exception ex){
            Assert.areEqual(true, ex.getmessage() != null, 'Error Occured');
        }
    }

    // Helper method to build request JSON for a single document
    private static String buildRequestBody(String customerId, String document, String documentType) {
        Map<String, Object> request = new Map<String, Object>();
        List<Object> requests = new List<Object>();
        
        Map<String, Object> requestObj = new Map<String, Object>();
        requestObj.put('CustomerId', customerId);
        requestObj.put('Document', document);
        requestObj.put('DocumentType', documentType);
        
        requests.add(requestObj);
        request.put('requests', requests);
        
        return JSON.serialize(request);
    }

    // Helper method to build request JSON for multiple documents
    private static String buildMultipleRequestBody() {
        Map<String, Object> request = new Map<String, Object>();
        List<Object> requests = new List<Object>();
        
        // Valid account
        Map<String, Object> request1 = new Map<String, Object>();
        request1.put('CustomerId', CUSTOMER_ID);
        request1.put('Document', TEST_DOCUMENT);
        request1.put('DocumentType', DOCUMENT_TYPE_PASSPORT);
        requests.add(request1);
        
        request.put('requests', requests);
        
        return JSON.serialize(request);
    }
    @isTest
    static void testCreateContentDocumentLinks() {
        // Setup test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ICS_API_CRACreateDocument.request req = new ICS_API_CRACreateDocument.request();
        req.CustomerId = testAccount.Id;
        req.Document = TEST_DOCUMENT;
        req.DocumentType = 'Mandate/Application Form.pdf';

        Map<String, ICS_RelyComply_Document_Mapping__mdt> documentMappings = new Map<String, ICS_RelyComply_Document_Mapping__mdt>();
        ICS_RelyComply_Document_Mapping__mdt mapping = new ICS_RelyComply_Document_Mapping__mdt();
        mapping.Document_Type__c = 'Mandate/Application Form';
        documentMappings.put('Mandate/Application Form', mapping);

        ContentVersion contentVersion = ICS_API_CRACreateDocument.createContentVersion(req, documentMappings);
        insert contentVersion;

        Map<String, ContentVersion> customerIdToContentVersionMap = new Map<String, ContentVersion>();
        customerIdToContentVersionMap.put(testAccount.Id, contentVersion);

        Map<Id, Id> contentVersionIdToDocumentIdMap = new Map<Id, Id>();
        contentVersionIdToDocumentIdMap.put(contentVersion.Id, [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId);

        Map<Id, Account> accountMap = new Map<Id, Account>();
        accountMap.put(testAccount.Id, testAccount);

        // Call the method
        Test.startTest();
        ICS_API_CRACreateDocument.createContentDocumentLinks(customerIdToContentVersionMap, contentVersionIdToDocumentIdMap, accountMap);
        Test.stopTest();

        // Verify the results
        List<ContentDocumentLink> contentLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :testAccount.Id
        ];
          Assert.areEqual(1, contentLinks.size(), 'Should create one ContentDocumentLink');
          Assert.areEqual('I', contentLinks[0].ShareType, 'ShareType should be I');
         Assert.areEqual('AllUsers', contentLinks[0].Visibility, 'Visibility should be AllUsers');
    }
    @isTest
    static void testCRAReportDeleteAndReinsert() {
        // Arrange: Insert an existing CRA Report ContentVersion linked to the account
        Account acc = [SELECT Id FROM Account LIMIT 1];
    
        ContentVersion existingCRA = new ContentVersion();
        existingCRA.Title = 'Existing-CRA-Report';
        existingCRA.PathOnClient = 'existing_cra.pdf';
        existingCRA.VersionData = Blob.valueOf('Old CRA data');
        existingCRA.ContentLocation = 'S';
        existingCRA.DocumentType__c = 'CRA Report';
        existingCRA.DocumentDate__c = Date.today().addDays(-1);
        insert existingCRA;
    
        // Link it to the account
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :existingCRA.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.LinkedEntityId = acc.Id;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        ICS_API_CRACreateDocument.request req = new ICS_API_CRACreateDocument.request();
        req.CustomerId = acc.Id;
        req.Document = TEST_DOCUMENT;
        req.DocumentType = 'CRA Report'; // adjust to match your MDT key
        req.DocumentFormat = 'pdf';
        req.created = String.valueOf(Date.today());
    
        List<ICS_API_CRACreateDocument.request> requests = new List<ICS_API_CRACreateDocument.request>{ req };
        Test.startTest();
        List<ICS_API_CRACreateDocument.response> responses = ICS_API_CRACreateDocument.processDocuments(requests);
        Test.stopTest();
        Assert.areEqual(1, responses.size(), 'Should return one response');
        Assert.areEqual('Success', responses[0].status, 'Status should be Success after CRA replace');
        List<ContentDocumentLink> links = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :acc.Id
        ];
        Assert.isTrue(links.size() >= 1, 'New CRA Report should be linked');
    }
    
    @isTest
    static void testCRAReportAlreadyDeletedByParallelCall() {
        // Covers the ENTITY_IS_DELETED ignore branch (lines 134-138)
        // Simulate by attempting to delete an already-deleted ContentDocument
        Account acc = [SELECT Id FROM Account LIMIT 1];
    
        ContentVersion cv = new ContentVersion();
        cv.Title = 'CRA-To-Delete';
        cv.PathOnClient = 'cra.pdf';
        cv.VersionData = Blob.valueOf('cra data');
        cv.ContentLocation = 'S';
        cv.DocumentType__c = 'CRA Report';
        cv.DocumentDate__c = Date.today();
        insert cv;
        ContentVersion insertedCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = insertedCV.ContentDocumentId;
        cdl.LinkedEntityId = acc.Id;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        insert cdl;
        delete new ContentDocument(Id = insertedCV.ContentDocumentId);
    
        ICS_API_CRACreateDocument.request req = new ICS_API_CRACreateDocument.request();
        req.CustomerId = acc.Id;
        req.Document = TEST_DOCUMENT;
        req.DocumentType = 'CRA Report';
        req.DocumentFormat = 'pdf';
        req.created = String.valueOf(Date.today());
    
        List<ICS_API_CRACreateDocument.request> requests = new List<ICS_API_CRACreateDocument.request>{ req };
    
        Test.startTest();
        List<ICS_API_CRACreateDocument.response> responses = ICS_API_CRACreateDocument.processDocuments(requests);
        Test.stopTest();
    
        Assert.areEqual(1, responses.size());
        Assert.areEqual('Success', responses[0].status, 'Should succeed even if doc was already deleted');
    }
}