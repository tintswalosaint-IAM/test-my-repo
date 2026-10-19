/**
 * @Name of the Class: SEL_ContactPointPhone_Test
 * @description: SFP-36380 Test Class for SEL_ContactPointPhone Entity
 * 
 * @author: Ikyatha Naidu
 * @date: 17/05/2024
 ********************************************
 * @last modified on: 01/07/2024
 * @last modified by: Ikyatha Naidu
 * @Modification Description: Updated to latest version
 */
@isTest
private class SEL_ContactPointPhone_Test {
    
    // Test setup to create common test data
    @testSetup
    static void setupTestData() {
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        ICS_DAL_TestFactory.createPointPhone(testAccount.Id);
    }
    
    /**
     * @description Verify the getSObjectType method
     */
    @isTest
    static void testGetSObjectType() {
        Test.startTest();
        SEL_ContactPointPhone phoneSelector = new SEL_ContactPointPhone();
        Schema.SObjectType sObjectType = phoneSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(ContactPointPhone.SObjectType, sObjectType, 'Unexpected SObjectType.');
    }
    
    /**
     * @description Verify the getSObjectFieldList method
     */
    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        SEL_ContactPointPhone phoneSelector = new SEL_ContactPointPhone();
        List<Schema.SObjectField> sObjectFieldList = phoneSelector.getSObjectFieldList();
        Map<String, Schema.SObjectField> fieldMap = ContactPointPhone.SObjectType.getDescribe().fields.getMap();
        Test.stopTest();        
        Assert.areNotEqual(0, sObjectFieldList.size(), 'Expected fields list to contain at least one item.');        
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.areEqual(true, fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in ContactPointPhone field map.');
        }
    }
    
    /**
     * @description Verify the selectByParentId method
     */
    @isTest
    static void testSelectByParentId() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        SEL_ContactPointPhone phoneSelector = new SEL_ContactPointPhone();       
        Test.startTest();
        List<ContactPointPhone> phoneList = phoneSelector.selectByParentId(accRec.Id);
         phoneSelector.selectByParentId(null);
        Test.stopTest();
        Assert.areNotEqual(0, phoneList.size(), 'Expected at least one ContactPointPhone record.');
    }
    
    /**
     * @description Verify the selectByParentIds method
     */
    @isTest
    static void testSelectByParentIds() {
        Account accRec = [SELECT Id FROM Account LIMIT 1];
        Set<Id> ids = new Set<Id>{accRec.Id};
        SEL_ContactPointPhone phoneSelector = new SEL_ContactPointPhone();        
        Test.startTest();
        List<ContactPointPhone> phoneList = phoneSelector.selectByParentIds(ids);
        phoneSelector.selectByParentIds(null);
        Test.stopTest();
        Assert.areNotEqual(0, phoneList.size(), 'Expected at least one ContactPointPhone record.');
    }
    
    /**
     * @description Verify the selectByTelephoneNumber method
     */
    @isTest
    static void testSelectByTelephoneNumber() {
        Test.startTest();
        List<ContactPointPhone> phoneList = new SEL_ContactPointPhone().selectByTelephoneNumber('9032296917');
        
        Test.stopTest();
        Assert.areNotEqual(0, phoneList.size(), 'Expected at least one ContactPointPhone record with the given telephone number.');
    }
     /**
     * @description Verify the selectByTelephoneNumber method
     */
    @isTest
    static void testSelectByTelephoneNumberNull() {
        try{
        Test.startTest();
        List<ContactPointPhone> phoneList = new SEL_ContactPointPhone().selectByTelephoneNumber(null);
        
        Test.stopTest();
        Assert.areNotEqual(0, phoneList.size(), 'Expected at least one ContactPointPhone record with the given telephone number.');
        }catch(exception ex){
             Assert.areEqual(true, ex.getmessage() != null, 'Attempt to dereference null object');
        }
    }
}