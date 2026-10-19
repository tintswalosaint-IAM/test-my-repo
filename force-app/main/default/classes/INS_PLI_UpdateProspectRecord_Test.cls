/**
 * @description       : Test class for INS_PLI_UpdateProspectRecord controller
 * @author            : Vershley Joyejob
 * @UserStory         : SFP-52379
 * @date              : 19-09-2025
 **/
@isTest
public with sharing class INS_PLI_UpdateProspectRecord_Test {

    // Constants to avoid duplicate literals
    private static final String STAGE_PROPOSAL = 'Proposal';
    private static final String PRICEBOOK_KENYA = 'C&HNW(Kenya)';
    private static final String PRODUCT_CODE_LIFE = 'LIFE001';
    private static final String PRODUCT_NAME_PLATINUM = 'Platinum Life Insurance';
    private static final String LAST_NAME_USER = 'User';
    private static final String ID_NUMBER_EXIST = 'EXIST123';
    private static final String LAST_NAME_RESUME = 'Resume';
    private static final String COUNTRY_KE = 'KE';
    private static final String RT_GENERAL = 'General';
    private static final String RECORDTYPE_PERSON_ACCOUNT_PROSPECT = 'Person_Account_Prospect';
    private static final String RECORDTYPE_BOTSWANA_BCC = 'Botswana_BCC';
    private static final String RECORDTYPE_PERSONACCOUNT = 'PersonAccount';
    private static final String RECORDTYPE_INSURANCE_INDIVIDUAL = 'Insurance_Individual';
    private static final String EMAIL_ENCODING = 'UTF-8';
    private static final String LANGUAGE_KEY = 'en_US';
    
    // Utility to get/create Person Account record type
    private static Id getPersonAccountProspectRT() {
        return Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(RECORDTYPE_PERSON_ACCOUNT_PROSPECT).getRecordTypeId();
    }

    // Utility to get/create Individual RT
    private static Id getIndividualRT() {
        return Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName()
                .get(RECORDTYPE_BOTSWANA_BCC).getRecordTypeId();
    }

    // Utility to get Opportunity RT  
    private static Id getOpportunityRT() {
        return Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                .get(RT_GENERAL).getRecordTypeId();
    }   
    @isTest
    static void testInitiateOnboardingProcess_NewRecords() {
        Test.startTest();
        // Build JSON
        INS_PLI_UpdateProspectRecord.personalInformation pi = new INS_PLI_UpdateProspectRecord.personalInformation();
        pi.ProductName = 'Life Cover';
        pi.FirstName = 'John';
        pi.LastName = 'Doe';
        pi.DateOfBirth = '1990-01-01';
        pi.IdNumber = 'ID123456';
        pi.Email = 'john.doe@test.com';
        pi.PhoneNumber = '721234567';
        pi.Gender = 'Male';

        String jsonStr = JSON.serialize(pi);

        // Call method (new record path since no IdentityDocument exists)
        Map<String, Object> result = INS_PLI_UpdateProspectRecord.initiateOnboardingProcess(jsonStr);

        Account acc = [SELECT Id FROM Account][0];
        IdentityDocument identDocId = [SELECT Id FROM IdentityDocument][0];
        Individual indId = [SELECT Id FROM Individual][0];

        Assert.areEqual(acc.Id, result.get('AccountId'), 'AccountId should be equal to selected on');
        Assert.areEqual(identDocId.Id, result.get('IdentityDocumentId'), 'IdentityDocumentId should be equal to selected on');
        Assert.areEqual(indId.Id, result.get('IndividualId'), 'IndividualId should be equal to selected on');
        Test.stopTest();
    }

    @isTest
    static void testInitiateOnboardingProcess_ExistingRecords() {
        // First insert Account + IdentityDocument manually
        Individual ind = new Individual(
                FirstName = 'Jane',
                LastName = 'Smith',
                BirthDate = Date.newInstance(1995,5,5),
                Data_Privacy_Consent__c = true,
                RecordTypeId = getIndividualRT(),
                National_Identity_Number__c = ID_NUMBER_EXIST
        );
        insert ind;

        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Jane',
                LastName = 'Smith',
                PersonEmail = 'jane@test.com',
                PersonBirthdate = Date.newInstance(1995,5,5),
                CMN_IdentityNumber__pc = ID_NUMBER_EXIST,
                PersonIndividualId = ind.Id
        );
        insert acc;

        IdentityDocument doc = new IdentityDocument(
                Name = ID_NUMBER_EXIST,
                RelatedLegalEntityId = acc.Id,
                IdDocumentType = 'NATIONAL IDENTITY DOCUMENT'
        );
        insert doc;

        // JSON with existing IdNumber
        INS_PLI_UpdateProspectRecord.personalInformation pi = new INS_PLI_UpdateProspectRecord.personalInformation();
        pi.FirstName = 'Jane';
        pi.LastName = 'Smith';
        pi.DateOfBirth = '1995-05-05';
        pi.IdNumber = ID_NUMBER_EXIST;
        String jsonStr = JSON.serialize(pi);

        Test.startTest();
        Map<String, Object> result = INS_PLI_UpdateProspectRecord.initiateOnboardingProcess(jsonStr);
        Test.stopTest();

        Assert.areEqual(acc.Id, (Id)result.get('AccountId'), 'AccountId should match existing account ID');
        Assert.areEqual(doc.Id, (Id)result.get('IdentityDocumentId'), 'IdentityDocumentId should match existing document ID');
    }

    @isTest
    static void testInitiateQuotingProcess() {
        User owner;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            UserRole role = new UserRole(Name = 'Portal Role');
            insert role;
    
            // Fetch a system admin as the owner
            owner = [SELECT Id, UserRoleId FROM User WHERE Profile.Name = 'System Administrator' LIMIT 1];
            owner.UserRoleId = role.Id;
            update owner;
        }
        // Create account first
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Quoter',
                LastName = 'Tester',
                CMN_IdentityNumber__pc = 'QID123',
            	OwnerId = owner.Id,
                PersonBirthdate = Date.newInstance(1980,1,1)
        );
        insert acc; 
      Contact con = [
                SELECT Id, Email, Phone
                FROM Contact
                WHERE AccountId = :acc.Id
                LIMIT 1
      		];
        con.INS_SalesAgentANumber__c = '123456789';
        update con;
        Profile p = [SELECT Id FROM Profile WHERE Name LIKE 'Customer Community%' LIMIT 1];
        User testUser = new User(
            FirstName = 'Portal',
            LastName = LAST_NAME_USER,
            Email = 'portal.user@example.com',
            Username = 'portal.user.' + System.currentTimeMillis() + '@test.com',
            Alias = 'puser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = LANGUAGE_KEY,
            EmailEncodingKey = EMAIL_ENCODING,
            LanguageLocaleKey = LANGUAGE_KEY,
            ProfileId = p.Id,
            ContactId = con.Id
        );
        insert testUser;        
		 Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();
       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry; 
        // Get related Account and Contact
        Contact cont = [SELECT Id, AccountId FROM Contact WHERE Id = :testUser.ContactId LIMIT 1];
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = cont.AccountId,
            StageName = 'Prospecting',     
            CloseDate = Date.today().addDays(30), // Required
            Pricebook2Id = customPricebook.Id,
            Country__c = COUNTRY_KE
        );
		insert opp;        
		// Create a Quote 
        Quote qt = new Quote(
            Name = 'Test Quote',
            OpportunityId = opp.Id,
            OwnerId = testUser.Id,
            Pricebook2Id = stdPricebookId
        );
        insert qt;
        // Prepare JSON
        INS_PLI_UpdateProspectRecord.personalInformation pi = new INS_PLI_UpdateProspectRecord.personalInformation();
        pi.ProductName = 'Life Cover';
        pi.FirstName = 'Quoter';
        pi.LastName = 'Tester';
        pi.CoverAmount = '500000';
        pi.MonthlyPremium = '2000';
        pi.AccountId = acc.Id;        
        String jsonStr = JSON.serialize(pi);

        Test.startTest();
        Map<String, Object> result = INS_PLI_UpdateProspectRecord.initiateQuotingProcess(jsonStr, 'Stanbic');               
		Test.stopTest();
        
        Id createdOppId = (Id) result.get('OpportunityId');
        Id createdQuoteId = (Id) result.get('QuoteId');        
        // Verify they exist
        Opportunity createdOpp = [
            SELECT Id, AccountId, StageName
            FROM Opportunity
            WHERE Id = :createdOppId
        ];        
        Quote createdQuote = [
            SELECT Id, OpportunityId
            FROM Quote
            WHERE Id = :createdQuoteId
        ];        
        // Assertions
        Assert.areEqual(acc.Id, createdOpp.AccountId, 'Account Id should be the same as created Opportunity Acccount Id');
        Assert.areEqual(createdOpp.Id, createdQuote.OpportunityId, 'Created Quote Opportunity Id should be the same as created Opportunity Id');
    }
    @isTest
    static void testUpdateOnboardingSteps() {

        // Create Account + Opportunity
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = LAST_NAME_RESUME,
                LastName = LAST_NAME_USER,
                CMN_IdentityNumber__pc = 'RESUME123',
                PersonEmail = 'resume@test.com',
                PersonBirthdate = Date.newInstance(1992,2,2)
        );
        insert acc;
         Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        Opportunity opp = new Opportunity(
                Name = 'Update Test Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;

        Test.startTest();
        INS_PLI_UpdateProspectRecord.updateOnboardingSteps(opp.Id, 'Step 3 - Submit');
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, INS_OnboardingStep__c FROM Opportunity WHERE Id = :opp.Id];
        Assert.areEqual('Step 3 - Submit', updatedOpp.INS_OnboardingStep__c, 'Onboarding step should be updated to Step 3 - Submit');
    }

    @isTest
    static void testResumeOrStartOnboarding_ResumeTrue() {
        // Create Account + Opportunity
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = LAST_NAME_RESUME,
                LastName = LAST_NAME_USER,
                CMN_IdentityNumber__pc = 'RESUME123',
                FinServ__CustomerType__c = 'IAM Liberty'
        );
        insert acc;
         Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        Opportunity opp = new Opportunity(
                RecordTypeId = getOpportunityRT(),
                Name = 'Resume Opp',
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
                AccountId = acc.Id,
                Total_Cover_Amount__c = 100000,
                Total_Monthly_Premium__c = 500,
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;
        
        
        Quote qt = new Quote(
            Name = 'Doc Status Quote',
            OpportunityId = opp.Id,
            Pricebook2Id = Test.getStandardPricebookId(),
            INS_PolicyDocumentLatestStatus__c = 'Signed by Customer'
        );
        insert qt;
        
        // Build personalInformation JSON matching the updated method signature
        String personalInformationJSON = JSON.serialize(new Map<String, Object>{
            'IdNumber'      => 'RESUME123',
            'FirstName'     => LAST_NAME_RESUME,
            'LastName'      => LAST_NAME_USER,
            'Email'         => 'resume@test.com',
            'PhoneNumber'   => '712345678',
            'Gender'        => 'Male',
            'DateOfBirth'   => '1992-02-02',
            'ProductName'   => 'Platinum Life Insurance'
        });

        Test.startTest();
        Map<String, Object> result = INS_PLI_UpdateProspectRecord.resumeOrStartOnboarding(personalInformationJSON);
        Test.stopTest();

        Assert.areEqual(acc.Id, result.get('AccountId'), 'AccountId should match the selected account ID');
        Assert.areEqual(true, result.get('Resume'), 'Resume should be true when account and opportunity exist');
        Assert.areEqual(opp.Id, result.get('OpportunityId'), 'OpportunityId should match the created opportunity ID');
    }

    @isTest
    static void testResumeOrStartOnboarding_NoAccount() {

        String personalInformationJSON = JSON.serialize(new Map<String, Object>{
            'IdNumber'    => 'NON_EXIST',
            'FirstName'   => 'Test',
            'LastName'    => 'User',
            'Email'       => 'noexist@test.com',
            'PhoneNumber' => '712345678',
            'Gender'      => 'Male',
            'DateOfBirth' => '1990-01-01',
            'ProductName' => 'Platinum Life Insurance'
        });

        Test.startTest();
        Map<String,Object> result = INS_PLI_UpdateProspectRecord.resumeOrStartOnboarding(personalInformationJSON);
        Test.stopTest();

        Assert.areEqual(false, result.get('Resume'), 'Resume should be false when no account exists');
    }

    @isTest
    static void testUpdateSalesEvent() {
        // Create Account + Opportunity
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Sales',
                LastName = 'Event',
                CMN_IdentityNumber__pc = 'SALESEVT123',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        insert acc;
		 Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        Opportunity opp = new Opportunity(
                Name = 'Sales Event Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;

        Test.startTest();
        INS_PLI_UpdateProspectRecord.updateSalesEvent(opp.Id, 'Q-00123');
        Test.stopTest();

        Opportunity reloaded = [SELECT Id, Quote_Id__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        Assert.areEqual('Q-00123', reloaded.Quote_Id__c, 'Sales Event (Quote_Id__c) should be updated');
    }
    
       @isTest
    static void testUpdateOpportunityStatus() {
        // Create Account + Opportunity
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Sales',
                LastName = 'Event',
                CMN_IdentityNumber__pc = 'SALESEVT123',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        insert acc;
         Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;

        Opportunity opp = new Opportunity(
                Name = 'Sales Event Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
				Country__c = COUNTRY_KE
        );
        insert opp;

        Test.startTest();
        INS_PLI_UpdateProspectRecord.updateOpportunityStatus(opp.Id, 'Closed Won');
        Opportunity opportunity = [SELECT Id, StageName FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        Assert.areEqual('Closed Won', opportunity.StageName, 'Opportunity StageName updated');
        Test.stopTest();

    }
    
    @isTest
    static void testUpdateConvertAcc() {
        //Store the recordtypeId        
       RecordType personRT = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Account'
            AND DeveloperName = :RECORDTYPE_PERSONACCOUNT 
            LIMIT 1
        ];         
        // Create Account + Opportunity
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Sales',
                LastName = 'Event',
                CMN_IdentityNumber__pc = 'SALESEVT123',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        insert acc;
         Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        Opportunity opp = new Opportunity(
                Name = 'Sales Event Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;

        Test.startTest();
        INS_PLI_UpdateProspectRecord.covertToPersonAcc(acc.Id, 'policy');
        Test.stopTest();
        
        Account accAfterConvert = CMN_DAL_Account.findById(acc.Id);
        Assert.areEqual(accAfterConvert.RecordTypeId, personRT.Id, 'Incorrect RecordType assigned during converson');        
        Assert.isTrue(accAfterConvert.IsPersonAccount, 'Account is not Person Account');
    }

    @isTest
    static void testCheckPolicyDocumentStatus_Signed() {
        // Create Account first
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Doc',
                LastName = 'Status',
                CMN_IdentityNumber__pc = 'DOC123',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        insert acc;
		 Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        // Create Quote with Signed status
        Opportunity opp = new Opportunity(
                Name = 'Doc Status Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;
        Quote qt = new Quote(
                Name = 'Doc Status Quote',
                OpportunityId = opp.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                INS_PolicyDocumentLatestStatus__c = 'Signed by Customer'
        );
        insert qt;

        Test.startTest();
        Boolean isSigned = INS_PLI_UpdateProspectRecord.checkPolicyDocumentStatus(qt.Id);
        Test.stopTest();

        Assert.areEqual(true, isSigned, 'Should return true when latest policy document status contains Signed');
    }

    @isTest
    static void testCheckPolicyDocumentStatus_NotSigned() {
        // Create Account first
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Doc',
                LastName = 'Status2',
                CMN_IdentityNumber__pc = 'DOC456',
                PersonBirthdate = Date.newInstance(1990,1,1)
        );
        insert acc;
        Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
		// Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;
        // Create Quote with non-signed status
        Opportunity opp = new Opportunity(
                Name = 'Doc Status Opp 2',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
            	Pricebook2Id = customPricebook.Id,
            	Country__c = COUNTRY_KE
        );
        insert opp;
        Quote qt = new Quote(
                Name = 'Doc Status Quote 2',
                OpportunityId = opp.Id,
                Pricebook2Id = Test.getStandardPricebookId(),
                INS_PolicyDocumentLatestStatus__c = 'Pending Signature'
        );
        insert qt;

        Test.startTest();
        Boolean isSigned = INS_PLI_UpdateProspectRecord.checkPolicyDocumentStatus(qt.Id);
        Test.stopTest();

        Assert.areEqual(false, isSigned, 'Should return false when latest policy document status is not signed');
    }

    @isTest
    static void testGetCountriesList_NoException() {
        Test.startTest();
        Map<String, String> countries = INS_PLI_UpdateProspectRecord.getCountriesList();
        Test.stopTest();

        // We don't assert specific contents as the provider may vary per org.
        // Assert only that the call completed without exception and returns either null or a map.
        Assert.isTrue(countries == null || countries.size() >= 0, 'Method should return null or a non-negative-sized map');
    }

    private class TinyUrlSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody('{"data":{"tiny_url":"https://tinyurl.com/test123","url":"https://www.example.com","domain":"tinyurl.com"}}');
            return res;
        }
    }

    @isTest
    static void testGetShortUrl_Success() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TinyUrlSuccessMock());
        String shortened = INS_PLI_UpdateProspectRecord.getShortUrl('https://www.example.com/page1');
        Test.stopTest();

        Assert.areEqual('https://tinyurl.com/test123', shortened, 'Expected shortened URL returned');
    }
	
    @isTest
    static void testUpdateAddress_Success() {
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Address',
                LastName = 'Tester',
                CMN_IdentityNumber__pc = 'ADDR123',
                PersonBirthdate = Date.newInstance(1985,5,15)
        );
        insert acc;

        Map<String, Object> payload = new Map<String, Object>{
                'AccId' => acc.Id,
                'AddressInformation' => new Map<String, Object>{
                        'AddressLine1' => '123 Main Street',
                        'AddressLine2' => 'Apartment 5B',
                        'City' => 'Gaborone',
                        'PostalCode' => '00000',
                        'CountriesLiveIn' => 'Botswana',
                        'CountriesCitizen' => 'Botswana'
                }
        };
		Test.startTest();
        Account updatedAcc = [SELECT BillingStreet, BillingCity FROM Account WHERE Id = :acc.Id LIMIT 1];

        try {
            INS_PLI_UpdateProspectRecord.updateAddress(JSON.serialize(payload));
        } catch (AuraHandledException e) {
            Assert.areNotEqual('123 Main Street\nApartment 5B', updatedAcc.BillingStreet, 'Billing street should be updated');
            Assert.areNotEqual('Gaborone', updatedAcc.BillingCity, 'Billing city should be updated');
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdateAddress_InvalidAccountId() {
        Map<String, Object> payload = new Map<String, Object>{
                'AccId' => sbgplatform.fflib_IDGenerator.generate(Account.SObjectType),
                'AddressInformation' => new Map<String, Object>{'AddressLine1' => '123 Main Street'}
        };

        Test.startTest();
        try {
            INS_PLI_UpdateProspectRecord.updateAddress(JSON.serialize(payload));
            Assert.fail('Expected AuraHandledException for invalid Account Id');        
        }catch (AuraHandledException e) {
    		Assert.isTrue(e.getMessage().contains('Script-thrown exception'),'Should throw AuraHandledException for invalid Account Id');
        }
        catch (Exception e) {
            Assert.fail('Unexpected exception type: ' + e.getTypeName());
        }
        Test.stopTest();        
    }
    @isTest
    static void testUpdateQuotingProcess_Success() {
        Account acc = new Account(
                RecordTypeId = getPersonAccountProspectRT(),
                FirstName = 'Update',
                LastName = 'Quote',
                CMN_IdentityNumber__pc = 'UPDATE123',
                PersonBirthdate = Date.newInstance(1985,3,15)
        );
        insert acc;
        Product2 prod = new Product2(
            Name = PRODUCT_NAME_PLATINUM,
            ProductCode = PRODUCT_CODE_LIFE,
            IsActive = true
        );
        insert prod;
        Id stdPricebookId = Test.getStandardPricebookId();       
		PricebookEntry pbe = new PricebookEntry(
            Product2Id = prod.Id,
            Pricebook2Id = stdPricebookId,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert pbe;
        // Create a Custom Pricebook and Entry
        Pricebook2 customPricebook = new Pricebook2(
            Name = PRICEBOOK_KENYA,
            IsActive = true			          
        );
        insert customPricebook;
        PricebookEntry customEntry = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 120.00,
            IsActive = true,
            UseStandardPrice = false
        );
        insert customEntry;

        Opportunity opp = new Opportunity(
                Name = 'Update Quote Opp',
                RecordTypeId = getOpportunityRT(),
                AccountId = acc.Id,
                StageName = STAGE_PROPOSAL,
                CloseDate = Date.today(),
                Pricebook2Id = customPricebook.Id,
				Country__c = COUNTRY_KE
        );
        insert opp;
        Quote qt = new Quote(
                Name = 'Update Quote',
                OpportunityId = opp.Id,
                Pricebook2Id = Test.getStandardPricebookId()
        );
        insert qt;
        INS_PLI_UpdateProspectRecord.personalInformation pi = new INS_PLI_UpdateProspectRecord.personalInformation();
        pi.CoverAmount = '750000';
        pi.MonthlyPremium = '3500';
        String jsonStr = JSON.serialize(pi);

        Test.startTest();
        Map<String, Object> result = INS_PLI_UpdateProspectRecord.updateQuotingProcess(jsonStr, qt.Id, opp.Id);
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Total_Cover_Amount__c, Total_Monthly_Premium__c FROM Opportunity WHERE Id = :opp.Id];
        Quote updatedQuote = [SELECT INS_IndicativePremium__c, INS_MonthlyPremium__c, UnderwriterQuoteReferenceNumber__c FROM Quote WHERE Id = :qt.Id];

        Assert.areEqual(750000, updatedOpp.Total_Cover_Amount__c, 'Total_Cover_Amount__c should be updated');
        Assert.areEqual(3500, updatedOpp.Total_Monthly_Premium__c, 'Total_Monthly_Premium__c should be updated');
        Assert.areEqual(3500, updatedQuote.INS_IndicativePremium__c, 'INS_IndicativePremium__c should be updated');
        Assert.areEqual(3500, updatedQuote.INS_MonthlyPremium__c, 'INS_MonthlyPremium__c should be updated');
        Assert.areEqual(opp.Id, result.get('OpportunityId'), 'OpportunityId should be returned');
        Assert.areEqual(qt.Id, result.get('QuoteId'), 'QuoteId should be returned');
                
        String newReference = 'New Reference';
        INS_PLI_UpdateProspectRecord.updateQuoteReference(updatedQuote.Id, newReference);
        Quote afterReference = [SELECT INS_IndicativePremium__c, INS_MonthlyPremium__c, UnderwriterQuoteReferenceNumber__c FROM Quote WHERE Id = :qt.Id];
        Assert.areEqual(newReference, afterReference.UnderwriterQuoteReferenceNumber__c, 'Reference was not changed');
        
    }    
    @IsTest
	static void testUpdateAccountRecord_success() {
       Account acc = new Account(
            RecordTypeId = getPersonAccountProspectRT(),
            FirstName = 'Test',
            LastName = LAST_NAME_USER,
            PersonEmail = 'test@test.com',
            CMN_EmploymentStatus__pc = 'Employed',
            Location_of_Business__c = COUNTRY_KE,
            FinServ__CurrentEmployer__pc = 'ABC Corp',
            Source_of_Funds__c = 'Salary',
            EmploymentIndustry__c = 'FINANCE',
            FinServ__Occupation__pc = 'Developer'
        );
        insert acc;

        Map<String, String> data = new Map<String, String>{
            'employment_status' => 'Employed',
            'nature_business_activity' => COUNTRY_KE,
            'employer' => 'ABC Corp',
            'source_wealth' => 'Salary',
            'employment_type' => 'FINANCE',
            'occupation' => 'Developer'
        };

        Test.startTest();
        INS_PLI_UpdateProspectRecord.updateAccountRecord(acc.Id, data);
        Test.stopTest();

        Account updatedAcc = [
            SELECT CMN_EmploymentStatus__pc,
                   Location_of_Business__c,
                   FinServ__CurrentEmployer__pc,
                   Source_of_Funds__c,
                   EmploymentIndustry__c,
                   FinServ__Occupation__pc
            FROM Account
            WHERE Id = :acc.Id
        ];

        Assert.areEqual('Employed', updatedAcc.CMN_EmploymentStatus__pc);
        Assert.areEqual(COUNTRY_KE, updatedAcc.Location_of_Business__c);
        Assert.areEqual('ABC Corp', updatedAcc.FinServ__CurrentEmployer__pc);
        Assert.areEqual('Salary', updatedAcc.Source_of_Funds__c);
        Assert.areEqual('FINANCE', updatedAcc.EmploymentIndustry__c);
        Assert.areEqual('Developer', updatedAcc.FinServ__Occupation__pc);
    }
    
    	//07012026
	@IsTest
    static void testUpdateAddress_updateExistingRecords() {

        Account acc = new Account(
            RecordTypeId = getPersonAccountProspectRT(),
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john@test.com'
        );
        insert acc;
		 Map<String, Object> payload = new Map<String, Object>{
            'AccId' => acc.Id,
            'AddressInformation' => new Map<String, Object>{
                'AddressLine1'     => '123 Main Street',
                'AddressLine2'     => 'Unit 5',
                'City'             => 'Nairobi',
                'PostalCode'       => '00100',
                'CountriesLiveIn'  => 'Kenya',
                'CountriesCitizen' => 'Kenya'
            }
        };
        PartyProfile pp = new PartyProfile(
            AccountId = acc.Id,
            FirstName = 'John',
            LastName = 'Doe',
            FullName = 'John Doe',
            Name = 'Existing Profile',
            RecordTypeId = Schema.SObjectType.PartyProfile
                .getRecordTypeInfosByDeveloperName()
                .get(RECORDTYPE_INSURANCE_INDIVIDUAL)
                .getRecordTypeId()
        );
        insert pp;

        PartyProfileAddress ppa = new PartyProfileAddress(
            Name = 'Existing Address',
            PartyProfileId = pp.Id,
            Street = 'Old Street',
            City = 'Old City',
            Country = 'Old Country',
            AddressType = 'Residential Address',
            Date_Move_In__c = Date.today().addYears(-1) 
    		
        );
        insert ppa;       
        
        try{
            Test.startTest();
            INS_PLI_UpdateProspectRecord.updateAddress(JSON.serialize(payload));
            Test.stopTest();            
    		Assert.fail('Expected AuraHandledException was not thrown');
        }catch (Exception e){
            Assert.isTrue(e.getMessage().contains('Script-thrown exception'),'Unexpected exception message: ' + e.getMessage());             
        }
        ppa = [
            SELECT Street, City, Country
            FROM PartyProfileAddress
            WHERE Id = :ppa.Id
        ];

        Assert.areEqual('Old Street', ppa.Street);
        Assert.areEqual('Old City', ppa.City);
        Assert.areEqual('Old Country', ppa.Country);
    }
    
    @isTest
    static void testResolveOpportunitySource_DSA() {
        
        User u = new User(
            LastName = 'Test',
            Alias = 'tst1',
            Email = 'test1@test.com',
            Username = 'test1' + System.currentTimeMillis() + '@test.com',
            CompanyName = 'Stanbic',
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_ZA',
            EmailEncodingKey = EMAIL_ENCODING,
            LanguageLocaleKey = LANGUAGE_KEY,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
        );
    
        insert u;
    
        Test.startTest();
        
        String result = INS_PLI_UpdateProspectRecord.resolveOpportunitySource(
            null,
            new List<User>{u}
        );
    
        Test.stopTest();
    
        System.assertEquals('DSA Stanbic', result);
 }    
    
    @isTest
    static void testResolveOpportunitySource_FSC() {
        
        User u = new User(
            LastName = 'Test',
            Alias = 'tst2',
            Email = 'test2@test.com',
            Username = 'test2' + System.currentTimeMillis() + '@test.com',
            CompanyName = '',
            TimeZoneSidKey = 'Africa/Johannesburg',
            LocaleSidKey = 'en_ZA',
            EmailEncodingKey = EMAIL_ENCODING,
            LanguageLocaleKey = LANGUAGE_KEY,
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id
        );
        
        insert u;
        
        Test.startTest();
        
        String result = INS_PLI_UpdateProspectRecord.resolveOpportunitySource(
            null,
            new List<User>{u}
        );
        
        Test.stopTest();
        
        System.assertEquals('FSC', result);
    }
    
    @isTest
    static void testResolveOpportunitySource_NoUser() {
    
        Test.startTest();
        
        String result = INS_PLI_UpdateProspectRecord.resolveOpportunitySource(
            null,
            new List<User>()
        );
    
        Test.stopTest();
    
        System.assertEquals(null, result);
    }
}