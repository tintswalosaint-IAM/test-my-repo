/**
* @description Testclass used to cover the ICS_CTRL_PingVerificationEmail class
*
* Story:SFP-36380
*
* @author Ikyatha Naidu
*
* @date May 2023
* @last modified on  : 17-03-2025
* @last modified by  : Shravani Ganta
* @Modification Description : SFP-36380 class used for Ping Email verification
*/   
@isTest
public class ICS_CTRL_PingVerification_Test {
    @testSetup
    static void setupTestData() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'test@example.com',
            AccountId = testAccount.Id);
        insert testContact;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            AccountId = testAccount.Id);
        insert testOpportunity;
        
        ApplicationForm testAppForm = new ApplicationForm(
            AccountId = testAccount.Id,
            UsageType = 'Onboarding',
            OpportunityId = testOpportunity.Id);
        insert testAppForm;
        
        PartyProfile testPartyProfile = new PartyProfile(
            AccountId = testAccount.Id,
            Name = testAccount.Name,
            Country_of_Nationality__c = 'UA',
            Country_of_Residence__c = 'UA',
            OwnerId = UserInfo.getUserId());
        insert testPartyProfile;
    }
    
    @isTest
    static void testPingVerificationEmail() {
        Test.startTest();
        ICS_CTRL_PingVerificationEmail.pingVerificationEmail([SELECT Id FROM Opportunity LIMIT 1].Id,'CURR_OPT');
        Test.stopTest();
        Assert.areEqual(0, Limits.getEmailInvocations());
    }
    @isTest
    static void testPingVerificationEmailSeafarer() {
        Test.startTest();
        ICS_CTRL_PingVerificationEmail.pingVerificationEmail([SELECT Id FROM Opportunity LIMIT 1].Id,'CURR_SEA');
        Test.stopTest();
        Assert.areEqual(0, Limits.getEmailInvocations());
    }
    
    @isTest
    static void testCheckCountryOfNationalityOrResidence() {
        Test.startTest();
        Boolean result = ICS_CTRL_PingVerificationEmail.checkCountryOfNationalityOrResidence([SELECT Id FROM Opportunity LIMIT 1].Id);
        Test.stopTest();
        Assert.areEqual(true, result, 'Expected checkCountryOfNationalityOrResidence to return true');
    }
    
    @isTest
    static void testSendCustomNotification() {
        Test.startTest();
        ICS_CTRL_PingVerificationEmail.sendCustomNotification(new Set<String>{UserInfo.getUserId()}, [SELECT Id FROM Opportunity LIMIT 1].Id);
        Test.stopTest();
        Assert.areEqual(0, Limits.getEmailInvocations());

    }
}