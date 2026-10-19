/**
 * @Name of the class: SEL_OpportunityLineItem_Test.cls
 * @description Test class for Selector Class for OpportunityLineItem Entity Test class
 *  
 * Story: SFP-37439
 * 
 * @autor Ikyatha Naidu  
 *
 * @date 29/03/2024 
 *********************************
 * @last modified on  :  01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @ Modification Description : SFP-30275, Updated to latest version
 */
@isTest
public class SEL_OpportunityLineItem_Test {
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

        OpportunityLineItem oppProd = WI_DAL_DataFactory.createOpportunityLineItem(
            new Map<String, Object>{
                'OpportunityId' => opp.Id,
                'Product2Id' => prod.Id
            }
        );
        insert oppProd;
    }

    /**
     * @description To check positive retrieve data
     */
    @isTest
    private static void getOpportunityLineItemsByOpportunityIdTest() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        List<OpportunityLineItem> opportunityItems = new SEL_OpportunityLineItem().getOpportunityLineItemsByOpportunityId(opp.Id);
        Assert.isTrue(opportunityItems.size() == 1, 'Error in the selector method');
        Test.stopTest();
    }

    /**
     * @description Verify the selection of OpportunityLineItem by  Id
     */
    @isTest
    private static void testSelectById(){
        OpportunityLineItem lineItem =[select id from OpportunityLineItem limit 1];
        SEL_OpportunityLineItem itemSelector = new SEL_OpportunityLineItem();
        Test.startTest();   
        OpportunityLineItem itemList = itemSelector.selectById(lineItem.id);
        itemSelector.selectByIds(new set<Id>{lineItem.id});
        Test.stopTest();
        Assert.areEqual(true, itemList != null, 'Expected itemList to contain at least one item.');
    }
    /**
     * @description Verify the selection of OpportunityLineItem by  OpportunityId
     */
    @isTest
    private static void testSelectByOpportunityId(){
        Opportunity opp=[select id from Opportunity LIMIT 1];
        
        SEL_OpportunityLineItem itemSelector = new SEL_OpportunityLineItem();
        Test.startTest();   
        OpportunityLineItem itemList = itemSelector.selectByOpportunityId(opp.id);
        itemSelector.selectByOpportunityIds(new set<Id>{opp.id});
        Test.stopTest();
        Assert.areEqual(true, itemList != null, 'Expected itemList to contain at least one item.');
    }
    
   
}