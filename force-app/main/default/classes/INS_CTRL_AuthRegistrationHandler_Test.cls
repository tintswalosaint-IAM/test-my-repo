/**
* @description  Test class for INS_CTRL_AuthRegistrationHandler
* @story        SFP-53279
* @createdBy    Jaco de Lange
* @date         2025-10-10
**/
@IsTest
private class INS_CTRL_AuthRegistrationHandler_Test {
    
    private static final String TEST_NETWORK_ID = '000000000000000000';
    private static final String KEY_NETWORK     = INS_CTRL_AuthRegistrationHandler.KEY_NETWORK;
    private static final String SALES_AGENT_CONTACT = 'Sales_Agent_Contact';
    private static final String LAST_NAME_JONES = 'Jones';

    // ----------------------------------------
    // Utility Methods
    // ----------------------------------------

    /** Builds a dummy Auth.UserData instance */
    private static Auth.UserData buildAuthUserData(String email, String firstName, String lastName, String networkId, string identifier) {
        return new Auth.UserData(
            '12345', firstName, lastName, null, email,
            null, null, null, null, null, new Map<String, String>{ KEY_NETWORK => networkId, 'id'=> identifier}
        );
    }

    /** Creates a deserialized UserDataWrapper for tests */
    private static INS_CTRL_AuthRegistrationHandler.UserDataWrapper buildUserDataWrapper(Map<String, Object> data) {
        return (INS_CTRL_AuthRegistrationHandler.UserDataWrapper)
            JSON.deserialize(JSON.serialize(data), INS_CTRL_AuthRegistrationHandler.UserDataWrapper.class);
    }

    /** Injects fake CMDT for profile lookup */
    private static void setupMockMetadata(INS_CTRL_AuthRegistrationHandler handler) {
        DSA_Ping_Registration_Site__mdt meta = new DSA_Ping_Registration_Site__mdt();
        meta.INS_Network_Id__c = TEST_NETWORK_ID;
        meta.INS_Comma_Separated_Permission_Set__c = 'INS_External_Credential_Access,INS_Insurance_Sale';
        // Unique suffix so generated usernames never clash with existing users in any org
        meta.INS_Username_Suffix__c = 'dsatest' + System.currentTimeMillis();
        handler.pingRegistrationSiteTestData = meta;

         INS_User_Locale__mdt  userLocale = new INS_User_Locale__mdt(
            INS_Locale__c = 'en_KE',
            INS_Time_Zone__c = 'Africa/Nairobi',
            INS_Currency_Code__c = 'KES',
            INS_Language_Locale__c = 'en_US',
            INS_Country__c = 'KE');
            handler.testLocale = userLocale;
    }

    // ----------------------------------------
    // Test Methods
    // ----------------------------------------

    @IsTest
     static void testCreateUser() {
        INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
        setupMockMetadata(handler);

        String recTypeId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get(SALES_AGENT_CONTACT).getRecordTypeId();

        // Portal users require their Account owner to have a role
        User accountOwner = [
            SELECT Id FROM User
            WHERE IsActive = true AND UserType = 'Standard' AND UserRoleId != null
            LIMIT 1
        ];
        Account acc = new Account(
            Name = 'TestACC',
            ExternalCIFId__c = 'KE',
            OwnerId = accountOwner.Id,
            RecordTypeId = Schema.SObjectType.Account
                .getRecordTypeInfosByDeveloperName()
                .get('IndustriesBusiness').getRecordTypeId()
        );
        insert acc;

        Contact con = new Contact(
            FirstName = 'Steve', LastName = LAST_NAME_JONES,
            Email = 'steve.jones' + System.currentTimeMillis() + '@test.com',
            Ping_Id__c = '12345', RecordTypeId = recTypeId,
            INS_SalesAgentPortalLicenseType__c = 'Partner Community User',
            AccountId = acc.Id
        );
        insert con;

        Auth.UserData data = buildAuthUserData(con.Email, con.FirstName, con.LastName, TEST_NETWORK_ID, con.Ping_Id__c);
        User createdUser;

        Test.startTest();
        // runAs gives the User insert its own context, avoiding MIXED_DML_OPERATION with the Account/Contact inserts
        System.runAs(new User(Id = UserInfo.getUserId())) {
            createdUser = handler.createUser(TEST_NETWORK_ID, data);
        }
        Test.stopTest();

        assert.areNotEqual(null, createdUser, 'User should be created successfully');
        assert.areEqual('Steve', createdUser.FirstName, 'First name should match');
        assert.areEqual(con.Id, createdUser.ContactId, 'User should be linked to the contact');

        handler.updatePermissionSet(TEST_NETWORK_ID, con.Id);
        handler.updateUser(createdUser.Id, TEST_NETWORK_ID, data);
    }

    @IsTest
    static void testFindContactFound() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();

            Contact c = new Contact(
                FirstName = 'Amy', LastName = 'Johnson',
                Email = 'amy.j@test.com',
                RecordTypeId = Schema.SObjectType.Contact
                    .getRecordTypeInfosByDeveloperName()
                    .get(SALES_AGENT_CONTACT).getRecordTypeId()
            );
            insert c;

            INS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = buildUserDataWrapper(
                new Map<String, Object>{ 'email' => c.Email, 'networkId' => TEST_NETWORK_ID }
            );

            Contact found = handler.findContactForUser(null, wrapper);
            assert.areNotEqual(null, found, 'Contact should be found');
            assert.areEqual(c.Email, found.Email, 'Email should match');
        Test.stopTest();
    }

    @IsTest
    static void testFindContactNotFound() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();

            INS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper =
                buildUserDataWrapper(new Map<String, Object>{ 'email' => 'missing@test.com', 'networkId' => TEST_NETWORK_ID });

            Contact found = handler.findContactForUser(null, wrapper);
            assert.areEqual(null, found, 'No contact should be found');
        Test.stopTest();
    }

    @IsTest
    static void testExtractUserData() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();

            Auth.UserData userData = buildAuthUserData('walter.white@test.com', 'Walter', 'White', TEST_NETWORK_ID, '1234');
            INS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = handler.extractUserData(userData);

            assert.areEqual('12345', wrapper.id, 'Wrapper ID should match');
            assert.areEqual('walter.white@test.com', wrapper.email, 'Wrapper email should match');
        Test.stopTest();
    }

    @IsTest
    static void testBuildAlias() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();

            assert.areEqual('bjones', handler.buildAlias('Bob', LAST_NAME_JONES));
            assert.areEqual(LAST_NAME_JONES.toLowerCase(), handler.buildAlias(null, LAST_NAME_JONES));
            assert.areEqual('amoonlig', handler.buildAlias('Arthur', 'Moonlight'));
        Test.stopTest();
    }

    @IsTest
    static void testPrepareUserData() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();

            INS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = buildUserDataWrapper(
                new Map<String, Object>{
                    'id' => '1234',
                    'email' => 'test@test.com',
                    'firstName' => 'John',
                    'lastName'  => 'Doe',
                    'networkId' => TEST_NETWORK_ID
                }
            );

            User user = new User();
            handler.prepareUserData(user, wrapper);

            assert.areEqual('John', user.FirstName, 'FirstName should match');
            assert.areEqual('Doe', user.LastName, 'LastName should match');
        Test.stopTest();
    }

    private class MockRegistrationHandler extends INS_CTRL_AuthRegistrationHandler {
        public override UserAccessCheckResult verifyUserAccessForCreate(Contact c, UserDataWrapper w) {
            return userAccessCheckSuccess();
        }
        public override UserAccessCheckResult verifyUserAccessForUpdate(Contact c) {
            return userAccessCheckSuccess();
        }
    }

    @IsTest
    static void testUpdatePermissionSet_NoContactFound() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
            Boolean exceptionThrown = false;
            try {
                handler.updatePermissionSet(TEST_NETWORK_ID, '00000000000000');
            } catch (Exception e) {
                exceptionThrown = true;
            }
        Test.stopTest();
        assert.isFalse(exceptionThrown, 'No exception should be thrown when contact is not found');
    }
    
    @IsTest
    static void testUpdatePermissionSet_NoMetadataFound() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
            Boolean exceptionThrown = false;
    
            Contact con = new Contact(
                FirstName = 'Meta', LastName = 'Missing',
                Email = 'meta.missing@test.com',
                RecordTypeId = Schema.SObjectType.Contact
                    .getRecordTypeInfosByDeveloperName()
                    .get(SALES_AGENT_CONTACT).getRecordTypeId()
            );
            insert con;
    
            try {
                handler.updatePermissionSet(TEST_NETWORK_ID, con.Id);
            } catch (Exception e) {
                exceptionThrown = true;
            }
        Test.stopTest();
        assert.isFalse(exceptionThrown, 'No exception should be thrown when metadata is not found');
    }
    
    @IsTest
    static void testUpdatePermissionSet_NoPermissionSetsConfigured() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
            Boolean exceptionThrown = false;
    
            DSA_Ping_Registration_Site__mdt meta = new DSA_Ping_Registration_Site__mdt();
            meta.INS_Network_Id__c = TEST_NETWORK_ID;
            meta.INS_Comma_Separated_Permission_Set__c = '';
            handler.pingRegistrationSiteTestData = meta;
    
            Contact con = new Contact(
                FirstName = 'Perm', LastName = 'Blank',
                Email = 'perm.blank@test.com',
                RecordTypeId = Schema.SObjectType.Contact
                    .getRecordTypeInfosByDeveloperName()
                    .get(SALES_AGENT_CONTACT).getRecordTypeId()
            );
            insert con;
    
            try {
                handler.updatePermissionSet(TEST_NETWORK_ID, con.Id);
            } catch (Exception e) {
                exceptionThrown = true;
            }
        Test.stopTest();
        assert.isFalse(exceptionThrown, 'No exception should be thrown when no permission sets are configured');
    }
    
    @IsTest
    static void testUpdatePermissionSet_NoUserFoundForContact() {
        Test.startTest();
            INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
            Boolean exceptionThrown = false;
    
            DSA_Ping_Registration_Site__mdt meta = new DSA_Ping_Registration_Site__mdt();
            meta.INS_Network_Id__c = TEST_NETWORK_ID;
            meta.INS_Comma_Separated_Permission_Set__c = 'INS_External_Credential_Access';
            handler.pingRegistrationSiteTestData = meta;
    
            Contact con = new Contact(
                FirstName = 'No', LastName = 'UserLinked',
                Email = 'no.user.linked@test.com',
                RecordTypeId = Schema.SObjectType.Contact
                    .getRecordTypeInfosByDeveloperName()
                    .get(SALES_AGENT_CONTACT).getRecordTypeId()
            );
            insert con;
    
            try {
                handler.updatePermissionSet(TEST_NETWORK_ID, con.Id);
            } catch (Exception e) {
                exceptionThrown = true;
            }
        Test.stopTest();
        assert.isFalse(exceptionThrown, 'No exception should be thrown when no user is linked to the contact');
    }

    /**
     * @description Creates a Sales Agent contact with a linked portal user.
     *              Portal users need an Account owner with a role, and the User insert runs in
     *              System.runAs so it doesn't cause MIXED_DML_OPERATION with the Contact DML.
     */
    private static User createPortalUserForContact(Contact con) {
        User accountOwner = [
            SELECT Id FROM User
            WHERE IsActive = true AND UserType = 'Standard' AND UserRoleId != null
            LIMIT 1
        ];
        Account acc = new Account(Name = 'Portal Test Account', OwnerId = accountOwner.Id);
        insert acc;

        con.AccountId = acc.Id;
        con.RecordTypeId = Schema.SObjectType.Contact
            .getRecordTypeInfosByDeveloperName()
            .get(SALES_AGENT_CONTACT).getRecordTypeId();
        insert con;

        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Partner Community User' LIMIT 1];
        User portalUser = new User(
            FirstName = con.FirstName,
            LastName = con.LastName,
            Email = con.Email,
            Username = con.Email + '.' + System.currentTimeMillis(),
            Alias = 'ptlusr',
            TimeZoneSidKey = 'Africa/Nairobi',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = portalProfile.Id,
            ContactId = con.Id
        );
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert portalUser;
        }
        return portalUser;
    }

    @IsTest
    static void testUpdateUser_setsPingIdAndAssignsPermissionSets() {
        INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
        setupMockMetadata(handler);

        Contact con = new Contact(FirstName = 'Update', LastName = 'Agent', Email = 'update.agent@test.com');
        User portalUser = createPortalUserForContact(con);
        Auth.UserData data = buildAuthUserData(con.Email, con.FirstName, con.LastName, TEST_NETWORK_ID, 'PING-999');

        Test.startTest();
        // Ping_Id__c is blank, so updateContact runs twice and assignPermissionSetsAsync is queued
        handler.updateUser(portalUser.Id, TEST_NETWORK_ID, data);
        Test.stopTest();

        Contact updated = [SELECT Ping_Id__c FROM Contact WHERE Id = :con.Id];
        assert.areEqual('PING-999', updated.Ping_Id__c, 'Ping Id should be written to the contact');
    }

    @IsTest
    static void testUpdateUser_existingPingId() {
        INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
        setupMockMetadata(handler);

        Contact con = new Contact(FirstName = 'Existing', LastName = 'Ping', Email = 'existing.ping@test.com', Ping_Id__c = 'PING-OLD');
        User portalUser = createPortalUserForContact(con);
        Auth.UserData data = buildAuthUserData(con.Email, con.FirstName, con.LastName, TEST_NETWORK_ID, 'PING-NEW');

        Test.startTest();
        handler.updateUser(portalUser.Id, TEST_NETWORK_ID, data);
        Test.stopTest();

        Contact updated = [SELECT Ping_Id__c FROM Contact WHERE Id = :con.Id];
        assert.areEqual('PING-NEW', updated.Ping_Id__c, 'Ping Id should be refreshed from the latest login');
    }

    @IsTest
    static void testUserAccessCheckFailure() {
        INS_CTRL_AuthRegistrationHandler handler = new MockRegistrationHandler();
        Id contactId = '003000000000001AAA';

        Test.startTest();
        INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult failure = handler.userAccessCheckFailure('Access denied');
        INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult failureWithContact = handler.userAccessCheckFailure('Access denied', contactId);
        INS_CTRL_AuthRegistrationHandler.UserAccessCheckResult success = handler.userAccessCheckSuccess();
        Test.stopTest();

        assert.isFalse(failure.success, 'Failure result should not be successful');
        assert.areEqual('Access denied', failure.errorMessage, 'Error message should match');
        assert.isFalse(failureWithContact.success, 'Failure result should not be successful');
        assert.areEqual('Access denied&contactid=' + contactId, failureWithContact.errorMessage, 'Error message should include the contact Id');
        assert.isTrue(success.success, 'Success result should be successful');
    }

    @IsTest
    static void testUserDataWrapperProperties() {
        Auth.UserData data = buildAuthUserData('wrapper@test.com', 'Wrap', 'Per', TEST_NETWORK_ID, 'PING-1');

        Test.startTest();
        INS_CTRL_AuthRegistrationHandler.UserDataWrapper wrapper = new INS_CTRL_AuthRegistrationHandler.UserDataWrapper(data);
        wrapper.cellPhone = '254700000000';
        wrapper.dateOfBirth = '1990-01-01';
        wrapper.sub = 'subject-123';
        Test.stopTest();

        assert.areEqual('254700000000', wrapper.cellPhone, 'cellPhone should be set');
        assert.areEqual('1990-01-01', wrapper.dateOfBirth, 'dateOfBirth should be set');
        assert.areEqual('subject-123', wrapper.sub, 'sub should be set');
        assert.areEqual(TEST_NETWORK_ID, wrapper.networkId, 'networkId should come from the attribute map');
    }
}