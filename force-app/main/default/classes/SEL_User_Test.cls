/**
 * @description       : 
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 08-02-2024
 * @last modified by  : Derek Hughes
 * 
 * @last modified by  : Ridhima Saxena
 *  @last modified on  : 05-06-2025
 *
 * @last modified by  : Raja Arsalan
 * @last modified on  : 15-10-2025
 * TODO
 * 1. Generate more specific test user data to better tests these methods
**/
@IsTest(seeAllData=false)
public with sharing class SEL_User_Test {
    /**
     * @description       : Basic test of the selectors
     * @author            : Derek Hughes
     **/
    @IsTest
    static void testSelectors() {
        // Portal users require their Account owner to have a role.
        User accountOwner = [
            SELECT Id
            FROM User
            WHERE IsActive = true
                AND UserType = 'Standard'
                AND UserRoleId != null
            LIMIT 1
        ];

        // Create Account owned by a role-bearing user.
	    Account testAccount = new Account(Name = 'Test Account', OwnerId = accountOwner.Id);
    	insert testAccount;

    // Create Contact linked to Account
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        AccountId = testAccount.Id
    );
    insert testContact;

    // Create a Portal/Community User linked to the Contact
    // First get a profile that supports Contact-linked users (e.g. Customer Community)
    Profile portalProfile = [SELECT Id FROM Profile WHERE Name LIKE 'Customer Community%' LIMIT 1];

    User testUser = new User(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'testcontact@example.com',
        Username = 'testcontact@example.com.sandbox',
        Alias = 'tcon',
        TimeZoneSidKey = 'America/New_York',
        LocaleSidKey = 'en_US',
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = 'en_US',
        ProfileId = portalProfile.Id,
        ContactId = testContact.Id 
    );
    insert testUser;
        Test.startTest();

        List<User> usersInGroup = new SEL_User().selectUsersByGroup('Test Group 123');
        List<User> usersForCountries = new SEL_User().selectActiveWithPortfoliosByCountry(new Set<String>{'ZA', 'GH'});
        List<User> users = new SEL_User().selectUsersByIds(new Set<Id>{UserInfo.getUserId()});
        List<User> usersByIds = new SEL_User().getUsersByIds(new Set<Id>{UserInfo.getUserId()});
        List<User> userByContact =  new SEL_User().selectByContactId(testContact.Id);

        Test.stopTest();

        List<User> usersForCountriesCheck = [SELECT Id FROM User WHERE User_Country__c IN ('ZA', 'GH') AND isActive = true AND (RM_AE_Code__c != '' OR (Portfolio_Role_Name__c != '' AND Portfolio_Codes__c != '') ) ];

        Assert.areEqual(usersForCountriesCheck.size(), usersForCountries.size(), 'Incorrect number of users for ZA and GH');
        Assert.areEqual(0, usersInGroup.size(), 'Should be 0 users in the test group');
        Assert.areEqual(1, users.size(), 'Should only select 1 user');
        Assert.areEqual(1, usersByIds.size(), 'Should only return 1 user');
        Assert.areEqual(1, userByContact.size(), 'Should return 1 user for test contact ID');

    }


    @IsTest
    static void testSelectByName() {
        User u = Insurance_TestDataFactory.createTestUser();
        u.FirstName = 'Test';
        u.LastName = 'UserABC';
        insert u;

        Test.startTest();
        User queriedUser = new SEL_User().selectByName('Test UserABC');
        Test.stopTest();

        Assert.areNotEqual(null, queriedUser, 'User should be returned based on Name');
        Assert.areEqual(u.Id, queriedUser.Id, 'Returned user should match inserted user');
    }


    @IsTest
    static void testSelectUserById_Single() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;

        Test.startTest();
        User queriedUser = new SEL_User().selectUserById(u.Id);
        Test.stopTest();

        Assert.areNotEqual(null, queriedUser, 'User should be returned using selectUserById');
        Assert.areEqual(u.EmployeeNumber, queriedUser.EmployeeNumber, 'EmployeeNumber should match');
    }

    @IsTest
    static void testSelectUserById_Set() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;

        Test.startTest();
        List<User> queriedUsers = new SEL_User().selectUserById(new Set<Id>{u.Id});
        Test.stopTest();

        Assert.areEqual(1, queriedUsers.size(), 'One user should be returned for provided Id set');
        Assert.areEqual(u.Id, queriedUsers[0].Id, 'Returned user should match inserted user');
    }

    /**
* @description       : Test of the selector method SelectUserByEmployeeNumber
* @author            : Raja Arsalan
**/
    @IsTest
    static void testSelectUserByEmployeeNumber() {
        User u = Insurance_TestDataFactory.createTestUser();
        insert u;

        Set<String> empNumbers = new Set<String>{u.EmployeeNumber};

        Test.startTest();
        Map<String, User> userMap = new SEL_User().selectUserByEmployeeNumber(empNumbers);
        Test.stopTest();

        Assert.areEqual(u.Id, userMap.get(u.EmployeeNumber).Id, 'User ID should match for the Employee Number');
    }

     @IsTest
    static void testSelectUsersWithManagersByIds() {

        // Get a Profile (Standard User profile is safest in tests)
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        // Create Manager User
        User manager = new User(
            FirstName = 'Manager',
            LastName = 'User',
            Alias = 'mgrusr',
            Email = 'manager@test.com',
            Username = 'manager' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert manager;

        // Create User with Manager
        User usr = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@test.com',
            Username = 'testuser' + System.currentTimeMillis() + '@test.com',
            ProfileId = p.Id,
            ManagerId = manager.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert usr;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> result = usersrv.selectUsersWithManagersByIds(new Set<Id>{ usr.Id });
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'One user should be returned');
        Assert.areEqual(manager.Id, result[0].ManagerId, 'ManagerId should match');
    }
   
    @IsTest
    static void testSelectByUserName_Found() {
        // Get a Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueUsername = 'testuser' + System.currentTimeMillis() + '@test.com';
        // Create User
        User usr = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'test@test.com',
            Username = uniqueUsername,
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert usr;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> result = usersrv.selectByUserName(uniqueUsername);
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'One user should be returned');
        Assert.areEqual(uniqueUsername, result[0].Username, 'Username should match');
        Assert.areEqual(usr.Id, result[0].Id, 'Returned user should match inserted user');
    }
    
     @IsTest
    static void testSelectActiveWithFinancialAccountRestrictionCodesByCountry() {

        // Get profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueBase = String.valueOf(System.currentTimeMillis());

        //  Matching User (Should Be Returned)
        User matchingUser = new User(
            FirstName = 'Match',
            LastName = 'User',
            Alias = 'musr',
            Email = 'match' + uniqueBase + '@test.com',
            Username = 'match' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            User_Country__c = 'ZA',
            CMN_FinancialAccountRestrictionCodes__c = 'ABC',
            IsActive = true
        );
        insert matchingUser;

        //  Null Restriction Code
        User noRestriction = new User(
            FirstName = 'NoRestrict',
            LastName = 'User',
            Alias = 'nrusr',
            Email = 'nr' + uniqueBase + '@test.com',
            Username = 'nr' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            User_Country__c = 'ZA',
            IsActive = true
        );
        insert noRestriction;

        //  Different Country
        User differentCountry = new User(
            FirstName = 'Diff',
            LastName = 'Country',
            Alias = 'dcusr',
            Email = 'dc' + uniqueBase + '@test.com',
            Username = 'dc' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            User_Country__c = 'KE',
            CMN_FinancialAccountRestrictionCodes__c = 'XYZ',
            IsActive = true
        );
        insert differentCountry;

        //  Inactive User
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Alias = 'iausr',
            Email = 'ia' + uniqueBase + '@test.com',
            Username = 'ia' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            User_Country__c = 'ZA',
            CMN_FinancialAccountRestrictionCodes__c = 'DEF',
            IsActive = false
        );
        insert inactiveUser;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> results = usersrv.selectActiveWithFinancialAccountRestrictionCodesByCountry('ZA');
        Test.stopTest();
        // Assertions
        Assert.areEqual(1, results.size(), 'Only one user should match all filters');
        Assert.areEqual(matchingUser.Id, results[0].Id, 'Returned user should be the matching user');
    }
    
    /**
* @description       : Test of the selector method selectByEmail (SFP-58853)
* @author            : Irshad
**/
    @IsTest
    static void testSelectByEmail_ActiveUserFound() {
        // Get a Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueBase = String.valueOf(System.currentTimeMillis());
        String uniqueEmail = 'active' + uniqueBase + '@test.com';

        // Active user with the target email (Should Be Returned)
        User activeUser = new User(
            FirstName = 'Active',
            LastName = 'EmailUser',
            Alias = 'aeusr',
            Email = uniqueEmail,
            Username = 'active' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert activeUser;

        // Inactive user with the SAME email (Should Be Excluded)
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'EmailUser',
            Alias = 'ieusr',
            Email = uniqueEmail,
            Username = 'inactive' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> result = usersrv.selectByEmail(uniqueEmail);
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'Only the active user should be returned');
        Assert.areEqual(activeUser.Id, result[0].Id, 'Returned user should be the active user');
        Assert.areEqual(uniqueEmail, result[0].Email, 'Email should match');
    }

   /**
    * @description       : Test of the selector method selectByBaseUsername (SFP-58853)
    * @author            : Irshad
    **/
    @IsTest
    static void testSelectByBaseUsername_MatchesSandboxSuffix() {
        // Get a Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueBase = String.valueOf(System.currentTimeMillis());
        String baseUsername = 'sbguser' + uniqueBase + '@test.com';

        // User whose username is base + sandbox suffix (Should Be Returned)
        User sandboxUser = new User(
            FirstName = 'Sandbox',
            LastName = 'User',
            Alias = 'sbusr',
            Email = 'sb' + uniqueBase + '@test.com',
            Username = baseUsername + '.uat',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert sandboxUser;

        // User with a non-matching username (Should Be Excluded)
        User otherUser = new User(
            FirstName = 'Other',
            LastName = 'User',
            Alias = 'otusr',
            Email = 'ot' + uniqueBase + '@test.com',
            Username = 'different' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert otherUser;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> result = usersrv.selectByBaseUsername(baseUsername);
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'One user should match the base username pattern');
        Assert.areEqual(sandboxUser.Id, result[0].Id, 'Returned user should be the sandbox-suffixed user');
        Assert.isTrue(result[0].Username.startsWith(baseUsername), 'Username should start with the base username');
    }

    /**
    * @description       : Test of the selector method selectByEmail (SFP-55746)
    * @author            : Irshad
    **/
    @IsTest
    static void testSelectByUserEmail_Found() {
        // Get a Profile
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        String uniqueBase = String.valueOf(System.currentTimeMillis());
        String uniqueEmail = 'byemail' + uniqueBase + '@test.com';

        // Create User
        User usr = new User(
            FirstName = 'ByEmail',
            LastName = 'User',
            Alias = 'beusr',
            Email = uniqueEmail,
            Username = 'byemail' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert usr;

        Test.startTest();
        SEL_User usersrv = new SEL_User();
        List<User> result = usersrv.selectByUserEmail(uniqueEmail);
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'One user should be returned for the email');
        Assert.areEqual(usr.Id, result[0].Id, 'Returned user should match inserted user');
        Assert.areEqual(uniqueEmail, result[0].Email, 'Email should match');
    }

    /**
    * @description       : Negative path for selectByUserName - no match returns empty list
    * @author            : Irshad
    **/
        @IsTest
        static void testSelectByUserName_NotFound() {
            Test.startTest();
            SEL_User usersrv = new SEL_User();
            List<User> result = usersrv.selectByUserName('nonexistent' + System.currentTimeMillis() + '@test.com');
            Test.stopTest();
    
            // Assertions
            Assert.areEqual(0, result.size(), 'No users should be returned for a nonexistent username');
        }

    /**
    * @description       : Test of newInstance via the ORG_Application selector factory
    **/
    @IsTest
    static void testNewInstance() {
        Test.startTest();
        SEL_User selector = SEL_User.newInstance();
        Test.stopTest();

        Assert.isNotNull(selector, 'newInstance should return a SEL_User selector');
        Assert.areEqual(User.SObjectType, selector.getSObjectType(), 'Selector should be for the User object');
    }

    /**
    * @description       : Test of the selector method selectUsersWithManagerChainByIds (SFP-55654)
    **/
    @IsTest
    static void testSelectUsersWithManagerChainByIds() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueBase = String.valueOf(System.currentTimeMillis());

        // Build a 3-level chain: seed -> manager -> senior manager
        User seniorManager = new User(
            FirstName = 'Senior',
            LastName = 'Manager',
            Alias = 'smgr',
            Email = 'smgr' + uniqueBase + '@test.com',
            Username = 'smgr' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert seniorManager;

        User manager = new User(
            FirstName = 'Chain',
            LastName = 'Manager',
            Alias = 'cmgr',
            Email = 'cmgr' + uniqueBase + '@test.com',
            Username = 'cmgr' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            ManagerId = seniorManager.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert manager;

        User seed = new User(
            FirstName = 'Chain',
            LastName = 'Seed',
            Alias = 'cseed',
            Email = 'cseed' + uniqueBase + '@test.com',
            Username = 'cseed' + uniqueBase + '@test.com',
            ProfileId = p.Id,
            ManagerId = manager.Id,
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert seed;

        Test.startTest();
        List<User> result = new SEL_User().selectUsersWithManagerChainByIds(new Set<Id>{ seed.Id });
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'One seed user should be returned');
        Assert.areEqual(manager.Id, result[0].ManagerId, 'Level 1 manager should match');
        Assert.areEqual(manager.Email, result[0].Manager.Email, 'Level 1 manager email should be populated');
        Assert.areEqual(seniorManager.Id, result[0].Manager.ManagerId, 'Level 2 manager should match');
        Assert.areEqual(seniorManager.Email, result[0].Manager.Manager.Email, 'Level 2 manager email should be populated');
    }
}