/**
 * @description Test class for Quote Line Item Selector
 * @author Alexandr Goryachko
 * @date 2024/05/22
 */
@isTest
public class SEL_QuoteLineItem_TEST {
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;

        Pricebook2 pb1 = WI_DAL_DataFactory.createPricebook(null);
        insert pb1;

        Opportunity opp = WI_DAL_DataFactory.createOpportunity(
            new Map<String, Object>{
                'AccountId' => acc.Id,
                'Pricebook2Id' => pb1.Id
            }
        );
        insert opp;

        Product2 prod = WI_DAL_DataFactory.createProduct(null);
        insert prod;

        PricebookEntry standardPrice = WI_DAL_DataFactory.createPricebookEntry(
            new Map<String, Object>{
                'Product2Id' => prod.Id
            }
        );
        insert standardPrice;

        PricebookEntry customPrice = WI_DAL_DataFactory.createPricebookEntry(
            new Map<String, Object>{
                'Product2Id' => prod.Id,
                'Pricebook2Id' => pb1.Id
            }
        );
        insert customPrice;

        Producer producer = WI_DAL_DataFactory.createProducer(
            new Map<String, Object>{
                'AccountId' => acc.Id
            }
        );
        insert producer;

        Quote quote = WI_DAL_DataFactory.createQuote(
            new Map<String, Object>{
                'OpportunityId' => opp.Id,
                Schema.Quote.Producer__c.getDescribe().getName() => producer.Id
            }
        );
        insert quote;

        QuoteLineItem qle = WI_DAL_DataFactory.createQuoteLineItem(
            new Map<String, Object>{
                'Product2Id' => prod.Id,
                'QuoteId' => quote.Id,
                'PricebookEntryId' => customPrice.Id
            }
        );
        insert qle;
    }

    /**
     * @description To check positive retrieve data
     */
    @isTest
    private static void getQuoteLineItemsByOpportunityIdTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<QuoteLineItem> quoteItems = new SEL_QuoteLineItem().getQuoteLineItemsByOpportunityId(opp.Id);
        Assert.isTrue(quoteItems.size() == 1, 'Error in the selector method');
        Test.stopTest();
    }
}