/**
* @Name of the Class : ICS_DAL_TestFactory_Test
* @description class used as test Class for ICS_DAL_TestFactory test class factory for  SBO-UK - Story:SFP-37310 
* @author Ikyatha Naidu 
* @date 29/06/2024
* @last modified on  : 19-10-2024
* @last modified by  : Tushar Walse
* @Modification Description : SFP-37310 class used for adding test methods for ICS_DAL_TestFactory_Test for SBO-UK
* 
*/ 
@IsTest 
private class ICS_DAL_TestFactory_Test {
    
    @IsTest
    static void testCreateScreen() {
        Test.startTest();
        List<AOB_FlowScreen__c> screens = ICS_DAL_TestFactory.createScreen();
        Test.stopTest();
        
        Assert.areEqual(1, screens.size(), 'One screen should be created');
        Assert.areEqual('ICS UK Pre-Account Details', screens[0].Name, 'Screen name should match');
    }
    
    @IsTest
    static void testCreateFinancialDetailsScreen() {
        Test.startTest();
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFinancialDetailsScreen();
        Test.stopTest();
        
        Assert.areNotEqual(null, screen, 'Financial details screen should be created');
        Assert.areEqual('ICS UK Financial Details', screen.Name, 'Screen name should match');
    }
    
    @IsTest
    static void testCreateFlowscreen() {
        String screenName = 'Test Screen';
        Test.startTest();
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen(screenName);
        Test.stopTest();
        
        Assert.areNotEqual(null, screen, 'Flow screen should be created');
        Assert.areEqual(screenName, screen.Name, 'Screen name should match');
    }
    
    @IsTest
    static void testCreateScreenSection() {
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen('Test Screen');
        String sectionName = 'Test Section';
        
        Test.startTest();
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createScreenSection(screen, sectionName);
        Test.stopTest();
        
        Assert.areNotEqual(null, section, 'Screen section should be created');
        Assert.areEqual(sectionName, section.Name, 'Section name should match');
    }
    
    @IsTest
    static void testCreateFinancialDetailsSection() {
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFinancialDetailsScreen();
        
        Test.startTest();
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createFinancialDetailsSection(screen.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, section, 'Financial details section should be created');
        Assert.areEqual('Trusts', section.Name, 'Section name should match');
    }
    
    @IsTest
    static void testCreateApplicationFormfields() {
        Test.startTest();
        ICS_DAL_TestFactory.createApplicationFormfields();
        Test.stopTest();
        
        List<AOB_Field__c> fields = [SELECT Id FROM AOB_Field__c];
        Assert.areNotEqual(0, fields.size(), 'Application form fields should be created');
    }
    
    @IsTest
    static void testCreateFinancialDetailsField() {
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFinancialDetailsScreen();
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createFinancialDetailsSection(screen.Id);
        
        Test.startTest();
        AOB_Field__c field = ICS_DAL_TestFactory.createFinancialDetailsField('Account', 'TestField', 'TestField__c', section.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, field, 'Financial details field should be created');
        Assert.areEqual('TestField', field.Name, 'Field name should match');
    }
    
    @IsTest
    static void testCreateSection() {
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen('Test Screen');
        
        Test.startTest();
        List<AOB_ScreenSection__c> sections = ICS_DAL_TestFactory.createSection(screen.Id);
        Test.stopTest();
        
        Assert.areEqual(3, sections.size(), 'Three sections should be created');
    }
    
    @IsTest
    static void testCreateField() {
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen('Test Screen');
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createScreenSection(screen, 'Test Section');
        String jsonString = '[{"Name": "TestField", "AOB_Type__c": "Text"}]';
        
        Test.startTest();
        List<AOB_Field__c> fields = ICS_DAL_TestFactory.createField(jsonString, section.Id);
        Test.stopTest();
        
        Assert.areEqual(1, fields.size(), 'One field should be created');
        Assert.areEqual('TestField', fields[0].Name, 'Field name should match');
    }
    
    @IsTest
    static void testCreateRefData() {
        Test.startTest();
        List<AOB_ReferencedData__c> refData = ICS_DAL_TestFactory.createRefData();
        Test.stopTest();
        
        Assert.areEqual(2, refData.size(), 'Two reference data records should be created');
    }
    
    @IsTest
    static void testCreateContact() {
        Test.startTest();
        Contact contact = ICS_DAL_TestFactory.createContact();
        Test.stopTest();
        
        Assert.areNotEqual(null, contact, 'Contact should be created');
        Assert.areEqual('pingTest', contact.LastName, 'Contact last name should match');
    }
    
    @IsTest
    static void testCreateContactping() {
        Test.startTest();
        Contact contact = ICS_DAL_TestFactory.createContactping();
        Test.stopTest();
        
        Assert.areNotEqual(null, contact, 'Contact with Ping ID should be created');
        Assert.areEqual('12345', contact.Ping_Id__c, 'Ping ID should match');
    }
    
    @IsTest
    static void testCreateAccount() {
        Test.startTest();
        Account account = ICS_DAL_TestFactory.createAccount();
        Test.stopTest();
        
        Assert.areNotEqual(null, account, 'Account should be created');
        Assert.areEqual('TestACC', account.FirstName, 'Account first name should match');
    }
    
    @IsTest
    static void testCreateOpportunity() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, opp, 'Opportunity should be created');
        Assert.areEqual('tesstopp', opp.Name, 'Opportunity name should match');
    }
    
    @IsTest
    static void testCreateAccountwithoutRecordType() {
        Test.startTest();
        Account account = ICS_DAL_TestFactory.createAccountwithoutRecordType();
        Test.stopTest();
        
        Assert.areNotEqual(null, account, 'Account without record type should be created');
        Assert.areEqual('John', account.FirstName, 'Account first name should match');
    }
    
    
    
    @IsTest
    static void testCreatePartyProfile() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, profile, 'Party profile should be created');
        Assert.areEqual('record', profile.Name, 'Party profile name should match');
    }
    
    @IsTest
    static void testCreatePartyAssetFunds() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        
        Test.startTest();
        Party_Assets_Funds__c assetFund = ICS_DAL_TestFactory.createPartyAssetFunds(profile.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, assetFund, 'Party asset fund should be created');
        Assert.areEqual('Test Fund', assetFund.Name, 'Asset fund name should match');
    }
    
    @IsTest
    static void testCreateBusinessOwnerPartyProfile() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        PartyProfile profile = ICS_DAL_TestFactory.createBusinessOwnerPartyProfile(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, profile, 'Business owner party profile should be created');
        Assert.areEqual('record', profile.Name, 'Profile name should match');
    }
    
    @IsTest
    static void testCreatePartyProfileAddress() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        Date moveInDate = Date.today();
        Date moveOutDate = Date.today().addDays(30);
        
        Test.startTest();
        PartyProfileAddress address = ICS_DAL_TestFactory.createPartyProfileAddress(profile.Id, 'Family', moveInDate, moveOutDate);
        Test.stopTest();
        
        Assert.areNotEqual(null, address, 'Party profile address should be created');
        Assert.areEqual('Address', address.Name, 'Address name should match');
    }
    
    @IsTest
    static void testCreateTestDataPartyAssetFund() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        Id fundRecordTypeId = Schema.SObjectType.Party_Assets_Funds__c.getRecordTypeInfosByName().get('Wealth in Country').getRecordTypeId();
        
        Test.startTest();
        Party_Assets_Funds__c assetFund = ICS_DAL_TestFactory.createTestDataPartyAssetFund(profile.Id, 'Gift', fundRecordTypeId);
        Test.stopTest();
        
        Assert.areNotEqual(null, assetFund, 'Test data party asset fund should be created');
        Assert.areEqual('test', assetFund.Name, 'Asset fund name should match');
    }
    
    @IsTest
    static void testCreatePointPhone() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        ContactPointPhone phone = ICS_DAL_TestFactory.createPointPhone(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, phone, 'Contact point phone should be created');
        Assert.areEqual('9032296917', phone.TelephoneNumber, 'Phone number should match');
    }
    
    @IsTest
    static void testCreateContactPointEmail() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        ContactPointEmail email = ICS_DAL_TestFactory.createContactPointEmail(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, email, 'Contact point email should be created');
        Assert.areEqual('test@gmail.com', email.EmailAddress, 'Email address should match');
    }
    
    @IsTest
    static void testCreateProduct2() {
        Test.startTest();
        Product2 product = ICS_DAL_TestFactory.createProduct2(); 
        Test.stopTest();
        
        Assert.areNotEqual(null, product, 'Product should be created');
    }
    
    @IsTest
    static void testCreateEmployment() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        FinServ__Employment__c employment = ICS_DAL_TestFactory.createEmployment(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, employment, 'Employment record should be created');
    }
    
    @IsTest
    static void testCreateAssessment() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        Assessment assessment = ICS_DAL_TestFactory.createAssessment(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, assessment, 'Assessment should be created');
        Assert.areEqual('test', assessment.Name, 'Assessment name should match');
    }
    
    @IsTest
    static void testCreateAssessmentQuestionResponse() {
        Account account = ICS_DAL_TestFactory.createAccount();
        Assessment assessment = ICS_DAL_TestFactory.createAssessment(account.Id);
        ICS_DAL_TestFactory.createAssessmentQuestion();
        AssessmentQuestionVersion questionVersion = [SELECT Id FROM AssessmentQuestionVersion LIMIT 1];
        
        Test.startTest();
        AssessmentQuestionResponse response = ICS_DAL_TestFactory.createAssessmentQuestionResponse(assessment.Id, questionVersion.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, response, 'Assessment question response should be created');
        Assert.areEqual('Trusts', response.Name, 'Response name should match');
    }
    
    @IsTest
    static void testCreateIdentityDocument() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        
        Test.startTest();
        IdentityDocument identity = ICS_DAL_TestFactory.createIdentityDocument(account.Id, profile.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, identity, 'Identity document should be created');
        Assert.areEqual('test', identity.Name, 'Identity document name should match');
    }
    
    @IsTest
    static void testCreatePartyIdentity() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        
        Test.startTest();
        PartyIdentityVerification verification = ICS_DAL_TestFactory.createPartyIdentity(profile.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, verification, 'Party identity verification should be created');
        Assert.areEqual('record', verification.Name, 'Verification name should match');
    }
    
    @IsTest
    static void testCreateApplicationForm() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, form, 'Application form should be created');
        Assert.areEqual('Onboarding', form.UsageType, 'Usage type should match');
        Assert.areEqual('Awaiting Verification', form.Stage, 'Stage should match');
    }
    
    @IsTest
    static void testCreateApplicationFormWithOpportunity() {
        Account account = ICS_DAL_TestFactory.createAccount();
        Opportunity opp = ICS_DAL_TestFactory.createOpportunity(account.Id);
        
        Test.startTest();
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(account.Id, opp.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, form, 'Application form with opportunity should be created');
        Assert.areEqual(opp.Id, form.OpportunityId, 'Opportunity ID should match');
    }
    
    @IsTest
    static void testCreateContentVersion() {
        Test.startTest();
        List<ContentVersion> versions = ICS_DAL_TestFactory.createContentVersion();
        Test.stopTest();
        
        Assert.areEqual(1, versions.size(), 'One content version should be created');
        Assert.areEqual('Everyday Banking account_UGX', versions[0].Title, 'Content version title should match');
    }
    
    @IsTest
    static void testCreateContentDocumentLink() {
        Account account = ICS_DAL_TestFactory.createAccount();
        List<ContentVersion> versions = ICS_DAL_TestFactory.createContentVersion();
        Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :versions[0].Id].ContentDocumentId;
        
        Test.startTest();
        List<ContentDocumentLink> links = ICS_DAL_TestFactory.createContentDocumentLink(account.Id, contentDocumentId);
        Test.stopTest();
        
        Assert.areEqual(1, links.size(), 'One content document link should be created');
        Assert.areEqual(account.Id, links[0].LinkedEntityId, 'Linked entity ID should match');
    }
    
    @IsTest
    static void testCreateApplicant() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(account.Id);
        
        Test.startTest();
        Applicant applicant = ICS_DAL_TestFactory.createApplicant(account.Id, profile.Id, form.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, applicant, 'Applicant should be created');
        Assert.areEqual('Primary Applicant', applicant.Role, 'Applicant role should match');
    }
    
    @IsTest
    static void testCreateTaxDetails() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        TaxDetails__c taxDetails = ICS_DAL_TestFactory.createTaxDetails(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, taxDetails, 'Tax details should be created');
        Assert.areEqual('sss', taxDetails.ExternalIdentifier__c, 'External identifier should match');
    }
    
    @IsTest
    static void testCreateApplicantByRole() {
        Account account = ICS_DAL_TestFactory.createAccount();
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(account.Id);
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(account.Id);
        String role = 'Secondary Applicant';
        
        Test.startTest();
        Applicant applicant = ICS_DAL_TestFactory.createApplicantByRole(role, account.Id, profile.Id, form.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, applicant, 'Applicant should be created');
        Assert.areEqual(role, applicant.Role, 'Applicant role should match');
    }
    
    @IsTest
    static void testCreateCommunityUser() {
        Test.startTest();
        User communityUser = ICS_DAL_TestFactory.createCommunityUser();
        Test.stopTest();
        
        Assert.areNotEqual(null, communityUser, 'Community user should be created');
        Assert.areEqual('test', communityUser.LastName, 'User last name should match');
    }
    
    @IsTest
    static void testCreateTestDataSalesCode() {
        Test.startTest();
        List<Sales_Codes__c> salesCodes = ICS_DAL_TestFactory.createTestDataSalesCode();
        Test.stopTest();
        
        Assert.areEqual(2, salesCodes.size(), 'Two sales code records should be created');
        Assert.areEqual('028NP', salesCodes[0].Name, 'First sales code name should match');
        Assert.areEqual('ZA', salesCodes[0].Sales_Code_Country__c, 'First sales code country should match');
        Assert.areEqual('AL', salesCodes[1].Sales_Code_Country__c, 'Second sales code country should match');
    }
    
    @IsTest
    static void testCreateAssessmentQuestion() {
        Test.startTest();
        ICS_DAL_TestFactory.createAssessmentQuestion();
        Test.stopTest();
        
        List<AssessmentQuestion> questions = [SELECT Id, Name FROM AssessmentQuestion];
        Assert.areEqual(1, questions.size(), 'One assessment question should be created');
        Assert.areEqual('Select all assets and income*', questions[0].Name, 'Assessment question name should match');
        
        List<AssessmentQuestionVersion> versions = [SELECT Id, Name FROM AssessmentQuestionVersion];
        Assert.areEqual(1, versions.size(), 'One assessment question version should be created');
        Assert.areEqual('Select all assets and income*', versions[0].Name, 'Assessment question version name should match');
    }

    @IsTest
    static void testCreateAssessmentQuestionVersion() {       
        Test.startTest();
        AssessmentQuestionVersion assessment = ICS_DAL_TestFactory.createAssessmentQuestionVersion();
        ICS_DAL_TestFactory.createFields((Id)null);
        Test.stopTest();
        
        Assert.areNotEqual(null, assessment, 'Assessment should be created');
    }    

    @IsTest
    static void testCreateDirectOpportunity() {
        Account account = ICS_DAL_TestFactory.createAccount();
        
        Test.startTest();
        Opportunity opp = ICS_DAL_TestFactory.createDirectOpportunity(account.Id);
        Test.stopTest();
        
        Assert.areNotEqual(null, opp, 'Opportunity should be created');
        Assert.areEqual('tesstopp', opp.Name, 'Opportunity name should match');
    }
    
    
    @isTest 
    	static void testCreateApplicationFormWithAccountandOpportunity(){
          Account account = ICS_DAL_TestFactory.createAccount();
            Opportunity opp = ICS_DAL_TestFactory.createDirectOpportunity(account.Id);
            
            Test.startTest();
        ApplicationForm appForm = ICS_DAL_TestFactory.createApplicationForm(account.Id,opp);
        Test.stopTest();
              Assert.areEqual('Awaiting Verification', appForm.Stage, 'ApplicationForm STage should match');
        
    }
    @isTest
    static void testCreateGroup(){
         Test.startTest();
        Group groupRec=ICS_DAL_TestFactory.createGroup();
         Test.stopTest();
           Assert.areEqual(true,groupRec !=null, 'Opportunity name should match');
    }
}