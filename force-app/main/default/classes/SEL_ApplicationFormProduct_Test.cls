/**
 * @description                 : Test class for SEL_ApplicationFormProduct
 * @author                      : Tushar Walse
 * @date                        : 20-03-2024
 * @last modified on            : 19-10-2024
 * @last modified by            : Tushar Walse
 * @modification description    : Updated
 */

@isTest
private class SEL_ApplicationFormProduct_Test {
    /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        Account account = ICS_DAL_TestFactory.createAccount();
        ApplicationForm applicationForm = ICS_DAL_TestFactory.createApplicationForm(account.Id);
        Product2 product2 = ICS_DAL_TestFactory.createProduct2();

        ICS_DAL_TestFactory.createApplicationFormProduct(applicationForm.Id, product2.Id);

    }

    /**
     * @description Test the getSObjectType method of SEL_ApplicationFormProduct class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_ApplicationFormProduct testApplicationFormProduct = new SEL_ApplicationFormProduct();
        Test.startTest();
        Schema.SObjectType sObjectType = testApplicationFormProduct.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ApplicationFormProduct.SObjectType, sObjectType, 'Unexpected SObjectType');
    }

    /**
     * @description Test the getSObjectFieldList method of SEL_ApplicationFormProduct class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_ApplicationFormProduct testApplicationFormProduct = new SEL_ApplicationFormProduct();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = testApplicationFormProduct.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }

    /**
     * @description Test the selectByApplicationFormIds method of SEL_ApplicationFormProduct class
     */
    @isTest
    static void testSelectByApplicationFormIds() {
        Set<Id> applicationFormIds = new Map<Id, ApplicationForm>([SELECT Id FROM ApplicationForm]).keySet();
        SEL_ApplicationFormProduct applicationFormProductSelector = new SEL_ApplicationFormProduct();
        Test.startTest();
        List<ApplicationFormProduct> applicationFormProducts = applicationFormProductSelector.selectByApplicationFormIds(applicationFormIds);
        Test.stopTest();
        Assert.areEqual(1, applicationFormProducts.size(), 'Expected 1 applicationFormProducts to be returned.');
    }

}