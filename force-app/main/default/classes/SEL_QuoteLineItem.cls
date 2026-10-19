/**
 * @description  Selector Class for Quote Line Item
 * @author Alexandr Goryachko
 * @date 2024/05/22
 */
public inherited sharing class SEL_QuoteLineItem extends sbgplatform.fflib_SObjectSelector {
    /**
     * Method to get list of fields to be part of response
     * @return `List<Schema.SObjectField>`
     */
    public override List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            QuoteLineItem.Id, 
            QuoteLineItem.UnitPrice, 
            QuoteLineItem.CurrencyIsoCode,
            QuoteLineItem.Description
        };
    }

    /**
     * Method to get list of fields through relationships
     * @return  `Set<String>`
     */
    private Set<String> getRelationshipFields() {
        return new Set<String> {
            'Product2.Name',
            'Product2.Product_Image__c',
            'Product2.ProductCode',
            'Quote.Id',
            'Quote.Excess__c',
            'Quote.GrandTotal',
            'Quote.Producer__r.Account.Name',
            'Quote.Producer__r.Account.Image__c',
            'Quote.Producer__r.Account.ColourHex__c'
        };
    }

    /**
     * Method to identify a query object
     * @return `Schema.SObjectType`
     */
    public override Schema.SObjectType getSObjectType() {
        return QuoteLineItem.sObjectType;
    }

    /**
     * Method to get Quote Line Item by opportunity id
     * @return `List<QuoteLineItem>`
     */
    public List<QuoteLineItem> getQuoteLineItemsByOpportunityId(Id oppId) {
        sbgplatform.fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, true);
        fieldQueryFactory.selectFields(this.getRelationshipFields());
        fieldQueryFactory.setCondition('Quote.OpportunityId = :oppId');
        fieldQueryFactory.setOrdering('Quote.GrandTotal', sbgplatform.fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<QuoteLineItem>)Database.query(String.escapeSingleQuotes(fieldQueryFactory.toSOQL()));
    }
}