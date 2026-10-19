/**
 * @description       : Test class for AOB_CTRL_NeedsAnalysisGeneratePDF controller class for generating PDF document
 * @author            : Madito Tsilo
 * @UserStory         : SFP-52370
 * @date              : 25-10-2025
 **/
@IsTest
private class AOB_CTRL_NeedsAnalysisGeneratePDF_Test {

    @IsTest
    static void testWithJsonInput() {
        // Create a generic JSON input (replace fields once known)
        String jsonInput = '{"someField":"someValue"}';
        
        // Simulate a Visualforce page with a parameter
        PageReference pageRef = new PageReference('/apex/AOB_NeedsAnalysisGeneratePDF');
        pageRef.getParameters().put('jsonString', jsonInput);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        AOB_CTRL_NeedsAnalysisGeneratePDF ctrl = new AOB_CTRL_NeedsAnalysisGeneratePDF();
        Test.stopTest();

        // Verify that the wrapper was initialized
        Assert.areNotEqual(null, ctrl.data, 'Wrapper data should not be null');
    }

    @IsTest
    static void testWithoutJsonInput() {
        // Simulate page without parameters
        PageReference pageRef = new PageReference('/apex/AOB_NeedsAnalysisGeneratePDF');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        AOB_CTRL_NeedsAnalysisGeneratePDF ctrl = new AOB_CTRL_NeedsAnalysisGeneratePDF();
        Test.stopTest();

        // Verify wrapper still initialized
        Assert.areNotEqual(null, ctrl.data, 'Wrapper data should be initialized even without JSON');
    }
}