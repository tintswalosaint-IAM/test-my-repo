/**
* @Name of the Class : SEL_ApplicationForm
* @description       : SFP-31898 Selector Class for ApplicationForm Entity
* @author            : Ofentse Sacha
* @date   24/11/2023
* @last modified on  : 01/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : class used for ApplicationForm Entity, updated to prevent SOQL injection
 * ***************************************************************************************
* @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 18-03-2025
* @Modification description : SFP-55521 updated for join account
***************************************************************************************
**/
public without sharing class SEL_ApplicationForm extends sbgplatform.fflib_SObjectSelector {
    private static Set<String> fields = new Set<String>{
      	 'Name', 'Id', 'OpportunityId', 'UsageType', 'Enhanced_Due_Diligence_Required__c', 'CreatedDate',
        'Section_Name__c', 'AccountId', 'OwnerId', 'Account.FirstName', 'stage','Account.Ping_Id__pc','Account.PersonBirthdate',
        'Account.LastName', 'Account.Name','Account.persontitle', 'WorldcheckStatus__c', 'On_hold_reason__c',
        'Opportunity.StageName', 'Opportunity.LastModifiedDate', 'Opportunity.CreatedDate','Opportunity.AccountId',
        'LastModifiedDate', 'Opportunity.IsWon', 'Opportunity.IsClosed','Account.PersonEmail', 'Account.ExternalCIFId__c',
        'Opportunity.Required_Approval_Processes__c','Account.ExternalSystemId__c','Account.ExternalCIFCountry__c'
    };


    /**
    * @description Implementation method for ApplicationForm Object as part of fflib framework
    * @author Ikyatha Naidu | 30-10-2023
    * @return Schema.SObjectType
    **/
    public override Schema.SObjectType getSObjectType() {
        return ApplicationForm.sObjectType;
    }

    /**
    * @description Method to get list of fields to be part of response
    * @author Ikyatha Naidu| 05-31-2023
    * @return List<Schema.SObjectField>
    **/
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ApplicationForm.Name,
            ApplicationForm.OpportunityId,
                ApplicationForm.Section_Name__c
        };
    }

    /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param accountId
    * @return List of ApplicationForm records
    **/
    public List<ApplicationForm> selectByAccountId(Id accountId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountId == null){
           return null;
        }else{
          fieldQueryFactory.setCondition('AccountId = :accountId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param accountIds
    * @return List of ApplicationForm records
    **/
    public List<ApplicationForm> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountIds == null){
            return null;
        }else{
          fieldQueryFactory.setCondition('AccountId IN :accountIds');
        }
            fieldQueryFactory.selectFields(fields);
			String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
       		return Database.query(query);
    }

    /**
    * @description Method to fetch ApplicationForm based on Application Form ID
    * @param appFormID The ID value (recordId or AccountId).
    * @param useappFormID Boolean for AccountId or recordId
    * @return ApplicationForm
    **/
    public ApplicationForm selectById(Id appFormID, Boolean useAppFormID) {
         String fieldName = useAppFormID ? 'Id' : 'AccountId';
         sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(appFormID == null){
            return null;
        }else{
            fieldQueryFactory.setCondition(fieldName + ' = :appFormID');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch ApplicationForm based on a set of Application Form IDs or Account IDs
     * @param appFormIDs The set of IDs (recordId or AccountId).
     * @param useAppFormIDs Boolean indicating whether to use Application Form IDs (true) or Account IDs (false).
     * @return List<ApplicationForm>
     **/
    public List<ApplicationForm> selectByIds(List<Id> appFormIDs, Boolean useAppFormIDs) {
                String fieldName = useAppFormIDs ? 'Id' : 'AccountId';
       sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(appFormIDs == null){
            return null;
        }else{
            fieldQueryFactory.setCondition(fieldName + ' IN : appFormIDs');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);

    }

    /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param oppID
    * @return List ApplicationForm
    **/
    public List<ApplicationForm> selectByOpportunityId(Id oppID) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
    
        if(oppID == null){
            return null;
        }else{
         fieldQueryFactory.setCondition('OpportunityId = :oppID');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Method to fetch list of ApplicationForm based on Opportunity IDs
     * @param opportunityIds List of Opportunity IDs
     * @return List<ApplicationForm> List of ApplicationForm records
     **/
    public List<ApplicationForm> selectByOpportunityIds(List<Id> opportunityIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(opportunityIds == null){
            return null;
        }else{
           fieldQueryFactory.setCondition('OpportunityId IN :opportunityIds');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);

    }

    /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param idsDisplayed List of IDs to display
    * @param recordsNum Number of records to retrieve
    * @param status Opportunity stage name
    * @return List ApplicationForm
    **/
    public List<ApplicationForm> selectByOpportunityStage(List<Id> idsDisplayed, Integer recordsNum, String status) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(status == null){
            return null;
        }else{
           fieldQueryFactory.setCondition('Opportunity.StageName = :status');
        }
        fieldQueryFactory.selectFields(fields);
        fieldQueryFactory.setLimit(recordsNum);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param idsDisplayed List of IDs to display
    * @param recordsNum Number of records to retrieve
    * @param status Opportunity stage name
    * @return List ApplicationForm
    **/
    public List<ApplicationForm> selectByOwnerId(string userId) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, false);
        queryFactory.selectFields(fields);
        queryFactory.setCondition('Owner.Id = :userId');

        String safeQuery = String.escapeSingleQuotes(queryFactory.toSOQL());
        return (List<ApplicationForm>) Database.query(safeQuery);
    }

     /**
    * @description Method to fetch list of ApplicationForm based on Parameters
    * @param idsDisplayed List of IDs to display
    * @param recordsNum Number of records to retrieve
    * @param status Opportunity stage name
    * @return List ApplicationForm
    **/
    public List<ApplicationForm> selectByAccountExternalCIFIdNull(string userId) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, false);
        queryFactory.selectFields(fields);
        queryFactory.setCondition('Account.ExternalCIFId__c = null');

        String safeQuery = String.escapeSingleQuotes(queryFactory.toSOQL());
        return (List<ApplicationForm>) Database.query(safeQuery);
    }

    public ApplicationForm selectById(Id formId) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, false);
        queryFactory.selectFields(fields);
        queryFactory.setCondition('Id = :formId');

        String safeQuery = String.escapeSingleQuotes(queryFactory.toSOQL());
        List<ApplicationForm> results = Database.query(safeQuery);

        return results.isEmpty() ? null : results[0];
    }

    public List<ApplicationForm> selectByOpportunityId(Set<Id> opportunityId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(true, false, false);
        fieldQueryFactory.setCondition('OpportunityId IN:opportunityId');
        fieldQueryFactory.selectFields(fields);
        List<String> subQueryFields = new List<String>{ 'Id',
            'Role',
            'PartyProfileId',
            'PartyProfile.Country_of_Nationality__c',
            'PartyProfile.PrimaryIdentifier',
            'AccountId',
            'PartyProfile.WI_PassportValidTo__c',
            'PartyProfile.WI_PassportValidFrom__c',
            'PartyProfile.WI_VisaPermitExpiryDate__c',
            'Account.FirstName',
            'Account.LastName',
            'Account.PersonBirthdate',
            'Account.ExternalCIFId__c'};
        fieldQueryFactory.subselectQuery('Applicants').selectFields(subQueryFields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    public List<ApplicationForm> selectByFirstandLastNameandBirth(Set<String> firstName,Set<String> surName,set<Date> PersonBirthdate) {
        sbgplatform.fflib_QueryFactory queryFactory = newQueryFactory(false, false, false);
        queryFactory.selectFields(fields);
        queryFactory.setCondition('Account.FirstName In: firstName and Account.lastName In: surName and Account.PersonBirthdate In: PersonBirthdate');
        String safeQuery = String.escapeSingleQuotes(queryFactory.toSOQL());
        return (List<ApplicationForm>) Database.query(safeQuery);
    }
}