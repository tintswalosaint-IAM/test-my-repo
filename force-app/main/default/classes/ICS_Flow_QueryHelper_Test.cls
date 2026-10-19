/**
 * @description                 :test class for Flow ICS_Flow_QueryHelper
 * @story 		                : SFP-34725 
 * @author                      : Ofentse sacha
 * @date                        : 2024-03-20
 * @last modified on            : 2024-03-20
 * @last modified by            : Ikyatha Naidu
 * @modification description    : Created
 */
@isTest
private class ICS_Flow_QueryHelper_Test {
    @TestSetup
    static void setupTestData() {
        // Create test Accounts
       
            ics_dal_testFactory.createAccount();
        
    }

    @isTest
    static void testFetchRecordsSingleObject() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        List<String> accountIds = new List<String>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        ICS_Flow_QueryHelper.Input input = new ICS_Flow_QueryHelper.Input();
        input.ids = accountIds;
        input.relationshipName = null;

        Test.startTest();
        List<ICS_Flow_QueryHelper.Output> results = ICS_Flow_QueryHelper.fetchRecords(new List<ICS_Flow_QueryHelper.Input>{input});
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Expected 1 output result');
        
    }

    @isTest
    static void testFetchRecordsWithRelatedObjects() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 2];
        List<String> accountIds = new List<String>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
        }

        ICS_Flow_QueryHelper.Input input = new ICS_Flow_QueryHelper.Input();
        input.ids = accountIds;
        input.relationshipName = 'Contacts';

        Test.startTest();
        List<ICS_Flow_QueryHelper.Output> results = ICS_Flow_QueryHelper.fetchRecords(new List<ICS_Flow_QueryHelper.Input>{input});
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Expected 1 output result');
        
    }

    @isTest
    static void testFetchRecordsMultipleObjects() {
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];

        ICS_Flow_QueryHelper.Input inputAccount = new ICS_Flow_QueryHelper.Input();
        inputAccount.ids = new List<String>{accounts[0].Id};
        inputAccount.relationshipName = null;

        ICS_Flow_QueryHelper.Input inputContact = new ICS_Flow_QueryHelper.Input();
        inputContact.ids = new List<String>{contacts[0].Id};
        inputContact.relationshipName = null;

        Test.startTest();
        List<ICS_Flow_QueryHelper.Output> results = ICS_Flow_QueryHelper.fetchRecords(new List<ICS_Flow_QueryHelper.Input>{inputAccount, inputContact});
        Test.stopTest();

        Assert.areEqual(2, results.size(), 'Expected 2 output results');
        Assert.areEqual(1, results[0].parentRecords.size(), 'Expected 1 Account record');
        Assert.areEqual(1, results[1].parentRecords.size(), 'Expected 1 Contact record');
        Assert.isTrue(results[0].parentRecords[0] instanceof Account, 'Expected Account record');
        Assert.isTrue(results[1].parentRecords[0] instanceof Contact, 'Expected Contact record');
    }

    @isTest
    static void testGetObjectFields() {
        ICS_Flow_QueryHelper helper = new ICS_Flow_QueryHelper('Account');
        List<Schema.SObjectField> fields = helper.getSObjectFieldList();
        
        Assert.isFalse(fields.isEmpty(), 'Expected fields for Account object');
        Assert.isTrue(fields.contains(Account.Name), 'Expected Name field in the list');
    }

    @isTest
    static void testGetSObjectType() {
        ICS_Flow_QueryHelper helper = new ICS_Flow_QueryHelper('Account');
        Schema.SObjectType sObjectType = helper.getSObjectType();
        
        Assert.areEqual(Account.SObjectType, sObjectType, 'Expected Account SObjectType');
    }
}