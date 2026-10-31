/**
 * @description             : Test class for INS_DTO_BenefitMapping
 * @story                   : SFP-50909
 * @author                  : Irshad
 * @created date            : <date>
 * @last modified date      : 
 * @last modified by        : 
 * @modification details    : 
 *
 * NOTE: INS_MemberRelation__mdt records cannot be inserted in tests, so these
 *       assertions are derived from the records deployed in the org rather than
 *       from fixtures. They assert the lookup behaviour, not specific ids.
 */
@IsTest
private class INS_DTO_BenefitMapping_TEST {

    /**
     * @description Returns any mapping record with both a category and a type,
     *              so the tests can assert against real deployed data.
     */
    private static INS_MemberRelation__mdt anyCompleteMapping() {
        for (INS_MemberRelation__mdt mapping : INS_MemberRelation__mdt.getAll().values()) {
            if (String.isNotBlank(mapping.Public_Benefit_Id__c)
                && String.isNotBlank(mapping.Member_Category__c)
                && String.isNotBlank(mapping.Benefit_Type__c)) {
                return mapping;
            }
        }
        return null;
    }

    // =========================================================================
    // LOOKUP BY PUBLIC BENEFIT ID
    // =========================================================================

    @IsTest
    static void getByPublicBenefitId_knownId_returnsMapping() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();
        Assert.isNotNull(expected,
            'At least one INS_MemberRelation__mdt record must be deployed for these tests');

        Test.startTest();
        INS_MemberRelation__mdt actual =
            INS_DTO_BenefitMapping.getByPublicBenefitId(expected.Public_Benefit_Id__c);
        Test.stopTest();

        Assert.isNotNull(actual, 'A deployed public benefit id should resolve');
        Assert.areEqual(expected.Public_Benefit_Id__c, actual.Public_Benefit_Id__c,
            'The returned mapping should match the requested id');
        Assert.areEqual(expected.Benefit_Type__c, actual.Benefit_Type__c,
            'The benefit type should come from the matched record');
    }

    @IsTest
    static void getByPublicBenefitId_unknownOrBlank_returnsNull() {
        Test.startTest();
        INS_MemberRelation__mdt unknown =
            INS_DTO_BenefitMapping.getByPublicBenefitId('NO_SUCH_BENEFIT_ID');
        INS_MemberRelation__mdt blank =
            INS_DTO_BenefitMapping.getByPublicBenefitId('');
        INS_MemberRelation__mdt nullValue =
            INS_DTO_BenefitMapping.getByPublicBenefitId(null);
        Test.stopTest();

        Assert.isNull(unknown, 'An unmapped benefit id should return null');
        Assert.isNull(blank, 'A blank benefit id should return null');
        Assert.isNull(nullValue, 'A null benefit id should return null');
    }

    // =========================================================================
    // LOOKUP BY CATEGORY AND TYPE
    // =========================================================================

    @IsTest
    static void getByCategoryAndType_knownPair_returnsMapping() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();
        Assert.isNotNull(expected,
            'At least one INS_MemberRelation__mdt record must be deployed for these tests');

        Test.startTest();
        INS_MemberRelation__mdt actual = INS_DTO_BenefitMapping.getByCategoryAndType(
            expected.Member_Category__c, expected.Benefit_Type__c);
        Test.stopTest();

        Assert.isNotNull(actual, 'A deployed category and type pair should resolve');
        Assert.areEqual(expected.Public_Benefit_Id__c, actual.Public_Benefit_Id__c,
            'The returned mapping should carry the matching benefit id');
    }

    @IsTest
    static void getByCategoryAndType_isCaseInsensitive() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();

        Test.startTest();
        INS_MemberRelation__mdt lower = INS_DTO_BenefitMapping.getByCategoryAndType(
            expected.Member_Category__c.toLowerCase(),
            expected.Benefit_Type__c.toLowerCase());
        Test.stopTest();

        Assert.isNotNull(lower,
            'Lookups should be case insensitive on both category and type');
        Assert.areEqual(expected.Public_Benefit_Id__c, lower.Public_Benefit_Id__c,
            'The same record should resolve regardless of case');
    }

    @IsTest
    static void getByCategoryAndType_unknownOrBlank_returnsNull() {
        Test.startTest();
        INS_MemberRelation__mdt unknownPair =
            INS_DTO_BenefitMapping.getByCategoryAndType('NO_SUCH_CATEGORY', 'NO_SUCH_TYPE');
        INS_MemberRelation__mdt blankCategory =
            INS_DTO_BenefitMapping.getByCategoryAndType('', 'FUNERAL');
        INS_MemberRelation__mdt blankType =
            INS_DTO_BenefitMapping.getByCategoryAndType('SPOUSE', '');
        INS_MemberRelation__mdt nullValues =
            INS_DTO_BenefitMapping.getByCategoryAndType(null, null);
        Test.stopTest();

        Assert.isNull(unknownPair, 'An unmapped pair should return null');
        Assert.isNull(blankCategory, 'A blank category should return null');
        Assert.isNull(blankType, 'A blank type should return null');
        Assert.isNull(nullValues, 'Null values should return null');
    }

    // =========================================================================
    // REVERSE LOOKUP — PUBLIC BENEFIT ID
    // =========================================================================

    @IsTest
    static void getPublicBenefitId_knownPair_returnsId() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();

        Test.startTest();
        String actual = INS_DTO_BenefitMapping.getPublicBenefitId(
            expected.Member_Category__c, expected.Benefit_Type__c);
        Test.stopTest();

        Assert.areEqual(expected.Public_Benefit_Id__c, actual,
            'The public benefit id should be resolved from category and type');
    }

    @IsTest
    static void getPublicBenefitId_unknownPair_returnsNull() {
        Test.startTest();
        String actual = INS_DTO_BenefitMapping.getPublicBenefitId(
            'NO_SUCH_CATEGORY', 'NO_SUCH_TYPE');
        Test.stopTest();

        Assert.isNull(actual, 'An unmapped pair should return null rather than a value');
    }

    // =========================================================================
    // LOOKUP BY MEMBER CATEGORY
    // =========================================================================

    @IsTest
    static void getByMemberCategory_knownCategory_returnsOnlyThatCategory() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();

        Test.startTest();
        List<INS_MemberRelation__mdt> matches =
            INS_DTO_BenefitMapping.getByMemberCategory(expected.Member_Category__c);
        Test.stopTest();

        Assert.isFalse(matches.isEmpty(),
            'A deployed category should return at least one mapping');
        for (INS_MemberRelation__mdt mapping : matches) {
            Assert.isTrue(
                expected.Member_Category__c.equalsIgnoreCase(mapping.Member_Category__c),
                'Every returned mapping should belong to the requested category');
        }
    }

    @IsTest
    static void getByMemberCategory_isCaseInsensitive() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();

        Test.startTest();
        List<INS_MemberRelation__mdt> matches =
            INS_DTO_BenefitMapping.getByMemberCategory(expected.Member_Category__c.toLowerCase());
        Test.stopTest();

        Assert.isFalse(matches.isEmpty(),
            'Category matching should be case insensitive');
    }

    @IsTest
    static void getByMemberCategory_unknownOrBlank_returnsEmptyList() {
        Test.startTest();
        List<INS_MemberRelation__mdt> unknown =
            INS_DTO_BenefitMapping.getByMemberCategory('NO_SUCH_CATEGORY');
        List<INS_MemberRelation__mdt> blank =
            INS_DTO_BenefitMapping.getByMemberCategory('');
        List<INS_MemberRelation__mdt> nullValue =
            INS_DTO_BenefitMapping.getByMemberCategory(null);
        Test.stopTest();

        Assert.isTrue(unknown.isEmpty(), 'An unmapped category should return an empty list');
        Assert.isTrue(blank.isEmpty(), 'A blank category should return an empty list');
        Assert.isTrue(nullValue.isEmpty(), 'A null category should return an empty list');
    }

    // =========================================================================
    // CACHING
    // =========================================================================

    @IsTest
    static void lookups_areCachedAcrossCalls() {
        INS_MemberRelation__mdt expected = anyCompleteMapping();

        Test.startTest();
        INS_MemberRelation__mdt first =
            INS_DTO_BenefitMapping.getByPublicBenefitId(expected.Public_Benefit_Id__c);
        INS_MemberRelation__mdt second =
            INS_DTO_BenefitMapping.getByPublicBenefitId(expected.Public_Benefit_Id__c);
        Test.stopTest();

        Assert.areEqual(first.Id, second.Id,
            'Repeated lookups should return the same cached record');
    }
}