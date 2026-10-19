/***************************************************************************************
* @name of the Class : ICS_CTRL_DML_OnboardingAI_Test.cls
* @description class used as test class for ICS_CTRL_DML_OnboardingAI 
* @Story:SFP-30236
* @author Ikyatha Naidu
* @date 11-06-2024
/***************************************************************************************
* @last modified on  : 06-07-2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : updated to latest version
***************************************************************************************/
@istest
public class ICS_CTRL_DML_OnboardingAI_Test {
    @testSetup
    static void setupTestData() {
        AOB_FlowScreen__c screen = createFlowScreen();
        AOB_ScreenSection__c section = createScreenSection(screen.Id);
        
        AOB_Field__c parentField = createParentField(section.Id, 'GiftW');
        createParentField(section.Id, 'GiftV');
        
        createFieldMappings(section.Id, parentField.Id);
        createFundFieldMappings(section.Id, parentField.Id);
        createAssessmentFieldMappings(section.Id);
        
        AssessmentQuestion question = createAssessmentQuestion('Select all assets and income*', 'ssds');
        AssessmentQuestion questionFund = createAssessmentQuestion('Select all funds assets and income*', 'sddsds');
        
        createAssessmentQuestionVersion(question.Id, 'Select all assets and income*');
        AssessmentQuestionVersion versionId = createAssessmentQuestionVersion(questionFund.Id, 'Select all funds assets and income*');
        
        User commUser = createCommunityUser();
        PartyProfile testPartyProfile = createPartyProfile(commUser.Contact.AccountId);
        createPartyAssetFunds(testPartyProfile.Id);
        
        Assessment assessment = createAssessment(commUser.Contact.AccountId, testPartyProfile.Id);
        createAssessmentQuestionResponse(assessment.Id, versionId.Id);
    }
    
    private static AOB_FlowScreen__c createFlowScreen() {
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK Financial Details',
            AOB_title__c = 'ICS UK Financial Details',
            AOB_subtitle__c = 'Enter the following information',
            AO_ExternalId__c = '1234',
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = 'EN'
        );
        insert screen;
        return screen;
    }
    
    private static AOB_ScreenSection__c createScreenSection(Id screenId) {
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screenId,
            Name = 'Assets and Income',
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = 'Assets and Income'
        );
        insert section;
        return section;
    }
    
    private static AOB_Field__c createParentField(Id sectionId, String name) {
        AOB_Field__c parentField = new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = name,
            AOB_Type__c = 'Text',
            AOB_Label__c = name,
            AOB_ParentControllingValue__c = name
        );
        insert parentField;
        return parentField;
    }
    
    private static void createFieldMappings(Id sectionId, Id parentFieldId) {
        List<AOB_Field__c> fieldMappings = new List<AOB_Field__c>{
            	new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = sectionId, AOB_Type__c='Currency', Name = 'Annual Monetary Value', AOB_SFField__c = 'Annual_Monetary_Value__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = sectionId, Name = 'Trust name', AOB_SFField__c = 'Trust_Name__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Identification number', AOB_Section__c = sectionId, AOB_SFField__c = 'Is_amount_to_more_than_10__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Trust name', AOB_Section__c = sectionId, AOB_SFField__c = 'Address_Line_1__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Client Cancelled', AOB_Section__c = sectionId, AOB_SFField__c = 'Beneficiary_Of_Trust__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Date received?', AOB_Section__c = sectionId, AOB_SFField__c = 'Date_Funds_Matured__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Country_of_Residence__c', AOB_Section__c = sectionId, AOB_SFField__c = 'Business_Location__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Different_Last_Name__c', AOB_Type__c='Lookup', Default_Value__c='IN', AOB_Section__c = sectionId, AOB_SFField__c = 'Business_Name__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Different_Last_Name__c', AOB_Type__c='Lookup', AOB_Section__c = sectionId, AOB_SFField__c = 'Party_Profile__c;PartyProfile'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Different_Last_Name__c', AOB_Type__c= ICS_Constants.MasterDetail, AOB_Section__c = sectionId, AOB_SFField__c = 'Party_Profile__c;PartyProfile'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'RecordtypeID', AOB_Type__c='Lookup', Default_Value__c='Source of Funds', AOB_Section__c = sectionId, AOB_SFField__c = 'RecordtypeId')
                };
                    insert fieldMappings;
    }
    
    private static void createFundFieldMappings(Id sectionId, Id parentFieldId) {
        List<AOB_Field__c> fieldFundMappings = new List<AOB_Field__c> {
            new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = sectionId, Name = 'Deed numberV', AOB_SFField__c = 'Deed_Number__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Section__c = sectionId, Name = 'Trust nameV', AOB_SFField__c = 'Trust_Name__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Identification numberV', AOB_Section__c = sectionId, AOB_SFField__c = 'Identification_Number__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'First nameV', AOB_Section__c = sectionId, AOB_SFField__c = 'FirstName'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Client CancelledV', AOB_Section__c = sectionId, AOB_SFField__c = 'ClientCancelled__c'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'BirthdateV', AOB_Section__c = sectionId, AOB_SFField__c = 'DateOfBirth'),
                new AOB_Field__c(AOB_SFObject__c = 'Party_Assets_Funds__c', AOB_Parent__c = parentFieldId, Name = 'Country_of_Residence__cV', AOB_Section__c = sectionId, AOB_SFField__c = 'Country_of_Residence__c')
                };
                    insert fieldFundMappings;
    }
    
    private static void createAssessmentFieldMappings(Id sectionId) {
        List<AOB_Field__c> fieldMappingsAsse = new List<AOB_Field__c>{
            new AOB_Field__c(AOB_SFObject__c = 'Assessment', Name = 'Select multi combobox', AOB_Section__c = sectionId, AOB_Type__c='Lookup'),
                new AOB_Field__c(AOB_SFObject__c = 'Assessment', Name = 'Select multi combobox of assests', AOB_Section__c = sectionId),
                new AOB_Field__c(AOB_SFObject__c = 'Assessment', Name = 'Select combobox', AOB_Section__c = sectionId)
                };
                    insert fieldMappingsAsse;
    }
    
    private static AssessmentQuestion createAssessmentQuestion(String name, String devName) {
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = devName,
            Name = name,
            QuestionCategory = 'Financial'
        );
        insert question;
        return question;
    }
    
    private static AssessmentQuestionVersion createAssessmentQuestionVersion(Id questionId, String questionText) {
        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = questionId,
            Questiontext = questionText,
            Name = questionText,
            IsActive = true
        );
        insert qv;
        return qv;
    }
    
    private static User createCommunityUser() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        return commUser;
    }
    
    private static PartyProfile createPartyProfile(Id accountId) {
        return ICS_DAL_TestFactory.createPartyProfile(accountId);
    }
    
    private static void createPartyAssetFunds(Id partyProfileId) {
        ICS_DAL_TestFactory.createPartyAssetFunds(partyProfileId);
    }
    
    private static Assessment createAssessment(Id accountId, Id partyProfileId) {
        Assessment assessment = new Assessment(
            Name = 'Test Assessment',
            AccountId = accountId,
            PartyProfileId = partyProfileId,
            AssessmentStatus = 'InProgress'
        );
        insert assessment;
        return assessment;
    }
    
    private static void createAssessmentQuestionResponse(Id assessmentId, Id questionId) {
        AssessmentQuestionResponse assRes = new AssessmentQuestionResponse(
            Name = 'Assets and Income',
            responsetext = 'Gift',
            AssessmentId = assessmentId,
            AssessmentQuestionId = questionId
        );
        insert assRes;
    }
    @isTest
    static void testAddNewBenefit() {
        try{
            User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
            
            String jsonString = '{"Select multi combobox":"Gift", "GiftW": [{"Identification number":"TRUE","Deed number":null,"Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}]}';
            List<aob_Field__c> fieldAssess=[select id from aob_Field__c where  AOB_SFObject__c ='Assessment'];
            Test.startTest();
            ICS_CTRL_DML_OnboardingAI.processData(jsonString,'ICS UK Financial Details','Assets and Income',commUser.contact.Accountid,fieldAssess);
            Test.stopTest();
        }catch(exception ex){
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }
        
    }
    @isTest
    static void testAddupdateBenefit() {
        try{
            User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
            
            Party_Assets_Funds__c fund =[select id from Party_Assets_Funds__c limit 1];
            String jsonString = '{"Select multi combobox":"Gift", "GiftW": [{"Deed number":null,"Id":"'+fund.id+'","Trust name":null,"Date received?":"2024-05-09","Full details inclusive of amount":null,"How and when did they derive their wealth?":"fgd","Who settled the Trust?":"dfgd","Location where trust is registered":"AF","Benefit description":null,"Are you named in the Trust deed":null,"Rationale for trust":"df","Annual Monetary Value":45,"Frequency of benefit":"Once-off","Type of benefit":"Disbursement"}]}';
            
            List<aob_Field__c> fieldAssess=[select id from aob_Field__c where  AOB_SFObject__c ='Assessment'];
            Test.startTest();
            
            ICS_CTRL_DML_OnboardingAI.processData(jsonString,'ICS UK Financial Details','Assets and Income',commUser.contact.Accountid,fieldAssess);
            
            Test.stopTest();
        }catch(exception ex){
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }
        
    }
    @isTest
    static void testProcessCurrencyField() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        AOB_Field__c field = new AOB_Field__c(
            Name = 'Annual Monetary Value',
            AOB_Type__c = 'Currency',
            AOB_SFField__c = 'Annual_Monetary_Value__c'
        );
        
        Map<String, Object> sectionData = new Map<String, Object>{
            'Annual Monetary Value' => 1000,
            'Annual Monetary ValueCurrency' => 'USD:1000'
        };
        
        Map<String, Decimal> conversionMap = new Map<String, Decimal>{
            'USD' => 1.2,
            'GBP' => 1.0
        };
        
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        Party_Assets_Funds__c testObj = new Party_Assets_Funds__c(
            Party_Profile__c = pData.Id
        );
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.wealthDetailsAmount = '';
        ICS_CTRL_DML_OnboardingAI.processCurrencyField(field, sectionData, 'Annual_Monetary_Value__c', testObj, conversionMap);
        Test.stopTest();
        
        Assert.isNotNull(testObj.get('Annual_Monetary_Value__c'));
        Assert.isNotNull(testObj.get('Wealth_Details_Inclusive_of_Amount__c'));
    }
    @isTest
    static void testUpsertPartyProfile() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        Party_Assets_Funds__c fund = new Party_Assets_Funds__c(
            Party_Profile__c = pData.Id,
            Type__c = 'Ownership/shares in business'
        );
        insert fund;
        
        String ownerJson = '[{' +
            '"First Name": "John",' +
            '"Surname": "Doe",' +
            '"Middle Name": "M",' +
            '"Date of birth": "1980-01-01",' +
            '"Gender": "Male",' +
            '"Town/City of Birth": "London",' +
            '"Country of Birth": "GB",' +
            '"Primary Country of Nationality": "GB",' +
            '"Secondary Country of Nationality": "US",' +
            '"Marital Status": "Single",' +
            '"Percentage of the business owned": "25"' +
        '}]';
    
        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.upsertPartyProfile(ownerJson, fund.Id);
        Test.stopTest();
    
        List<PartyProfile> insertedProfiles = [
            SELECT Id, FirstName, LastName, Party_Assets_Funds__c
            FROM PartyProfile 
            WHERE Party_Assets_Funds__c = :fund.Id
        ];
        
        Assert.areEqual(1, insertedProfiles.size(), 'One profile should be inserted');
        Assert.areEqual('John', insertedProfiles[0].FirstName, 'First name should match');
        Assert.areEqual('Doe', insertedProfiles[0].LastName, 'Last name should match');
    }
    @isTest
    static void testUpdateLinkedMap() {
       User commUser = ICS_DAL_TestFactory.createCommunityUser();
       commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
       
       PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
       Party_Assets_Funds__c fund = new Party_Assets_Funds__c(
           Party_Profile__c = pData.Id
       );
       insert fund;
       
       Test.startTest();
       // Test first insertion
       ICS_CTRL_DML_OnboardingAI.linkedMap = new Map<String, String>();
       ICS_CTRL_DML_OnboardingAI.updateLinkedMap(fund.Id, commUser.Contact.accountId);
       Assert.areEqual(fund.Id, ICS_CTRL_DML_OnboardingAI.linkedMap.get('Party_Assets_Funds__c'));
       Assert.areEqual(commUser.Contact.accountId, ICS_CTRL_DML_OnboardingAI.linkedMap.get('Account'));
       
       // Test adding another record
       Party_Assets_Funds__c fund2 = new Party_Assets_Funds__c(
           Party_Profile__c = pData.Id
       );
       insert fund2;
       ICS_CTRL_DML_OnboardingAI.updateLinkedMap(fund2.Id, commUser.Contact.accountId);
       Assert.areEqual(fund.Id + ':' + fund2.Id, ICS_CTRL_DML_OnboardingAI.linkedMap.get('Party_Assets_Funds__c'));
       Test.stopTest();
    }
    @isTest
    static void testAddNewFunds() {
        try{
            User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
            String jsonString = '{"Select multi combobox of assests":"Gift", "GiftV": [{"Deed numberV":null,"Trust nameV":null,"Date received?V":"2024-05-09","Full details inclusive of amountV":null,"How and when did they derive their wealth?V":"fgd","Who settled the Trust?V":"dfgd","Location where trust is registeredV":"AF","Benefit descriptionV":null,"Are you named in the Trust deedV":null,"Rationale for trustV":"df","Annual Monetary ValueV":45,"Frequency of benefitV":"Once-off","Type of benefitV":"Disbursement"}]}';
            
            List<aob_Field__c> fieldAssess=[select id from aob_Field__c where  AOB_SFObject__c ='Assessment'];
            Test.startTest();
            
            ICS_CTRL_DML_OnboardingAI.processData(jsonString,'ICS UK Financial Details','Assets and Income',commUser.contact.Accountid,fieldAssess);
            
            Test.stopTest();
        }catch(exception ex){
            Assert.areEqual(true, ex.getMessage() != null, 'Error Occurred'); 
        }
    }
    
    @isTest
    static void testUpdateLookup() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        Party_Assets_Funds__c testAssetFund = [SELECT Id FROM Party_Assets_Funds__c LIMIT 1];
        
        ICS_CTRL_DML_OnboardingAI.lookupFields = new Map<String, List<String>>{
            'Party_Assets_Funds__c' => new List<String>{'Party_Profile__c;PartyProfile'}
        };
            ICS_CTRL_DML_OnboardingAI.linkedMap = new Map<String, String>{
                'Party_Assets_Funds__c' => testAssetFund.Id,
                    'PartyProfile' => testPartyProfile.Id 
                    };
                        
                        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.updateLookup();
        Test.stopTest();
        
        // Add assertions to verify the results
        Party_Assets_Funds__c updatedAssetFund = [SELECT Id, Party_Profile__c FROM Party_Assets_Funds__c WHERE Id = :testAssetFund.Id];
        Assert.areEqual(testPartyProfile.Id, updatedAssetFund.Party_Profile__c, 'The Party_Profile__c lookup should be updated');
    }
    @isTest
    static void testProcessMultipleIds() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(commUser.contact.AccountId);
        ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.id);
        
        List<Party_Assets_Funds__c> testAssetFunds = new List<Party_Assets_Funds__c>();
        for(Integer i = 0; i < 2; i++) {
            Party_Assets_Funds__c fund = new Party_Assets_Funds__c(
                Party_Profile__c = testPartyProfile.Id,
                Type__c = 'Gift',
                Name = 'Test Fund ' + i
            );
            testAssetFunds.add(fund);
        }
        insert testAssetFunds;
        
        Party_Assets_Funds__c existingFund = [SELECT Id FROM Party_Assets_Funds__c WHERE Party_Profile__c = :testPartyProfile.Id LIMIT 1];
        testAssetFunds.add(existingFund);
        
        String multipleIds = testAssetFunds[0].Id + ':' + testAssetFunds[1].Id + ':' + testAssetFunds[2].Id;
        
        ICS_CTRL_DML_OnboardingAI.lookupFields = new Map<String, List<String>>{
            'Party_Assets_Funds__c' => new List<String>{'Party_Profile__c;PartyProfile'}
        };
        
        ICS_CTRL_DML_OnboardingAI.linkedMap = new Map<String, String>{
            'Party_Assets_Funds__c' => multipleIds,
            'PartyProfile' => testPartyProfile.Id 
        };
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.updateLookup();
        Test.stopTest();
        
        List<Party_Assets_Funds__c> updatedFunds = [SELECT Id, Party_Profile__c FROM Party_Assets_Funds__c WHERE Id IN :testAssetFunds];
        
        for(Party_Assets_Funds__c fund : updatedFunds) {
            Assert.areEqual(testPartyProfile.Id, fund.Party_Profile__c);
        }
        Assert.areEqual(3, updatedFunds.size());
    }
    
    @isTest
    static void testProcessMultipleIdsWithTwoRecords() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(commUser.contact.AccountId);
        ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.id);
        
        Party_Assets_Funds__c testAssetFund1 = new Party_Assets_Funds__c(
            Party_Profile__c = testPartyProfile.Id,
            Type__c = 'Gift',
            Name = 'Test Fund 1'
        );
        insert testAssetFund1;
        
        Party_Assets_Funds__c testAssetFund2 = [SELECT Id FROM Party_Assets_Funds__c WHERE Party_Profile__c = :testPartyProfile.Id LIMIT 1];
        
        String multipleAssetFundIds = testAssetFund1.Id + ':' + testAssetFund2.Id;
        
        ICS_CTRL_DML_OnboardingAI.lookupFields = new Map<String, List<String>>{
            'Party_Assets_Funds__c' => new List<String>{'Party_Profile__c;PartyProfile'}
        };
        
        ICS_CTRL_DML_OnboardingAI.linkedMap = new Map<String, String>{
            'Party_Assets_Funds__c' => multipleAssetFundIds,
            'PartyProfile' => testPartyProfile.Id
        };
        
        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.updateLookup();
        Test.stopTest();
        
        List<Party_Assets_Funds__c> updatedFunds = [SELECT Id, Party_Profile__c FROM Party_Assets_Funds__c WHERE Id IN (:testAssetFund1.Id, :testAssetFund2.Id)];
        
        Assert.areEqual(2, updatedFunds.size());
        for(Party_Assets_Funds__c fund : updatedFunds) {
            Assert.areEqual(testPartyProfile.Id, fund.Party_Profile__c);
        }
    }
    @isTest
    static void testUpsertPartyProfileWithFormerName() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        Party_Assets_Funds__c fund = new Party_Assets_Funds__c(
            Party_Profile__c = pData.Id,
            Type__c = 'Ownership/shares in business'
        );
        insert fund;
        
        String ownerJson = '[{' +
            '"First Name": "John",' +
            '"Surname": "Doe",' +
            '"Former Name or Maiden NameFFF": "FormerName",' +
            '"Former Name": "John Smith",' +
            '"Percentage of the business owned": "25"' +
        '}]';
    
        Test.startTest();
        ICS_CTRL_DML_OnboardingAI.upsertPartyProfile(ownerJson, fund.Id);
        Test.stopTest();
    
        List<PartyProfile> insertedProfiles = [
            SELECT Id, Has_Former_Name__c, Has_Maiden_Name__c, Former_Name__c
            FROM PartyProfile 
            WHERE Party_Assets_Funds__c = :fund.Id
        ];
        
        Assert.areEqual(1, insertedProfiles.size());
        Assert.areEqual('Yes', insertedProfiles[0].Has_Former_Name__c);
        Assert.areEqual('No', insertedProfiles[0].Has_Maiden_Name__c);
        Assert.areEqual('John Smith', insertedProfiles[0].Former_Name__c);
    }
    
}