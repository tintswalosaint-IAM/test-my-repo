/**
* @Name of the Class : SEL_AssesmentQuestionResponse      
* @description       : SFP-37439 Selector Class for AssesmentQuestionResponse Entity 
* @author            : Ikyatha Naidu
* @last modified on  : 22-10-2024
* @last modified by  : Tushar Walse
* @Modification Description : updated to latest version  
**/
public inherited sharing class SEL_AssesmentQuestionResponse extends sbgplatform.fflib_SObjectSelector{  
    
    private static Set<String> fields = new Set<String>{   
        'id',  
            'OwnerId',  
            'Name',
            'AssessmentId',
            'AssessmentQuestionId',
            'AssessmentQuestion.Name',
            'AssessmentQuestion.AssessmentQuestionId',
            'AssessmentQuestion.QuestionText', 
            'ResponseText',
            'ResponseValue',
            'ResponseType',
            'IsTrueOrFalseValue',
            'IntegerResponseValue',
            'ChoiceValue',
            'LastModifiedDate',
            'Assessment.ContactId',
            'Assessment.AccountId',
            'Assessment.Type',
            'Assessment.PartyProfileId'
            };
                
                /**
* This is used to retrieve the sObject name when building the SOQL
* queries.
*
* @return the SObject type for the selector.
*/
                public override Schema.SObjectType getSObjectType(){
                    return AssessmentQuestionResponse.SObjectType;
                }
    
    /**
* This is used to retrieve a specific set of SObject fields
*
* @return List of SObjectField
*/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            AssessmentQuestionResponse.Id,
                AssessmentQuestionResponse.Name,
                AssessmentQuestionResponse.AssessmentId, 
                AssessmentQuestionResponse.AssessmentQuestionId,
                AssessmentQuestionResponse.AssessmentQuestion.Name,
                AssessmentQuestionResponse.ResponseText,
                AssessmentQuestionResponse.ResponseValue,
                AssessmentQuestionResponse.ResponseType,
                AssessmentQuestionResponse.IsTrueOrFalseValue,
                AssessmentQuestionResponse.IntegerResponseValue,
                AssessmentQuestionResponse.ChoiceValue,
                AssessmentQuestionResponse.OwnerId,
                AssessmentQuestionResponse.AssessmentQuestion.AssessmentQuestionId,
                AssessmentQuestionResponse.LastModifiedDate
                };
                    }
    
    /**
* @description Select AssessmentQuestionResponse by on Account Id
* @param parentId Id of the Account of Assessment of AssessmentQuestionResponse
* @return AssessmentQuestionResponse
*/
    public List<AssessmentQuestionResponse> selectByParentId(String parentId) {
        SEL_Assesment selectorAssesmentData = new SEL_Assesment();
        List<Assessment> assesDataInfo = selectorAssesmentData.SelectByAccountId(parentId);
        if(assesDataInfo.size()>0) {
            string asses = assesDataInfo[0].id;
            if(asses == null){
                return null;
            }
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('AssessmentId =: asses');
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
        }else{
            return null;
        }
    }
    
    /**
* @description fetch assessment responses based on set of assessment ids
* @param set of assessment ids
* @return list of assessmentQuestionResponse
*/
    public List<AssessmentQuestionResponse> selectByAssessmentIds(Set<Id> assessmentIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AssessmentId in :assessmentIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
* @description fetch assessment responses based on sectionName and parentId
* @param set of assessment ids
* @return list of assessmentQuestionResponse
*/
    public List<AssessmentQuestionResponse> selectByParentIdAndSectionName(String parentId,string sectionName) {
        SEL_Assesment selectorAssesmentData = new SEL_Assesment();
        List<Assessment> assesDataInfo = selectorAssesmentData.SelectByAccountId(parentId);
        
        if(assesDataInfo.size()>0) {
            string asses = assesDataInfo[0].id;
            if(asses == null){
                return null;
            }
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('AssessmentId =: asses and Name=:sectionName');
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
            
        }else{
            return new List<AssessmentQuestionResponse>();
        }
    }
    public List<AssessmentQuestionResponse> selectByParentIdAndSectionNameAndAssesmentName(String parentId,string sectionName,string assementName) {       
        SEL_Assesment selectorAssesmentData = new SEL_Assesment();
        List<Assessment> assesDataInfo = selectorAssesmentData.selectByParentIdAndSectionName(parentId,assementName);
        
        if(assesDataInfo.size()>0) {
            string asses = assesDataInfo[0].id;
            if(asses == null){
                return null;
            }
            sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
            fieldQueryFactory.setCondition('AssessmentId =: asses and Name=:sectionName');
            fieldQueryFactory.selectFields(fields);
            String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
            return Database.query(query);
            
        }else{
            return new List<AssessmentQuestionResponse>();
        }
    }
    
    /**
* @description Select AssessmentQuestionResponse by Name and AccountId of Assessment
* @author Tushar Walse | 22-10-2024 
* @param accountId Id of Account of Assessment of AssessmentQuestionResponse
* @param name Name field value of AssessmentQuestionResponse
* @return List<AssessmentQuestionResponse> 
**/
    public List<AssessmentQuestionResponse> selectByAccountIdAndName(String accountId, String name) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Assessment.AccountId =: accountId and Name =: name');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.addOrdering('Assessment.LastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
* @description Select AssessmentQuestionResponse by Name and AccountId of Assessment
* @author Jogarao B | 29-01-2025 
* @param accountId Id of Account of Assessment of AssessmentQuestionResponse
* @param name Name sectionName
* @return List<AssessmentQuestionResponse> 
**/
    public List<AssessmentQuestionResponse> selectByAccountIdAndName(String accountId, List<String> name) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Assessment.AccountId =: accountId and Name =: name');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.addOrdering('Assessment.LastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
* @description fetch assessment responses based on set of assessment Names
* @param list of assessment question names
* @return list of assessmentQuestionResponse
*/
    public List<AssessmentQuestionResponse> selectByAssessmentNames(List<String> assessmentQuestionNames) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AssessmentQuestion.Name in :assessmentQuestionNames');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
* @description Select AssessmentQuestionResponse by assessmentQuestionName and AccountId of Assessment
* @author Tushar Walse | 22-10-2024
* @param accountId Id of Account of Assessment of AssessmentQuestionResponse
* @param name Name field value of AssessmentQuestionResponse
* @return List<AssessmentQuestionResponse>
**/
    public List<AssessmentQuestionResponse> selectByAccountIdAndAssessmentName(String accountId, String name) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Assessment.AccountId =: accountId and AssessmentQuestion.Name =: name');
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.addOrdering('Assessment.LastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
* @description fetch assessment responses based on set of Parent Ids
* @param PartyProfileId
* @return PartyProfileId
*/
    public List<AssessmentQuestionResponse> selectByParentIds(Id PartyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Assessment.PartyProfileId =:PartyProfileId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
}