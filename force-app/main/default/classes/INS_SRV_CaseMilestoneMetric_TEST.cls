/*--------------------------------*---------------------------
Author*        Given Khupai
Company:     * Salesforce
Description:   Test class for INS_SRV_CaseMilestoneMetric*.

               Verifies that SLA metric records are created and
  *            updated correctly for allocation, classification,
       *       resolution, and closed Case*fallback scenarios.

Test Class:    INS_SRV_CaseMilestoneMetrics_TEST

23-06-2026     Given Khupai     Initial version (SFP-55625)
16-07-2026     Given Khupai     Updated test data and assertions for
                                resolved date, classification update,
                                and ClosedDate fallback
16-07-2026     Given Khupai     Added closed Case snapshot helper to
                                avoid Case close automation SOQL limits
------------------------------------------------------------*/
@IsTest(SeeAllData=false)
private class INS_SRV_CaseMilestoneMetric_TEST {

    private static final String TAT_PERMISSION_SET_NAME = 'INS_Case_Business_Hour_TAT';

    /*------------------------------------------------------------
    *   Purpose:  Returns the org default Business Hours record.
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
    *   Purpose:  Assigns the Case TAT permission set to the running
    *             test user when the permission set exists.
    *
    *             This is required because the service exits early
    *             when INS_UTIL_BusinessHoursCalcHelper.hasAccessToCaseTaT()
    *             returns false.
    *--------------------------------------------------------------*/
    private static void assignTatPermissionSetToRunningUser() {
        List<PermissionSet> permissionSets = [
            SELECT Id, Name
            FROM PermissionSet
            WHERE Name = :TAT_PERMISSION_SET_NAME
            LIMIT 1
        ];

        if (permissionSets.isEmpty()) {
            return;
        }

        List<PermissionSetAssignment> existingAssignments = [
            SELECT Id
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
            AND PermissionSetId = :permissionSets[0].Id
            LIMIT 1
        ];

        if (!existingAssignments.isEmpty()) {
            return;
        }

        User runningUser = [
            SELECT Id
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        System.runAs(runningUser) {
            insert new PermissionSetAssignment(
                AssigneeId = runningUser.Id,
                PermissionSetId = permissionSets[0].Id
            );
        }
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a basic Account record used by test Cases.
    *--------------------------------------------------------------*/
    private static Account createTestAccount() {
        Account testAccount = new Account(
            Name = 'Test Account Case SLA Metrics'
        );

        insert testAccount;
        return testAccount;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates a base Case with Business Hours populated.
    *--------------------------------------------------------------*/
    private static Case createBaseCase(String subject) {
        Account testAccount = createTestAccount();
        BusinessHours defaultBusinessHours = getDefaultBusinessHours();

        Case testCase = new Case(
            Subject = subject,
            Status = 'New',
            Origin = 'Email',
            AccountId = testAccount.Id,
            BusinessHoursId = defaultBusinessHours.Id
        );

        insert testCase;

        Test.setCreatedDate(
            testCase.Id,
            System.now().addHours(-8)
        );

        return getCaseForService(testCase.Id);
    }

    /*------------------------------------------------------------
    *   Purpose:  Re-queries the Case with all fields required by
    *             INS_SRV_CaseMilestoneMetrics.
    *--------------------------------------------------------------*/
    private static Case getCaseForService(Id caseId) {
        List<Case> caseRecords = [
            SELECT Id,
                   Subject,
                   Status,
                   CreatedDate,
                   ClosedDate,
                   BusinessHoursId,
                   SVC_Case_Allocation_Date__c,
                   SVC_CaseClassificationDate__c,
                   SVC_ResolvedDate__c
            FROM Case
            WHERE Id = :caseId
            LIMIT 1
        ];

        Assert.isFalse(
            caseRecords.isEmpty(),
            'Expected test Case to exist before calling INS_SRV_CaseMilestoneMetrics'
        );

        return caseRecords[0];
    }

    /*------------------------------------------------------------
    *   Purpose:  Builds an in-memory Case snapshot with ClosedDate
    *             populated for testing fallback logic.
    *
    *             This avoids updating Case.Status to a closed value,
    *             which can trigger org automation and cause:
    *
    *             Too many SOQL queries: 101
    *
    *             The service uses the Case values passed into it,
    *             so the Case does not need to be physically closed
    *             in the database for this unit test.
    *--------------------------------------------------------------*/
    private static Case createClosedCaseSnapshotForService(
        Case sourceCase,
        DateTime allocationDate,
        DateTime classificationDate,
        DateTime closedDate
    ) {
        String caseJson = JSON.serialize(
            new Map<String, Object>{
                'attributes' => new Map<String, Object>{
                    'type' => 'Case'
                },
                'Id' => String.valueOf(sourceCase.Id),
                'Subject' => sourceCase.Subject,
                'Status' => 'Closed',
                'CreatedDate' => sourceCase.CreatedDate,
                'ClosedDate' => closedDate,
                'BusinessHoursId' => String.valueOf(sourceCase.BusinessHoursId),
                'SVC_Case_Allocation_Date__c' => allocationDate,
                'SVC_CaseClassificationDate__c' => classificationDate,
                'SVC_ResolvedDate__c' => null
            }
        );

        return (Case) JSON.deserialize(caseJson, Case.class);
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates an existing metric record with allocation
    *             TAT already populated.
    *
    *             Required for classification update branch:
    *
    *             m.CMN_CaseAllocationTurnaroundTime__c != null
    *             m.CMN_ClassificationTurnaroundTime__c == null
    *--------------------------------------------------------------*/
    private static CMN_CaseMilestoneMetric__c createMetricWithAllocationOnly(Id caseId) {
        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c(
            CMN_Case__c = caseId,
            CMN_CaseAllocationTurnaroundTime__c = '1 Business Hour',
            CMN_CreationToAllocationMillisecond__c = 3600000
        );

        insert metric;
        return metric;
    }

    /*------------------------------------------------------------
    *   Purpose:  Creates an existing metric record with classification
    *             TAT already populated.
    *
    *             Required for resolution update branches:
    *
    *             m.CMN_ClassificationTurnaroundTime__c != null
    *             m.CMN_ResolutionTurnaroundTime__c == null
    *--------------------------------------------------------------*/
    private static CMN_CaseMilestoneMetric__c createMetricWithClassification(Id caseId) {
        CMN_CaseMilestoneMetric__c metric = new CMN_CaseMilestoneMetric__c(
            CMN_Case__c = caseId,
            CMN_CaseAllocationTurnaroundTime__c = '1 Business Hour',
            CMN_CreationToAllocationMillisecond__c = 3600000,
            CMN_ClassificationTurnaroundTime__c = '2 Business Hours',
            CMN_ClassificationMillisecond__c = 7200000
        );

        insert metric;
        return metric;
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that a new allocation-only metric is created
    *             when the Case has an allocation date but no
    *             classification date.
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsCreatesAllocationMetricPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('Allocation Metric Test');

        testCase.SVC_Case_Allocation_Date__c = System.now().addHours(-6);
        update testCase;

        testCase = getCaseForService(testCase.Id);

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(testCase);

        Test.stopTest();

        List<CMN_CaseMilestoneMetric__c> insertedMetrics = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_CaseAllocationTurnaroundTime__c,
                   CMN_CreationToAllocationMillisecond__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.isFalse(
            insertedMetrics.isEmpty(),
            'Metric should be created for allocation-only Case'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_CaseAllocationTurnaroundTime__c,
            'Allocation TAT should be populated'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_CreationToAllocationMillisecond__c,
            'Allocation millisecond value should be populated'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that classification TAT is updated on an
    *             existing metric record.
    *
    *             Fix for:
    *             "Classification TAT should be updated on existing metric"
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsUpdatesClassificationOnExistingMetricPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('Classification Existing Metric Test');

        DateTime allocationDate = System.now().addHours(-6);
        DateTime classificationDate = System.now().addHours(-4);

        testCase.SVC_Case_Allocation_Date__c = allocationDate;
        testCase.SVC_CaseClassificationDate__c = classificationDate;
        update testCase;

        CMN_CaseMilestoneMetric__c existingMetric =
            createMetricWithAllocationOnly(testCase.Id);

        testCase = getCaseForService(testCase.Id);

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(testCase);

        Test.stopTest();

        CMN_CaseMilestoneMetric__c updatedMetric = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_CaseAllocationTurnaroundTime__c,
                   CMN_ClassificationTurnaroundTime__c,
                   CMN_ClassificationMillisecond__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE Id = :existingMetric.Id
            LIMIT 1
        ];

        Assert.areEqual(
            existingMetric.Id,
            updatedMetric.Id,
            'Existing metric should be updated and not replaced'
        );

        Assert.isNotNull(
            updatedMetric.CMN_ClassificationTurnaroundTime__c,
            'Classification TAT should be updated on existing metric'
        );

        Assert.isNotNull(
            updatedMetric.CMN_ClassificationMillisecond__c,
            'Classification millisecond value should be updated on existing metric'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that resolution TAT uses SVC_ResolvedDate__c
    *             when that field is available.
    *
    *             Fix for:
    *             "Resolution TAT should use SVC_ResolvedDate__c when available"
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsUsesResolvedDateForResolutionPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('Resolved Date Resolution Metric Test');

        DateTime allocationDate = System.now().addHours(-7);
        DateTime classificationDate = System.now().addHours(-5);
        DateTime resolvedDate = System.now().addHours(-2);

        testCase.SVC_Case_Allocation_Date__c = allocationDate;
        testCase.SVC_CaseClassificationDate__c = classificationDate;
        testCase.SVC_ResolvedDate__c = resolvedDate;
        update testCase;

        CMN_CaseMilestoneMetric__c existingMetric =
            createMetricWithClassification(testCase.Id);

        testCase = getCaseForService(testCase.Id);

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(testCase);

        Test.stopTest();

        CMN_CaseMilestoneMetric__c updatedMetric = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_ResolutionTurnaroundTime__c,
                   CMN_ResolutionMillisecond__c,
                   CMN_CaseOverallTurnaroundTime__c,
                   CMN_CaseOverallDurationMillisecond__c,
                   CMN_SpecialistTurnaroundTime__c,
                   CMN_SpecialistDurationMillisecond__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE Id = :existingMetric.Id
            LIMIT 1
        ];

        Assert.isNotNull(
            updatedMetric.CMN_ResolutionTurnaroundTime__c,
            'Resolution TAT should use SVC_ResolvedDate__c when available'
        );

        Assert.isNotNull(
            updatedMetric.CMN_ResolutionMillisecond__c,
            'Resolution millisecond value should be populated using SVC_ResolvedDate__c'
        );

        Assert.isNotNull(
            updatedMetric.CMN_CaseOverallTurnaroundTime__c,
            'Overall TAT should be populated using SVC_ResolvedDate__c'
        );

        Assert.isNotNull(
            updatedMetric.CMN_CaseOverallDurationMillisecond__c,
            'Overall millisecond value should be populated using SVC_ResolvedDate__c'
        );

        Assert.isNotNull(
            updatedMetric.CMN_SpecialistTurnaroundTime__c,
            'Specialist TAT should be populated using SVC_ResolvedDate__c'
        );

        Assert.isNotNull(
            updatedMetric.CMN_SpecialistDurationMillisecond__c,
            'Specialist millisecond value should be populated using SVC_ResolvedDate__c'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that resolution TAT falls back to ClosedDate
    *             when SVC_ResolvedDate__c is not available.
    *
    *             Fix for:
    *             "Resolution TAT should be populated using ClosedDate as fallback"
    *
    *             Governor-limit fix:
    *             Does not close the Case through DML because Case close
    *             automation can consume too many SOQL queries in the test.
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsUsesClosedDateFallbackForResolutionPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('Closed Date Fallback Resolution Metric Test');

        DateTime allocationDate = System.now().addHours(-7);
        DateTime classificationDate = System.now().addHours(-5);
        DateTime closedDate = System.now().addHours(-1);

        CMN_CaseMilestoneMetric__c existingMetric =
            createMetricWithClassification(testCase.Id);

        Case closedCaseSnapshot = createClosedCaseSnapshotForService(
            testCase,
            allocationDate,
            classificationDate,
            closedDate
        );

        Assert.isNotNull(
            closedCaseSnapshot.ClosedDate,
            'ClosedDate should be populated on the in-memory test Case snapshot'
        );

        Assert.isNull(
            closedCaseSnapshot.SVC_ResolvedDate__c,
            'SVC_ResolvedDate__c should be null so that ClosedDate fallback is tested'
        );

        Assert.isNotNull(
            closedCaseSnapshot.SVC_CaseClassificationDate__c,
            'Classification date must be populated for closed resolution branch'
        );

        CMN_CaseMilestoneMetric__c metricBeforeService = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_ClassificationTurnaroundTime__c,
                   CMN_ResolutionTurnaroundTime__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE Id = :existingMetric.Id
            LIMIT 1
        ];

        Assert.isNotNull(
            metricBeforeService.CMN_ClassificationTurnaroundTime__c,
            'Existing metric must already have Classification TAT before resolution fallback can run'
        );

        Assert.isNull(
            metricBeforeService.CMN_ResolutionTurnaroundTime__c,
            'Existing metric must not already have Resolution TAT before service runs'
        );

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(closedCaseSnapshot);

        Test.stopTest();

        CMN_CaseMilestoneMetric__c updatedMetric = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_ResolutionTurnaroundTime__c,
                   CMN_ResolutionMillisecond__c,
                   CMN_CaseOverallTurnaroundTime__c,
                   CMN_CaseOverallDurationMillisecond__c,
                   CMN_SpecialistTurnaroundTime__c,
                   CMN_SpecialistDurationMillisecond__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE Id = :existingMetric.Id
            LIMIT 1
        ];

        Assert.isNotNull(
            updatedMetric.CMN_ResolutionTurnaroundTime__c,
            'Resolution TAT should be populated using ClosedDate as fallback'
        );

        Assert.isNotNull(
            updatedMetric.CMN_ResolutionMillisecond__c,
            'Resolution millisecond value should be populated using ClosedDate as fallback'
        );

        Assert.isNotNull(
            updatedMetric.CMN_CaseOverallTurnaroundTime__c,
            'Overall TAT should be populated using ClosedDate as fallback'
        );

        Assert.isNotNull(
            updatedMetric.CMN_CaseOverallDurationMillisecond__c,
            'Overall millisecond value should be populated using ClosedDate as fallback'
        );

        Assert.isNotNull(
            updatedMetric.CMN_SpecialistTurnaroundTime__c,
            'Specialist TAT should be populated using ClosedDate as fallback'
        );

        Assert.isNotNull(
            updatedMetric.CMN_SpecialistDurationMillisecond__c,
            'Specialist millisecond value should be populated using ClosedDate as fallback'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that a new classification metric is created
    *             when no existing metric exists and the Case has a
    *             classification date.
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsCreatesClassificationMetricPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('New Classification Metric Test');

        testCase.SVC_CaseClassificationDate__c = System.now().addHours(-4);
        update testCase;

        testCase = getCaseForService(testCase.Id);

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(testCase);

        Test.stopTest();

        List<CMN_CaseMilestoneMetric__c> insertedMetrics = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_ClassificationTurnaroundTime__c,
                   CMN_ClassificationMillisecond__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.isFalse(
            insertedMetrics.isEmpty(),
            'Metric should be created for classification Case'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_ClassificationTurnaroundTime__c,
            'Classification TAT should be populated on new metric'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_ClassificationMillisecond__c,
            'Classification millisecond value should be populated on new metric'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that a new full resolution metric is created
    *             when no existing metric exists and the Case already
    *             has resolution information.
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsCreatesResolutionMetricWhenNoMetricExistsPositiveOutcome() {
        assignTatPermissionSetToRunningUser();

        Case testCase = createBaseCase('New Resolution Metric Test');

        testCase.SVC_Case_Allocation_Date__c = System.now().addHours(-7);
        testCase.SVC_CaseClassificationDate__c = System.now().addHours(-5);
        testCase.SVC_ResolvedDate__c = System.now().addHours(-2);
        update testCase;

        testCase = getCaseForService(testCase.Id);

        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(testCase);

        Test.stopTest();

        List<CMN_CaseMilestoneMetric__c> insertedMetrics = [
            SELECT Id,
                   CMN_Case__c,
                   CMN_CaseAllocationTurnaroundTime__c,
                   CMN_ClassificationTurnaroundTime__c,
                   CMN_ResolutionTurnaroundTime__c,
                   CMN_CaseOverallTurnaroundTime__c,
                   CMN_SpecialistTurnaroundTime__c
            FROM CMN_CaseMilestoneMetric__c
            WHERE CMN_Case__c = :testCase.Id
            LIMIT 1
        ];

        Assert.isFalse(
            insertedMetrics.isEmpty(),
            'Metric should be created when resolved Case has no existing metric'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_ResolutionTurnaroundTime__c,
            'Resolution TAT should be populated on new metric'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_CaseOverallTurnaroundTime__c,
            'Overall TAT should be populated on new metric'
        );

        Assert.isNotNull(
            insertedMetrics[0].CMN_SpecialistTurnaroundTime__c,
            'Specialist TAT should be populated on new metric'
        );
    }

    /*------------------------------------------------------------
    *   Purpose:  Verifies that the service safely exits when the
    *             input Case is null.
    *--------------------------------------------------------------*/
    @IsTest
    static void updateCaseSlaDetailsNullInputDoesNotThrowExceptionPositiveOutcome() {
        Test.startTest();

        INS_SRV_CaseMilestoneMetrics.updateCaseSlaDetails(null);

        Test.stopTest();

        Assert.isTrue(
            true,
            'Method should safely return when Case input is null'
        );
    }
}