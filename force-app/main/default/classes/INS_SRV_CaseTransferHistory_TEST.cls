/**
 * @description Test class for INS_SRV_CaseTransferHistory.
 *              <br/>SFP-51816
 *              Verifies that transfer history records are created
 *              only when Case.OwnerId changes, that Queue vs User
 *              owners are distinguished correctly, and that Transfer
 *              Count/Duration are calculated correctly across
 *              multiple transfers on the same Case.
 *
 * @author Given Khupai
 *
 * @date September 2026
 *
 * Lastmodified: September 2026 : SFP-51816
 * @lastModified Given Khupai - Initial version
 *
 * @see INS_SRV_CaseTransferHistory
 */
@IsTest(SeeAllData=false)
private class INS_SRV_CaseTransferHistory_TEST {

    private static final Integer BULK_SIZE = 200;
    private static final String PERMISSION_SET_NAME = 'Case_Transfer_History';
    private static final String STANDARD_PROFILE_NAME = 'Standard User';

    /**
     * @description Returns the org default Business Hours record, so
     *              CMN_DurationWithPreviousOwnerHour__c's business-hours-aware
     *              calculation (INS_UTIL_BusinessHoursCalcHelper) has a
     *              real BusinessHoursId to work with - without one it
     *              deliberately returns null rather than a wall-clock guess.
     *
     * @return BusinessHours the org default Business Hours
     */
    private static BusinessHours getDefaultBusinessHours() {
        return [
            SELECT Id
            FROM BusinessHours
            WHERE IsDefault = true
            LIMIT 1
        ];
    }

    /**
     * @description Creates a basic Account record used by test Cases.
     *
     * @return Account the inserted Account
     */
    private static Account createTestAccount() {
        Account testAccount = new Account(Name = 'Test Account Case Transfer History');
        insert testAccount;
        return testAccount;
    }

    /**
     * @description Creates a Queue that Case records can be owned by,
     *              so the Queue-owner branch of the service can be
     *              exercised without depending on other org data.
     *
     *              The insert is wrapped in System.runAs() - Group and
     *              QueueSobject are "setup objects", and Salesforce
     *              throws MIXED_DML_OPERATION if setup-object DML and
     *              non-setup-object DML (Account/Case, inserted later
     *              in the same test method) run in the same transaction.
     *              System.runAs() opens a new DML context even when
     *              running as the current user, which is the standard
     *              workaround.
     *
     * @return Group the inserted Queue
     */
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

    /**
     * @description Creates a base Case owned by the given owner (User
     *              or Queue Id) and re-queries it with the fields the
     *              service reads.
     *
     * @param subject Case subject
     * @param ownerId Case owner (User or Queue Id)
     *
     * @return Case the inserted and re-queried Case
     */
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

    /**
     * @description Queries a Case with the fields the service reads.
     *
     * @param caseId Case Id
     *
     * @return Case the queried Case
     */
    private static Case getCaseForService(Id caseId) {
        return [
            SELECT Id, Subject, Status, OwnerId, CreatedDate, BusinessHoursId, SVC_CaseOwnerTeam__c
            FROM Case
            WHERE Id = :caseId
        ];
    }

    /**
     * @description Builds an in-memory Case snapshot with a different
     *              OwnerId. Used instead of a real "update testCase"
     *              DML so the arrange phase never fires SVC_TRH_Case's
     *              afterUpdate for real - a real update would invoke
     *              INS_SRV_CaseTransferHistory a second time and create
     *              a competing transfer history record before the
     *              explicit call under test runs.
     *
     * @param sourceCase Case to copy
     * @param ownerId Owner Id to set on the snapshot
     *
     * @return Case the in-memory snapshot
     */
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

    /**
     * @description Same as withOwner(), but also lets the caller force
     *              a specific BusinessHoursId (including null) onto the
     *              snapshot, to exercise the Duration calculation's
     *              no-Business-Hours branch independent of what the
     *              underlying Case row actually has.
     *
     * @param sourceCase Case to copy
     * @param ownerId Owner Id to set on the snapshot
     * @param businessHoursId Business Hours Id to set on the snapshot (may be null)
     *
     * @return Case the in-memory snapshot
     */
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

    /**
     * @description Same as withOwner(), but also lets the caller force a
     *              specific SVC_CaseOwnerTeam__c value onto the snapshot,
     *              so the Team copy-through in buildTracker() can be tested
     *              deterministically - real Case inserts in this test class
     *              don't reliably get SVC_CaseOwnerTeam__c populated, since
     *              the org's SVC_SetCaseOwnerTeamValue flow keys off business
     *              criteria (real queue/team mappings) that synthetic test
     *              queues and accounts won't match.
     *
     * @param sourceCase Case to copy
     * @param ownerId Owner Id to set on the snapshot
     * @param ownerTeam SVC_CaseOwnerTeam__c value to set on the snapshot
     *
     * @return Case the in-memory snapshot
     */
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

    /**
     * @description Creates an active Standard User, optionally given read-only access to
     *              CMN_History_Tracker__c. The access comes from a permission set created here
     *              that mirrors Case Transfer History (Read, no View All), so the test does not
     *              depend on that permission set already being deployed to the target org.
     *              The inserts run in System.runAs() because User, PermissionSet, ObjectPermissions
     *              and PermissionSetAssignment are setup objects and the calling tests also insert
     *              Cases (MIXED_DML_OPERATION otherwise).
     *
     * @param hasCaseTransferHistoryAccess true to give the user read-only access to transfer history
     *
     * @return User the inserted user
     */
    private static User createTestUser(Boolean hasCaseTransferHistoryAccess) {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = :STANDARD_PROFILE_NAME LIMIT 1];
        User testUser = new User(
            FirstName = 'Transfer',
            LastName = 'Agent',
            Email = 'transfer.agent@example.test',
            Username = 'transfer.agent.' + System.currentTimeMillis() + '@example.test',
            Alias = 'tagent',
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_ZA',
            TimeZoneSidKey = 'Africa/Johannesburg'
        );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
            if (hasCaseTransferHistoryAccess) {
                PermissionSet caseTransferHistory = new PermissionSet(
                    Name = PERMISSION_SET_NAME + '_TEST',
                    Label = 'Case Transfer History Test'
                );
                insert caseTransferHistory;
                insert new ObjectPermissions(
                    ParentId = caseTransferHistory.Id,
                    SobjectType = String.valueOf(CMN_History_Tracker__c.SObjectType),
                    PermissionsRead = true
                );
                insert new PermissionSetAssignment(
                    AssigneeId = testUser.Id,
                    PermissionSetId = caseTransferHistory.Id
                );
            }
        }
        return testUser;
    }

    /**
     * @description Verifies that a Queue -> User transfer creates a
     *              CMN_History_Tracker__c record with both owner sides
     *              populated correctly, as the first (count 1)
     *              transfer on the Case.
     */
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
                   CMN_PreviousOwnerUser__c, CMN_CurrentOwnerType__c, CMN_CurrentOwnerUser__c,
                   CMN_TransferCount__c, CMN_DurationWithPreviousOwnerHour__c, OwnerId
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.areEqual('Queue', tracker.CMN_PreviousOwnerType__c, 'Previous owner should be recorded as a Queue');
        Assert.areEqual(
            testQueue.Name,
            tracker.CMN_PreviousOwnerQueueName__c,
            'Previous owner queue name should be captured'
        );
        Assert.isNull(tracker.CMN_PreviousOwnerUser__c, 'Previous owner User lookup should be blank for a Queue owner');
        Assert.areEqual('User', tracker.CMN_CurrentOwnerType__c, 'Current owner should be recorded as a User');
        Assert.areEqual(newOwnerId, tracker.CMN_CurrentOwnerUser__c, 'Current owner User lookup should be populated');
        Assert.areEqual(1, tracker.CMN_TransferCount__c, 'First transfer on this Case should have a count of 1');
        Assert.isNotNull(
            tracker.CMN_DurationWithPreviousOwnerHour__c,
            'Duration with previous owner should be calculated in business hours from Case CreatedDate'
        );
        // Queues aren't whitelisted (via QueueSobject) to own CMN_History_Tracker__c records,
        // so when the previous owner was a Queue, OwnerId is deliberately left as the running
        // user rather than the Queue - see INS_SRV_CaseTransferHistory.buildTracker().
        Assert.areEqual(
            UserInfo.getUserId(),
            tracker.OwnerId,
            'Tracker owner should fall back to the running user when previous owner was a Queue'
        );
    }

    /**
     * @description Verifies that a second transfer on the same Case is
     *              recorded with a transfer count of 2, alongside the
     *              existing count-1 record from an earlier transfer.
     */
    @IsTest
    static void recordTransfersSecondTransferIncrementsCountPositiveOutcome() {
        Group testQueue = createTestQueue();
        Id currentUserId = UserInfo.getUserId();
        Case testCase = createBaseCase('Second Transfer Count Test', currentUserId);

        CMN_History_Tracker__c firstTransfer = new CMN_History_Tracker__c(
            CMN_Case__c = testCase.Id,
            CMN_TransferDate__c = System.now().addHours(-5),
            CMN_PreviousOwnerType__c = 'Queue',
            CMN_PreviousOwnerQueueName__c = testQueue.Name,
            CMN_CurrentOwnerType__c = 'User',
            CMN_CurrentOwnerUser__c = currentUserId,
            CMN_TransferCount__c = 1,
            CMN_DurationWithPreviousOwnerHour__c = 2
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
            SELECT Id, CMN_TransferCount__c, CMN_TransferDate__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            ORDER BY CMN_TransferDate__c DESC
        ];

        Assert.areEqual(2, trackers.size(), 'Should now have two transfer history records');
        Assert.areEqual(2, trackers[0].CMN_TransferCount__c, 'Second transfer should have a transfer count of 2');
        Assert.areEqual(1, trackers[1].CMN_TransferCount__c, 'Original transfer should keep a transfer count of 1');
    }

    /**
     * @description Verifies that no transfer history is created when
     *              OwnerId is unchanged between old and new Case state.
     */
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

    /**
     * @description Verifies that Duration With Previous Owner is left
     *              null (not a wall-clock guess) when the Case has no
     *              BusinessHoursId - INS_UTIL_BusinessHoursCalcHelper
     *              cannot compute a business-hours-aware duration
     *              without one, and the two should not be conflated.
     *
     *              This org auto-assigns a default BusinessHoursId to
     *              every Case on insert, so a "no Business Hours" Case
     *              can't be produced via a normal DML insert - the
     *              BusinessHoursId is forced to null on the in-memory
     *              snapshot instead, the same technique withOwner()
     *              already uses to simulate an OwnerId change.
     */
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
            SELECT Id, CMN_DurationWithPreviousOwnerHour__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.isNull(
            tracker.CMN_DurationWithPreviousOwnerHour__c,
            'Duration should be null, not a wall-clock guess, when Case has no Business Hours'
        );
    }

    /**
     * @description Verifies that CMN_PreviousOwnerTeam__c/CMN_CurrentOwnerTeam__c
     *              are copied straight from Case.SVC_CaseOwnerTeam__c (Trigger.old/
     *              new) with no independent resolution logic - that field is
     *              already correctly set by the org's existing before-save flow
     *              SVC_SetCaseOwnerTeamValue before this trigger runs.
     */
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

    /**
     * @description Verifies the service safely no-ops for null/empty
     *              inputs rather than throwing.
     */
    @IsTest
    static void recordTransfersNullInputsDoNotThrowExceptionPositiveOutcome() {
        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(null, new Map<Id, Case>());
            INS_SRV_CaseTransferHistory.recordTransfers(new List<Case>(), new Map<Id, Case>());
            INS_SRV_CaseTransferHistory.recordTransfers(new List<Case>{ new Case(Id = null) }, null);
        Test.stopTest();

        Integer trackerCount = [SELECT COUNT() FROM CMN_History_Tracker__c];
        Assert.areEqual(0, trackerCount, 'Null or empty inputs should not create any transfer history');
    }

    /**
     * @description Verifies the service is bulk-safe: 200 Cases transferred in one call
     *              create 200 trackers within governor limits (one query for earlier
     *              transfers, one for Queue names, one DML).
     *              Assumes the Case insert automation in the org can handle 200 Cases.
     */
    @IsTest
    static void recordTransfersBulkTransferCreatesOneTrackerPerCasePositiveOutcome() {
        Group testQueue = createTestQueue();
        Account testAccount = createTestAccount();
        Id businessHoursId = getDefaultBusinessHours().Id;

        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < BULK_SIZE; i++) {
            testCases.add(new Case(
                Subject = 'Bulk Transfer Test ' + i,
                Status = 'New',
                AccountId = testAccount.Id,
                OwnerId = testQueue.Id,
                BusinessHoursId = businessHoursId
            ));
        }
        insert testCases;

        List<Case> newCaseSnapshots = new List<Case>();
        Map<Id, Case> oldCaseById = new Map<Id, Case>();
        for (Case testCase : [
            SELECT Id, Subject, Status, OwnerId, CreatedDate, BusinessHoursId
            FROM Case
            WHERE Id IN :testCases
        ]) {
            oldCaseById.put(testCase.Id, withOwner(testCase, testQueue.Id));
            newCaseSnapshots.add(withOwner(testCase, UserInfo.getUserId()));
        }

        Test.startTest();
            INS_SRV_CaseTransferHistory.recordTransfers(newCaseSnapshots, oldCaseById);
        Test.stopTest();

        Integer trackerCount = [
            SELECT COUNT()
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c IN :testCases
        ];
        Assert.areEqual(BULK_SIZE, trackerCount, 'One transfer history record should be created per transferred Case');
    }

    /**
     * @description Verifies that a user without the Case Transfer History permission set
     *              (for example Omni-Channel routing or a manager) still creates a complete
     *              tracker, so the transfer history has no gaps.
     *              Assumes the Standard User profile has no access to CMN_History_Tracker__c.
     */
    @IsTest
    static void recordTransfersUserWithoutPermissionSetCreatesRecordPositiveOutcome() {
        Group testQueue = createTestQueue();
        Case testCase = createBaseCase('No Permission Set Transfer Test', testQueue.Id);
        User userWithoutAccess = createTestUser(false);

        Test.startTest();
            System.runAs(userWithoutAccess) {
                INS_SRV_CaseTransferHistory.recordTransfers(
                    new List<Case>{ withOwner(testCase, userWithoutAccess.Id) },
                    new Map<Id, Case>{ testCase.Id => withOwner(testCase, testQueue.Id) }
                );
            }
        Test.stopTest();

        List<CMN_History_Tracker__c> trackers = [
            SELECT Id, CMN_PreviousOwnerType__c, CMN_PreviousOwnerQueueName__c,
                   CMN_CurrentOwnerUser__c, CMN_TransferCount__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
        ];
        Assert.areEqual(1, trackers.size(), 'A user without the permission set should still create a tracker');
        Assert.areEqual('Queue', trackers[0].CMN_PreviousOwnerType__c, 'Previous owner type should be saved');
        Assert.areEqual(
            testQueue.Name,
            trackers[0].CMN_PreviousOwnerQueueName__c,
            'Previous owner queue name should be saved, not removed for missing field access'
        );
        Assert.areEqual(userWithoutAccess.Id, trackers[0].CMN_CurrentOwnerUser__c, 'Current owner should be saved');
        Assert.areEqual(1, trackers[0].CMN_TransferCount__c, 'Transfer count should be saved');
    }

    /**
     * @description Verifies that an agent with the read-only Case Transfer History permission
     *              set (no View All) counts an earlier transfer owned by another user that the
     *              agent cannot see, so Transfer Count stays correct under OWD Private.
     */
    @IsTest
    static void recordTransfersCountsTransferOwnedByAnotherUserPositiveOutcome() {
        Group testQueue = createTestQueue();
        Case testCase = createBaseCase('Hidden Transfer Count Test', testQueue.Id);

        // Earlier transfer owned by the running test user, not by the agent.
        insert new CMN_History_Tracker__c(
            CMN_Case__c = testCase.Id,
            CMN_TransferDate__c = System.now().addHours(-5),
            CMN_PreviousOwnerType__c = 'User',
            CMN_PreviousOwnerUser__c = UserInfo.getUserId(),
            CMN_CurrentOwnerType__c = 'Queue',
            CMN_CurrentOwnerQueueName__c = testQueue.Name,
            CMN_TransferCount__c = 1
        );
        User agentWithAccess = createTestUser(true);

        Test.startTest();
            System.runAs(agentWithAccess) {
                INS_SRV_CaseTransferHistory.recordTransfers(
                    new List<Case>{ withOwner(testCase, agentWithAccess.Id) },
                    new Map<Id, Case>{ testCase.Id => withOwner(testCase, testQueue.Id) }
                );
            }
        Test.stopTest();

        List<CMN_History_Tracker__c> trackers = [
            SELECT Id, CMN_TransferCount__c, CMN_CurrentOwnerUser__c
            FROM CMN_History_Tracker__c
            WHERE CMN_Case__c = :testCase.Id
            ORDER BY CMN_TransferDate__c DESC
        ];
        Assert.areEqual(2, trackers.size(), 'The agent should have created a second transfer record');
        Assert.areEqual(2, trackers[0].CMN_TransferCount__c, 'The agent\'s transfer should count the earlier transfer');
        Assert.areEqual(agentWithAccess.Id, trackers[0].CMN_CurrentOwnerUser__c, 'Current owner should be the agent');
    }
}