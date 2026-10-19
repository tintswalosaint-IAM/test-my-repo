/***************************************************************************************
@name of the Class : ICS_CTRL_FecthOnboardingDetailsAI_Test.cls
@description : test class used as controller for  ICS_CTRL_FecthOnboardingDetailsAI
@author : Ikyatha Naidu
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
@isTest
public class ICS_CTRL_FecthOnboardingDetailsAI_Test {
    private static Account testAccount;
    private static PartyProfile testProfile;
    private static PartyProfile testProfileOwnership;
    @testSetup
    static void setupTestData() {
         createAccounts();
        createPartyProfile();
        createPartyAssetsFunds();
        createAssessments();
        createPartyProfileOwnership();
        createAssessmentQuestionHierarchy();
        createAOBScreenAndFields();
    }
    private static void createAccounts() {
        testAccount = new Account(Name = 'Test Account');
        Account bulkAccount = new Account(Name = 'ulk REC');
        insert new List<Account>{testAccount, bulkAccount};
    }
    
    private static void createPartyProfile() {
        Id partyProfileRecordTypeId = Schema.getGlobalDescribe()
            .get('PartyProfile')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('ICS Party Profile')
            .getRecordTypeId();
            
        testProfile = new PartyProfile(
            AccountId = testAccount.Id,
            RecordTypeId = partyProfileRecordTypeId,
            Name = 'Test Profile'
        );
        insert testProfile;
    }

    private static void createPartyProfileOwnership() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile WHERE AccountId =: acc.id]; 
        Party_Assets_Funds__c testPartyAssets = [select id from Party_Assets_Funds__c where 
        type__c='Ownership/shares in business' and  Party_Profile__c =: testPartyProfile.id and Is_Future_Fund__c=false and recordtype.name='Source of Funds'  order by Createddate asc limit 1]; 
        Id partyProfileRecordTypeId = Schema.getGlobalDescribe()
            .get('PartyProfile')
            .getDescribe()
            .getRecordTypeInfosByName()
            .get('ICS Additional Business Owner')
            .getRecordTypeId();
            
        testProfileOwnership = new PartyProfile(
            RecordTypeId = partyProfileRecordTypeId,
            Party_Assets_Funds__c=testPartyAssets.id,
            Name = 'Test Profile'
        );
        insert testProfileOwnership;
    }
    
    private static void createPartyAssetsFunds() {
        Id sourceFundsRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c
            .getRecordTypeInfosByName()
            .get('Source of Funds')
            .getRecordTypeId();
            
        Id wealthCountryRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c
            .getRecordTypeInfosByName()
            .get('Wealth in Country')
            .getRecordTypeId();
            
        List<Party_Assets_Funds__c> partyAssetsFundsList = new List<Party_Assets_Funds__c>{
            createPartyAssetsFund(sourceFundsRecordTypeId, true, 'Compensation Payment'),
            createPartyAssetsFund(wealthCountryRecordTypeId, true, 'Compensation Payment'),
            createPartyAssetsFund(sourceFundsRecordTypeId, true, 'Investment/Stock'),
            createPartyAssetsFund(sourceFundsRecordTypeId, false, 'Gift'),
            createPartyAssetsFund(sourceFundsRecordTypeId, false, 'Ownership/shares in business'),
            createPartyAssetsFund(sourceFundsRecordTypeId, true, 'Bank Account')
        };
        insert partyAssetsFundsList;
    }
    
    private static Party_Assets_Funds__c createPartyAssetsFund(Id recordTypeId, Boolean isFutureFund, String type) {
        return new Party_Assets_Funds__c(
            Party_Profile__c = testProfile.Id,
            RecordTypeId = recordTypeId,
            Is_Future_Fund__c = isFutureFund,
            Type__c = type
        );
    }
    
    private static void createAssessments() {
        List<Assessment> assessments = new List<Assessment>{
            new Assessment(AccountId = testAccount.Id, Name = 'Test Assessment', AssessmentStatus = 'In Progress'),
            new Assessment(AccountId = testAccount.Id, Name = 'Test Assessment BULK', AssessmentStatus = 'In Progress')
        };
        insert assessments;
    }
    
    private static void createAssessmentQuestionHierarchy() {
        // Create Questions
        List<AssessmentQuestion> questions = createAssessmentQuestions();
        insert questions;
        
        // Create Question Versions
        List<AssessmentQuestionVersion> versions = createQuestionVersions(questions);
        insert versions;
        
        // Create Question Responses
        List<Assessment> assessments = [SELECT Id FROM Assessment WHERE AccountId = :testAccount.Id];
        List<AssessmentQuestionResponse> responses = createQuestionResponses(versions, assessments);
        insert responses;
    }
    
    private static List<AssessmentQuestion> createAssessmentQuestions() {
        return new List<AssessmentQuestion>{
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you', Name = 'Select all assets and income*', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you2', Name = 'Select years*', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you3', Name = 'Select all funds assets and income*', QuestionCategory = 'Financial'),
            new AssessmentQuestion(DataType = 'Checkbox', DeveloperName = 'how_are_you4', Name = 'Are you associated to any Shell Banks', QuestionCategory = 'Financial')
        };
    }
    
    private static List<AssessmentQuestionVersion> createQuestionVersions(List<AssessmentQuestion> questions) {
        return new List<AssessmentQuestionVersion>{
            new AssessmentQuestionVersion(AssessmentQuestionId = questions[0].Id, QuestionText = 'Select all assets and income*', Name = 'Assets and Income'),
            new AssessmentQuestionVersion(AssessmentQuestionId = questions[1].Id, QuestionText = 'Select years*', Name = 'Assets and Income'),
            new AssessmentQuestionVersion(AssessmentQuestionId = questions[2].Id, QuestionText = 'Select all funds assets and income*', Name = 'Assets and Income'),
            new AssessmentQuestionVersion(AssessmentQuestionId = questions[3].Id, QuestionText = 'Are you associated to any Shell Banks', Name = 'Account Purpose')
        };
    }
    
    private static List<AssessmentQuestionResponse> createQuestionResponses(List<AssessmentQuestionVersion> versions, List<Assessment> assessments) {
        return new List<AssessmentQuestionResponse>{
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[0].Id, AssessmentId = assessments[0].Id, Name = 'Assets and Income', ResponseText = 'Compensation Payment'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[1].Id, AssessmentId = assessments[0].Id, Name = 'Assets and Income', ResponseText = '4'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[2].Id, AssessmentId = assessments[0].Id, Name = 'Assets and Income', ResponseText = 'Compensation Payment'),
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[3].Id, AssessmentId = assessments[1].Id, Name = 'Account Purpose', ResponseText = 'TRUE')
        };
    }
    
    private static void createAOBScreenAndFields() {
        // Create Screen
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK Financial Details',
            AOB_title__c = 'ICS UK Financial Details',
            AOB_subtitle__c = 'Enter the following information',
            AO_ExternalId__c = '1234',
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = 'EN'
        );
        insert screen;
        
        // Create Section
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screen.Id,
            Name = 'Assets and Income',
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = 'Assets and Income'
        );
        insert section;
        
        // Create Fields
        List<AOB_Field__c> fields = createAOBFields(section.Id);
        insert fields;
    }
    
    private static List<AOB_Field__c> createAOBFields(Id sectionId) {
        List<AOB_Field__c> fields = new List<AOB_Field__c>();
       AOB_Field__c parentField =  new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Gift',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'Gift',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Name'
        );
        insert parentField;
        fields.add(new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Name',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'Name',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Name',
            AOB_Parent__c = parentField.id
        ));
        
        fields.add(new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Date Received',
            AOB_Type__c = 'Date',
            AOB_Label__c = 'Date Received',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Date_Funds_Received__c',
            AOB_Parent__c = parentField.id
        ));
        
        fields.add(new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Does this asset amount to more than 10% of your total wealth?',
            AOB_Type__c = 'Radio',
            AOB_Label__c = 'Does this asset amount to more than 10% of your total wealth?',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Is_amount_to_more_than_10__c',
            AOB_Parent__c = parentField.id
        ));
        
        fields.add(new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Party Profile',
            AOB_Type__c = 'Lookup',
            AOB_Label__c = 'Party Profile',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Party_Profile__c;PartyProfile',
            AOB_Parent__c = parentField.id
        ));
        
        fields.add(new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = 'Same details as current employer',
            AOB_Type__c = 'Checkbox',
            Default_Value__c = '',
            AOB_Label__c = 'Same details as current employer',
            AOB_SFObject__c = 'Assessment',
            AOB_SFField__c = '',
            AOB_Parent__c = parentField.id
        ));
        
        return fields;
    }
    @isTest
    static void testFetchDynamicData() {
        String sectionName = 'Assets and Income';
        String screenName = 'ICS UK Financial Details';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> typeList = new List<String>{'Compensation Payment'};
            test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsAI.fetchDynamicData(acc.Id, screenName, sectionName, typeList);
        Test.stopTest();
        Assert.areNotEqual('', result, 'The result should not be an empty string.');
    }
     @isTest
    static void testFetchDynamicTypeListNullData() {
        String sectionName = 'Assets and Income';
        String screenName = 'ICS UK Financial Details';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> typeList ;
            test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsAI.fetchDynamicData(acc.Id, screenName, sectionName, typeList);
                    
        AOB_Field__c fieldInfo = [select id,AOB_SFObject__c,Name,AOB_SFField__c,AOB_Section__c,AOB_Parent__c,AOB_Type__c,Default_Value__c,AOB_Label__c from  AOB_Field__c limit 1];
        ICS_CTRL_FecthOnboardingDetailsAI.isValidField(fieldInfo);
        
        Test.stopTest();
        Assert.areNotEqual('', result, 'The result should not be an empty string.');
    }
    
  
     @isTest
    static void testFetchDynamicDataSingleType() {
        String sectionName = 'Assets and Income';
        String screenName = 'ICS UK Financial Details';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> typeList = new List<String>{'Compensation Payment'};
            test.startTest();
 		String result = ICS_CTRL_FecthOnboardingDetailsAI.fetchDynamicData(acc.Id, screenName, sectionName, typeList);
		Test.stopTest();
        Assert.areNotEqual(null,result,'should be null');
    }


    @isTest
    static void testQueryData() {
       
		Account acc = [SELECT Id from Account LIMIT 1];
        Set<String> objectNameList = new Set<String>{'Party_Assets_Funds__c'};
        String sectionName = 'Funds';
        List<String> typeList = new List<String>{'Compensation Payment'};  
            Test.startTest();
        List<sObject> result = ICS_CTRL_FecthOnboardingDetailsAI.queryData(acc.Id, objectNameList, sectionName, typeList);
        Assert.areEqual(true, result != null, ' Expected result Info');
		Test.stopTest();        
      
    }
    
    @isTest
    static void testQueryAssessments() {
       
        String sectionName = 'Assets and Income';
        String screenName = 'ICS UK Financial Details';
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsAI.fetchAssestListedFunds(acc.Id, screenName, sectionName);     
        Test.StopTest();
        Assert.areNotEqual(null,result,'should be null');
    }
    
    @isTest
    static void testQueryAssessments2() {       
        String sectionName = 'Assets and Income';
        String screenName = 'ICS UK Financial Details';
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetailsAI.fetchAssestListedFunds(acc.Id, screenName, sectionName);
        Test.stopTest();
        Assert.areNotEqual(null,result,'should be null');
    }
     @isTest
    static void testFetchAdditionalBussinessOwners() { 
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id, AccountId, Account.Name FROM PartyProfile WHERE AccountId =: acc.id]; 
        Party_Assets_Funds__c testPartyAssets = [SELECT Id FROM Party_Assets_Funds__c WHERE Party_Profile__c =: testPartyProfile.id  LIMIT 1]; 
        Test.startTest();
        String resultJson  = ICS_CTRL_FecthOnboardingDetailsAI.fetchAdditionalBussinessOwners(testPartyAssets.Id);
        Test.stopTest();
        Assert.areNotEqual(null,resultJson,'should be null');
    }
    
      @isTest
    static void testBasicProfileInformation() {
        PartyProfile profile = new PartyProfile(
            FirstName = 'John',
            MiddleName = 'Robert',
            LastName = 'Doe',
            Person_Title__c = 'Mr.',
            Birthdate__c = Date.newInstance(1990, 5, 15),
            Gender = 'Male'
        );
        String assetId = 'TEST123';
        
        Map<String, Object> result = ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, assetId);
        
         Assert.areEqual('John', result.get('First Name'));
         Assert.areEqual('Robert', result.get('Middle Name'));
         Assert.areEqual('Doe', result.get('Surname'));
         Assert.areEqual('Mr.', result.get('Title'));
         Assert.areEqual('1990-05-15', result.get('Date of birth'));
         Assert.areEqual('Male', result.get('Gender'));
         Assert.areEqual('TEST123', result.get('PartyProfileId'));
    }
    
    @isTest
    static void testLocationInformation() {
        PartyProfile profile = new PartyProfile(
            Town_City_of_Birth__c = 'London',
            CountryofBirth = 'United Kingdom',
            Country_of_Nationality__c = 'British',
            Second_Country_of_Nationality__c = 'French'
        );
        
        Map<String, Object> result = ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, 'TEST123');
        
         Assert.areEqual('London', result.get('Town/City of Birth'));
         Assert.areEqual('United Kingdom', result.get('Country of Birth'));
         Assert.areEqual('British', result.get('Primary Country of Nationality'));
         Assert.areEqual('French', result.get('Secondary Country of Nationality'));
    }
    
    @isTest
    static void testMaritalStatus() {
        PartyProfile profile = new PartyProfile(
            WI_MaritialStatus__c = 'Married'  
        );
        
        Map<String, Object> result = ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, 'TEST123');
      
         Assert.areNOTEqual('null', result.get('Marital Status'));
    }
    

    
    @isTest
    static void testOtherNames() {
        PartyProfile profile = new PartyProfile(
            Has_different_First_Middle_Family_Name__c = 'Yes',
            Different_First_Name__c = 'Johnny',
            Different_Middle_Name__c = 'Bob',
            Different_Last_Name__c = 'Smith'
        );
        
        ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, 'TEST123');
        
    }
    
    @isTest
    static void testBusinessInformation() {
        PartyProfile profile = new PartyProfile(
            Percentage_of_Business__c = 25.5
        );
        Map<String, Object> result =ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, 'TEST123');
         Assert.areEqual(25.5, result.get('Percentage of the business owned'));
    }
    
    @isTest
    static void testNullValues() {
        PartyProfile profile = new PartyProfile();
        Map<String, Object> result = ICS_CTRL_FecthOnboardingDetailsAI.generateOwnershipJson(profile, 'TEST123');
         Assert.areEqual(null, result.get('Date of birth'));
         Assert.areEqual(null, result.get('Marital Status'));
         Assert.areEqual(null, result.get('Percentage of the business owned'));
    }
    
  
    
        
    }