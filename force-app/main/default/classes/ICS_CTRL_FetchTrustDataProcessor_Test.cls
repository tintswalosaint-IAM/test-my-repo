@isTest
public class ICS_CTRL_FetchTrustDataProcessor_Test {
    private static Account testAccount;
    private static Assessment testAssessment;
    private static PartyProfile testPartyProfile;
    private static Party_Assets_Funds__c testTrust;
    private static AssessmentQuestionResponse testResponse;

    @TestSetup
    static void setupTestData() {
        // Create test account
        User communityUser = ICS_DAL_testfactory.createCommunityUser();
        
		communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
		testAccount =[select id from account where id=: communityUser.contact.accountid];
        PartyProfile profileData= ICS_DAL_testfactory.createPartyProfile(communityUser.contact.accountID);
        
        // Create test assessment
        // 
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'ID & Address Verification', CloseDate = System.today());
        opp.AccountId = communityUser.Contact.accountId;
        opp.LeadSource='IFA';
        insert opp;
        testAssessment = new Assessment(
            AccountId = testAccount.Id,
            Name = 'Test Assessment',
            AssessmentStatus = 'In Progress'
        );
        insert testAssessment;

        // Create test party profile
        testPartyProfile = new PartyProfile(
            Name = 'PEP',
            Has_Former_Name__c='Yes',
            Has_Maiden_Name__c='Yes',
            Has_different_First_Middle_Family_Name__c= 'Yes',
            Different_First_Name__c = 'test',
            Different_Middle_Name__c ='test',
            Different_Last_Name__c ='test',
            RecordTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId(),
            Person_Title__c = 'Mr.',
            Gender = 'Male',
            Town_City_of_Birth__c = 'Pune',
            Country_of_Residence__c = 'IN',
            Country_of_Nationality__c = 'IN',
            Second_Country_of_Nationality__c = 'US'
            
        );
        insert testPartyProfile;

        // Create test trust
        testTrust = new Party_Assets_Funds__c(
            Name = 'Test Trust',
            Type__c = 'Trust',
            Party_Profile__c = profileData.Id,
            Is_Trust_Beneficiary__c = true
        );
        insert testTrust;
        Party_Assets_Funds__c benifitTrust = new Party_Assets_Funds__c(
            Name = 'Test Trust',
            
            Party_Profile__c = profileData.Id,
            Is_Trust_Beneficiary__c = true,
            Type__c = 'Benefit from a trust',
            Trust__c = testTrust.id
        );
        insert benifitTrust;
        
		ICS_DAL_TestFactory.createPartyProfileWithoutRecordType(profileData.Id,testTrust.id);
        // Create test assessment question and response
        AssessmentQuestion testQuestion = new AssessmentQuestion(
            DataType = 'TextArea',
            DeveloperName = 'how_are_you',
            Name = 'Annual Monetary ValueCurrency',
            QuestionCategory = 'Financial'
        );
        insert testQuestion;

        AssessmentQuestionVersion testQuestionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = testQuestion.Id,
            QuestionText = 'Annual Monetary ValueCurrency',
            Name = 'Annual Monetary ValueCurrency'
        );
        insert testQuestionVersion;
		AssessmentQuestionResponse testBenifitCurrencyResponse = new AssessmentQuestionResponse(
            Name = 'Trusts:'+benifitTrust.id,
            AssessmentId = testAssessment.Id,
            AssessmentQuestionId = testQuestionVersion.Id,
            ResponseText = 'AED:500'
        );
        insert testBenifitCurrencyResponse;
        testResponse = new AssessmentQuestionResponse(
            Name = 'Trusts',
            AssessmentId = testAssessment.Id,
            AssessmentQuestionId = testQuestionVersion.Id,
            ResponseText = 'TRUE'
        );
        insert testResponse;

        // Create AOB fields
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK Financial Details',
            AOB_title__c = 'ICS UK Financial Details',
            AOB_subtitle__c = 'Enter the following information',
            AO_ExternalId__c = '1234',
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = 'EN'
        );
        insert screen;

        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screen.Id,
            Name = 'Trusts',
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = 'Trusts'
        );
        insert section;

        List<AOB_Field__c> fieldMappings = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', Name = 'Deed Number', AOB_SFField__c = 'Deed_Number__c', AOB_Section__c = section.Id),
            new AOB_Field__c(AOB_SFObject__c = 'PartyProfile', Name = 'Person Title', AOB_SFField__c = 'Person_Title__c', AOB_Section__c = section.Id),
                new AOB_Field__c(AOB_SFObject__c = 'Assessment',aob_type__c='Lookup', Name = 'Annual Monetary ValueCurrency', AOB_Section__c = section.Id)

                };
        insert fieldMappings;
    }

    @isTest
    static void testPrepareJsonForUI() {
         String jsonResponse='';
        Test.startTest();
        
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        system.runas(communityUser){
         jsonResponse = ICS_CTRL_FetchTrustDataProcessor.prepareJsonForUI(communityUser.Contact.AccountId);
        }
        Test.stopTest();

        Assert.isNotNull(jsonResponse, 'JSON response should not be null');
        
        List<Object> responseList = (List<Object>)JSON.deserializeUntyped(jsonResponse);
        Assert.areEqual(1, responseList.size(), 'Response should contain one object');
        
        Map<String, Object> responseMap = (Map<String, Object>)responseList[0];
        Assert.areEqual('Party_asset_Funds__c', responseMap.get('objectName'), 'Object name should be Party_asset_Funds__c');        
    }

    @isTest
    static void testCheckTrustStructure() {
        Test.startTest();
        User communityUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        AssessmentQuestionResponse result = ICS_CTRL_FetchTrustDataProcessor.checkTrustStructure(communityUser.Contact.AccountId);
        Test.stopTest();

        Assert.areEqual('TRUE', result.responseText, 'Trust structure check result should be TRUE');
    }

    @isTest
    static void testGetMaritalStatusMap() {
        Test.startTest();
        Map<String, String> maritalStatusMap = ICS_CTRL_FetchTrustDataProcessor.getMaritalStatusMap();
        Test.stopTest();

        Assert.areEqual(12, maritalStatusMap.size(), 'Marital status map should contain 12 entries');
        Assert.areEqual('SINGLE', maritalStatusMap.get('1'), 'Marital status for key 1 should be SINGLE');
        Assert.areEqual('MARRIED', maritalStatusMap.get('2'), 'Marital status for key 2 should be MARRIED');
        Assert.areEqual('1', maritalStatusMap.get('SINGLE'), 'Key for SINGLE should be 1');
        Assert.areEqual('2', maritalStatusMap.get('MARRIED'), 'Key for MARRIED should be 2');
    }
     
}