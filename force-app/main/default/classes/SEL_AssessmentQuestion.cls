/**
 * @description                 : Selector Class for AssessmentQuestion
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 20-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_AssessmentQuestion extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries 
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return AssessmentQuestion.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AssessmentQuestion.Id,
            AssessmentQuestion.Name,
            AssessmentQuestion.QuestionText,
            AssessmentQuestion.Description,
            AssessmentQuestion.DeveloperName,
            AssessmentQuestion.DataType,
            AssessmentQuestion.QuestionCategory,
            AssessmentQuestion.RelatedQuestionId,
            AssessmentQuestion.ActiveVersionId,
            AssessmentQuestion.Namespace,
            AssessmentQuestion.UniqueIndex
            };
    }    

    /**
     * @description Select by Id
     * @param Id
     * @return AssessmentQuestion
     */
    public AssessmentQuestion selectById(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select Assessment question based on Ids
     * @param set of ids
     * @return assesssment question records
     */
    public List<AssessmentQuestion> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id in :ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Select Assessment question by developer names
     * @param Set of string with developer names
     * @return Assessment question records
     */
    public List<AssessmentQuestion> selectByDeveloperNames(Set<String> developerNames) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('DeveloperName in :developerNames');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by ActiveVersionIds
     * @param Set of Id with ActiveVersionIds
     * @return Assesssment question records
     */
    public List<AssessmentQuestion> selectByActiveVersionIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('ActiveVersionId in :ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
     /**
     * @description Select AssessmentQuestions based on names
     * @param Set of Strings with names of AssessmentQuestion records
     * @return assesssment question records
     */
    public List<AssessmentQuestion> selectByNames(Set<String> names) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Name in :names');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}