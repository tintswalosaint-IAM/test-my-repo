/**
 * @description             : Selector Class for Opportunity Entity
 * @story                   : SFP-36380
 * @author                  : Ikyatha Naidu
 * @created date            : 2023-11-08
 * @last modified date      : 2025-01-02
 * @last modified by        : Irshad Alam
 * @modification details    : SFP-36380: Used new field Signing Arrangement SBO UK
 *                          : SFP-51839: Added Quote_Id__c field to the fields set
 * 
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 18-06-2026                  
 * @modification details	: SFP-57387: Added Sales_Code__r.Sales_Code_Country__c to
 *                          : the selector field set to support sector classification
 *                          : derivation in SAP Create Customer integration.
 * 
 * @Last Modified By 	    : Shams
 * @Last Modified On 		: 24-07-2026                  
 * @modification details	: SFP-59435: Added additional method to query by OpportunityId
 */
@SuppressWarnings('PMD.AvoidDuplicateLiterals, PMD.TooManyMethods, PMD.UnusedLocalVariable')
public inherited sharing class SEL_Opportunity extends sbgplatform.fflib_SObjectSelector {
    /**
    * @description declaration of fields
    */
    private static Set<String> fields = new Set<String>{
            'id',
            'Name',
            'accountId',
            'stageName',
            'INS_OnboardingStep__c',
            'iswon',
            'isClosed',
            'ICS_Decline_Reason__c',
            'Loss_Reason__c',
            'LeadSource',
            'CloseDate',
            'Other_Loss_Reason__c',
            'ICS_Other_Competitor__c',
            'Owner.Name',
            'CurrencyIsoCode',
            'Owner.ContactId',
            'Account.PersonContact.Id',
            'Sales_Code__c',
            'Sales_Code__r.Sales_Code_Country__c',
            'Required_Approval_Processes__c',
            'Queue__c',
            'ICS_RM_Sales_Code__c',
            'RecordTypeId',
            'Account.Name',
            'Owner.Email',
            'Required_Approval_Processes__c',
            'Quote_Id__c',
            'Account.Gross_Income__c',
            'Total_Cover_Amount__c',
            'Total_Monthly_Premium__c'
    };

    /**
    * @description This is used to retrieve the sObject name when building the SOQL queries
    * @return Schema.SObjectType
    */
    public override Schema.SObjectType getSObjectType(){
        return Opportunity.SObjectType;
    }

    /**
    * @description This is used to retrieve a specific set of SObject fields
    * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Opportunity.Id,
                Opportunity.Name,
                Opportunity.accountId,
                Opportunity.stageName,
                Opportunity.ICS_Decline_Reason__c,
                Opportunity.Loss_Reason__c,
                Opportunity.LeadSource,
                Opportunity.Required_Approval_Processes__c,
                Opportunity.Total_Monthly_Premium__c,
                Opportunity.Total_Cover_Amount__c
        };
    }

    /**
    * @description Select by Id for SBO-UK Project
    * @param accId
    * @return List<Opportunity>
    */
    public List<Opportunity> selectByAccountId(Id accId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accId == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId = :accId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Select by Id for SBO-UK Project
    * @param accId
    * @return List<Opportunity>
    */
    public Opportunity selectOpportunityByAccountId(Id accId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accId == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId = :accId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
    * @description Select by Id for SBO-UK Project
    * @param oppId
    * @return Opportunity
    */
    public Opportunity selectById(Id oppId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(oppId == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('Id = :oppId');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by Id for SBO-UK Project
    * @param accountIds
    * @return List<Opportunity>
    */
    public List<Opportunity> selectByAccountIds(Set<Id> accountIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(accountIds == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('accountId IN :accountIds');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by Id for SBO-UK Project
    * @param ids
    * @return List<Opportunity>
    */
    public List<Opportunity> selectByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        if(ids == null){
            return null;
        }else{
            fieldQueryFactory.setCondition('Id IN :ids');
        }
        fieldQueryFactory.selectFields(fields);
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Select by Opportunity ids using a minimal field set
    * @param ids
    * @return List<Opportunity>
    */
    public List<Opportunity> selectCloseDateByIds(Set<Id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        if (ids == null) {
            return null;
        } else {
            fieldQueryFactory.setCondition('Id IN :ids');
        }
        fieldQueryFactory.selectFields(new List<String>{ 'Id', 'CloseDate', 'StageName' });
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
    * @description Calls method selectCloseDateByIds in without sharing context
    * 'WoSharing' stands for 'Without Sharing'
    * @author Shams
    * @param ids list of opportunity ids
    *
    * @return list of opportunities
    */
    public List<Opportunity> selectCloseDateByIdsWoSharing(Set<Id> ids) {
        return new NoOpportunitySharing().selectCloseDateByIds(this, ids);
    }
    /**
    * @description Calls method selectByIdsWoSharing in without sharing context
    * 'WoSharing' stands for 'Without Sharing'
    * @author Shams
    * @param ids list of opportunity ids
    *
    * @return list of opportunities
    */
    public List<Opportunity> selectByIdsWoSharing(Set<Id> ids) {
        return new NoOpportunitySharing().selectByIds(this, ids);
    }

    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class NoOpportunitySharing {
        /**
        * @description Returns list of opportunities by ids without sharing
        *
        * @param selOpportunity SEL_Opportunity selector instance
        * @param ids Set<Id> list of opportunity ids
        *
        * @return list of selected opportunities
        */
        public List<Opportunity> selectCloseDateByIds(SEL_Opportunity selOpportunity, Set<Id> ids) {
            return selOpportunity.selectCloseDateByIds(ids);
        }
        /**
        * @description Select by Id for SBO-UK Project
        * @param ids
        * @return List<Opportunity>
        */
        public List<Opportunity> selectByIds(SEL_Opportunity selOpportunity, Set<Id> ids) {
            return selOpportunity.selectByIds(ids);  
        }
    }

    /**
    * @author Dhriven Hamlall | 7-11-2024
    * @description Retrieves Opportunity Id by Lead Id
    * @param leadId
    * @return Id of the related Opportunity or null if not found
    */
    public Id getOpportunityIdByLeadId(Id leadId) {
        if (leadId == null) {return null;}

        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Lead__c = :leadId');
        fieldQueryFactory.selectFields(new Set<String>{ 'Id', 'Name' });

        String query = fieldQueryFactory.toSOQL();
        List<Opportunity> oppList = Database.query(query);

        if (oppList == null || oppList.isEmpty()) {
            return null;
        } else {
            return oppList[0].Id;
        }
    }

    /**
    * @author Dhriven Hamlall | 7-11-2024
    * @description Retrieves an Opportunity of record type General by Lead Id,StageName not 'Closed Won' or 'Closed Lost' with a specific name pattern
    * @param leadId
    * @return Opportunity record or null if not found
    */
    public Opportunity getOpenOpportunityByLeadId(Id leadId,String recordTypeName,String namePattern) {
        if (leadId == null) {return null;}
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        fieldQueryFactory.setCondition('Lead__c = :leadId AND StageName NOT IN (\'Closed Won\', \'Closed Lost\') AND RecordTypeId=:recTypeId AND Name Like:namePattern');
        fieldQueryFactory.selectFields(new Set<String>{ 'Id', 'Name' });
        List<Opportunity> oppList = Database.query(fieldQueryFactory.toSOQL());
        if (oppList.isEmpty()) {
            return null;
        } else {
            return oppList[0];
        }
    }

    /**
    * @author Dhriven Hamlall | 7-11-2024
    * @description Retrieves an Opportunity by Account Id where StageName is not 'Closed Won' or 'Closed Lost' with a specific name pattern
    * @param leadId
    * @return Opportunity record or null if not found
    */
    public Opportunity getOpenOpportunityByAccountId(String accountId,String recordTypeName,String namePattern) {
        if (accountId == null) {return null;}
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        fieldQueryFactory.setCondition('AccountId =:accountId AND StageName NOT IN (\'Closed Won\', \'Closed Lost\') AND RecordTypeId=:recTypeId AND Name Like:namePattern');
        fieldQueryFactory.selectFields(new Set<String>{ 'Id', 'Name','StageName' });
        List<Opportunity> oppList = Database.query(fieldQueryFactory.toSOQL());
        if (oppList.isEmpty()) {
            return null;
        } else {
            return oppList[0];
        }
    }

    /**
     * Method to fetch list of QuoteSobject based on Quote names or ids
     * @author Michal Orawiec | 14-10-2025
     * @param quoteIds Listo of ids
     * @return List<Quote>
     */
    public List<Opportunity> selectBySalesEvent(List<String> salesEvents) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory();
        fieldQueryFactory.selectFields(new List<String>{'Id','AccountId','Quote_Id__c'});
        fieldQueryFactory.setCondition('Quote_Id__c IN :salesEvents');
        return Database.query(fieldQueryFactory.toSOQL());
    }

}