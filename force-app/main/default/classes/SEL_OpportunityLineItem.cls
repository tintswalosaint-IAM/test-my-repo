/**
 * @description                 : Selector Class for OpportunityLineItem
 * @story 		                : SFP-34698 Application Approval flow, Queues and Sign off
 * @author                      : Tushar Walse
 * @date                        : 2024-03-20
 * @last modified on            : 2024-03-20
 * @last modified by            : Tushar Walse
 * @modification description    : Created
 */

public inherited sharing class SEL_OpportunityLineItem extends sbgplatform.fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL queries
     * @return Schema.SObjectType
     */
    public override Schema.SObjectType getSObjectType(){
        return OpportunityLineItem.SObjectType;
    }
   
    /**
     * @description This is used to retrieve SObject fields frequently needed
     * @return  List<Schema.SObjectField>
    */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            OpportunityLineItem.Id,
            OpportunityLineItem.OpportunityId,
            OpportunityLineItem.Product2Id,
            OpportunityLineItem.PricebookEntryId,
            OpportunityLineItem.Product2.Name,
            OpportunityLineItem.Name,
            OpportunityLineItem.Product_Family__c,
            OpportunityLineItem.ProductCode,
            OpportunityLineItem.Quantity,
            OpportunityLineItem.Description,
            OpportunityLineItem.Product2.CurrencyIsoCode  
        };
    }    

    /**
     * Method to get list of fields through relationships
     * @return  `Set<String>`
     */
    private Set<String> getRelationshipFields() {
        return new Set<String> {
            'Product2.Name'
        };
    }

    /**
     * @description Select by Id
     * @param Id
     * @return OpportunityLineItem
     */
    public OpportunityLineItem selectById(id id) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id =: id');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        return Database.query(fieldQueryFactory.toSOQL());
    }
    
    /**
     * @description Select by opportunityId
     * @param opportunityId
     * @return OpportunityLineItem
     */
    public OpportunityLineItem selectByOpportunityId(id opportunityId) {
        List<OpportunityLineItem> results = selectByOpportunityIds(new Set<Id>{ opportunityId });
        return results.isEmpty() ? null : results.get(0);
    }
    
    /**
     * @description Select by set of opportunityIds
     * @param opportunityIds
     * @return List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByOpportunityIds(Set<id> opportunityIds) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('OpportunityId IN: opportunityIds');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
         fieldQueryFactory.selectField('Product2.Name');
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * @description Select by set of Ids
     * @param ids
     * @return List<OpportunityLineItem>
     */
    public List<OpportunityLineItem> selectByIds(Set<id> ids) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('Id IN : ids');
        fieldQueryFactory.selectFields(getSObjectFieldList());  
        return Database.query(fieldQueryFactory.toSOQL());
    }

    /**
     * Method to get Opportunity Line Item by opportunity id
     * @return `List<OpportunityLineItem>`
     */
    public List<OpportunityLineItem> getOpportunityLineItemsByOpportunityId(Id oppId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.selectFields(this.getRelationshipFields());
        fieldQueryFactory.setCondition('OpportunityId = :oppId');
        return (List<OpportunityLineItem>)Database.query(fieldQueryFactory.toSOQL());
    }
}