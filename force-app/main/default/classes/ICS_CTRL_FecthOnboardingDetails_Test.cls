/***************************************************************************************
@name of the Class : ICS_CTRL_FecthOnboardingDetails_Test.cls
@description : test class used as controller for  ICS_CTRL_FecthOnboardingDetails
@author : Ikyatha Naidu
@created Date : 05 May 2023
/***************************************************************************************
@last Modified By : Ikyatha Naidu
@last Modified On : 06-06-2024
@modification description: Updated to latest version
***************************************************************************************/
@isTest
public class ICS_CTRL_FecthOnboardingDetails_Test {
    @TestSetup
    static void setupTestData() {
        User commUser = createCommunityUser();
        Account account = new Account(Id = commUser.Contact.AccountId);
        PartyProfile profile = createPartyProfile(account.Id);
        Opportunity opp = createOpportunity(account.Id);
        ApplicationForm aForm = createApplicationForm(account.Id, opp.Id);
        
        createContactPoints(account.Id);
        createApplicant(account.Id, profile.Id, aForm.Id);
        createCustomMetadata();
        
        Assessment assessmentObj = createAssessment(account.Id, profile.Id);
        List<AssessmentQuestion> questions = createAssessmentQuestions();
        List<AssessmentQuestionVersion> questionVersions = createAssessmentQuestionVersions(questions);
        createAssessmentQuestionResponses(questionVersions, assessmentObj.Id);
        
        createScreensAndSections();
        createFields();
    }
    
    private static User createCommunityUser() {
       ICS_DAL_TestFactory.createCommunityUser();
        return [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
    }
    
    private static PartyProfile createPartyProfile(Id accountId) {
        return ICS_DAL_TestFactory.createPartyProfile(accountId);
    }
    
    private static Opportunity createOpportunity(Id accountId) {
        return ICS_DAL_TestFactory.createOpportunity(accountId);
    }
    
    private static ApplicationForm createApplicationForm(Id accountId, Id oppId) {
        return ICS_DAL_TestFactory.createApplicationForm(accountId, oppId);
    }
    
    private static void createContactPoints(Id accountId) {
        ICS_DAL_TestFactory.createPointPhone(accountId);
        ICS_DAL_TestFactory.createContactPointEmail(accountId);
    }
    
    private static void createApplicant(Id accountId, Id profileId, Id formId) {
        ICS_DAL_TestFactory.createApplicant(accountId, profileId, formId);
    }
    
    private static void createCustomMetadata() {
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = 'ics_customlabel__mdt.TestLabel';
        customMetadata.label = 'TestLabel';
        
        Metadata.CustomMetadataValue descField = new Metadata.CustomMetadataValue();
        descField.field = 'Description__c';
        descField.value = '{"ics_serverSentUrl": "https://example.com"}';
        customMetadata.values.add(descField);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
    }
    
    private static Assessment createAssessment(Id accountId, Id profileId) {
        Assessment assessmentObj = new Assessment(
            Name = 'Test Assessment',
            AccountId = accountId,
            PartyProfileId = profileId,
            AssessmentStatus = 'InProgress'
        );
        insert assessmentObj;
        return assessmentObj;
    }
    
    private static List<AssessmentQuestion> createAssessmentQuestions() {
        List<AssessmentQuestion> questions = new List<AssessmentQuestion>{
            new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you', Name = 'Select all assets and income*', QuestionCategory = 'Financial'),
                new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you2', Name = 'Select years*', QuestionCategory = 'Financial'),
                new AssessmentQuestion(DataType = 'TextArea', DeveloperName = 'how_are_you3', Name = 'Select all funds assets and income*', QuestionCategory = 'Financial'),
                new AssessmentQuestion(DataType = 'Checkbox', DeveloperName = 'how_are_you4', Name = 'Are you associated to any Shell Banks', QuestionCategory = 'Financial')
                };
                    insert questions;
        return questions;
    }
    
    private static List<AssessmentQuestionVersion> createAssessmentQuestionVersions(List<AssessmentQuestion> questions) {
        List<AssessmentQuestionVersion> versions = new List<AssessmentQuestionVersion>{
            new AssessmentQuestionVersion(AssessmentQuestionId = questions[0].Id, QuestionText = 'Select all assets and income*', Name = 'Assets and Income'),
                new AssessmentQuestionVersion(AssessmentQuestionId = questions[1].Id, QuestionText = 'Select years*', Name = 'Assets and Income'),
                new AssessmentQuestionVersion(AssessmentQuestionId = questions[2].Id, QuestionText = 'Select all funds assets and income*', Name = 'Assets and Income'),
                new AssessmentQuestionVersion(AssessmentQuestionId = questions[3].Id, QuestionText = 'Are you associated to any Shell Banks', Name = 'Account Purpose')
                };
                    insert versions;
        return versions;
    }
    
    private static void createAssessmentQuestionResponses(List<AssessmentQuestionVersion> versions, Id assessmentId) {
        List<AssessmentQuestionResponse> responses = new List<AssessmentQuestionResponse>{
            new AssessmentQuestionResponse(AssessmentQuestionId = versions[0].Id, AssessmentId = assessmentId, Name = 'Assets and Income', ResponseText = 'Compensation Payment'),
                new AssessmentQuestionResponse(AssessmentQuestionId = versions[1].Id, AssessmentId = assessmentId, Name = 'Assets and Income', ResponseText = '4'),
                new AssessmentQuestionResponse(AssessmentQuestionId = versions[2].Id, AssessmentId = assessmentId, Name = 'Assets and Income', ResponseText = 'Compensation Payment'),
                new AssessmentQuestionResponse(AssessmentQuestionId = versions[3].Id, AssessmentId = assessmentId, Name = 'Account Purpose', ResponseText = 'TRUE')
                };
                    insert responses;
    }
    
    private static void createScreensAndSections() {
        List<AOB_FlowScreen__c> screens = ICS_DAL_TestFactory.createScreen();
        List<AOB_ScreenSection__c> sections = ICS_DAL_TestFactory.createSection(screens[0].Id);
        ICS_DAL_TestFactory.createFields(sections[0].Id);
    }
    
    private static void createFields() {
        AOB_ScreenSection__c section = [SELECT Id FROM AOB_ScreenSection__c LIMIT 1];
        List<AOB_Field__c> fieldList = new List<AOB_Field__c>();
        
        // Create Text field
        fieldList.add(new AOB_Field__c(
            AOB_Section__c = section.Id,
            Name = 'Name',
            AOB_Type__c = 'Text',
            AOB_Label__c = 'Name',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Name'
        ));
        
        // Create Date field
        fieldList.add(new AOB_Field__c(
            AOB_Section__c = section.Id,
            Name = 'Date Received',
            AOB_Type__c = 'Date',
            AOB_Label__c = 'Date Received',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Date_Funds_Received__c'
        ));
        
        // Create Radio field
        fieldList.add(new AOB_Field__c(
            AOB_Section__c = section.Id,
            Name = 'Does this asset amount to more than 10% of your total wealth?',
            AOB_Type__c = 'Radio',
            AOB_Label__c = 'Does this asset amount to more than 10% of your total wealth?',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Is_amount_to_more_than_10__c'
        ));
        
        // Create Lookup field
        fieldList.add(new AOB_Field__c(
            AOB_Section__c = section.Id,
            Name = 'Party Profile',
            AOB_Type__c = 'Lookup',
            AOB_Label__c = 'Party Profile',
            AOB_SFObject__c = 'Party_Assets_Funds__c',
            AOB_SFField__c = 'Party_Profile__c;PartyProfile'
        ));
        
        // Create Checkbox field
        fieldList.add(new AOB_Field__c(
            AOB_Section__c = section.Id,
            Name = 'Same details as current employer',
            AOB_Type__c = 'Checkbox',
            Default_Value__c = '',
            AOB_Label__c = 'Same details as current employer',
            AOB_SFObject__c = 'Assessment',
            AOB_SFField__c = ''
        ));
        
        // Create additional fields
        List<AOB_Field__c> additionalFields = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, AOB_Type__c='Currency', Name = 'Annual Monetary Value', AOB_SFField__c = 'Annual_Monetary_Value__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, AOB_Type__c='Currency', Name = 'Annual Monetary Value', AOB_SFField__c = 'Annual_Monetary_Value__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Trust name', AOB_SFField__c = 'Trust_Name__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Identification number', AOB_SFField__c = 'Is_amount_to_more_than_10__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Trust name', AOB_SFField__c = 'Address_Line_1__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Client Cancelled', AOB_SFField__c = 'Beneficiary_Of_Trust__c'),
                new AOB_Field__c(AOB_SFObject__c = 'table:Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Date received?', AOB_SFField__c = 'table:Date_Funds_Matured__c'),
                new AOB_Field__c(AOB_SFObject__c = 'table:Party_Assets_Funds__c', AOB_Section__c = section.Id, Name = 'Country_of_Residence__c', AOB_SFField__c = 'table:Business_Location__c')
                };
                    
                    fieldList.addAll(additionalFields);
        
        if (!fieldList.isEmpty()) {
            insert fieldList; 
        }
    }
    
    @isTest
    static void testGetLandingPageJSON() {
        
        ics_customlabel__mdt metaData =[select id,developername from ics_customlabel__mdt limit 1];
        Test.startTest();
        
        ics_customlabel__mdt result = ICS_CTRL_FecthOnboardingDetails.getLandingPageJSON(metaData.developerName);
        Test.stopTest();
        Assert.isnotNull(result, 'Expected  result for existent custom label');
    }
    
    @isTest
    static void testQueryData() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Set<String> objectNameList = new Set<String>{'Account', 'ContactPointPhone', 'ContactPointEmail','PartyProfileAddress','IdentityDocument','Applicant','FinServ__Employment__c','Party_Assets_Funds__c'};
            
            Test.startTest();
        List<SObject> result = ICS_CTRL_FecthOnboardingDetails.queryData(commUser.Contact.AccountId, objectNameList, 'Current Residential Address');
        ICS_CTRL_FecthOnboardingDetails.queryData(commUser.Contact.AccountId, objectNameList, 'Previous Residential Address');
        
        ICS_CTRL_FecthOnboardingDetails.queryData(commUser.Contact.AccountId, objectNameList, 'Selected Account');
        ICS_CTRL_FecthOnboardingDetails.queryData(commUser.Contact.AccountId, objectNameList, 'Correspondence Address');
        ICS_CTRL_FecthOnboardingDetails.queryData(commUser.Contact.AccountId, objectNameList, 'Business Ownership');
        
        
        Test.stopTest();
        
        Assert.isTrue(result.size() > 0, 'Expected queried data');
    }
    
    @isTest
    static void testFetchAobFields() {
        AOB_FlowScreen__c screen = [SELECT Id, Name FROM AOB_FlowScreen__c LIMIT 1];
        AOB_ScreenSection__c section = [SELECT Id, Name FROM AOB_ScreenSection__c WHERE AOB_Screen__c = :screen.Id LIMIT 1];
        
        Test.startTest();
        List<AOB_Field__c> result = ICS_CTRL_FecthOnboardingDetails.fetchAobFields(screen.Name, section.Name);
        Test.stopTest();
        
        Assert.isTrue(result.size() > 0, 'Expected AOB fields');
    }
    
    @isTest
    static void testFetchDynamicData() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        AOB_FlowScreen__c screen = [SELECT Id, Name FROM AOB_FlowScreen__c LIMIT 1];
        AOB_ScreenSection__c section = [SELECT Id, Name FROM AOB_ScreenSection__c WHERE AOB_Screen__c = :screen.Id LIMIT 1];
        
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetails.fetchDynamicData(commUser.Contact.AccountId, screen.Name, section.Name, 'TableData');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected JSON string result');
    }
    @isTest
    static void testFetchQuestionResponseDataWithAccountId() { 
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        AOB_FlowScreen__c screen = [SELECT Id, Name FROM AOB_FlowScreen__c LIMIT 1];
        AOB_ScreenSection__c section = [SELECT Id, Name FROM AOB_ScreenSection__c WHERE AOB_Screen__c = :screen.Id LIMIT 1];
        
        Test.startTest();
        List<AssessmentQuestionResponse> result = ICS_CTRL_FecthOnboardingDetails.fetchQuetsionReposneDataWithAccountId(commUser.Contact.AccountId, section.Name);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected JSON string result');
    }
    @isTest
    static void testQueryDataObject() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        set<string> objNames = new set<string>{'Account','ContactPointPhone','ContactPointEmail','PartyProfile','PartyProfileAddress','IdentityDocument','Applicant'};
            
            Test.startTest();
        Map<string,string> result = ICS_CTRL_FecthOnboardingDetails.queryDataWithObject(commUser.Contact.AccountId, objNames,'Current Residential Address');
        Assert.isnotnull(result, 'Expected Map values');
        Test.stopTest();
        
    }
    
    @isTest
    static void testCheckIsJoint() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        String result = ICS_CTRL_FecthOnboardingDetails.checkisJoint(commUser.Contact.AccountId);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected JSON string result');
    }
    
    @isTest
    static void testFetchQuestionResponseData() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        Test.startTest();
        Map<String, AssessmentQuestionResponse> result = ICS_CTRL_FecthOnboardingDetails.fetchQuetsionReposneData(commUser.Contact.AccountId, 'Test Section');
        Test.stopTest();
        
        Assert.isNotNull(result, 'Expected map of assessment question responses');
    }
    
    @isTest
    static void testQueryPartyAssetsFunds() {
       User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       PartyProfile profile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
       
       Map<String, List<SObject>> dataMap = new Map<String, List<SObject>>();
       Set<String> objectNames = new Set<String>{'Party_Assets_Funds__c', 'PartyProfile'};
       
       Test.startTest();
       
       // Test Business Ownership
       ICS_CTRL_FecthOnboardingDetails.queryPartyAssetsFunds(
           profile, 'Business Ownership', objectNames, dataMap
       );
       Assert.isTrue(dataMap.containsKey('Party_Assets_Funds__c'));
       
       // Test Other Business Interests
       dataMap.clear();
       ICS_CTRL_FecthOnboardingDetails.queryPartyAssetsFunds(
           profile, 'Other Business Interests', objectNames, dataMap
       );
       Assert.isTrue(dataMap.containsKey('OtherBusinessInterests'));
       
       // Test Initial Deposit
       dataMap.clear(); 
       ICS_CTRL_FecthOnboardingDetails.queryPartyAssetsFunds(
           profile, 'Initial Deposit', objectNames, dataMap
       );
       Assert.isTrue(dataMap.containsKey('InitialDeposit'));
       
       // Test Bank Details
       dataMap.clear();
       ICS_CTRL_FecthOnboardingDetails.queryPartyAssetsFunds(
           profile, 'Bank Details', objectNames, dataMap
       );
       Assert.isTrue(dataMap.containsKey('BankDetails'));
       
       // Test Additional Bank Accounts
       dataMap.clear();
       ICS_CTRL_FecthOnboardingDetails.queryPartyAssetsFunds(
           profile, 'Additional Bank Accounts', objectNames, dataMap
       );
       Assert.isTrue(dataMap.containsKey('AdditionalBankAccounts'));
       
       Test.stopTest();
    }
     @isTest
    static void testAddPreviousEmploymentDetails() {
        Map<String, String> questionWithScreenNameSet = new Map<String, String>();
       	Test.startTest();
        	ICS_CTRL_FecthOnboardingDetails.addPreviousEmploymentDetails(questionWithScreenNameSet);
        Test.stopTest();
        Assert.areEqual(2, questionWithScreenNameSet.size(), 'The map should contain 2 entries.');
        Assert.areEqual(
            'Bonuses/Commissions received per annumCurrency',
            questionWithScreenNameSet.get('Bonuses/Commissions received per annumCurrency'),
            'The map should contain the correct value for Bonuses/Commissions received per annumCurrency.'
        );
        Assert.areEqual(
            'Gross Annual SalaryCurrency',
            questionWithScreenNameSet.get('Gross Annual SalaryCurrency'),
            'The map should contain the correct value for Gross Annual SalaryCurrency.'
        );
    }
    
  @isTest
    static void testCheckDateDifference() {
       Test.startTest();
       
       Date startDate1 = Date.newInstance(2020, 1, 1);
       String result1 = ICS_CTRL_FecthOnboardingDetails.checkDateDifference(startDate1, null);
       Assert.isTrue(result1.contains('Years and'), 'Should return year/month difference with today');
       
       // Test with specific dates
       Date startDate2 = Date.newInstance(2020, 1, 1);
       Date endDate2 = Date.newInstance(2022, 3, 1);
       String result2 = ICS_CTRL_FecthOnboardingDetails.checkDateDifference(startDate2, endDate2);
       Assert.areEqual('2 Years and 2 Months', result2, 'Should return correct difference');
       
       // Test with null start date
       String result3 = ICS_CTRL_FecthOnboardingDetails.checkDateDifference(null, Date.today());
       Assert.areEqual('', result3, 'Should return empty string for null start date');
       
       Test.stopTest();
    }
}