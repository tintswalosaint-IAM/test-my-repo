/***************************************************************************************

@name of the Class : ICS_CTRL_DMLAdditionalBankAccounts_Test.cls
@description :	Test class used as controller for  SBO-UK onBoardingApplication additional bank Feature
@author : Ikyatha Naidu
@created Date : 04-06-2024
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: SFP-30128
*
***************************************************************************************/

@isTest
public class ICS_CTRL_DMLAdditionalBankAccounts_Test {
    
    @TestSetup
    static void setupTestData() {
        // Create test data
        user commUser =ICS_DAL_Testfactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
		 ICS_DAL_Testfactory.createPartyProfile( commUser.Contact.AccountId );
       
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Current Account BalanceCurrency',
            QuestionCategory = 'Financial'
        );
        insert question;

        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Current Account BalanceCurrency',
            Name = 'Current Account BalanceCurrency',
            IsActive = true
        );
        insert qv;
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(Name = 'ICS UK Financial Details', AO_ExternalId__c = 'test',AOB_Screen_Sequence__c=2);
        insert screen;
        
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            Name = 'Additional Bank Accounts',
            AOB_Screen__c = screen.Id,
            AOB_ExternalId__c = 'test_section'
        );
        insert section;
        
        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', Name = 'Bank Name', AOB_SFField__c = 'Bank_Name__c', AOB_Section__c = section.Id),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', Name = 'Account Number', AOB_SFField__c = 'Account_Number__c', AOB_Section__c = section.Id),
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', Name = 'Current Account Balance', AOB_SFField__c = 'Current_Account_Balance__c', AOB_Section__c = section.Id)
        };
        insert fields;
       
    }
    
    @isTest
    static void testCreatePartyAssetFunds() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testProfile = [SELECT Id FROM PartyProfile LIMIT 1];
        
        String jsonString = '{"Party_Assets_Funds__c":null,"Sub Accordian":[' +
            '{"Bank Name":"Test Bank","Account Number":"123456789","Current Account Balance":1000,' +
            '"Current Account BalanceCurrency":"USD"}]}';
        
        Test.startTest();
        ICS_CTRL_DMLAdditionalBankAccounts.createPartyAssetFunds(jsonString, testAccount.Id);
        Test.stopTest();
        
        List<Party_Assets_Funds__c> createdFunds = [SELECT Id, Bank_Name__c, Current_Account_Balance__c, Party_Profile__c FROM Party_Assets_Funds__c WHERE Party_Profile__c = :testProfile.Id];
        
        Assert.areEqual(1, createdFunds.size(), 'One Party_Assets_Funds__c record should be created');
        Assert.areEqual('Test Bank', createdFunds[0].Bank_Name__c, 'Bank Name should match');
        Assert.areNotEqual(null, createdFunds[0].Current_Account_Balance__c, 'Current Account Balance should not be null');
    }
    
    @isTest
    static void testGetFieldMappings() {
        Map<String, List<AOB_Field__c>> fieldMappings = ICS_CTRL_DMLAdditionalBankAccounts.getFieldMappings();
        
        Assert.isTrue(fieldMappings.containsKey('Party_Assets_Funds__c'), 'Field mappings should contain Party_Assets_Funds__c');
        Assert.areEqual(3, fieldMappings.get('Party_Assets_Funds__c').size(), 'There should be 3 field mappings for Party_Assets_Funds__c');
    }
    
    @isTest
    static void testMapFieldsToPartyAssetFund() {
        Map<String, List<AOB_Field__c>> fieldMappings = ICS_CTRL_DMLAdditionalBankAccounts.getFieldMappings();
        Map<String, Schema.SObjectField> sObjectFields = Schema.getGlobalDescribe().get('Party_Assets_Funds__c').getDescribe().fields.getMap();
        
        Map<String, Object> subRecord = new Map<String, Object>{
            'Bank Name' => 'Test Bank',
            'Account Number' => '123456789',
            'Current Account Balance' => 1000
        };
        
        Party_Assets_Funds__c mappedFund = ICS_CTRL_DMLAdditionalBankAccounts.mapFieldsToPartyAssetFund(subRecord, null, fieldMappings, sObjectFields);
        
        Assert.areEqual('Test Bank', mappedFund.Bank_Name__c, 'Bank Name should be mapped correctly');
        Assert.areEqual(1000, mappedFund.Current_Account_Balance__c, 'Current Account Balance should be mapped correctly');
    }
    
    @isTest
    static void testCastValueToFieldType() {
        // Test String casting
        Object stringValue = 'Test String';
        Object castedString = ICS_CTRL_DMLAdditionalBankAccounts.castValueToFieldType(stringValue, Schema.DisplayType.STRING);
        Assert.areEqual('Test String', castedString, 'String should be cast correctly');
        
        // Test Integer casting
        Object intValue = '123';
        Object castedInt = ICS_CTRL_DMLAdditionalBankAccounts.castValueToFieldType(intValue, Schema.DisplayType.INTEGER);
        Assert.areEqual(123, castedInt, 'Integer should be cast correctly');
        
        // Test Decimal casting
        Object decimalValue = '123.45';
        Object castedDecimal = ICS_CTRL_DMLAdditionalBankAccounts.castValueToFieldType(decimalValue, Schema.DisplayType.DOUBLE);
        Assert.areEqual(123.45, castedDecimal, 'Decimal should be cast correctly');
        
        // Test Boolean casting
        Object boolValue = 'true';
        Object castedBool = ICS_CTRL_DMLAdditionalBankAccounts.castValueToFieldType(boolValue, Schema.DisplayType.BOOLEAN);
        Assert.areEqual(true, castedBool, 'Boolean should be cast correctly');
        
        // Test Date casting
        Object dateValue = '2023-07-23';
        Object castedDate = ICS_CTRL_DMLAdditionalBankAccounts.castValueToFieldType(dateValue, Schema.DisplayType.DATE);
        Assert.areEqual(Date.newInstance(2023, 7, 23), castedDate, 'Date should be cast correctly');
    }

}