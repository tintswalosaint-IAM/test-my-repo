/**
 * @Name of the class: SEL_ContactPointEmail_Test.cls
 * @description testClass for Selector Class for ContactPointEmail Entity Test class
 * 
 * Story: SFP-37439
 * 
 * @date 29/03/2024
 *********************************
 * @last modified on  : 01/07/2024 
 * @last modified by  : Ikyatha Naidu
 * @ Modification Description : SFP-30275, Updated to latest version
 */
@isTest
public class SEL_ContactPointEmail_Test {

    @TestSetup
    static void setupTestData() {
        Account accRec = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createContactPointEmail(accRec.Id);
    }

    /**
    * @description Verify that the SObjectType returned is ContactPointEmail.SObjectType
    */
    @IsTest
    static void testGetSObjectType() {
        SEL_ContactPointEmail contactPointEmailSelector = new SEL_ContactPointEmail();
        Test.startTest();
        Schema.SObjectType sObjectType = contactPointEmailSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ContactPointEmail.SObjectType, sObjectType, 'The returned SObjectType does not match ContactPointEmail.SObjectType');
    }

    /**
    * @description Verify that the SObjectFieldList returned is not empty and contains valid fields
    */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_ContactPointEmail contactPointEmailSelector = new SEL_ContactPointEmail();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = contactPointEmailSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = ContactPointEmail.SObjectType.getDescribe().fields.getMap();
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in ContactPointEmail field map');
        }
    }

    /**
    * @description Verify that a ContactPointEmail is returned for the given parent Account ID
    */
    @IsTest
    static void tesSelectByParentId() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_ContactPointEmail contactPointEmailSelector = new SEL_ContactPointEmail();
        Test.startTest();
        ContactPointEmail contactPointEmail = contactPointEmailSelector.selectByParentId(accRec.Id);
        Test.stopTest();
        Assert.areEqual(true, contactPointEmail != null, 'Expected a non-null ContactPointEmail for Account ID: ' + accRec.Id);
    }

    /**
    * @description Verify that a list of ContactPointEmails is returned for the given set of Account IDs
    */
    @IsTest
    static void testSelectByAccountIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Set<Id> accountIds = new Set<Id>{accRec.Id};
        SEL_ContactPointEmail contactPointEmailSelector = new SEL_ContactPointEmail();
        Test.startTest();
        List<ContactPointEmail> contactPointEmailList = contactPointEmailSelector.selectByAccountIds(accountIds);
        Test.stopTest();
        Assert.areEqual(1, contactPointEmailList.size(), 'Expected 1 ContactPointEmail for Account ID: ' + accRec.Id);
    }

    /**
    * @description Verify that a list of ContactPointEmails is returned for the given email address
    */
    @IsTest
    static void testSelectByEmail() {
        SEL_ContactPointEmail contactPointEmailSelector = new SEL_ContactPointEmail();
        Test.startTest();
        List<ContactPointEmail> contactPointEmailList = contactPointEmailSelector.selectByEmail('test@gmail.com');
        Test.stopTest();
        Assert.areEqual(1, contactPointEmailList.size(), 'Expected 1 ContactPointEmail for email: test@gmail.com');
    }
}