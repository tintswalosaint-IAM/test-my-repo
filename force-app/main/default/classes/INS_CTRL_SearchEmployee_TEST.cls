/**
 * @description             : Test class for INS_CTRL_SearchEmployee
 * @story                   : SFP-55635
 * @author                  : Irshad
 * @created date            : 2026-01-10
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_SearchEmployee_TEST {

    private static final String REFERRER_ACCOUNT_NAME =
        'External Referrer IAM AR Generic Account';
    private static final String USER_EMAIL     = 'employee.search.user@example.test';
    private static final String CONTACT_EMAIL  = 'existing.referrer@example.test';
    private static final String NEW_EMAIL      = 'brand.new.referrer@example.test';
    private static final String KEY_EMAIL         = 'Email';
    private static final String KEY_ASSISTED_CONTACT_ID = 'assistedContactId';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setupData() {
        Account referrerAccount = new Account(Name = REFERRER_ACCOUNT_NAME);
        insert referrerAccount;

        insert new Contact(
            FirstName = 'Existing',
            LastName  = 'Referrer',
            Email     = CONTACT_EMAIL,
            AccountId = referrerAccount.Id
        );
    }

    private static User createInternalUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User u = new User(
            FirstName         = 'Search',
            LastName          = 'Target',
            Email             = USER_EMAIL,
            Username          = 'search.target.' + System.currentTimeMillis() + '@example.test',
            Alias             = 'starget',
            ProfileId         = p.Id,
            EmailEncodingKey  = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_GB',
            TimeZoneSidKey    = 'Europe/London'
        );
        insert u;
        return u;
    }

    // =========================================================================
    // TEST HELPERS
    // =========================================================================

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_SearchEmployee().call('SearchEmployee',
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    // =========================================================================
    // SCENARIO 1: INTERNAL USER FOUND
    // =========================================================================

    @IsTest
    static void searchEmployee_userFound_returnsUserId() {
        User target = createInternalUser();

        Test.startTest();
        Map<String, Object> output = invokeAction(
            new Map<String, Object>{ KEY_EMAIL => USER_EMAIL });
        Test.stopTest();

        Assert.areEqual(target.Id, output.get('assistedUserId'),
            'Matching user should be returned as assistedUserId');
        Assert.isFalse(output.containsKey(KEY_ASSISTED_CONTACT_ID),
            'Contact path should not run when a user matches');
    }

    // =========================================================================
    // SCENARIO 2: EXISTING REFERRER CONTACT FOUND
    // =========================================================================

    @IsTest
    static void searchEmployee_existingContact_returnsContactId() {
        Contact existing = [SELECT Id FROM Contact WHERE Email = :CONTACT_EMAIL LIMIT 1];

        Test.startTest();
        Map<String, Object> output = invokeAction(
            new Map<String, Object>{ KEY_EMAIL => CONTACT_EMAIL });
        Test.stopTest();

        Assert.areEqual(existing.Id, output.get(KEY_ASSISTED_CONTACT_ID),
            'Existing referrer contact should be returned');
        Assert.isFalse(output.containsKey('assistedUserId'),
            'assistedUserId should not be set on the contact path');

        Integer contactCount = [
            SELECT COUNT() FROM Contact WHERE Email = :CONTACT_EMAIL
        ];
        Assert.areEqual(1, contactCount,
            'No duplicate contact should be created when one exists');
    }

    // =========================================================================
    // SCENARIO 3: NO MATCH - CONTACT CREATED
    // =========================================================================

    @IsTest
    static void searchEmployee_noMatch_createsContact() {
        Map<String, Object> input = new Map<String, Object>{
            'Email'       => NEW_EMAIL,
            'FirstName'   => 'Brand',
            'LastName'    => 'NewReferrer',
            'MobilePhone' => '254712345678'
        };

        Test.startTest();
        Map<String, Object> output = invokeAction(input);
        Test.stopTest();

        Id returnedId = (Id) output.get(KEY_ASSISTED_CONTACT_ID);
        Assert.isNotNull(returnedId,
            'Newly created contact id should be returned - this was the original bug');

        Contact created = [
            SELECT Id, FirstName, LastName, Email, MobilePhone, Account.Name
            FROM Contact WHERE Email = :NEW_EMAIL LIMIT 1
        ];
        Assert.areEqual(created.Id, returnedId,
            'Returned id should match the inserted contact');
        Assert.areEqual('Brand', created.FirstName, 'FirstName should be mapped');
        Assert.areEqual('NewReferrer', created.LastName, 'LastName should be mapped');
        Assert.areEqual('254712345678', created.MobilePhone, 'MobilePhone should be mapped');
        Assert.areEqual(REFERRER_ACCOUNT_NAME, created.Account.Name,
            'Contact should be parented to the generic referrer account');
    }

    @IsTest
    static void searchEmployee_noMatch_missingOptionalFields_createsContact() {
        Map<String, Object> input = new Map<String, Object>{
            KEY_EMAIL    => NEW_EMAIL,
            'LastName' => 'MinimalReferrer'
            // No FirstName, no MobilePhone - blank defaults should apply
        };

        Test.startTest();
        Map<String, Object> output = invokeAction(input);
        Test.stopTest();

        Assert.isNotNull(output.get(KEY_ASSISTED_CONTACT_ID),
            'Contact should be created even without optional fields');

        Contact created = [
            SELECT FirstName, MobilePhone FROM Contact WHERE Email = :NEW_EMAIL LIMIT 1
        ];
        Assert.areEqual(null, created.FirstName, 'Missing FirstName should default to null');
    }

    // =========================================================================
    // FAILURE PATHS
    // =========================================================================

    @IsTest
    static void searchEmployee_referrerAccountMissing_throws() {
        delete [SELECT Id FROM Contact];
        delete [SELECT Id FROM Account WHERE Name = :REFERRER_ACCOUNT_NAME];

        Boolean thrown = false;
        Test.startTest();
        try {
            invokeAction(new Map<String, Object>{ KEY_EMAIL => NEW_EMAIL, 'LastName' => 'X' });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Test.stopTest();

        Assert.isTrue(thrown,
            'Missing referrer account should surface as AuraHandledException');
    }

    @IsTest
    static void call_unsupportedAction_throws() {
        Boolean thrown = false;
        try {
            new INS_CTRL_SearchEmployee().call('wrongAction',
                new Map<String, Object>{
                    'input'  => new Map<String, Object>{ KEY_EMAIL => NEW_EMAIL },
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            thrown = true;
        }
        Assert.isTrue(thrown, 'Unsupported action should throw AuraHandledException');
    }

    // =========================================================================
    // DIRECT UNIT: searchContactByEmail
    // =========================================================================

    @IsTest
    static void searchContactByEmail_noMatch_returnsNull() {
        Id accountId = [SELECT Id FROM Account WHERE Name = :REFERRER_ACCOUNT_NAME LIMIT 1].Id;

        Id result = INS_CTRL_SearchEmployee.searchContactByEmail('nobody@example.test', accountId);

        Assert.isNull(result,
            'No match should return null rather than throwing - this was the original bug');
    }
}