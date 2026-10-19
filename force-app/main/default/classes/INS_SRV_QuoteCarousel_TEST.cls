/**
 * @description Test class for Quote carousel
 * @author Alexandr Goryachko
 * @date 2024/05/20
 */
@isTest
public class INS_SRV_QuoteCarousel_TEST {
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

        Product2 prod = WI_DAL_DataFactory.createProduct(
            new Map<String, Object>{
                'ProductCode' => 'vehicle'
            }
        );
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
     * @description To check retrieve quote line items records
     */
    @isTest
    private static void getDataPositiveTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Test.startTest();
        INS_SRV_QuoteCarousel.DataResponse result = (INS_SRV_QuoteCarousel.DataResponse)INS_FACTORY_Data.getData(
            INS_SRV_QuoteCarousel.class.getName(), 
            new Map<String, Object>{'recordId' => opp.Id}
        );
        Assert.areEqual(1, result.records.size(), 'Expected true but got false in getData method');
        Test.stopTest();
    }

    /**
     * @description To check exception when passing wrong apex class
     */
    @isTest
    private static void getDataNegativeTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Object result;
        try {
            result = INS_FACTORY_Data.getData(
                'WrongClass', 
                new Map<String, Object>{'recordId' => opp.Id}
            );
        } catch (Exception ex) {
            Assert.areEqual('Script-thrown exception', ex.getMessage(), 'Exception wasn\'t thrown');
        }
        Assert.isNull(result, 'Error when passing wrong apex class');
        Test.stopTest();
    }
}