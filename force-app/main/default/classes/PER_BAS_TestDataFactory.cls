/**
 * @description       : Test Data Factor for PER Banker Assistant Data Provider
 * @author            : Sandile Mathe
 * @group             : PER: Personalisation
 * @Created on        : 13-05-2024
**/
@isTest
public class PER_BAS_TestDataFactory {
        public static  user insertTestUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            Alias = 'testuser',
            Email='testuser@test.test',
            EmailEncodingKey='UTF-8',
            LastName='Test User',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey='Europe/Berlin',
            Username='test.user.dev@stdb.chnwlsdev',
            RM_AE_Code__c = '0046385');
        insert testUser;
        return testUser;
    }
     public static Account createTestAccount() {
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account';
        testAccount.FirstName  = 'Standardbank';
        testAccount.ExternalCIFId__c = '100001';
        testAccount.RelationshipMgrCode__c = '0046383';
        testAccount.ExternalIdentifier__c = 'ZA01519079219';
        testAccount.RecordTypeId = getPersonAccountRecordTypeId();
        testAccount.PersonEmail = 'Test@standardbank.co.za';
        insert testAccount;
        return testAccount;
    }
    static Id getPersonAccountRecordTypeId() {
        // Query the RecordType for Person Account
        return [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Account' AND  DeveloperName = 'Person_Account_Contact' LIMIT 1].Id;
    }
    
    //This is Only To Tst the Snooze Methods, which are not support yet as of 13-05-2024
     public static sbgpers.RecommendedActionResult getActionResultInstance() {
        sbgpers.RecommendedActionResult actionResult = new sbgpers.RecommendedActionResult();
        actionResult.recordId = null;
        actionResult.identifier = 'ID00001';
        actionResult.response = 'Test Response';
        actionResult.reason = 'Test Reason';
        actionResult.notes = 'Test Notes';
        return actionResult;
    }

    public static sbgpers.RecommendedAction getRecommendedActionInstance() {
        sbgpers.RecommendedAction action = new sbgpers.RecommendedAction();
        action.accountId = null;
        action.accountName = 'Test Customer';
        action.category = 'Alert';
        action.subCategory = 'Fraud Alert';
        action.portfolioCode = '0046383';
        action.additionalData = 'Dear Sandile,\n\nI hope this email finds you well. As your private banker at Standard Bank, I would like to inform you that a fraud case has been created due to a suspicious transaction on your account. The case number is 2024-554966187, and it was created on 2024-03-12 16:04:39.306000 for an amount of R256.0.\n\nPlease know that we take fraud very seriously, and we are working on resolving the issue as soon as possible. I advise that you continue to engage with our fraud team, who can provide you with any necessary updates and assistance regarding the case.\n\nIf you have any questions or concerns, please do not hesitate to contact me. As always, I am here to help you and ensure that your banking experience with Standard Bank is smooth and secure.\n\nBest regards,\n\n[Your Name]\nPrivate Banker at Standard Bank';
        action.nextSteps = 'These are your next steps';
        action.validFrom= Date.today(); 
        action.validUntil = Date.today(); 
        return action;
    }
}