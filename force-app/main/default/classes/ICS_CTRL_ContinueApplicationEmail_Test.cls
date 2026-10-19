/***************************************************************************************
@name of the Class : ICS_CTRL_ContinueWithApplicationEmail_Test.cls
@Story:SFP-34724
@description :Testclass used to cover the ICS_CTRL_ContinueWithApplicationEmail class
@author : Shravani Ganta
@created Date : 04 March 2024
/***************************************************************************************
@last Modified By : Ruchi Agrawal
@last Modified On : 18-09-2024
@modification description: Updated to latest version
***************************************************************************************/
@IsTest
public class ICS_CTRL_ContinueApplicationEmail_Test {
    /**
     * @description This method is used creating setup data
   */
    @TestSetup
    static void setup() {
        // Create test Account (Person Account)
        Account testAccount = new Account(
            FirstName = 'Test11',
            LastName = 'Account',
            PersonEmail = 'test@example.com',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert testAccount;

        // Create test Contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test@example.com'
        );
        insert testContact;
        // Create test Opportunity
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity12',
            CloseDate = Date.today().addDays(7),
            StageName = 'Review',
            AccountId = testAccount.Id
        );
		
        insert testOpportunity;
		OpportunityContactRole oppConRole=new OpportunityContactRole();
			oppConRole.OpportunityId=testOpportunity.id;
			oppConRole.ContactId=testContact.id;
			oppConRole.Role='IFA';
			insert oppConRole;

        // Create test ApplicationForm
        ApplicationForm testApplicationForm = new ApplicationForm(
            OpportunityId = testOpportunity.Id,
            Stage = 'Awaiting Form Filling',
            AccountId = testAccount.Id,
            usagetype='Onboarding'
        );
        insert testApplicationForm;
        // Create test Applicant
        Applicant testApplicant = new Applicant(
            Email = 'applicant@example.com',
            ApplicationFormId = testApplicationForm.Id
        );
        insert testApplicant;
        // Create test PartyProfile
        PartyProfile testPartyProfile = new PartyProfile(
            AccountId = testAccount.Id, 
            Name = 'Test Profile Record 1'
        );
        insert testPartyProfile;
    }
    /**
     * @description This method is used to test email template to be sent as an email
   */
    @IsTest
    static void testContinueApplication() {
        // Query for the created PartyProfile
        List<PartyProfile> testProfileRecords = [SELECT Id FROM PartyProfile WHERE Name = 'Test Profile Record 1'];
        List<String> partyProfileIds = new List<String>();
        for (PartyProfile pp : testProfileRecords) {
            partyProfileIds.add(pp.Id);
        }

        Test.startTest();
        ICS_CTRL_ContinueWithApplicationEmail.queryEmailTemplate(partyProfileIds);
        Test.stopTest();

        // Assert that no emails were sent (as per the original test)
        Assert.areEqual(0, Limits.getEmailInvocations(), 'No email should be sent');
    }
}