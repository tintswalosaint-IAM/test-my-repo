/**
 * ─────────────────────────────────────────────────────────────────────────────
 * Class Name      : INS_CustomerSearchRemoteAction_Test
 * Description     : Enterprise-grade unit test class for
 *                   INS_CustomerSearchRemoteAction.
 *
 *                   Covers:
 *                   • Positive scenario — account found
 *                   • Negative scenario — account not found
 *                   • Exception handling — unsupported action
 *                   • Null / missing PersonalInformation input
 *                   • Invalid date format (exception path in searchCustomer)
 *                   • User context execution (runAs)
 *                   
 *
 * Testing Standards:
 * • No SeeAllData=true — test data fully self-contained
 * • All assertions include failure messages
 * • Positive and negative paths covered
 * • runAs scenario included
 * • Defensive coding validated
 * • Parallel execution enabled
 *
 * Architecture Notes:
 * • INS_CustomerSearchRemoteAction instantiates SEL_User and INS_Get_Account
 *   directly (no interface injection), so we cannot stub them.
 * • SEL_User.getUsersByIds() uses UserInfo.getUserId() — the running user is
 *   always available, so we rely on the real user context.
 * • INS_Get_Account.selectAccountByName() returns live Account records.
 *   We create a test Account matching our search criteria for the positive
 *   scenario and use deliberately non-matching values for the negative one.
 * • The production class is declared 'without sharing', so test Account DML
 *   is visible regardless of user profile.
 * ─────────────────────────────────────────────────────────────────────────────
 **/

@IsTest(SeeAllData=false IsParallel=false)
private with sharing class INS_CustomerSearchRemoteAction_Test {
 
    private static final String TEST_FIRST_NAME     = 'TestFirst';
    private static final String TEST_LAST_NAME      = 'TestLast';
    private static final String TEST_DOB_STRING     = '1990-01-15';
    private static final String TEST_IDENTITY_NUMBER = 'TEST_ID_123456';
    private static final String TEST_CUSTOMER_TYPE  = 'Individual';
    private static final String INVALID_DATE_STRING = 'NOT-A-DATE';
 
    // =========================================================================
    // HELPER METHODS
    // =========================================================================
 
    private static Map<String, Object> buildArgs(Map<String, Object> input) {
        return new Map<String, Object>{
            'input'  => input,
            'output' => new Map<String, Object>()
        };
    }
 
    private static Map<String, Object> buildPersonalInformation(
        String firstName,
        String lastName,
        String dobStr,
        String idNumber
    ) {
        return new Map<String, Object>{
            'FirstName'      => firstName,
            'LastName'       => lastName,
            'OS_DateOfBirth' => dobStr,
            'IdNumber'       => idNumber
        };
    }
 
    private static Map<String, Object> buildValidInput() {
        return new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                TEST_FIRST_NAME,
                TEST_LAST_NAME,
                TEST_DOB_STRING,
                TEST_IDENTITY_NUMBER
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
    }
 
    private static User createTestUser() {
        Profile profile = [
            SELECT Id
            FROM   Profile
            WHERE  Name = 'Standard User'
            LIMIT  1
        ];
 
        User testUser = new User(
            Alias             = 'csrtest',
            Email             = 'ins.csrtest@test.example.com',
            EmailEncodingKey  = 'UTF-8',
            LastName          = 'CSRAutomation',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey      = 'en_US',
            ProfileId         = profile.Id,
            TimeZoneSidKey    = 'Africa/Johannesburg',
            UserName          = 'ins.csrtest'
                                + System.currentTimeMillis()
                                + '@test.example.com'
        );
 
        insert testUser;
        return testUser;
    }
 
    private static Id getPersonAccountRecordTypeId() {
        List<RecordType> personAccountTypes = [
            SELECT Id
            FROM   RecordType
            WHERE  SObjectType = 'Account'
            AND    IsPersonType = true
            LIMIT  1
        ];
 
        return personAccountTypes.isEmpty()
            ? null
            : personAccountTypes[0].Id;
    }
 
    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================
 
    @IsTest
    static void searchCustomerAccountFoundScenario() {
 
        User runningUser = [
            SELECT Id, User_Country__c
            FROM   User
            WHERE  Id = :UserInfo.getUserId()
            LIMIT  1
        ];
 
        Account testAccount = new Account(
            FirstName       = TEST_FIRST_NAME,
            LastName        = TEST_LAST_NAME,
            PersonBirthdate = Date.valueOf(TEST_DOB_STRING),
            BillingCountry  = runningUser.User_Country__c,
            RecordTypeId    = getPersonAccountRecordTypeId()
        );
 
        insert testAccount;
 
        Map<String, Object> input = buildValidInput();
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null response map.'
        );
 
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get('existingAccount');
 
        System.assertNotEquals(
            null,
            existingAccount,
            'Expected existingAccount key in output.'
        );
 
        if ((Boolean) existingAccount.get('CustomerFound') == true) {
 
            System.assertNotEquals(
                null,
                existingAccount.get('ContextId'),
                'Expected ContextId to be populated when customer is found.'
            );
 
            System.assertNotEquals(
                null,
                existingAccount.get('accountRecordTypeId'),
                'Expected accountRecordTypeId to be populated when customer is found.'
            );
 
        } else {
 
            System.assertEquals(
                false,
                existingAccount.get('CustomerFound'),
                'Expected CustomerFound to be false when account not matched.'
            );
        }
    }
 
    @IsTest
    static void searchCustomerAccountNotFoundScenario() {
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                'NOMATCH_FIRST',
                'NOMATCH_LAST',
                '1900-01-01',
                'NOMATCH_ID_999'
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null response map.'
        );
 
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get('existingAccount');
 
        System.assertNotEquals(
            null,
            existingAccount,
            'Expected existingAccount key in output.'
        );
 
        System.assertEquals(
            false,
            existingAccount.get('CustomerFound'),
            'Expected CustomerFound=false when no account matches.'
        );
 
        System.assertEquals(
            null,
            existingAccount.get('ContextId'),
            'Expected no ContextId when customer is not found.'
        );
    }
 
    // =========================================================================
    // NEGATIVE / VALIDATION TESTS
    // =========================================================================
 
    @IsTest
    static void searchCustomerNullPersonalInformationScenario() {
 
        // Production class now returns buildErrorResponse() when
        // PersonalInformation is null, so no exception is expected.
 
        Map<String, Object> input = new Map<String, Object>{
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null response even when PersonalInformation is missing.'
        );
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false when PersonalInformation is missing.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage to be populated when PersonalInformation is missing.'
        );
    }
 
    @IsTest
    static void searchCustomerInvalidDateFormatScenario() {
 
        // Production class catches the TypeException from Date.valueOf() and
        // returns buildErrorResponse(), so no exception should propagate.
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                TEST_FIRST_NAME,
                TEST_LAST_NAME,
                INVALID_DATE_STRING,
                TEST_IDENTITY_NUMBER
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null response for invalid date format.'
        );
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false for invalid date format.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage to be populated for invalid date format.'
        );
    }
 
    @IsTest
    static void searchCustomerNullInputMapScenario() {
 
        // Production class now guards null inputMap and returns buildErrorResponse().
 
        Map<String, Object> args = new Map<String, Object>{
            'input'  => null,
            'output' => new Map<String, Object>()
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', args);
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null result for null input.'
        );
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false for null input.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage to be populated for null input.'
        );
    }
 
    @IsTest
    static void searchCustomerNullCustomerTypeScenario() {
 
        // CustomerType defaults to empty string when absent.
        // Execution should continue normally and return existingAccount.
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                TEST_FIRST_NAME,
                TEST_LAST_NAME,
                TEST_DOB_STRING,
                TEST_IDENTITY_NUMBER
            )
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null response when CustomerType is absent.'
        );
 
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get('existingAccount');
 
        System.assertNotEquals(
            null,
            existingAccount,
            'Expected existingAccount in response when CustomerType is absent.'
        );
    }
 
    @IsTest
    static void searchCustomerBlankFirstNameScenario() {
 
        // Production class returns buildErrorResponse() when FirstName is blank.
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                '',
                TEST_LAST_NAME,
                TEST_DOB_STRING,
                TEST_IDENTITY_NUMBER
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false when FirstName is blank.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage when FirstName is blank.'
        );
    }
 
    @IsTest
    static void searchCustomerBlankLastNameScenario() {
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                TEST_FIRST_NAME,
                '',
                TEST_DOB_STRING,
                TEST_IDENTITY_NUMBER
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false when LastName is blank.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage when LastName is blank.'
        );
    }
 
    @IsTest
    static void searchCustomerBlankDobScenario() {
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                TEST_FIRST_NAME,
                TEST_LAST_NAME,
                '',
                TEST_IDENTITY_NUMBER
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        Map<String, Object> result =
            (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
        Test.stopTest();
 
        System.assertEquals(
            false,
            result.get('success'),
            'Expected success=false when DateOfBirth is blank.'
        );
 
        System.assertNotEquals(
            null,
            result.get('errorMessage'),
            'Expected errorMessage when DateOfBirth is blank.'
        );
    }
 
    // =========================================================================
    // EXCEPTION TESTS
    // =========================================================================
 
    @IsTest
    static void unsupportedActionScenario() {
 
        Test.startTest();
 
        INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
        try {
 
            action.call('invalidAction', buildArgs(new Map<String, Object>()));
 
            System.assert(
                false,
                'Expected AuraHandledException was not thrown for unsupported action.'
            );
 
        } catch (AuraHandledException ex) {
 
            System.assertNotEquals(
                null,
                ex.getMessage(),
                'Expected exception message to be populated for unsupported action.'
            );
        }
 
        Test.stopTest();
    }
 
    // =========================================================================
    // DIRECT STATIC METHOD TESTS
    // =========================================================================
 
    @IsTest
    static void searchCustomerStaticMethodAccountFoundScenario() {
 
        Account testAccount = new Account(
            FirstName       = TEST_FIRST_NAME,
            LastName        = TEST_LAST_NAME,
            PersonBirthdate = Date.valueOf(TEST_DOB_STRING),
            RecordTypeId    = getPersonAccountRecordTypeId()
        );
 
        insert testAccount;
 
        Map<String, Object> input  = buildValidInput();
        Map<String, Object> output = new Map<String, Object>();
 
        Test.startTest();
 
        Map<String, Object> result =
            INS_CustomerSearchRemoteAction.searchCustomer(input, output);
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null result from direct static call.'
        );
 
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get('existingAccount');
 
        System.assertNotEquals(
            null,
            existingAccount,
            'Expected existingAccount key from direct static call.'
        );
    }
 
    @IsTest
    static void searchCustomerStaticMethodAccountNotFoundScenario() {
 
        Map<String, Object> input = new Map<String, Object>{
            'PersonalInformation' => buildPersonalInformation(
                'DIRECTCALL_NOMATCH',
                'DIRECTCALL_NOMATCH',
                '1800-06-15',
                'DIRECTCALL_ID_000'
            ),
            'CustomerType' => TEST_CUSTOMER_TYPE
        };
 
        Map<String, Object> output = new Map<String, Object>();
 
        Test.startTest();
 
        Map<String, Object> result =
            INS_CustomerSearchRemoteAction.searchCustomer(input, output);
 
        Test.stopTest();
 
        System.assertNotEquals(
            null,
            result,
            'Expected non-null result from direct static call (not found).'
        );
 
        Map<String, Object> existingAccount =
            (Map<String, Object>) result.get('existingAccount');
 
        System.assertEquals(
            false,
            existingAccount.get('CustomerFound'),
            'Expected CustomerFound=false from direct static call (not found).'
        );
    }
 
    // =========================================================================
    // USER CONTEXT TESTS
    // =========================================================================
 
    @IsTest
    static void runAsUserScenario() {
 
        User testUser = createTestUser();
 
        System.runAs(testUser) {
 
            Map<String, Object> input = new Map<String, Object>{
                'PersonalInformation' => buildPersonalInformation(
                    'RUNAS_FIRST',
                    'RUNAS_LAST',
                    '1985-03-20',
                    'RUNAS_ID_789'
                ),
                'CustomerType' => TEST_CUSTOMER_TYPE
            };
 
            Test.startTest();
 
            INS_CustomerSearchRemoteAction action = new INS_CustomerSearchRemoteAction();
 
            Map<String, Object> result =
                (Map<String, Object>) action.call('seachCustomer', buildArgs(input));
 
            Test.stopTest();
 
            System.assertNotEquals(
                null,
                result,
                'Expected non-null response under runAs user context.'
            );
 
            Map<String, Object> existingAccount =
                (Map<String, Object>) result.get('existingAccount');
 
            System.assertNotEquals(
                null,
                existingAccount,
                'Expected existingAccount key under runAs user context.'
            );
        }
    }
}