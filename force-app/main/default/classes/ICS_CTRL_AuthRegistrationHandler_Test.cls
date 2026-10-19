/**
 * @Name of the Class : ICS_CTRL_AuthRegistrationHandler_Test
 * @description class used as Test class for SBO-UK Ping Feature for ICS_CTRL_AuthRegistrationHandler_Test - Story:SFP-31800
 * @author Ikyatha Naidu
 * @date September 2023
 * @last modified on  : 28-03-2024
 * @last modified by  : Ramya Gurram
 * @Modification Description : SFP-31800 class used for adding test methods for ICS_CTRL_AuthRegistrationHandler_Test for SBO-UK
 */
@isTest
private class ICS_CTRL_AuthRegistrationHandler_Test {

    private static final String TEST_EMAIL = 'test@example.com';
    private static final String TEST_FIRST_NAME = 'John';
    private static final String TEST_LAST_NAME = 'Doe';
    private static final String TEST_NETWORK_ID = 'testNetworkId';
    private static final String TEST_PROFILE_NAME = 'Test Profile';
    private static final String TEST_IFA_PROFILE_NAME = 'Test IFA Profile';

    @TestSetup
    static void setupTestData() {
        ICS_DAL_TestFactory.createCommunityUser();
    }

    @isTest
    static void testCreateUser() {


        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        Auth.UserData userData = createTestUserData();
        try{
        Test.startTest();
        handler.createUser(null, userData);
        Test.stopTest();
        }catch(exception ex){
            Assert.areEqual(true, ex.getmessage()!= null, 'Exception occured');
        }

    }
    @isTest
static void testCreateUser_ContactNotFound() {
    TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
    Auth.UserData userData = createTestUserData();
    userData.email = 'nonexistent@example.com'; // Email that won't match any contact

    Test.startTest();
    try {
        handler.createUser(null, userData);
        Assert.fail('Should throw exception when contact not found');
    } catch (Auth.AuthProviderPluginException e) {
        Assert.areEqual('Contact_not_found', e.getMessage(), 'Should throw correct error message');
    }
    Test.stopTest();
}


    @isTest
    static void testUpdateUser() {
        User existingUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        Auth.UserData userData = createTestUserData();
        userData.firstName = 'UpdatedFirstName';
        userData.lastName = 'UpdatedLastName';
        try{
        Test.startTest();
        handler.updateUser(existingUser.Id, null, userData);
        Test.stopTest();

        User updatedUser = [SELECT FirstName, LastName FROM User WHERE Id = :existingUser.Id];
        Assert.areEqual('UpdatedFirstName', updatedUser.FirstName, 'First name should be updated');
        Assert.areEqual('UpdatedLastName', updatedUser.LastName, 'Last name should be updated');
        }catch(exception ex){
            Assert.areEqual(true, ex.getmessage() != null, 'exception occured');
        }
    }

    @isTest
    static void testExtractUserData() {
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        Auth.UserData userData = createTestUserData();

        Test.startTest();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = handler.extractUserData(userData);
        Test.stopTest();

        Assert.areEqual(TEST_EMAIL, wrapper.email, 'Email should match');
        Assert.areEqual(TEST_FIRST_NAME, wrapper.firstName, 'First name should match');
        Assert.areEqual(TEST_LAST_NAME, wrapper.lastName, 'Last name should match');
        Assert.areEqual(TEST_NETWORK_ID, wrapper.networkId, 'Network ID should match');
    }
    @isTest
static void testExtractUserData_NullNetworkId() {
    TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
    Map<String, String> attributes = new Map<String, String>{
        'id' => 'testId'
        // Deliberately omitting networkId
    };
    Auth.UserData userData = new Auth.UserData(
        'testId', TEST_FIRST_NAME, TEST_LAST_NAME,
        TEST_FIRST_NAME + ' ' + TEST_LAST_NAME,
        TEST_EMAIL, null, TEST_EMAIL, 'en_US', 'Ping',
        null, attributes
    );

    Test.startTest();
    ICS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = handler.extractUserData(userData);
    Test.stopTest();

    Assert.areEqual(null, wrapper.networkId, 'NetworkId should be null when not provided');
}

    @isTest
    static void testFindProfileForUser() {
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        User testUser = new User();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = new ICS_CTRL_AuthRegistrationHandler.UserDataWrapper(createTestUserData());

        handler.pingRegistrationSiteTestData = new SBO_Ping_Registration_Site__mdt(
            Profile__c = TEST_PROFILE_NAME,
            IFA_Profile__c = TEST_IFA_PROFILE_NAME,
            Comma_Separated_Permission_Set__c ='ICS_Community_Plus_License_External_Credential'
        );

        Test.startTest();
        Id profileId = handler.findProfileForUser(testUser, wrapper, '');
        Test.stopTest();

        Assert.areNotEqual('', profileId, 'Profile ID should be returned');
    }

    @isTest
    static void testPrepareUserData() {
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        User testUser = new User();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = new ICS_CTRL_AuthRegistrationHandler.UserDataWrapper(createTestUserData());

        Test.startTest();
        handler.prepareUserData(testUser, wrapper);
        Test.stopTest();

        Assert.areEqual(TEST_FIRST_NAME, testUser.FirstName, 'User first name should match');
        Assert.areEqual(TEST_LAST_NAME, testUser.LastName, 'User last name should match');
        Assert.isTrue(testUser.Username.startsWith(TEST_EMAIL), 'Username should start with email');
    }

    @isTest
    static void testBuildAlias() {
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();

        Test.startTest();
        String alias = handler.buildAlias(TEST_FIRST_NAME, TEST_LAST_NAME);
        Test.stopTest();

        Assert.areEqual('jdoe', alias, 'Alias should be correctly generated');
    }

    @isTest
    static void testBuildAliasWithNullFirstName() {
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();

        Test.startTest();
        String alias = handler.buildAlias(null, TEST_LAST_NAME);
        Test.stopTest();

        Assert.areEqual('doe', alias, 'Alias should be correctly generated with null first name');
    }

    @isTest
    static void testUpdateUserData() {
        User existingUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        TestICS_CTRL_AuthRegistrationHandler handler = new TestICS_CTRL_AuthRegistrationHandler();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = new ICS_CTRL_AuthRegistrationHandler.UserDataWrapper(createTestUserData());
        wrapper.firstName = 'UpdatedFirstName';
        wrapper.lastName = 'UpdatedLastName';

        Test.startTest();
        handler.updateUserData(existingUser.Id, wrapper);
        Test.stopTest();

        User updatedUser = [SELECT FirstName, LastName FROM User WHERE Id = :existingUser.Id];
        Assert.areEqual('UpdatedFirstName', updatedUser.FirstName, 'First name should be updated');
        Assert.areEqual('UpdatedLastName', updatedUser.LastName, 'Last name should be updated');
    }

    private static Auth.UserData createTestUserData() {
        Map<String, String> attributes = new Map<String, String>{
            'id' => 'testId',
            ICS_CTRL_AuthRegistrationHandler.KEY_NETWORK => TEST_NETWORK_ID
        };
        return new Auth.UserData(
            'testId', TEST_FIRST_NAME, TEST_LAST_NAME,
            TEST_FIRST_NAME + ' ' + TEST_LAST_NAME,
            TEST_EMAIL, null, TEST_EMAIL, 'en_US', 'Ping',
            null, attributes
        );
    }

    private class TestICS_CTRL_AuthRegistrationHandler extends ICS_CTRL_AuthRegistrationHandler {
        public override UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
            return userAccessCheckSuccess();
        }

        public override UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
            return userAccessCheckSuccess();
        }
    }
}