/*******************************************************************
* @Name of the Class : ICS_API_AuthRegistrationHandlerPing_Test.cls
* @description       : Test class for ICS_API_AuthRegistrationHandlerPing
* Story              : SFP-31800
* @author            : Ikyatha Naidu
* @date              : 23-03-2024
***************************************************************
* @last modified on  : 29-06-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
*******************************************************************/
@IsTest
private class ICS_API_AuthRegistrationHandlerPing_Test {
    // Constants
    private static final String KEY_NETWORK = ICS_CTRL_AuthRegistrationHandler.KEY_NETWORK;
    private static final String KEY_CELLPHONE = 'cellphonenumber';
    private static final String KEY_DATE_OF_BIRTH = 'dateofbirth';
    private static final String KEY_FIRST_NAME = 'first_name';
    private static final String KEY_LAST_NAME = 'last_name';
    private static final String KEY_ID = 'id';

    // Test data
    private static final String TEST_FIRST_NAME = 'TestACC';
    private static final String TEST_LAST_NAME = 'testet';
    private static final String TEST_EMAIL = 'test@example.com';
    private static final String TEST_PING_ID = '12345';
    private static final String TEST_CELLPHONE = '1112223333';
    private static final String TEST_DATE_OF_BIRTH = '17/01/1975';
    private static final String TEST_NETWORK = 'myNetwork';

    @TestSetup
    static void setupTestData() {
        // Create a  Contact
         Account acc = ICS_DAL_TestFactory.createAccount();
        acc.ExternalCIFCountry__c='OS';
        acc.Ping_Id__pc =TEST_PING_ID;
        acc.PersonEmail = TEST_EMAIL;
         update acc;
      

    }

    /**
     * @description This method tests the extractUserData method
     */  
    @IsTest
    static void extractUserData() {
        // Sample user data
        Map<String, String> attributes = new Map<String, String>{
            KEY_ID => TEST_PING_ID,
            KEY_FIRST_NAME => TEST_FIRST_NAME,
            KEY_LAST_NAME => TEST_LAST_NAME,
            KEY_CELLPHONE => TEST_CELLPHONE,
            KEY_DATE_OF_BIRTH => TEST_DATE_OF_BIRTH,
            KEY_NETWORK => TEST_NETWORK
        };

        Auth.UserData userData = new Auth.UserData(
            null, null, null, null, TEST_EMAIL, null, null, null, null, null, attributes
        );

        ICS_API_AuthRegistrationHandlerPing authRegistrationHandlerPing = new MockRegistrationHandler();

        Test.startTest();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper = authRegistrationHandlerPing.extractUserData(userData);
        Test.stopTest();

        Assert.areEqual(TEST_PING_ID, userDataWrapper.id, 'The identifier should match');
        Assert.areEqual(TEST_FIRST_NAME, userDataWrapper.firstName, 'The first name should match');
        Assert.areEqual(TEST_LAST_NAME, userDataWrapper.lastName, 'The last name should match');
        Assert.areEqual(TEST_EMAIL, userDataWrapper.email, 'The email should match'); 
        Assert.areEqual(TEST_DATE_OF_BIRTH, userDataWrapper.dateOfBirth, 'The date of birth should match');
    }
    private static Auth.UserData createTestUserData() {
        Map<String, String> attributes = new Map<String, String>{
            'id' => 'testId',
            ICS_CTRL_AuthRegistrationHandler.KEY_NETWORK => '11111'
        };
        return new Auth.UserData(
            'testId', TEST_FIRST_NAME, TEST_LAST_NAME,
            TEST_FIRST_NAME + ' ' + TEST_LAST_NAME,
            TEST_EMAIL, null, TEST_EMAIL, 'en_US', 'Ping',
            null, attributes
        );
    }

    /**
     * @description This method tests the findContactForUser method when a contact is found
     */ 
    @IsTest
    static void findContactForUserFound() {
        ICS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();
        Auth.UserData userData = createTestUserData();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new ICS_CTRL_AuthRegistrationHandler.UserDataWrapper(userData);
        userDataWrapper.id = TEST_PING_ID;

        Test.startTest();
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);
        Test.stopTest();

        Assert.isNotNull(foundContact, 'The contact should be found');
        Assert.areEqual(TEST_FIRST_NAME, foundContact.FirstName, 'The first name should match');
        Assert.areEqual(TEST_LAST_NAME, foundContact.LastName, 'The last name should match');
        Assert.areEqual(TEST_EMAIL, foundContact.Email, 'The email should match');
    }

    /**
     * @description This method tests the findContactForUser method when no contact is found
     */
    @IsTest
    static void findContactForUserNotFound() {
        ICS_API_AuthRegistrationHandlerPing authRegistrationHandler = new MockRegistrationHandler();
        Auth.UserData userData = createTestUserData();
        ICS_CTRL_AuthRegistrationHandler.UserDataWrapper userDataWrapper = new ICS_CTRL_AuthRegistrationHandler.UserDataWrapper(userData);
        userDataWrapper.email = 'nonexistent@test.com';

        Test.startTest();
        Contact foundContact = authRegistrationHandler.findContactForUser(null, userDataWrapper);
        Test.stopTest();

        Assert.isNull(foundContact, 'No contact should be found'); 
    }

    /**
     * @description Mock class extending ICS_API_AuthRegistrationHandlerPing for testing purposes
     */
    private class MockRegistrationHandler extends ICS_API_AuthRegistrationHandlerPing {
        /**
         * @description Overriding verifyUserAccessForCreate method for testing
         */
        public override ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForCreate(Contact contact, UserDataWrapper userDataWrapper) {
            return null;
        }

        /**
         * @description Overriding verifyUserAccessForUpdate method for testing
         */
        public override ICS_CTRL_AuthRegistrationHandler.UserAccessCheckResult verifyUserAccessForUpdate(Contact contact) {
            return null;
        }
    }
}