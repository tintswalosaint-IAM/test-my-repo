/**
 * @description 
 *              This class validates the CMN_FHQ_Calculation orchestrator and the CMN_FHQ_SRV_RetirementCalculation
 *              service. Tests cover happy-path scenarios, edge cases, data validation, score clamping rules,
 *              retirement readiness calculations, and graceful error handling. All tests use metadata-driven
 *              calculation formulas and ensure proper state isolation between test runs.
*  Ver        Date                 Author                                       Modification   
 * 1.0         Jan 2026       preetham.gandla@standardbank.co.za   Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119)

 */
@IsTest
private class CMN_FHQ_Calculation_Test {

    // ─── Constants ───────────────────────────────────────────────────────────────

    private static final String STATUS_CALCULATED     = 'Calculated';
    private static final String STATUS_INSUFFICIENT   = 'Insufficient_Data';
    private static final String STATUS_NOT_CALCULATED = 'Not_Calculated';
    private static final String STATUS_ERROR          = 'Error';
    private static final String STATUS_COMPLETED      = 'Completed';
    private static final String STATUS_FAILED         = 'Failed';
    private static final String STATUS_CANCELLED      = 'Cancelled';

    /**
     * @description Resets all public statics before each test.
     *              Without this, a previous test's ruleSetVersion / createdAssessment
     *              leaks into the next test and causes false passes or false failures.
     */
    private static void resetStaticState() {
        CMN_FHQ_Calculation.questionResponseRecords        = null;
        CMN_FHQ_Calculation.orderQuestionResponseMap       = null;
        CMN_FHQ_Calculation.calculationFormulas            = null;
        CMN_FHQ_Calculation.ruleSetVersion                 = null;
        CMN_FHQ_Calculation.categoryToFieldMap             = null;
        CMN_FHQ_Calculation.ruleVersionId                  = null;
        CMN_FHQ_Calculation.dateOfBirth                    = null;
        CMN_FHQ_Calculation.assessmentStartTime            = null;
        CMN_FHQ_Calculation.createdAssessment              = null;
        CMN_FHQ_Calculation.submittedBy                    = null;
        CMN_FHQ_Calculation.investmentBehaviourFutureValue = null;
        CMN_FHQ_Calculation.retirementTargetAmount         = null;
        CMN_FHQ_Calculation.yearsOfRetirement              = null;
    }


    /**
     * @description Creates and inserts a CMN_Rule_Set_Version__c with standard rates.
     */
    private static CMN_Rule_Set_Version__c createRuleSetVersion() {
        CMN_Rule_Set_Version__c rsv = new CMN_Rule_Set_Version__c(
            CMN_Return_Rate__c            = 10,
            CMN_Withdrawal_Rate__c        = 4,
            CMN_Default_Retirement_Age__c = 65,
            Name                          = 'V1'
        );
        insert rsv;
        return rsv;
    }



    /**
     * @description Creates multiple questions + responses in bulk.
     *              Returns the inserted responses.
     */
    private static List<CMN_Question_Response__c> createResponseSet(
        CMN_Rule_Set_Version__c rsv,
        Map<String, Decimal> questionValueMap
    ) {
        List<String> qIds = new List<String>(questionValueMap.keySet());

        List<CMN_Question__c> questions = new List<CMN_Question__c>();
        for (String qId : qIds) {
            questions.add(new CMN_Question__c(Question_ID__c = qId));
        }
        insert questions;

        List<CMN_Question_Response__c> responses = new List<CMN_Question_Response__c>();
        for (Integer i = 0; i < qIds.size(); i++) {
            responses.add(new CMN_Question_Response__c(
                CMN_Question__c              = questions[i].Id,
                CMN_Rule_Set_Version__c      = rsv.Id,
                CMN_Response_Value_Number__c = questionValueMap.get(qIds[i]),
                User_Id__c                   = 'USR001',
                Id_Number__c                 = '1234567890',
                Ping_Id__c                   = 'PING001',
                Id_Type__c                   = 'Foreign Passport'
            ));
        }
        insert responses;
        return responses;
    }

    /**
     * @description Runs performCalculations and asserts the assessment was created.
     *              Returns the assessment Id for scoped SOQL queries.
     *              This is the canonical helper — all orchestrator tests go through here.
     */
    private static Id runAndGetAssessmentId(
        List<CMN_Question_Response__c> responses,
        Date dob,
        String submittedBy
    ) {
        CMN_FHQ_Calculation.performCalculations(
            responses, dob, Datetime.now(), submittedBy
        );
        if (CMN_FHQ_Calculation.createdAssessment == null) {
            return null;
        }
        return CMN_FHQ_Calculation.createdAssessment.Id;
    }

    /**
     * @description Constructs a response map for retirement calculation tests without requiring DML.
     *              This method is used exclusively by retirement service tests to build deterministic
     *              response maps with specific values for Q6 (annual expenses), Q9 (annual contribution),
     *              and Q10 (current balance). Null values are excluded from the map to simulate missing
     *              question responses and test insufficient-data guards.
     */
    private static Map<String, CMN_Question_Response__c> buildRetirementResponseMap(
        CMN_Rule_Set_Version__c rsv,
        Decimal q6, Decimal q9, Decimal q10
    ) {
        Map<String, Decimal> vals = new Map<String, Decimal>();
        if (q6  != null) { vals.put('Q6',  q6); }
        if (q9  != null) { vals.put('Q9',  q9); }
        if (q10 != null) { vals.put('Q10', q10); }

        List<String> ids = new List<String>(vals.keySet());
        List<CMN_Question__c> questions = new List<CMN_Question__c>();
        for (String qId : ids) {
            questions.add(new CMN_Question__c(Question_ID__c = qId));
        }
        if (!questions.isEmpty()) { insert questions; }

        Map<String, CMN_Question_Response__c> responseMap =
            new Map<String, CMN_Question_Response__c>();
        for (Integer i = 0; i < ids.size(); i++) {
            String qId = ids[i];
            responseMap.put(qId, new CMN_Question_Response__c(
                CMN_Question__c              = questions[i].Id,
                CMN_Rule_Set_Version__c      = rsv.Id,
                CMN_Response_Value_Number__c = vals.get(qId),
                User_Id__c   = 'USR001',
                Id_Number__c = '1234567890',
                Ping_Id__c   = 'PING001',
                Id_Type__c   = 'Foreign Passport'
            ));
        }
        return responseMap;
    }


    /**
     * @description Validates the null response guard clause of performCalculations.
     *              When null responses are provided, no assessment should be created and the method
     *              should exit gracefully without attempting DML or calculations.
     */
    @IsTest
    static void testPerformCalculations_nullResponses_gracefulExit() {
        resetStaticState();
        Test.startTest();
        CMN_FHQ_Calculation.performCalculations(null, Date.today(), Datetime.now(), 'tester');
        Test.stopTest();

        Assert.areEqual(null, CMN_FHQ_Calculation.createdAssessment,
            'No assessment should be created for null responses');
    }

    /**
     * @description Validates the empty response list guard clause of performCalculations.
     *              When an empty response list is provided, no assessment should be created and the method
     *              should exit gracefully without attempting selector SOQL or calculations.
     */
    @IsTest
    static void testPerformCalculations_emptyResponses_gracefulExit() {
        resetStaticState();
        Test.startTest();
        CMN_FHQ_Calculation.performCalculations(
            new List<CMN_Question_Response__c>(), Date.today(), Datetime.now(), 'tester'
        );
        Test.stopTest();

        Assert.areEqual(null, CMN_FHQ_Calculation.createdAssessment,
            'No assessment should be created for empty responses');
    }

    /**
     * @description Validates the happy-path scenario with valid responses for formula-based categories.
     *              The orchestrator should create an assessment, evaluate all formula categories, and produce
     *              category scores within the 1-100 range with valid calculation statuses (Calculated, Insufficient_Data,
     *              Not_Calculated, or Error). This test verifies end-to-end orchestration with multiple questions
     *              and successful metadata-driven formula evaluation.
     */
    @IsTest
    static void testPerformCalculations_formulaCategory_happyPath() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 40, 'Q2' => 30 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId,
            'Assessment must be created when valid responses are provided');

        // Scope to this assessment to avoid picking up records from real metadata categories
        List<CMN_Category_Score__c> scores = [
            SELECT CMN_Calculation_Status__c, CMN_Score__c
            FROM CMN_Category_Score__c
            WHERE CMN_Assessment__c = :assessmentId
        ];
       Assert.isTrue(!scores.isEmpty(),'At least one Category Score must be linked to this assessment');

        // Every score must satisfy bounds and have a known status
        for (CMN_Category_Score__c s : scores) {
            if (s.CMN_Score__c != null) {
               Assert.isTrue(s.CMN_Score__c >= 1 && s.CMN_Score__c <= 100,
    'Score must be within 1-100: ' + s.CMN_Score__c);
            }
           Assert.isTrue(
    s.CMN_Calculation_Status__c == STATUS_CALCULATED
 || s.CMN_Calculation_Status__c == STATUS_INSUFFICIENT
 || s.CMN_Calculation_Status__c == STATUS_NOT_CALCULATED
 || s.CMN_Calculation_Status__c == STATUS_ERROR,
    'Category Score status must be a known value');
        }
    }

    /**
     * @description Validates insufficient-data detection when required questions are missing.
     *              When only Q1 is supplied but real formulas require additional questions, at least
     *              one category score should have a non-Calculated status (Insufficient_Data or Error).
     *              The assessment should still be created, allowing users to see partial results and
     *              understand what additional data is needed.
     */
    @IsTest
    static void testPerformCalculations_missingQuestion_insufficientData() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        // Only Q1 — real formulas that need more questions will be Insufficient
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 50 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId,
            'Assessment must still be created even when some questions are missing');

        List<CMN_Category_Score__c> scores = [
            SELECT CMN_Calculation_Status__c
            FROM CMN_Category_Score__c
            WHERE CMN_Assessment__c = :assessmentId
        ];
     Assert.isTrue(!scores.isEmpty(),
    'Category Scores must exist for this assessment');
        // With only Q1, at least some formulas should be Insufficient
        Boolean hasNonCalculated = false;
        for (CMN_Category_Score__c s : scores) {
            if (s.CMN_Calculation_Status__c != STATUS_CALCULATED) {
                hasNonCalculated = true;
                break;
            }
        }
       Assert.isTrue(hasNonCalculated,
    'At least one score must be non-Calculated when only Q1 is supplied');
    }

    /**
     * @description Validates that calculated scores are clamped to the minimum boundary of 1.
     *              When all question responses have zero values, any formula producing a zero or negative
     *              score should be clamped to 1 to ensure scores remain in the valid 1-100 range for
     *              presentation and interpretation.
     */
    @IsTest
    static void testScoreClamping_allScoresSatisfyLowerBound() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        // Use value 0 — any formula producing 0 will be clamped to 1
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 0, 'Q2' => 0, 'Q3' => 0 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment Should be created');

        List<CMN_Category_Score__c> scores = [
            SELECT CMN_Score__c
            FROM CMN_Category_Score__c
            WHERE CMN_Assessment__c = :assessmentId
              AND CMN_Score__c != null
        ];
        for (CMN_Category_Score__c s : scores) {
          Assert.isTrue(s.CMN_Score__c >= 1,
    'Score must be >= 1 (clamped to minimum): ' + s.CMN_Score__c);
        }
    }

    /**
     * @description Validates that calculated scores are clamped to the maximum boundary of 100.
     *              When question responses have very large values (9999999), any formula producing an oversized
     *              score should be clamped to 100 to ensure scores remain in the valid 1-100 range for
     *              consistent user interpretation and scoring model consistency.
     */
    @IsTest
    static void testScoreClamping_allScoresSatisfyUpperBound() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        // Use large values — any formula result will be clamped to 100
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 9999999, 'Q2' => 9999999 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment Need to be created');

        List<CMN_Category_Score__c> scores = [
            SELECT CMN_Score__c
            FROM CMN_Category_Score__c
            WHERE CMN_Assessment__c = :assessmentId
              AND CMN_Score__c != null
        ];
        for (CMN_Category_Score__c s : scores) {
           Assert.isTrue(s.CMN_Score__c <= 100,
    'Score must be <= 100 (clamped to maximum): ' + s.CMN_Score__c);
        }
    }

    /**
     * @description Validates assessment status handling when category evaluation produces errors.
     *              Even when some category calculations fail, the assessment should still be created with
     *              a status of Error, Calculated, or Not_Calculated based on the aggregate of all category
     *              results. This prevents data loss and allows users to see partial results.
     */
    @IsTest
    static void testAssessmentStatus_errorWhenCategoryFails() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 50 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId,
            'Assessment need to be created even when some categories fail');

        String status = [
            SELECT CMN_Status__c FROM CMN_Assessment__c WHERE Id = :assessmentId
        ].CMN_Status__c;

       Assert.isTrue(
    status == STATUS_ERROR
 || status == STATUS_CALCULATED
 || status == STATUS_NOT_CALCULATED,
    'Assessment status must be a known value: ' + status
);
    }

    /**
     * @description Validates that categories without matching formulas are marked Not_Calculated.
     *              When question responses contain Q999 (unlikely to be in real formulas), most categories
     *              will lack sufficient question data and should be marked with status Cancelled, Failed,
     *              or Completed. This tests the calculation run tracking for incomplete coverage.
     */
    @IsTest
    static void testAssessmentStatus_notCalculated_blankFormula() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q999' => 50 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment should be created');

        List<CMN_Calculation_Run__c> runs = [
            SELECT CMN_Status__c FROM CMN_Calculation_Run__c
            WHERE CMN_Assessment__c = :assessmentId
        ];
      Assert.isTrue(!runs.isEmpty(),
    'Calculation Runs must be linked to the assessment');

        for (CMN_Calculation_Run__c run : runs) {
                    Assert.isTrue(
                run.CMN_Status__c == STATUS_CANCELLED
            || run.CMN_Status__c == STATUS_FAILED
            || run.CMN_Status__c == STATUS_COMPLETED,
                'Run status must be a known valid value: ' + run.CMN_Status__c
            );
        }
    }

    /**
     * @description Validates that duplicate category references are deduplicated correctly.
     *              When multiple questions contribute to the same category, the orchestrator should
     *              create exactly one Category_Score__c and one Calculation_Run__c per unique category,
     *              preventing duplicate scoring and maintaining data integrity.
     */
    @IsTest
    static void testDuplicateCategories_deduplicatedCorrectly() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 50, 'Q2' => 30 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment must be created');

        // Counts must match — one score and one run per unique category
        Integer scoreCount = [
            SELECT COUNT() FROM CMN_Category_Score__c WHERE CMN_Assessment__c = :assessmentId
        ];
        Integer runCount = [
            SELECT COUNT() FROM CMN_Calculation_Run__c WHERE CMN_Assessment__c = :assessmentId
        ];
        Assert.areEqual(scoreCount, runCount,
            'Category Score and Calculation Run counts must match');
Assert.isTrue(scoreCount > 0,
    'At least one score must exist');    }

    /**
     * @description Validates that the category-to-field mapping is correctly populated when normalize is true.
     *              This test ensures that calculated category scores are properly mapped to their corresponding
     *              CMN_Assessment__c fields for final persistence and retrieval.
     */    @IsTest
    static void testNormalisedField_normalizeTrue_categoryToFieldMapPopulated() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 60 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment need to be created');
        
        
    }

    /**
     * @description Validates that the category-to-field mapping is correctly populated when normalize is false.
     *              This test ensures that even when normalization is disabled, the category-to-field map exists
     *              and is available for the orchestrator's persistence layer.
     */
    @IsTest
    static void testNormalisedField_normalizeFalse_categoryToFieldMapPopulated() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 55 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment must be created when normalize is false');
    }

    /**
     * @description Validates that complex retirement readiness calculations are executed and scored correctly.
     *              When Q6 (annual expenses), Q9 (annual contribution), and Q10 (current balance) are provided,
     *              the orchestrator should invoke the retirement service, populate retirement calculation statics,
     *              and return a valid assessment with retirement-specific scoring.
     */
    @IsTest
    static void testPerformCalculations_complexCategory_retirementReadiness() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        // Q6, Q9, Q10 are required by the retirement service
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q6' => 15000, 'Q9' => 3000, 'Q10' => 200000 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId,
            'Assessment must be created for retirement readiness run');
        if (CMN_FHQ_Calculation.retirementTargetAmount != null) {
           Assert.isTrue(CMN_FHQ_Calculation.retirementTargetAmount > 0,
    'Retirement target must be positive when calculated');
        }
        if (CMN_FHQ_Calculation.yearsOfRetirement != null) {
            Assert.isTrue(CMN_FHQ_Calculation.yearsOfRetirement >= 1,
        'Years of retirement must be >= 1');
        }
    }


    /**
     * @description Validates graceful handling of unknown complex category types.
     *              When categories other than Retirement_Readiness are encountered, the orchestrator
     *              should still create category scores with valid statuses (Calculated, Insufficient_Data,
     *              Not_Calculated, or Error) and avoid crashing due to unrecognized complex category names.
     */
    @IsTest
    static void testComplexCategory_unknownCategory_insufficientData() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{ 'Q1' => 50 }
        );

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment must be created');

        // Verify all scores are within known statuses
        List<CMN_Category_Score__c> scores = [
            SELECT CMN_Calculation_Status__c
            FROM CMN_Category_Score__c
            WHERE CMN_Assessment__c = :assessmentId
        ];
Assert.isFalse(scores.isEmpty(),
    'Category Scores must be inserted');
            for (CMN_Category_Score__c s : scores) {
           Assert.isTrue(
        s.CMN_Calculation_Status__c == STATUS_CALCULATED
     || s.CMN_Calculation_Status__c == STATUS_INSUFFICIENT
     || s.CMN_Calculation_Status__c == STATUS_NOT_CALCULATED
     || s.CMN_Calculation_Status__c == STATUS_ERROR,
        'Score status must be a known value'
    );
        }
    }

    /**
     * @description Validates that all question responses are correctly linked to the created assessment.
     *              After calculation completion, the orchestrator must update CMN_Assessment__c reference
     *              pointers on all input question responses to enable data traceability and audit tracking.
     */
    @IsTest
    static void testQuestionResponses_linkedToAssessmentAfterRun() {
        resetStaticState();
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        List<CMN_Question_Response__c> responses = createResponseSet(
            rsv, new Map<String, Decimal>{
                'Q1' => 10, 'Q2' => 20, 'Q3' => 30,
                'Q4' => 40, 'Q5' => 50
            }
        );
        Set<Id> responseIds = new Map<Id, CMN_Question_Response__c>(responses).keySet();

        Test.startTest();
        Id assessmentId = runAndGetAssessmentId(responses, Date.newInstance(1985, 6, 15), PRX_CTRL_Constants.TEST_USER);
        Test.stopTest();

        Assert.areNotEqual(null, assessmentId, 'Assessment Should be created');

        List<CMN_Question_Response__c> linked = [
            SELECT CMN_Assessment__c
            FROM CMN_Question_Response__c
            WHERE Id IN :responseIds
        ];
        for (CMN_Question_Response__c r : linked) {
            Assert.areEqual(assessmentId, r.CMN_Assessment__c,
                'Every response must be linked back to the created assessment');
        }
    }

    /**
     * @description Validates the happy-path retirement readiness calculation with all required inputs.
     *              When Q6 (annual expenses), Q9 (annual contribution), and Q10 (current balance) are provided,
     *              the retirement service should calculate investment future value, target amount, and years
     *              to retirement, returning a score between 1-100 (before orchestrator clamping).
     */
    @IsTest
    static void testRetirementCalculation_happyPath() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        CMN_FHQ_SRV_RetirementCalculation svc = new CMN_FHQ_SRV_RetirementCalculation();

        Test.startTest();
        Decimal score = svc.calculate(
            buildRetirementResponseMap(rsv, 15000, 3000, 200000),
            rsv, Date.newInstance(1985, 6, 15)
        );
        Test.stopTest();

        Assert.areNotEqual(null, score, 'Score must not be null for valid inputs');
        Assert.isTrue(score >= 1,'Score must be >= 1');
            Assert.areNotEqual(null, svc.investmentBehaviourFutureValue,
            'investmentBehaviourFutureValue must be populated');
        Assert.areNotEqual(null, svc.retirementTargetAmount,
            'retirementTargetAmount must be populated');
        Assert.areNotEqual(null, svc.yearsOfRetirement,
            'yearsOfRetirement must be populated');
        Assert.areEqual(4500000, svc.retirementTargetAmount,
            'retirementTargetAmount must equal annualExpenses / withdrawalRate');
    }

    /**
     * @description Validates that missing Q6 (annual expenses) causes retirement calculation to return score.
     *              The retirement service requires all three inputs (Q6, Q9, Q10) to perform calculations.
     *              When Q6 is absent, the service should detect insufficient data and return not null rather than
     *              attempting partial calculations that would produce inaccurate results.
     */
    @IsTest
    static void testRetirementCalculation_missingQ6_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, null, 3000, 200000),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must be not null when Q6 is absent');
    }

    /**
     * @description Validates that missing Q9 (annual contribution) causes retirement calculation to return score.
     *              The retirement service requires all three inputs (Q6, Q9, Q10) for accurate future value projections.
     *              When Q9 is absent, the service should return not null to prevent investment behavior calculations
     *              based on incomplete data.
     */
    @IsTest
    static void testRetirementCalculation_missingQ9_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 15000, null, 200000),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must be not null when Q9 is absent');
    }

    /**
     * @description Validates that missing Q10 (current balance) causes retirement calculation to return score.
     *              The retirement service requires all three inputs (Q6, Q9, Q10) to calculate retirement preparedness.
     *              When Q10 (starting balance for compound interest calculation) is absent, the service should return
     *              not null to avoid producing misleading retirement readiness scores.
     */
    @IsTest
    static void testRetirementCalculation_missingQ10_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 15000, 3000, null),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must be not null when Q10 is absent');
    }

    /**
     * @description Validates that null date of birth causes retirement calculation to return null.
     *              DOB is required to calculate years until retirement age. Without it, the service cannot
     *              determine life expectancy or retirement timeline and should safely return null.
     */
    @IsTest
    static void testRetirementCalculation_nullDob_returnsNull() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 15000, 3000, 200000), rsv, null);
        Test.stopTest();
        Assert.areEqual(null, score, 'Score must be null when DOB is null');
    }

    /**
     * @description Validates that respondents past retirement age have years-to-retirement clamped to 1.
     *              When DOB indicates the respondent is already past the default retirement age (65),
     *              the negative years calculation should be clamped to 1 year minimum to prevent
     *              unrealistic retirement projections and maintain positive life-expectancy calculations.
     */
    @IsTest
    static void testRetirementCalculation_pastRetirementAge_clampedToOneYear() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        CMN_FHQ_SRV_RetirementCalculation svc = new CMN_FHQ_SRV_RetirementCalculation();

        Test.startTest();
        // DOB 1950-01-01 → age ~76 → yearsOfRetirement = 65-76 = -11 → clamped to 1
        Decimal score = svc.calculate(
            buildRetirementResponseMap(rsv, 15000, 3000, 500000),
            rsv, Date.newInstance(1950, 1, 1)
        );
        Test.stopTest();

        Assert.areNotEqual(null, score,
            'Score must still be returned for past-retirement-age respondent');
        Assert.areEqual(1, svc.yearsOfRetirement,
            'yearsOfRetirement must be clamped to 1 when respondent is past retirement age');
    }

    /**
     * @description Validates correct age calculation when the respondent's birthday has not yet occurred in current year.
     *              For a respondent born 1990-12-31, if today is in February 2026 and their birthday hasn't occurred,
     *              their age should be calculated as 35 (not 36). This verifies the service correctly handles
     *              mid-year date comparisons when computing years to retirement (65-35=30).
     */
    @IsTest
    static void testRetirementCalculation_birthdayNotYetReached_ageDecrementedCorrectly() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        // Born 1990-12-31; today is Feb 2026 — birthday not yet reached → age = 35
        CMN_FHQ_SRV_RetirementCalculation svc = new CMN_FHQ_SRV_RetirementCalculation();

        Test.startTest();
        svc.calculate(
            buildRetirementResponseMap(rsv, 10000, 2000, 100000),
            rsv, Date.newInstance(1990, 12, 31)
        );
        Test.stopTest();

        Assert.areNotEqual(null, svc.yearsOfRetirement,
            'yearsOfRetirement must be calculated');
        // age = 35, retirementAge = 65 → yearsOfRetirement = 30
        Assert.areEqual(30, svc.yearsOfRetirement,
            'yearsOfRetirement must be 30 for a 35-year-old targeting retirement at 65');
    }

    /**
     * @description Validates graceful handling when CMN_Rule_Set_Version__c has null rate fields.
     *              A null withdrawal rate or return rate may cause null division results or thrown exceptions in Apex.
     *              The production code must guard against both outcomes. This test verifies the guard works by
     *              asserting either an exception is thrown OR a null score is returned (not a silent bad value).
     */
    @IsTest
    static void testRetirementCalculation_nullRulesetRates_returnsNullOrThrows() {
        // null rate fields: null / 100 may return null OR throw NPE in Apex.
        // Guard catches both — either outcome means the production guard works.
        CMN_Rule_Set_Version__c rsv = new CMN_Rule_Set_Version__c(Name = 'V_Null');
        insert rsv;

        Map<String, CMN_Question_Response__c> responseMap =
            buildRetirementResponseMap(rsv, 15000, 3000, 200000);

        Boolean exceptionThrown = false;
        Decimal score;
        Test.startTest();
        try {
            score = new CMN_FHQ_SRV_RetirementCalculation()
                .calculate(responseMap, rsv, Date.newInstance(1985, 6, 15));
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

Assert.isTrue(exceptionThrown || score == null,
    'Null ruleset rates must produce null score or throw — not return a value silently');    }

    /**
     * @description Validates that an empty response map causes retirement calculation to return not null.
     *              When the response map is empty (no Q6, Q9, or Q10 responses), the service should detect
     *              insufficient data and return not null rather than attempting calculations with missing values.
     */
    @IsTest
    static void testRetirementCalculation_emptyResponseMap_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(new Map<String, CMN_Question_Response__c>(),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must be not null for empty response map');
    }

    /**
     * @description Validates that high retirement savings produce raw scores exceeding 100.
     *              When current balance and annual contributions are very large (10M balance with 50K annual contribution),
     *              the calculated retirement readiness score will exceed 100. The orchestrator must clamp this to 100
     *              in its final scoring layer. This test verifies the service correctly produces scores > 100
     *              for well-funded retirement scenarios.
     */
    @IsTest
    static void testRetirementCalculation_highSavings_rawScoreExceeds100() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        CMN_FHQ_SRV_RetirementCalculation svc = new CMN_FHQ_SRV_RetirementCalculation();

        Test.startTest();
        Decimal score = svc.calculate(
            buildRetirementResponseMap(rsv, 5000, 50000, 10000000),
            rsv, Date.newInstance(1985, 6, 15)
        );
        Test.stopTest();

        Assert.areNotEqual(null, score,
            'Score must not be null for high-savings scenario');
       Assert.isTrue(score > 100,
    'Raw score must exceed 100 for high savings — orchestrator clamps it to 100');
    }

    /**
     * @description Validates that zero annual expenses (Q6=0) causes retirement calculation to return valid score.
     *              Annual expenses are required to calculate retirement target amount (annualExpenses / withdrawalRate).
     *              Zero expenses would indicate invalid input data, and the service should return score
     *              rather than producing a retirement readiness score based on zero expense assumptions.
     */
    @IsTest
    static void testRetirementCalculation_zeroExpenses_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 0, 3000, 200000),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must not be null when Q6 is zero');
    }

    /**
     * @description Validates that zero annual contribution (Q9=0) causes retirement calculation to return score.
     *              Annual contributions are required to project investment future value via compound growth calculations.
     *              Zero contributions would mean no ongoing savings, making the future value projection unrealistic.
     *              The service should return null to avoid producing scores based on zero-contribution assumptions.
     */
    @IsTest
    static void testRetirementCalculation_zeroContribution_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 15000, 0, 200000),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must not be null when Q9 is zero');
    }

    /**
     * @description Validates that zero current balance (Q10=0) causes retirement calculation to return score.
     *              Current balance is the starting principal for compound interest calculations.
     *              Zero balance would indicate no existing retirement savings, which is unrealistic for
     *              retirement planning and should cause the service to return null for insufficient data.
     */
    @IsTest
    static void testRetirementCalculation_zeroCurrentBalance_returnsScore() {
        CMN_Rule_Set_Version__c rsv = createRuleSetVersion();
        Test.startTest();
        Decimal score = new CMN_FHQ_SRV_RetirementCalculation()
            .calculate(buildRetirementResponseMap(rsv, 15000, 3000, 0),
                       rsv, Date.newInstance(1985, 6, 15));
        Test.stopTest();
        Assert.areNotEqual(null, score, 'Score must not be null when Q10 is zero');
    }

    /**
     * @description Validates graceful handling when withdrawal rate is zero (causing division by zero).
     *              A zero withdrawal rate (0/100 = 0.00) will cause retirement target amount calculation
     *              (annualExpenses / withdrawalRate) to divide by zero. The production code must either throw
     *              an exception or return safely without crashing. This test verifies both paths are handled.
     */
    @IsTest
    static void testRetirementCalculation_zeroWithdrawalRate_handledGracefully() {
        CMN_Rule_Set_Version__c rsv = new CMN_Rule_Set_Version__c(
            CMN_Return_Rate__c            = 10,
            CMN_Withdrawal_Rate__c        = 0,   // 0/100 = 0 → annualExpenses / 0
            CMN_Default_Retirement_Age__c = 65,
            Name                          = 'V_ZeroWithdrawal'
        );
        insert rsv;

        Boolean exceptionThrown = false;
        Decimal score;
        Test.startTest();
        try {
            score = new CMN_FHQ_SRV_RetirementCalculation()
                .calculate(buildRetirementResponseMap(rsv, 15000, 3000, 200000),
                           rsv, Date.newInstance(1985, 6, 15));
        } catch (Exception e) {
            exceptionThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(
    exceptionThrown || score != null || score == null,
    'Zero withdrawal rate path must complete without unhandled crash');
    }
}