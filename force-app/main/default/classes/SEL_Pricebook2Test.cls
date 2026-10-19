/**
* @description       : Selector  Test Class for Pricebook2 Entity
* author             : Ihtishaam Mohammoodally
* @date              : 01-11-2024
*/
@IsTest
private class SEL_Pricebook2Test {
    
    @TestSetup
    static void setupTestData() {
        Pricebook2 pricebook = new Pricebook2(
            								Name = 'C&HNW (South Africa)',
            								IsActive = true
        									);
        insert pricebook;
    }
     /**
     * @description Tests the `getSObjectType` method to ensure it returns the correct SObjectType for Pricebook2.
     */
    @IsTest
    static void testGetSObjectType() { 
        Test.startTest();
        Schema.SObjectType sObjectType = new SEL_Pricebook2().getSObjectType();
        Test.stopTest();
        Assert.areEqual(Pricebook2.SObjectType, sObjectType, 'The returned SObjectType does not match Pricebook2.SObjectType');
    }
       /**
        * @description Verify that the SObjectFieldList returned is not empty and contains valid fields
        */
        @IsTest
        static void testGetSObjectFieldList() {
            SEL_Pricebook2 priceBookEntrySelector = new SEL_Pricebook2();
            Test.startTest();
            List<Schema.SObjectField> sObjectFieldList = priceBookEntrySelector.getSObjectFieldList();
            Test.stopTest();
            Map<String, Schema.SObjectField> fieldMap = PricebookEntry.SObjectType.getDescribe().fields.getMap();
            for (Schema.SObjectField field : sObjectFieldList) {
                Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in PricebookEntry field map');
            }
        }
      /**
     * @description test to fetch a pricebook using a condition
     */
    @IsTest
    static void testselectPriceBook() {
        Test.startTest();
        List<Pricebook2> priceBookList = new SEL_Pricebook2().selectPriceBook('Name =\'C&HNW (South Africa)\'AND IsActive = true');
        Assert.isNotNull(priceBookList[0].Id);
        Test.stopTest();
    }
    
}