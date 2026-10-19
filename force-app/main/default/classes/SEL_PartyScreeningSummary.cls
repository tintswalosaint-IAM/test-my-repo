/**
* @description Selector layer class for PartyScreeningSummary SObject
* @author Ofentse Sacha
* @date 2024-01-18
* Last Modified by Irshad on 2025-08-29: selectBysetpartyProfileIds was updated first param with false;
*/
public inherited sharing class SEL_PartyScreeningSummary  extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description fields to retrieve.   
     */    
    private static Set<String> fields = new Set<String>{    
        'Id', 'Name', 'RankScore__c', 'RankValue__c', 'Status', 'IsPEP__c', 'IsAdverseMedia__c' , 'IsBlacklist__c', 'IsReviewed__c', 'PartyProfile.Account.PersonContactId', 'PartyProfile.PrimaryIdentifier', 'PartyProfile.Account.Name', 'PartyProfile.Account.Id',
        'IsSanctioned__c', 'IsUncategorised__c', 'IsWatchlist__c', 'CategoryDescription__c', 'CreatedBy.Name', 'Information__c', 'BirthPlace__c', 'PartyProfileId',
        'Subcategory__c', 'SubcategoryDescription__c', 'ScreeningMatchKey__c', 'Risk_Rating__c', 'RequestCompletionDate', 'RecordTypeId', 'BirthdateList__c', 'keywordList__c', 'ExternalSourceList__c', 'LinkedEntityList__c', 'CompanyList__c', 'LocationList__c', 'AliasList__c','ThirdPartySreeningIdentifier',
        'CitizenshipList__c', 'ScreeningMatchPosition__c', 'ScreeningMatchCategory__c', 'NameList__c', 'FinscanCategoryList__c'
    };
 
        
    /**
     * @description Retrieves the SObjectType for PartyScreeningSummary.
     * @return The SObjectType for PartyScreeningSummary
     */
    public override Schema.SObjectType getSObjectType() {
        return PartyScreeningSummary.SObjectType;
    }
 
    /**
     * @description Retrieves the list of SObjectFields for PartyScreeningSummary.
     * @return The list of SObjectFields for PartyScreeningSummary
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
 
    /**
     * @description Set default sort ordering, get latest
    * @return Default order
    **/
    public override String getOrderBy(){
        return 'CreatedDate DESC';
    }
 
     /**
     * @description Select by Id
     * @param id
     * @return PartyScreeningSummary
     */
    public PartyScreeningSummary selectById(String recordId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('Id = :recordId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
      
    }
 
    /**
     * @description Select by Party profile Ids
     * @param partyProfileId
     * @return List of PartyScreeningSummary
     */
    public List<PartyScreeningSummary> selectListBypartyProfileId(Id partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
 
    /**
     * @description Select by Party profile Ids
     * @param partyProfileIds
     * @return List of PartyScreeningSummary
     */
    public List<PartyScreeningSummary> selectBysetpartyProfileIds(Set<Id> partyProfileIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId IN :partyProfileIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
 
    /**
     * @description Method to retrieve list of PartyScreeningSummary with relationship PartyScreeningSteps records
     * @param id The ID value  recordId.
     * @return List of PartyScreeningSummary object by Id
     */
    public List<PartyScreeningSummary> selectByIdWithPartyScreeningSteps(Id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('Id =:id');
        fieldQueryFactory.selectFields(fields);
        List<String> subQueryFields = new List<String>{
            'Id', 'Name', 'Status', 'ScreeningMatchCategory__c', 'OutcomeChallengeDate__c', 'Comments__c', 'OutcomeConfirmationDate__c', 'isWeakStatus__c', 'ScreeningSummaryId',
            'Reason__c', 'SubReason__c', 'ResponseCodeComment', 'Temp_Source_Id__c', 'Type', 'CreatedDate', 'CreatedById', 'CreatedBy.Name', 'CreatedBy.Username',
            'LastModifiedById', 'LastModifiedDate'
        };
        fieldQueryFactory.subselectQuery('PartyScreeningSteps').selectFields(subQueryFields);
        fieldQueryFactory.setOrdering('RankScore__c', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Method to retrieve list of PartyScreeningSummary with relationship PartyScreeningSteps records
     * @param partyProfileId The ID value partyProfile
     * @param usePartyProfileId Boolean flag to determine which field to use for filtering.
     * @return List of PartyScreeningSummary object by Id
     */
    public List<PartyScreeningSummary> selectByPartyProfileIdWithPartyScreeningSteps(Id partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('PartyProfileId =:partyProfileId');
        
        fieldQueryFactory.selectFields(fields);
        List<String> subQueryFields = new List<String>{
            'Id', 'Name', 'Status', 'ScreeningMatchCategory__c', 'OutcomeChallengeDate__c', 'Comments__c', 'OutcomeConfirmationDate__c', 'isWeakStatus__c', 'ScreeningSummaryId',
            'Reason__c', 'SubReason__c', 'ResponseCodeComment', 'Temp_Source_Id__c', 'Type', 'CreatedDate', 'CreatedById', 'CreatedBy.Name', 'CreatedBy.Username',
            'LastModifiedById', 'LastModifiedDate'
        };
        fieldQueryFactory.subselectQuery('PartyScreeningSteps').selectFields(subQueryFields);
        fieldQueryFactory.setOrdering('RankScore__c', sbgplatform.fflib_QueryFactory.SortOrder.DESCENDING);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
      
    /**
    * @description Method to fetch Party Screening Summary on Party Profile Ids and active
    * @author Nagendra Mylavarapu | 18-Mar-2024
    * @param partyProfileId
    * @return PartyScreeningSummary
    **/
    public PartyScreeningSummary selectByPartyProfileIdandStatus(String partyProfileId,String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('PartyProfileId = :partyProfileId And Status = :status');
        fieldQueryFactory.selectFields(fields);
        String query = fieldQueryFactory.toSOQL();    
        return Database.query(query);
    }
    /**
        * @description Method to fetch partyScreeningsummary based on Parameters
        * @param partyProfileId
     * @return PartyScreeningSummary
     **/
    public PartyScreeningSummary selectByPartyProfileId(Id partyProfileId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('PartyProfileId =:partyProfileId');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    
    /**
     * @description Method to fetch partyScreeningsummary based on Parameters
     * @param partyScreeningIds
     * @return List of PartyScreeningSummary
     **/
    public List<PartyScreeningSummary> selectByIds(Set<Id> partyScreeningIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('Id IN :partyScreeningIds');
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
}