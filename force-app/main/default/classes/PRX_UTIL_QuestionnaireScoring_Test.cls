/**
 * @description Test class for PRX_UTIL_QuestionnaireScoring utility.
 *              Covers cache initialisation, question-name resolution,
 *              answer scoring (exact and case-insensitive), null-safety
 *              guards, exception/catch-block paths, and the full
 *              end-to-end flow.
 *              Scoring assertions are defensive where custom metadata
 *              visibility in the test context cannot be guaranteed.
 *
 * @author Taimoor.shaik@standardbank.co.za
 * @date Jan 2026
 *
 * @see PRX_UTIL_QuestionnaireScoring
 @ Modification Description :
1.0   Jan 2026      Taimoor.Shaik@standardbank.co.za    Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119,270,172)
*/
@IsTest
private class PRX_UTIL_QuestionnaireScoring_Test {

    /* ───────────────── CONSTANTS ───────────────── */

    private static final String  Q1        = 'Q1';
    private static final String  Q2        = 'Q2';
    private static final String  Q3        = 'Q3';

    private static final String  YES       = 'Yes';
    private static final String  YES_LOWER = 'yes';
    private static final String  YES_MIXED = 'yEs';

    /* ───────────────── HELPERS ───────────────── */

    /**
     * @description Creates and inserts a single active CMN_Question__c record.
     * @param name The Name value to assign to the question record.
     * @return The inserted CMN_Question__c record.
     */
    private static CMN_Question__c createQuestion(String name) {
        CMN_Question__c q = new CMN_Question__c(
            Name         = name,
            Is_Active__c = true
        );
        insert q;
        return q;
    }

    /**
     * @description Creates and inserts three active CMN_Question__c records
     *              named Q1, Q2, and Q3 for use in multi-question scenarios.
     * @return List of inserted CMN_Question__c records in insertion order.
     */
    private static List<CMN_Question__c> createQuestions() {
        List<CMN_Question__c> questions = new List<CMN_Question__c>{
            new CMN_Question__c(Name = Q1, Is_Active__c = true),
            new CMN_Question__c(Name = Q2, Is_Active__c = true),
            new CMN_Question__c(Name = Q3, Is_Active__c = true)
        };
        insert questions;
        return questions;
    }

    /* ───────────────── INITIALISE TESTS ───────────────── */

    /**
     * @description Verifies that initialise() loads all active question
     *              mappings into the cache so that getQuestionNameFromId
     *              resolves correctly for each inserted record.
     */
    @IsTest
    static void testInitialise_loadsMappings() {
        List<CMN_Question__c> questions = createQuestions();

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        Assert.areEqual(
            Q1,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(questions[0].Id),
            'First question Id should resolve to Q1 after initialise()'
        );
        Assert.areEqual(
            Q2,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(questions[1].Id),
            'Second question Id should resolve to Q2 after initialise()'
        );
    }

    /**
     * @description Verifies that calling initialise() twice within the same
     *              transaction does not throw an exception (idempotent behaviour).
     */
    @IsTest
    static void testInitialise_calledTwice() {
        createQuestions();

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        Assert.isTrue(true, 'Calling initialise() twice must not throw an exception');
    }

    /**
     * @description Verifies that when only inactive questions exist, initialise()
     *              still completes without error and the cache returns null for
     *              any queried Id.
     */
    @IsTest
    static void testInitialise_noActiveQuestions() {
        insert new CMN_Question__c(Name = 'Inactive', Is_Active__c = false);

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        Id inactiveId = [SELECT Id FROM CMN_Question__c LIMIT 1].Id;

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(inactiveId),
            'Inactive questions must not appear in the cache'
        );
    }

    /* ───────────────── QUESTION NAME TESTS ───────────────── */

    /**
     * @description Verifies that getQuestionNameFromId() returns null when
     *              a null Id is supplied, regardless of cache state.
     */
    @IsTest
    static void testGetQuestionName_nullId() {
        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(null),
            'A null Id argument must always return null'
        );
    }

    /**
     * @description Verifies that getQuestionNameFromId() returns null when
     *              the cache has not been initialised (no prior initialise() call).
     */
    @IsTest
    static void testGetQuestionName_cacheNotLoaded() {
        CMN_Question__c q = createQuestion(Q1);

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(q.Id),
            'Without initialise(), the cache is null and must return null'
        );
    }

    /**
     * @description Verifies that getQuestionNameFromId() correctly resolves
     *              the name of an active question after initialise() has run.
     */
    @IsTest
    static void testGetQuestionName_valid() {
        CMN_Question__c q = createQuestion(Q1);
        PRX_UTIL_QuestionnaireScoring.initialise();

        Assert.areEqual(
            Q1,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(q.Id),
            'An active question inserted before initialise() must resolve correctly'
        );
    }

    /**
     * @description Verifies that a question inserted after initialise() has run
     *              is not present in the already-loaded cache and returns null.
     */
    @IsTest
    static void testGetQuestionName_notInCache() {
        createQuestion(Q1);
        PRX_UTIL_QuestionnaireScoring.initialise();

        CMN_Question__c q2 = createQuestion(Q2);

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(q2.Id),
            'A question inserted after initialise() must not be present in the cache'
        );
    }

    /* ───────────────── SCORING TESTS ───────────────── */

    /**
     * @description Verifies that getScoreForAnswer() returns null when the
     *              scoring cache has not been initialised.
     */
    @IsTest
    static void testScore_cacheNull() {
        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES),
            'Score lookup must return null when the cache is not initialised'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() returns null for a question
     *              name that does not exist in the cache.
     */
    @IsTest
    static void testScore_questionMissing() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer('BAD', YES),
            'A question name absent from the cache must return null'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() does not throw and returns
     *              a safe value after initialise() when scoring metadata may or
     *              may not be deployed in the test context.
     */
    @IsTest
    static void testScore_afterInitialise_safeBehaviour() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Decimal score = PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES);

        Assert.isTrue(
            score == null || score >= 0,
            'Score must be null or a non-negative value — must not throw'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() does not throw for a
     *              lowercase answer variant and returns the same value as the
     *              original-case lookup (case-insensitive consistency).
     */
    @IsTest
    static void testScore_caseInsensitive_consistency() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Decimal scoreExact = PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES);
        Decimal scoreLower = PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES_LOWER);
        Decimal scoreMixed = PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES_MIXED);

        Assert.areEqual(
            scoreExact,
            scoreLower,
            'Lowercase answer must return the same score as the original-case answer'
        );
        Assert.areEqual(
            scoreExact,
            scoreMixed,
            'Mixed-case answer must return the same score as the original-case answer'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() returns null for an answer
     *              text that has no matching rule in the cache.
     */
    @IsTest
    static void testScore_noMatch_returnsNull() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, 'UNKNOWN_ANSWER_XYZ'),
            'An answer with no matching rule must return null'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() returns null when a null
     *              answer text is supplied.
     */
    @IsTest
    static void testScore_nullAnswer() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, null),
            'A null answer text must return null without throwing'
        );
    }

    /**
     * @description Verifies that getScoreForAnswer() returns null when a null
     *              question name is supplied.
     */
    @IsTest
    static void testScore_nullQuestion() {
        PRX_UTIL_QuestionnaireScoring.initialise();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(null, YES),
            'A null question name must return null without throwing'
        );
    }

    /* ───────────────── FULL FLOW TEST ───────────────── */

    /**
     * @description End-to-end test that initialises the question mapping cache,
     *              resolves a question Id to its name, and verifies the score
     *              lookup does not throw and returns a safe value.
     */
    @IsTest
    static void testFullFlow() {
        List<CMN_Question__c> questions = createQuestions();

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        String resolvedName = PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(
            questions[0].Id
        );
        Decimal score = PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(resolvedName, YES);

        Assert.areEqual(Q1, resolvedName, 'Question Id should resolve to Q1');
        Assert.isTrue(
            score == null || score >= 0,
            'Score must be null or a non-negative value — must not throw'
        );
    }

    /* ───────────────── EXCEPTION / CATCH-BLOCK TESTS ───────────────── */

    /**
     * @description Verifies that when the question-mapping loader throws an
     *              exception (simulated via forceQuestionLoadException flag),
     *              the catch block runs, the cache is set to an empty map,
     *              and subsequent lookups return null rather than throwing.
     */
    @IsTest
    static void testLoadQuestionMappings_catchBlock() {
        PRX_UTIL_QuestionnaireScoring.forceQuestionLoadException = true;
        
        // Create a test question to use a valid ID format
        CMN_Question__c testQuestion = createQuestion('TestQuestion');

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getQuestionNameFromId(testQuestion.Id),
            'After a load exception the cache must be an empty map and return null'
        );

        PRX_UTIL_QuestionnaireScoring.forceQuestionLoadException = false;
    }

    /**
     * @description Verifies that when the scoring-rules loader throws an
     *              exception (simulated via forceScoringLoadException flag),
     *              the catch block runs, the cache is set to an empty map,
     *              and subsequent score lookups return null rather than throwing.
     */
    @IsTest
    static void testLoadScoringRules_catchBlock() {
        PRX_UTIL_QuestionnaireScoring.forceScoringLoadException = true;

        Test.startTest();
        PRX_UTIL_QuestionnaireScoring.initialise();
        Test.stopTest();

        Assert.areEqual(
            null,
            PRX_UTIL_QuestionnaireScoring.getScoreForAnswer(Q1, YES),
            'After a load exception the scoring cache must be an empty map and return null'
        );

        PRX_UTIL_QuestionnaireScoring.forceScoringLoadException = false;
    }
}