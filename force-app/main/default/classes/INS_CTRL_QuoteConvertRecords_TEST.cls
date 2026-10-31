/**
 * @description             : Test class for INS_CTRL_QuoteConvertRecords
 * @story                   : SFP-56577
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 23/10/2026
 * @last modified by        : Irshad
 * @modification details    : Added Flexi Protect product/price book entries required by
 *                            ConversionContext; surfaced errorMessage in assertions;
 *                            restored assertions.
 */
@IsTest
private class INS_CTRL_QuoteConvertRecords_TEST {

    private static final String POLICY_NUMBER = 'KA5111905';
    private static final String PRODUCT_NAME  = 'Flexi Protect';
    private static final String PRICEBOOK_NAME = 'C&HNW(Kenya)';

    private static final String ACTION_CREATE_RECORDS = 'createConversionRecords';
    private static final String KEY_RESPONSE          = 'conversionRecordsResponse';
    private static final String KEY_HAS_ERROR         = 'hasError';
    private static final String KEY_ERROR_MESSAGE     = 'errorMessage';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

    @TestSetup
    static void setup() {
        Pricebook2 customPricebook = new Pricebook2(Name = PRICEBOOK_NAME, IsActive = true);
        insert customPricebook;

        // ConversionContext resolves the product from the price book on every call
        Product2 product = new Product2(Name = PRODUCT_NAME, IsActive = true);
        insert product;

        insert new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id   = product.Id,
            UnitPrice    = 0,
            IsActive     = true
        );
        insert new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id   = product.Id,
            UnitPrice    = 0,
            IsActive     = true
        );

        // Same label lookup the controller uses, but fail loudly if it is missing
        Schema.RecordTypeInfo prospectRt = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect');
        Assert.isNotNull(prospectRt, 'Record type "Person Account - Prospect" not found');

        Account policyholder = new Account(
            RecordTypeId    = prospectRt.getRecordTypeId(),
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
        return [SELECT Id FROM Account WHERE LastName = 'Khan' AND FirstName = 'Salman' LIMIT 1].Id;
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
            'MemberSummary'      => new Map<String, Object>{ 'members' => members },
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
     * @description The controller swallows exceptions into errorMessage, so use it
     *              as the assertion message to see the real cause of a failure.
     */
    private static String errorOf(Map<String, Object> response) {
        return response == null
            ? 'No conversionRecordsResponse returned'
            : 'Conversion failed: ' + String.valueOf(response.get(KEY_ERROR_MESSAGE));
    }

    /**
     * @description Invokes the action and reports whether it was rejected, so
     *              assertions stay in the @IsTest methods.
     */
    private static String captureFailure(Map<String, Object> input) {
        try {
            Map<String, Object> response = getResponse(invokeAction(input));
            return response != null && response.get(KEY_HAS_ERROR) == true ? 'ERROR' : '';
        } catch (Exception ex) {
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
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), errorOf(response));

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
        Assert.areEqual(Date.newInstance(2000, 8, 17), created[0].PersonBirthdate,
            'Birth date should be parsed');

        Assert.areEqual('Father', created[1].FirstName, 'The beneficiary account should be created');
        Assert.areEqual('Third Party Person Account', created[1].RecordType.Name,
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
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), errorOf(response));

        InsurancePolicy policy = [
            SELECT Id, Name, PolicyName, Status, NameInsuredId, ProductId
            FROM   InsurancePolicy
            LIMIT  1
        ];
        Assert.areEqual(policy.Id, response.get('insurancePolicyId'),
            'The response should return the created policy Id');
        Assert.areEqual(POLICY_NUMBER, policy.PolicyName,
            'The policy name should be the policy number from the conversion');
        Assert.areEqual('Awaiting KYC', policy.Status, 'The policy should await KYC');
        Assert.areEqual(policyholderAccountId, policy.NameInsuredId,
            'The policy should be linked to the policyholder account');
        Assert.isNotNull(policy.ProductId, 'The policy should be linked to the Flexi Protect product');

        List<InsurancePolicyParticipant> participants = [
            SELECT Role, PrimaryParticipantAccountId, RelatedParticipantAccountId
            FROM   InsurancePolicyParticipant
        ];
        Assert.areEqual(3, participants.size(),
            'One primary life assured plus one participant per beneficiary');

        Integer primaryCount = 0;
        Integer beneficiaryCount = 0;
        for (InsurancePolicyParticipant participant : participants) {
            Assert.areEqual(policyholderAccountId, participant.PrimaryParticipantAccountId,
                'Every participant should reference the policyholder as primary');
            if (participant.Role == 'Primary Life Assured') {
                primaryCount++;
            } else if (participant.Role == 'Beneficiary') {
                beneficiaryCount++;
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
        Map<String, Object> output = invokeAction(
            buildInput(defaultMembers(), defaultBeneficiaries()));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), errorOf(response));

        
        Assert.isNotNull(output.get('PolicyholderPartyProfileId'),
            'The policyholder party profile Id should be returned');

        Opportunity opp = [SELECT LS_PolicyNumber__c FROM Opportunity LIMIT 1];
        Assert.areEqual(POLICY_NUMBER, opp.LS_PolicyNumber__c,
            'The opportunity should carry the policy number');

        Quote quoteRecord = [SELECT Status FROM Quote LIMIT 1];
        Assert.areEqual('Awaiting KYC', quoteRecord.Status,
            'The quote status should be updated');
    }

    // =========================================================================
    // SUCCESS — ENRICHED SUMMARIES
    // =========================================================================

    @IsTest
    static void createConversionRecords_enrichesSummariesWithAccountIds() {
        Id policyholderAccountId = getPolicyholderAccountId();

        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(defaultMembers(), defaultBeneficiaries()));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), errorOf(response));

        List<Object> members = (List<Object>)
            ((Map<String, Object>) output.get('MemberSummary')).get('members');
        Assert.areEqual(2, members.size(), 'Member rows should be preserved');
        Assert.areEqual(policyholderAccountId,
            ((Map<String, Object>) members[0]).get('accountId'),
            'The policyholder row should carry the existing account Id');
        Assert.isNotNull(((Map<String, Object>) members[1]).get('accountId'),
            'The dependant row should carry its new account Id');

        List<Object> beneficiaries = (List<Object>)
            ((Map<String, Object>) output.get('BeneficiarySummary')).get('members');
        Assert.areEqual(2, beneficiaries.size(), 'Beneficiary rows should be preserved');
        for (Object row : beneficiaries) {
            Map<String, Object> beneficiary = (Map<String, Object>) row;
            Assert.isNotNull(beneficiary.get('beneficiaryAccountId'),
                'Each beneficiary row should carry its account Id');
            Assert.isNotNull(beneficiary.get('beneficiaryPartyProfileId'),
                'Each beneficiary row should carry its party profile Id');
        }
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
        Assert.areEqual(false, response.get(KEY_HAS_ERROR), errorOf(response));
        Assert.areEqual(0, response.get('accountsCreated'),
            'No additional accounts when there are no dependants or beneficiaries');

        Assert.areEqual(1, [SELECT COUNT() FROM InsurancePolicyParticipant],
            'Only the primary life assured participant should exist');
    }

    // =========================================================================
    // VALIDATION  (requires ctx.validate() to be re-enabled in the controller)
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

        Map<String, String> outcomes = new Map<String, String>();
        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            outcomes.put(scenario, captureFailure(scenarios.get(scenario)));
        }
        Test.stopTest();

        for (String scenario : outcomes.keySet()) {
            Assert.areNotEqual('', outcomes.get(scenario),
                'The action should be rejected for: ' + scenario);
        }
        Assert.areEqual(0, [SELECT COUNT() FROM InsurancePolicy],
            'No policy should be created for rejected input');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Map<String, Object> validInput = buildInput(defaultMembers(), defaultBeneficiaries());

        Boolean unsupportedThrown = false;
        Boolean missingInputThrown = false;
        Boolean missingOutputThrown = false;

        Test.startTest();
        try {
            new INS_CTRL_QuoteConvertRecords().call('wrongAction',
                new Map<String, Object>{
                    'input'  => validInput,
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedThrown = true;
        }

        try {
            new INS_CTRL_QuoteConvertRecords().call(ACTION_CREATE_RECORDS,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }

        try {
            new INS_CTRL_QuoteConvertRecords().call(ACTION_CREATE_RECORDS,
                new Map<String, Object>{ 'input' => validInput });
        } catch (AuraHandledException ex) {
            missingOutputThrown = true;
        }
        Test.stopTest();

        Assert.isTrue(unsupportedThrown, 'Unsupported action should throw');
        Assert.isTrue(missingInputThrown, 'Missing input map should throw');
        Assert.isTrue(missingOutputThrown, 'Missing output map should throw');
    }
}