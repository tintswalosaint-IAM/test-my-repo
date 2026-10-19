/***************************************************************************************
@Name of the Class : INS_PartyProfileRemoteAction_Test
@Description : SFP-58522 Test class for INS_PartyProfileRemoteAction.
               Covers the Callable dispatch, the two-step account search,
               policyholder Party Profile find-or-create, multi-beneficiary
               processing, Opportunity linking, and all error paths.
@Author : Shams
@Created Date : 2026-06-15
***************************************************************************************
* Last Modified By  Shams
* Last Modified Date 2026-06-15
* Last Modified Description: Initial Version
* User Story : SFP-58522
****************************************************************************************/
@IsTest(SeeAllData=false IsParallel=false)
private class INS_PartyProfileRemoteAction_Test {

    // =========================================================================
    // CONSTANTS
    // =========================================================================

    private static final String ACTION_PROCESS_BENEFICIARIES    = 'processBeneficiaries';
    private static final String ACTION_UNSUPPORTED              = 'unsupportedAction';
    private static final String RECORD_TYPE_THIRD_PARTY         = 'Third_Party';
    private static final String RECORD_TYPE_PERSON_ACCOUNT      = 'Person_Account_Prospect';
    private static final String RECORD_TYPE_OPPORTUNITY_GENERAL = 'General';
    private static final String OPPORTUNITY_STAGE_PROSPECTING   = 'Prospecting';

    private static final String POLICYHOLDER_FIRST_NAME = 'John';
    private static final String POLICYHOLDER_LAST_NAME  = 'Policyholder';
    private static final String POLICYHOLDER_EMAIL      = 'policyholder@test.com';
    private static final String POLICYHOLDER_PHONE      = '+254077801010';
    private static final String POLICYHOLDER_ID_NUMBER  = '11111111';
    private static final String POLICYHOLDER_GENDER     = 'Male';

    private static final String BENEFICIARY_ONE_FIRST_NAME = 'Jane';
    private static final String BENEFICIARY_ONE_LAST_NAME  = 'Doe';
    private static final String BENEFICIARY_ONE_ID_NUMBER  = '12345678';
    private static final String BENEFICIARY_ONE_BIRTHDATE  = '1990-01-15';
    private static final String BENEFICIARY_ONE_PHONE      = '+254712345678';
    private static final String BENEFICIARY_ONE_EMAIL      = 'jane.doe@test.com';
    private static final String BENEFICIARY_ONE_GENDER     = 'FEMALE';

    private static final String BENEFICIARY_TWO_FIRST_NAME = 'Bob';
    private static final String BENEFICIARY_TWO_LAST_NAME  = 'Smith';
    private static final String BENEFICIARY_TWO_ID_NUMBER  = '87654321';
    private static final String BENEFICIARY_TWO_BIRTHDATE  = '1985-06-20';
    private static final String BENEFICIARY_TWO_PHONE      = '+254798765432';
    private static final String BENEFICIARY_TWO_EMAIL      = 'bob.smith@test.com';
    private static final String BENEFICIARY_TWO_GENDER     = 'MALE';

    private static final String ID_TYPE_NATIONAL = 'National Identity Document';
    private static final Integer ALLOCATION_SIXTY    = 60;
    private static final Integer ALLOCATION_FORTY    = 40;
    private static final Integer ALLOCATION_HUNDRED  = 100;

    private static final String KEY_MEMBERS             = 'members';
    private static final String KEY_POLICYHOLDER_INFO   = 'PolicyholderInfo';
    private static final String KEY_BENEFICIARY_SUMMARY = 'BeneficiarySummary';
    private static final String KEY_ERROR               = 'error';

    // =========================================================================
    // HELPER METHODS
    // =========================================================================

    private static Id getThirdPartyAccountRecordTypeId() {
        return Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_THIRD_PARTY).getRecordTypeId();
    }

    private static Id getPolicyholderAccountRecordTypeId() {
        return Schema.SObjectType.Account
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_PERSON_ACCOUNT).getRecordTypeId();
    }

    private static Id getOpportunityRecordTypeId() {
        return Schema.SObjectType.Opportunity
            .getRecordTypeInfosByDeveloperName().get(RECORD_TYPE_OPPORTUNITY_GENERAL).getRecordTypeId();
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
    * @description Builds the PolicyholderInfo map sent from OmniScript
    **/
    private static Map<String, Object> buildPolicyholderInfoMap(String accountId) {
        return new Map<String, Object>{
            'AccountId' => accountId,
            'FirstName' => POLICYHOLDER_FIRST_NAME,
            'LastName'  => POLICYHOLDER_LAST_NAME,
            'Gender'    => POLICYHOLDER_GENDER,
            'Email'     => POLICYHOLDER_EMAIL,
            'Phone'     => POLICYHOLDER_PHONE,
            'IdNumber'  => POLICYHOLDER_ID_NUMBER
        };
    }

    /**
    * @description Builds a single beneficiary member map matching the cmn_Beneficiaries LWC payload
    **/
    private static Map<String, Object> buildMemberMap(
        String firstName, String lastName, String identityNumber,
        String birthDate, String phone, String email, String idType, Integer allocation
    ) {
        return buildMemberMap(firstName, lastName, identityNumber, birthDate, phone, email, idType, allocation, null);
    }

    private static Map<String, Object> buildMemberMap(
        String firstName, String lastName, String identityNumber,
        String birthDate, String phone, String email, String idType, Integer allocation, String gender
    ) {
        return new Map<String, Object>{
            'FirstName__c'      => firstName,
            'LastName__c'       => lastName,
            'IdentityNumber__c' => identityNumber,
            'BirthDate__c'      => birthDate,
            'PhoneNumber__c'    => phone,
            'EmailAddress__c'   => email,
            'IdType__c'         => idType,
            'Allocation__c'     => allocation,
            'Gender__c'         => gender
        };
    }

    /**
    * @description Builds the BeneficiarySummary map containing members and total allocation
    **/
    private static Map<String, Object> buildBeneficiarySummaryMap(
        List<Map<String, Object>> memberMapList, Integer totalAllocation
    ) {
        return new Map<String, Object>{
            KEY_MEMBERS         => memberMapList,
            'totalAllocation' => totalAllocation
        };
    }

    /**
    * @description Builds the full inputMap passed to processBeneficiaries
    **/
    private static Map<String, Object> buildInputMap(
        Id opportunityId, String policyholderAccountId,
        List<Map<String, Object>> memberMapList
    ) {
        return new Map<String, Object>{
            'OpportunityId'      => opportunityId,
            KEY_POLICYHOLDER_INFO   => buildPolicyholderInfoMap(policyholderAccountId),
            KEY_BENEFICIARY_SUMMARY => buildBeneficiarySummaryMap(memberMapList, ALLOCATION_HUNDRED)
        };
    }

    private static Account createPolicyholderAccount() {
        Account policyholderAccount = new Account(
            FirstName    = POLICYHOLDER_FIRST_NAME,
            LastName     = POLICYHOLDER_LAST_NAME,
            PersonEmail  = POLICYHOLDER_EMAIL,
            RecordTypeId = getPolicyholderAccountRecordTypeId()
        );
        insert policyholderAccount;
        return policyholderAccount;
    }

    private static Account createThirdPartyAccount(
        String firstName, String lastName, String identityNumber, String birthDate
    ) {
        Account beneficiaryAccount = new Account(
            FirstName              = firstName,
            LastName               = lastName,
            CMN_IdentityNumber__pc = identityNumber,
            PersonBirthdate        = Date.valueOf(birthDate),
            RecordTypeId           = getThirdPartyAccountRecordTypeId()
        );
        insert beneficiaryAccount;
        return beneficiaryAccount;
    }

    private static Pricebook2 createKenyaHnwPricebook() {
        Pricebook2 pb = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert pb;
        return pb;
    }

    private static Opportunity createOpportunity(Id policyholderAccountId) {
        Pricebook2 kenyaHnwPricebook = createKenyaHnwPricebook();
        Opportunity testOpportunity = new Opportunity(
            Name         = 'Test AR Opportunity',
            AccountId    = policyholderAccountId,
            StageName    = OPPORTUNITY_STAGE_PROSPECTING,
            CloseDate    = Date.today().addDays(30),
            RecordTypeId = getOpportunityRecordTypeId(),
            Pricebook2Id = kenyaHnwPricebook.Id
        );
        insert testOpportunity;
        return testOpportunity;
    }

    private static PartyProfile createPartyProfile(Id accountId, String identityNumber) {
        PartyProfile beneficiaryPartyProfile = new PartyProfile(
            AccountId                       = accountId,
            Name                            = BENEFICIARY_ONE_FIRST_NAME + ' ' + BENEFICIARY_ONE_LAST_NAME,
            FirstName                       = BENEFICIARY_ONE_FIRST_NAME,
            LastName                        = BENEFICIARY_ONE_LAST_NAME,
            WI_PrimaryIdentificationName__c = identityNumber
        );
        insert beneficiaryPartyProfile;
        return beneficiaryPartyProfile;
    }

    // =========================================================================
    // POSITIVE TESTS
    // =========================================================================

    @IsTest
    static void testProcessBeneficiaries_SingleNewMember_AccountAndPartyProfileCreated() {
        // WHY: Full happy-path — no pre-existing account or Party Profile.
        // Validates that a new Third_Party account and Party Profile are inserted
        // and their Ids are returned in the enriched member output.
        Account policyholderAccount = createPolicyholderAccount();
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_HUNDRED)
        };

        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected for new member happy path: ' + result.get(KEY_ERROR));

        Map<String, Object> returnedSummary = (Map<String, Object>) result.get(KEY_BENEFICIARY_SUMMARY);
        System.assertNotEquals(null, returnedSummary, 'BeneficiarySummary should be returned');

        List<Object> processedMemberList = (List<Object>) returnedSummary.get(KEY_MEMBERS);
        System.assertEquals(1, processedMemberList.size(), 'Expected exactly 1 processed member');

        Map<String, Object> processedMember = (Map<String, Object>) processedMemberList[0];
        System.assertNotEquals('', processedMember.get('beneficiaryAccountId'),
            'beneficiaryAccountId should be populated for new member');
        System.assertNotEquals('', processedMember.get('beneficiaryPartyProfileId'),
            'beneficiaryPartyProfileId should be populated for new member');
    }

    @IsTest
    static void testProcessBeneficiaries_MultipleBeneficiaries_AllProcessedWithoutError() {
        // WHY: The primary regression test for SFP-58522 — the static UoW bug in
        // KYC_CTRL_PartyProfile caused INVALID_FIELD_FOR_INSERT_UPDATE on the
        // second processKycTest call within a single transaction. Both members
        // must be processed successfully.
        Account policyholderAccount = createPolicyholderAccount();
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_SIXTY, BENEFICIARY_ONE_GENDER),
            buildMemberMap(BENEFICIARY_TWO_FIRST_NAME, BENEFICIARY_TWO_LAST_NAME,
                BENEFICIARY_TWO_ID_NUMBER, BENEFICIARY_TWO_BIRTHDATE,
                BENEFICIARY_TWO_PHONE, BENEFICIARY_TWO_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_FORTY, BENEFICIARY_TWO_GENDER)
        };

        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected when processing multiple beneficiaries: ' + result.get(KEY_ERROR));

        List<Object> processedMemberList = (List<Object>) ((Map<String, Object>) result.get(KEY_BENEFICIARY_SUMMARY)).get(KEY_MEMBERS);
        System.assertEquals(2, processedMemberList.size(), 'Both beneficiary members should be returned');
    }

    @IsTest
    static void testProcessBeneficiaries_ExistingAccountByIdentityNumber_AccountReused() {
        // WHY: Validates Step 1 of the two-step account search — an existing
        // Third_Party account matched by CMN_IdentityNumber__pc is reused instead
        // of creating a duplicate.
        Account policyholderAccount        = createPolicyholderAccount();
        Account existingBeneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
            BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE
        );
        PartyProfile existingBeneficiaryPartyProfile = createPartyProfile(
            existingBeneficiaryAccount.Id, BENEFICIARY_ONE_ID_NUMBER
        );
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_HUNDRED)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected when existing account found by identity number: ' + result.get(KEY_ERROR));

        Map<String, Object> processedMember = (Map<String, Object>)
            ((List<Object>) ((Map<String, Object>) result.get(KEY_BENEFICIARY_SUMMARY)).get(KEY_MEMBERS))[0];

        System.assertEquals(String.valueOf(existingBeneficiaryAccount.Id),
            String.valueOf(processedMember.get('beneficiaryAccountId')),
            'Existing account should be reused — no duplicate created (Step 1 match)');
        System.assertEquals(String.valueOf(existingBeneficiaryPartyProfile.Id),
            String.valueOf(processedMember.get('beneficiaryPartyProfileId')),
            'Existing Party Profile should be reused');
    }

    @IsTest
    static void testProcessBeneficiaries_ExistingAccountByNameAndDob_AccountReused() {
        // WHY: Validates Step 2 of the two-step account search — when no identity
        // number match is found in Step 1, the account is located by first name,
        // last name, and date of birth to avoid creating a duplicate.
        Account policyholderAccount = createPolicyholderAccount();
        Account existingBeneficiaryAccount = new Account(
            FirstName       = BENEFICIARY_ONE_FIRST_NAME,
            LastName        = BENEFICIARY_ONE_LAST_NAME,
            PersonBirthdate = Date.valueOf(BENEFICIARY_ONE_BIRTHDATE),
            RecordTypeId    = getThirdPartyAccountRecordTypeId()
        );
        insert existingBeneficiaryAccount;
        createPartyProfile(existingBeneficiaryAccount.Id, BENEFICIARY_ONE_ID_NUMBER);
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_HUNDRED)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error expected when existing account found by name and DOB: ' + result.get(KEY_ERROR));

        Map<String, Object> processedMember = (Map<String, Object>)
            ((List<Object>) ((Map<String, Object>) result.get(KEY_BENEFICIARY_SUMMARY)).get(KEY_MEMBERS))[0];

        System.assertEquals(String.valueOf(existingBeneficiaryAccount.Id),
            String.valueOf(processedMember.get('beneficiaryAccountId')),
            'Existing account should be reused by name+DOB fallback (Step 2 match)');
    }

    @IsTest
    static void testProcessBeneficiaries_ExistingPolicyholderPartyProfile_LinkedToOpportunity() {
        // WHY: Validates that when the policyholder already has a Party Profile,
        // it is updated with the Opportunity Id rather than a second one being created.
        Account policyholderAccount = createPolicyholderAccount();
        PartyProfile existingPolicyholderPartyProfile = new PartyProfile(
            AccountId = policyholderAccount.Id,
            Name      = POLICYHOLDER_FIRST_NAME + ' ' + POLICYHOLDER_LAST_NAME,
            FirstName = POLICYHOLDER_FIRST_NAME,
            LastName  = POLICYHOLDER_LAST_NAME
        );
        insert existingPolicyholderPartyProfile;
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        Map<String, Object> inputMap = buildInputMap(
            testOpportunity.Id, policyholderAccount.Id, new List<Map<String, Object>>()
        );

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        PartyProfile updatedPolicyholderPartyProfile = [
            SELECT Id, Opportunity__c FROM PartyProfile WHERE Id = :existingPolicyholderPartyProfile.Id
        ];
        System.assertEquals(testOpportunity.Id, updatedPolicyholderPartyProfile.Opportunity__c,
            'Existing policyholder Party Profile should be updated with the Opportunity Id');

        Integer partyProfileCount = [SELECT COUNT() FROM PartyProfile WHERE AccountId = :policyholderAccount.Id];
        System.assertEquals(1, partyProfileCount,
            'Only one policyholder Party Profile should exist — no duplicate created');
    }

    @IsTest
    static void testProcessBeneficiaries_NewPolicyholderPartyProfile_CreatedWithOpportunity() {
        // WHY: Validates that when no policyholder Party Profile exists yet, a new
        // one is inserted and immediately linked to the Opportunity.
        Account policyholderAccount = createPolicyholderAccount();
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        Map<String, Object> inputMap = buildInputMap(
            testOpportunity.Id, policyholderAccount.Id, new List<Map<String, Object>>()
        );

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        List<PartyProfile> createdPolicyholderProfiles = [
            SELECT Id, Opportunity__c, FirstName, LastName, PrimaryEmail, PrimaryPhone
            FROM PartyProfile
            WHERE AccountId = :policyholderAccount.Id
        ];
        System.assertEquals(1, createdPolicyholderProfiles.size(),
            'Exactly one policyholder Party Profile should be created');
        System.assertEquals(testOpportunity.Id, createdPolicyholderProfiles[0].Opportunity__c,
            'New policyholder Party Profile must be linked to the Opportunity');
        System.assertEquals(POLICYHOLDER_FIRST_NAME, createdPolicyholderProfiles[0].FirstName,
            'FirstName should match the PolicyholderInfo input');
        System.assertEquals(POLICYHOLDER_EMAIL, createdPolicyholderProfiles[0].PrimaryEmail,
            'PrimaryEmail should match the PolicyholderInfo input');
    }

    @IsTest
    static void testCallDispatch_ProcessBeneficiariesAction_RoutesCorrectly() {
        // WHY: Validates the Callable interface entry point dispatches to
        // processBeneficiaries without throwing for a recognised action type.
        Account policyholderAccount = createPolicyholderAccount();
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        Map<String, Object> inputMap = buildInputMap(
            testOpportunity.Id, policyholderAccount.Id, new List<Map<String, Object>>()
        );

        Test.startTest();
        INS_PartyProfileRemoteAction remoteActionInstance = new INS_PartyProfileRemoteAction();
        Object callResult = remoteActionInstance.call(ACTION_PROCESS_BENEFICIARIES, buildCallArguments(inputMap));
        Test.stopTest();

        System.assertNotEquals(null, callResult,
            'call() with a valid action type should return a non-null result');
    }

    @IsTest
    static void testProcessBeneficiaries_NewAccount_AllProspectFieldsPopulated() {
        // WHY: Validates field parity between Third_Party beneficiary accounts and
        // Person_Account_Prospect accounts. PLI sets PersonMobilePhone + Phone +
        // FinServ__KYCStatus__c + Receive_Marketing__c; Flexi adds PersonHomePhone +
        // FinServ__Gender__pc; Quick Quote Flow stamps ExternalCIFId__c = Account.Id
        // after insert. All of these must be present on newly created beneficiary accounts.
        Account policyholderAccount = createPolicyholderAccount();
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(
                BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL,
                ID_TYPE_NATIONAL, ALLOCATION_HUNDRED, BENEFICIARY_ONE_GENDER
            )
        };

        KYC_CTRL_PartyProfile.IGNORE_SMS = true;
        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        Account createdAccount = [
            SELECT FirstName, LastName, CMN_IdentityNumber__pc, PersonBirthdate,
                   Phone, PersonMobilePhone, PersonHomePhone, PersonEmail,
                   FinServ__Gender__pc, FinServ__KYCStatus__c,
                   Receive_Marketing__c, ExternalCIFId__c
            FROM Account
            WHERE CMN_IdentityNumber__pc = :BENEFICIARY_ONE_ID_NUMBER
            AND RecordType.DeveloperName = :RECORD_TYPE_THIRD_PARTY
            LIMIT 1
        ];

        System.assertEquals(BENEFICIARY_ONE_PHONE,   createdAccount.Phone,
            'Phone should be set to match PLI pattern');
        System.assertEquals(BENEFICIARY_ONE_PHONE,   createdAccount.PersonMobilePhone,
            'PersonMobilePhone should be set — matches PLI and Flexi');
        System.assertEquals(BENEFICIARY_ONE_PHONE,   createdAccount.PersonHomePhone,
            'PersonHomePhone should be set — matches Flexi pattern');
        System.assertEquals(BENEFICIARY_ONE_EMAIL,   createdAccount.PersonEmail,
            'PersonEmail should be populated');
        System.assertEquals('Female',                createdAccount.FinServ__Gender__pc,
            'Gender FEMALE should be title-cased to Female for FinServ__Gender__pc');
        System.assertEquals('In Queue',             createdAccount.FinServ__KYCStatus__c,
            'KYC status should default to In Queue — matches PLI pattern');
        System.assertEquals(true,                   createdAccount.Receive_Marketing__c,
            'Receive_Marketing__c should default true — matches PLI pattern');
        System.assertEquals(String.valueOf(createdAccount.Id), createdAccount.ExternalCIFId__c,
            'ExternalCIFId__c should be stamped with the Account Id — matches Quick Quote flow pattern');
    }

    @IsTest
    static void testProcessBeneficiaries_BeneficiaryPartyProfileLinkedToOpportunity() {
        // WHY: Validates that Opportunity__c is set on the beneficiary Party Profile
        // during the bulk update phase, not just on the policyholder PP.
        Account policyholderAccount        = createPolicyholderAccount();
        Account existingBeneficiaryAccount = createThirdPartyAccount(
            BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
            BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE
        );
        PartyProfile existingBeneficiaryPartyProfile = createPartyProfile(
            existingBeneficiaryAccount.Id, BENEFICIARY_ONE_ID_NUMBER
        );
        Opportunity testOpportunity = createOpportunity(policyholderAccount.Id);

        List<Map<String, Object>> memberMapList = new List<Map<String, Object>>{
            buildMemberMap(BENEFICIARY_ONE_FIRST_NAME, BENEFICIARY_ONE_LAST_NAME,
                BENEFICIARY_ONE_ID_NUMBER, BENEFICIARY_ONE_BIRTHDATE,
                BENEFICIARY_ONE_PHONE, BENEFICIARY_ONE_EMAIL, ID_TYPE_NATIONAL, ALLOCATION_HUNDRED)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        INS_PartyProfileRemoteAction.processBeneficiaries(
            buildInputMap(testOpportunity.Id, policyholderAccount.Id, memberMapList), outputMap
        );
        Test.stopTest();

        PartyProfile updatedBeneficiaryPartyProfile = [
            SELECT Id, Opportunity__c FROM PartyProfile WHERE Id = :existingBeneficiaryPartyProfile.Id
        ];
        System.assertEquals(testOpportunity.Id, updatedBeneficiaryPartyProfile.Opportunity__c,
            'Beneficiary Party Profile must be linked to the Opportunity');
    }

    // =========================================================================
    // NEGATIVE TESTS
    // =========================================================================

    @IsTest
    static void testProcessBeneficiaries_MissingPolicyholderInfo_ReturnsError() {
        // WHY: Validates that a missing PolicyholderInfo key surfaces a descriptive
        // error message instead of throwing an unhandled NullPointerException.
        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_BENEFICIARY_SUMMARY => buildBeneficiarySummaryMap(new List<Map<String, Object>>(), ALLOCATION_HUNDRED)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        System.assertNotEquals(null, result.get(KEY_ERROR),
            'An error should be returned when PolicyholderInfo is absent');
        System.assertEquals('PolicyholderInfo is missing', (String) result.get(KEY_ERROR),
            'Error message should clearly identify the missing field');
    }

    @IsTest
    static void testProcessBeneficiaries_MissingBeneficiarySummary_ReturnsError() {
        // WHY: Validates that a missing BeneficiarySummary key surfaces a descriptive
        // error message instead of throwing an unhandled NullPointerException.
        Account policyholderAccount = createPolicyholderAccount();

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_INFO => buildPolicyholderInfoMap(policyholderAccount.Id)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        System.assertNotEquals(null, result.get(KEY_ERROR),
            'An error should be returned when BeneficiarySummary is absent');
        System.assertEquals('BeneficiarySummary is missing', (String) result.get(KEY_ERROR),
            'Error message should clearly identify the missing field');
    }

    @IsTest
    static void testProcessBeneficiaries_EmptyMemberList_ReturnsSummaryUnchanged() {
        // WHY: Validates the early-exit path — when the members list is empty the
        // method returns immediately with the original BeneficiarySummary without
        // performing any DML, preventing unnecessary database operations.
        Account policyholderAccount = createPolicyholderAccount();

        Map<String, Object> originalBeneficiarySummary = buildBeneficiarySummaryMap(
            new List<Map<String, Object>>(), ALLOCATION_HUNDRED
        );
        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_INFO   => buildPolicyholderInfoMap(policyholderAccount.Id),
            KEY_BENEFICIARY_SUMMARY => originalBeneficiarySummary
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'No error should be returned for an empty member list');
        System.assertNotEquals(null, result.get(KEY_BENEFICIARY_SUMMARY),
            'BeneficiarySummary should be returned unchanged when members list is empty');
    }

    @IsTest
    static void testCallDispatch_UnsupportedAction_ThrowsAuraHandledException() {
        // WHY: Validates that the Callable contract is enforced — an unrecognised
        // action type must throw AuraHandledException so callers are not silently
        // ignored.
        Map<String, Object> inputMap = new Map<String, Object>();

        Test.startTest();
        INS_PartyProfileRemoteAction remoteActionInstance = new INS_PartyProfileRemoteAction();
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

    @IsTest
    static void testProcessBeneficiaries_BlankPolicyholderAccountId_NoCrash() {
        // WHY: Validates that a blank AccountId in PolicyholderInfo does not throw
        // — findOrCreatePolicyholderPartyProfile returns null gracefully and
        // processing continues for the empty member list.
        Map<String, Object> policyholderInfoWithBlankAccountId = new Map<String, Object>{
            'AccountId' => '',
            'FirstName' => POLICYHOLDER_FIRST_NAME,
            'LastName'  => POLICYHOLDER_LAST_NAME
        };

        Map<String, Object> inputMap = new Map<String, Object>{
            KEY_POLICYHOLDER_INFO   => policyholderInfoWithBlankAccountId,
            KEY_BENEFICIARY_SUMMARY => buildBeneficiarySummaryMap(new List<Map<String, Object>>(), ALLOCATION_HUNDRED)
        };

        Test.startTest();
        Map<String, Object> outputMap = new Map<String, Object>();
        Map<String, Object> result = (Map<String, Object>) INS_PartyProfileRemoteAction.processBeneficiaries(inputMap, outputMap);
        Test.stopTest();

        System.assertEquals(null, result.get(KEY_ERROR),
            'A blank AccountId should not cause an exception — method should return gracefully');
    }
}