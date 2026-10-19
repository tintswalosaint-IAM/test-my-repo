/**
 * @description Test class for SEL_PartyConsent selector
 * @author Shams Arifeen
 * @date 2026-06-26
 * @user story SFP-58864
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SEL_PartyConsent_Test {

    private static final List<String> CONSENT_ACTIONS = new List<String>{
        'PrivacyPolicyAcceptance', 'CrossBorderDataTransfer',
        'BiometricProcessing', 'ComplianceScreening'
    };

    @IsTest
    static void testSelectByPartyIdsAndActionsEmptyIds() {
        Test.startTest();
        List<PartyConsent> result = new SEL_PartyConsent().selectByPartyIdsAndActions(
            new Set<Id>(), CONSENT_ACTIONS
        );
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'Expected empty list when partyIds set is empty');
    }

    @IsTest
    static void testSelectByPartyIdsAndActionsNullIds() {
        Test.startTest();
        List<PartyConsent> result = new SEL_PartyConsent().selectByPartyIdsAndActions(
            null, CONSENT_ACTIONS
        );
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'Expected empty list when partyIds is null');
    }

    @IsTest
    static void testSelectByPartyIdsAndActionsEmptyActions() {
        Individual ind = new Individual(LastName = 'TestInd');
        insert ind;

        Test.startTest();
        List<PartyConsent> result = new SEL_PartyConsent().selectByPartyIdsAndActions(
            new Set<Id>{ ind.Id }, new List<String>()
        );
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'Expected empty list when actions list is empty');
    }

    @IsTest
    static void testSelectByPartyIdsAndActionsReturnsMatchingConsents() {
        Individual ind = new Individual(LastName = 'ConsentInd');
        insert ind;

        List<PartyConsent> consents = new List<PartyConsent>();
        for (String action : CONSENT_ACTIONS) {
            consents.add(new PartyConsent(
                PartyId              = ind.Id,
                Name				 = 'Test Concent',
                Action__c            = action,
                PrivacyConsentStatus = 'OptIn',
                CaptureSource        = 'TestSource',
                EffectiveFrom        = Date.today()
            ));
        }
        insert consents;

        Test.startTest();
        List<PartyConsent> result = new SEL_PartyConsent().selectByPartyIdsAndActions(
            new Set<Id>{ ind.Id }, CONSENT_ACTIONS
        );
        Test.stopTest();

        Assert.areEqual(CONSENT_ACTIONS.size(), result.size(),
            'Expected ' + CONSENT_ACTIONS.size() + ' PartyConsent records returned');
    }

    @IsTest
    static void testGetSObjectType() {
        Assert.areEqual(
            PartyConsent.SObjectType,
            new SEL_PartyConsent().getSObjectType(),
            'getSObjectType must return PartyConsent.SObjectType'
        );
    }

    @IsTest
    static void testGetSObjectFieldList() {
        List<Schema.SObjectField> fields = new SEL_PartyConsent().getSObjectFieldList();
        Assert.isFalse(fields.isEmpty(), 'Field list must not be empty');
        Assert.isTrue(fields.contains(PartyConsent.Id),        'Field list must contain Id');
        Assert.isTrue(fields.contains(PartyConsent.PartyId),   'Field list must contain PartyId');
        Assert.isTrue(fields.contains(PartyConsent.Action__c), 'Field list must contain Action__c');
    }
}