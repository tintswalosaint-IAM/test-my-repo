/***************************************************************************************
@Name of the Class : INS_PartyConsentRemoteAction_Test
@Description : SFP-58864 Test class for INS_PartyConsentRemoteAction.
               Covers the Callable dispatch, bulk consent creation, field value
               verification, guard conditions, and error paths.
@Author : Shams Arifeen
@Created Date : 2026-06-26
***************************************************************************************
* Last Modified By  Shams Arifeen
* Last Modified Date 2026-06-26
* Last Modified Description: Initial Version
* User Story : SFP-58864
****************************************************************************************/
@IsTest(SeeAllData=false IsParallel=false)
private class INS_PartyConsentRemoteAction_Test {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_CREATE_CONSENTS = 'createConsents';
    private static final String ACTION_UNSUPPORTED      = 'unsupportedAction';
    private static final String CAPTURE_SOURCE          = 'InsuranceARFlow';
    private static final String BRAND_NAME              = 'Liberty Life Kenya';
    private static final String RECORD_TYPE_THIRD_PARTY = 'Third_Party';
    private static final Integer EXPECTED_CONSENTS_PER_MEMBER = 4;

    private static final String KEY_ERROR   = 'error';
    private static final String KEY_SUCCESS = 'success';

    private static final String BENEFICIARY_ONE_FIRST_NAME = 'Jane';
    private static final String BENEFICIARY_ONE_LAST_NAME  = 'Doe';

    private static final String BENEFICIARY_TWO_FIRST_NAME = 'Bob';
    private static final String BENEFICIARY_TWO_LAST_NAME  = 'Smith';

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    private static Id getThirdPartyAccountRecordTypeId() {
        return Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_THIRD_PARTY).getRecordTypeId();
    }

    /**
    * @description Wraps input into the args Map structure expected by the Callable interface
    **/
    private static Map<String, Object> buildCallArguments(Map<String, Object> inputMap) {
        return new Map<String, Object>{
            'input'  => inputMap,
            'output' => new Map<String, Object>()
        };
    }

    /**
    * @description Builds a member entry as produced by the party profile IP output
    **/
    private static Map<String, Object> buildMemberMap(String accountId) {
        return new Map<String, Object>{
            'beneficiaryAccountId' => accountId
        };
    }

    /**
    * @description Builds the inputMap passed to createConsents
    **/
    private static Map<String, Object> buildInputMap(
        List<Map<String, Object>> memberMapList, String captureSource
    ) {
        return buildInputMap(memberMapList, captureSource, BRAND_NAME);
    }

    private static Map<String, Object> buildInputMap(
        List<Map<String, Object>> memberMapList, String captureSource, String businessBrandName
    ) {
        return new Map<String, Object>{
            'members'           => memberMapList,
            'CaptureSource'     => captureSource,
            'BusinessBrandName' => businessBrandName
        };
    }

    private static Account createThirdPartyAccount(String firstName, String lastName) {
        // CMN_TRH_Account only creates an Individual (and sets PersonIndividualId) when
        // CMN_IdentityNumber__pc is non-blank. Without it PersonIndividualId stays null,
        // accountToIndividualMap is empty, and createConsents returns success=true with 0 records.
        // Fix: insert Individual explicitly and link via PersonIndividualId so the selector
        // re-query in the production code finds a non-null value to use as PartyId.
        Individual ind = new Individual(
            FirstName                   = firstName,
            LastName                    = lastName,
            National_Identity_Number__c = 'TEST-' + firstName.left(3) + '-' + lastName.left(3)
        );
        insert ind;
        Account beneficiaryAccount = new Account(
            FirstName          = firstName,
            LastName           = lastName,
            PersonIndividualId = ind.Id,
            RecordTypeId       = getThirdPartyAccountRecordTypeId()
        );
        insert beneficiaryAccount;
        return beneficiaryAccount;
    }

    private static BusinessBrand createBusinessBrand() {
        BusinessBrand brand = new BusinessBrand(Name = BRAND_NAME);
        insert brand;
        return brand;
    }

    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================

    @IsTest
    static void testCreateConsents_SingleAccount_InsertsFourRecords() {
        // WHY: Core happy-path — validates that exactly 4 PartyConsent records are
        // inserted per beneficiary when all required inputs are present.
        createBusinessBrand();
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(beneficiaryAccount.Id)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(memberMapList, CAPTURE_SOURCE), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected for single-account happy path: ' + result.get(KEY_ERROR));
        System.assertEquals(true, result.get(KEY_SUCCESS),
            'success flag should be true when consents are created');

        Integer consentCount = [SELECT COUNT() FROM PartyConsent WHERE CaptureSource = :CAPTURE_SOURCE];
        System.assertEquals(EXPECTED_CONSENTS_PER_MEMBER, consentCount,
            'Exactly 4 PartyConsent records should be inserted for one beneficiary');
    }

    @IsTest
    static void testCreateConsents_TwoAccounts_InsertsEightRecords() {
        // WHY: Validates bulk path — the Remote Action must insert 4 × N records
        // in a single UoW commit regardless of how many beneficiaries are processed.
        createBusinessBrand();
        Account beneficiaryOne = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );
        Account beneficiaryTwo = createThirdPartyAccount(
            BENEFICIARY_TWO_FIRST_NAME, BENEFICIARY_TWO_LAST_NAME
        );

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(beneficiaryOne.Id),
            buildMemberMap(beneficiaryTwo.Id)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(memberMapList, CAPTURE_SOURCE), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected for two-account happy path: ' + result.get(KEY_ERROR));

        Integer consentCount = [SELECT COUNT() FROM PartyConsent WHERE CaptureSource = :CAPTURE_SOURCE];
        System.assertEquals(EXPECTED_CONSENTS_PER_MEMBER * 2, consentCount,
            '8 PartyConsent records should be inserted for two beneficiaries (4 each)');
    }

    @IsTest
    static void testCreateConsents_FieldValues_AllSetCorrectly() {
        // WHY: Validates every field on created PartyConsent records against the
        // AC 2 requirement — PartyId must be PersonIndividualId (not Account.Id),
        // Action__c must be one of the 4 specified values, and fixed fields
        // (PrivacyConsentStatus, CaptureContactPointType, EffectiveFrom) must match.
        createBusinessBrand();
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );
        Account requeriedAccount = [
            SELECT Id, PersonIndividualId FROM Account WHERE Id = :beneficiaryAccount.Id
        ];

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(beneficiaryAccount.Id)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(memberMapList, CAPTURE_SOURCE), outputMap
        );
        Test.stopTest();

        List<PartyConsent> createdConsents = [
            SELECT Id, Name, PartyId, Action__c, PrivacyConsentStatus,
                   CaptureContactPointType, CaptureSource, EffectiveFrom, BusinessBrandId
            FROM PartyConsent
            WHERE CaptureSource = :CAPTURE_SOURCE
            ORDER BY Action__c
        ];
        System.assertEquals(EXPECTED_CONSENTS_PER_MEMBER, createdConsents.size(),
            'Expected 4 PartyConsent records');

        Set<String> expectedActions = new Set<String>{
            'PrivacyPolicyAcceptance', 'CrossBorderDataTransfer',
            'BiometricProcessing', 'ComplianceScreening'
        };
        Set<String> actualActions = new Set<String>();

        for (PartyConsent consent : createdConsents) {
            System.assertEquals(requeriedAccount.PersonIndividualId, consent.PartyId,
                'PartyId must be the Individual record Id (PersonIndividualId), not the Account Id');
            System.assertEquals('OptIn', consent.PrivacyConsentStatus,
                'PrivacyConsentStatus must be OptIn per AC 2 requirement');
            System.assertEquals('Web', consent.CaptureContactPointType,
                'CaptureContactPointType must be Web per AC 2 requirement');
            System.assertEquals(CAPTURE_SOURCE, consent.CaptureSource,
                'CaptureSource must match the value passed from the embedding flow');
            System.assertEquals(Date.today(), consent.EffectiveFrom,
                'EffectiveFrom must be set to today');
            System.assertNotEquals(null, consent.BusinessBrandId,
                'BusinessBrandId must be populated');
            System.assertNotEquals(null, consent.Name,
                'Name must be populated');
            System.assertEquals(true, consent.Name.startsWith('PC-'),
                'Name must follow PC-{AccountId}-{SUFFIX}-{Timestamp} format');
            actualActions.add(consent.Action__c);
        }

        System.assertEquals(expectedActions, actualActions,
            'All 4 required Action__c values must be present across the created consents');
    }

    @IsTest
    static void testCallDispatch_CreateConsentsAction_RoutesCorrectly() {
        // WHY: Validates the Callable interface entry point dispatches to
        // createConsents without throwing for a recognised action type.
        createBusinessBrand();
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );

        Map<String, Object> inputMap = buildInputMap(
            new List<Map<String, Object>>{ buildMemberMap(beneficiaryAccount.Id) },
            CAPTURE_SOURCE
        );

        Test.startTest();
        INS_PartyConsentRemoteAction remoteActionInstance = new INS_PartyConsentRemoteAction();
        Object callResult = remoteActionInstance.call(ACTION_CREATE_CONSENTS, buildCallArguments(inputMap));
        Test.stopTest();

        System.assertNotEquals(null, callResult,
            'call() with a valid action type should return a non-null result');
    }

    // =========================================================================
    // NEGATIVE TESTS
    // =========================================================================

    @IsTest
    static void testCreateConsents_EmptyMembers_ReturnsFalseNoDml() {
        // WHY: Validates the guard condition — when the members list is empty the
        // method must return immediately with success=false and perform no DML.
        createBusinessBrand();

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(new List<Map<String, Object>>(), CAPTURE_SOURCE), outputMap
        );
        Test.stopTest();

        System.assertEquals(false, result.get(KEY_SUCCESS),
            'success should be false when members list is empty');
        System.assertEquals(null, result.get(KEY_ERROR),
            'No exception should be thrown for empty members — guard exits gracefully');

        Integer consentCount = [SELECT COUNT() FROM PartyConsent];
        System.assertEquals(0, consentCount, 'No PartyConsent records should be inserted for empty members');
    }

    @IsTest
    static void testCreateConsents_BlankCaptureSource_ReturnsFalseNoDml() {
        // WHY: CaptureSource is required by AC 2 — a blank value must halt processing
        // before any DML occurs so no consent records are created with a missing source.
        createBusinessBrand();
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(
                new List<Map<String, Object>>{ buildMemberMap(beneficiaryAccount.Id) },
                ''
            ),
            outputMap
        );
        Test.stopTest();

        System.assertEquals(false, result.get(KEY_SUCCESS),
            'success should be false when CaptureSource is blank');
        System.assertEquals(null, result.get(KEY_ERROR),
            'No exception should be thrown for blank CaptureSource — guard exits gracefully');

        Integer consentCount = [SELECT COUNT() FROM PartyConsent];
        System.assertEquals(0, consentCount, 'No PartyConsent records should be inserted when CaptureSource is blank');
    }

    @IsTest
    static void testCreateConsents_BlankBusinessBrandName_ReturnsFalseNoDml() {
        // WHY: BusinessBrandName is now passed dynamically from the embedding flow.
        // A blank value must halt processing before any DML — same guard pattern as
        // CaptureSource — so no consent records are created with a null brand reference.
        createBusinessBrand();
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyConsentRemoteAction.createConsents(
            buildInputMap(
                new List<Map<String, Object>>{ buildMemberMap(beneficiaryAccount.Id) },
                CAPTURE_SOURCE,
                ''
            ),
            outputMap
        );
        Test.stopTest();

        System.assertEquals(false, result.get(KEY_SUCCESS),
            'success should be false when BusinessBrandName is blank');
        System.assertEquals(null, result.get(KEY_ERROR),
            'No exception should be thrown for blank BusinessBrandName — guard exits gracefully');

        Integer consentCount = [SELECT COUNT() FROM PartyConsent];
        System.assertEquals(0, consentCount,
            'No PartyConsent records should be inserted when BusinessBrandName is blank');
    }

    @IsTest
    static void testCreateConsentsMissingBrandThrowsAuraHandledException() {
        // WHY: BusinessBrand lookup is mandatory — without the brand record the
        // Remote Action cannot populate BusinessBrandId and must throw AuraHandledException
        // rather than inserting consents with a null brand reference.
        // BusinessBrandName is provided but the matching record does not exist in the org.
        Account beneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME
        );

        Boolean exceptionThrown = false;
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        try {
            INS_PartyConsentRemoteAction.createConsents(
                buildInputMap(
                    new List<Map<String, Object>>{ buildMemberMap(beneficiaryAccount.Id) },
                    CAPTURE_SOURCE,
                    BRAND_NAME
                ),
                outputMap
            );
        } catch (AuraHandledException caughtException) {
            exceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, exceptionThrown,
            'AuraHandledException should be thrown when the BusinessBrand record is not found');

        Integer consentCount = [SELECT COUNT() FROM PartyConsent];
        System.assertEquals(0, consentCount,
            'No PartyConsent records should be inserted when BusinessBrand lookup fails');
    }

    @IsTest
    static void testCallDispatch_UnsupportedAction_ThrowsAuraHandledException() {
        // WHY: Validates that the Callable contract is enforced — an unrecognised
        // action type must throw AuraHandledException so callers are not silently
        // ignored.
        Map<String, Object> inputMap = new Map<String, Object>();

        Test.startTest();
        INS_PartyConsentRemoteAction remoteActionInstance = new INS_PartyConsentRemoteAction();
        Boolean auraExceptionThrown = false;
        try {
            remoteActionInstance.call(ACTION_UNSUPPORTED, buildCallArguments(inputMap));
        } catch (AuraHandledException caughtException) {
            auraExceptionThrown = true;
        }
        Test.stopTest();

        System.assertEquals(true, auraExceptionThrown,
            'AuraHandledException should be thrown for an unsupported action type');
    }
}