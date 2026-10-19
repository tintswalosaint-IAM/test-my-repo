/**
 * @description                 : Selector Class for TaxDetails
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 20-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_TaxDetails extends sbgplatform.fflib_SObjectSelector {
    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return TaxDetails__c.SObjectType;
    }

    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            TaxDetails__c.Id,
            TaxDetails__c.Name,
            TaxDetails__c.Account__c,
            TaxDetails__c.ExternalIdentifier__c,
            TaxDetails__c.TaxExemptReason__c,
            TaxDetails__c.TaxNumber__c,
            TaxDetails__c.TaxType__c,
            TaxDetails__c.External_Country_Code__c,
            TaxDetails__c.External_System_Id__c,
            TaxDetails__c.Country__c,
            TaxDetails__c.TIN_IN_Number__c,
            TaxDetails__c.Jurisdiction_of_Tax_Residence__c
        };
    }

    /**
     * @description Select by Id
     * @param Id
     * @return TaxDetails
     */
    public TaxDetails__c selectByAccountId(id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Account__c =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }

    /**
     * @description Select by set of accountIds
     * @param accountIds
     * @return List<TaxDetails>
     */
    public List<TaxDetails__c> selectByAccountIds(Set<id> accountIds) {
        return Database.query(
            newQueryFactory(false, false, false)
            .selectFields(getSObjectFieldList())
            .setCondition('Account__c IN : accountIds')
            .toSOQL()
        );
    }
    /**
     * @description Select by set of accountIds
     * @param contactIds
     * @return List<TaxDetails>
     */
    public List<TaxDetails__c> selectByContactIds(Set<id> contactIds) {
        return Database.query(
            newQueryFactory(false, false, false)
            .selectFields(getSObjectFieldList())
            .setCondition('Account__c IN : contactIds')
            .toSOQL()
        );
    }


    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<TaxDetails__c>
     */
    public List<TaxDetails__c> selectByIds(Set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());
        String query = String.escapeSingleQuotes(fieldQueryFactory.toSOQL());
        return Database.query(query);
    }
    /**
     * @description Select by set of accountIds
     * @param accountIds
     * @param fields
     * @return List<TaxDetails__c>
     */
    public List<TaxDetails__c> selectByAccountIdAndFields(Set<Id> accountIds, List<String> fields) {
        return Database.query(
            newQueryFactory(false, false, false)
            .selectFields(fields)
            .setCondition('Account__c IN : accountIds')
            .toSOQL()
        );
    }

}