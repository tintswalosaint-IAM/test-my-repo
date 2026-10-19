/**
 * @description Test class of LWC controller
 * 
 * @author Alexandr Goryachko
 *
 * @date 2023/02/16
 */
@isTest
public class WI_CTRL_ProductsRelatedList_TEST {
    @testSetup 
    private static void setup() {
        Account acc = WI_DAL_DataFactory.createAccount(null);
        insert acc;

        Pricebook2 pb1 = WI_DAL_DataFactory.createPricebook(null);
        Pricebook2 pb2 = WI_DAL_DataFactory.createPricebook(null);
        insert pb1;
        insert pb2;

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

        OpportunityLineItem oppProd = WI_DAL_DataFactory.createOpportunityLineItem(
            new Map<String, Object>{
                'OpportunityId' => opp.Id,
                'Product2Id' => prod.Id,
                'PricebookEntryId' => customPrice.Id,
                Schema.OpportunityLineItem.WI_Status__c.getDescribe().getName() => 'Setup'
            }
        );
        insert oppProd;
    }

    /**
     * @description To check retrieve data
     */
    @isTest
    private static void getRelatedListDataTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.getRelatedListData(
            opp.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check exception of retrieve data
     */
    @isTest
    private static void getRelatedListDataExceptionTest() {
        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.getRelatedListData(
            null
        );
        Assert.isFalse(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check retrieve price books
     */
    @isTest
    private static void getPriceBooksTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.getPriceBooks(
            opp.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check retrieve exception price books
     */
    @isTest
    private static void getPriceBooksExceptionTest() {
        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.getPriceBooks(
            null
        );
        Assert.isFalse(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check removing records
     */
    @isTest
    private static void removeLineItemsByOppTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.removeLineItems(
            opp.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check removing records
     */
    @isTest
    private static void removeLineItemsByOLITest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp.Id];

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.removeLineItems(
            opp.Id
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check upserting records
     */
    @isTest
    private static void upsertLineItemsTest() {
        Opportunity opp = [SELECT Id, Pricebook2Id FROM Opportunity LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry customPrice = [SELECT Id FROM PricebookEntry WHERE Pricebook2Id = :opp.Pricebook2Id LIMIT 1];

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            PricebookEntryId = customPrice.Id,
            WI_Status__c = 'Setup'
        );

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.upsertLineItems(
            new List<OpportunityLineItem>{oli}
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }

    /**
     * @description To check getting entries
     */
    @isTest
    private static void getEntriesTest() {
        Opportunity opp = [SELECT Id, Pricebook2Id, CurrencyIsoCode FROM Opportunity LIMIT 1];

        Test.startTest();
        WI_CTRL_ProductsRelatedList.DataResponse response = WI_CTRL_ProductsRelatedList.getEntries(
            opp.Pricebook2Id,
            opp.CurrencyIsoCode,
            null,
            0
        );
        Assert.isTrue(response.isSuccess, 'Wrong get response');
        Test.stopTest();
    }
}