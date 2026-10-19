/**
 * @description Test class for SVC_UpdateVoiceCallRelatedRecord.
 *              Covers the invocable method, inner request wrapper, and private constructor.
 * @see SVC_UpdateVoiceCallRelatedRecord
 * @author Raymond Magezi
 * @date 05-13-2026
 */
@IsTest(SeeAllData=false)
private class SVC_UpdateVoiceCallRelatedRecord_TEST {

    // ───────────────────────────────────────────────────────────────────────────
    // Test data helpers
    // ───────────────────────────────────────────────────────────────────────────

    private static Case insertCase() {
        Case c = new Case(Subject = 'Test Case', Origin = 'Phone');
        insert c;
        return c;
    }

    private static VoiceCall insertVoiceCall() {
        CallCenter cc = [SELECT Id FROM CallCenter LIMIT 1];
        VoiceCall vc = new VoiceCall(
            VendorCallKey = 'test-' + DateTime.now().getTime(),
            CallStartDateTime = DateTime.now(),
            CallEndDateTime = DateTime.now().addMinutes(5),
            CallCenterId = cc.Id,
            VendorType = 'Custom',
            FromPhoneNumber = '+27000000000',
            ToPhoneNumber = '+27000000001',
            CallType = 'Inbound'
        );
        insert vc;
        return vc;
    }

    private static SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest buildRequest(String voiceCallId, String caseId) {
        SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest req = new SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest();
        req.voiceCallId = voiceCallId;
        req.caseId = caseId;
        return req;
    }

    // ───────────────────────────────────────────────────────────────────────────
    // Tests
    // ───────────────────────────────────────────────────────────────────────────

    /**
     * @description Verifies that a valid request correctly sets RelatedRecordId on the VoiceCall
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_happyPath() {
        Case testCase = insertCase();
        VoiceCall testVoiceCall = insertVoiceCall();

        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest(testVoiceCall.Id, testCase.Id)
            }
        );
        Test.stopTest();

        VoiceCall updated = [SELECT RelatedRecordId FROM VoiceCall WHERE Id = :testVoiceCall.Id];
        Assert.areEqual(testCase.Id, updated.RelatedRecordId, 'RelatedRecordId should be set to the case Id');
    }

    /**
     * @description Verifies that multiple valid requests in a single invocation are all processed
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_multipleRequests() {
        Case testCase = insertCase();
        VoiceCall voiceCall1 = insertVoiceCall();
        VoiceCall voiceCall2 = insertVoiceCall();

        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest(voiceCall1.Id, testCase.Id),
                buildRequest(voiceCall2.Id, testCase.Id)
            }
        );
        Test.stopTest();

        List<VoiceCall> updated = [SELECT RelatedRecordId FROM VoiceCall WHERE Id IN :new List<Id>{ voiceCall1.Id, voiceCall2.Id }];
        for (VoiceCall vc : updated) {
            Assert.areEqual(testCase.Id, vc.RelatedRecordId, 'RelatedRecordId should be set for all records');
        }
    }

    /**
     * @description Verifies that a request with both IDs blank is silently skipped — no DML, no exception
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_bothBlank() {
        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest('', '')
            }
        );
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM VoiceCall WHERE RelatedRecordId != null], 'No VoiceCall should be updated when both IDs are blank');
    }

    /**
     * @description Verifies that a request with a blank voiceCallId is skipped
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_blankVoiceCallId() {
        Case testCase = insertCase();

        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest('', testCase.Id)
            }
        );
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM VoiceCall WHERE RelatedRecordId = :testCase.Id], 'No VoiceCall should be updated when voiceCallId is blank');
    }

    /**
     * @description Verifies that a request with a blank caseId is skipped
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_blankCaseId() {
        VoiceCall testVoiceCall = insertVoiceCall();

        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest(testVoiceCall.Id, '')
            }
        );
        Test.stopTest();

        VoiceCall result = [SELECT RelatedRecordId FROM VoiceCall WHERE Id = :testVoiceCall.Id];
        Assert.isNull(result.RelatedRecordId, 'RelatedRecordId should remain null when caseId is blank');
    }

    /**
     * @description Verifies that a mixed list (one valid, one blank) only processes the valid request
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_mixedRequests() {
        Case testCase = insertCase();
        VoiceCall testVoiceCall = insertVoiceCall();

        Test.startTest();
        SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
            new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                buildRequest(testVoiceCall.Id, testCase.Id),
                buildRequest('', '')
            }
        );
        Test.stopTest();

        VoiceCall updated = [SELECT RelatedRecordId FROM VoiceCall WHERE Id = :testVoiceCall.Id];
        Assert.areEqual(testCase.Id, updated.RelatedRecordId, 'Valid request in mixed list should still be processed');
    }

    /**
     * @description Covers the private constructor for CodeScan compliance
     */
    @IsTest
    private static void testPrivateConstructor() {
        SVC_UpdateVoiceCallRelatedRecord instance = new SVC_UpdateVoiceCallRelatedRecord();
        Assert.isNotNull(instance, 'Constructor should produce a non-null instance');
    }

    /**
     * @description Covers the catch block by passing an invalid voiceCallId that causes a DML exception
     */
    @IsTest
    private static void testUpdateVoiceCallRelatedRecord_exceptionPath() {
        try {
            Test.startTest();
            SVC_UpdateVoiceCallRelatedRecord.updateVoiceCallRelatedRecord(
                new List<SVC_UpdateVoiceCallRelatedRecord.VoiceCallRequest>{
                    buildRequest('INVALID_ID', 'INVALID_CASE_ID')
                }
            );
            Test.stopTest();
            Assert.fail('Expected an exception to be thrown');
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage(), 'Exception message should not be null');
        }
    }
}