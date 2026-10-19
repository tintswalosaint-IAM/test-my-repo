/*
 * Class Name      : INS_CTRL_CustomerSearch_TEST
 * Description     : Test class for INS_CTRL_CustomerSearch
 * Created Date    : Mar 18, 2026
 * Author          : Irshad Alam
 * User Story      : SFP-55635
 **/
@IsTest(SeeAllData=false IsParallel=false)
private with sharing class INS_CTRL_CustomerSearch_TEST {

    // ---- Input/output map keys and action name ----
    private static final String ACTION_SEARCH        = 'seachCustomer';
    private static final String KEY_INPUT            = 'input';
    private static final String KEY_OUTPUT           = 'output';
    private static final String KEY_PERSONAL_INFO    = 'PersonalInformation';
    private static final String KEY_CUSTOMER_TYPE    = 'CustomerType';
    private static final String KEY_EXISTING_ACCOUNT = 'existingAccount';
    private static final String KEY_CUSTOMER_FOUND   = 'CustomerFound';
    private static final String KEY_CONTEXT_ID       = 'ContextId';
    private static final String KEY_SUCCESS          = 'success';
    private static final String KEY_ERROR_MESSAGE    = 'errorMessage';

    // ---- Test data values ----
    private static final String TEST_FIRST_NAME      = 'TestFirst';
    private static final String TEST_LAST_NAME       = 'TestLast';
    private static final String TEST_DOB_STRING      = '1990-01-15';
    private static final String TEST_IDENTITY_NUMBER = 'TEST_ID_123456';
    private static final String TEST_CUSTOMER_TYPE   = 'Individual';
    private static final String INVALID_DATE_STRING  = 'NOT-A-DATE';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        insert new User(
            Alias             = 'csrtest',
            Email             = 'ins.csrtest@test.example.com',
            EmailEncodingKey  = 'UTF-8',
            LastName          = 'CSRAutomation',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = profile.Id,
            TimeZoneSidKey    = 'Africa/Johannesburg',
            UserName          = 'ins.csrtest' + System.currentTimeMillis() + '@test.example.com'
        );

        User runningUser = [
            SELECT Id, User_Country__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1
        ];

        List<RecordType> personAccountTypes = [
            SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND IsPersonType = true
            LIMIT 1
        ];
        Id rtId = personAccountTypes.isEmpty() ? null : personAccountTypes[0].Id;

        insert new Account(
            FirstName       = TEST_FIRST_NAME,
            LastName        = TEST_LAST_NAME,
            PersonBirthdate = Date.valueOf(TEST_DOB_STRING),
            BillingCountry  = runningUser.User_Country__c,
            RecordTypeId    = rtId
        );
    }

    // =========================================================================
    // HELPER METHODS (builders only - no assertions, per NonUnitTestContainsAsserts)
    // =========================================================================

    private static Map<String, Object> buildInput(
        String firstName, String lastName, String dobStr, String idNumber
    ) {
        return new Map<String, Object>{
            KEY_PERSONAL_INFO => new Map<String, Object>{
                'FirstName'      => firstName,
                'LastName'       => lastName,
                'OS_DateOfBirth' => dobStr,
                'IdNumber'       => idNumber
            },
            KEY_CUSTOMER_TYPE => TEST_CUSTOMER_TYPE
        };
    }

    private static Map<String, Object> invoke(Map<String, Object> input) {
        return (Map<String, Object>) new INS_CTRL_CustomerSearch().call(
            ACTION_SEARCH,
            new Map<String, Object>{
                KEY_INPUT  => input,
                KEY_OUTPUT => new Map<String, Object>()
            });
    }

    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================

    @IsTest
    static void searchCustomerAccountFoundPositiveOutcome() {

        Test.startTest();
        Map<String, Object> result = invoke(buildInput(
            TEST_FIRST_NAME, TEST_LAST_NAME, TEST_DOB_STRING, TEST_IDENTITY_NUMBER));


        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null response map.');
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get(KEY_EXISTING_ACCOUNT);
        Assert.isNotNull(existingAccount, 'Expected existingAccount key in output.');
        
    }

    @IsTest
    static void searchCustomerNullCustomerTypePositiveOutcome() {

        Map<String, Object> input = buildInput(
            TEST_FIRST_NAME, TEST_LAST_NAME, TEST_DOB_STRING, TEST_IDENTITY_NUMBER);
        input.remove(KEY_CUSTOMER_TYPE);

        Test.startTest();
        Map<String, Object> result = invoke(input);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null response when CustomerType is absent.');
        Assert.isNotNull(result.get(KEY_EXISTING_ACCOUNT),
            'Expected existingAccount when CustomerType is absent.');
    }

    @IsTest
    static void runAsUserPositiveOutcome() {

        User testUser = [SELECT Id FROM User WHERE Alias = 'csrtest' LIMIT 1];

        System.runAs(testUser) {
            Test.startTest();
            Map<String, Object> result = invoke(buildInput(
                'RUNAS_FIRST', 'RUNAS_LAST', '1985-03-20', 'RUNAS_ID_789'));
            Test.stopTest();

            Assert.isNotNull(result, 'Expected non-null response under runAs context.');
            Assert.isNotNull(result.get(KEY_EXISTING_ACCOUNT),
                'Expected existingAccount under runAs context.');
        }
    }

    // =========================================================================
    // NEGATIVE TESTS
    // =========================================================================

    @IsTest
    static void searchCustomerAccountNotFoundNegativeOutcome() {

        Test.startTest();
        Map<String, Object> result = invoke(buildInput(
            'NOMATCH_FIRST', 'NOMATCH_LAST', '1900-01-01', 'NOMATCH_ID_999'));
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null response map.');
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get(KEY_EXISTING_ACCOUNT);
        Assert.isNotNull(existingAccount, 'Expected existingAccount key in output.');
        Assert.areEqual(false, existingAccount.get(KEY_CUSTOMER_FOUND),
            'Expected CustomerFound=false when no account matches.');
        Assert.isNull(existingAccount.get(KEY_CONTEXT_ID),
            'Expected no ContextId when customer is not found.');
    }

    /*------------------------------------------------------------
     *  Data-driven validation coverage: null input, missing
     *  PersonalInformation, blank FirstName / LastName /
     *  DateOfBirth, and invalid date format. Assertions are inline
     *  in the loop (per UnitTestsShouldIncludeAssert /
     *  NonUnitTestContainsAsserts rules), labelled per scenario.
     *------------------------------------------------------------*/
    @IsTest
    static void searchCustomerValidationErrorsNegativeOutcome() {

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'null input' => null,
            'missing PersonalInformation' => new Map<String, Object>{
                KEY_CUSTOMER_TYPE => TEST_CUSTOMER_TYPE },
            'blank FirstName' => buildInput(
                '', TEST_LAST_NAME, TEST_DOB_STRING, TEST_IDENTITY_NUMBER),
            'blank LastName' => buildInput(
                TEST_FIRST_NAME, '', TEST_DOB_STRING, TEST_IDENTITY_NUMBER),
            'blank DateOfBirth' => buildInput(
                TEST_FIRST_NAME, TEST_LAST_NAME, '', TEST_IDENTITY_NUMBER),
            'invalid date format' => buildInput(
                TEST_FIRST_NAME, TEST_LAST_NAME, INVALID_DATE_STRING, TEST_IDENTITY_NUMBER)
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Map<String, Object> result = invoke(scenarios.get(scenario));

            Assert.isNotNull(result, 'Expected non-null response for: ' + scenario);
            Assert.areEqual(false, result.get(KEY_SUCCESS),
                'Expected success=false for: ' + scenario);
            Assert.isNotNull(result.get(KEY_ERROR_MESSAGE),
                'Expected errorMessage for: ' + scenario);
        }
        Test.stopTest();
    }

    @IsTest
    static void unsupportedActionNegativeOutcome() {

        Test.startTest();
        try {
            new INS_CTRL_CustomerSearch().call('invalidAction',
                new Map<String, Object>{
                    KEY_INPUT  => new Map<String, Object>(),
                    KEY_OUTPUT => new Map<String, Object>()
                });
            Assert.fail('Expected AuraHandledException for unsupported action.');
        } catch (AuraHandledException ex) {
            Assert.isNotNull(ex.getMessage(),
                'Expected exception message for unsupported action.');
        }
        Test.stopTest();
    }
}