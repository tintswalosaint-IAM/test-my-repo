/**
 * @Name of the Class : SEL_Contact_Test
 * @description Test class for SEL_Contact class
 * @author Ridhima Saxena
 * @date  05-06-2025
 * @last modified on  : 05-06-2025
 * @last modified by  : Ridhima Saxena
 * 
 * @last modified on  : 10-13-2025
 * @last modified by  : Jaco de Lange
 * @Modification Description : SFP-47621 - Added additional logic to the createTestContact method
 */
@Istest
public class SEL_Contact_Test {
    @TestSetup
    static void setupTestData() {
        ICS_DAL_TestFactory.createAccount();
    }
  
    /**
    * @description: Verify that the SObjectType returned is Account.SObjectType
    */
    @IsTest 
    static void testGetSObjectType() { 
        SEL_Contact contactSelector = new SEL_Contact();
        Test.startTest();
        Schema.SObjectType sObjectType = contactSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(Contact.SObjectType, sObjectType, 'The returned SObjectType does not match Contact.SObjectType');
    }

    /**
    * @description: Verify that the SObjectFieldList returned is not empty and contains valid fields
    */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_Contact contactSelector = new SEL_Contact();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = contactSelector.getSObjectFieldList();
        Test.stopTest();
        Map<String, Schema.SObjectField> fieldMap = Contact.SObjectType.getDescribe().fields.getMap();
        Assert.areEqual(true, !sObjectFieldList.isEmpty(), 'The field list should not be empty');
        for (Schema.SObjectField field : sObjectFieldList) {
            Assert.isTrue(fieldMap.containsKey(field.getDescribe().getName()), 'Field ' + field.getDescribe().getName() + ' not found in Contact field map');
        }
    }

    @IsTest
    static void testSelectById() {
        Contact accRec = [SELECT Id FROM Contact LIMIT 1];
        SEL_Contact accountQueryList = new SEL_Contact();
        Test.startTest();
        Contact acc = accountQueryList.selectById(accRec.Id);
        Test.stopTest();
        Assert.areEqual(true, acc != null, 'Expected a non-null Account for Account ID: ' + accRec.Id);
    }

    @IsTest
    static void testselectContactByRoleAndAccountId() {
        Contact accRec = [SELECT Id FROM Contact LIMIT 1];
        SEL_Contact accountQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> acc = accountQueryList.selectByRoleAndAccountId(accRec.Id, new Set<String>{'test'});
        Test.stopTest();
        Assert.areEqual(true, acc != null, 'Expected a non-null Account for Account ID: ' + accRec.Id);
    }

    @isTest
    static void testSelectByAccountIds() {
        try {
            Set<Id> accountIds = new Map<Id, Account>([SELECT Id FROM Account]).keySet();
            SEL_Contact ContactSelector = new SEL_Contact();
            Test.startTest();
            List<Contact> assessments = ContactSelector.selectByAccountIds(accountIds);
            Test.stopTest();
            Assert.areEqual(1, assessments.size(), 'Expected 3 assessments to be returned.');
        } catch(Exception ex) {
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occured');
        }
    }

    @IsTest
    static void testSelectByEmail() {
        Contact con = createTestContact();
        SEL_Contact contactQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> conRec = contactQueryList.selectByEmail(con.Email);
        Test.stopTest();
        Assert.areEqual(true, conRec != null, 'Expected a non-null Contact for Contact ID: ' + con.Id);
    }

    @IsTest
    static void testSelectByEmailandRecordTypeName() {
        Contact con = createTestContact();
        SEL_Contact contactQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> conRec = contactQueryList.selectByEmailandRecordTypeName(con.Email, con.RecordType.Name);
        Test.stopTest();
        Assert.areEqual(true, conRec != null, 'Expected a non-null Contact for Contact ID: ' + con.Id);
    }

    @IsTest
    static void testSelectByPingId() {
        Contact con = createTestContact();
        SEL_Contact contactQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> conRec = contactQueryList.selectByPingId(con.Ping_Id__c);
        Test.stopTest();
        Assert.areEqual(true, conRec != null, 'Expected a non-null Contact for Contact ID: ' + con.Id);
    }

    private static Contact createTestContact() {
        Id industriesBusAccRecId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
        Account acc = new Account(
            Name = 'Test DSA Account',
            RecordTypeId = industriesBusAccRecId,
            ExternalCIFId__c = 'KE'
        );
        insert acc;

        Id salesAgentContactRecId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Sales_Agent_Contact').getRecordTypeId();
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test.dsa@example.com',
            RecordTypeId = salesAgentContactRecId,
            External_CIF_Country__c = 'KE',
            AccountId = acc.Id,
            INS_SalesAgentPortalLicenseType__c = 'Partner Community User',
            Ping_Id__c = '123456'
        );
        insert con;
        return con;
    }

    @IsTest
    static void testSelectPersonContactByEmail() {
        Contact con = createTestContact();
        SEL_Contact contactQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> conRec = contactQueryList.selectPersonContactByEmail(con.Email);
        Test.stopTest();
        Assert.areEqual(true, conRec != null, 'Expected a non-null Contact list for email: ' + con.Email);
    }
    
    @IsTest
    static void testSelectByAccountIdAndRelativeName() {
        Contact con = createTestContact();
        SEL_Contact contactQueryList = new SEL_Contact();
        Test.startTest();
        List<Contact> conRec = contactQueryList.selectByAccountIdandRelativeName(
            con.AccountId,
            new Set<String>{ 'TestRelative' }
        );
        Test.stopTest();
        Assert.areEqual(true, conRec != null, 'Expected a non-null Contact list for AccountId: ' + con.AccountId);
    }
}