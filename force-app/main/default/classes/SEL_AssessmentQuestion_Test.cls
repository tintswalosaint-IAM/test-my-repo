/**
* @description Test class for SEL_AssessmentQuestion
* @author Tushar Walse
* @date 18/10/2024
* @last modified on  : 20-10-2024
* @last modified by  : Tushar Walse
* @Modification Description : Added methods
*/
@isTest
private class SEL_AssessmentQuestion_Test {
 /**
     * @description Create common test data for the test methods
     */
    @TestSetup
    static void setupTestData() {
        ICS_DAL_TestFactory.createAssessmentQuestion();
    }
    
    /**
     * @description Test the getSObjectType method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testGetSObjectType() {
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        Schema.SObjectType sObjectType = assessmentQuestionSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(AssessmentQuestion.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description Test the getSObjectFieldList method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testGetSObjectFieldList() {
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = assessmentQuestionSelector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the field list.');
    }
    
    /**
     * @description Test the selectById method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testSelectById() {
        Id assessmentQuestionId = [Select Id from AssessmentQuestion][0].Id;
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        AssessmentQuestion assessmentQuestion = assessmentQuestionSelector.selectById(assessmentQuestionId);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestion != null, 'Expected at least one AssessmentQuestion record.');
    }


    /**
     * @description Test the selectById method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testSelectByIds() {
        Set<Id> assessmentQuestionIds = new Map<Id, AssessmentQuestion>([Select Id from AssessmentQuestion]).keySet();
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        List<AssessmentQuestion> assessmentQuestionList = assessmentQuestionSelector.selectByIds(assessmentQuestionIds);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionList.size() > 0, 'Expected at least one AssessmentQuestion record.');
    }
    
    /**
     * @description Test the selectByActiveVersionIds method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testSelectByActiveVersionIds() {
        List<AssessmentQuestion> assessmentQuestions = [Select Id, ActiveVersionId from AssessmentQuestion];
        Set<Id> activeVersionIds = new Set<Id>();
        for(AssessmentQuestion eachQuestion : assessmentQuestions){
            activeVersionIds.add(eachQuestion.ActiveVersionId);
        }

        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        List<AssessmentQuestion> assessmentQuestionList = assessmentQuestionSelector.selectByActiveVersionIds(activeVersionIds);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionList.size() > 0, 'Expected at least one AssessmentQuestion record.');
    }
    
    /**
     * @description Test the selectByNames method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testSelectByNames() {
        List<AssessmentQuestion> assessmentQuestions = [Select Id, Name from AssessmentQuestion];
        Set<String> assessmentQuestionNamesSet = new Set<String>();
        for(AssessmentQuestion eachQuestion : assessmentQuestions){
            assessmentQuestionNamesSet.add(eachQuestion.Name);
        }
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        List<AssessmentQuestion> assessmentQuestionList = assessmentQuestionSelector.selectByNames(assessmentQuestionNamesSet);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionList.size() > 0, 'Expected at least one AssessmentQuestion record.');
    }

    /**
     * @description Test the selectByDeveloperNames method of SEL_AssessmentQuestion class
     */
    @isTest
    static void testSelectByDeveloperNames() {
        List<AssessmentQuestion> assessmentQuestions = [Select Id, DeveloperName from AssessmentQuestion];
        Set<String> assessmentQuestionDeveloperNamesSet = new Set<String>();
        for(AssessmentQuestion eachQuestion : assessmentQuestions){
            assessmentQuestionDeveloperNamesSet.add(eachQuestion.DeveloperName);
        }
        SEL_AssessmentQuestion assessmentQuestionSelector = new SEL_AssessmentQuestion();
        Test.startTest();
        List<AssessmentQuestion> assessmentQuestionList = assessmentQuestionSelector.selectByDeveloperNames(assessmentQuestionDeveloperNamesSet);
        Test.stopTest();
        Assert.areEqual(true, assessmentQuestionList.size() > 0, 'Expected at least one AssessmentQuestion record.');
    }
}