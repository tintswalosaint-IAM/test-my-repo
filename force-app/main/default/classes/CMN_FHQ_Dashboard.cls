/***************************************************************************************
@ Author            : Taimoor.shaik@standardbank.co.za
@ Date              : Feb 2026
@ Name of the Class : CMN_FHQ_Dashboard
@ Description       : Apex controller for Cmn_comp_fhqDashboard LWC.
                      Fetches FHQ scores and question responses directly from
                      Salesforce objects (CMN_Assessment__c, CMN_Question_Response__c)
                      using the Lead's Source_System_Reference__c as the User ID key.
@ Jira Ticket       : SFP-29597
@ Last Modified By  : preetham
@ Last Modified On  : Mar 2026
@ Modification Description :
1.0   Feb-2026   Taimoor.shaik@standardbank.co.za   Initial Creation(PPBSF-179, 127, 120, 271)
2.0   Mar-2026   preetham.Thernakal-gandla@standardbank.co.za   SyncGuestUser Assesment and Lead(PPBSF-341)
***************************************************************************************/

public with sharing class CMN_FHQ_Dashboard {

    private static final sbgplatform.rflib_Logger LOGGER =
        sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_FHQ_Dashboard');

    /***************************************************************************************
     * @description Retrieves FHQ category scores and overall score from the latest
     *              CMN_Assessment__c record linked to the Lead via Source_System_Reference__c.
     *              NOTE: CMN_Overall_Score__c is a formula field and is not included in
     *              SEL_CMNAssessment's standard field list. It is fetched via an additional
     *              selectField call on the query factory so the selector remains unchanged.
     * @param recordId  Salesforce Record ID of the Lead record.
     * @return          AssessmentScoreWrapper containing all score fields, or null if not found.
     ***************************************************************************************/

    @AuraEnabled(cacheable=true)
    public static AssessmentScoreWrapper getAssessmentScores(String recordId) {
        try {
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('Record ID cannot be empty.');
            }
            UserIdentifier identifier = getLeadUserIdentifier(recordId);
        if (identifier == null) {
            throw new AuraHandledException('No Lead found or both Source_System_Reference__c and ID_Number__c are empty.');
        }
            SEL_CMNAssessment assessmentSelector = new SEL_CMNAssessment();
            CMN_Assessment__c assessment = identifier.isSourceSystemRef
            ? assessmentSelector.selectLatestByUserId(identifier.value)
            : assessmentSelector.selectLatestByIdNumber(identifier.value);

            if (assessment == null) {
                return null;
            }

            AssessmentScoreWrapper wrapper  = new AssessmentScoreWrapper();
            wrapper.overallScore            = toIntScore(assessment.CMN_Overall_Score__c);
            wrapper.expensesScore           = toIntScore(assessment.CMN_Expenses_Score__c);
            wrapper.insuranceScore          = toIntScore(assessment.CMN_Insurance_Score__c);
            wrapper.emergencyFundScore      = toIntScore(assessment.CMN_Emergency_Fund_Score__c);
            wrapper.debtScore               = toIntScore(assessment.CMN_Debt_to_Income_Score__c);
            wrapper.retirementScore         = toIntScore(assessment.CMN_Retirement_Readiness_Score__c);
            return wrapper;

        } catch (AuraHandledException e) {
            LOGGER.error('CMN_FHQ_Dashboard.getAssessmentScores AuraHandledException: ' + e.getMessage());
            throw e;
        } catch (Exception e) {
            LOGGER.error('CMN_FHQ_Dashboard.getAssessmentScores Exception: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred while retrieving assessment scores.');
        }
    }

    /***************************************************************************************
     * @description Retrieves all CMN_Question_Response__c records linked to the latest
     *              CMN_Assessment__c for the given Lead.
     *              Returns title, answer, responseValueNumber, category and sequence
     *              so the LWC can group, order and apply conditional logic dynamically.
     * @param recordId  Salesforce Record ID of the Lead record.
     * @return          List of QuestionAnswerWrapper ordered by sequence.
     ***************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static List<QuestionAnswerWrapper> getQuestionResponses(String recordId) {
        try {
            if (String.isBlank(recordId)) {
                throw new AuraHandledException('Record ID cannot be empty.');
            }
            
            UserIdentifier identifier = getLeadUserIdentifier(recordId);
        if (identifier == null) {
            throw new AuraHandledException('No Lead found or both Source_System_Reference__c and ID_Number__c are empty.');
        }
            SEL_CMNAssessment assessmentSelector = new SEL_CMNAssessment();
            CMN_Assessment__c assessment = identifier.isSourceSystemRef
            ? assessmentSelector.selectLatestByUserId(identifier.value)
            : assessmentSelector.selectLatestByIdNumber(identifier.value);

            if (assessment == null) {
                return new List<QuestionAnswerWrapper>();
            }
            SEL_CMNQuestionResponse responseSelector = new SEL_CMNQuestionResponse();
            List<CMN_Question_Response__c> responses = responseSelector.selectByAssessmentId(assessment.Id);

            List<QuestionAnswerWrapper> result = new List<QuestionAnswerWrapper>();
            for (CMN_Question_Response__c resp : responses) {
                QuestionAnswerWrapper wrapper  = new QuestionAnswerWrapper();
                wrapper.title                  = resp.CMN_Question_Text__c;
                wrapper.answer                 = resp.CMN_Response_Value__c;
                if (resp.CMN_Response_Value_Number__c == null) {
                    wrapper.responseValueNumber = null;
                } else {
                    wrapper.responseValueNumber = String.valueOf(resp.CMN_Response_Value_Number__c.intValue());
                }
                wrapper.category               = resp.CMN_Category__c;
                if (resp.CMN_Sequence__c == null) {
                    wrapper.sequence = 0;
                } else {
                    wrapper.sequence = resp.CMN_Sequence__c.intValue();
                }
                result.add(wrapper);
            }
            return result;

        } catch (AuraHandledException e) {
            LOGGER.error('CMN_FHQ_Dashboard.getQuestionResponses AuraHandledException: ' + e.getMessage());
            throw e;
        } catch (Exception e) {
            LOGGER.error('CMN_FHQ_Dashboard.getQuestionResponses Exception: ' + e.getMessage());
            throw new AuraHandledException('An unexpected error occurred while retrieving question responses.');
        }
    }
    
    /***************************************************************************************
 * @description Small holder so callers know which field the returned value came from,
 *              allowing them to call the correct selector method.
 ***************************************************************************************/
private class UserIdentifier {
    String value;
    Boolean isSourceSystemRef; 

    UserIdentifier(String value, Boolean isSourceSystemRef) {
        this.value = value;
        this.isSourceSystemRef = isSourceSystemRef;
    }
}

/***************************************************************************************
 * @description Retrieves a user identifier from the Lead record.
 *              First attempts Source_System_Reference__c; falls back to ID_Number__c.
 * @param recordId  Lead record ID.
 * @return          UserIdentifier with the value and its source field, or null if neither found.
 ***************************************************************************************/
private static UserIdentifier getLeadUserIdentifier(String recordId) {
    
    Lead leadRecord = new SEL_Lead().selectById(recordId);
    if (leadRecord != null && 
        String.isNotBlank(leadRecord.Source_System_Reference__c)) {
        return new UserIdentifier(
            leadRecord.Source_System_Reference__c, 
            true
        );
    }

    if (leadRecord != null && 
        String.isNotBlank(leadRecord.ID_Number__c)) {
        return new UserIdentifier(
            leadRecord.ID_Number__c, 
            false
        );
    }

    return null;
}
    /**
     * @description Safely converts a Decimal score field to an Integer, clamped 0-100.
     */
    private static Integer toIntScore(Decimal value) {
        if (value == null) {
            return 0;
        }
        Integer intVal = value.intValue();
        if (intVal > 100) {
            return 100;
        }
        if (intVal < 0) {
            return 0;
        }
        return intVal;
    }

    /***************************************************************************************
     * @description Wrapper class returned by getAssessmentScores().
     ***************************************************************************************/
    public class AssessmentScoreWrapper {
        @AuraEnabled public Integer overallScore       { get; set; }
        @AuraEnabled public Integer expensesScore      { get; set; }
        @AuraEnabled public Integer insuranceScore     { get; set; }
        @AuraEnabled public Integer emergencyFundScore { get; set; }
        @AuraEnabled public Integer debtScore          { get; set; }
        @AuraEnabled public Integer retirementScore    { get; set; }
    }

    /***************************************************************************************
     * @description Wrapper class returned by getQuestionResponses().
     *   title               = CMN_Question_Text__c
     *   answer              = CMN_Response_Value__c
     *   responseValueNumber = CMN_Response_Value_Number__c (integer as String)
     *   category            = CMN_Category__c
     *   sequence            = CMN_Sequence__c (integer)
     ***************************************************************************************/
    public class QuestionAnswerWrapper {
        @AuraEnabled public String  title               { get; set; }
        @AuraEnabled public String  answer              { get; set; }
        @AuraEnabled public String  responseValueNumber { get; set; }
        @AuraEnabled public String  category            { get; set; }
        @AuraEnabled public Integer sequence            { get; set; }
    }
}