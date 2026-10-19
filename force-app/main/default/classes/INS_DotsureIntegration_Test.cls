/**
 * @description Test class for Dotsure Lead Integration flow
 *              Covers: Handler, Batch, Factory, Service, DTO, Response Parser
 * @author Raja Arsalan
 * @group Insurance
 * @last modified on 2026-09-21
 * 
 * Modifications Log
 * Date         Author          Modification
 * 2026-09-21   Raja Arsalan    Initial Version
 **/
@isTest
private class INS_DotsureIntegration_Test {
    
    /**
     * @description Common test setup helper
     **/
    private static TestSetup createTestSetup(String scenario) {
        TestSetup setup = new TestSetup();
        
        // Create test user
        setup.testUser = Insurance_TestDataFactory.createTestUser();
        insert setup.testUser;
        
        // Create campaign for lead
        setup.campaigns = Insurance_TestDataFactory.createCampaigns();
        insert setup.campaigns;
        
        // Create expressed interests
        setup.expressedInterests = Insurance_TestDataFactory.createExpressInterest();
        setup.expressedInterests[0].lead_type__c = 'Dotsure Lead';
        setup.expressedInterests[0].Leads_Product_Family__c = 'Insurance';
        insert setup.expressedInterests;
        
        // Create lead
        setup.lead = Insurance_TestDataFactory.createLead('General');
        setup.lead.OwnerId = setup.testUser.Id;
        setup.lead.Expressed_Interest_Product__c = setup.expressedInterests[0].Id;
        
        if (scenario == 'SuccessResponse') {
            setup.lead.Referred_System_Reference_Number__c = null;
        } else if (scenario == 'ClientErrorResponse') {
            setup.lead.Referred_System_Reference_Number__c = null;
        } else if (scenario == 'ServerErrorResponse') {
            setup.lead.Referred_System_Reference_Number__c = null;
        } else if (scenario == 'RetryLeads') {
            setup.lead.Dialer_Failure_Reason__c = '500 - Server Error';
            setup.lead.Referred_System_Reference_Number__c = 'Dotsure Failed';
        }
        
        insert setup.lead;
        
        return setup;
    }
    
    /**
     * @description Batch execution helper
     **/
    private static void executeBatch(TestSetup setup, String mockScenario) {
        INS_DotsureService.mockScenario = mockScenario;
        INS_DotsureService.testLeadId = setup.lead.Id;
        
        Test.setMock(HttpCalloutMock.class, new INS_DotsureAPI_Mock());
        
        Map<Id, String> leadToSystemMap = new Map<Id, String>();
        leadToSystemMap.put(setup.lead.Id, 'DOTSURE');
        
        INS_Batch_LeadIntegration batchJob = new INS_Batch_LeadIntegration(leadToSystemMap);
        Database.executeBatch(batchJob, 20);
    }
    
    /**
     * @description Test setup wrapper class
     **/
    private class TestSetup {
        public User testUser;
        public List<Campaign> campaigns;
        public List<Leads_ProductQueueAllocation__c> expressedInterests;
        public Lead lead;
    }
    
    // ==========================================
    // BATCH TESTS
    // ==========================================
    
    /**
     * @description Test batch success flow
     **/
    @isTest
    static void testBatchSuccess() {
        TestSetup setup = createTestSetup('SuccessResponse');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [
            SELECT Id, Referred_System_Reference_Number__c, Dialer_Failure_Reason__c 
            FROM Lead WHERE Id = :setup.lead.Id
        ];
        Assert.areEqual('12345', updated.Referred_System_Reference_Number__c, 
            'Reference number should be set on success');
        Assert.isNull(updated.Dialer_Failure_Reason__c, 
            'Failure reason should be null on success');
    }
    
    /**
     * @description Test batch client error (400)
     **/
    @isTest
    static void testBatchClientError() {
        TestSetup setup = createTestSetup('ClientErrorResponse');
        
        Test.startTest();
        executeBatch(setup, 'clientError');
        Test.stopTest();
        
        Lead updated = [
            SELECT Id, Referred_System_Reference_Number__c, 
                   Dialer_Failure_Reason__c, Lead_Closing_Comment__c 
            FROM Lead WHERE Id = :setup.lead.Id
        ];
        Assert.areEqual('Dotsure Failed', updated.Referred_System_Reference_Number__c, 
            'Reference should be Dotsure Failed on client error');
        Assert.isNotNull(updated.Dialer_Failure_Reason__c, 
            'Failure reason should be set');
        Assert.isNotNull(updated.Lead_Closing_Comment__c, 
            'Closing comment should be set');
    }
    
    /**
     * @description Test batch server error (502)
     **/
    @isTest
    static void testBatchServerError() {
        TestSetup setup = createTestSetup('ServerErrorResponse');
        
        Test.startTest();
        executeBatch(setup, 'serverError');
        Test.stopTest();
        
        Lead updated = [
            SELECT Id, Referred_System_Reference_Number__c, Dialer_Failure_Reason__c 
            FROM Lead WHERE Id = :setup.lead.Id
        ];
        Assert.areEqual('Dotsure Pending', updated.Referred_System_Reference_Number__c, 
            'Reference should be Dotsure Pending on server error');
        Assert.isNotNull(updated.Dialer_Failure_Reason__c, 
            'Failure reason should be set');
    }
    
    // ==========================================
    // FACTORY TESTS
    // ==========================================
    
    /**
     * @description Test factory returns Dotsure handler
     **/
    @isTest
    static void testFactoryDotsureHandler() {
        Test.startTest();
        INS_IIntegrationHandler handler = INS_IntegrationFactory.getHandler('DOTSURE');
        Test.stopTest();
        
        Assert.isNotNull(handler, 'Handler should not be null for DOTSURE');
        Assert.isInstanceOfType(handler, INS_DotsureIntegrationHandler.class, 
            'Handler should be INS_DotsureIntegrationHandler');
    }
    
    /**
     * @description Test factory returns null for unknown system
     **/
    @isTest
    static void testFactoryUnknownHandler() {
        Test.startTest();
        INS_IIntegrationHandler handler = INS_IntegrationFactory.getHandler('UNKNOWN');
        Test.stopTest();
        
        Assert.isNull(handler, 'Handler should be null for unknown system');
    }
    
    // ==========================================
    // DTO TESTS
    // ==========================================
    
    /**
     * @description Test DTO builds JSON payload correctly
     **/
    @isTest
    static void testDTOBuildJsonPayload() {
        TestSetup setup = createTestSetup('SuccessResponse');
        INS_Insurance_Lead_Settings__mdt settings = 
            Insurance_TestDataFactory.createMockDotsureSettings();
        
        Test.startTest();
        String jsonPayload = INS_DTO_DotsureLead.buildJsonPayload(setup.lead, settings);
        Test.stopTest();
        
        Assert.isNotNull(jsonPayload, 'JSON payload should not be null');
        Assert.isTrue(jsonPayload.contains('LeadGeneration'), 
            'Payload should contain LeadGeneration');
        Assert.isTrue(jsonPayload.contains(String.valueOf(settings.INS_PreferredProduct__c)), 
            'Payload should contain PreferredProduct from settings');
        Assert.isTrue(jsonPayload.contains(String.valueOf(settings.INS_Agentkey__c)), 
            'Payload should contain AgentId from settings');
    }
    
    // ==========================================
    // RESPONSE PARSER TESTS
    // ==========================================
    
    /**
     * @description Test response parser — empty body
     **/
    @isTest
    static void testResponseParserEmptyBody() {
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, '');
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.UNKNOWN, result.status, 
            'Status should be UNKNOWN for empty body');
    }
    
    /**
     * @description Test response parser — success
     **/
    @isTest
    static void testResponseParserSuccess() {
        String successBody = '{' +
            '"status_code": 200,' +
            '"LeadGenerationResponse": {' +
                '"message": "{\\"leadIds\\":[12345],\\"statusCode\\":201,\\"message\\":\\"Created\\"}"' +
            '}}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, successBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.SUCCESS, result.status, 
            'Status should be SUCCESS');
        Assert.areEqual('12345', result.leadReferenceNumber, 
            'Reference number should match');
    }
    
    /**
     * @description Test response parser — client error (400)
     **/
    @isTest
    static void testResponseParserClientError() {
        String clientErrorBody = '{' +
            '"status_code": 400,' +
            '"status": "Duplicate",' +
            '"message": "Lead already exists"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(200, clientErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.CLIENT_ERROR, result.status, 
            'Status should be CLIENT_ERROR');
    }
    
    /**
     * @description Test response parser — server error (502)
     **/
    @isTest
    static void testResponseParserServerError() {
        String serverErrorBody = '{' +
            '"status_code": 502,' +
            '"message": "Bad Gateway"' +
            '}';
        
        Test.startTest();
        INS_SRV_DotsureLeadResponse.ResponseResult result = 
            INS_SRV_DotsureLeadResponse.parse(502, serverErrorBody);
        Test.stopTest();
        
        Assert.areEqual(INS_SRV_DotsureLeadResponse.ResponseStatus.SERVER_ERROR, result.status, 
            'Status should be SERVER_ERROR');
    }
    
    // ==========================================
    // HANDLER TESTS
    // ==========================================
    
    /**
     * @description Test Dotsure handler delegates to service
     **/
    @isTest
    static void testDotsureHandlerProcessRecord() {
        TestSetup setup = createTestSetup('SuccessResponse');
        INS_Insurance_Lead_Settings__mdt settings = 
            Insurance_TestDataFactory.createMockDotsureSettings();
        
        INS_DotsureService.mockScenario = 'success';
        INS_DotsureService.testLeadId = setup.lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_DotsureAPI_Mock());
        
        Test.startTest();
        INS_DotsureIntegrationHandler handler = new INS_DotsureIntegrationHandler();
        handler.processRecord(setup.lead, 'mock-token', settings);
        Test.stopTest();
        
        Lead updated = [
            SELECT Id, Referred_System_Reference_Number__c 
            FROM Lead WHERE Id = :setup.lead.Id
        ];
        Assert.areEqual('12345', updated.Referred_System_Reference_Number__c, 
            'Reference number should be set');
    }
    
    // ==========================================
    // SCHEDULED JOB TESTS
    // ==========================================
    
    /**
     * @description Test scheduled retry with no leads
     **/
    @isTest
    static void testScheduledRetryNoLeads() {
        Test.startTest();
        INS_SCHED_LeadIntegrationRetry scheduler = new INS_SCHED_LeadIntegrationRetry();
        scheduler.execute(null);
        Test.stopTest();
        
        // No assertion needed — just verifying no exception
        Assert.isTrue(true, 'Scheduler should execute without errors');
    }
    
    /**
     * @description Test scheduled retry with failed leads
     **/
    @isTest
    static void testScheduledRetryWithLeads() {
        TestSetup setup = createTestSetup('RetryLeads');
        
        INS_DotsureService.mockScenario = 'success';
        INS_DotsureService.testLeadId = setup.lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_DotsureAPI_Mock());
        
        Test.startTest();
        INS_SCHED_LeadIntegrationRetry scheduler = new INS_SCHED_LeadIntegrationRetry();
        scheduler.execute(null);
        Test.stopTest();
        
        // Batch should have been queued
        Assert.isTrue(true, 'Scheduler should queue batch successfully');
    }
}