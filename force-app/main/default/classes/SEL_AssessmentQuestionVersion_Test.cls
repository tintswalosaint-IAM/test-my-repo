/**
* @description Class for Selector Class for AssessmentQuestionVersion Entity Test class
*
* Story:SFP-37439
*
* @author Tushar Walse
*
* @date 18/10/2024
*/
@isTest
private class SEL_AssessmentQuestionVersion_Test {
 /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        ICS_DAL_TestFactory.createAssessmentQuestion();
    }
    
    /**
     * @description Test the getSObjectType method of SEL_AssessmentQuestionVersion class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_AssessmentQuestionVersion assesmentQuestionVersionSelector = new SEL_AssessmentQuestionVersion();
        Test.startTest();
        Schema.SObjectType sObjectType = assesmentQuestionVersionSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(AssessmentQuestionVersion.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description Test the getSObjectFieldList method of SEL_AssessmentQuestionVersion class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_AssessmentQuestionVersion assesmentQuestionVersionSelector = new SEL_AssessmentQuestionVersion();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = assesmentQuestionVersionSelector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }
    
    /**
     * @description Test the selectById method of SEL_AssessmentQuestionVersion class
     */
    @isTest
    static void testSelectById() {
        Id assessmentQuestionVersionId = [Select Id from AssessmentQuestionVersion][0].Id;
        SEL_AssessmentQuestionVersion assesmentQuestionVersionSelector = new SEL_AssessmentQuestionVersion();
        Test.startTest();
        AssessmentQuestionVersion assessmentQuestionVersion = assesmentQuestionVersionSelector.selectById(assessmentQuestionVersionId);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionVersion != null, 'Expected at least one AssessmentQuestionVersion record.');
    }


    /**
     * @description Test the selectById method of SEL_AssessmentQuestionVersion class
     */
    @isTest
    static void testSelectByIds() {
        Set<Id> assessmentQuestionVersionIds = new Map<Id, AssessmentQuestionVersion>([Select Id from AssessmentQuestionVersion]).keySet();
        SEL_AssessmentQuestionVersion assesmentQuestionVersionSelector = new SEL_AssessmentQuestionVersion();
        Test.startTest();
        List<AssessmentQuestionVersion> assessmentQuestionVersionList = assesmentQuestionVersionSelector.selectByIds(assessmentQuestionVersionIds);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionVersionList.size() > 0, 'Expected at least one AssessmentQuestionVersion record.');
    }
}