/***************************************************************************************
@Name of the Component : SEL_BranchUnit_TEST
@Description : Test class for SEL_BranchUnit
@Author : Raymond Magezi
@Created Date : 15-04-2026
User Story: SFP-55823
/***************************************************************************************
@Last Modified By : Raymond Magezi
@Last Modified On : 22-04-2026
@Modification description: Updated to use instance methods instead of static.
 User Story: SFP-57596
***************************************************************************************/
@IsTest(SeeAllData=false)
private class SEL_BranchUnit_TEST {

    private static final String ASSERT_MSG = 'Picklist values should be returned';

    /**
     * @description Test selectActiveBranches returns picklist values from SVC_BranchName
     */
    @isTest
    private static void testSelectActiveBranchesPositiveOutcome() {
        Test.startTest();
        List<Map<String, String>> results = SEL_BranchUnit.newInstance().selectActiveBranches();
        Test.stopTest();
        Assert.isTrue(!results.isEmpty(), ASSERT_MSG);
        Assert.isNotNull(results[0].get('label'), 'Label should be populated');
        Assert.isNotNull(results[0].get('value'), 'Value should be populated');
    }

    /**
     * @description Test selectActiveDepartments returns picklist values from SVC_DepartmentName
     */
    @isTest
    private static void testSelectActiveDepartmentsPositiveOutcome() {
        Test.startTest();
        List<Map<String, String>> results = SEL_BranchUnit.newInstance().selectActiveDepartments();
        Test.stopTest();
        Assert.isTrue(!results.isEmpty(), ASSERT_MSG);
        Assert.isNotNull(results[0].get('label'), 'Label should be populated');
        Assert.isNotNull(results[0].get('value'), 'Value should be populated');
    }
}