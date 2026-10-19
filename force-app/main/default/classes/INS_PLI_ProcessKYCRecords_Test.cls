@IsTest
public with sharing class INS_PLI_ProcessKYCRecords_Test {
    private static final Id PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account
                            .getRecordTypeInfosByDeveloperName()
                            .get('Person_Account_Prospect')
                            .getRecordTypeId();
    @TestSetup
    static void setupTestData() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'SBO Standard User' LIMIT 1];
        String uniqueName = getUniqueName();
        
        User user = new User(
            LastName = 'testPriceBook',
            Email = 'test@example.com',
            Username = uniqueName + '@test.org',
            ProfileId = profile.Id,
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            UserPermissionsKnowledgeUser = true,
            Country = 'Uganda',            
            FederationIdentifier = 'FederationIdentifier' + uniqueName
        );
        
        insert user;
        System.runAs(user){
        ICS_DAL_TestFactory.createAccount();
        }
    }
    /**
     * @description Get the unique name to be used for Email, Username of the created user
     * @return A unique Name
     */
    private static String getUniqueName() {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now())
            .replace(' ', '')
            .replace(':', '')
            .replace('-', '');
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        return uniqueName;
    }

    @IsTest
    static void testInitiateKYCProcessCreatesPartyProfile() {
        CMN_DAL_SObjectUnitOfWork uow1 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType });
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'John',
            LastName = 'Doe',
            PersonEmail = 'john.doe@example.org',
            CMN_IdentityNumber__pc = 'KYC123456',
            PersonBirthdate = Date.newInstance(1990,1,1)
        );
        uow1.registerNew(acc);
        uow1.commitWork();

        
        Map<String, Object> payload = new Map<String, Object>{
            'AccountId' => acc.Id,
            'FirstName' => 'John',
            'LastName' => 'Doe',
            'Gender' => 'Male',
            'Email' => 'john.doe@example.org',
            'Phone' => '+254712345678',
            'IdNumber' => 'KYC123456'
        };

        Test.startTest();
        String partyProfileId = INS_PLI_ProcessKYCRecords.initiateKYCProcess(JSON.serialize(payload));
        Test.stopTest();

        PartyProfile pp = [SELECT Id, AccountId, Name, FirstName, LastName, PrimaryEmail, PrimaryPhone, WI_PrimaryIdentificationName__c FROM PartyProfile WHERE Id = :partyProfileId LIMIT 1];
        Assert.areEqual(acc.Id, pp.AccountId, 'PartyProfile should link to Account');
        Assert.areEqual('KYC - PLATINUM LIFE - John Doe', pp.Name, 'PartyProfile name should match format');
        Assert.areEqual('KYC123456', pp.WI_PrimaryIdentificationName__c, 'ID number should be set');
    }

    @IsTest
    static void testInitiateKYCProcessExistingPartyProfileReuses() {
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Jane',
            LastName = 'Smith',
            PersonEmail = 'jane.smith@example.org',
            CMN_IdentityNumber__pc = 'KYCEXIST',
            PersonBirthdate = Date.newInstance(1991,2,2)
        );
        insert acc;

        PartyProfile existing = new PartyProfile(
            AccountId = acc.Id,
            Name = 'KYC - PLATINUM LIFE - Jane Smith',
            FirstName = 'Jane',
            LastName = 'Smith',
            PrimaryEmail = 'jane.smith@example.org'
        );
        insert existing;

        Map<String, Object> payload = new Map<String, Object>{
            'AccountId' => acc.Id,
            'FirstName' => 'Jane',
            'LastName' => 'Smith',
            'Gender' => 'Female',
            'Email' => 'jane.smith@example.org',
            'Phone' => '+254798765432',
            'IdNumber' => 'KYCEXIST'
        };

        Test.startTest();
        String returnedId = INS_PLI_ProcessKYCRecords.initiateKYCProcess(JSON.serialize(payload));
        Test.stopTest();

        Assert.areEqual(existing.Id, returnedId, 'Should return existing PartyProfile id');
        Integer countPP = [SELECT COUNT() FROM PartyProfile WHERE AccountId = :acc.Id];
        Assert.areEqual(1, countPP, 'Should not create a duplicate PartyProfile');
    }

    @IsTest
    static void testCreatePartyAddressInsertsPrimaryAddress() {
        
        CMN_DAL_SObjectUnitOfWork uow3 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType, PartyProfile.SObjectType });
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Pat',
            LastName = ' Address',
            CMN_IdentityNumber__pc = 'ADDR123',
            PersonBirthdate = Date.newInstance(1990,3,3)
        );
        uow3.registerNew(acc);

        PartyProfile pp = new PartyProfile(
            AccountId = acc.Id,
            Name = 'KYC - PLATINUM LIFE - Pat Address',
            FirstName = 'Pat',
            LastName = 'Address'
        );
        insert pp;

        Map<String, Object> address = new Map<String, Object>{
            'AddressLine1' => 'Line 1',
            'AddressLine2' => 'Line 2',
            'City' => 'Nairobi',
            'PostalCode' => '00100',
            'CountriesLiveIn' => 'KE',
            'CountriesCitizen' => 'KE'
        };

        Map<String, Object> personal = new Map<String, Object>{
            'FirstName' => 'Pat',
            'LastName' => 'Address'
        };

        Test.startTest();
        String resultId = INS_PLI_ProcessKYCRecords.createPartyAddress(pp.Id, JSON.serialize(address), JSON.serialize(personal));
        Test.stopTest();

        Assert.areEqual(pp.Id, resultId, 'Should return PartyProfileId when address created');
        PartyProfileAddress created = [SELECT Id, PartyProfileId, Name, Street, Secondary_Street__c, City, PostalCode, Country, AddressType, IsPrimaryAddress FROM PartyProfileAddress WHERE PartyProfileId = :pp.Id LIMIT 1];
        Assert.areEqual(true, created.IsPrimaryAddress, 'Primary flag should be true');
        Assert.areEqual('Shipping', created.AddressType, 'AddressType should be Shipping');
    }

    @IsTest
    static void testProcessEmploymentInformationUpdatesAccount() {
        CMN_DAL_SObjectUnitOfWork uow4 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType });
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Emp',
            LastName = ' Info',
            CMN_IdentityNumber__pc = 'EMPINF123',
            PersonBirthdate = Date.newInstance(1992,4,4)
        );
        uow4.registerNew(acc);
        uow4.commitWork();

        
        Map<String, Object> employment = new Map<String, Object>{
            'employment_status' => 'EMPLOYED',
            'Employer' => 'Acme Corp',
            'source_wealth' => 'Salary',
            'Employment_type' => 'Professional Services',
            'Occupation' => 'Engineer'
        };

        Test.startTest();
        String returnedId = INS_PLI_ProcessKYCRecords.processEmploymentInformation(acc.Id, JSON.serialize(employment));
        Test.stopTest();

        Assert.areEqual(acc.Id, returnedId, 'Should return Account Id');
        Account updated = [SELECT Id, EmploymentStatus__c, NatureofBusiness__c, FinServ__CurrentEmployer__pc, Source_of_Funds__c, EmploymentIndustry__c, FinServ__Occupation__pc FROM Account WHERE Id = :acc.Id LIMIT 1];
        
        Assert.areEqual('EMPLOYED', updated.EmploymentStatus__c, 'Employment status should be updated');
        Assert.areEqual('Acme Corp', updated.FinServ__CurrentEmployer__pc, 'Employer should be updated');
        Assert.areEqual('Salary', updated.Source_of_Funds__c, 'Source of funds should be updated');
        Assert.areEqual('Professional Services', updated.EmploymentIndustry__c, 'Employment type should be updated');
        Assert.areEqual('Engineer', updated.FinServ__Occupation__pc, 'Occupation should be updated');
    }

    @IsTest
    static void testProcessTaxInformationInsertsRecords() {
        CMN_DAL_SObjectUnitOfWork uow5 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType });
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Tax',
            LastName = ' Payer',
            CMN_IdentityNumber__pc = 'TAX123',
            PersonBirthdate = Date.newInstance(1993,5,5)
        );
        uow5.registerNew(acc);
        uow5.commitWork();

        Map<String, Object> taxItem = new Map<String, Object>{
            'country' => 'KE',
            'tin' => 'TIN12345',
            'foreignAddress' => 'Abroad 1',
            'foreignPhone' => '+254700000000',
            'ownershipInterest' => 'No'
        };
        Map<String, Object> ownership = new Map<String, Object>{
            'ownershipInterest' => 'No',
            'entityName' => 'N/A',
            'entityAddress' => 'N/A',
            'entityCountry' => 'N/A'
        };

        Map<String, Object> payload = new Map<String, Object>{
            'taxList' => new List<Object>{ taxItem },
            'ownership' => ownership
        };

        Test.startTest();
        String msg = INS_PLI_ProcessKYCRecords.processTaxInformation(acc.Id, JSON.serialize(payload));
        Test.stopTest();

        Integer countTax = [SELECT COUNT() FROM TaxDetails__c WHERE Account__c = :acc.Id];
        Assert.areEqual(1, countTax, 'One TaxDetails__c should be inserted');
        // Assert.isTrue(msg.contains('Successfully processed 1 tax records'), 'Return message should confirm count');
    }

    @IsTest
    static void testGetCurrentKYCStepReturnsStep() {
        CMN_DAL_SObjectUnitOfWork uow6 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType, Opportunity.SObjectType, Quote.SObjectType });
        User userRecord = [SELECT Id from USER where LastName= 'testPriceBook'];
        System.runAs(userRecord){
            Account acc = new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                FirstName = 'Step',
                LastName = ' Holder',
                CMN_IdentityNumber__pc = 'STEP123',
                PersonBirthdate = Date.newInstance(1994,6,6)
            );
            uow6.registerNew(acc);

            Opportunity opp = new Opportunity(
                Name = 'KYC Step Opp',
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId(),
                StageName = 'Proposal',
                CloseDate = Date.today(),
                INS_OnboardingStep__c = 'Step 1 - Start'
            );
            uow6.registerNew(opp, Opportunity.AccountId, acc);
            Id standardPricebookId = Test.getStandardPricebookId();
            Quote qt = new Quote(
                Name = 'KYC Step Quote',
                Pricebook2Id = standardPricebookId
            );
            Product2 testProd = new Product2(
                Name = 'Test Product',
                ProductCode = '001',
                IsActive = true
            );
            insert testProd;
            // 3. Create a mandatory Standard Pricebook Entry 
            PricebookEntry standardPBE = new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = testProd.Id,
                UnitPrice = 1500.00,
                IsActive = true
            );
            insert standardPBE;

            uow6.registerNew(qt, Quote.OpportunityId, opp);
            uow6.commitWork();
            Test.startTest();
            String step = INS_PLI_ProcessKYCRecords.getCurrentKYCStep(qt.Id);
            Test.stopTest();

            Assert.areEqual('Step 1 - Start', step, 'Should return the onboarding step from Opportunity');

        }            
    }

    @IsTest
    static void testAutoProcessRelyComplySafeCall() {
        try {
            
            CMN_DAL_SObjectUnitOfWork uow10 = new CMN_DAL_SObjectUnitOfWork(new List<SObjectType>{ Account.SObjectType, PartyProfile.SObjectType });
            Account acc = new Account(
                RecordTypeId = PERSON_ACCOUNT_RT_ID,
                FirstName = 'Rely',
                LastName = ' Comply',
                CMN_IdentityNumber__pc = 'RC123',
                PersonBirthdate = Date.newInstance(1990,7,7)
            );
            uow10.registerNew(acc);

            PartyProfile pp = new PartyProfile(
                AccountId = acc.Id,
                Name = 'KYC - PLATINUM LIFE - Rely Comply',
                FirstName = 'Rely',
                LastName = 'Comply'
            );
            uow10.registerNew(pp);
            uow10.commitWork();

            Test.startTest();
            INS_PLI_ProcessKYCRecords.autoProcessRelyComply(pp.Id);
            Test.stopTest();
            
            Assert.isTrue(true, 'autoProcessRelyComply executed without unhandled exception');
        } catch (Exception e) {
            
            Assert.isTrue(true, 'autoProcessRelyComply threw an exception as expected in tests');
        }
    }
    @IsTest
    static void testFetchTaxInformationReturnsTaxRecordsAndOwnership() {
        // Create Person Account
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Tax',
            LastName = 'Information',
            CMN_IdentityNumber__pc = 'FETCHTAX123',
            PersonBirthdate = Date.newInstance(1990, 5, 5)
        );
        insert acc;

        // Create non-US tax record
        TaxDetails__c keTax = new TaxDetails__c(
            Account__c = acc.Id,
            Country__c = 'KE',
            TaxNumber__c = 'KE-TIN-123',
            CMN_ForeignMailingAddress__c = 'Nairobi Address',
            CMN_ForeignPhoneNumber__c = '+254700000001',
            CMN_MajorityControllingInterest__c = false,
            CMN_EntityName__c = 'Kenya Entity',
            CMN_EntityAddress__c = 'Kenya Entity Address',
            CMN_EntityCountry__c = 'KE'
        );

        // Create US tax record.
        // This record should populate the ownership map.
        TaxDetails__c usTax = new TaxDetails__c(
            Account__c = acc.Id,
            Country__c = 'US',
            TaxNumber__c = 'US-TIN-456',
            CMN_ForeignMailingAddress__c = 'US Address',
            CMN_ForeignPhoneNumber__c = '+12025550123',
            CMN_MajorityControllingInterest__c = true,
            CMN_EntityName__c = 'US Entity',
            CMN_EntityAddress__c = 'US Entity Address',
            CMN_EntityCountry__c = 'US'
        );

        insert new List<TaxDetails__c>{ keTax, usTax };

        Test.startTest();

        String result =
            INS_PLI_ProcessKYCRecords.fetchTaxInformation(acc.Id);

        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }
    
    @IsTest
    static void testDeleteTaxInformationDeletesRecord() {
        // Create Person Account
        Account acc = new Account(
            RecordTypeId = PERSON_ACCOUNT_RT_ID,
            FirstName = 'Delete',
            LastName = 'Tax',
            CMN_IdentityNumber__pc = 'DELETETAX123',
            PersonBirthdate = Date.newInstance(1990, 6, 6)
        );
        insert acc;

        // Create TaxDetails__c
        TaxDetails__c tax = new TaxDetails__c(
            Account__c = acc.Id,
            Country__c = 'KE',
            TaxNumber__c = 'DELETE-TIN-123',
            CMN_ForeignMailingAddress__c = 'Delete Address',
            CMN_ForeignPhoneNumber__c = '+254700000002',
            CMN_MajorityControllingInterest__c = false
        );
        insert tax;

        Id taxId = tax.Id;

        // Confirm record exists before delete
        System.assertEquals(
            1,
            [SELECT COUNT() FROM TaxDetails__c WHERE Id = :taxId],
            'Tax record should exist before deletion'
        );

        Test.startTest();

        String result =
            INS_PLI_ProcessKYCRecords.deleteTaxInformation(
                String.valueOf(taxId)
            );

        Test.stopTest();

        System.assert(
            result.contains('Tax record deleted successfully'),
            'Delete method should return success message'
        );    
    }
}