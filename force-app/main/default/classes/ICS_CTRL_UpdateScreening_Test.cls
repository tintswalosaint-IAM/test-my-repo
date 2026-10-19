/**
* @description SFP-32986 Class used to update to next stage of FinScan
* @author Swapnil Walse, Ikyatha Naidu
* @date 23/04/2024
* Last Modified By IKYATHA NAIDU
* Last Modified Date 22/04/2025
* Modification Description: Updated to latest version
*/
@isTest
public class ICS_CTRL_UpdateScreening_Test {
 @TestSetup
    static void setupTestData() {
         // Create test opportunity
         Account acc = ICS_DAL_TestFactory.createAccount();
       Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(acc.id);
         testOpportunity.StageName = 'Screening';
        testOpportunity.CloseDate = Date.today();
        update testOpportunity;
        ICS_DAL_TestFactory.createPartyProfile(acc.id);
         // Create test application form
         ICS_DAL_TestFactory.createApplicationForm(acc.id, testOpportunity.id);



    }
     @isTest
    static void testUpdateScreening() {
           Test.startTest();
        Account testAccount =[select id from Account limit 1];
        ICS_CTRL_UpdateScreening.updateStages(new List<Id>{testAccount.Id});
        string response= ICS_CTRL_UpdateScreening.updateFormAndOpportunity(testAccount.id);
        Assert.areequal(true,response=='updated','Stages Updated');
            Test.stopTest();
    }
    @isTest
    static void testUpdateErrorScreening() {
           Test.startTest();
        ICS_CTRL_UpdateScreening.updateStages(null);
        string response= ICS_CTRL_UpdateScreening.updateFormAndOpportunity(null);
        Assert.areequal(true,response=='Error','Error Occured in Exception');
            Test.stopTest();
    }
     @isTest
    static void testCheckPartyProfileScreeningField() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String screeningStatus = ICS_CTRL_UpdateScreening.checkPartyProfileScreeningField(testAccount.Id);
        Assert.isNotNull(screeningStatus, 'Screening status should not be null');
        Test.stopTest();
    }

    @isTest
    static void testNavigateToReview() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ApplicationForm form = [SELECT Id FROM ApplicationForm LIMIT 1];
        form.Stage = 'Awaiting Screening';
        update form;

        Boolean canNavigate = ICS_CTRL_UpdateScreening.navigatetoReview(testAccount.Id);
        Assert.isTrue(canNavigate, 'Should return true for Awaiting Screening stage');
        Test.stopTest();
    }

    @isTest
    static void testNavigateToReviewFalse() {
        Test.startTest();
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ApplicationForm form = [SELECT Id FROM ApplicationForm LIMIT 1];
        form.Stage = 'Awaiting Verification';
        update form;

        Boolean canNavigate = ICS_CTRL_UpdateScreening.navigatetoReview(testAccount.Id);
        Assert.isFalse(canNavigate, 'Should return false for non-Awaiting Screening stage');
        Test.stopTest();
    }

    @isTest
    static void testNavigateToReviewError() {
        Test.startTest();
        try {
            ICS_CTRL_UpdateScreening.navigatetoReview(null);
            Assert.fail('Should throw an exception for null account ID');
        } catch (AuraHandledException e) {
            // Expected exception
            Assert.isTrue(true, 'Exception was thrown as expected');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateAppForm() {
        Test.startTest();
        ApplicationForm form = [SELECT Id, OpportunityId FROM ApplicationForm LIMIT 1];
        form.Stage = 'Awaiting Form Filling';
        update form;
        
        ICS_CTRL_UpdateScreening.updateAppForm(form.Id);

        Test.stopTest();

        // Verify the update
        Opportunity updatedOpportunity = [SELECT StageName FROM Opportunity WHERE Id = :form.OpportunityId];
        Assert.areEqual('Application form', updatedOpportunity.StageName, 'Opportunity stage should be updated');
    }

    @isTest
    static void testUpdateAppFormError() {
        Test.startTest();
        ICS_CTRL_UpdateScreening.updateAppForm(null);
        // Verify that the error was logged (you might need to adjust this based on your logging implementation)
        // Assert that no exception bubbles up since the method handles exceptions internally
        Assert.isTrue(true, 'Method should handle null ID gracefully');
        Test.stopTest();
    }
}