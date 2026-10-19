/*------------------------------------------------------------
Author:        Given Khupai
Company:       Salesforce
Description:   Test class for INS_SRV_CaseTransferHistory.

               Verifies that transfer history records are created
               only when Case.OwnerId changes, that Queue vs User
               owners are distinguished correctly, and that Transfer
               Sequence/Duration are calculated correctly across
               multiple transfers on the same Case.
Test Class:    INS_SRV_CaseTransferHistory_TEST

02-09-2026     Given Khupai     Initial version (SFP-51816)
------------------------------------------------------------*/
@IsTest(SeeAllData=false)
private class INS_SRV_CaseTransferHistory_TEST {

    /*------------------------------------------------------------
    *   Purpose:  Returns the org default Business Hours record, so
    *             CMN_DurationWithPreviousOwner__c's business-hours-aware
    *             calculation (INS_UTIL_BusinessHoursCalcHelper) has a
    *             real BusinessHoursId to work with - without one it
    *             deliberately returns null rather than a wall-clock guess.
    *--------------------------------------------------------------*/
    private static BusinessHours getDefaultBusinessHours() {
        return [
            SELECT Id
            FROM BusinessHours
            WHERE IsDefault = true
            LIMIT 1
        ];
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a basic Account record used by test Cases.
    *--------------------------------------------------------------*/
    private static Account createTestAccount() {
        Account testAccount = new Account(Name = 'Test Account Case Transfer History');
        insert testAccount;
        return testAccount;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a Queue that Case records can be owned by,
    *             so the Queue-owner branch of the service can be
    *             exercised without depending on other org data.
    *
    *             The insert is wrapped in System.runAs() - Group and
    *             QueueSobject are "setup objects", and Salesforce
    *             throws MIXED_DML_OPERATION if setup-object DML and
    *             non-setup-object DML (Account/Case, inserted later
    *             in the same test method) run in the same transaction.
    *             System.runAs() opens a new DML context even when
    *             running as the current user, which is the standard
    *             workaround.
    *--------------------------------------------------------------*/
    private static Group createTestQueue() {
        Group testQueue = new Group(
            Name = 'TRH_TEST_Queue_' + String.valueOf(System.now().getTime()).right(8),
            Type = 'Queue'
        );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testQueue;
            insert new QueueSobject(
                QueueId = testQueue.Id,
                SobjectType = 'Case'
            );
        }

        return testQueue;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a base Case owned by the given owner (User
    *             or Queue Id) and re-queries it with the fields the
    *             service reads.
    *--------------------------------------------------------------*/
    private static Case createBaseCase(String subject, Id ownerId) {
        Account testAccount = createTestAccount();
        BusinessHours defaultBusinessHours = getDefaultBusinessHours();

        Case testCase = new Case(
            Subject = subject,
            Status = 'New',
            AccountId = testAccount.Id,
            OwnerId = ownerId,
            BusinessHoursId = defaultBusinessHours.Id
        );
        insert testCase;

        return getCaseForService(testCase.Id);
    }

    private static Case getCaseForService(Id caseId) {
        return [
            SELECT Id, Subject, Status, OwnerId, CreatedDate, BusinessHoursId, SVC_CaseOwnerTeam__c
            FROM Case
            WHERE Id = :caseId
        ];
    }

    /*------------------------------------------------------------
    *   Purpose:  Builds an in-memory Case snapshot with a different
    *             OwnerId. Used instead of a real "update testCase"
    *             DML so the arrange phase never fires SVC_TRH_Case's
    *             afterUpdate for real - a real update would invoke
    *             INS_SRV_CaseTransferHistory a second time and create
    *             a competing transfer history record before the
    *             explicit call under test runs.
    *--------------------------------------------------------------*/
    private static Case withOwner(Case sourceCase, Id ownerId) {
        String caseJson = JSON.serialize(
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'type' => 'Case' },
                'Id' => String.valueOf(sourceCase.Id),
                'Subject' => sourceCase.Subject,
                'Status' => sourceCase.Status,
                'OwnerId' => String.valueOf(ownerId),
                'CreatedDate' => sourceCase.CreatedDate,
                'BusinessHoursId' => String.valueOf(sourceCase.BusinessHoursId)
            }
        );
        return (Case) JSON.deserialize(caseJson, Case.class);
    }

    /*------------------------------------------------------------
    *   Purpose:  Same as withOwner(), but also lets the caller force
    *             a specific BusinessHoursId (including null) onto the
    *             snapshot, to exercise the Duration calculation's
    *             no-Business-Hours branch independent of what the
    *             underlying Case row actually has.
    *--------------------------------------------------------------*/
    private static Case withOwnerAndBusinessHours(Case sourceCase, Id ownerId, Id businessHoursId) {
        String caseJson = JSON.serialize(
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'type' => 'Case' },
                'Id' => String.valueOf(sourceCase.Id),
                'Subject' => sourceCase.Subject,
                'Status' => sourceCase.Status,
                'OwnerId' => String.valueOf(ownerId),
                'CreatedDate' => sourceCase.CreatedDate,
                'BusinessHoursId' => businessHoursId == null ? null : String.valueOf(businessHoursId)
            }
        );
        return (Case) JSON.deserialize(caseJson, Case.class);
    }

    /*------------------------------------------------------------
    *   Purpose:  Same as withOwner(), but also lets the caller force a
    *             specific SVC_CaseOwnerTeam__c value onto the snapshot,
    *             so the Team copy-through in buildTracker() can be tested
    *             deterministically - real Case inserts in this test class
    *             don't reliably get SVC_CaseOwnerTeam__c populated, since
    *             the org's SVC_SetCaseOwnerTeamValue flow keys off business
    *             criteria (real queue/team mappings) that synthetic test
    *             queues and accounts won't match.
    *--------------------------------------------------------------*/
    private static Case withOwnerAndTeam(Case sourceCase, Id ownerId, String ownerTeam) {
        String caseJson = JSON.serialize(
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{ 'type' => 'Case' },
                'Id' => String.valueOf(sourceCase.Id),
                'Subject' => sourceCase.Subject,
                'Status' => sourceCase.Status,
                'OwnerId' => String.valueOf(ownerId),
                'CreatedDate' => sourceCase.CreatedDate,
                'BusinessHoursId' => String.valueOf(sourceCase.BusinessHoursId),
                'SVC_CaseOwnerTeam__c' => ownerTeam
            }
        );
        return (Case) JSON.deserialize(caseJson, Case.class);
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that a Queue -> User transfer creates a
    *             CMN_History_Tracker__c record with both owner sides
    *             populated correctly, as the first (sequence 1)
    *             transfer on the Case.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersCreatesFirstTransferFromQueueToUserPositiveOutcome() {
        Group testQueue = createTestQueue();
        Id newOwnerId = UserInfo.getUserId();
        Case testCase = createBaseCase('Queue To User Transfer Test', testQueue.Id);

        Case oldCaseSnapshot = withOwner(testCase, testQueue.Id);
        Case newCaseSnapshot = withOwner(testCase, newOwnerId);

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(
                new List<Case>{ newCaseSnapshot },
                new Map<Id, Case>{ testCase.Id => oldCaseSnapshot }
            );
        Test.stopTest();

        CMN_History_Tracker__c tracker = [
            SELECT Id, CMN_Case__c, CMN_PreviousOwnerType__c, CMN_PreviousOwnerQueueName__c,
                   CMN_PreviousUserOwner__c, CMN_CurrentOwnerType__c, CMN_CurrentUserOwner__c,
                   CMN_TransferSequence__c, CMN_DurationWithPreviousOwner__c, OwnerId
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.areEqual('Queue', tracker.CMN_PreviousOwnerType__c, 'Previous owner should be recorded as a Queue');
        Assert.areEqual(testQueue.Name, tracker.CMN_PreviousOwnerQueueName__c, 'Previous owner queue name should be captured');
        Assert.isNull(tracker.CMN_PreviousUserOwner__c, 'Previous owner User lookup should be blank for a Queue owner');
        Assert.areEqual('User', tracker.CMN_CurrentOwnerType__c, 'Current owner should be recorded as a User');
        Assert.areEqual(newOwnerId, tracker.CMN_CurrentUserOwner__c, 'Current owner User lookup should be populated');
        Assert.areEqual(1, tracker.CMN_TransferSequence__c, 'First transfer on this Case should be sequence 1');
        Assert.isNotNull(tracker.CMN_DurationWithPreviousOwner__c, 'Duration with previous owner should be calculated (business-hours-aware) from Case CreatedDate');
        // Queues aren't whitelisted (via QueueSobject) to own CMN_History_Tracker__c records,
        // so when the previous owner was a Queue, OwnerId is deliberately left as the running
        // user rather than the Queue - see INS_SRV_CaseTransferHistory.buildTracker().
        Assert.areEqual(UserInfo.getUserId(), tracker.OwnerId, 'Tracker owner should fall back to the running user when previous owner was a Queue');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that a second transfer on the same Case is
    *             recorded as sequence 2, alongside the existing
    *             sequence-1 record from an earlier transfer.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersSecondTransferIncrementsSequencePositiveOutcome() {
        Group testQueue = createTestQueue();
        Id currentUserId = UserInfo.getUserId();
        Case testCase = createBaseCase('Second Transfer Sequence Test', currentUserId);

        CMN_History_Tracker__c firstTransfer = new CMN_History_Tracker__c(
            CMN_Case__c = testCase.Id,
            CMN_TransferDate__c = System.now().addHours(-5),
            CMN_PreviousOwnerType__c = 'Queue',
            CMN_PreviousOwnerQueueName__c = testQueue.Name,
            CMN_CurrentOwnerType__c = 'User',
            CMN_CurrentUserOwner__c = currentUserId,
            CMN_TransferSequence__c = 1,
            CMN_DurationWithPreviousOwner__c = 2
        );
        insert firstTransfer;

        Case oldCaseSnapshot = withOwner(testCase, currentUserId);
        Case newCaseSnapshot = withOwner(testCase, testQueue.Id);

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(
                new List<Case>{ newCaseSnapshot },
                new Map<Id, Case>{ testCase.Id => oldCaseSnapshot }
            );
        Test.stopTest();

        List<CMN_History_Tracker__c> trackers = [
            SELECT Id, CMN_TransferSequence__c, CMN_TransferDate__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            ORDER BY CMN_TransferDate__c DESC
        ];

        Assert.areEqual(2, trackers.size(), 'Should now have two transfer history records');
        Assert.areEqual(2, trackers[0].CMN_TransferSequence__c, 'Second transfer should be sequence 2');
        Assert.areEqual(1, trackers[1].CMN_TransferSequence__c, 'Original transfer should remain sequence 1');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that no transfer history is created when
    *             OwnerId is unchanged between old and new Case state.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersNoOwnerChangeDoesNotCreateRecordPositiveOutcome() {
        Id currentUserId = UserInfo.getUserId();
        Case testCase = createBaseCase('No Owner Change Test', currentUserId);

        Case oldCaseSnapshot = withOwner(testCase, currentUserId);
        Case newCaseSnapshot = withOwner(testCase, currentUserId);

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(
                new List<Case>{ newCaseSnapshot },
                new Map<Id, Case>{ testCase.Id => oldCaseSnapshot }
            );
        Test.stopTest();

        Integer trackerCount = [
            SELECT COUNT()
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
        ];

        Assert.areEqual(0, trackerCount, 'No transfer history should be created when OwnerId does not change');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that Duration With Previous Owner is left
    *             null (not a wall-clock guess) when the Case has no
    *             BusinessHoursId - INS_UTIL_BusinessHoursCalcHelper
    *             cannot compute a business-hours-aware duration
    *             without one, and the two should not be conflated.
    *
    *             This org auto-assigns a default BusinessHoursId to
    *             every Case on insert, so a "no Business Hours" Case
    *             can't be produced via a normal DML insert - the
    *             BusinessHoursId is forced to null on the in-memory
    *             snapshot instead, the same technique withOwner()
    *             already uses to simulate an OwnerId change.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersNullDurationWhenNoBusinessHoursPositiveOutcome() {
        Id currentUserId = UserInfo.getUserId();
        Case testCase = createBaseCase('No Business Hours Test', currentUserId);
        Group testQueue = createTestQueue();

        Case oldCaseSnapshot = withOwnerAndBusinessHours(testCase, currentUserId, null);
        Case newCaseSnapshot = withOwnerAndBusinessHours(testCase, testQueue.Id, null);

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(
                new List<Case>{ newCaseSnapshot },
                new Map<Id, Case>{ testCase.Id => oldCaseSnapshot }
            );
        Test.stopTest();

        CMN_History_Tracker__c tracker = [
            SELECT Id, CMN_DurationWithPreviousOwner__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.isNull(tracker.CMN_DurationWithPreviousOwner__c, 'Duration should be null, not a wall-clock guess, when Case has no Business Hours');
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that CMN_PreviousOwnerTeam__c/CMN_CurrentOwnerTeam__c
    *             are copied straight from Case.SVC_CaseOwnerTeam__c (Trigger.old/
    *             new) with no independent resolution logic - that field is
    *             already correctly set by the org's existing before-save flow
    *             SVC_SetCaseOwnerTeamValue before this trigger runs.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersCopiesOwnerTeamFromCasePositiveOutcome() {
        Id currentUserId = UserInfo.getUserId();
        Group testQueue = createTestQueue();
        Case testCase = createBaseCase('Owner Team Copy Test', currentUserId);

        Case oldCaseSnapshot = withOwnerAndTeam(testCase, currentUserId, 'INS_SBIB_CarAndHomeServVAFTeam');
        Case newCaseSnapshot = withOwnerAndTeam(testCase, testQueue.Id, 'INS_SBIB_CarAndHomeServeRefundTeam');

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(
                new List<Case>{ newCaseSnapshot },
                new Map<Id, Case>{ testCase.Id => oldCaseSnapshot }
            );
        Test.stopTest();

        CMN_History_Tracker__c tracker = [
            SELECT Id, CMN_PreviousOwnerTeam__c, CMN_CurrentOwnerTeam__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.areEqual(
            'INS_SBIB_CarAndHomeServVAFTeam',
            tracker.CMN_PreviousOwnerTeam__c,
            'Previous Owner Team should be copied from the old Case snapshot\'s SVC_CaseOwnerTeam__c'
        );
        Assert.areEqual(
            'INS_SBIB_CarAndHomeServeRefundTeam',
            tracker.CMN_CurrentOwnerTeam__c,
            'Current Owner Team should be copied from the new Case snapshot\'s SVC_CaseOwnerTeam__c'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies the service safely no-ops for null/empty
    *             inputs rather than throwing.
    *--------------------------------------------------------------*/
    @IsTest
    static void recordTransfersNullInputsDoNotThrowExceptionPositiveOutcome() {
        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(null, new Map<Id, Case>());
            INS_SRV_CaseTransferHistory.recordTransfers(new List<Case>(), new Map<Id, Case>());
            INS_SRV_CaseTransferHistory.recordTransfers(new List<Case>{ new Case(Id = null) }, null);
        Test.stopTest();

        Assert.isTrue(true, 'Method should safely return for null/empty inputs without throwing');
    }
}