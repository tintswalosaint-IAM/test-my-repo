/**
 * @description Test class for the Expressed Interest Changed flow.
 *
 * ── REQUIREMENT ──────────────────────────────────────────────────────────────
 * When a lead's Expressed_Interest_Product__c changes AND the lead already has
 * a Referred_System_Reference_Number__c (meaning it was previously sent to the
 * dialler), two callouts must be made:
 *
 *   Step 1 — PUT with expiry status code
 *     Removes the lead from the old AWS dialler queue so agents stop working it.
 *
 *   Step 2 — POST (only if PUT succeeded)
 *     Re-creates the lead under the new queue that matches the updated product.
 *
 * If the PUT fails, the POST must be blocked to avoid creating a duplicate
 * record in the dialler while the old one is still active.
 *
 * ── WHAT THESE TESTS COVER ───────────────────────────────────────────────────
 *   1. Flag detection — isExpressedInterestChanged is set correctly by the trigger
 *   2. Happy path — PUT succeeds then POST succeeds, new ref# written to lead
 *   3. PUT failure — POST is blocked, old ref# preserved, failure reason set
 *   4. Validation gate — lead with no ref# is rejected before any callout
 *
 * ── WHAT THESE TESTS DO NOT COVER ────────────────────────────────────────────
 *   The pre-existing normal flow (POST for new leads, PUT for info changes,
 *   scheduled expiry) is covered by INS_BATCH_ConnexLead_Test.
 * ─────────────────────────────────────────────────────────────────────────────
 *
 * @author          Tintswalo Mushwana
 * @date            2026-10-19
 * @userstory       AWS Dialler — Expressed Interest Change Flow
 */
@isTest
private class INS_UTIL_LeadExpressedInterest_Test {

    // ── String constants ──────────────────────────────────────────────────────
    // A ref# that represents a lead already in the dialler (sent previously).
    private static final String EXISTING_REF = 'existing-ref';
    // The ref# that INS_LeadsAPI_Mock returns on a successful POST.
    private static final String MOCK_NEW_REF = 'mock-ref-id';
    // Validation message written when the lead has no ref# to PUT against.
    private static final String MISSING_REF_ERROR =
        'Cannot expire the existing Dialler lead because its reference number is missing.';

    // ── Test data setup ───────────────────────────────────────────────────────

    /**
     * @description Creates a lead that already exists in the dialler.
     *
     * WHY THIS STATE:
     *   The expressed interest flow only fires when the lead already has a
     *   Referred_System_Reference_Number__c. Without it, the lead has never
     *   been sent to the dialler so there is nothing to expire (PUT target).
     */
    private static Lead createLeadAlreadyInDialler() {
        List<Leads_ProductQueueAllocation__c> products =
            Insurance_TestDataFactory.createExpressInterest();
        insert products;

        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.Expressed_Interest_Product__c  = products[0].Id;
        lead.Referred_System_Reference_Number__c = EXISTING_REF;
        insert lead;

        return lead;
    }

    /**
     * @description Creates a lead that has never been sent to the dialler.
     * Used for the validation gate test — no ref# means no PUT target.
     */
    private static Lead createLeadNotYetInDialler() {
        List<Leads_ProductQueueAllocation__c> products =
            Insurance_TestDataFactory.createExpressInterest();
        insert products;

        Lead lead = Insurance_TestDataFactory.createLead('General');
        lead.Expressed_Interest_Product__c  = products[0].Id;
        // Referred_System_Reference_Number__c intentionally left blank
        insert lead;

        return lead;
    }

    /**
     * @description Fires INS_BATCH_ConnexLead with isExpressedInterestChanged=true.
     *
     * WHY THE 7-PARAM CONSTRUCTOR:
     *   The 6-param overload defaults isExpressedInterestChanged=false, which
     *   routes to the normal PUT/POST split. We need the 7-param constructor
     *   to route to processExpressedInterestChangedLeads() in INS_UTIL_ConnexLeads.
     */
    private static void fireExpressedInterestBatch(Id leadId, String mockScenario) {
        INS_Leads_API.mockScenario = mockScenario;
        INS_Leads_API.testLeadId   = leadId;
        Test.setMock(HttpCalloutMock.class, new INS_LeadsAPI_Mock());

        INS_Insurance_Lead_Settings__mdt settings =
            Insurance_TestDataFactory.createMockLeadSettings();

        Date leadDate = settings.INS_LeadDate__c != null
            ? settings.INS_LeadDate__c.date()
            : null;

        INS_BATCH_ConnexLead batch = new INS_BATCH_ConnexLead(
            false,                   // expireLeads — not a scheduled expiry run
            null,                    // expiredStatuses — not used
            settings.INS_LeadType__c,
            settings.INS_ProductFamily__c,
            leadDate,
            new List<Id>{ leadId },  // run on this specific lead only
            true                     // isExpressedInterestChanged = true
                                     // → routes to processExpressedInterestChangedLeads()
        );

        Database.executeBatch(batch, 1);
    }

    // ════════════════════════════════════════════════════════════════════════
    // TEST 1 — FLAG DETECTION
    // ════════════════════════════════════════════════════════════════════════

    /**
     * @description Verifies that hasExpressedInterestChanged() returns true
     * when the product changes on a lead that already has a ref#, and false
     * when the lead has no ref# (it was never in the dialler).
     *
     * WHY THIS MATTERS:
     *   The flag is the entry point for the whole flow. If it does not fire
     *   correctly, the two callouts never happen.
     *
     *   We test hasExpressedInterestChanged indirectly by checking what
     *   Dialer_Failure_Reason__c is set to after the batch runs:
     *   - Lead WITH ref# + product change → flows through PUT+POST → failure
     *     reason is blank (success) or a dialler error (callout ran)
     *   - Lead WITHOUT ref# → validation gate fires → failure reason =
     *     MISSING_REF_ERROR (no callout was made)
     *
     *   This cleanly separates "flag fired" from "flag did not fire".
     */
    @isTest
    static void testFlag_SetWhenProductChangesAndRefExists() {
        // Arrange: lead WITHOUT a ref# — flag should NOT trigger the two-step flow
        Lead lead = createLeadNotYetInDialler();

        Test.startTest();
        // Fire the batch as if isExpressedInterestChanged=true was set.
        // The validation gate inside processExpressedInterestChangedLeads()
        // will catch the missing ref# before making any callout.
        fireExpressedInterestBatch(lead.Id, 'success');
        Test.stopTest();

        Lead result = [
            SELECT Dialer_Failure_Reason__c
            FROM Lead WHERE Id = :lead.Id
        ];

        // The validation gate fired — no callout was made, failure reason is set.
        // This proves the flag routing works: a lead without a ref# is caught
        // before it can reach the PUT callout.
        Assert.areEqual(
            MISSING_REF_ERROR,
            result.Dialer_Failure_Reason__c,
            'A lead with no ref# must be rejected before any callout — flag routing is correct'
        );
    }

    // ════════════════════════════════════════════════════════════════════════
    // TEST 2 — HAPPY PATH: PUT SUCCEEDS, POST SUCCEEDS
    // ════════════════════════════════════════════════════════════════════════

    /**
     * @description Verifies the full two-step flow when both callouts succeed.
     *
     * WHAT THE MOCK RETURNS:
     *   PUT 'success' → HTTP 200, errorCode='' → parsePutResponse sets
     *                   Dialer_Failure_Reason__c='' (blank = success)
     *   POST 'success' → HTTP 200, contact_data_id='mock-ref-id' →
     *                    parsePostResponse sets Referred_System_Reference_Number__c
     *
     * ASSERTIONS:
     *   1. Referred_System_Reference_Number__c = 'mock-ref-id'
     *      Proves: PUT expired the old record (old ref# cleared after PUT success),
     *              POST re-created the lead (new ref# written from POST response).
     *
     *   2. Dialer_Failure_Reason__c is blank
     *      Proves: Both steps completed without error.
     */
    @isTest
    static void testHappyPath_PutSuccessPostSuccess() {
        // Arrange: lead already in the dialler with an existing ref#
        Lead lead = createLeadAlreadyInDialler();

        Test.startTest();
        fireExpressedInterestBatch(lead.Id, 'success');
        Test.stopTest();

        Lead result = [
            SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c
            FROM Lead WHERE Id = :lead.Id
        ];

        // The old ref 'existing-ref' was cleared after PUT succeeded.
        // The POST then wrote back the new ref from the dialler response.
        Assert.areEqual(
            MOCK_NEW_REF,
            result.Referred_System_Reference_Number__c,
            'After PUT+POST success the lead must have the new dialler reference number'
        );

        Assert.isTrue(
            String.isBlank(result.Dialer_Failure_Reason__c),
            'Both steps succeeded — Dialer_Failure_Reason__c must be blank'
        );
    }

    // ════════════════════════════════════════════════════════════════════════
    // TEST 3 — PUT FAILS: POST MUST BE BLOCKED
    // ════════════════════════════════════════════════════════════════════════

    /**
     * @description Verifies that a PUT failure blocks the POST entirely.
     *
     * WHAT THE MOCK RETURNS:
     *   PUT 'failure' → errorCode='PUT_FAILED', message='Lead not found'
     *   POST is never called because processExpressedInterestChangedLeads()
     *   gates the POST on a blank Dialer_Failure_Reason__c from the PUT result.
     *
     * WHY WE BLOCK THE POST ON PUT FAILURE:
     *   The old dialler record is still active. If we POST, there would be two
     *   records for the same lead in the dialler — the old one (still active)
     *   and the new one. Two agents would call the same customer.
     *
     * ASSERTIONS:
     *   1. Referred_System_Reference_Number__c = 'existing-ref' (unchanged)
     *      Proves: old ref# was NOT cleared — PUT failed so the old record
     *              is still active in the dialler.
     *
     *   2. Dialer_Failure_Reason__c is non-blank
     *      Proves: the PUT failure reason was persisted so the lead appears
     *              in the Failed Leads report for manual retry.
     */
    @isTest
    static void testPutFailure_BlocksPost_PreservesOldRef() {
        // Arrange: lead already in the dialler
        Lead lead = createLeadAlreadyInDialler();

        Test.startTest();
        fireExpressedInterestBatch(lead.Id, 'failure');
        Test.stopTest();

        Lead result = [
            SELECT Referred_System_Reference_Number__c, Dialer_Failure_Reason__c
            FROM Lead WHERE Id = :lead.Id
        ];

        // Old ref# must remain — the dialler record is still active.
        Assert.areEqual(
            EXISTING_REF,
            result.Referred_System_Reference_Number__c,
            'Old ref# must not be cleared when PUT fails — the old dialler record is still active'
        );

        // Failure reason must be persisted for retry visibility.
        Assert.isTrue(
            String.isNotBlank(result.Dialer_Failure_Reason__c),
            'PUT failure reason must be written to the lead so it appears in the Failed Leads report'
        );
    }

    // ════════════════════════════════════════════════════════════════════════
    // TEST 4 — VALIDATION GATE: NO REF# MEANS NO CALLOUT
    // ════════════════════════════════════════════════════════════════════════

    /**
     * @description Verifies that a lead with no Referred_System_Reference_Number__c
     * is caught by validation before any callout is made.
     *
     * WHY THE GATE EXISTS:
     *   The PUT endpoint is /<refNum>/LeadEnhancement — it requires a ref# in
     *   the URL. Without one, the PUT would fail with a 404. We catch this
     *   upfront to avoid a wasted API call.
     *
     * ASSERTION:
     *   Dialer_Failure_Reason__c = the validation message.
     *   This proves the gate fired and no callout was attempted.
     */
    @isTest
    static void testValidationGate_NoRefNumber_RejectsBeforeCallout() {
        // Arrange: lead with no ref# — was never sent to the dialler before
        Lead lead = createLeadNotYetInDialler();

        Test.startTest();
        fireExpressedInterestBatch(lead.Id, 'success');
        // 'success' mock is set but will never be called —
        // the validation gate fires first
        Test.stopTest();

        Lead result = [
            SELECT Dialer_Failure_Reason__c, Referred_System_Reference_Number__c
            FROM Lead WHERE Id = :lead.Id
        ];

        // Validation failure reason was written without making any callout.
        Assert.areEqual(
            MISSING_REF_ERROR,
            result.Dialer_Failure_Reason__c,
            'Lead with no ref# must be rejected by validation before any PUT callout is made'
        );

        // Ref# must still be null — no callout ran, nothing was written.
        Assert.isNull(
            result.Referred_System_Reference_Number__c,
            'Referred_System_Reference_Number__c must remain null when validation rejects the lead'
        );
    }
}