/**
 * @description       : Test class for INS_Get_Account
 * @author            : Shamsul Arifeen
 * @last modified on  : 10-16-2025
 * user story         : SFP-26933
 * Modification       : Jaco de Lange - Add additional logic to the testSelectAccountByName.
 * @last modified	  : 06-10-2025
 * @last Modified	  : SFP-54233: Updated API version to 65.0	
 * Modification       : Jaco de Lange - SFP-59700 - Updated test class for additional code coverage.
 * @last modified on  : 03-08-2026
**/
@isTest
private class INS_Get_Account_Test {

    // Utility method to create a test user
    private static User createTestUser(String username) {
        User u = new User(
            Username = username,
            LastName = 'TestUser',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            ProfileId = UserInfo.getProfileId(),
            Country = 'UG',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York'
        );
        insert u;
        return u;
    }

    // Utility method to create a test Person Account
    private static Account createTestAccount(User owner, String identityNumber) {
        Account acc = new Account(
            FirstName = 'Test',
            LastName = 'Account',
            PersonBirthdate = Date.today(),
            CMN_IdentityNumber__pc = identityNumber,
            OwnerId = owner.Id,
            FinServ__CustomerType__c = 'Liberty',
            ExternalCIFCountry__c = 'UG'
        );
        insert acc;
        return acc;
    }

    @isTest
    static void testSelectAccountByName() {
        User u = createTestUser('testuser321zyx@example.com');
        Account acc = createTestAccount(u, 'TEST00101M53G');
        acc.ExternalCIFCountry__c = 'UG';
        update acc;

        INS_Get_Account selector = new INS_Get_Account();

        // First query (by identity number)
        List<Account> results = selector.selectAccountByName(
            acc.FirstName, acc.LastName, acc.PersonBirthdate, acc.CMN_IdentityNumber__pc, 'Liberty', 'UG'
        );
       Assert.areEqual(1, results.size());
       Assert.areEqual(acc.Id, results[0].Id);

        // Second query (after changing identity number → forces name/DOB path)
        acc.CMN_IdentityNumber__pc = 'UPDATEDT00101M53G';
        results = selector.selectAccountByName(
            acc.FirstName, acc.LastName, acc.PersonBirthdate, acc.CMN_IdentityNumber__pc, 'Liberty', 'UG'
        );
       Assert.areEqual(1, results.size());
    }

    @isTest
    static void testSelectAccountByNameFromFlow() {
        User u = createTestUser('testuser4321z@example.com');
        Account acc = createTestAccount(u, 'TEST00202M53G');
        acc.ExternalCIFCountry__c = 'UG';
        update acc;

        INS_Get_Account.GetCustomer cust = new INS_Get_Account.GetCustomer();
        cust.firstName = acc.FirstName;
        cust.lastName = acc.LastName;
        cust.dateOfBirth = acc.PersonBirthdate;
        cust.identityNumber = acc.CMN_IdentityNumber__pc;
        cust.userCountry = 'UG';
        cust.customerType = 'Liberty';

        List<INS_Get_Account.AccountResponse> flowResults =
            INS_Get_Account.selectAccountByNameFromFlow(new List<INS_Get_Account.GetCustomer>{ cust });

        Assert.areEqual(1, flowResults.size());
        Assert.areEqual(acc.Id, flowResults[0].accountId);
    }

    @isTest
    static void testGetSObjectFieldList() {
        INS_Get_Account selector = new INS_Get_Account();
        List<Schema.SObjectField> fields = selector.getSObjectFieldList();

        Assert.areNotEqual(null, fields);
        Assert.areEqual(12, fields.size());
    }
}