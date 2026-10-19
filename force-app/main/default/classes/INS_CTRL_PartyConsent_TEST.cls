/**
 * @description             : Test class for INS_CTRL_PartyConsent
 * @story                   : <story>
 * @author                  : Irshad
 * @created date            : 28/09/2026
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 */
@IsTest
private class INS_CTRL_PartyConsent_TEST {

    private static final String ACTION_CREATE_CONSENTS = 'createPartyConsents';
    private static final String BUSINESS_BRAND         = 'Liberty Life Kenya';

    private static final String KEY_PROSPECT_ACCOUNT_ID = 'ProspectAccountId';
    private static final String KEY_CONSENT_GIVEN       = 'isConsentGiven';
    private static final String KEY_POLICY_DISCLOSURE   = 'PolicyDisclosure';
    private static final String KEY_ALL_CONSENTS_GIVEN  = 'AllConsentsGiven';
    private static final String KEY_RESPONSE            = 'partyConsentResponse';
    private static final String KEY_HAS_ERROR           = 'hasError';

    private static final String CONSENT_NAME_PRIVACY = 'Data Privacy & Marketing Consent';
    private static final String CONSENT_NAME_TERMS   = 'Policy Ts&Cs Consents';

    // =========================================================================
    // TEST SETUP
    // =========================================================================

        @TestSetup
    static void setup() {
        insert new BusinessBrand(Name = BUSINESS_BRAND);

        Individual ind = new Individual(
            FirstName = 'Consent',
            LastName  = 'TestCustomer',
            BirthDate = Date.newInstance(1990, 5, 15)
        );
        insert ind;

        Id personAccountRtId = Schema.SObjectType.Account
            .getRecordTypeInfosByName()
            .get('Person Account - Prospect')
            .getRecordTypeId();

        insert new Account(
            RecordTypeId       = personAccountRtId,
            FirstName          = 'Consent',
            LastName           = 'TestCustomer',
            PersonBirthdate    = Date.newInstance(1990, 5, 15),
            PersonIndividualId = ind.Id
        );
    }

    // =========================================================================
    // HELPERS
    // =========================================================================

    private static Id getTestAccountId() {
        return [SELECT Id FROM Account WHERE LastName = 'TestCustomer' LIMIT 1].Id;
    }

    private static Map<String, Object> buildInput(
        Object accountId, Boolean privacyGiven, Boolean termsGiven
    ) {
        return new Map<String, Object>{
            KEY_PROSPECT_ACCOUNT_ID => accountId,
            KEY_CONSENT_GIVEN       => privacyGiven,
            KEY_POLICY_DISCLOSURE   => new Map<String, Object>{
                KEY_ALL_CONSENTS_GIVEN => termsGiven
            }
        };
    }

    private static Map<String, Object> invokeAction(Map<String, Object> input) {
        Map<String, Object> output = new Map<String, Object>();
        new INS_CTRL_PartyConsent().call(ACTION_CREATE_CONSENTS,
            new Map<String, Object>{ 'input' => input, 'output' => output });
        return output;
    }

    private static Map<String, Object> getResponse(Map<String, Object> output) {
        return (Map<String, Object>) output.get(KEY_RESPONSE);
    }

    // =========================================================================
    // SUCCESS
    // =========================================================================

    @IsTest
    static void createPartyConsents_bothConsents_createsTwoRecords() {
        Id accountId = getTestAccountId();
		
        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(String.valueOf(accountId), true, true));
        Test.stopTest();

        Map<String, Object> response = getResponse(output);
        
        Assert.areEqual(2, response.get('consentsCreated'),
            'Both consents should be created when both flags are set');
        Assert.isNotNull(response.get('individualId'),
            'The Individual the consents attach to should be returned');

        List<PartyConsent> consents = [
            SELECT Name, Action, PrivacyConsentStatus, CaptureContactPointType,
                   EffectiveFrom, PartyId, BusinessBrandId
            FROM   PartyConsent
            ORDER BY Name
        ];
        Assert.areEqual(2, consents.size(), 'Two PartyConsent records should exist');

        Map<String, PartyConsent> byName = new Map<String, PartyConsent>();
        for (PartyConsent consent : consents) {
            byName.put(consent.Name, consent);
        }

        PartyConsent privacy = byName.get(CONSENT_NAME_PRIVACY);
        Assert.isNotNull(privacy, 'The privacy consent should be created');
        Assert.areEqual('Data Collection', privacy.Action,
            'The privacy consent action should be Data Collection');
        Assert.areEqual('OptIn', privacy.PrivacyConsentStatus, 'Status should be OptIn');
        Assert.areEqual('Web', privacy.CaptureContactPointType,
            'Capture contact point type should be Web');
        Assert.areEqual(Date.today(), privacy.EffectiveFrom, 'Effective from should be today');
        Assert.isNotNull(privacy.BusinessBrandId, 'The business brand should be linked');

        PartyConsent terms = byName.get(CONSENT_NAME_TERMS);
        Assert.isNotNull(terms, 'The terms consent should be created');
        Assert.areEqual('Share Data', terms.Action,
            'The terms consent action should be Share Data');
    }

    @IsTest
    static void createPartyConsents_privacyOnly_createsOneRecord() {
        Id accountId = getTestAccountId();

        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(String.valueOf(accountId), true, false));
        Test.stopTest();

        Assert.areEqual(false, getResponse(output).get(KEY_HAS_ERROR),
            'hasError should be false');
        Assert.areEqual(1, getResponse(output).get('consentsCreated'),
            'Only the privacy consent should be created');

        List<PartyConsent> consents = [SELECT Name FROM PartyConsent];
        Assert.areEqual(1, consents.size(), 'One PartyConsent record should exist');
        Assert.areEqual(CONSENT_NAME_PRIVACY, consents[0].Name,
            'The record should be the privacy consent');
    }

    @IsTest
    static void createPartyConsents_termsOnly_createsOneRecord() {
        Id accountId = getTestAccountId();

        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput(String.valueOf(accountId), false, true));
        Test.stopTest();

        Assert.areEqual(1, getResponse(output).get('consentsCreated'),
            'Only the terms consent should be created');

        List<PartyConsent> consents = [SELECT Name FROM PartyConsent];
        Assert.areEqual(CONSENT_NAME_TERMS, consents[0].Name,
            'The record should be the terms consent');
    }

    // =========================================================================
    // ERROR PATHS
    // =========================================================================

    @IsTest
    static void createPartyConsents_errorScenarios_returnError() {
        Id accountId = getTestAccountId();

        Map<String, Map<String, Object>> scenarios = new Map<String, Map<String, Object>>{
            'no consent given'      => buildInput(String.valueOf(accountId), false, false),
            'missing account id'    => buildInput(null, true, true),
            'blank account id'      => buildInput('', true, true),
            'malformed account id'  => buildInput('not-an-id', true, true)
        };

        Test.startTest();
        for (String scenario : scenarios.keySet()) {
            Map<String, Object> output = invokeAction(scenarios.get(scenario));
            Map<String, Object> response = getResponse(output);

            Assert.isNotNull(response, 'A response node should be present for: ' + scenario);
            Assert.areEqual(true, response.get(KEY_HAS_ERROR),
                'hasError should be true for: ' + scenario);
            Assert.isNotNull(response.get('errorMessage'),
                'An error message should be present for: ' + scenario);
        }
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM PartyConsent],
            'No consent records should be created on any error path');
    }

    @IsTest
    static void createPartyConsents_accountNotFound_returnsError() {
        Test.startTest();
        Map<String, Object> output = invokeAction(
            buildInput('001000000000000AAA', true, true));
        Test.stopTest();

        Assert.areEqual(true, getResponse(output).get(KEY_HAS_ERROR),
            'A non-existent account should produce an error response');
    }

    // =========================================================================
    // CALLABLE CONTRACT
    // =========================================================================

    @IsTest
    static void call_invalidInvocations_throw() {
        Id accountId = getTestAccountId();
        Map<String, Object> validInput = buildInput(String.valueOf(accountId), true, true);

        Boolean unsupportedThrown = false;
        try {
            new INS_CTRL_PartyConsent().call('wrongAction',
                new Map<String, Object>{
                    'input'  => validInput,
                    'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            unsupportedThrown = true;
        }
        Assert.isTrue(unsupportedThrown, 'Unsupported action should throw');

        Boolean missingInputThrown = false;
        try {
            new INS_CTRL_PartyConsent().call(ACTION_CREATE_CONSENTS,
                new Map<String, Object>{ 'output' => new Map<String, Object>() });
        } catch (AuraHandledException ex) {
            missingInputThrown = true;
        }
        Assert.isTrue(missingInputThrown, 'Missing input map should throw');

        Boolean missingOutputThrown = false;
        try {
            new INS_CTRL_PartyConsent().call(ACTION_CREATE_CONSENTS,
                new Map<String, Object>{ 'input' => validInput });
        } catch (AuraHandledException ex) {
            missingOutputThrown = true;
        }
        Assert.isTrue(missingOutputThrown, 'Missing output map should throw');
    }
}