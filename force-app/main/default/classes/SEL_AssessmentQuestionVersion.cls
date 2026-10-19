/**
 * @description                 : Selector Class for AssessmentQuestionVersion
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 16-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_AssessmentQuestionVersion extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return AssessmentQuestionVersion.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AssessmentQuestionVersion.Id,
            AssessmentQuestionVersion.Name,
            AssessmentQuestionVersion.AssessmentQuestionId,
            AssessmentQuestionVersion.QuestionText,
            AssessmentQuestionVersion.DataType,
            AssessmentQuestionVersion.Description
        };
    }    

    /**
     * @description Select by Id
     * @param id
     * @return AssessmentQuestionVersion
     */
    public AssessmentQuestionVersion selectById(Id id) {
        return selectByIds(new Set<Id>{id})[0];
    }
    
    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<AssessmentQuestionVersion>
     */
    public List<AssessmentQuestionVersion> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}