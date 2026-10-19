/***************************************************************************************
@Name of the Component : SEL_SurveyInvitation_TEST
@Description : Test class for SEL_SurveyInvitation
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Updated test assertions to expect List returns from selector
    methods. Removed unused constant. Replaced hardcoded ID.
 User Story: SFP-57596
***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 27-07-2026
@Modification description: Removed testSelectByBranchUnitNoMatch — selectByBranchUnit
    was deleted from SEL_SurveyInvitation (dead code tied to the never-populated
    BranchUnit object, see SEL_SurveyInvitation modification log).
 User Story: SFP-57596
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SEL_SurveyInvitation_TEST {

    private static final String ASSERT_EMPTY = 'Result list should be empty when no match';

    /**
     * @description Test getSObjectType returns SurveyInvitation
     */
    @isTest
    private static void testGetSObjectType() {
        Test.startTest();
        Schema.SObjectType result = SEL_SurveyInvitation.newInstance().getSObjectType();
        Test.stopTest();
        Assert.areEqual(SurveyInvitation.SObjectType, result, 'Should return SurveyInvitation SObjectType');
    }

    /**
     * @description Test getSObjectFieldList returns fields
     */
    @isTest
    private static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectField> fields = SEL_SurveyInvitation.newInstance().getSObjectFieldList();
        Test.stopTest();
        Assert.isTrue(!fields.isEmpty(), 'Field list should not be empty');
    }

    /**
     * @description Test selectByBranchName returns null when no match
     */
    @isTest
    private static void testSelectByBranchNameNoMatch() {
        Test.startTest();
        List<SurveyInvitation> results = SEL_SurveyInvitation.newInstance().selectByBranchName('NONEXISTENT');
        Test.stopTest();
        Assert.isTrue(results.isEmpty(), ASSERT_EMPTY);
    }

    /**
     * @description Test selectById returns null when no match
     */
    @isTest
    private static void testSelectByIdNoMatch() {
        Test.startTest();
        List<SurveyInvitation> results = SEL_SurveyInvitation.newInstance().selectById(null);
        Test.stopTest();
        Assert.isTrue(results.isEmpty(), ASSERT_EMPTY);
    }

    /**
     * @description Test selectByDepartmentName returns null when no match
     */
    @isTest
    private static void testSelectByDepartmentNameNoMatch() {
        Test.startTest();
        List<SurveyInvitation> results = SEL_SurveyInvitation.newInstance().selectByDepartmentName('NONEXISTENT');
        Test.stopTest();
        Assert.isTrue(results.isEmpty(), ASSERT_EMPTY);
    }

}