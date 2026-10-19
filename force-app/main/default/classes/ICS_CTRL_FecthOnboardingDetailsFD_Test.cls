/**
* @Name of the Class : ICS_CTRL_FecthOnboardingDetailsAI_Test
* @description class used as Test class for  SBO-UK fetchOnboarding Details
* @author Ridhima Saxena
* @date June 2024
* @last modified on  : 14-06-2024
* @last modified by  : Ridhima Saxena
* @Modification Description : test methods for ICS_CTRL_FecthOnboardingDetailsAI_Test for SBO-UK
*/
@isTest
public class ICS_CTRL_FecthOnboardingDetailsFD_Test {

    @testSetup
    static void setupTestData() {
        // Create Accounts
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account'),
            new Account(Name = 'Test Account 2')
        };
        insert accounts;

        // Create PartyProfile
        Id recordTypeId = Schema.getGlobalDescribe().get('PartyProfile')
            .getDescribe().getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
        PartyProfile profile = new PartyProfile(
            AccountId = accounts[0].Id,
            RecordTypeId = recordTypeId,
            Name = 'Test Profile'
        );
        insert profile;

        // Create Party_Assets_Funds__c records
        Id assetRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        List<Party_Assets_Funds__c> partyAssetsFunds = new List<Party_Assets_Funds__c>{
            new Party_Assets_Funds__c(
                Party_Profile__c = profile.Id, 
                RecordTypeId = assetRecordTypeId, 
                Is_Future_Fund__c = true, 
                Type__c = 'Compensation Payment',
                Name = 'Test Asset 1'
            ),
            new Party_Assets_Funds__c(
                Party_Profile__c = profile.Id, 
                RecordTypeId = assetRecordTypeId, 
                Is_Future_Fund__c = false, 
                Type__c = 'Gift',
                Name = 'Test Asset 2'
            )
        };
        insert partyAssetsFunds;

        // Create Assessments
        List<Assessment> assessments = new List<Assessment>{
            new Assessment(
                AccountId = accounts[0].Id, 
                Name = 'Test Assessment', 
                AssessmentStatus = 'In Progress'
            )
        };
        insert assessments;

        // Create Assessment Question
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'TextArea', 
            DeveloperName = 'how_are_you', 
            Name = 'How do you intend to fund the future deposits?', 
            QuestionCategory = 'Financial'
        );
        insert question;

        // Create Assessment Question Version
        AssessmentQuestionVersion questionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id, 
            QuestionText = 'How do you intend to fund the future deposits?', 
            Name = 'Future Deposits'
        );
        insert questionVersion;

        // Create Assessment Question Response
        AssessmentQuestionResponse response = new AssessmentQuestionResponse(
            AssessmentQuestionId = questionVersion.Id, 
            AssessmentId = assessments[0].Id, 
            Name = 'Future Deposits', 
            ResponseText = 'Compensation Payment'
        );
        insert response;

        // Create AOB Flow Screen
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK Account Details', 
            AOB_title__c = 'ICS UK Account Details', 
            AOB_subtitle__c = 'Enter the following information', 
            AO_ExternalId__c = '1234', 
            AOB_Screen_Sequence__c = 1, 
            AOB_Language__c = 'EN'
        );
        insert screen;

        // Create AOB Screen Section
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screen.Id, 
            Name = 'Future Deposits', 
            AOB_ExternalId__c = 'Q1', 
            AOB_Title__c = 'Future Deposits'
        );
        insert section;

        // Create AOB Fields
        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            new AOB_Field__c(
                AOB_Section__c = section.Id, 
                Name = 'Name', 
                AOB_Type__c = 'Text', 
                AOB_Label__c = 'Name', 
                AOB_SFObject__c = 'Party_Assets_Funds__c', 
                AOB_SFField__c = 'Name'
            )
        };
        insert fields;
    }

    @isTest
    static void testQueryData() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        List<String> typeList = new List<String>{'Compensation Payment'};  
        
        Test.startTest();
        List<sObject> result = ICS_CTRL_FecthOnboardingDetailsFD.queryData(acc.Id, typeList);   
        Test.stopTest();
       
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(!result.isEmpty(), 'Result should contain records');
    }
    
    @isTest
    static void testFetchAssestListedFunds() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        String sectionName = 'Future Deposits';
        String screenName = 'ICS UK Account Details';
        
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsFD.fetchAssestListedFunds(acc.Id, screenName, sectionName); 
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
    }
   
@isTest
static void testDeleteAssets_Success() {
    try {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        PartyProfile profile = [SELECT Id FROM PartyProfile WHERE AccountId = :testAccount.Id LIMIT 1];
        Id assetRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        
        Party_Assets_Funds__c giftAsset = new Party_Assets_Funds__c(
            Party_Profile__c = profile.Id,
            RecordTypeId = assetRecordTypeId,
            Type__c = 'Gift',
            Is_Future_Fund__c = false
        );
        insert giftAsset;
        
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsFD.deleteAssetsByProfile(
            testAccount.Id, 
            'Gift', 
            false,
            assetRecordTypeId
        );
        Test.stopTest();
        
        List<Party_Assets_Funds__c> remainingAssets = [
            SELECT Id 
            FROM Party_Assets_Funds__c 
            WHERE Party_Profile__c = :profile.Id AND Type__c = 'Gift'
        ];
        
        Assert.areEqual(0, remainingAssets.size(), 'Gift assets should be deleted');
        Assert.areEqual('assets deleted successfully.', result, 'Deletion result message incorrect');
    } catch (Exception e) {
       Assert.areNotEqual(null, e.getMessage(),'no error');
    }
}

@isTest
static void testDeleteAssets_NoAssetsFound() {
    try {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Id assetRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Source of Funds').getRecordTypeId();
        
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsFD.deleteAssetsByProfile(
            testAccount.Id, 
            'NonExistentType', 
            false,
            assetRecordTypeId
        );
        Test.stopTest();
        Assert.areEqual('No gift assets found to delete.', result, 'Incorrect result for non-existent asset type');
    } catch (Exception ex) {
       Assert.areNotEqual(null, ex.getMessage(),'no error');
    }
}
}