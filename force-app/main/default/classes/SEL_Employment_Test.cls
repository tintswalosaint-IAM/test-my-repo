/**
 * @Name of the class: SEL_Employment_Test
 * @description Test class for the SEL_Employment selector class
 * 
 * Story: SFP-37439
 * 
 * @author Ikyatha Naidu
 * @date 29/03/2024
 *********************************
 * @last modified on: 01/07/2024
 * @last modified by: Ikyatha Naidu
 * @Modification Description: SFP-30275, Updated to latest version
 */
@isTest
public class SEL_Employment_Test {

    // Test setup to create common test data
    @testSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createEmployment(acc.Id);
    }

    /**
     * @description Verify the getSObjectType method
     */
    @isTest
    static void testGetSObjectType() {
        SEL_Employment employmentSelector = new SEL_Employment();
        Schema.SObjectType sObjectType = employmentSelector.getSObjectType();
        Assert.areEqual(FinServ__Employment__c.SObjectType, sObjectType, 'Expected FinServ__Employment__c SObjectType.');
    }

    /**
     * @description Verify the getSObjectFieldList method
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_Employment employmentSelector = new SEL_Employment();
        List<Schema.SObjectField> sObjectFieldList = employmentSelector.getSObjectFieldList();
        Assert.areNotEqual(0, sObjectFieldList.size(), 'Expected fields list to contain at least one item.');
    }

    /**
     * @description Verify the selectEmploymentByParentIdAndSectionName method
     */
    @isTest
    static void testSelectByParentIdAndSectionName() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SEL_Employment employmentSelector = new SEL_Employment();        
        Test.startTest();
        List<FinServ__Employment__c> dualEmploymentData = employmentSelector.selectByParentIdAndSectionName(acc.Id, 'Dual Employment Details');
         employmentSelector.selectByParentIdAndSectionName(acc.Id, 'Current Employment Details');
        employmentSelector.selectByParentIdAndSectionName(acc.Id, 'Previous Employment Details');
        Test.stopTest();
        Assert.areNotEqual(0, dualEmploymentData.size(), 'Expected at least one record in dualEmploymentData list.');
    }

    /**
     * @description Verify the selectEmploymentByAccountIds method
     */
    @isTest
    static void testSelectByAccountIds() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Set<Id> ids = new Set<Id>{acc.Id};
        SEL_Employment employmentSelector = new SEL_Employment();        
        Test.startTest();
        List<FinServ__Employment__c> employmentTest = employmentSelector.selectByAccountIds(ids);
        Test.stopTest();
        Assert.areNotEqual(0, employmentTest.size(), 'Expected at least one record in employmentTest list.');
    }
}