/*------------------------------------------------------------
Author:        Given Khupai
Description:   Bulk service that records Case ownership/team transfers
               on CMN_History_Tracker__c whenever Case.OwnerId changes.
               Replaces the record-triggered Flow originally proposed for
               SFP-51816 - the TDA review flagged that a Flow recalculating
               Transfer Sequence/Duration per record would hit the 101 SOQL
               query limit under bulk owner reassignment, so this logic is
               implemented as a single bulkified Apex pass instead.
Test Class:    INS_SRV_CaseTransferHistory_TEST

02-09-2026     Given Khupai     Initial version (SFP-51816)

------------------------------------------------------------*/
public with sharing class INS_SRV_CaseTransferHistory {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('INS_SRV_CaseTransferHistory');

    private static final String LOG_AREA = 'Case Transfer History';

    private static final String OWNER_TYPE_USER = 'User';
    private static final String OWNER_TYPE_QUEUE = 'Queue';

    // Group (Queue) record IDs always start with this key prefix - the same
    // check the original Flow design used to distinguish a Queue owner from a User owner.
    private static final String QUEUE_ID_PREFIX =
        Group.SObjectType.getDescribe().getKeyPrefix();

    /*------------------------------------------------------------
    *   Purpose:  Prevents instantiation - all entry points are static.
    *--------------------------------------------------------------*/
    private INS_SRV_CaseTransferHistory() {
    }

    /*------------------------------------------------------------
    *   Purpose:  Bulk entry point - called from SVC_TRH_Case.andFinally().
    *             For every Case whose OwnerId changed, creates one
    *             CMN_History_Tracker__c record capturing the previous
    *             and current owner (User or Queue), how long the previous
    *             owner held the case, and this transfer's
    *             sequence number on the case.
    *   Parameters: newCases    - Case records after the update (Trigger.new values)
    *               oldCaseById - old Case values (Trigger.old), keyed by Id
    *   Returns:    void
    *   Throws:     None - exceptions are logged, not re-thrown, so a
    *               failure here never rolls back the Case DML that
    *               triggered it. This mirrors INS_SRV_CaseMilestoneMetrics.
    *--------------------------------------------------------------*/
    public static void recordTransfers(List<Case> newCases, Map<Id, Case> oldCaseById) {
        if (newCases == null || newCases.isEmpty() || oldCaseById == null) {
            return;
        }

        if (!hasRequiredCrudAccess()) {
            LOGGER.error(
                'Skipping transfer history processing - running user lacks CRUD access on CMN_History_Tracker__c',
                LOG_AREA,
                new List<Object>(),
                null
            );
            return;
        }

        List<Case> ownerChangedCases = filterOwnerChangedCases(newCases, oldCaseById);
        if (ownerChangedCases.isEmpty()) {
            return;
        }

        try {
            Map<Id, List<CMN_History_Tracker__c>> priorTransfersByCaseId =
                mapPriorTransfersByCaseId(ownerChangedCases);

            OwnerLookups lookups = resolveOwnerLookups(ownerChangedCases, oldCaseById);

            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                (sbgplatform.fflib_SObjectUnitOfWork)
                    ORG_Application.unitOfWork.newInstance();

            Datetime changedDate = Datetime.now();

            for (Case newCase : ownerChangedCases) {
                Case oldCase = oldCaseById.get(newCase.Id);
                CMN_History_Tracker__c tracker = buildTracker(
                    newCase,
                    oldCase,
                    changedDate,
                    lookups,
                    priorTransfersByCaseId.get(newCase.Id)
                );
                unitOfWork.registerNew(tracker);
            }

            unitOfWork.commitWork();

        } catch (Exception ex) {
            LOGGER.error(
                'Failed to record transfer history for Cases {0}',
                LOG_AREA,
                new List<Object>{ new Map<Id, Case>(ownerChangedCases).keySet() },
                ex
            );
        }
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies the running user has create access on
    *             CMN_History_Tracker__c before any DML is attempted.
    *--------------------------------------------------------------*/
    private static Boolean hasRequiredCrudAccess() {
        return Schema.sObjectType.CMN_History_Tracker__c.isCreateable();
    }

    /*------------------------------------------------------------
    *   Purpose:  Narrows the batch down to Cases whose OwnerId actually
    *             changed - Case Milestone/other unrelated field updates
    *             on the same Case must not create a spurious transfer record.
    *--------------------------------------------------------------*/
    private static List<Case> filterOwnerChangedCases(List<Case> newCases, Map<Id, Case> oldCaseById) {
        List<Case> changed = new List<Case>();
        for (Case newCase : newCases) {
            Case oldCase = oldCaseById.get(newCase.Id);
            if (oldCase != null && oldCase.OwnerId != newCase.OwnerId) {
                changed.add(newCase);
            }
        }
        return changed;
    }

    /*------------------------------------------------------------
    *   Purpose:  Single bulk query for all existing transfer history on
    *             the affected Cases, grouped and ordered (descending) by
    *             Transfer Date so index 0 per Case is always the latest
    *             prior transfer. Used to derive both Transfer Sequence
    *             (list size + 1) and Duration With Previous Owner
    *             (elapsed time since index 0's Transfer Date).
    *--------------------------------------------------------------*/
    private static Map<Id, List<CMN_History_Tracker__c>> mapPriorTransfersByCaseId(List<Case> cases) {
        Set<Id> caseIds = new Map<Id, Case>(cases).keySet();

        Map<Id, List<CMN_History_Tracker__c>> priorTransfersByCaseId =
            new Map<Id, List<CMN_History_Tracker__c>>();

        for (CMN_History_Tracker__c priorTransfer :
                SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(caseIds)) {
            if (!priorTransfersByCaseId.containsKey(priorTransfer.CMN_Case__c)) {
                priorTransfersByCaseId.put(priorTransfer.CMN_Case__c, new List<CMN_History_Tracker__c>());
            }
            priorTransfersByCaseId.get(priorTransfer.CMN_Case__c).add(priorTransfer);
        }

        return priorTransfersByCaseId;
    }

    /*------------------------------------------------------------
    *   Purpose:  Small value holder for the bulk-resolved Queue
    *             display names needed to populate every tracker
    *             record in the batch.
    *--------------------------------------------------------------*/
    private class OwnerLookups {
        Map<Id, String> queueNameById = new Map<Id, String>();
    }

    /*------------------------------------------------------------
    *   Purpose:  Resolves, in bulk, every distinct old/new Queue owner
    *             Id in the batch to its display Name.
    *
    *             Note: this does NOT resolve Team. An earlier version
    *             of this service tried to derive Team independently via
    *             CMN_TeamMember__c.CMN_PrimaryTeam__c (never populated
    *             org-wide - 0 of 21 records) and SVC_QueueTeamMapping__mdt
    *             (inconsistently keyed by Name vs DeveloperName), both of
    *             which proved unreliable. CMN_PreviousOwnerTeam__c/
    *             CMN_CurrentOwnerTeam__c are populated in buildTracker()
    *             instead, by copying Case.SVC_CaseOwnerTeam__c directly off
    *             Trigger.old/new - that field is already correctly resolved
    *             by the existing before-save flow SVC_SetCaseOwnerTeamValue,
    *             for both User and Queue owners, before this trigger runs.
    *--------------------------------------------------------------*/
    private static OwnerLookups resolveOwnerLookups(List<Case> ownerChangedCases, Map<Id, Case> oldCaseById) {
        OwnerLookups lookups = new OwnerLookups();

        Set<Id> queueIds = new Set<Id>();

        for (Case newCase : ownerChangedCases) {
            collectQueueId(oldCaseById.get(newCase.Id).OwnerId, queueIds);
            collectQueueId(newCase.OwnerId, queueIds);
        }

        for (Group g : [SELECT Id, Name FROM Group WHERE Id IN :queueIds]) {
            lookups.queueNameById.put(g.Id, g.Name);
        }

        return lookups;
    }

    private static void collectQueueId(Id ownerId, Set<Id> queueIds) {
        if (ownerId != null && isQueueId(ownerId)) {
            queueIds.add(ownerId);
        }
    }

    private static Boolean isQueueId(Id ownerId) {
        return ownerId != null && String.valueOf(ownerId).startsWith(QUEUE_ID_PREFIX);
    }

    /*------------------------------------------------------------
    *   Purpose:  Builds one fully-populated (but not yet inserted)
    *             CMN_History_Tracker__c for a single Case transfer.
    *--------------------------------------------------------------*/
    private static CMN_History_Tracker__c buildTracker(
        Case newCase,
        Case oldCase,
        Datetime changedDate,
        OwnerLookups lookups,
        List<CMN_History_Tracker__c> priorTransfersForCase
    ) {
        CMN_History_Tracker__c tracker = new CMN_History_Tracker__c();
        tracker.CMN_Case__c = newCase.Id;
        tracker.CMN_TransferDate__c = changedDate;

        // SVC_CaseOwnerTeam__c is set by the existing before-save flow
        // SVC_SetCaseOwnerTeamValue, which runs earlier in the same save -
        // so Trigger.old/new already carry the correct previous/current team
        // for both User and Queue owners, with no query needed here at all.
        tracker.CMN_PreviousOwnerTeam__c = oldCase.SVC_CaseOwnerTeam__c;
        tracker.CMN_CurrentOwnerTeam__c = newCase.SVC_CaseOwnerTeam__c;

        // Owner = previous owner, so Private-OWD role-hierarchy reports remain
        // visible to the agent/team who just lost the case, matching the
        // original design intent captured in the TD's data model diagram.
        // Only done when the previous owner was a User: Queues can only own
        // object types explicitly whitelisted for them via QueueSobject, and
        // CMN_History_Tracker__c isn't (and realistically won't be) added to
        // every routing Queue's whitelist - assigning to a Queue here throws
        // an invalid-owner DML error, which would otherwise be silently
        // swallowed by this method's caller. When the previous owner was a
        // Queue, OwnerId is left as the running user (automation context).
        if (!isQueueId(oldCase.OwnerId)) {
            tracker.OwnerId = oldCase.OwnerId;
        }

        populateOwnerSide(tracker, oldCase.OwnerId, lookups, true);
        populateOwnerSide(tracker, newCase.OwnerId, lookups, false);

        if (priorTransfersForCase == null || priorTransfersForCase.isEmpty()) {
            tracker.CMN_TransferSequence__c = 1;
            tracker.CMN_DurationWithPreviousOwner__c =
                businessHoursBetween(newCase.BusinessHoursId, newCase.CreatedDate, changedDate);
        } else {
            tracker.CMN_TransferSequence__c = priorTransfersForCase.size() + 1;
            // priorTransfersForCase is ordered by Transfer Date descending,
            // so index 0 is this Case's most recent prior transfer.
            tracker.CMN_DurationWithPreviousOwner__c =
                businessHoursBetween(newCase.BusinessHoursId, priorTransfersForCase[0].CMN_TransferDate__c, changedDate);
        }

        return tracker;
    }

    private static void populateOwnerSide(
        CMN_History_Tracker__c tracker,
        Id ownerId,
        OwnerLookups lookups,
        Boolean isPreviousSide
    ) {
        Boolean isQueue = isQueueId(ownerId);
        String queueName = isQueue ? lookups.queueNameById.get(ownerId) : null;

        if (isPreviousSide) {
            tracker.CMN_PreviousOwnerType__c = isQueue ? OWNER_TYPE_QUEUE : OWNER_TYPE_USER;
            if (isQueue) {
                tracker.CMN_PreviousOwnerQueueName__c = queueName;
            } else {
                tracker.CMN_PreviousUserOwner__c = ownerId;
            }
        } else {
            tracker.CMN_CurrentOwnerType__c = isQueue ? OWNER_TYPE_QUEUE : OWNER_TYPE_USER;
            if (isQueue) {
                tracker.CMN_CurrentOwnerQueueName__c = queueName;
            } else {
                tracker.CMN_CurrentUserOwner__c = ownerId;
            }
        }
    }

    /*------------------------------------------------------------
    *   Purpose:  Business-hours-aware elapsed time, matching the
    *             pattern INS_SRV_CaseMilestoneMetrics already uses
    *             for Case TAT calculations - raw wall-clock time
    *             would count nights/weekends the case sat untouched
    *             as "duration with owner", inflating the figure.
    *             Falls back to null (rather than raw wall-clock time)
    *             when the Case has no Business Hours assigned, since
    *             INS_UTIL_BusinessHoursCalcHelper cannot compute an
    *             hours-aware duration without one.
    *--------------------------------------------------------------*/
    private static Decimal businessHoursBetween(Id businessHoursId, Datetime startDate, Datetime endDate) {
        if (businessHoursId == null || startDate == null || endDate == null) {
            return null;
        }
        Long elapsedMs = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
            businessHoursId,
            startDate,
            endDate
        );
        return INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(elapsedMs);
    }
}