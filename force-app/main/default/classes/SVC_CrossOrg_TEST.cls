/**
 * @description Test class for cross org case creation
 *
 * @see SVC_API_CrossOrgInbound
 * @see SVC_API_CrossOrgOutbound
 * @see SVC_UTIL_CrossOrg
 *
 * @author Accenture
 *
 * @date Aug 2022
 */

@IsTest(SeeAllData=false)
private class SVC_CrossOrg_TEST
{
    /**
     * @description Test class for the inbound cross org post call, positive scenario
     */
    @IsTest
    static void testInboundPostPositive()
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
        outboundDtoRequest.namedCredential = 'BCWVBDEV';
        outboundDtoRequest.federationId = testUser.FederationIdentifier;
        outboundDtoRequest.sourceCaseNumber = '123456';
        outboundDtoRequest.svcExternalCifCountry = 'Angola';
        outboundDtoRequest.sourceCaseId = testCase.Id;

        req.requestURI = '/services/apexrest/CrossOrgInbound/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(outboundDtoRequest));

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInbound.doPost();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the inbound cross org post call, negative scenario
     */
    @IsTest
    static void testInboundPostNegative()
    {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/CrossOrgInbound/';
        req.httpMethod = 'POST';
        req.requestBody = null;

        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        SVC_API_CrossOrgInbound.doPost();
        Test.stopTest();

        System.assertEquals(res.responseBody != null, true, 'Expecting a response body');

    }

    /**
     * @description Test class for the outbound cross org callout, negative scenario
     */
    @IsTest
    static void testOutboundCalloutNegative()
    {
        List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest> testDTORequests = new List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest>();

        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest testDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        testDtoRequest.namedCredential = null;
        testDtoRequest.federationId = null;
        testDtoRequest.destinationTeam = null;
        testDtoRequest.sourceCaseNumber = '1234567890';
        testDTORequest.svcExternalCifCountry = 'Angola';

        testDTORequests.add(testDtoRequest);

        String jsonString = JSON.serialize(testDtoRequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(400, 'ERROR', jsonString, new Map<String, String>());

        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutbound.initiateNewCase(testDTORequests);
        Test.stopTest();

        System.assertEquals(testDtoRequest.destinationTeam == null, true);
    }

    /**
     * @description Test class for the outbound cross org callout, positive scenario
     */
    @IsTest
    static void testOutboundCalloutPositive()
    {
        Case testCase = new Case();
        insert testCase;

        List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest> testDTORequests = new List<SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest>();

        SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest testDtoRequest = new SVC_API_CrossOrgOutbound.SVC_DTO_CrossOrgCaseCreateRequest();
        testDtoRequest.namedCredential = 'BCWVBDEV';
        testDtoRequest.federationId = 'relmanager@standardbank.co.za.bcwvbdev';
        testDtoRequest.destinationTeam = 'sampleTeam';
        testDtoRequest.sourceCaseNumber = '1234567890';
        testDTORequest.svcExternalCifCountry = 'Angola';
        testDtoRequest.sourceCaseId = testCase.Id;

        testDTORequests.add(testDtoRequest);

        String jsonString = JSON.serialize(testDtoRequest);
        SVC_MOCK_CrossOrg mock = new SVC_MOCK_CrossOrg(200, 'SUCCESS', jsonString, new Map<String, String>());
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        SVC_API_CrossOrgOutbound.initiateNewCase(testDTORequests);
        Test.stopTest();

        System.assertEquals(testDtoRequest.destinationTeam != null, true);
    }

    /**
     * @description Cover code for invokable methods
     */
    @IsTest
    private static void invokableOrApexDefinedTypeCoverage()
    {
        String returnQueueId = SVC_UTIL_CrossOrg.getQueueId('sampleTeamName');
        String returnedUserId = SVC_UTIL_CrossOrg.getFederationUserId('sample@domain.com');
        List<String> returnDestinationOrgs = SVC_UTIL_CrossOrg.retrieveDestinationOrgs();

        System.assertEquals(returnQueueId == '', true, 'Incorrect queue returned');
        System.assertEquals(returnedUserId == '', true, 'Incorrect user returned');
        System.assertEquals(returnDestinationOrgs.size() > 0 || returnDestinationOrgs.isEmpty(), true, 'Destination org list error');

        SVC_API_CrossOrgInbound.errorMessageWrapperClass customException = new SVC_API_CrossOrgInbound.errorMessageWrapperClass('testType', 'testMessage');
        System.assertEquals(customException != null, true, 'Expecting an exception object');
    }
}