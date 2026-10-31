/**
 * @description Records Case ownership and team transfers on CMN_History_Tracker__c
 *              whenever Case.OwnerId changes.
 *              <br/>SFP-51816
 *
 * @author Given Khupai
 *
 * @date September 2026
 *
 * @see INS_SRV_CaseTransferHistory_TEST
 *
 * Lastmodified: September 2026 : SFP-51816
 * @lastModified Given Khupai - Initial version
 */
public with sharing class INS_SRV_CaseTransferHistory {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('INS_SRV_CaseTransferHistory');

    private static final String LOG_AREA = 'Case Transfer History';

    private static final String OWNER_TYPE_USER = 'User';
    private static final String OWNER_TYPE_QUEUE = 'Queue';

    // Queue (Group) Ids share this key prefix, which tells a Queue owner apart from a User owner.
    private static final String QUEUE_ID_PREFIX =
        Group.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).getKeyPrefix();

    /**
     * @description Prevents instantiation - all entry points are static.
     */
    private INS_SRV_CaseTransferHistory() {
    }

    /**
     * @description Bulk entry point called from SVC_TRH_Case.andFinally(). Creates one
     *              CMN_History_Tracker__c record for every Case whose OwnerId changed.
     *              Records are created for every transfer, whoever makes it (agents, managers,
     *              Omni-Channel routing, integration users), so the history has no gaps.
     *              Failures are logged and never re-thrown, so a history failure never
     *              rolls back the Case save that triggered it.
     *              <br/>SFP-51816
     *
     * @param newCases Case records after the update (Trigger.new values)
     * @param oldCaseById Case records before the update (Trigger.old), keyed by Id
     */
    public static void recordTransfers(List<Case> newCases, Map<Id, Case> oldCaseById) {
        List<Case> ownerChangedCases = filterOwnerChangedCases(newCases, oldCaseById);

        if (!ownerChangedCases.isEmpty()) {
            insertTrackers(ownerChangedCases, oldCaseById);
        }
    }

    /**
     * @description Returns the Cases whose OwnerId changed, so that updates to other fields
     *              never create a transfer record.
     *
     * @param newCases Case records after the update
     * @param oldCaseById Case records before the update, keyed by Id
     *
     * @return List<Case> Cases whose OwnerId changed; empty when either input is null
     */
    private static List<Case> filterOwnerChangedCases(List<Case> newCases, Map<Id, Case> oldCaseById) {
        List<Case> ownerChangedCases = new List<Case>();
        List<Case> candidateCases = (newCases == null || oldCaseById == null) ? new List<Case>() : newCases;

        for (Case newCase : candidateCases) {
            Case oldCase = oldCaseById.get(newCase.Id);
            if (oldCase != null && oldCase.OwnerId != newCase.OwnerId) {
                ownerChangedCases.add(newCase);
            }
        }
        return ownerChangedCases;
    }

    /**
     * @description Builds and inserts one tracker per transferred Case in a single DML.
     *
     * @param ownerChangedCases Cases whose OwnerId changed
     * @param oldCaseById Case records before the update, keyed by Id
     */
    private static void insertTrackers(List<Case> ownerChangedCases, Map<Id, Case> oldCaseById) {
        try {
            TransferContext context = new TransferContext(ownerChangedCases, oldCaseById);

            List<CMN_History_Tracker__c> trackers = new List<CMN_History_Tracker__c>();
            for (Case newCase : ownerChangedCases) {
                trackers.add(buildTracker(newCase, oldCaseById.get(newCase.Id), context));
            }

            new TrackerSystemAccess().insertTrackers(trackers);
        } catch (Exception ex) {
            // Deliberately broad: transfer history must never roll back the Case save that triggered it.
            LOGGER.error(
                'Failed to record transfer history for Cases {0}',
                LOG_AREA,
                new List<Object>{ new Map<Id, Case>(ownerChangedCases).keySet() },
                ex
            );
        }
    }

    /**
     * @description Builds one tracker (not yet inserted) for a single Case transfer.
     *
     * @param newCase Case after the update
     * @param oldCase Case before the update
     * @param context Data resolved once for the whole batch
     *
     * @return CMN_History_Tracker__c the populated tracker record
     */
    private static CMN_History_Tracker__c buildTracker(Case newCase, Case oldCase, TransferContext context) {
        CMN_History_Tracker__c tracker = new CMN_History_Tracker__c();
        tracker.CMN_Case__c = newCase.Id;
        tracker.CMN_TransferDate__c = context.changedDate;

        // SVC_CaseOwnerTeam__c is set by the before-save flow SVC_SetCaseOwnerTeamValue earlier
        // in the same save, so Trigger.old/new already hold the correct previous and current team.
        tracker.CMN_PreviousOwnerTeam__c = oldCase.SVC_CaseOwnerTeam__c;
        tracker.CMN_CurrentOwnerTeam__c = newCase.SVC_CaseOwnerTeam__c;

        // The previous user owns the record so role-hierarchy reports stay visible to them and
        // their managers. Queues cannot own this object (it is not added to their QueueSobject
        // list), so when the previous owner was a Queue the running user stays the owner.
        if (!isQueueId(oldCase.OwnerId)) {
            tracker.OwnerId = oldCase.OwnerId;
        }

        populatePreviousOwner(tracker, oldCase.OwnerId, context.queueNameById);
        populateCurrentOwner(tracker, newCase.OwnerId, context.queueNameById);

        // Earlier transfers are ordered latest first, so index 0 is when the previous owner
        // received the Case. The first transfer is measured from Case creation.
        List<CMN_History_Tracker__c> priorTransfersForCase = context.priorTransfersByCaseId.get(newCase.Id);
        Datetime heldSince = newCase.CreatedDate;
        tracker.CMN_TransferCount__c = 1;
        if (priorTransfersForCase != null) {
            tracker.CMN_TransferCount__c = priorTransfersForCase.size() + 1;
            heldSince = priorTransfersForCase[0].CMN_TransferDate__c;
        }
        tracker.CMN_DurationWithPreviousOwnerHour__c =
            businessHoursBetween(newCase.BusinessHoursId, heldSince, context.changedDate);

        return tracker;
    }

    /**
     * @description Sets the previous owner type and either the previous User or Queue name.
     *
     * @param tracker Tracker record being built
     * @param ownerId Previous Case owner (User or Queue Id)
     * @param queueNameById Queue names keyed by Queue Id
     */
    private static void populatePreviousOwner(
        CMN_History_Tracker__c tracker,
        Id ownerId,
        Map<Id, String> queueNameById
    ) {
        if (isQueueId(ownerId)) {
            tracker.CMN_PreviousOwnerType__c = OWNER_TYPE_QUEUE;
            tracker.CMN_PreviousOwnerQueueName__c = queueNameById.get(ownerId);
        } else {
            tracker.CMN_PreviousOwnerType__c = OWNER_TYPE_USER;
            tracker.CMN_PreviousOwnerUser__c = ownerId;
        }
    }

    /**
     * @description Sets the current owner type and either the current User or Queue name.
     *
     * @param tracker Tracker record being built
     * @param ownerId New Case owner (User or Queue Id)
     * @param queueNameById Queue names keyed by Queue Id
     */
    private static void populateCurrentOwner(
        CMN_History_Tracker__c tracker,
        Id ownerId,
        Map<Id, String> queueNameById
    ) {
        if (isQueueId(ownerId)) {
            tracker.CMN_CurrentOwnerType__c = OWNER_TYPE_QUEUE;
            tracker.CMN_CurrentOwnerQueueName__c = queueNameById.get(ownerId);
        } else {
            tracker.CMN_CurrentOwnerType__c = OWNER_TYPE_USER;
            tracker.CMN_CurrentOwnerUser__c = ownerId;
        }
    }

    /**
     * @description Loads all earlier transfers for the Cases in one query and groups them
     *              by Case, latest transfer first. The query runs in system mode, so transfers
     *              owned by other users are counted even though the running user cannot see them.
     *
     * @param cases Cases whose OwnerId changed
     *
     * @return Map<Id, List<CMN_History_Tracker__c>> earlier transfers keyed by Case Id
     */
    private static Map<Id, List<CMN_History_Tracker__c>> mapPriorTransfersByCaseId(List<Case> cases) {
        Map<Id, List<CMN_History_Tracker__c>> priorTransfersByCaseId =
            new Map<Id, List<CMN_History_Tracker__c>>();

        Set<Id> caseIds = new Map<Id, Case>(cases).keySet();
        for (CMN_History_Tracker__c priorTransfer : new TrackerSystemAccess().selectByCaseIds(caseIds)) {
            if (!priorTransfersByCaseId.containsKey(priorTransfer.CMN_Case__c)) {
                priorTransfersByCaseId.put(priorTransfer.CMN_Case__c, new List<CMN_History_Tracker__c>());
            }
            priorTransfersByCaseId.get(priorTransfer.CMN_Case__c).add(priorTransfer);
        }
        return priorTransfersByCaseId;
    }

    /**
     * @description Resolves every old and new Queue owner in the batch to its name in one query.
     *              Team is not resolved here; it is copied from Case.SVC_CaseOwnerTeam__c.
     *
     * @param ownerChangedCases Cases whose OwnerId changed
     * @param oldCaseById Case records before the update, keyed by Id
     *
     * @return Map<Id, String> Queue names keyed by Queue Id
     */
    private static Map<Id, String> mapQueueNameById(List<Case> ownerChangedCases, Map<Id, Case> oldCaseById) {
        Map<Id, String> queueNameById = new Map<Id, String>();

        Set<Id> queueIds = new Set<Id>();
        for (Case newCase : ownerChangedCases) {
            collectQueueId(oldCaseById.get(newCase.Id).OwnerId, queueIds);
            collectQueueId(newCase.OwnerId, queueIds);
        }

        if (!queueIds.isEmpty()) {
            for (Group queue : new SEL_Group().selectByIds(queueIds)) {
                queueNameById.put(queue.Id, queue.Name);
            }
        }
        return queueNameById;
    }

    /**
     * @description Adds the owner Id to the set when it is a Queue.
     *
     * @param ownerId Case owner (User or Queue Id)
     * @param queueIds Queue Ids being collected
     */
    private static void collectQueueId(Id ownerId, Set<Id> queueIds) {
        if (isQueueId(ownerId)) {
            queueIds.add(ownerId);
        }
    }

    /**
     * @description Checks whether an owner Id belongs to a Queue rather than a User.
     *
     * @param ownerId Case owner Id
     *
     * @return Boolean true if the Id is a Queue Id
     */
    private static Boolean isQueueId(Id ownerId) {
        return ownerId != null && String.valueOf(ownerId).startsWith(QUEUE_ID_PREFIX);
    }

    /**
     * @description Calculates elapsed business hours, matching INS_SRV_CaseMilestoneMetrics.
     *              Wall-clock time would count nights and weekends as time with the owner.
     *              Returns null when the Case has no Business Hours, because
     *              INS_UTIL_BusinessHoursCalcHelper cannot calculate without them.
     *
     * @param businessHoursId Business Hours of the Case
     * @param startDate Start of the period
     * @param endDate End of the period
     *
     * @return Decimal elapsed business hours, or null if any input is null
     */
    private static Decimal businessHoursBetween(Id businessHoursId, Datetime startDate, Datetime endDate) {
        Decimal elapsedHours;
        if (businessHoursId != null && startDate != null && endDate != null) {
            Long elapsedMilliseconds = INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                businessHoursId,
                startDate,
                endDate
            );
            elapsedHours = INS_UTIL_BusinessHoursCalcHelper.convertMilliSecondsToHours(elapsedMilliseconds);
        }
        return elapsedHours;
    }

    /**
     * @description Holds the data resolved once per batch (transfer time, Queue names and
     *              earlier transfers), so each record is built without further queries.
     */
    private class TransferContext {
        private final Datetime changedDate = Datetime.now();
        private final Map<Id, String> queueNameById;
        private final Map<Id, List<CMN_History_Tracker__c>> priorTransfersByCaseId;

        /**
         * @description Resolves Queue names and earlier transfers for the whole batch.
         *
         * @param ownerChangedCases Cases whose OwnerId changed
         * @param oldCaseById Case records before the update, keyed by Id
         */
        private TransferContext(List<Case> ownerChangedCases, Map<Id, Case> oldCaseById) {
            queueNameById = mapQueueNameById(ownerChangedCases, oldCaseById);
            priorTransfersByCaseId = mapPriorTransfersByCaseId(ownerChangedCases);
        }
    }

    /**
     * @description Reads and writes transfer history in system mode (Design Authority exception,
     *              SFP-51816). Transfer history is system audit data, like standard Field History
     *              Tracking, so it must not depend on the running user's access:
     *              <br/>- Earlier transfers are owned by other users and are Private, so a query in
     *              user mode would miss them and reset Transfer Count and Duration.
     *              <br/>- An agent who transfers a Case to a queue they are not a member of loses read
     *              access to that Case in the same save, and Salesforce then rejects the CMN_Case__c
     *              lookup (INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY).
     *              <br/>- Users without the Case Transfer History permission set (Omni-Channel routing,
     *              managers, integration users) must still leave a record, or the history has gaps.
     *              Who can view the records is controlled by OWD Private, the role hierarchy and the
     *              Case Transfer History permission set (Read only).
     */
    private without sharing class TrackerSystemAccess {

        /**
         * @description Retrieves every earlier transfer for the Cases, whoever owns them.
         *
         * @param caseIds Case record Ids
         *
         * @return List<CMN_History_Tracker__c> earlier transfers, latest first
         */
        private List<CMN_History_Tracker__c> selectByCaseIds(Set<Id> caseIds) {
            return SEL_CMN_HistoryTracker.newInstance().selectByCaseIds(caseIds);
        }

        /**
         * @description Inserts the trackers in a single DML through the Unit of Work.
         *
         * @param trackers Tracker records to insert
         */
        private void insertTrackers(List<SObject> trackers) {
            sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
                (sbgplatform.fflib_SObjectUnitOfWork) ORG_Application.unitOfWork.newInstance();
            unitOfWork.registerNew(trackers);
            unitOfWork.commitWork();
        }
    }
}