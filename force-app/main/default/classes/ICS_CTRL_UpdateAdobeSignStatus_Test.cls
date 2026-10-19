/***************************************************************************************
@ Author            :Ikyatha Naidu
@ Date              :2024-02-24
@ Name of the Class :ICS_CTRL_UpdateAdobeSignStatus_Test
@ Description       :class used to testclass
@ Last Modified By  :Ikyatha Naidu
@ Last Modified On  :2024-02-24
@ Modification Description :SFP-30254
***************************************************************************************/
@IsTest
private class ICS_CTRL_UpdateAdobeSignStatus_Test {
    @TestSetup
    static void setupTestData() {
        // Create test data using ICS_DAL_TestFactory
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        Opportunity testOpportunity = ICS_DAL_TestFactory.createOpportunity(testAccount.Id);
        ICS_DAL_TestFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        echosign_dev1__SIGN_Agreement__c agreement =new echosign_dev1__SIGN_Agreement__c();
        agreement.Name ='test';
        agreement.echosign_dev1__Account__c = testAccount.id;
        insert agreement;
    }

    @IsTest
    static void testUpdateApplicationFormStatus() {
        // Retrieve the test data
        Account testAccount = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        ApplicationForm testAppForm = [SELECT Id FROM ApplicationForm LIMIT 1];
		echosign_dev1__SIGN_Agreement__c agreement =[select id from echosign_dev1__SIGN_Agreement__c LIMIT 1];
        // Create test Echosign_Dev1__SIGN_Recipients__c records
        List<Echosign_Dev1__SIGN_Recipients__c> testRecipients = new List<Echosign_Dev1__SIGN_Recipients__c>{
            new Echosign_Dev1__SIGN_Recipients__c(
                echosign_dev1__Agreement__c = agreement.id,
                echosign_dev1__Contact__c = testAccount.PersonContactId,
                echosign_dev1__Status__c = ICS_Constants.Signed
            ),
            new Echosign_Dev1__SIGN_Recipients__c(
                echosign_dev1__Agreement__c = agreement.id,
                echosign_dev1__Contact__c = testAccount.PersonContactId,
                echosign_dev1__Status__c = 'Waiting for Signature'
            )
        };
        insert testRecipients;

        Test.startTest();
        ICS_CTRL_UpdateAdobeSignStatus.updateStatusesOnSignature(testRecipients);
        Test.stopTest();

        // Verify the ApplicationForm status has been updated
        ApplicationForm updatedAppForm = [SELECT Id, Stage FROM ApplicationForm WHERE Id = :testAppForm.Id];
        Assert.areEqual(ICS_Constants.Signed, updatedAppForm.Stage, 'ApplicationForm stage should be updated to Signed');

        // Verify the Opportunity stage has been updated
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Assert.areEqual('Risk Rating', updatedOpportunity.StageName, 'Opportunity stage should be updated to Risk Rating');
    }

    @IsTest
    static void testUpdateApplicationFormStatus_NoSignedRecipients() {
        // Retrieve the test data
        Account testAccount = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        ApplicationForm testAppForm = [SELECT Id, Stage FROM ApplicationForm LIMIT 1];
        String initialStage = testAppForm.Stage;
		echosign_dev1__SIGN_Agreement__c agreement =[select id from echosign_dev1__SIGN_Agreement__c LIMIT 1];
        // Create test Echosign_Dev1__SIGN_Recipients__c records with no signed status
        List<Echosign_Dev1__SIGN_Recipients__c> testRecipients = new List<Echosign_Dev1__SIGN_Recipients__c>{
            new Echosign_Dev1__SIGN_Recipients__c(
                echosign_dev1__Agreement__c = agreement.id,
                echosign_dev1__Contact__c = testAccount.PersonContactId,
                echosign_dev1__Status__c = 'Waiting for Signature'
            )
        };
        insert testRecipients;
 
        Test.startTest();
        ICS_CTRL_UpdateAdobeSignStatus.updateStatusesOnSignature(testRecipients);
        Test.stopTest(); 

        // Verify the ApplicationForm status has not been updated
        ApplicationForm updatedAppForm = [SELECT Id, Stage FROM ApplicationForm WHERE Id = :testAppForm.Id];
        Assert.areEqual(initialStage, updatedAppForm.Stage, 'ApplicationForm stage should not be updated');

        // Verify the Opportunity stage has not been updated
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Assert.areNotEqual('Risk Rating', updatedOpportunity.StageName, 'Opportunity stage should not be updated to Risk Rating');
    }

    @IsTest
    static void testUpdateOpportunityStages() {
        // Retrieve the test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ApplicationForm testAppForm = [SELECT Id, AccountId FROM ApplicationForm LIMIT 1];

        // Update the ApplicationForm stage to Signed
        testAppForm.Stage = ICS_Constants.Signed;
        update testAppForm;

        // Prepare the input for updateOpportunityStages
        Map<Id, Set<Id>> accountToFormIdsMap = new Map<Id, Set<Id>>();
        accountToFormIdsMap.put(testAccount.Id, new Set<Id>{testAppForm.Id});

        Test.startTest();
        ICS_CTRL_UpdateAdobeSignStatus.updateStages(accountToFormIdsMap);
        Test.stopTest();

        // Verify the Opportunity stage has been updated
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Assert.areEqual('Risk Rating', updatedOpportunity.StageName, 'Opportunity stage should be updated to Risk Rating');
    }

    @IsTest
    static void testUpdateOpportunityStages_NoUpdate() {
        // Retrieve the test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        ApplicationForm testAppForm = [SELECT Id, AccountId FROM ApplicationForm LIMIT 1];

        // Keep the ApplicationForm stage as is (not Signed)
        // Prepare the input for updateOpportunityStages
        Map<Id, Set<Id>> accountToFormIdsMap = new Map<Id, Set<Id>>();
        accountToFormIdsMap.put(testAccount.Id, new Set<Id>{testAppForm.Id});

        Test.startTest();
        ICS_CTRL_UpdateAdobeSignStatus.updateStages(accountToFormIdsMap);
        Test.stopTest();

        // Verify the Opportunity stage has not been updated
        Opportunity updatedOpportunity = [SELECT Id, StageName FROM Opportunity LIMIT 1];
        Assert.areNotEqual('Risk Rating', updatedOpportunity.StageName, 'Opportunity stage should not be updated to Risk Rating');
    }

    @IsTest
    static void testUpdateOpportunityStages_Error() {
        // Simulate an error by providing an empty map
        Map<Id, Set<Id>> emptyMap = new Map<Id, Set<Id>>();

        Test.startTest();
        try {
            ICS_CTRL_UpdateAdobeSignStatus.updateStages(emptyMap);
        } catch (Exception e) {
            // Verify that an exception is thrown
            Assert.isTrue(e.getMessage().contains('Error occurred while updating Opportunities'), 'Expected error message not found');
        }
        Test.stopTest();
    }
}