/**
* @Name of the Class : SEL_Assesment
* @description       : SFP-37439 Selector Class for Assesment Entity
* @author            : Ikyatha Naidu
* @date 10-09-2023
* @last modified on  : 15-11-2024
* @last modified by  : Jogarao Bevara
* @Modification Description : updated to latest version
**/
public inherited sharing class SEL_Assesment extends sbgplatform.fflib_SObjectSelector{

    /**
     * This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public override Schema.SObjectType getSObjectType(){
        return Assessment.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Assessment.Id,
            Assessment.Name,
            Assessment.AccountId,
            Assessment.LastModifiedDate,
            Assessment.AssessmentStatus, 
            Assessment.ContactId
        };
    }
    
    /**
     * @description Select Assessment based on AccountId
     * @param accountId Id of the account whose Assessment is to be retrieved
     * @return Assessment
     */
    public List<Assessment> selectByAccountId(id accountId) {
        return selectByAccountIds(new Set<Id> {accountId});
    }

    /**
     * @description Select Assessment based on AccountId
     * @param accountId Id of the account whose Assessment is to be retrieved
     * @return Assessment
     */
    public List<Assessment> selectByParentId(String accountId) {
        return selectByAccountId(accountId);
    }

    /**
     * @description Select Assessment based on AccountId
     * @param accountIds Ids of the accounts whose Assessments are to be retrieved
     * @return Assessment
     */
    public List<Assessment> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId in :accountIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        fieldQueryFactory.addOrdering('LastModifiedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select Assessment based on accountId and sectionName
     * @param accountId
     * @param sectionName
     * @return Assessment
     */
    public List<Assessment> selectByParentIdAndSectionName(String accountId, string sectionName) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('accountId =: accountId and Name =: sectionName'); 
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        fieldQueryFactory.addOrdering('CreatedDate', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
       String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select Assessment by AccountId Or ContactId
     * @param accountIds
     * @param contactIds
     * @return Assessment
     */
    public List<Assessment> selectByAccountIdOrContactId(set<id> accountIds, list<id> contactIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('AccountId =: accountIds OR ContactId =: contactIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

     /**
     * @description Select Assessment by Ids
     * @param assesmentIds set of assessment ids
     * @return Assessment
     */
    public List<Assessment> selectByIds(set<id> assesmentIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: assesmentIds'); 
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

}