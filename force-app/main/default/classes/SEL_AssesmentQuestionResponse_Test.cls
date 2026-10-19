/**
 * @Name of the class: SEL_AssesmentQuestionResponse_Test.cls
 * @description: Test Class for Selector Class for AssessmentQuestionResponse Entity.
 * This class contains test methods to verify the functionality of the 
 * SEL_AssesmentQuestionResponse class methods. 
 *
 * Story: SFP-37439
 *
 * @author Ikyatha Naidu
 *
 * @date 29/03/2024
 *********************************
 * @last modified on: 21-10-2024
 * @last modified by: Tushar Walse
 * @Modification Description: Updated to the latest version
 */
@IsTest
private class SEL_AssesmentQuestionResponse_Test {
    
    /**
     * @description: Test data setup for the SEL_AssesmentQuestionResponse tests.
     * Creates required test records such as Account, Assessment, AssessmentQuestion, 
     * AssessmentQuestionVersion, and AssessmentQuestionResponse.
     */
    @TestSetup
    static void setupTestData() {
        Account acc = ICS_DAL_TestFactory.createAccount();
        Assessment ass = ICS_DAL_TestFactory.createAssessment(acc.Id);
        AssessmentQuestionVersion aqv = ICS_DAL_TestFactory.createAssessmentQuestionVersion();
        ICS_DAL_TestFactory.createAssessmentQuestionResponse(ass.Id, aqv.Id);
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(acc.Id);
        ass.PartyProfileId = testPartyProfile.Id;
    }
    
    /**
     * @description: Test the getSObjectType method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns the expected SObjectType for AssessmentQuestionResponse.
     */
    @IsTest
    static void testGetSObjectType() {
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        Schema.SObjectType sObjectType = assessmentQuestionResponseSelector.getSObjectType();
        Test.stopTest();
        Assert.areEqual(AssessmentQuestionResponse.SObjectType, sObjectType, 'Unexpected SObjectType');
    }
    
    /**
     * @description: Test the getSObjectFieldList method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a non-empty list of fields for AssessmentQuestionResponse.
     */
    @IsTest
    static void testGetSObjectFieldList() {
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        List<Schema.SObjectField> sObjectFieldList = assessmentQuestionResponseSelector.getSObjectFieldList();
        Test.stopTest();
        Assert.areEqual(true, sObjectFieldList.size() > 0, 'Expected at least one field in the list.');
    }
    
    /**
     * @description: Test the selectByParentId method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a list of AssessmentQuestionResponse records for a given Account Id.
     */
    @IsTest
    static void testSelectByParentId() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        List<AssessmentQuestionResponse> assList = assessmentQuestionResponseSelector.selectByParentId(acc.Id);
        Test.stopTest();
        Assert.areEqual(true, assList.size() > 0, 'Expected at least one AssessmentQuestionResponse record to be returned.');
    }
    
    /**
     * @description: Test the selectByParentIdAndSectionName method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a list of AssessmentQuestionResponse records for a given Account Id 
     * and section name.
     */
    @IsTest
    static void testSelectByParentIdAndSectionName() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        List<AssessmentQuestionResponse> assList = assessmentQuestionResponseSelector.selectByParentIdAndSectionName(acc.Id, 'Future Deposit');
         assessmentQuestionResponseSelector.selectByAccountIdAndAssessmentName(acc.Id, 'Future Deposit');
        assessmentQuestionResponseSelector.selectByAccountIdAndName(acc.Id, 'Future Deposit');
        Test.stopTest();
        Assert.areEqual(false, assList.size() > 0, 'Expected at least one AssessmentQuestionResponse record for section name "Future Deposit".');
    }
    
    /**
     * @description: Test the selectByAssessmentIds method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a list of AssessmentQuestionResponse records for a given set of Assessment Ids.
     */
    @IsTest
    static void testSelectByAssessmentIds() {
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        Set<Id> assessmentIds = new Set<Id>{ [SELECT Id FROM Assessment LIMIT 1].Id };
        List<AssessmentQuestionResponse> assList = assessmentQuestionResponseSelector.selectByAssessmentIds(assessmentIds);
        Test.stopTest();
        Assert.areEqual(true, assList.size() > 0, 'Expected at least one AssessmentQuestionResponse record for the provided Assessment Ids.');
    }

    /**
     * @description: Test the selectByAssessmentNames method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a list of AssessmentQuestionResponse records for a given set of Assessment Ids.
     */
    @IsTest
    static void testSelectByAssessmentNames() {
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        List<AssessmentQuestionResponse> assList = assessmentQuestionResponseSelector.selectByAssessmentNames(new String[]{'xyz'});
       
        Test.stopTest();
        Assert.areEqual(true, assList.size() == 0, 'No records should be returned here');
    } 

   /**
     * @description: Test the selectByParentIds method of the SEL_AssesmentQuestionResponse class.
     * Verifies that the method returns a list of AssessmentQuestionResponse records for a given set of Assessment Ids.
     */
    @IsTest
    static void testSelectByParentIds() {
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        Test.startTest();
        List<AssessmentQuestionResponse> assList = assessmentQuestionResponseSelector.selectByParentIds(testPartyProfile.Id);
        Test.stopTest();
        Assert.areEqual(true, assList.size() == 0, 'Expected no AssessmentQuestionResponse record');
    } 
    
    /**
 * @description: Test the selectByParentIdAndSectionNameAndAssesmentName method.
 * Verifies that the method returns a list of AssessmentQuestionResponse records 
 * for a given Parent Id, Section Name, and Assessment Name.
 */
    @IsTest
    static void testSelectByParentIdAndSectionNameAndAssessmentName() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Assessment ass = [SELECT Id, Name FROM Assessment LIMIT 1];
        
        String sectionName = 'Sample Section';
        
        SEL_AssesmentQuestionResponse assessmentQuestionResponseSelector = new SEL_AssesmentQuestionResponse();
        
        Test.startTest();
        List<AssessmentQuestionResponse> responses = assessmentQuestionResponseSelector.selectByParentIdAndSectionNameAndAssesmentName(
            acc.Id, 
            sectionName, 
            ass.Name
        );
        Test.stopTest();
        
        Assert.areNotEqual(null, responses, 'Expected a valid list of AssessmentQuestionResponse records.');
    }
}