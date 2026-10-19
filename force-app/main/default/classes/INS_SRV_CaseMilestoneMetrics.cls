/*------------------------------------------------------------
Author:        Given Khupai
Company:       Salesforce
Description:   Computes elapsed time between Case milestone dates
               in business hours and stores the calculated values
               on CMN_CaseMilestoneMetric__c.
Test Class:    INS_SRV_CaseMilestoneMetrics_TEST

23-06-2026     Given Khupai     Initial version (SFP-55625)

------------------------------------------------------------*/
public with sharing class INS_SRV_CaseMilestoneMetrics {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory()
            .createLogger('INS_SRV_CaseMilestoneMetrics');

    private static final String LOG_AREA = 'Case SLA Metrics';

    /*------------------------------------------------------------
    *   Purpose:  Prevents instantiation — all entry points are
    *             static. 
    *   Parameters: none
    *   Returns:    n/a
    *--------------------------------------------------------------*/
    private INS_SRV_CaseMilestoneMetrics() {
    }

    /*------------------------------------------------------------
    *   Purpose:  Entry point — evaluates the Case milestone dates
    *             and creates or updates the corresponding
    *             CMN_CaseMilestoneMetric__c record.
    *   Parameters: newCase — the Case record with current field values
    *   Returns:    void
    *   Throws:     None (exceptions are logged; see design note below)
    *--------------------------------------------------------------
    *   Design note: The catch block intentionally does NOT re-throw
    *   because this method is called from a trigger handler.
    *   Re-throwing would roll back the entire Case DML transaction,
    *   which is unacceptable for a metrics-only side effect.
    *--------------------------------------------------------------*/
    public static void updateCaseSlaDetails(Case newCase) {
        if (newCase == null) {
            return;
        }
        updateCaseSlaDetailsForCases(new List<Case>{ newCase });
    }

    /*------------------------------------------------------------
    *   Purpose:  Bulk entry point — evaluates the Case milestone dates
    *             for a batch of Cases and creates or updates the
    *             corresponding CMN_CaseMilestoneMetric__c records
    *             using a single selector query and UnitOfWork commit.
    *             Named distinctly (rather than overloading
    *             updateCaseSlaDetails) so that any existing or future
    *             caller passing a literal null is never ambiguous
    *             between the single-Case and List<Case> signatures.
    *   Parameters: newCases — the Case records with current field values
    *   Returns:    void
    *   Throws:     None (exceptions are logged; see design note above)
    *--------------------------------------------------------------*/
    public static void updateCaseSlaDetailsForCases(List<Case> newCases) {
        if (newCases == null || newCases.isEmpty()) {
            return;
        }

        if (!hasRequiredCrudAccess()) {
            LOGGER.error(
                'Skipping SLA metric processing - running user lacks CRUD access on CMN_CaseMilestoneMetric__c',
                LOG_AREA,
                new List<Object>(),
                null
            );
            return;
        }

        Set<Id> caseIds = new Set<Id>();
        for (Case newCase : newCases) {
            caseIds.add(newCase.Id);
        }

        sbgplatform.fflib_SObjectUnitOfWork unitOfWork =
            (sbgplatform.fflib_SObjectUnitOfWork)
                ORG_Application.unitOfWork.newInstance();

        try {
            Map<Id, CMN_CaseMilestoneMetric__c> existingMetricsByCaseId =
                mapLatestMetricByCaseId(caseIds);

            for (Case newCase : newCases) {
                CMN_CaseMilestoneMetric__c existingMetric =
                    existingMetricsByCaseId.get(newCase.Id);

                if (existingMetric != null) {
                    processExistingMetric(unitOfWork, newCase, existingMetric);
                } else {
                    createNewMetric(unitOfWork, newCase);
                }
            }

            unitOfWork.commitWork();

        } catch (Exception ex) {
            LOGGER.error(
                'Failed to update SLA metrics for Cases {0}',
                LOG_AREA,
                new List<Object>{ caseIds },
                ex
            );
        }
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies the running user has object-level create
    *             and update access on CMN_CaseMilestoneMetric__c
    *             before any DML is attempted.
    *   Returns:    Boolean
    *--------------------------------------------------------------*/
    private static Boolean hasRequiredCrudAccess() {
        return Schema.sObjectType.CMN_CaseMilestoneMetric__c.isCreateable()
            && Schema.sObjectType.CMN_CaseMilestoneMetric__c.isUpdateable();
    }

    /*------------------------------------------------------------
    *   Purpose:  Queries existing metric records for the given Case
    *             Ids in a single SOQL call and returns the most
    *             recent metric per Case, keyed by Case Id.
    *   Parameters: caseIds — Set of Case record Ids
    *   Returns:    Map<Id, CMN_CaseMilestoneMetric__c>
    *--------------------------------------------------------------*/
    private static Map<Id, CMN_CaseMilestoneMetric__c> mapLatestMetricByCaseId(
        Set<Id> caseIds
    ) {
        Map<Id, CMN_CaseMilestoneMetric__c> metricsByCaseId =
            new Map<Id, CMN_CaseMilestoneMetric__c>();

        for (CMN_CaseMilestoneMetric__c metric :
                SEL_CMN_CaseMilestoneMetric.newInstance().selectByCaseIds(caseIds)) {
            if (!metricsByCaseId.containsKey(metric.CMN_Case__c)) {
                metricsByCaseId.put(metric.CMN_Case__c, metric);
            }
        }

        return metricsByCaseId;
    }

    /*------------------------------------------------------------
    *   Purpose:  Handles updates to an existing metric record
    *             based on which milestone dates are newly available.
    *   Parameters: unitOfWork — UoW instance for DML registration
    *               newCase    — the triggering Case
    *               metric     — the existing metric record
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void processExistingMetric(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        LOGGER.info(
            'Processing existing metric record {0}',
            LOG_AREA,
            new List<Object>{ metric.Id }
        );

        if (isReadyForClassificationUpdate(newCase, metric)) {
            applyClassificationUpdate(unitOfWork, newCase, metric);

        } else if (isReadyForResolutionUpdate(newCase, metric)) {
            applyResolutionUpdate(unitOfWork, newCase, metric);

        } else if (isReadyForClosedCaseResolution(newCase, metric)) {
            applyClosedCaseResolution(unitOfWork, newCase, metric);
        }
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a brand-new metric record when none
    *             exists for the Case.
    *   Parameters: unitOfWork — UoW instance for DML registration
    *               newCase    — the triggering Case
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void createNewMetric(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase
    ) {
        LOGGER.info(
            'Creating first TAT record for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );

        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c();
        metric.CMN_Case__c = newCase.Id;

        if (newCase.SVC_ResolvedDate__c != null || newCase.ClosedDate != null) {
            applyNewResolution(unitOfWork, newCase, metric);

        } else if (isNewClassificationOnly(newCase)) {
            applyNewClassification(unitOfWork, newCase, metric);

        } else if (isNewAllocationOnly(newCase)) {
            applyNewAllocation(unitOfWork, newCase, metric);
        }
    }

    // ─── Branch condition helpers ───────────────────────────────

    private static Boolean isReadyForClassificationUpdate(
        Case c,
        CMN_CaseMilestoneMetric__c m
    ) {
        return c.ClosedDate == null
            && c.SVC_Case_Allocation_Date__c != null
            && m.CMN_CaseAllocationTurnaroundTime__c != null
            && c.SVC_CaseClassificationDate__c != null
            && m.CMN_ClassificationTurnaroundTime__c == null;
    }

    private static Boolean isReadyForResolutionUpdate(
        Case c,
        CMN_CaseMilestoneMetric__c m
    ) {
        return c.SVC_ResolvedDate__c != null
            && c.SVC_CaseClassificationDate__c != null
            && m.CMN_ClassificationTurnaroundTime__c != null
            && m.CMN_ResolutionTurnaroundTime__c == null;
    }

    private static Boolean isReadyForClosedCaseResolution(
        Case c,
        CMN_CaseMilestoneMetric__c m
    ) {
        return c.ClosedDate != null
            && c.SVC_CaseClassificationDate__c != null
            && m.CMN_ClassificationTurnaroundTime__c != null
            && m.CMN_ResolutionTurnaroundTime__c == null;
    }

    private static Boolean isNewAllocationOnly(Case c) {
        return c.ClosedDate == null
            && c.SVC_Case_Allocation_Date__c != null
            && c.SVC_CaseClassificationDate__c == null;
    }

    private static Boolean isNewClassificationOnly(Case c) {
        return c.ClosedDate == null
            && c.SVC_CaseClassificationDate__c != null;
    }

    // ─── Update-path methods (existing metric) ─────────────────

    /*------------------------------------------------------------
    *   Purpose:  Calculates and writes classification TAT on an
    *             existing metric.
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyClassificationUpdate(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        LOGGER.info(
            'Starting classification update for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );

        Long classificationMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.SVC_Case_Allocation_Date__c,
                newCase.SVC_CaseClassificationDate__c
            );

        metric.CMN_ClassificationTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(classificationMs);
        metric.CMN_ClassificationMillisecond__c = classificationMs;

        registerCaseMetricUpdate(unitOfWork, metric);
    }

    /*------------------------------------------------------------
    *   Purpose:  Calculates and writes resolution, overall and
    *             specialist TAT on an existing metric when the
    *             Case is resolved (not yet closed).
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyResolutionUpdate(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        LOGGER.info(
            'Processing resolution update for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );

        Long resolutionMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.SVC_CaseClassificationDate__c,
                newCase.SVC_ResolvedDate__c
            );

        Long overallMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.CreatedDate,
                newCase.SVC_ResolvedDate__c
            );

        Long specialistMs = calculateSpecialistDurationMilliseconds(newCase);

        populateResolutionFields(metric, resolutionMs, overallMs, specialistMs);
        registerCaseMetricUpdate(unitOfWork, metric);
    }

    /*------------------------------------------------------------
    *   Purpose:  Calculates and writes resolution TAT when the
    *             Case is closed. Falls back to ClosedDate if
    *             SVC_ResolvedDate__c is null.
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyClosedCaseResolution(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        LOGGER.info(
            'Processing closed case resolution update for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );

        DateTime resolutionEndDate =
            newCase.SVC_ResolvedDate__c != null
                ? newCase.SVC_ResolvedDate__c
                : newCase.ClosedDate;

        Long resolutionMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.SVC_CaseClassificationDate__c,
                resolutionEndDate
            );

        Long overallMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.CreatedDate,
                newCase.ClosedDate
            );

        Long specialistMs = calculateSpecialistDurationMilliseconds(newCase);

        populateResolutionFields(metric, resolutionMs, overallMs, specialistMs);
        registerCaseMetricUpdate(unitOfWork, metric);
    }

    // ─── Insert-path methods (no existing metric) ──────────────

    /*------------------------------------------------------------
    *   Purpose:  Creates a new metric with allocation TAT only.
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyNewAllocation(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        Long allocationMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.CreatedDate,
                newCase.SVC_Case_Allocation_Date__c
            );

        metric.CMN_CaseAllocationTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(allocationMs);
        metric.CMN_CreationToAllocationMillisecond__c = allocationMs;

        registerCaseMetricInsert(unitOfWork, metric);

        LOGGER.info(
            'Inserting first TAT record for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a new metric with classification TAT
    *             when no allocation step occurred.
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyNewClassification(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        Long classificationMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.CreatedDate,
                newCase.SVC_CaseClassificationDate__c
            );

        metric.CMN_ClassificationTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(classificationMs);
        metric.CMN_ClassificationMillisecond__c = classificationMs;

        registerCaseMetricInsert(unitOfWork, metric);

        LOGGER.info(
            'Inserting classification TAT record for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a new metric with full resolution TAT
    *             when no prior metric existed. Backfills allocation
    *             and classification TAT if those dates are present
    *             on the Case (handles late metric creation due to
    *             prior failures or permission issues).
    *   Parameters: unitOfWork, newCase, metric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void applyNewResolution(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        Case newCase,
        CMN_CaseMilestoneMetric__c metric
    ) {
        DateTime resolutionEndDate =
            newCase.SVC_ResolvedDate__c != null
                ? newCase.SVC_ResolvedDate__c
                : newCase.ClosedDate;

        // ── Backfill allocation TAT if allocation date exists ──
        if (newCase.SVC_Case_Allocation_Date__c != null) {
            Long allocationMs =
                INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                    newCase.BusinessHoursId,
                    newCase.CreatedDate,
                    newCase.SVC_Case_Allocation_Date__c
                );

            metric.CMN_CaseAllocationTurnaroundTime__c =
                INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(allocationMs);
            metric.CMN_CreationToAllocationMillisecond__c = allocationMs;

            LOGGER.info(
                'Backfilling allocation TAT for Case {0}',
                LOG_AREA,
                new List<Object>{ newCase.Id }
            );
        }

        // ── Backfill classification TAT if classification date exists ──
        if (newCase.SVC_CaseClassificationDate__c != null) {
            DateTime classificationStartDate =
                newCase.SVC_Case_Allocation_Date__c != null
                    ? newCase.SVC_Case_Allocation_Date__c
                    : newCase.CreatedDate;

            Long classificationMs =
                INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                    newCase.BusinessHoursId,
                    classificationStartDate,
                    newCase.SVC_CaseClassificationDate__c
                );

            metric.CMN_ClassificationTurnaroundTime__c =
                INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(classificationMs);
            metric.CMN_ClassificationMillisecond__c = classificationMs;

            LOGGER.info(
                'Backfilling classification TAT for Case {0}',
                LOG_AREA,
                new List<Object>{ newCase.Id }
            );
        }

        // ── Resolution TAT ──
        Long resolutionMs =
            INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
                newCase.BusinessHoursId,
                newCase.CreatedDate,
                resolutionEndDate
            );

        Long specialistMs = calculateSpecialistDurationMilliseconds(newCase);

        populateResolutionFields(metric, resolutionMs, resolutionMs, specialistMs);
        registerCaseMetricInsert(unitOfWork, metric);

        LOGGER.info(
            'Inserting resolution TAT record for Case {0}',
            LOG_AREA,
            new List<Object>{ newCase.Id }
        );
    }

    // ─── Shared helpers ────────────────────────────────────────

    /*------------------------------------------------------------
    *   Purpose:  Populates all resolution-related fields on a
    *             metric record. Eliminates duplication across
    *             the three resolution branches.
    *   Parameters: metric        — the record to populate
    *               resolutionMs  — classification-to-resolution ms
    *               overallMs     — creation-to-close ms
    *               specialistMs  — allocation-to-resolution ms
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void populateResolutionFields(
        CMN_CaseMilestoneMetric__c metric,
        Long resolutionMs,
        Long overallMs,
        Long specialistMs
    ) {
        metric.CMN_ResolutionTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(resolutionMs);
        metric.CMN_ResolutionMillisecond__c = resolutionMs;

        metric.CMN_CaseOverallTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(overallMs);
        metric.CMN_CaseOverallDurationMillisecond__c = overallMs;

        metric.CMN_SpecialistDurationMillisecond__c = specialistMs;
        metric.CMN_SpecialistTurnaroundTime__c =
            INS_UTIL_BusinessHoursCalcHelper.printTATInBusinessHours(specialistMs);
    }

    /*------------------------------------------------------------
    *   Purpose:  Calculates specialist duration in milliseconds.
    *             Uses allocation date as start if available,
    *             otherwise falls back to CreatedDate.
    *   Parameters: caseData — the Case record
    *   Returns:    Long (milliseconds) or null
    *--------------------------------------------------------------*/
    private static Long calculateSpecialistDurationMilliseconds(Case caseData) {
        if (caseData == null) {
            return null;
        }

        DateTime specialistEndDate =
            caseData.SVC_ResolvedDate__c != null
                ? caseData.SVC_ResolvedDate__c
                : caseData.ClosedDate;

        if (specialistEndDate == null) {
            return null;
        }

        DateTime startDate =
            caseData.SVC_Case_Allocation_Date__c != null
                ? caseData.SVC_Case_Allocation_Date__c
                : caseData.CreatedDate;

        return INS_UTIL_BusinessHoursCalcHelper.calculateElapsedMilliSeconds(
            caseData.BusinessHoursId,
            startDate,
            specialistEndDate
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Registers a new metric record with the UoW.
    *   Parameters: unitOfWork, caseMetric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void registerCaseMetricInsert(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        CMN_CaseMilestoneMetric__c caseMetric
    ) {
        if (unitOfWork == null || caseMetric == null) {
            return;
        }

        LOGGER.info(
            'Registering new metric for Case {0}',
            LOG_AREA,
            new List<Object>{ caseMetric.CMN_Case__c }
        );

        unitOfWork.registerNew(caseMetric);
    }

    /*------------------------------------------------------------
    *   Purpose:  Registers an existing metric record as dirty
    *             with the UoW.
    *   Parameters: unitOfWork, caseMetric
    *   Returns:    void
    *--------------------------------------------------------------*/
    private static void registerCaseMetricUpdate(
        sbgplatform.fflib_SObjectUnitOfWork unitOfWork,
        CMN_CaseMilestoneMetric__c caseMetric
    ) {
        if (unitOfWork == null || caseMetric == null || caseMetric.Id == null) {
            return;
        }

        LOGGER.info(
            'Registering update for metric {0}',
            LOG_AREA,
            new List<Object>{ caseMetric.Id }
        );

        unitOfWork.registerDirty(caseMetric);
    }
}