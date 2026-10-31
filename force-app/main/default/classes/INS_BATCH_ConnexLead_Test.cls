
/**
* @description       : Test for INS_BATCH_ConnexLead
* @author            : Raja Arsalan
* @group             : Smartenup
* @User Story        : SFP-44418
* @last modified on  : 28-01-2026
* @last modified by  : Raja Arsalan

* Change log
* 2026-01-28   Raja Arsalan    SFP-52529 - Added new method to the test class (testExtractErrorMessageWithDTO, testExtractFromErrorsArrayWithTitleFallback, testExtractFromErrorsArrayDirect, testParseNestedErrorWithErrorMessage, testParseNestedErrorWithErrorMessage, testParseNestedErrorWithErrorsArray)

*/


@isTest
private class INS_BATCH_ConnexLead_Test {
    
    /**
* @description Common test setup helper
*/
    private static TestSetup createTestSetup(String scenario) {
        TestSetup setup = new TestSetup();
        
        setup.testUser = Insurance_TestDataFactory.createTestUser();
        if (scenario == 'LeadQualify') {
            setup.testUser.EmployeeNumber = '123456';
        }
        insert setup.testUser;
        
        setup.campaigns = Insurance_TestDataFactory.createCampaigns();
        if (scenario == 'withoutDailLerQueueId') {
            for (Campaign cam : setup.campaigns) {
                cam.Dialler_System_Code__c = null;
            }
        }
        insert setup.campaigns;
        
        setup.expressedInterests = Insurance_TestDataFactory.createExpressInterest();
        insert setup.expressedInterests;
        
        setup.mockSettings = Insurance_TestDataFactory.createMockLeadSettings();
        
        setup.lead = createScenarioLead('General', scenario, setup);
        insert setup.lead;
        
        return setup;
    }
    
    
    
    /**
* @description Lead creation based on scenario
*/
    private static Lead createScenarioLead(String leadType, String scenario, TestSetup setup) {
        Lead lead = Insurance_TestDataFactory.createLead(leadType);
        lead.OwnerId = setup.testUser.Id;
        lead.Expressed_Interest_Product__c = setup.expressedInterests[0].Id;
        
        if (scenario == 'FuturePreferredTimeLead') {
            lead.Preferred_Contact_Date_Time__c = DateTime.now().addDays(1);
        } else if (scenario == 'PastPreferredTimeLead') {
            lead.Preferred_Contact_Date_Time_End__c = DateTime.now().addDays(-1);
        } else if (scenario == 'SuccessResponseOnUpdate' || scenario == 'UpdateSuccessResponse'|| scenario == 'Update502Response') {
            lead.Referred_System_Reference_Number__c = 'existing-ref';
        } else if (scenario == 'LeadQualify' || scenario == 'LeadExpiry') {
            lead.Referred_System_Reference_Number__c = '12345';
        } else if (scenario == 'IncorrectNumber') {
            lead.MobilePhone = '12';
            lead.Phone = '23';
        } else if (scenario == 'ExpressedInterestChanged') {
            // ── ADDED ─────────────────────────────────────────────────────────
            // This scenario represents a lead that was previously created in the
            // dialler (it has a Referred_System_Reference_Number__c) and whose
            // Expressed_Interest_Product__c has just changed.
            //
            // The two-step flow requires:
            //   1. A non-blank ref# so the PUT can target /<refNum>/LeadEnhancement
            //   2. A valid Dialler_Queue_ID__c (set by factory default 'Queue1')
            //   3. A valid MobilePhone (set by factory default '0720000000')
            // ──────────────────────────────────────────────────────────────────
            lead.Referred_System_Reference_Number__c = 'existing-ref';
        }
        
        return lead;
    }
    
    /**
* @description Batch execution helper
*/
    private static void executeBatch(TestSetup setup, String mockScenario) {
        INS_Leads_API.mockScenario = mockScenario;
        INS_Leads_API.testLeadId = setup.lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_LeadsAPI_Mock());
        
        INS_BATCH_ConnexLead batchJob = new INS_BATCH_ConnexLead(
            false,
            null,
            setup.mockSettings.INS_LeadType__c,
            setup.mockSettings.INS_ProductFamily__c,
            setup.mockSettings.INS_LeadDate__c != null ? setup.mockSettings.INS_LeadDate__c.date() : null,
            new List<String>{setup.lead.Id}
        );
        
        Database.executeBatch(batchJob, 15);
    }
    
    /**
* @description Test setup wrapper class (inner class)
*/
    private class TestSetup {
        public User testUser;
        public List<Campaign> campaigns;
        public List<Leads_ProductQueueAllocation__c> expressedInterests;
        public INS_Insurance_Lead_Settings__mdt mockSettings;
        public Lead lead;
    }
    
    /**
* @description Test for SuccessResponse
*/ 
    @isTest static void testSuccessResponse() {
        TestSetup setup = createTestSetup('SuccessResponse');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should not be empty on success');
    }
    
    /**
* @description Test for FuturePreferredTimeLead
*/ 
    @isTest static void testFuturePreferredTimeLead() {
        TestSetup setup = createTestSetup('FuturePreferredTimeLead');
        
        // No batch execution for future preferred time
        Test.startTest();
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual(NULL, updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should be NULL');
    }
    
    /**
* @description Test for PastPreferredTimeLead
*/ 
    @isTest static void testPastPreferredTimeLead() {
        TestSetup setup = createTestSetup('PastPreferredTimeLead');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Referred_System_Reference_Number__c should not be empty on success');
    }
    
    /**
* @description Test for SuccessResponseOnUpdate
*/ 
    @isTest static void testSuccessResponseOnUpdate() {
        TestSetup setup = createTestSetup('SuccessResponseOnUpdate');
        
        // Update lead
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Expressed_Interest_Product__c = setup.expressedInterests[1].Id;
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Expressed_Interest_Product__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areNotEqual(setup.expressedInterests[0].Id, updated.Expressed_Interest_Product__c,'Expressed_Interest_Product__c should not match');
    }
    
    /**
* @description Test for LeadQualify scenario
*/  
    @isTest static void testLeadQualify() {
        TestSetup setup = createTestSetup('LeadQualify');
        
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Status = 'Qualified';
        leadRecord[0].Dialer_Agent_Id__c = '123456';
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT OwnerId FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual(setup.testUser.Id, updated.OwnerId,' OwnerId should not match');
    }
    
    /**
* @description Test for LeadExpiry scenario
*/ 
    @isTest static void testLeadExpiry() {
        TestSetup setup = createTestSetup('LeadExpiry');
        
        CMN_TRH_Lead.skipConnexCallout = true;
        SEL_Lead leadSelector = new SEL_Lead();
        List<Lead> leadRecord = leadSelector.selectLeadByRecId(setup.lead.Id);
        leadRecord[0].Status = 'Unqualified';
        Update leadRecord[0];
        CMN_TRH_Lead.skipConnexCallout = false;
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Stage__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Closed Lost', updated.Stage__c,'Lead has been expired in salesforce');
    }
    
    /**
* @description Test for withoutDailLerQueueId
*/ 
    @isTest static void testwithoutDailLerQueueId() {
        TestSetup setup = createTestSetup('withoutDailLerQueueId');
        
        Test.startTest();
        executeBatch(setup, 'Queuefailure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Dialler Queue ID is missing on the lead record.', updated.Dialer_Failure_Reason__c,'Lead failed because it does not have queue Id');
    }
    
    /**
* @description Test for IncorrectNumber
*/ 
    @isTest static void testIncorrectNumber() {
        TestSetup setup = createTestSetup('IncorrectNumber');
        
        Test.startTest();
        executeBatch(setup, 'Queuefailure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Invalid format detected for Mobile Phone or Phone.', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    }
    
    /**
* @description Test for FailureResponse
*/ 
    @isTest static void testFailureResponse() {
        TestSetup setup = createTestSetup('FailureResponse');
        
        Test.startTest();
        executeBatch(setup, 'failure');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Invalid phone', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    } 
    
    /**
* @description Test for ServerFailure
*/ 
    @isTest static void testServerFailure() {
        TestSetup setup = createTestSetup('ServerFailure');
        
        Test.startTest();
        executeBatch(setup, 'ServerError');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex POST API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should not be empty on failure');
    } 
    
    /**
* @description Test for ScheduleMe
*/ 
    @isTest static void testScheduleMe() {
        Test.startTest();
        INS_BATCH_ConnexLead.scheduleMe();
        Test.stopTest(); 
    }
    
    /**
* @description Test for UpdateSuccessResponse
*/ 
    @isTest static void testUpdateSuccessResponse() {
        TestSetup setup = createTestSetup('UpdateSuccessResponse');
        
        Test.startTest();
        executeBatch(setup, 'success');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('mock-ref-id', updated.Referred_System_Reference_Number__c,'Reference Number matches');
        // ── CHANGED (test fix) ────────────────────────────────────────────────
        // BEFORE: Assert.areEqual(null, ...) — incorrect expectation.
        // parsePutResponse sets Dialer_Failure_Reason__c = '' (empty string, not null)
        // on success so the field gets cleared in the DML update. A null assertion
        // would fail because the database stores '' and returns '' on query.
        // AFTER: Assert blank (covers both null and '') which is the correct
        // post-success state for this field.
        // ─────────────────────────────────────────────────────────────────────
        Assert.isTrue(String.isBlank(updated.Dialer_Failure_Reason__c), 'Update Successful, failure Reason Should be blank');
    }
    
    /**
* @description Test for BuildErrorLeadFailure
*/ 
    @isTest static void testBuildErrorLeadFailure() {
        TestSetup setup = createTestSetup('BuildErrorLeadFailure');
        
        Test.startTest();
        
        executeBatch(setup, '502Error');
        Test.stopTest();
        
        Lead updated = [SELECT Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex POST API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should match the failure message');
    }
    
    /**
* @description Test for Update502Response
*/ 
    @isTest static void testUpdate502Response() {
        TestSetup setup = createTestSetup('Update502Response');
        
        Test.startTest();
        executeBatch(setup, '502Error');
        Test.stopTest();
        
        Lead updated = [SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c FROM Lead WHERE Id = :setup.lead.Id];
        Assert.areEqual('Unknown error from Connex PUT API', updated.Dialer_Failure_Reason__c,'Dialer_Failure_Reason__c should match the failure message');
    } 
    
    
    /**
* @description Test for GetObjectType
*/ 
    @isTest static void testGetObjectType() {
        INS_DTO_UpdateConnexLeadResponse dto = new INS_DTO_UpdateConnexLeadResponse();
        Type result = dto.getObjectType();
        Assert.areEqual(INS_DTO_UpdateConnexLeadResponse.class, result, 'The returned type should be INS_DTO_UpdateConnexLeadResponse');
    }
    
    
    /**
* @description Test parseNestedError with valid nested JSON containing 'errors' array
*
* WHY THIS CALLS INS_SRV_DiallerLeadResponse:
*   parseNestedError was originally in INS_UTIL_ConnexLeads but was moved to
*   INS_SRV_DiallerLeadResponse during the response-parsing refactor. The test
*   must call the class where the method now lives.
*/
    @isTest static void testParseNestedErrorWithErrorsArray() {
        String nestedJson = '{"errors":[{"detail":"This is an error detail","title":"Error Title"}]}';
        String result = INS_SRV_DiallerLeadResponse.parseNestedError(nestedJson);
        
        Assert.areEqual('This is an error detail', result, 'Should extract the detail from errors array');
    }
    
    /**
* @description Test parseNestedError with nested JSON containing 'errorMessage'
*/
    @isTest static void testParseNestedErrorWithErrorMessage() {
        String nestedJson = '{"error":{"errorMessage":"Nested error message here"}}';
        String result = INS_SRV_DiallerLeadResponse.parseNestedError(nestedJson);
        
        Assert.areEqual('Nested error message here', result, 'Should extract the errorMessage from nested error');
    }
    
    /**
* @description Test extractFromErrorsArray directly
*
* WHY THIS CALLS INS_SRV_DiallerLeadResponse:
*   extractFromErrorsArray was moved to INS_SRV_DiallerLeadResponse with the
*   response-parsing refactor. Same reason as parseNestedError above.
*/
    @isTest static void testExtractFromErrorsArrayDirect() {
        List<Object> errorsList = new List<Object>{
            new Map<String, Object>{ 'detail' => 'First detail', 'title' => 'First title' },
                new Map<String, Object>{ 'detail' => 'Second detail', 'title' => 'Second title' }
        };
            
        String result = INS_SRV_DiallerLeadResponse.extractFromErrorsArray(errorsList);
        Assert.areEqual('First detail', result, 'Should return the detail of the first error object');
    }
    
    /**
* @description Test extractFromErrorsArray with title fallback
*/
    @isTest static void testExtractFromErrorsArrayWithTitleFallback() {
        List<Object> errorsList = new List<Object>{
            new Map<String, Object>{ 'title' => 'Only title here' }
        };
            
        String result = INS_SRV_DiallerLeadResponse.extractFromErrorsArray(errorsList);
        Assert.areEqual('Only title here', result, 'Should fallback to title when detail is missing');
    }
    
    /**
* @description Test extractErrorMessage using actual DTO structure
*
* extractErrorMessage is public on INS_SRV_DiallerLeadResponse — no @TestVisible needed.
*/
    @isTest static void testExtractErrorMessageWithDTO() {
        INS_DTO_ConnexLeadsResponse dto1 = new INS_DTO_ConnexLeadsResponse();
        dto1.error = new INS_DTO_ConnexLeadsResponse.ConnexError();
        dto1.error.errorDescription = '{"error":[{"detail":"Provided credentials are invalid","title":"Unauthorized"}]}';
        
        String result1 = INS_SRV_DiallerLeadResponse.extractErrorMessage(dto1, 'Default error');
        Assert.areEqual('Provided credentials are invalid', result1, 'Should extract detail from nested errorDescription');
    }
    
    
    
    
    
    
    // ══════════════════════════════════════════════════════════════════════════
    // EXPRESSED INTEREST CHANGED TESTS
    //
    // WHY THESE TESTS EXIST:
    //   When a lead's Expressed_Interest_Product__c changes and it already has a
    //   Referred_System_Reference_Number__c (i.e. it already exists in the dialler),
    //   the requirement is to run a two-step flow:
    //
    //   Step 1 — PUT with expiry status code
    //     Removes the lead from the old dialler queue so it is no longer worked
    //     by agents under the wrong product line.
    //
    //   Step 2 — POST (only if PUT succeeded)
    //     Re-creates the lead under the new queue that matches the updated product.
    //
    //   If the PUT fails, the POST must be blocked so we never create a duplicate
    //   dialler record while the old one is still active.
    //
    //   These tests fire the batch with isExpressedInterestChanged=true, which
    //   routes to processExpressedInterestChangedLeads() in INS_UTIL_ConnexLeads.
    //   They use the same INS_LeadsAPI_Mock as the rest of the file — the mock
    //   already returns distinct PUT vs POST responses based on the HTTP method.
    // ══════════════════════════════════════════════════════════════════════════

    /**
     * @description Helper: fires the batch with isExpressedInterestChanged=true.
     *
     * WHY A SEPARATE HELPER:
     *   The existing executeBatch() helper omits the isExpressedInterestChanged
     *   constructor argument (uses the 6-param overload which defaults it to false).
     *   We need the 7-param constructor to route into the expressed-interest path.
     */
    private static void executeExpressedInterestBatch(TestSetup setup, String mockScenario) {
        INS_Leads_API.mockScenario = mockScenario;
        INS_Leads_API.testLeadId = setup.lead.Id;
        Test.setMock(HttpCalloutMock.class, new INS_LeadsAPI_Mock());

        INS_BATCH_ConnexLead batchJob = new INS_BATCH_ConnexLead(
            false,                          // expireLeads — false: we're not scheduling expiry
            null,                           // expiredStatuses — not used here
            setup.mockSettings.INS_LeadType__c,
            setup.mockSettings.INS_ProductFamily__c,
            setup.mockSettings.INS_LeadDate__c != null
                ? setup.mockSettings.INS_LeadDate__c.date()
                : null,
            new List<Id>{ setup.lead.Id },  // explicit lead Ids so the batch fetches exactly this lead
            true                            // isExpressedInterestChanged=true → routes to
                                            // INS_UTIL_ConnexLeads.processExpressedInterestChangedLeads()
        );

        Database.executeBatch(batchJob, 15);
    }

    /**
     * @description Verifies the happy path: PUT succeeds, then POST succeeds.
     *
     * SETUP:
     *   Lead has Referred_System_Reference_Number__c = 'existing-ref' (already in dialler)
     *   and a valid Dialler_Queue_ID__c and MobilePhone (set by the factory).
     *
     * WHAT THE MOCK RETURNS:
     *   PUT 'success' → errorCode '' → parsePutResponse returns Lead(Dialer_Failure_Reason__c='')
     *   POST 'success' → contact_data_id 'mock-ref-id' → parsePostResponse sets new ref#
     *
     * ASSERTIONS:
     *   1. Referred_System_Reference_Number__c = 'mock-ref-id'
     *      The old ref ('existing-ref') is gone, replaced by the new one from the POST.
     *      This proves Step 1 cleared the old ref and Step 2 wrote the new one.
     *
     *   2. Dialer_Failure_Reason__c is blank
     *      Both PUT and POST succeeded — no failure reason should remain.
     */
    @isTest
    static void testExpressedInterestChanged_PutSuccessPostSuccess() {
        // Arrange: lead with an existing dialler reference number, representing a lead
        // that was previously sent to the dialler and now has its product changed.
        TestSetup setup = createTestSetup('ExpressedInterestChanged');

        Test.startTest();
        executeExpressedInterestBatch(setup, 'success');
        Test.stopTest();

        Lead updated = [
            SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        // The old ref 'existing-ref' was cleared when PUT succeeded (Step 1).
        // The POST (Step 2) assigned a new ref from the dialler response.
        Assert.areEqual(
            'mock-ref-id',
            updated.Referred_System_Reference_Number__c,
            'POST should have written the new dialler reference number after successful PUT expiry'
        );

        // Both steps succeeded — no failure reason.
        Assert.isTrue(
            String.isBlank(updated.Dialer_Failure_Reason__c),
            'Dialer_Failure_Reason__c should be blank after a fully successful PUT+POST flow'
        );
    }

    /**
     * @description Verifies that when the PUT fails, the POST is blocked.
     *
     * SETUP:
     *   Same as above — lead already exists in dialler.
     *
     * WHAT THE MOCK RETURNS:
     *   PUT 'failure' → errorCode 'PUT_FAILED', message 'Lead not found'
     *   The mock checks request.getMethod().equalsIgnoreCase('PUT') and returns
     *   the failure response. POST is never called because processExpressedInterestChangedLeads
     *   gates the POST on PUT success.
     *
     * ASSERTIONS:
     *   1. Referred_System_Reference_Number__c = 'existing-ref' (unchanged)
     *      The old ref must NOT be cleared — the PUT failed so the lead is still
     *      active in the dialler under the old ref. If we cleared it, a retry would
     *      try a fresh POST against an existing dialler record.
     *
     *   2. Dialer_Failure_Reason__c is non-blank
     *      The PUT failure reason must be persisted so the lead appears in the
     *      Failed Connex Leads report and can be retried.
     */
    @isTest
    static void testExpressedInterestChanged_PutFailureBlocksPost() {
        // Arrange
        TestSetup setup = createTestSetup('ExpressedInterestChanged');

        Test.startTest();
        executeExpressedInterestBatch(setup, 'failure');
        Test.stopTest();

        Lead updated = [
            SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        // PUT failed — old ref must remain so the lead is still identifiable in
        // the dialler. The POST was correctly blocked.
        Assert.areEqual(
            'existing-ref',
            updated.Referred_System_Reference_Number__c,
            'Old dialler reference must not be cleared when PUT fails — POST must have been blocked'
        );

        // Failure reason must be written back to the lead so it surfaces in the
        // Failed Connex Leads report for manual retry.
        Assert.isTrue(
            String.isNotBlank(updated.Dialer_Failure_Reason__c),
            'Dialer_Failure_Reason__c should be populated when the PUT fails'
        );
    }

    /**
     * @description Verifies that a lead with a missing Referred_System_Reference_Number__c
     * is rejected during validation before any callout is made.
     *
     * WHY THIS MATTERS:
     *   The two-step flow requires an existing dialler reference to PUT against.
     *   validateProductChangedLead() checks for this upfront to avoid a wasted callout.
     *   A lead without a ref# cannot have its dialler record expired — the PUT endpoint
     *   is /<refNum>/LeadEnhancement, so the ref# is mandatory.
     *
     * SETUP:
     *   Lead has Referred_System_Reference_Number__c = null (never sent to dialler).
     *   selectDialerLeadsByRecIds() only returns this lead if it passes the condition:
     *   Dialer_Failure_Reason__c = null OR (Dialer_Failure_Reason__c != null AND mobile+queue present)
     *   Since it has no failure reason and a valid mobile+queue, it will be fetched.
     *
     * ASSERTION:
     *   Dialer_Failure_Reason__c is populated with the validation message.
     *   No PUT or POST callout is made (mock never receives a request).
     */
    @isTest
    static void testExpressedInterestChanged_MissingReferenceNumber() {
        // Arrange: lead with no dialler reference — validation should fail before callout
        TestSetup setup = createTestSetup('SuccessResponse'); // no ref# set by this scenario

        Test.startTest();
        executeExpressedInterestBatch(setup, 'success');
        Test.stopTest();

        Lead updated = [
            SELECT Dialer_Failure_Reason__c
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        // validateProductChangedLead() catches the missing ref# and writes the reason
        // back without making any API call.
        Assert.areEqual(
            'Cannot expire the existing Dialler lead because its reference number is missing.',
            updated.Dialer_Failure_Reason__c,
            'Leads without a reference number must be rejected before any callout is attempted'
        );
    }

    /**
     * @description Verifies that a 502 gateway error on the PUT is handled gracefully.
     *
     * WHY THIS MATTERS:
     *   A 502 is caught by isPutResponseError() in INS_SRV_DiallerLeadResponse before
     *   reaching processSuccessfulPutResponse(). handlePutResponse() returns buildErrorLead()
     *   directly. The POST must be blocked and the error reason persisted.
     *
     * ASSERTIONS:
     *   1. Referred_System_Reference_Number__c unchanged — PUT failed, old ref stands.
     *   2. Dialer_Failure_Reason__c is non-blank — error persisted for retry.
     */
    @isTest
    static void testExpressedInterestChanged_Put502ErrorBlocksPost() {
        // Arrange
        TestSetup setup = createTestSetup('ExpressedInterestChanged');

        Test.startTest();
        executeExpressedInterestBatch(setup, '502Error');
        Test.stopTest();

        Lead updated = [
            SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c
            FROM Lead
            WHERE Id = :setup.lead.Id
        ];

        // 502 is treated as a PUT failure — old ref must not be cleared.
        Assert.areEqual(
            'existing-ref',
            updated.Referred_System_Reference_Number__c,
            'Old dialler reference must not be cleared on a PUT 502 error'
        );

        Assert.isTrue(
            String.isNotBlank(updated.Dialer_Failure_Reason__c),
            'Dialer_Failure_Reason__c should be populated after a PUT 502 error'
        );
    }
}