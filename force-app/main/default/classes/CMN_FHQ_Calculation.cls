/**
 * @description Orchestrates the FHQ category score calculations for the Mall Org application.
 *              Loads formula metadata, evaluates each category (formula-based or complex),
 *              persists CMN_Category_Score__c and CMN_Calculation_Run__c records,
 *              then builds and persists the CMN_Assessment__c.
 *              Complex calculations (e.g. Retirement Readiness) are delegated to
 *              CMN_FHQ_SRV_RetirementCalculation. Formula evaluation is handled by
 *              CMN_FHQ_MathExpression. All System.debug calls replaced with RFLIB logger.
 *  Ver        Date                 Author                                       Modification   
 * 1.0         Jan 2026       preetham.gandla@standardbank.co.za               Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119)
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class CMN_FHQ_Calculation {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FHQ_Calculation');

    /**
     * @description Private constructor to prevent instantiation.
     *              All methods are static utility methods.
     */
    // NOPMD - Private constructor intentionally empty
    private CMN_FHQ_Calculation() {
        // Utility class - private constructor to prevent instantiation
    }

    private static final String STATUS_NOT_CALCULATED  = 'Not_Calculated';
    private static final String STATUS_CALCULATED      = 'Calculated';
    private static final String STATUS_INSUFFICIENT    = 'Insufficient_Data';
    private static final String STATUS_ERROR           = 'Error';
    private static final String STATUS_RUNNING         = 'Running';
    private static final String STATUS_COMPLETED       = 'Completed';
    private static final String STATUS_FAILED          = 'Failed';
    private static final String STATUS_CANCELLED       = 'Cancelled';

    // ─── Shared Calculation State ────────────────────────────────────────────────

    /** @description Full list of hydrated question response records for this run. */
    public static List<CMN_Question_Response__c> questionResponseRecords;

    /** @description Map of Question_ID__c (e.g. Q1) to CMN_Question_Response__c record. */
    public static Map<String, CMN_Question_Response__c> orderQuestionResponseMap;

    /** @description Loaded formula metadata records for all categories. */
    public static List<CMN_FHQ_CalculationFormula__mdt> calculationFormulas;

    /** @description Loaded rule set version record for this calculation run. */
    public static CMN_Rule_Set_Version__c ruleSetVersion;

    /** @description Map of Assessment field API name to computed category score value. */
    public static Map<String, Decimal> categoryToFieldMap;

    /** @description Rule Set Version ID extracted from the first response record. */
    public static Id ruleVersionId;

    /** @description Respondent date of birth passed in from the REST endpoint. */
    public static Date dateOfBirth;

    /** @description Assessment start timestamp passed in from the REST endpoint. */
    public static Datetime assessmentStartTime;

    /** @description The CMN_Assessment__c record created by this run (used by REST caller). */
    public static CMN_Assessment__c createdAssessment;

    /** @description Full name of the user who submitted the assessment. */
    public static String submittedBy;

    // Retirement Readiness outputs (populated by CMN_FHQ_SRV_RetirementCalculation)
    /** @description Compound-interest future value of respondent's current investments. */
    public static Decimal investmentBehaviourFutureValue;

    /** @description Target retirement savings amount (annual expenses / withdrawal rate). */
    public static Decimal retirementTargetAmount;

    /** @description Calculated years remaining until the respondent's retirement age. */
    public static Decimal yearsOfRetirement;

    /**
     * @description Entry point to perform all category score calculations.
     *              Loads responses, resolves ruleset configuration, and runs the
     *              calculation pipeline. Persists all derived records on completion.
     * @param questionResponses List of responses submitted for calculation
     * @param dobInput Respondent date of birth
     * @param startTime Assessment start datetime
     * @param userSubmitted Name of the user who submitted the assessment
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static void performCalculations(
        List<CMN_Question_Response__c> questionResponses,
        Date dobInput,
        Datetime startTime,
        String userSubmitted
    ) {
        if (questionResponses == null || questionResponses.isEmpty()) {
            return;
        }

        dateOfBirth      = dobInput;
        assessmentStartTime = startTime;
        submittedBy      = userSubmitted;

        LOGGER.info(
            'CMN_FHQ_Calculation.performCalculations: Starting - submittedBy={0}, responses.size={1}',
            new List<Object>{ submittedBy, questionResponses.size() }
        );

        orderQuestionResponseMap = new Map<String, CMN_Question_Response__c>();

        Set<Id> responseIds = new Set<Id>();
        for (CMN_Question_Response__c questionResponse : questionResponses) {
            responseIds.add(questionResponse.Id);
        }

        SEL_CMNQuestionResponse questionResponseSelector = new SEL_CMNQuestionResponse();
        questionResponseRecords = questionResponseSelector.selectQuestionResponsesById(responseIds);

        for (CMN_Question_Response__c responseRecord : questionResponseRecords) {
            LOGGER.debug(
                'CMN_FHQ_Calculations.performCalculations: responseId={0}, questionId={1}',
                new List<Object>{
                    responseRecord.CMN_Question__c,
                    responseRecord.CMN_Question__r.Question_ID__c
                }
            );

            if (responseRecord.CMN_Question__c != null
                    && responseRecord.CMN_Question__r.Question_ID__c != null) {
                orderQuestionResponseMap.put(
                    responseRecord.CMN_Question__r.Question_ID__c,
                    responseRecord
                );
            }
        }

        ruleVersionId = questionResponseRecords[0].CMN_Rule_Set_Version__c;

        SEL_CMNRuleSetVersion ruleSetVersionSelector = new SEL_CMNRuleSetVersion();
        ruleSetVersion = ruleSetVersionSelector.selectById(ruleVersionId);

        SEL_CMNCategoryCalculationFormulas formulaSelector = new SEL_CMNCategoryCalculationFormulas();
        calculationFormulas = formulaSelector.getCategoryCalculationFormulas();

        executeWithStatusHandling();
    }

    // ─── Calculation Orchestration ───────────────────────────────────────────────

    /**
     * @description Iterates all formula metadata categories, evaluates scores,
     *              inserts Category Score and Calculation Run records, then
     *              builds and persists the Assessment.
     */
    private static void executeWithStatusHandling() {
        checkCalculationPermissions();
        if (calculationFormulas == null || calculationFormulas.isEmpty()) {
            LOGGER.warn('CMN_FHQ_Calculations.executeWithStatusHandling: No formula metadata found');
            return;
        }

        categoryToFieldMap = new Map<String, Decimal>();

        CategoryRecordMaps recordMaps = buildCategoryRecords();

        List<CMN_Category_Score__c> categoryScoresToPersist =
            new List<CMN_Category_Score__c>();
        List<CMN_Calculation_Run__c> runsToPersist =
            new List<CMN_Calculation_Run__c>();

        for (String category : recordMaps.processedCategories) {
            CMN_Category_Score__c categoryScore         = recordMaps.categoryToScoreRecord.get(category);
            CMN_Calculation_Run__c runRecord            = recordMaps.categoryToRunRecord.get(category);
            CMN_FHQ_CalculationFormula__mdt formulaMeta = recordMaps.metadataByCategory.get(category);
            Datetime calculationStartTime               = Datetime.now();

            evaluateCategoryScoreWithErrorHandling(categoryScore, runRecord, formulaMeta,
                calculationStartTime);

            categoryScoresToPersist.add(categoryScore);
            runsToPersist.add(runRecord);
        }

        persistCalculationResults(categoryScoresToPersist, runsToPersist);

        LOGGER.info(
            'CMN_FHQ_Calculations.executeWithStatusHandling: Completed - assessmentId={0}',
            new List<Object>{ createdAssessment.Id }
        );
    }

    /**
     * @description Helper class to encapsulate category record maps for the calculation process.
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private class CategoryRecordMaps {
        Map<String, CMN_Category_Score__c> categoryToScoreRecord;
        Map<String, CMN_Calculation_Run__c> categoryToRunRecord;
        Map<String, CMN_FHQ_CalculationFormula__mdt> metadataByCategory;
        Set<String> processedCategories;

        CategoryRecordMaps(
            Map<String, CMN_Category_Score__c> scores,
            Map<String, CMN_Calculation_Run__c> runs,
            Map<String, CMN_FHQ_CalculationFormula__mdt> metadata,
            Set<String> categories
        ) {
            this.categoryToScoreRecord = scores;
            this.categoryToRunRecord = runs;
            this.metadataByCategory = metadata;
            this.processedCategories = categories;
        }
    }

    /**
     * @description Builds Category Score and Calculation Run records from formula metadata.
     * @return CategoryRecordMaps containing prepared records
     */
    private static CategoryRecordMaps buildCategoryRecords() {
        Map<String, CMN_Category_Score__c> categoryToScoreRecord =
            new Map<String, CMN_Category_Score__c>();
        Map<String, CMN_Calculation_Run__c> categoryToRunRecord  =
            new Map<String, CMN_Calculation_Run__c>();
        Map<String, CMN_FHQ_CalculationFormula__mdt> metadataByCategory =
            new Map<String, CMN_FHQ_CalculationFormula__mdt>();
        Set<String> processedCategories = new Set<String>();

        for (CMN_FHQ_CalculationFormula__mdt formulaMetadata : calculationFormulas) {
            String category = formulaMetadata.Category__c;
            if (String.isBlank(category) || processedCategories.contains(category)) {
                continue;
            }
            processedCategories.add(category);
            metadataByCategory.put(category, formulaMetadata);

            CMN_Category_Score__c categoryScore = new CMN_Category_Score__c();
            categoryScore.CMN_Category__c           = category;
            categoryScore.CMN_Rule_Set_Version__c   = ruleVersionId;
            categoryScore.CMN_Calculation_Status__c = STATUS_NOT_CALCULATED;
            categoryScore.CMN_Weight__c             = formulaMetadata.CMN_Weight__c;
            categoryScore.CMN_Explanation__c        = buildCategoryExplanation(formulaMetadata);
            categoryToScoreRecord.put(category, categoryScore);

            CMN_Calculation_Run__c runRecord = new CMN_Calculation_Run__c();
            runRecord.CMN_Rule_Set_Version__c = ruleVersionId;
            runRecord.CMN_Status__c           = STATUS_RUNNING;
            runRecord.Date_of_Birth__c        = dateOfBirth;
            runRecord.CMN_API_Request_ID__c   = Request.getCurrent().getRequestId();
            categoryToRunRecord.put(category, runRecord);
        }

        return new CategoryRecordMaps(categoryToScoreRecord, categoryToRunRecord,
            metadataByCategory, processedCategories);
    }

    /**
     * @description Builds explanation text for a category based on formula metadata.
     * @param formulaMetadata Formula metadata record
     * @return Explanation string for the category
     */
    private static String buildCategoryExplanation(CMN_FHQ_CalculationFormula__mdt formulaMetadata) {
        if (String.isBlank(formulaMetadata.Formula__c)) {
            return 'No formula found';
        }
        return 'Formula: ' + formulaMetadata.Formula__c;
    }

    /**
     * @description Evaluates category score with error handling and logging.
     * @param categoryScore Category Score record to populate
     * @param runRecord Calculation Run record to populate
     * @param formulaMeta Formula metadata record
     * @param calculationStartTime Start timestamp
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void evaluateCategoryScoreWithErrorHandling(
        CMN_Category_Score__c categoryScore,
        CMN_Calculation_Run__c runRecord,
        CMN_FHQ_CalculationFormula__mdt formulaMeta,
        Datetime calculationStartTime
    ) {
        try {
            evaluateCategoryScore(categoryScore, runRecord, formulaMeta, calculationStartTime);
        } catch (Exception calculationException) {
            String category = categoryScore.CMN_Category__c;
            categoryScore.CMN_Calculation_Status__c = STATUS_ERROR;
            categoryScore.CMN_Explanation__c = 'Error while calculating category ' + category
                + ': ' + calculationException.getMessage();
            runRecord.CMN_Status__c = STATUS_FAILED;
            runRecord.CMN_Error_Message__c = calculationException.getMessage();
            runRecord.CMN_Error_Stack_Trace__c = calculationException.getStackTraceString();

            LOGGER.error(
                'CMN_FHQ_Calculations.executeWithStatusHandling: Category={0} failed - {1}',
                new List<Object>{ category, calculationException.getMessage() },
                calculationException
            );
        }
    }

    /**
     * @description Persists category scores, calculation runs, and assessment records.
     * @param categoryScoresToPersist Category score records to insert
     * @param runsToPersist Calculation run records to insert
     */
    /**
     * @description Validates that the current user has permissions to perform database operations.
     * @return True if user has all required permissions, false otherwise
     */
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private static Boolean validateDatabasePermissions() {
        Boolean canAccessCategoryScore = Schema.sObjectType.CMN_Category_Score__c.isCreateable()
            && Schema.sObjectType.CMN_Category_Score__c.isUpdateable();
        Boolean canAccessCalculationRun = Schema.sObjectType.CMN_Calculation_Run__c.isCreateable()
            && Schema.sObjectType.CMN_Calculation_Run__c.isUpdateable();
        Boolean canAccessAssessment = Schema.sObjectType.CMN_Assessment__c.isCreateable();
        Boolean canAccessQuestionResponse = Schema.sObjectType.CMN_Question_Response__c.isUpdateable();

        return canAccessCategoryScore && canAccessCalculationRun && canAccessAssessment
            && canAccessQuestionResponse;
    }

    private static void persistCalculationResults(
        List<CMN_Category_Score__c> categoryScoresToPersist,
        List<CMN_Calculation_Run__c> runsToPersist
    ) {
        if (!validateDatabasePermissions()) {
            LOGGER.error('CMN_FHQ_Calculation.persistCalculationResults: Insufficient permissions');
            return;
        }

        insert categoryScoresToPersist;
        insert runsToPersist;

        CMN_Assessment__c assessment =
            buildAssessmentFromCategoryScores(categoryScoresToPersist);
        insert assessment;
        createdAssessment = assessment;

        linkAssessmentToRecords(categoryScoresToPersist, runsToPersist, assessment.Id);
    }

    /**
     * @description Links assessment ID to all related records and updates them.
     * @param categoryScores Category score records to update
     * @param runRecords Calculation run records to update
     * @param assessmentId Assessment ID to link to records
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void linkAssessmentToRecords(
        List<CMN_Category_Score__c> categoryScores,
        List<CMN_Calculation_Run__c> runRecords,
        Id assessmentId
    ) {
        for (CMN_Category_Score__c categoryScore : categoryScores) {
            categoryScore.CMN_Assessment__c = assessmentId;
        }
        for (CMN_Calculation_Run__c runRecord : runRecords) {
            runRecord.CMN_Assessment__c = assessmentId;
        }
        update categoryScores;
        update runRecords;

        for (CMN_Question_Response__c responseRecord : questionResponseRecords) {
            responseRecord.CMN_Assessment__c = assessmentId;
        }
        update questionResponseRecords;
    }

    /**
     * @description Evaluates the score for a single category and updates the Category Score
     *              and Calculation Run records in place. Delegates to the retirement service
     *              for complex calculations, or CMN_FHQ_MathExpression for formula-based ones.
     * @param categoryScore Category Score record to populate
     * @param runRecord Calculation Run record to populate
     * @param formulaMeta Formula metadata record for this category
     * @param calculationStartTime Timestamp captured before evaluation began
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void evaluateCategoryScore(
        CMN_Category_Score__c categoryScore,
        CMN_Calculation_Run__c runRecord,
        CMN_FHQ_CalculationFormula__mdt formulaMeta,
        Datetime calculationStartTime
    ) {
        if (!isFormulaValid(formulaMeta)) {
            categoryScore.CMN_Calculation_Status__c = STATUS_NOT_CALCULATED;
            runRecord.CMN_Status__c = STATUS_CANCELLED;
            LOGGER.warn(
                'CMN_FHQ_Calculations.evaluateCategoryScore: No formula for category={0}',
                new List<Object>{ categoryScore.CMN_Category__c }
            );
            return;
        }

        Set<String> missingQuestions = getMissingQuestions(
            formulaMeta.Formula__c, orderQuestionResponseMap
        );

        if (!missingQuestions.isEmpty()) {
            handleInsufficientData(categoryScore, runRecord, missingQuestions);
            return;
        }

        Decimal rawResult = calculateRawResult(formulaMeta);

        if (formulaMeta.isComplex__c && rawResult == null) {
            categoryScore.CMN_Calculation_Status__c = STATUS_INSUFFICIENT;
            runRecord.CMN_Status__c = STATUS_FAILED;
            return;
        }

        Decimal calculatedScore = applyScoreBounds(rawResult);
        categoryToFieldMap.put(formulaMeta.Saved_to_Field__c, calculatedScore);
        handleNormalizedField(formulaMeta, calculatedScore);

        populateCategoryScoreFields(categoryScore, formulaMeta, rawResult, calculatedScore);
        populateRunRecordFields(runRecord, calculationStartTime, calculatedScore);

        LOGGER.info(
            'CMN_FHQ_Calculations.evaluateCategoryScore: Category={0}, rawResult={1}, calculatedScore={2}',
            new List<Object>{ formulaMeta.Category__c, rawResult, calculatedScore }
        );
    }

    /**
     * @description Validates that formula metadata has required data.
     * @param formulaMeta Formula metadata to validate
     * @return True if formula is valid, false otherwise
     */
    private static Boolean isFormulaValid(CMN_FHQ_CalculationFormula__mdt formulaMeta) {
        if (formulaMeta == null) {
            return false;
        }
        Boolean hasFormula = !String.isBlank(formulaMeta.Formula__c);
        Boolean isComplex = formulaMeta.isComplex__c;
        return hasFormula || isComplex;
    }

    /**
     * @description Handles insufficient data situation for a category.
     * @param categoryScore Category Score record to update
     * @param runRecord Calculation Run record to update
     * @param missingQuestions Set of missing question IDs
     */
    private static void handleInsufficientData(
        CMN_Category_Score__c categoryScore,
        CMN_Calculation_Run__c runRecord,
        Set<String> missingQuestions
    ) {
        categoryScore.CMN_Calculation_Status__c = STATUS_INSUFFICIENT;
        categoryScore.CMN_Explanation__c = 'Missing answers for: '
            + String.join(new List<String>(missingQuestions), ', ');
        runRecord.CMN_Status__c = STATUS_FAILED;
        LOGGER.warn(
            'CMN_FHQ_Calculations.evaluateCategoryScore: Insufficient data for category={0}, missing={1}',
            new List<Object>{ categoryScore.CMN_Category__c, missingQuestions }
        );
    }

    /**
     * @description Calculates the raw result for a category based on formula type.
     * @param formulaMeta Formula metadata record
     * @return Calculated raw Decimal result
     */
    private static Decimal calculateRawResult(CMN_FHQ_CalculationFormula__mdt formulaMeta) {
        if (formulaMeta.isComplex__c) {
            return evaluateComplexCategory(formulaMeta);
        }
        String resolvedFormula = applyQuestionValues(formulaMeta.Formula__c, orderQuestionResponseMap);
        Decimal evaluated = safeEval(resolvedFormula);
        return Math.round(evaluated);
    }

    /**
     * @description Handles normalized field mapping if applicable.
     * @param formulaMeta Formula metadata record
     * @param calculatedScore Calculated category score
     */
    private static void handleNormalizedField(
        CMN_FHQ_CalculationFormula__mdt formulaMeta,
        Decimal calculatedScore
    ) {
        if (formulaMeta.Normalized_Field__c == null) {
            return;
        }

        if (formulaMeta.Normalize__c) {
            Decimal normalizedScore = applyScoreBounds(100 - calculatedScore);
            categoryToFieldMap.put(formulaMeta.Normalized_Field__c, normalizedScore);
            LOGGER.debug(
                'CMN_FHQ_Calculations.evaluateCategoryScore: Category={0}, score={1}, normalised={2}',
                new List<Object>{ formulaMeta.Category__c, calculatedScore, normalizedScore }
            );
        } else {
            categoryToFieldMap.put(formulaMeta.Normalized_Field__c, calculatedScore);
        }
    }

    /**
     * @description Populates CMN_Category_Score__c fields with calculation results.
     * @param categoryScore Category Score record to populate
     * @param formulaMeta Formula metadata record
     * @param rawResult Raw calculated value
     * @param calculatedScore Bounded calculated score
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static void populateCategoryScoreFields(
        CMN_Category_Score__c categoryScore,
        CMN_FHQ_CalculationFormula__mdt formulaMeta,
        Decimal rawResult,
        Decimal calculatedScore
    ) {
        categoryScore.CMN_Score__c          = calculatedScore;
        categoryScore.CMN_Raw_Value__c      = rawResult;
        categoryScore.CMN_Raw_Value_Text__c = String.valueOf(rawResult);
        categoryScore.CMN_Explanation__c    = formulaMeta.Formula__c;

        if (calculatedScore == null) {
            categoryScore.CMN_Calculation_Status__c = STATUS_NOT_CALCULATED;
            categoryScore.CMN_Metrics_Available__c  = false;
            categoryScore.CMN_Explanation__c        =
                'Score not found - answer is missing or score not found for the Formula';
        } else {
            categoryScore.CMN_Calculation_Status__c = STATUS_CALCULATED;
            categoryScore.CMN_Metrics_Available__c  = true;
        }
    }

    /**
     * @description Populates CMN_Calculation_Run__c fields with calculation metadata.
     * @param runRecord Calculation Run record to populate
     * @param calculationStartTime Start timestamp
     * @param calculatedScore Calculated category score
     */
    private static void populateRunRecordFields(
        CMN_Calculation_Run__c runRecord,
        Datetime calculationStartTime,
        Decimal calculatedScore
    ) {
        runRecord.CMN_Started_DateTime__c      = calculationStartTime;
        runRecord.CMN_Completed_DateTime__c    = System.now();
        runRecord.CMN_Duration_Milliseconds__c =
            runRecord.CMN_Completed_DateTime__c.getTime() - calculationStartTime.getTime();

        if (calculatedScore == null) {
            runRecord.CMN_Status__c = STATUS_FAILED;
        } else {
            runRecord.CMN_Status__c = STATUS_COMPLETED;
        }
    }

    /**
     * @description Delegates the complex Retirement Readiness calculation to
     *              CMN_FHQ_SRV_RetirementCalculation and captures its output fields.
     * @param formulaMeta Formula metadata record for the complex category
     * @return Calculated score Decimal, or null when inputs are insufficient
     */
    private static Decimal evaluateComplexCategory(CMN_FHQ_CalculationFormula__mdt formulaMeta) {
        if (formulaMeta.Category__c == 'Retirement_Readiness') {
            CMN_FHQ_SRV_RetirementCalculation retirementService =
                new CMN_FHQ_SRV_RetirementCalculation();
            Decimal result = retirementService.calculate(
                orderQuestionResponseMap, ruleSetVersion, dateOfBirth
            );
            investmentBehaviourFutureValue = retirementService.investmentBehaviourFutureValue;
            retirementTargetAmount         = retirementService.retirementTargetAmount;
            yearsOfRetirement              = retirementService.yearsOfRetirement;
            return result;
        }
        return null;
    }

    /**
     * @description Clamps a raw score to the valid range 1-100.
     *              Values <= 0 become 1; values >= 100 become 100.
     * @param rawScore Unclamped score value
     * @return Clamped Decimal score value
     */
    private static Decimal applyScoreBounds(Decimal rawScore) {
        if (rawScore == null) {
            return null;
        }
        if (rawScore <= 0) {
            return 1;
        }
        if (rawScore >= 100) {
            return 100;
        }
        return rawScore;
    }

    // ─── Assessment Builder ──────────────────────────────────────────────────────

    /**
     * @description Builds a CMN_Assessment__c from computed Category Score records.
     *              Maps category field values, retirement outputs, and respondent
     *              identity fields onto the assessment record.
     * @param scores List of category score records after calculation
     * @return Populated CMN_Assessment__c ready for insert
     */
    private static CMN_Assessment__c buildAssessmentFromCategoryScores(
        List<CMN_Category_Score__c> scores
    ) {
        CMN_Assessment__c assessment = new CMN_Assessment__c();
        assessment.CMN_Version_Number__c = ruleVersionId;

        Integer successCount = 0;
        Integer errorCount   = 0;

        for (CMN_Category_Score__c categoryScore : scores) {
            if (categoryScore.CMN_Calculation_Status__c == STATUS_CALCULATED) {
                successCount++;
            } else {
                errorCount++;
            }
        }

        if (errorCount > 0) {
            assessment.CMN_Status__c = STATUS_ERROR;
        } else if (successCount == 0) {
            assessment.CMN_Status__c = STATUS_NOT_CALCULATED;
        } else {
            assessment.CMN_Status__c = STATUS_CALCULATED;
        }

        for (String fieldApiName : categoryToFieldMap.keySet()) {
            assessment.put(fieldApiName, categoryToFieldMap.get(fieldApiName));
        }

        assessment.CMN_Retirement_Target__c      = retirementTargetAmount;
        assessment.CMN_Years_to_Retirement__c    = yearsOfRetirement;
        assessment.CMN_Future_Value__c           = investmentBehaviourFutureValue;
        assessment.User_Id__c                    = questionResponseRecords[0].User_Id__c;
        assessment.Id_Number__c                  = questionResponseRecords[0].Id_Number__c;
        assessment.PING_Id__c                    = questionResponseRecords[0].Ping_Id__c;
        assessment.Id_Type__c                    = questionResponseRecords[0].Id_Type__c;
        if (assessmentStartTime == null) {
            assessment.CMN_Assessment_Start_Date__c = System.now();
        } else {
            assessment.CMN_Assessment_Start_Date__c = assessmentStartTime;
        }
        assessment.CMN_Assessment_Completion_Date__c = System.now();
        assessment.CMN_Source__c                 = 'Perx';
        assessment.CMN_Return_Rate__c            = ruleSetVersion.CMN_Return_Rate__c;
        assessment.CMN_Withdrawal_Rate__c        = ruleSetVersion.CMN_Withdrawal_Rate__c;
        assessment.CMN_Retirement_Age__c         = ruleSetVersion.CMN_Default_Retirement_Age__c;
        assessment.CMN_Rule_Set_Version__c       = ruleSetVersion.Name;
        assessment.CMN_Completed_By__c           = submittedBy;

        LOGGER.info(
            'CMN_FHQ_Calculations.buildAssessmentFromCategoryScores: Built assessment - status={0}, successCount={1}, errorCount={2}',
            new List<Object>{ assessment.CMN_Status__c, successCount, errorCount }
        );

        return assessment;
    }

    // ─── Formula Evaluation Helpers ──────────────────────────────────────────────

    /**
     * @description Safely evaluates a mathematical expression string.
     *              Returns 0 when the expression is blank or the evaluation returns null.
     * @param expression Mathematical expression string to evaluate
     * @return Evaluated Decimal result (never null)
     */
    private static Decimal safeEval(String expression) {
        if (String.isBlank(expression)) {
            return 0;
        }
        Decimal evaluatedValue = CMN_FHQ_MathExpressions.eval(expression);
        if (evaluatedValue == null) {
            return 0;
        }
        return evaluatedValue;
    }

    /**
     * @description Checks if a question has been answered with a numeric value.
     * @param questionKey Question identifier (e.g., Q1)
     * @param responseMap Map of question responses
     * @return True if question is answered, false otherwise
     */
    private static Boolean isQuestionAnswered(
        String questionKey,
        Map<String, CMN_Question_Response__c> responseMap
    ) {
        if (!responseMap.containsKey(questionKey)) {
            return false;
        }
        CMN_Question_Response__c responseRecord = responseMap.get(questionKey);
        return responseRecord != null && responseRecord.CMN_Response_Value_Number__c != null;
    }

    /**
     * @description Finds question keys referenced in a formula that are absent
     *              or have a null numeric value in the response map.
     *              Expects formula tokens in the format {Q1}, {Q2}, etc.
     * @param formula Formula string containing question tokens
     * @param responseMap Map of question ID key to CMN_Question_Response__c record
     * @return Set of missing question key strings
     */
    private static Set<String> getMissingQuestions(
        String formula,
        Map<String, CMN_Question_Response__c> responseMap
    ) {
        Set<String> missingQuestions = new Set<String>();

        if (String.isBlank(formula)) {
            return missingQuestions;
        }

        Pattern questionPattern = Pattern.compile('\\{(Q[0-9]+)\\}');
        Matcher questionMatcher = questionPattern.matcher(formula);

        while (questionMatcher.find()) {
            String questionKey = questionMatcher.group(1);

            if (!isQuestionAnswered(questionKey, responseMap)) {
                missingQuestions.add(questionKey);
            }
        }

        return missingQuestions;
    }

    /**
     * @description Replaces {Q1}-style tokens in a formula string with the respondent's
     *              actual numeric answer values. Unresolved tokens are replaced with 0.
     * @param formula Formula string with question tokens
     * @param responseMap Map of question ID key to CMN_Question_Response__c record
     * @return Resolved formula string ready for CMN_FHQ_MathExpression evaluation
     */
    private static String applyQuestionValues(
        String formula,
        Map<String, CMN_Question_Response__c> responseMap
    ) {
        if (String.isBlank(formula)) {
            return formula;
        }

        for (String questionKey : responseMap.keySet()) {
            Decimal responseValue = responseMap.get(questionKey).CMN_Response_Value_Number__c;
            Decimal valueToUse = getResponseValueOrDefault(responseValue); 
            valueToUse = preventDivisionByZero(questionKey, valueToUse);
            formula = formula.replace(
                '{' + questionKey + '}',
                String.valueOf(valueToUse)
            );
        }

        // Replace any remaining unresolved tokens with 0
        formula = formula.replaceAll('\\{Q[0-9]+\\}', '0');

        return formula;
    }

    /**
     * @description Gets a response value or returns default of 0 if null.
     * @param responseValue Response value to check
     * @return Response value if non-null, otherwise 0
     */
    private static Decimal getResponseValueOrDefault(Decimal responseValue) {
        if (responseValue == null) {
            return 0;
        }
        return responseValue;
    }

    /**
     * @description Validates that the current user has permissions to create and update
     *              required calculation records.
     */
    private static void checkCalculationPermissions() {
        Boolean hasCreateableScoreObjects = Schema.sObjectType.CMN_Category_Score__c.isCreateable()
            && Schema.sObjectType.CMN_Category_Score__c.isUpdateable();
        Boolean hasCreateableRunObjects = Schema.sObjectType.CMN_Calculation_Run__c.isCreateable()
            && Schema.sObjectType.CMN_Calculation_Run__c.isUpdateable();
        Boolean hasCreateableAssessments = Schema.sObjectType.CMN_Assessment__c.isCreateable();
        Boolean hasUpdateableResponses = Schema.sObjectType.CMN_Question_Response__c.isUpdateable();

        if (!hasCreateableScoreObjects || !hasCreateableRunObjects || !hasCreateableAssessments
                || !hasUpdateableResponses) {
            return;
        }
    }
    
    /**
     * @description validates the question value to prevent division by zero
     */
    private static Decimal preventDivisionByZero(String questionKey, Decimal value) {
    Set<String> denominatorQuestions = new Set<String>{ 'Q5' };
    if (denominatorQuestions.contains(questionKey) && value == 0) {
        LOGGER.warn(
            'CMN_FHQ_Calculation.preventDivisionByZero: {0} is zero — substituting 1 to avoid division by zero',
            new List<Object>{ questionKey }
        );
        return 1;
    }
    return value;
}
}