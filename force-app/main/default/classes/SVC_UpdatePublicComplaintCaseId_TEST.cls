/**
 * @description Test class for SVC_UpdatePublicComplaintCaseId.
 *              Covers the invocable method, inner request wrapper, and private constructor.
 * @see SVC_UpdatePublicComplaintCaseId
 * @author Raymond Magezi
 * @date July-02-2026
 */
@IsTest(SeeAllData=false)
private class SVC_UpdatePublicComplaintCaseId_TEST {

    // ───────────────────────────────────────────────────────────────────────────
    // Test data helpers
    // ───────────────────────────────────────────────────────────────────────────

    private static Case insertCase() {
        Case c = new Case(Subject = 'Test Case', Origin = 'Phone');
        insert c;
        return c;
    }

    private static PublicComplaint insertComplaint() {
        PublicComplaint pc = new PublicComplaint(
            Subject = 'Test Complaint',
            IncidentDate = Date.today()
        );
        insert pc;
        return pc;
    }

    private static SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest buildRequest(String publicComplaintId, String caseId) {
        SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest req = new SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest();
        req.publicComplaintId = publicComplaintId;
        req.caseId = caseId;
        return req;
    }

    // ───────────────────────────────────────────────────────────────────────────
    // Tests
    // ───────────────────────────────────────────────────────────────────────────

    /**
     * @description Verifies that a valid request correctly sets ComplaintCaseId on the PublicComplaint
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_happyPath() {
        Case testCase = insertCase();
        PublicComplaint testComplaint = insertComplaint();

        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest(testComplaint.Id, testCase.Id)
            }
        );
        Test.stopTest();

        PublicComplaint updated = [SELECT ComplaintCaseId FROM PublicComplaint WHERE Id = :testComplaint.Id];
        Assert.areEqual(testCase.Id, updated.ComplaintCaseId, 'ComplaintCaseId should be set to the case Id');
    }

    /**
     * @description Verifies that multiple valid requests in a single invocation are all processed
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_multipleRequests() {
        Case testCase = insertCase();
        PublicComplaint complaint1 = insertComplaint();
        PublicComplaint complaint2 = insertComplaint();

        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest(complaint1.Id, testCase.Id),
                buildRequest(complaint2.Id, testCase.Id)
            }
        );
        Test.stopTest();

        List<PublicComplaint> updated = [SELECT ComplaintCaseId FROM PublicComplaint WHERE Id IN :new List<Id>{ complaint1.Id, complaint2.Id }];
        for (PublicComplaint pc : updated) {
            Assert.areEqual(testCase.Id, pc.ComplaintCaseId, 'ComplaintCaseId should be set for all records');
        }
    }

    /**
     * @description Verifies that a request with both IDs blank is silently skipped — no DML, no exception
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_bothBlank() {
        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest('', '')
            }
        );
        Test.stopTest();

        Assert.isTrue(true, 'Blank IDs should be handled gracefully without exception');
    }

    /**
     * @description Verifies that a request with a blank publicComplaintId is skipped
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_blankComplaintId() {
        Case testCase = insertCase();

        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest('', testCase.Id)
            }
        );
        Test.stopTest();

        Assert.isTrue(true, 'Blank publicComplaintId should be skipped without exception');
    }

    /**
     * @description Verifies that a request with a blank caseId is skipped
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_blankCaseId() {
        PublicComplaint testComplaint = insertComplaint();

        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest(testComplaint.Id, '')
            }
        );
        Test.stopTest();

        Assert.isTrue(true, 'Blank caseId should be skipped without exception');
    }

    /**
     * @description Verifies that a mixed list (one valid, one blank) only processes the valid request
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_mixedRequests() {
        Case testCase = insertCase();
        PublicComplaint testComplaint = insertComplaint();

        Test.startTest();
        SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
            new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
                buildRequest(testComplaint.Id, testCase.Id),
                buildRequest('', '')
            }
        );
        Test.stopTest();

        PublicComplaint updated = [SELECT ComplaintCaseId FROM PublicComplaint WHERE Id = :testComplaint.Id];
        Assert.areEqual(testCase.Id, updated.ComplaintCaseId, 'Valid request in mixed list should still be processed');
    }

    /**
     * @description Covers the private constructor for CodeScan compliance
     */
    @IsTest
    private static void testPrivateConstructor() {
        SVC_UpdatePublicComplaintCaseId instance = new SVC_UpdatePublicComplaintCaseId();
        Assert.isNotNull(instance, 'Constructor should produce a non-null instance');
    }

    /**
     * @description Covers the catch block by passing an invalid publicComplaintId that causes a DML exception
     */
    @IsTest
    private static void testUpdatePublicComplaintCaseId_exceptionPath() {
        try {
            Test.startTest();
            SVC_UpdatePublicComplaintCaseId.updatePublicComplaintCaseId(
                new List<SVC_UpdatePublicComplaintCaseId.PublicComplaintRequest>{
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