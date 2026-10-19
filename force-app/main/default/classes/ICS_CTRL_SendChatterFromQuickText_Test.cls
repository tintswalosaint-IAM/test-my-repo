/**
 * @Name of the Class : ICS_CTRL_SendChatterFromQuickText_Test
 * @description test class used for ICS_CTRL_SendChatterFromQuickText Controller used for SBO UK 	
 * @author IKYATHA NAIDU
 * @date 11/01/2024
 * @last modified on  : 01/07/2024
 * @last modified by  : IKYATHA NAIDU
 * @Modification Description : Initial Version
 */
@isTest
public class ICS_CTRL_SendChatterFromQuickText_Test { 
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = ics_dal_testFactory.createAccount();
      
		testAccount.PersonBirthdate=date.today().adddays(-365);
        update testAccount;
          ics_dal_testFactory.createOpportunity(testAccount.id);
        // Create PartyProfile
        PartyProfile testPartyProfile = new PartyProfile(
            Name = 'Test PartyProfile',
            AccountId = testAccount.Id,
            Country_of_Residence__c='AF',
			Country_of_Nationality__c='AF'
        );
        insert testPartyProfile;

        // Create PartyProfileRisk
        PartyProfileRisk testPartyProfileRisk = new PartyProfileRisk(
            Name = 'Test PartyProfileRisk',
            PartyProfileId = testPartyProfile.Id,
            OverridenRiskCategory = 'High'
        );
        insert testPartyProfileRisk;

        // Create QuickText
        QuickText testQuickText = new QuickText(
            Name = 'Test QuickText',
            Message = 'Hello {!PartyProfile.FirstName} {!PartyProfile.LastName}, your risk {!PartyProfile.Country_of_Residence__c} category is {!PartyProfileRisk.OverridenRiskCategory}. [TestGroup]  {!PartyProfile.Country_of_Nationality__c}'
        );
        insert testQuickText;

        // Create CollaborationGroup
        CollaborationGroup testGroup = new CollaborationGroup(
            Name = 'TestGroup',
            CollaborationType = 'Public'
        );
        insert testGroup;
    }

    @isTest
    static void testProcessSelectedTemplate() {
        // Create EmailTemplate
        createTestEmailTemplate();

        // Retrieve test data
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        QuickText testQuickText = [SELECT Id FROM QuickText LIMIT 1];

        // Create request parameter
        ICS_CTRL_SendChatterFromQuickText.RequestParam param = new ICS_CTRL_SendChatterFromQuickText.RequestParam();
        param.parentId = testPartyProfile.Id;
        param.quickTextId = testQuickText.Id;
        param.action = true;
        param.email = true;

        Test.startTest();
        List<ICS_CTRL_SendChatterFromQuickText.ResponseParam> result = ICS_CTRL_SendChatterFromQuickText.processSelectedTemplate(new List<ICS_CTRL_SendChatterFromQuickText.RequestParam>{param});
        Test.stopTest();

        // Assertions
        Assert.areEqual(1, result.size(), 'Expected one result');


    }

    @isTest
    static void testProcessSelectedTemplateNoAction() {
        // Create EmailTemplate
        createTestEmailTemplate();

        // Retrieve test data
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        QuickText testQuickText = [SELECT Id FROM QuickText LIMIT 1];

        // Create request parameter with action set to false
        ICS_CTRL_SendChatterFromQuickText.RequestParam param = new ICS_CTRL_SendChatterFromQuickText.RequestParam();
        param.parentId = testPartyProfile.Id;
        param.quickTextId = testQuickText.Id;
        param.action = false;
        param.email = false;

        Test.startTest();
        List<ICS_CTRL_SendChatterFromQuickText.ResponseParam> result = ICS_CTRL_SendChatterFromQuickText.processSelectedTemplate(new List<ICS_CTRL_SendChatterFromQuickText.RequestParam>{param});
        Test.stopTest();

        // Assertions
        Assert.areEqual(0, result.size(), 'Expected no results when action is false');

        // Verify no email was sent
        Integer emailInvocations = Limits.getEmailInvocations();
        Assert.areEqual(0, emailInvocations, 'No emails should have been sent');
    }

    // Separate method to create EmailTemplate
    private static void createTestEmailTemplate() {
        // Query for the folder Id
        Folder folder = [SELECT Id FROM Folder WHERE Type = 'Email' AND AccessType = 'Public' LIMIT 1];
        
        EmailTemplate testTemplate = new EmailTemplate(
            DeveloperName = 'Test_Chatter_Message_Email',
            Name = 'ICS Send Chatter Post Notification',
            IsActive = true,
            FolderId = folder.Id,
            TemplateType = 'text',
            Subject = 'Test Email',
            Body = 'Test Email Body'
        );
        insert testTemplate;
    }
}