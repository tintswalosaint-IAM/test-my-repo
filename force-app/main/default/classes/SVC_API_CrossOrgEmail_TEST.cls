/**
 * @description Test class for cross org case creation
 *
 * @see SVC_API_CrossOrgInboundContDoc
 * @see SVC_API_CrossOrgInboundEmailMessage
 * @see SVC_API_CrossOrgOutboundContDoc
 * @see SVC_API_CrossOrgOutboundEmailMessage
 * @see SVC_UTIL_CrossOrgs
 *
 * @author Angola Team
 *
 * @date September 2022
 */


@isTest(SeeAllData=false)
private class SVC_API_CrossOrgEmail_TEST {
    
    @TestSetup
    private static void svcApiCrossOrgEmailInsertData(){
        Account acc = new Account(
	        firstName = 'John',
            lastName = 'Smith'
        );

        insert acc;

        Case caseObj = new Case(
            Accountid = acc.id,
            Status = 'Working',
            Origin = 'Phone'
        );

        Case case2 = new Case(
            AccountId = acc.id,
            Status = 'Working',
            Origin = 'Email'
        );

        insert caseObj;
        insert case2;

        EmailMessage newEmailMessage = new EmailMessage(
                fromAddress = 'John123@gmail.com',
                fromName = 'John',
                toAddress = 'John321@gmail.com',
                subject = 'This is a Test',
                headers = '123 Teste 345 123 Teste 345 123 Teste 345 ',
                htmlBody = 'this is the htmlBody',
                textBody = 'this is the textBody',
                isBounced = false,
                parentId = caseObj.id
           );

        insert newEmailMessage;

        ContentVersion contentVersion = new ContentVersion(
                title = 'This is the ContentVersion Title',
                pathOnClient = 'Test pathOnClient',
                versionData = EncodingUtil.base64Decode('VersionNumber')
            );

        insert(contentVersion);

            ContentVersion conDocument = [SELECT ContentDocumentID FROM ContentVersion WHERE id=:contentVersion.id LIMIT 1];
            
            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
                LinkedEntityId = caseObj.id,
                ContentDocumentId = conDocument.ContentDocumentID,
                shareType = 'V',
                visibility = 'AllUsers'
            );

            Database.insert(contentDocumentLink);

    }

    /**
     * @description Test class for the outbound cross org callout, negative scenario
     */
    @isTest
    static void svcApiCrossOrgEmailNegative() {

        List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow> testDTORequests = new List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow>();

        SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow testDTORequest = new SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow();

        Case case1 = [SELECT id FROM Case WHERE Origin = 'Email' LIMIT 1];

        testDTORequest.namedCredential = null;
        testDTORequest.sourceCaseId = case1.id;
        testDTORequest.destinationCaseId = null;

        testDTORequests.add(testDTORequest);

        String jsonString = JSON.serialize(testDTORequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(400, 'Error', jsonString, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutBoundEmailMessage.sentCaseEmailsCrossOrg(testDTORequests);
        Test.stopTest();

        system.assertEquals(testDTORequest.namedCredential == null, true, 'Named Credential not null');
    }

    @isTest
    static void svcApiCrossOrgEmailPositive() {

        List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow> testDTORequests = new List<SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow>();

        SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow testDTORequest = new SVC_API_CrossOrgOutBoundEmailMessage.SVC_DTO_CrossOrgCaseEmailDestOrgRequestFromFlow();

        Case ca = [SELECT id FROM Case LIMIT 1];

        testDTORequest.namedCredential = 'BCWAogDev';
        testDTORequest.sourceCaseId = ca.id;
        testDTORequest.destinationCaseId = 'C-239213';

        testDTORequests.add(testDTORequest);

        String jsonString = JSON.serialize(testDTORequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(200, 'SUCCESS', jsonString, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutBoundEmailMessage.sentCaseEmailsCrossOrg(testDTORequests);
        Test.stopTest();

        system.assertEquals(testDTORequest.namedCredential == null, false, 'Named Credential not null');
    }

    @isTest
    static void svcApiCrossOrgFilesNegative() {

        List<SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow> testDTORequests = new List<SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow>();

        SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow testDTORequest = new SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow();

        Case case1 = [SELECT id FROM Case WHERE Origin = 'Email' LIMIT 1];

        testDTORequest.namedCredential = null;
        testDTORequest.sourceCaseId = case1.id;
        testDTORequest.destinationCaseId = null;

        testDTORequests.add(testDTORequest);

        String jsonString = JSON.serialize(testDTORequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(400, 'Error', jsonString, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutBoundContDoc.sentCaseContDocCrossOrg(testDTORequests);
        Test.stopTest();

        system.assertEquals(testDTORequest.namedCredential == null, true, 'Named Credential not null');
    }

    @isTest
    static void svcApiCrossOrgFilesPositive() {

        List<SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow> testDTORequests = new List<SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow>();

        SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow testDTORequest = new SVC_API_CrossOrgOutBoundContDoc.SVC_DTO_CrossOrgCaseContDocDestOrgRequestFromFlow();

        Case ca = [SELECT id FROM Case LIMIT 1];

        testDTORequest.namedCredential = 'BCWAogDev';
        testDTORequest.sourceCaseId = ca.id;
        testDTORequest.destinationCaseId = 'C-239213';

        testDTORequests.add(testDTORequest);

        String jsonString = JSON.serialize(testDTORequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(200, 'SUCCESS', jsonString, new Map<String,String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutBoundContDoc.sentCaseContDocCrossOrg(testDTORequests);
        Test.stopTest();

        system.assertEquals(testDTORequest.namedCredential == null, false, 'Named Credential is null');
    }

    /**
     * @description Test class for the inbound cross org post call, positive scenario
     */
    @IsTest
    static void testInboundPostPositiveEmails()
    {
        /**
         * @note some destination orgs require an entitlement, and an account
         * linked to the entitlement.
         */
        Case testCase = new Case();
        insert testCase;

        Account testAccount = new Account();
        testAccount.Name = 'Test Class Account';
        insert testAccount;

        Entitlement defaultEntitlement =  new Entitlement();
        defaultEntitlement.Name = 'FR240mins : Mon - Fri (8h00 - 17h00)';
        defaultEntitlement.Account = testAccount;
        defaultEntitlement.AccountId = testAccount.Id;
        insert defaultEntitlement;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        User testUser = [SELECT Id, FederationIdentifier FROM USER WHERE FederationIdentifier != NULL LIMIT 1];
        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest outboundDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        outboundDtoRequest.namedCredential = 'BCWAogDev';
        outboundDtoRequest.federationId = testUser.FederationIdentifier;
        outboundDtoRequest.sourceCaseNumber = '123456';
        outboundDtoRequest.sourceCaseId = testCase.Id;

        req.requestURI = '/services/apexrest/CrossOrgInBoundEmailMessage/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(outboundDtoRequest));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInboundEmailMessage.doPostEmailMessage();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the inbound cross org post call, negative scenario
     */
    @IsTest
    static void testInboundPostNegativeEmails()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CrossOrgInBoundEmailMessage/';
        req.httpMethod = 'POST';
        req.requestBody = null;

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInboundEmailMessage.doPostEmailMessage();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the inbound cross org post call, positive scenario
     */
    @IsTest
    static void testInboundPostPositiveContDoc()
    {
        /**
         * @note some destination orgs require an entitlement, and an account
         * linked to the entitlement.
         */
        Case testCase = new Case();
        insert testCase;

        Account testAccount = new Account();
        testAccount.Name = 'Test Class Account';
        insert testAccount;

        Entitlement defaultEntitlement =  new Entitlement();
        defaultEntitlement.Name = 'FR240mins : Mon - Fri (8h00 - 17h00)';
        defaultEntitlement.Account = testAccount;
        defaultEntitlement.AccountId = testAccount.Id;
        insert defaultEntitlement;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        User testUser = [SELECT Id, FederationIdentifier FROM USER WHERE FederationIdentifier != NULL LIMIT 1];
        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest outboundDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        outboundDtoRequest.namedCredential = 'BCWAogDev';
        outboundDtoRequest.federationId = testUser.FederationIdentifier;
        outboundDtoRequest.sourceCaseNumber = '123456';
        outboundDtoRequest.sourceCaseId = testCase.Id;

        req.requestURI = '/services/apexrest/CrossOrgInBoundContDoc/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(outboundDtoRequest));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInboundContDoc.doPost();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the inbound cross org post call, negative scenario
     */
    @IsTest
    static void testInboundPostNegativeContDoc()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CrossOrgInBoundContDoc/';
        req.httpMethod = 'POST';
        req.requestBody = null;

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInboundContDoc.doPost();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the outbound cross org callout, positive scenario
     */
    @IsTest
    static void testOutboundCalloutPositiveAngola()
    {
        Case testCase = new Case();
        insert testCase;

        List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest> testDTORequests = new List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest>();

        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest testDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        testDtoRequest.namedCredential = 'BCWVBDEV';
        testDtoRequest.federationId = 'relmanager@standardbank.co.za.bcwvbdev';
        testDtoRequest.destinationTeam = 'sampleTeam';
        testDtoRequest.sourceCaseNumber = '1234567890';
        testDtoRequest.sourceCaseId = testCase.Id;
        testDtoRequest.svcExternalCifCountry = 'AO';

        testDTORequests.add(testDtoRequest);

        SVC_API_CrossOrgOutbound.DTO_Response testDTOResponse = new SVC_API_CrossOrgOutbound.DTO_Response();
        testDTOResponse.caseId = 'C-1203';
        testDTOResponse.caseNumber = '1299321';
        testDTOResponse.message = 'Success';
        testDTOResponse.responseCode = 200;

        String jsonString = JSON.serialize(testDTOResponse);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(200, 'SUCCESS', jsonString, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutbound.initiateNewCase(testDTORequests);
        Test.stopTest();

        System.assertEquals(testDtoRequest.destinationTeam != null, true, 'Destination Team is null');
    }

    /**
     * @description Test class for the outbound cross org callout, negative scenario
     */
    @IsTest
    static void testOutboundCalloutNegativeAngola()
    {
        List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest> testDTORequests = new List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest>();

        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest testDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        testDtoRequest.namedCredential = null;
        testDtoRequest.federationId = null;
        testDtoRequest.destinationTeam = null;
        testDtoRequest.sourceCaseNumber = '1234567890';
        testDtoRequest.svcExternalCifCountry = 'AO';

        testDTORequests.add(testDtoRequest);

        SVC_API_CrossOrgOutbound.DTO_Response testDTOResponse = new SVC_API_CrossOrgOutbound.DTO_Response();
        testDTOResponse.caseId = 'C-1203';
        testDTOResponse.caseNumber = '1299321';
        testDTOResponse.message = 'Error';
        testDTOResponse.responseCode = 400;

        String jsonString = JSON.serialize(testDTOResponse);

        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(400, 'ERROR', jsonString, new Map<String, String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutbound.initiateNewCase(testDTORequests);
        Test.stopTest();

        System.assertEquals(testDtoRequest.destinationTeam == null, true, 'Destination team is not null');
    }
}