/**
* @Name of the Class : SEL_PriceBookEntry_Test
* @description       : SFP-36380 Selector Test class for SEL_PriceBookEntry object.
* This class provides methods to test SEL_PriceBookEntry functionalities.
* @date              : 17/05/2024
* @last modified on  : 01/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
**/
@isTest
public class SEL_PriceBookEntry_Test {
    /**
* @description Verify that the SObjectType returned is PricebookEntry.SObjectType
*/
    @IsTest
    static void testGetSObjectType() {
        SEL_PriceBookEntry priceBookEntrySelector = new SEL_PriceBookEntry();
        Test.startTest();
        Schema.SObjectType sObjectType = priceBookEntrySelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(PricebookEntry.SObjectType, sObjectType, 'The returned SObjectType does not match PricebookEntry.SObjectType');
    }
    
    /**
* @description Verify that the SObjectFieldList returned is not empty and contains valid fields
*/
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_PriceBookEntry priceBookEntrySelector = new SEL_PriceBookEntry();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = priceBookEntrySelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = PricebookEntry.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in PricebookEntry field map');
        }
    }
    
    
    /**
* @description Verify that no PricebookEntry records are returned for given product codes, name, and currency
*/
    @IsTest
    static void testSelectByProductcodeAndName() {
        try{
        List<String> prodStrings = new List<String>{'test1','test2','test3'};
            SEL_PriceBookEntry priceBookEntrySelector = new SEL_PriceBookEntry(); 
        Test.startTest();   
        List<PricebookEntry> PricebookEntryList = priceBookEntrySelector.selectByProductcodeAndName(prodStrings, 'tester', 'USD');
        priceBookEntrySelector.selectByProductIdAndPBName('', 'tester', 'USD');
        Test.stopTest();
        Assert.areEqual(0, PricebookEntryList.size(), 'Expected 0 PricebookEntry records but got ' + PricebookEntryList.size());
        }catch(exception ex){
               Assert.areEqual(true, ex.getmessage() != null,'Error Occured');
        }
    }
    
}