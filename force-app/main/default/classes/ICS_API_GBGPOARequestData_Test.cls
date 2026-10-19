/***********************************************************
* @Name of the Class: ICS_API_GBGPOARequestData.cls
* @description: SFP-32986 Class used as test class for ICS_API_GBGPOARequestData
* @author: Ikyatha Naidu
* @date: 11/05/2024
********************************************************************
* @Last Modified By  IKYATHA NAIDU 
* @Last Modified Date 01/07/2024
* @Last Modified Description: updated to latest version
******************************************************************
* @Last Modified By  Ridhima Saxena
* @Last Modified Date 29/01/2025
* @Last Modified Description: SFP-55936 updated to latest version
******************************************************************/
@isTest
public class ICS_API_GBGPOARequestData_Test {
    
    // Constants to avoid duplicate string literals
    private static final String FEDERATION_IDENTIFIER_QUERY = 'FederationIdentifier%';
    private static final String DOC_TYPE_DRIVINGLICENCE = 'DrivingLicence';
    private static final String DOC_TYPE_IDENTITY_CARD = 'IdentityCard';
    private static final String COUNTRY_US = 'US';
    private static final String COUNTRY_AUSTRALIA = 'AU';
    private static final String COUNTRY_BRAZIL = 'BR';
    private static final String COUNTRY_CANADA = 'CA';
    private static final String COUNTRY_CHINA = 'CN';
    private static final String COUNTRY_INDIA = 'IN';
    private static final String COUNTRY_MEXICO = 'MX';
    private static final String COUNTRY_SPAIN = 'ES';
    private static final String COUNTRY_NEW_ZEALAND = 'NZ';
    private static final String COUNTRY_GERMANY = 'DE';
    private static final String COUNTRY_ITALY = 'IT';
    private static final String COUNTRY_ARGENTINA = 'AR';
    
    @TestSetup
    static void makeData() {
        // Create a community user - wrapped to separate setup object DML
        User commUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            commUser = ICS_DAL_TestFactory.createCommunityUser();
        }
        
        commUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        
        // Update account with comprehensive personal details
        Account acc = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId];
        acc.FirstName = 'John';
        acc.LastName = 'Doe';
        acc.PersonBirthdate = Date.newInstance(1990, 1, 1);
        acc.FinServ__Gender__pc = 'Male';
        acc.PersonEmail = 'john.doe@test.com';
        acc.PersonTitle = 'Mr';
        acc.MiddleName = 'Michael';
        update acc;
        
        // Create a party profile for the community user's account
        PartyProfile profileData = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.AccountId);
        profileData.Country_of_Residence__c = COUNTRY_US;
        profileData.Country_of_Nationality__c = COUNTRY_US;
        update profileData;
        
        // Create a party profile address with comprehensive data
        PartyProfileAddress address = ICS_DAL_TestFactory.createPartyProfileAddress(profileData.Id, 'Residential Address', Date.today(), null);
        address.Building_Name__c = 'Test Building';
        address.City = 'New York';
        address.Country = COUNTRY_US;
        address.Street = 'Main Street';
        address.PostalCode = '10001';
        address.State = 'NY';
        address.Sub_Building__c = 'Apt 101';
        address.Apartment_Number__c = '101';
        address.Secondary_Street__c = 'Second Ave';
        address.Neighbourhood__c = 'Manhattan';
        address.Date_Move_In__c = Date.newInstance(2020, 1, 1);
        update address;
        
        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            StageName = 'ID & Address Verification',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;
        
        // Create ApplicationForm
        ApplicationForm appForm = new ApplicationForm(
            AccountId = acc.Id,
            OpportunityId = opp.Id,
            UsageType='Onboarding'
        );
        insert appForm;
        
        // Create Product
        Product2 prod = new Product2(
            Name = 'Seafarer Product',
            ProductCode = 'CURR_SEA',
            IsActive = true
        );
        insert prod;
        
        // Create PricebookEntry (REQUIRED for OpportunityLineItem)
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
        
        // Create OpportunityLineItem (CORRECTED SYNTAX)
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,  // Required field
            Quantity = 1,                // Required field
            UnitPrice = 100              // Required field
        );
        insert oli;
        
        // Create a contact point phone for the account
        ContactPointPhone phone = ICS_DAL_TestFactory.createPointPhone(commUser.Contact.AccountId);
        phone.TelephoneNumber = '1234567890';
        update phone;
        
        // Create identity documents for testing
        IdentityDocument idDoc = new IdentityDocument();
        idDoc.PartyProfileId = profileData.Id;
        idDoc.Name = 'ID Number:123456789';
        idDoc.IdDocumentType = 'IDENTITY CARD';
        idDoc.RelatedLegalEntityId = acc.Id;
        insert idDoc;
    }
    
    // ========== BASIC FUNCTIONALITY TESTS ==========
    
    @isTest
    static void testBasicPOAJsonGeneration() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isNotNull(result, 'JSON result should not be null');
            Assert.isTrue(result.length() > 0, 'JSON result should not be empty');
            Assert.isTrue(result.contains('Address'), 'JSON should contain Address section');
            Assert.isTrue(result.contains('ContactDetails'), 'JSON should contain ContactDetails section');
            Assert.isTrue(result.contains('IdentityDocuments'), 'JSON should contain IdentityDocuments section');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testInvalidPartyProfileId() {
        User commUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson('InvalidId');
            Assert.isTrue(result == '', 'result was empty due to invalid partyprofile Id');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testNullPartyProfileId() {
        User commUser = [SELECT Id, Name, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(null);
            Assert.isTrue(result == '', 'result was empty due to null partyprofile Id');
        }
        Test.stopTest();
    }
    
    // ========== UK COUNTRY TESTS ==========
    @isTest
    static void testPopulateUKDocumentsDirectly() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            reqData.craRequest.IdentityDocuments = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments();
            
            // Test National Insurance
            reqData.populateUKDocuments('AB123456C', 'NationalInsurance');
            Assert.isNotNull(reqData.craRequest.IdentityDocuments.UK, 'UK section should be created');
            Assert.isNotNull(reqData.craRequest.IdentityDocuments.UK.NationalInsuranceNumber, 'NationalInsuranceNumber should be populated');
            Assert.areEqual('AB123456C', reqData.craRequest.IdentityDocuments.UK.NationalInsuranceNumber.Number_Z, 'NI number should match');
            
            // Test Passport
            reqData.craRequest.IdentityDocuments.UK = null;
            reqData.populateUKDocuments('987654321', 'Passport');
            Assert.isNotNull(reqData.craRequest.IdentityDocuments.UK.Passport, 'Passport should be populated');
            Assert.areEqual('987654321', reqData.craRequest.IdentityDocuments.UK.Passport.Number_Z, 'Passport number should match');
            
            // Test Driving Licence
            reqData.craRequest.IdentityDocuments.UK = null;
            reqData.populateUKDocuments('SMITH123456ABC', DOC_TYPE_DRIVINGLICENCE);
            Assert.isNotNull(reqData.craRequest.IdentityDocuments.UK.DrivingLicence, 'DrivingLicence should be populated');
            Assert.areEqual('SMITH123456ABC', reqData.craRequest.IdentityDocuments.UK.DrivingLicence.Number_Z, 'Driving licence number should match');
        }
        Test.stopTest();
    }
    // ========== US COUNTRY TESTS ==========
    
    @isTest
    static void testUSSocialSecurityDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        Test.startTest();
        IdentityDocument usDoc = new IdentityDocument();
        usDoc.PartyProfileId = profileData.Id;
        usDoc.Name = 'SocialSecurity:123-45-6789';
        usDoc.IdDocumentType = 'SocialSecurity';
        usDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert usDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('US'), 'JSON should contain US section');
            Assert.isTrue(result.contains('SocialSecurity'), 'JSON should contain SocialSecurity');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUSDrivingLicenceDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        Test.startTest();
        IdentityDocument usDoc = new IdentityDocument();
        usDoc.PartyProfileId = profileData.Id;
        usDoc.Name = 'DrivingLicence:MH01-20190012345';
        usDoc.IdDocumentType = DOC_TYPE_DRIVINGLICENCE;
        usDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert usDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('US'), 'JSON should contain US section');
        }
        Test.stopTest();
    }
    
    // ========== BRAZIL TESTS ==========
    
    @isTest
    static void testBrazilCPFDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_BRAZIL;
        update profileData;
        
        Test.startTest();
        IdentityDocument brDoc = new IdentityDocument();
        brDoc.PartyProfileId = profileData.Id;
        brDoc.Name = 'CPF:123.456.789-00';
        brDoc.IdDocumentType = 'CPF';
        brDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert brDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Brazil'), 'JSON should contain Brazil section');
            Assert.isTrue(result.contains('CPFNumber'), 'JSON should contain CPFNumber');
        }
        Test.stopTest();
    }
    
    // ========== AUSTRALIA TESTS ==========
    
    @isTest
    static void testAustraliaMedicareDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_AUSTRALIA;
        update profileData;
        
        Test.startTest();
        IdentityDocument auDoc = new IdentityDocument();
        auDoc.PartyProfileId = profileData.Id;
        auDoc.Name = 'DrivingLicence:MH01-20190012345';
        auDoc.IdDocumentType = DOC_TYPE_DRIVINGLICENCE;
        auDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert auDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Australia'), 'JSON should contain Australia section');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAustraliaPassportDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_AUSTRALIA;
        update profileData;
        
        Test.startTest();
        IdentityDocument auDoc = new IdentityDocument();
        auDoc.PartyProfileId = profileData.Id;
        auDoc.Name = 'Passport:N1234567';
        auDoc.IdDocumentType = 'PASSPORT NUMBER';
        auDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert auDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Australia'), 'JSON should contain Australia section');
        }
        Test.stopTest();
    }
    
    
    // ========== CANADA TESTS ==========
    
    @isTest
    static void testCanadaSocialInsuranceDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_CANADA;
        update profileData;
        
        Test.startTest();
        IdentityDocument caDoc = new IdentityDocument();
        caDoc.PartyProfileId = profileData.Id;
        caDoc.Name = 'SocialInsurance:123-456-789';
        caDoc.IdDocumentType = 'SocialInsurance';
        caDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert caDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Canada'), 'JSON should contain Canada section');
            Assert.isTrue(result.contains('SocialInsuranceNumber'), 'JSON should contain SocialInsuranceNumber');
        }
        Test.stopTest();
    }
    
    // ========== CHINA TESTS ==========
    
    @isTest
    static void testChinaResidentIdentityCardDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_CHINA;
        update profileData;
        
        Test.startTest();
        IdentityDocument cnDoc = new IdentityDocument();
        cnDoc.PartyProfileId = profileData.Id;
        cnDoc.Name = 'ResidentIdentityCard:123456789012345678';
        cnDoc.IdDocumentType = 'ResidentIdentityCard';
        cnDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert cnDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('China'), 'JSON should contain China section');
            Assert.isTrue(result.contains('ResidentIdentityCard'), 'JSON should contain ResidentIdentityCard');
        }
        Test.stopTest();
    }
    
    // ========== INDIA TESTS ==========
    
    @isTest
    static void testIndiaPANDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_INDIA;
        update profileData;
        
        Test.startTest();
        IdentityDocument inDoc = new IdentityDocument();
        inDoc.PartyProfileId = profileData.Id;
        inDoc.Name = 'PAN:ABCDE1234F';
        inDoc.IdDocumentType = 'PAN';
        inDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert inDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('India'), 'JSON should contain India section');
            Assert.isTrue(result.contains('PAN'), 'JSON should contain PAN');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testIndiaVoterIdDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_INDIA;
        update profileData;
        
        Test.startTest();
        IdentityDocument inDoc = new IdentityDocument();
        inDoc.PartyProfileId = profileData.Id;
        inDoc.Name = 'Voter ID:XYZ1234567';  
        inDoc.IdDocumentType = 'VOTERS ID CARD';  // Use actual picklist value
        inDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert inDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('India'), 'JSON should contain India section');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testIndiaDrivingLicenceDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_INDIA;
        update profileData;
        
        Test.startTest();
        IdentityDocument inDoc = new IdentityDocument();
        inDoc.PartyProfileId = profileData.Id;
        inDoc.Name = 'DrivingLicence:MH01-20190012345';
        inDoc.IdDocumentType = DOC_TYPE_DRIVINGLICENCE;
        inDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert inDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('India'), 'JSON should contain India section');
        }
        Test.stopTest();
    }
    
    // ========== MEXICO TESTS ==========
    
    @isTest
    static void testMexicoIdentityCardDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_MEXICO;
        update profileData;
        
        Test.startTest();
        IdentityDocument mxDoc = new IdentityDocument();
        mxDoc.PartyProfileId = profileData.Id;
        mxDoc.Name = 'IdentityCard:ABCD123456HDFABC01';
        mxDoc.IdDocumentType = DOC_TYPE_IDENTITY_CARD;
        mxDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert mxDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Mexico'), 'JSON should contain Mexico section');
            Assert.isTrue(result.contains(DOC_TYPE_IDENTITY_CARD), 'JSON should contain IdentityCard');
        }
        Test.stopTest();
    }
    
    // ========== SPAIN TESTS ==========
    
    @isTest
    static void testSpainTaxIDDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_SPAIN;
        update profileData;
        
        Test.startTest();
        IdentityDocument esDoc = new IdentityDocument();
        esDoc.PartyProfileId = profileData.Id;
        esDoc.Name = 'TaxIDNumber:12345678A';
        esDoc.IdDocumentType = 'TaxIDNumber';
        esDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert esDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Spain'), 'JSON should contain Spain section');
            Assert.isTrue(result.contains('TaxIDNumber'), 'JSON should contain TaxIDNumber');
        }
        Test.stopTest();
    }
    
    // ========== NEW ZEALAND TESTS ==========
    
    @isTest
    static void testNewZealandDrivingLicenceDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_NEW_ZEALAND;
        update profileData;
        
        Test.startTest();
        IdentityDocument nzDoc = new IdentityDocument();
        nzDoc.PartyProfileId = profileData.Id;
        nzDoc.Name = 'DrivingLicence:AB123456';
        nzDoc.IdDocumentType = DOC_TYPE_DRIVINGLICENCE;
        nzDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert nzDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('NewZealand'), 'JSON should contain NewZealand section');
            Assert.isTrue(result.contains('DrivingLicence'), 'JSON should contain DrivingLicence');
        }
        Test.stopTest();
    }
    
    // ========== EUROPEAN IDENTITY CARD TESTS ==========
    
    @isTest
    static void testEuropeanIdentityCardDefaultCase() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_GERMANY;
        update profileData;
        
        Test.startTest();
        IdentityDocument euDoc = new IdentityDocument();
        euDoc.PartyProfileId = profileData.Id;
        euDoc.Name = 'IdentityCard:123456789';
        euDoc.IdDocumentType = DOC_TYPE_IDENTITY_CARD;
        euDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert euDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains(DOC_TYPE_IDENTITY_CARD), 'JSON should contain IdentityCard section for European countries');
        }
        Test.stopTest();
    }
    // ========== GENDER MAPPING TESTS ==========
    
    @isTest
    static void testGenderMapping() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        Account acc = [SELECT Id FROM Account WHERE Id = :commUser.Contact.AccountId];
        
        Test.startTest();
        
        // Test Male
        acc.FinServ__Gender__pc = 'Male';
        update acc;
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            Assert.isTrue(result.contains('"Gender":2'), 'Male should map to 2');
        }
        
        // Test Female
        acc.FinServ__Gender__pc = 'Female';
        update acc;
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            Assert.isTrue(result.contains('"Gender":3'), 'Female should map to 3');
        }
        
        // Test Unknown
        acc.FinServ__Gender__pc = 'Unknown';
        update acc;
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            Assert.isTrue(result.contains('"Gender":1'), 'Unknown should map to 1');
        }
        
        Test.stopTest();
    }
    
    // ========== ADDRESS FIELD TESTS ==========
    
    @isTest
    static void testAddressWithNullFields() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        PartyProfileAddress address = [SELECT Id FROM PartyProfileAddress WHERE PartyProfileId = :profileData.Id LIMIT 1];
        
        Test.startTest();
        // Set some fields to null
        address.Sub_Building__c = null;
        address.Street = null;
        address.Neighbourhood__c = null;
        update address;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isNotNull(result, 'JSON should be generated even with null address fields');
            Assert.isTrue(result.length() > 0, 'JSON should not be empty');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAddressLinesPopulation() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('AddressLine1'), 'JSON should contain AddressLine1');
            Assert.isTrue(result.contains('AddressLine2'), 'JSON should contain AddressLine2');
        }
        Test.stopTest();
    }
    
    // ========== CONTACT DETAILS TESTS ==========
    
    @isTest
    static void testMissingContactPhone() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        // Delete phone to test missing phone scenario
        List<ContactPointPhone> phones = [SELECT Id FROM ContactPointPhone WHERE ParentId = :commUser.Contact.AccountId];
        if (!phones.isEmpty()) {
            delete phones;
        }
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            Assert.isTrue(result != '', 'result should still be generated without phone');
        }
        Test.stopTest();
    }
    // ========== MISSING DATA TESTS ==========
    
    @isTest
    static void testMissingIdentityDocuments() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        // Delete all identity documents
        List<IdentityDocument> docs = [SELECT Id FROM IdentityDocument WHERE PartyProfileId = :profileData.Id];
        if (!docs.isEmpty()) {
            delete docs;
        }
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isNotNull(result, 'JSON should be generated even without identity documents');
        }
        Test.stopTest();
    }
 
    // ========== ARGENTINA TESTS ==========

    @isTest
    static void testArgentinaDNIDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        profileData.Country_of_Residence__c = COUNTRY_ARGENTINA;
        update profileData;
        
        Test.startTest();
        IdentityDocument arDoc = new IdentityDocument();
        arDoc.PartyProfileId = profileData.Id;
        arDoc.Name = 'DNI No:12345678';
        arDoc.IdDocumentType = 'DNI No';
        arDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert arDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isTrue(result.contains('Argentina'), 'JSON should contain Argentina section');
            Assert.isTrue(result.contains('DNINumber'), 'JSON should contain DNINumber');
        }
        Test.stopTest();
    }
    
    // ========== EUROPEAN IDENTITY CARD TESTS ==========
    
    @isTest
    static void testEuropeanIdentityCardMultipleCountries() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        
        Test.startTest();
        
        // Test Italy
        profileData.Country_of_Residence__c = COUNTRY_ITALY;
        update profileData;
        
        IdentityDocument itDoc = new IdentityDocument();
        itDoc.PartyProfileId = profileData.Id;
        itDoc.Name = 'IdentityCard:IT123456';
        itDoc.IdDocumentType = DOC_TYPE_IDENTITY_CARD;
        itDoc.RelatedLegalEntityId = commUser.Contact.AccountId;
        insert itDoc;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            Assert.isTrue(result.contains(DOC_TYPE_IDENTITY_CARD), 'Should contain IdentityCard');
        }
        
        Test.stopTest();
    }
    @isTest
    static void testPopulateGenericIdentityCardMethodDirectly() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            reqData.craRequest = new ICS_DTO_CreateUpdateCustomerForCRA();
            reqData.craRequest.IdentityDocuments = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments();       
            reqData.populateGenericIdentityCard('XYZ123456', 'Portugal');
            Assert.isNotNull(reqData.craRequest.IdentityDocuments.IdentityCard, 'IdentityCard object should be created');
            Assert.areEqual('XYZ123456', reqData.craRequest.IdentityDocuments.IdentityCard.Number_Z, 'Document number should match');
            Assert.areEqual('Portugal', reqData.craRequest.IdentityDocuments.IdentityCard.Country, 'Country should match');
        }
        Test.stopTest();
    }
        
    // ========== RESIDENCE DATE TESTS ==========
    
    @isTest
    static void testResidenceDatesNull() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        PartyProfile profileData = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId];
        PartyProfileAddress address = [SELECT Id FROM PartyProfileAddress WHERE PartyProfileId = :profileData.Id LIMIT 1];
        
        Test.startTest();
        address.Date_Move_In__c = null;
        update address;
        
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            String result = reqData.preparePOAJson(profileData.Id);
            
            Assert.isNotNull(result, 'JSON should be generated even with null residence dates');
        }
        Test.stopTest();
    }

    // ========== IDENTITY CARD FLAG TEST ==========

    @isTest
    static void testGetIsIdentityCardFlag() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            // Test with metadata that has isIdentityCard flag
            for (ICS_GBGManadatoryFields__mdt metadata : ICS_GBGManadatoryFields__mdt.getAll().values()) {
                Boolean result = reqData.getIsIdentityCardFlag(metadata);
                // Should return either true or false based on metadata configuration
                Assert.isNotNull(result, 'Should return a boolean value');
            }
        }
        Test.stopTest();
    }
    @isTest
    static void testGetIsIdentityCardFlagException() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE :FEDERATION_IDENTIFIER_QUERY LIMIT 1];
        Test.startTest();
        System.runAs(commUser) {
            ICS_API_GBGPOARequestData reqData = new ICS_API_GBGPOARequestData();
            Boolean result = reqData.getIsIdentityCardFlag(null);
            Assert.isFalse(result, 'Should return false for null metadata');
        }
        Test.stopTest();
    }

}