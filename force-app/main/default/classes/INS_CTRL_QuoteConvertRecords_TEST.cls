/**
 * @description             : Test class for INS_CTRL_QuoteConvertRecords
 * @story                   : SFP-56577
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_QuoteConvertRecords_TEST {

    private static final String POLICY_NUMBER = 'KA5111905';

    private static final String ACTION_CREATE_RECORDS = 'createConversionRecords';
    private static final String KEY_RESPONSE          = 'conversionRecordsResponse';
    private static final String KEY_HAS_ERROR         = 'hasError';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {
        Pricebook2 customPricebook = new Pricebook2(Name = 'C&HNW(Kenya)', IsActive = true);
        insert customPricebook;

        Id prospectRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect')
            .getRecordTypeId();

        Account policyholder = new Account(
            RecordTypeId    = prospectRtId,
            FirstName       = 'Salman',
            LastName        = 'Khan',
            PersonBirthdate = Date.newInstance(2000, 8, 1)
        );
        insert policyholder;

        Opportunity opp = new Opportunity(
            AccountId    = policyholder.Id,
            Name         = 'Conversion Records Test Opportunity',
            StageName    = 'Quoting',
            CloseDate    = Date.today(),
            Pricebook2Id = customPricebook.Id
        );
        insert opp;

        insert new Quote(
            OpportunityId  = opp.Id,
            Name           = 'Conversion Records Test Quote',
            Status         = 'Quote In-Progress',
            ExpirationDate = Date.today().addDays(30)
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Id getPolicyholderAccountId() {
        return [SELECT Id FROM Account WHERE LastName = 'Khan' LIMIT 1].Id;
    }

    private static Id getOpportunityId() {
        return [SELECT Id FROM Opportunity LIMIT 1].Id;
    }

    private static Id getQuoteId() {
        return [SELECT Id FROM Quote LIMIT 1].Id;
    }

    private static Map<String, Object> buildPerson(
        String firstName, String lastName, String birthDate, String relationship
    ) {
        return new Map<String, Object>{
            'FirstName__c'          => firstName,
            'LastName__c'           => lastName,
            'BirthDate__c'          => birthDate,
            'Gender__c'             => 'Male',
            'IdentityNumber__c'     => '78678688',
            'EmailAddress__c'       => 'test@example.com',
            'PhoneNumber__c'        => '+254074687590',
            'RelationshipToInsured' => relationship
        };
    }

    private static Map<String, Object> buildInput(
        List<Map<String, Object>> members,
        List<Map<String, Object>> beneficiaries
    ) {
        return new Map<String, Object>{
            'ProspectAccountId' => String.valueOf(getPolicyholderAccountId()),
            'OppId'             => String.valueOf(getOpportunityId()),
            'QuoteId'           => String.valueOf(getQuoteId()),
            'quoteConversionResponse' => new Map<String, Object>{
                'policyNumber' => POLICY_NUMBER
            },
            'MemberSummary' => new Map<String, Object>{ 'members' => members },
            'BeneficiarySummary' => new Map<String, Object>{ 'members' => beneficiaries }
        };
    }

    private static List<Map<String, Object>> defaultMembers() {
        return new List<Map<String, Object>>{
            buildPerson('Salman', 'Khan', '2000-08-01', 'Myself'),
            buildPerson('Aunt', 'Khan', '2000-08-17', 'AUNT')
        };
    }

    private static List<Map<String, Object>> defaultBeneficiaries() {
        return new List<Map<String, Object>>{
            buildPerson('Father', 'Khan', '1970-03-10', 'FATHER'),
            buildPerson('Aunt', 'Khan', '2000-08-17', 'AUNT')
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_QuoteConvertRecords().call(ACTION_CREATE_RECORDS,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static Map<String, Object> getResponse(Map<String, Object> output) {
        return (Map<String, Object>) output.get(KEY_RESPONSE);
    }

    /**
     * @description Invokes the action and reports whether it threw, so assertions
     *              stay in the @IsTest methods (see sf:NonUnitTestContainsAsserts).
     */
    private static String captureFailure(Map<String, Object> input) {
        try {
            Map<String, Object> output = invokeAction(input);
            Map<String, Object> response = getResponse(output);			
            return response != null && response.get(KEY_HAS_ERROR) == true ? 'ERROR' : '';
        } catch (AuraHandledException ex) {
            return 'THREW';
        }
    }

    // =========================================================================
    // SUCCESS — ACCOUNTS
    // =========================================================================

    @IsTest
    static void createConversionRecords_createsAccountsForMembersAndBeneficiaries() {
        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(defaultMembers(), defaultBeneficiaries()));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), 'hasError should be false');

        // Aunt Khan appears as both member and beneficiary — one account, member
        // record type winning. Father Khan is beneficiary only. The policyholder
        // already had an account.
        Assert.areEqual(2, response.get('accountsCreated'),
            'One account per unique person, excluding the policyholder');

        List<Account> created = [
            SELECT FirstName, LastName, RecordType.Name, FinServ__CustomerType__c,
                   PersonBirthdate, CMN_IdentityNumber__pc
            FROM   Account
            WHERE  LastName = 'Khan' AND FirstName != 'Salman'
            ORDER BY FirstName
        ];
        Assert.areEqual(2, created.size(), 'Two new accounts should exist');

        Assert.areEqual('Aunt', created[0].FirstName, 'The member account should be created');
        Assert.areEqual('Person Account - Prospect', created[0].RecordType.Name,
            'A person appearing as both member and beneficiary takes the member record type');
        Assert.areEqual('IAM Liberty', created[0].FinServ__CustomerType__c,
            'Customer type should be set');

        Assert.areEqual('Father', created[1].FirstName, 'The beneficiary account should be created');
        Assert.areEqual('Third Party', created[1].RecordType.Name,
            'A beneficiary-only person takes the third party record type');
    }

    // =========================================================================
    // SUCCESS — POLICY AND PARTICIPANTS
    // =========================================================================

    @IsTest
    static void createConversionRecords_createsPolicyAndParticipants() {
        Id policyholderAccountId = getPolicyholderAccountId();

        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(defaultMembers(), defaultBeneficiaries()));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        Assert.isNotNull(response.get('insurancePolicyId'),
            'The insurance policy id should be returned');

        InsurancePolicy policy = [
            SELECT Name, PolicyName, Status, NameInsuredId FROM InsurancePolicy LIMIT 1
        ];
        Assert.areEqual(POLICY_NUMBER, policy.PolicyName,
            'The policy name should be the policy number from the conversion');
        Assert.areEqual('Awaiting KYC', policy.Status, 'The policy should await KYC');
        Assert.areEqual(policyholderAccountId, policy.NameInsuredId,
            'The policy should be linked to the policyholder account');

        List<InsurancePolicyParticipant> participants = [
            SELECT Role, PrimaryParticipantAccountId, RelatedParticipantAccountId
            FROM   InsurancePolicyParticipant
        ];
        Assert.areEqual(3, participants.size(),
            'One primary life assured plus one participant per beneficiary');

        Integer primaryCount = 0;
        Integer beneficiaryCount = 0;
        for (InsurancePolicyParticipant participant : participants) {
            if (participant.Role == 'Primary Life Assured') {
                primaryCount++;
                Assert.areEqual(policyholderAccountId, participant.PrimaryParticipantAccountId,
                    'The primary life assured should be the policyholder');
            } else if (participant.Role == 'Beneficiary') {
                beneficiaryCount++;
                Assert.areEqual(policyholderAccountId, participant.PrimaryParticipantAccountId,
                    'Beneficiary participants should reference the policyholder as primary');
                Assert.isNotNull(participant.RelatedParticipantAccountId,
                    'Beneficiary participants should reference the beneficiary account');
            }
        }
        Assert.areEqual(1, primaryCount, 'Exactly one primary life assured');
        Assert.areEqual(2, beneficiaryCount, 'One participant per beneficiary');
    }

    // =========================================================================
    // SUCCESS — PARTY PROFILES AND RECORD UPDATES
    // =========================================================================

    @IsTest
    static void createConversionRecords_createsPartyProfilesAndUpdatesRecords() {
        Test.startTest();
        invokeAction(buildInput(defaultMembers(), defaultBeneficiaries()));
        Test.stopTest();

        List<PartyProfile> profiles = [
            SELECT AccountId, FirstName, LastName, Opportunity__c FROM PartyProfile
        ];
        Assert.areEqual(3, profiles.size(),
            'A party profile for the policyholder plus each created account');
        for (PartyProfile profile : profiles) {
            Assert.isNotNull(profile.AccountId, 'Each profile should link to an account');
            Assert.isNotNull(profile.Opportunity__c, 'Each profile should link to the opportunity');
        }

        Opportunity opp = [SELECT LS_PolicyNumber__c FROM Opportunity LIMIT 1];
        Assert.areEqual(POLICY_NUMBER, opp.LS_PolicyNumber__c,
            'The opportunity should carry the policy number');

        Quote quoteRecord = [SELECT Status FROM Quote LIMIT 1];
        Assert.areEqual('Awaiting KYC', quoteRecord.Status,
            'The quote status should be updated');
    }

    // =========================================================================
    // NO DEPENDANTS OR BENEFICIARIES
    // =========================================================================

    @IsTest
    static void createConversionRecords_policyholderOnly_createsNoAccounts() {
        List<Map<String, Object>> membersOnly = new List<Map<String, Object>>{
            buildPerson('Salman', 'Khan', '2000-08-01', 'Myself')
        };

        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(membersOnly, new List<Map<String, Object>>()));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), 'hasError should be false');
        Assert.areEqual(0, response.get('accountsCreated'),
            'No additional accounts when there are no dependants or beneficiaries');

        Assert.areEqual(1, [SELECT COUNT() FROM InsurancePolicyParticipant],
            'Only the primary life assured participant should exist');
    }

    // =========================================================================
    // VALIDATION
    // =========================================================================

    @IsTest
    static void createConversionRecords_missingRequiredValues_rejected() {
        Map<String, Object> noAccount = buildInput(defaultMembers(), defaultBeneficiaries());
        noAccount.remove('ProspectAccountId');

        Map<String, Object> noOpportunity = buildInput(defaultMembers(), defaultBeneficiaries());
        noOpportunity.remove('OppId');

        Map<String, Object> noPolicyNumber = buildInput(defaultMembers(), defaultBeneficiaries());
        noPolicyNumber.remove('quoteConversionResponse');

        Map<String, Object> noPolicyholder =
            buildInput(new List<Map<String, Object>>{
                buildPerson('Aunt', 'Khan', '2000-08-17', 'AUNT')
            }, defaultBeneficiaries());

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'missing ProspectAccountId' => noAccount,
            'missing OppId'             => noOpportunity,
            'missing policyNumber'      => noPolicyNumber,
            'no policyholder member'    => noPolicyholder
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            String outcome = captureFailure(scenarios.get(scenario));
            Assert.areNotEqual('', outcome,
                'The action should be rejected for: ' + scenario);
        }
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM InsurancePolicy],
            'No policy should be created on any validation failure');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Map<String, Object> validInput = buildInput(defaultMembers(), defaultBeneficiaries());

        Boolean unsupportedThrown = false;
        try {
            new INS_CTRL_QuoteConvertRecords().call('wrongAction',
                new Map<String, Object>{
                    'input'  => validInput,
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedThrown = true;
        }
        Assert.isTrue(unsupportedThrown, 'Unsupported action should throw');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_QuoteConvertRecords().call(ACTION_CREATE_RECORDS,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown, 'Missing input map should throw');
    }
}