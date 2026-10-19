/**
 * @description  Selector Class for Quote Line Item
 * @author Alexandr Goryachko
 * @date 2024/10/22
 * ****************************************************************************************
* Last Modified By  Ihtishaam Mohammoodally
* Last Modified Date 17-02-2026
* Last Modified Description: User Story SFP-55981
******************************************************************************************/
public inherited sharing class SEL_Producer extends sbgplatform.fflib_SObjectSelector {
    /**
     * Method to get list of fields to be part of response
     * @return `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Producer.Id,
            Producer.Name,
            Producer.AccountId,
            Producer.InternalUserId 
        };
    }

    /**
     * Method to get list of fields through relationships
     * @return  `Set<String>`
     */
    private Set<String> getRelationshipFields() {
        return new Set<String> {
            'Account.Name',
            'Account.Image__c',
            'Account.ColourHex__c',
            'Account.Company_Email_Address__c',
            'Account.Client_Sector__c',
            'InternalUserId',
            'InternalUser.EmployeeNumber'
        };
    }

    /**
     * Method to identify a query object
     * @return `Schema.SObjectType`
     */
    public override Schema.SObjectType getSObjectType() {
        return Producer.sObjectType;
    }

    /**
     * Method to get Producer by account names
     * @return `List<Producer>`
     */
    public List<Producer> getProducersByAccountNames(List<String> names) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.selectFields(this.getRelationshipFields());
        fieldQueryFactory.setCondition('Name IN :names');
        return (List<Producer>)Database.query(String.escapeSingleQuotes(fieldQueryFactory.toSOQL()));
    }
    
     /**
     * Method to get Producer by employee number
     * @author: Ihtishaam Mohammoodally
     * @return `List<Producer>`
     * @date 2026/02/12
     */
    
    public Producer getProducersByInternalUserId(String userId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.selectFields(this.getRelationshipFields());
        fieldQueryFactory.setCondition('InternalUserId =:userId');
        fieldQueryFactory.setLimit(1);
        List<Producer> producers = (List<Producer>)Database.query(String.escapeSingleQuotes(fieldQueryFactory.toSOQL()));
        return producers.isEmpty() ? null : producers[0];
    }

}