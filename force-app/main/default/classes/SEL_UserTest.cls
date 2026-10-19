/**
* @File Name : SEL_UserTest .cls
* @Description :Test class for SEL_User selector class
* @Author :Rahul.Mamidala@standardbank.co.za
* @Modification Log :Rahul.Mamidala@standardbank.co.za
* Ver | Date | Author | Modification
* 1.0 | April 29, 2025 |   | Initial Version
*
* @Last Modified By : Jaco de Lange
* @Last Modified On : 10-28-2025
* @Modification : SFP-54086 - Add test for selectByUserName
*
* @Last Modified By : Alex Niyonsaba
* @Last Modified On : 27-01-2025
* @Last Modified Reason : Add Select active users by country, with financial account restriction codes assigned test method.
* @User Story: SFP-55187
**/
@IsTest
private class SEL_UserTest {
    private static final String LOCALE = 'en_US';
    private static final String EMAIL_SUFFIX = '@test.org';

    /** Utility: creates a test user safely **/
    private static User createTestUser(String alias, String emailSuffix) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
            Alias = alias,
            CompanyName = 'Standard Bank',
            Email = alias + emailSuffix,
            EmailEncodingKey = 'UTF-8',
            LastName = alias + '_Last',
            FirstName = alias + '_First',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE,
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Nairobi',
            Username = alias + emailSuffix + '.' + System.currentTimeMillis(),
            Country = 'Kenya',
            User_Country__c = 'KE',
            IsActive = true,
            CMN_FinancialAccountRestrictionCodes__c = '001',
            EmployeeNumber = String.valueOf(Math.abs(Crypto.getRandomInteger()))
        );
        insert u;
        return u;
    }

    @IsTest
    static void testSelectUserById_Single() {
        User testUser = createTestUser('usr1', EMAIL_SUFFIX);

        Test.startTest();
        SEL_User selector = new SEL_User();
        User result = selector.selectUserById(testUser.Id);
        Test.stopTest();

       assert.areNotEqual(null, result, 'Should return a user');
       assert.areEqual(testUser.Id, result.Id, 'Returned user should match test user');
        
    }

    @IsTest
    static void testSelectUserById_Set() {
        User testUser = createTestUser('usr2', EMAIL_SUFFIX);
        Set<Id> userIds = new Set<Id>{ testUser.Id };

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectUserById(userIds);
        Test.stopTest();

        assert.areEqual(1, result.size(), 'Should return one user');
        assert.areEqual(testUser.Id, result[0].Id, 'User Ids should match');
    }

    @IsTest
    static void testSelectUsersByIds() {
        User u1 = createTestUser('usr3', EMAIL_SUFFIX);
        Set<Id> ids = new Set<Id>{ u1.Id };

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectUsersByIds(ids);
        Test.stopTest();

        assert.areNotEqual(0, result.size(), 'Should return user list');
        assert.areEqual(u1.Id, result[0].Id, 'User Ids should match');
    }

    @IsTest
    static void testSelectUsersByGroup() {
        User u = createTestUser('usr4', EMAIL_SUFFIX);
        Group g = new Group(Name = 'TestGroup', Type = 'Regular');
        insert g;

        insert new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectUsersByGroup('TestGroup');
        Test.stopTest();

        assert.areEqual(1, result.size(), 'Should find the user in group');
        assert.areEqual(u.Id, result[0].Id, 'User Ids should match');
    }

    @IsTest
    static void testSelectByName() {
        User u = createTestUser('usr5', EMAIL_SUFFIX);
        
        String custName = u.FirstName+' '+u.LastName;

        Test.startTest();
        SEL_User selector = new SEL_User();
        User result = selector.selectByName(custName);
        Test.stopTest();

        assert.areNotEqual(null, result, 'Should return a user by name');
        assert.areEqual(custName, result.Name, 'Customer names should be the same');
    }

    @IsTest
    static void testSelectActiveWithPortfoliosByCountry() {
        User u = createTestUser('usr6', EMAIL_SUFFIX);
        u.RM_AE_Code__c = '123';
        update u;

        Set<String> countries = new Set<String>{ 'KE' };

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectActiveWithPortfoliosByCountry(countries);
        Test.stopTest();

        assert.areNotEqual(0, result.size(), 'Should return active users in country with portfolio');
    }

    @IsTest
    static void testSelectUserByEmployeeNumber() {
        User u = createTestUser('usr7', EMAIL_SUFFIX);
        Set<String> empNos = new Set<String>{ u.EmployeeNumber };

        Test.startTest();
        SEL_User selector = new SEL_User();
        Map<String, User> result = selector.selectUserByEmployeeNumber(empNos);
        Test.stopTest();

		assert.areEqual(u.Id, result.get(u.EmployeeNumber).Id, 'Employee numbers should match');
    }

    @IsTest
    static void testSelectByContactId() {
        // Create related contact and user
        Account acc = new Account(Name = 'TestAcc');
        insert acc;

        Contact c = new Contact(FirstName = 'Con', LastName = 'User', AccountId = acc.Id, Email = 'usr8@test.org');
        insert c;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        User u = new User(
            Alias = 'usr8',
            Email = 'usr8@test.org',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Usr8',
            FirstName = 'Usr8',
            LanguageLocaleKey = LOCALE,
            LocaleSidKey = LOCALE,
            ProfileId = p.Id,
            TimeZoneSidKey = 'Africa/Nairobi',
            Username = 'usr8@test.org.' + System.currentTimeMillis(),
            ContactId = c.Id
        );
        insert u;

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectByContactId(c.Id);
        Test.stopTest();

        assert.areEqual(1, result.size(), 'Should find user by contact id');
        assert.areEqual(u.Id, result[0].Id, 'Partner user found');
    }

    @IsTest
    static void testSelectByUserName() {
        User u = createTestUser('usr10', EMAIL_SUFFIX);

        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectByUserName(u.Username);
        Test.stopTest();

 		assert.areEqual(1, result.size(), 'Should return user by username');
        assert.areEqual(u.Id, result[0].Id, 'User Ids must match');
    }

    @IsTest
    static void testSelectActiveWithFinancialAccountRestrictionCodesByCountry() {
        User u = createTestUser('usr10', EMAIL_SUFFIX);
        Test.startTest();
        SEL_User selector = new SEL_User();
        List<User> result = selector.selectActiveWithFinancialAccountRestrictionCodesByCountry('KE');
        Test.stopTest();

 		assert.areEqual(1, result.size(), 'Should return user');
        assert.areEqual(u.Id, result[0].Id, 'User Ids must match');
    }
}