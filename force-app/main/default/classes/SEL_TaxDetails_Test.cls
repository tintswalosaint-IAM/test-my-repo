/**
 * @description       : Test class for SEL_TaxDetails
 * @author            : Tushar Walse
 * @last modified on  : 19-10-2024
 * @last modified by  : Tushar Walse
**/

@isTest
private class SEL_TaxDetails_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account account = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createTaxDetails(account.Id);
    }

    /**
     * @description Test the getSObjectType method of SEL_TaxDetails class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_TaxDetails testTaxDetails = new SEL_TaxDetails();
        Test.startTest();
        Schema.SObjectType sObjectType = testTaxDetails.getSObjectType();
        Test.stopTest();
        Assert.areEqual(TaxDetails__c.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_TaxDetails class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_TaxDetails testTaxDetails = new SEL_TaxDetails();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = testTaxDetails.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the selectByIds method of SEL_TaxDetails class
     */
    @isTest
    static void testSelectByIds() {
        Set<Id> taxDetailsIds = new Map<Id, TaxDetails__c>([select Id from TaxDetails__c Limit 1]).keySet();

        SEL_TaxDetails taxDetailsSelector = new SEL_TaxDetails();
        Test.startTest();
        List<TaxDetails__c> taxDetails = taxDetailsSelector.selectByIds(taxDetailsIds);
        Test.stopTest();
        Assert.areEqual(true, taxDetails.size()>0, 'Expected at least 1 TaxDetails record to be returned.');
    }

    /**
     * @description Test the selectByAccountIds method of SEL_TaxDetails class
     */
    @isTest
    static void testSelectByAccountIds() {
        Set<Id> accountIds = new Map<Id, Account>([select Id from Account Limit 1]).keySet();

        SEL_TaxDetails taxDetailsSelector = new SEL_TaxDetails();
        Test.startTest();
        List<TaxDetails__c> taxDetails = taxDetailsSelector.selectByAccountIds(accountIds);
        Test.stopTest();
        Assert.areEqual(true, taxDetails.size()>0, 'Expected at least 1 TaxDetails record to be returned.');
    }

    /**
     * @description Test the selectByAccountId method of SEL_TaxDetails class
     */
    @isTest
    static void testSelectByAccountId() {
        Id accountId = [select Id from Account Limit 1].Id;

        SEL_TaxDetails taxDetailsSelector = new SEL_TaxDetails();
        Test.startTest();
        TaxDetails__c taxDetails = taxDetailsSelector.selectByAccountId(accountId);
        taxDetailsSelector.selectByContactIds(new set<Id>{accountID});
        Test.stopTest();
        Assert.areEqual(true, taxDetails != null, 'Expected 1 TaxDetails record to be returned.');
    }

}