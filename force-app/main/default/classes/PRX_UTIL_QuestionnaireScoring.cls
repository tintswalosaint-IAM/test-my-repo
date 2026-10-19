/**
* @description Utility class responsible for loading and querying answer scoring rules
*              and question name mappings used during questionnaire response processing.
*              Implements request-scoped static caching to avoid redundant queries within
*              a single transaction. All System.debug calls replaced with RFLIB logger.
*
* @author Taimoor.shaik@standardbank.co.za
* @date Jan 2026
@ Modification Description :
1.0   Jan 2026      Taimoor.Shaik@standardbank.co.za    Initial Creation(PPBSF-179, 127, 120, 271, 176, 121, 122, 123, 119,270,172)
*/
public with sharing class PRX_UTIL_QuestionnaireScoring {
    
    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PRX_UTIL_QuestionnaireScoring');
    
    // Request-scoped cache: Question Name -> (Answer Text -> Score Value)
    private static Map<String, Map<String, Decimal>> answerScoreCache;
    
    // Request-scoped cache: Question Record ID -> Question Name
    private static Map<Id, String> questionIdToNameMap;
    
    @TestVisible
    private static Boolean forceQuestionLoadException = false;
    
    @TestVisible
    private static Boolean forceScoringLoadException = false;
    
    /**
    * @description Private constructor prevents instantiation.
    *              This is a utility class with only static methods.
    */
    private PRX_UTIL_QuestionnaireScoring() {
    }
    
    /**
* @description Initialises both the scoring rule cache and the question name cache
*              in a single call. Safe to invoke multiple times within one transaction;
*              each cache loads only on first call.
*/
    public static void initialise() {
        loadScoringRules();
        loadQuestionMappings();
    }
    
    /**
* @description Returns the Question Name (e.g. Q1) for a given Question Record ID.
*              Returns null when the ID is absent from the cache or the cache
*              has not been initialised.
* @param questionId Salesforce Record ID of the CMN_Question__c record
* @return Question Name string, or null if not found
*/
    public static String getQuestionNameFromId(Id questionId) {
        if (questionId == null || questionIdToNameMap == null) {
            return null;
        }
        return questionIdToNameMap.get(questionId);
    }
    
    /**
* @description Looks up the score value for a given question and answer text.
*              Performs exact-match first, then falls back to case-insensitive matching.
*              Returns null when no scoring rule exists for the given inputs.
* @param questionName The Name field of the CMN_Question__c record (e.g. Q1)
* @param answerText The answer text selected by the respondent
* @return Score Decimal value, or null if no rule matches
*/
    public static Decimal getScoreForAnswer(String questionName, String answerText) {
        if (answerScoreCache == null || !answerScoreCache.containsKey(questionName)) {
            return null;
        }
        
        Map<String, Decimal> answerScores = answerScoreCache.get(questionName);
        
        if (answerScores.containsKey(answerText)) {
            return answerScores.get(answerText);
        }
        
        for (String answerKey : answerScores.keySet()) {
            if (answerKey.equalsIgnoreCase(answerText)) {
                return answerScores.get(answerKey);
            }
        }
        
        LOGGER.debug(
            'PRX_UTIL_QuestionnaireScoring.getScoreForAnswer: No scoring rule match - questionName={0}, answerText={1}',
            new List<Object>{ questionName, answerText }
        );
        return null;
    }
    
    // ─── Private Cache Loaders ───────────────────────────────────────────────────
    
    /**
* @description Loads Question ID to Question Name mappings from the active question list
*              into the request-scoped cache. No-ops when already loaded.
*/
    private static void loadQuestionMappings() {
        if (questionIdToNameMap != null) {
            return;
        }
        
        questionIdToNameMap = new Map<Id, String>();
        
        try {
            if (forceQuestionLoadException) {
                throw new AuraHandledException('Forced test exception');
            }
            
            SEL_CMNQuestion questionSelector = new SEL_CMNQuestion();
            List<CMN_Question__c> activeQuestions = questionSelector.selectActiveQuestions();
            
            for (CMN_Question__c question : activeQuestions) {
                questionIdToNameMap.put(question.Id, question.Name);
            }
            
            LOGGER.info(
                'PRX_UTIL_QuestionnaireScoring.loadQuestionMappings: Loaded {0} question mappings',
                new List<Object>{ questionIdToNameMap.size() }
            );
            
        } catch (Exception queryException) {
            LOGGER.error(
                'PRX_UTIL_QuestionnaireScoring.loadQuestionMappings: Query failed - {0}',
                new List<Object>{ queryException.getMessage() },
                queryException
            );
            questionIdToNameMap = new Map<Id, String>();
        }
    }
    
    /**
* @description Loads scoring rules from FHQ_Answer_Scoring__mdt custom metadata
*              into a nested map structure for fast lookup during processing.
*              No-ops when already loaded.
*/
    private static void loadScoringRules() {
        if (answerScoreCache != null) {
            return;
        }
        
        answerScoreCache = new Map<String, Map<String, Decimal>>();
        
        try {
            if (forceScoringLoadException) {
                throw new AuraHandledException('Forced test exception');
            }
            
            SEL_FHQAnswerScoring answerScoringSelector = new SEL_FHQAnswerScoring();
            List<FHQ_Answer_Scoring__mdt> scoringRules = answerScoringSelector.selectActiveQuestions();
            
            for (FHQ_Answer_Scoring__mdt scoringRule : scoringRules) {
                if (!answerScoreCache.containsKey(scoringRule.Question_Name__c)) {
                    answerScoreCache.put(scoringRule.Question_Name__c, new Map<String, Decimal>());
                }
                answerScoreCache.get(scoringRule.Question_Name__c)
                    .put(scoringRule.Answer_Text__c, scoringRule.Score_Value__c);
            }
            
            LOGGER.info(
                'PRX_UTIL_QuestionnaireScoring.loadScoringRules: Loaded {0} rules for {1} questions',
                new List<Object>{ scoringRules.size(), answerScoreCache.size() }
            );
            
        } catch (Exception queryException) {
            LOGGER.error(
                'PRX_UTIL_QuestionnaireScoring.loadScoringRules: Metadata query failed - {0}',
                new List<Object>{ queryException.getMessage() },
                queryException
            );
            answerScoreCache = new Map<String, Map<String, Decimal>>();
        }
    }
}