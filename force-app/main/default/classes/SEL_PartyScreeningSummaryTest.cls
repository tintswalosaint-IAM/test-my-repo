/**
 * @description Test Class for SEL_PartyScreeningSummary
 * @author Ofentse Sacha
 * @date January 2024
 */
@isTest
private class SEL_PartyScreeningSummaryTest {
    /**
     * @description Helper method to create a PartyProfile test record.
     * @return PartyProfile The created PartyProfile record.
     */
    private static PartyProfile createPartyProfileTestData() {
        PartyProfile testPartyProfile = new PartyProfile(Name = 'Test Party Profile');
        insert testPartyProfile;
        return testPartyProfile;
    }

    /**
     * @description Test method for getSObjectType method in SEL_PartyScreeningSummary class.
     * Verifies that the correct SObjectType is returned for the PartyScreeningSummary object.
     */
    @isTest
    static void testGetSObjectType() {
        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        Schema.SObjectType sObjectType = selector.getSObjectType();
        Assert.areEqual(PartyScreeningSummary.SObjectType, sObjectType, 'Expected the SObjectType for PartyScreeningSummary to be returned');
    }

    /**
     * @description Test method for getSObjectFieldList method in SEL_PartyScreeningSummary class.
     * Verifies that the correct list of SObjectField objects is returned for the PartyScreeningSummary object.
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Assert.areNotEqual(null, fieldList, 'Expected a non-null list of fields');
    }

    /**
     * @description Test method for getPartyScreeningSummary method in SEL_PartyScreeningSummary class.
     * Verifies that the correct PartyScreeningSummary record is returned based on the provided ID.
     */
    @isTest
    static void testGetPartyScreeningSummary() {
        PartyProfile testPartyProfile = createPartyProfileTestData();
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary', PartyProfileId = testPartyProfile.Id);
        insert testSummary;

        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        PartyScreeningSummary retrievedSummary = selector.selectById(testSummary.Id);

        Assert.areNotEqual(null, retrievedSummary, 'Expected a PartyScreeningSummary record to be returned');
        Assert.areEqual(testSummary.Id, retrievedSummary.Id, 'Expected the returned PartyScreeningSummary to have the correct Id');
    }

    /**
     * @description Test method for getScreeningSummaryList method in SEL_PartyScreeningSummary class.
     * Verifies that the correct list of PartyScreeningSummary records is returned based on the provided PartyProfileId.
     */
    @isTest
    static void testselectListBypartyProfileId() {
        PartyProfile testPartyProfile = createPartyProfileTestData();
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary', PartyProfileId = testPartyProfile.Id);
        insert testSummary;

        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> summaries = selector.selectListBypartyProfileId(testPartyProfile.Id);

        Assert.areEqual(1, summaries.size(), 'Expected one PartyScreeningSummary record to be returned');
        Assert.areEqual(testSummary.Id, summaries[0].Id, 'Expected the returned PartyScreeningSummary to have the correct Id');
    }

    /**
     * @description Test method for selectBysetpartyProfileIds method in SEL_PartyScreeningSummary class.
     * Verifies that the correct list of PartyScreeningSummary records is returned based on a set of PartyProfileIds.
     */
    @isTest
    static void testselectBysetpartyProfileIds() {
        PartyProfile testPartyProfile1 = createPartyProfileTestData();
        PartyProfile testPartyProfile2 = createPartyProfileTestData();
        PartyScreeningSummary testSummary1 = new PartyScreeningSummary(Name = 'Test Summary 1', PartyProfileId = testPartyProfile1.Id);
        PartyScreeningSummary testSummary2 = new PartyScreeningSummary(Name = 'Test Summary 2', PartyProfileId = testPartyProfile2.Id);
        insert new List<PartyScreeningSummary>{testSummary1, testSummary2};

        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> summaries = selector.selectBysetpartyProfileIds(new Set<Id>{testPartyProfile1.Id, testPartyProfile2.Id});

        Assert.areEqual(2, summaries.size(), 'Expected two PartyScreeningSummary records to be returned');
    }

    /**
     * @description Test method for getMatchesWithOutcomes method in SEL_PartyScreeningSummary class.
     * Verifies that the correct list of PartyScreeningSummary records is returned based on the provided ID, with related PartyScreeningSteps records.
     */
    @isTest
    static void testselectByIdorPartyProfileId() {
        PartyProfile testPartyProfile = createPartyProfileTestData();
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary', PartyProfileId = testPartyProfile.Id);
        insert testSummary;

        PartyScreeningStep testStep = new PartyScreeningStep(Name = 'Test Step', ScreeningSummaryId = testSummary.Id, Status = 'SAFE' , Type = 'World Check');
        insert testStep;

        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        List<PartyScreeningSummary> summaries = selector.selectByIdWithPartyScreeningSteps(testSummary.Id);

        Assert.areEqual(1, summaries.size(), 'Expected one PartyScreeningSummary record to be returned');
        Assert.areEqual(1, summaries[0].PartyScreeningSteps.size(), 'Expected one related PartyScreeningStep record to be returned');
    }

    /**
     * @description Test method for selectByPartyProfileId method in SEL_PartyScreeningSummary class.
     * Verifies that the correct PartyScreeningSummary record is returned based on the provided PartyProfileId.
     */
    @isTest
    static void testselectByPartyProfileId() {
        PartyProfile testPartyProfile = createPartyProfileTestData();
        PartyScreeningSummary testSummary = new PartyScreeningSummary(Name = 'Test Summary', PartyProfileId = testPartyProfile.Id);
        insert testSummary;

        SEL_PartyScreeningSummary selector = new SEL_PartyScreeningSummary();
        PartyScreeningSummary retrievedSummary = selector.selectByPartyProfileId(testPartyProfile.Id);

        Assert.areNotEqual(null, retrievedSummary, 'Expected a PartyScreeningSummary record to be returned');
        Assert.areEqual(testSummary.Id, retrievedSummary.Id, 'Expected the returned PartyScreeningSummary to have the correct Id');
    }
}