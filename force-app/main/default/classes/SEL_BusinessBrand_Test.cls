/**
 * @description Test class for SEL_BusinessBrand selector
 * @author Shams Arifeen
 * @date 2026-06-26
 * @user story SFP-58864
 */
@IsTest(SeeAllData=false IsParallel=false)
private class SEL_BusinessBrand_Test {

    private static final String BRAND_NAME = 'Test Liberty Brand';

    @IsTest
    static void testSelectByNameFound() {
        BusinessBrand brand = new BusinessBrand(Name = BRAND_NAME);
        insert brand;

        Test.startTest();
        BusinessBrand result = new SEL_BusinessBrand().selectByName(BRAND_NAME);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected a non-null BusinessBrand for a matching name');
        Assert.isNotNull(result.Id, 'BusinessBrand Id should be populated');
    }

    @IsTest
    static void testSelectByNameNotFoundReturnsNull() {
        Test.startTest();
        BusinessBrand result = new SEL_BusinessBrand().selectByName('Nonexistent Brand XYZ');
        Test.stopTest();

        Assert.isNull(result, 'Expected null when no BusinessBrand matches the name');
    }

    @IsTest
    static void testSelectByBlankNameReturnsNull() {
        Test.startTest();
        BusinessBrand result = new SEL_BusinessBrand().selectByName('');
        Test.stopTest();

        Assert.isNull(result, 'Expected null for a blank name without querying');
    }

    @IsTest
    static void testGetSObjectType() {
        Assert.areEqual(
            BusinessBrand.SObjectType,
            new SEL_BusinessBrand().getSObjectType(),
            'getSObjectType must return BusinessBrand.SObjectType'
        );
    }

    @IsTest
    static void testGetSObjectFieldList() {
        List<Schema.SObjectField> fields = new SEL_BusinessBrand().getSObjectFieldList();
        Assert.isFalse(fields.isEmpty(), 'Field list must not be empty');
        Assert.isTrue(fields.contains(BusinessBrand.Id),   'Field list must contain Id');
        Assert.isTrue(fields.contains(BusinessBrand.Name), 'Field list must contain Name');
    }
}