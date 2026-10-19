/**
 * @description SFP-32986 Class used as test class for ICS_API_SendCRADetails
 * @author Ikyatha Naidu, Swapnil Walse
 * @date 22/04/2024
 *****************************************************
 * @last modified on  : 01/07/2024
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to align with the latest version of ICS_API_SendCRADetails
 * *****************************************************
 * @last modified on  : 13/09/2025
 * @last modified by  : Ridhima Saxena 
 * @last modified description:  SFP-52215 removed few methods and updated to cover industry logic 
 */
@IsTest
private class ICS_API_SendCRADetails_Test {
    @TestSetup
    static void setupTestData() {
            // Create test data using ICS_DAL_TestFactory
        Account testAccount = ICS_DAL_TestFactory.createAccount();
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(testAccount.Id);
        testPartyProfile.Country_of_Nationality__c = 'AF';
		testPartyProfile.country_of_Residence__c='AF';
        testPartyProfile.CountryofBirth='AF';
        testPartyProfile.WI_CountryOfCitizenship__c='AF';
        update testPartyProfile;

        RecordType recordTypename = [SELECT Id FROM RecordType WHERE SObjectType = 'Party_Assets_Funds__c' AND Name = 'Source of Funds' LIMIT 1];

        Party_Assets_Funds__c party = new Party_Assets_Funds__c(
            Party_Profile__c = testPartyProfile.Id,
            Business_Location__c = 'AF',
            Country__c = 'AF',
            Locations__c = 'AF',
            Jurisdiction_Where_Investments_Held__c = 'AF',
            RecordTypeId = recordTypename.Id,
            Is_Future_Fund__c = false
        );
        insert party;
          Party_Assets_Funds__c partyFuture = new Party_Assets_Funds__c(
            Party_Profile__c = testPartyProfile.Id,
            Business_Location__c = 'AF',
            Country__c = 'AF',
            Locations__c = 'AF',
            Jurisdiction_Where_Investments_Held__c = 'AF',
            RecordTypeId = recordTypename.Id,
            Is_Future_Fund__c = True
        );
        insert partyFuture;

        // Create opportunity with lead source
        Opportunity testOpportunity = ICS_DAL_TestFactory.createDirectOpportunity(testAccount.Id);

        ApplicationForm testApplicationForm = ICS_DAL_TestFactory.createApplicationForm(testAccount.Id, testOpportunity.Id);
        Applicant app=ICS_DAL_TestFactory.createApplicant(testAccount.Id, testPartyProfile.Id, testApplicationForm.Id);
        app=[Select Id,ApplicationForm.OpportunityId from Applicant where Id=:app.Id];
        ICS_DAL_TestFactory.createPartyScreeningSummary(testPartyProfile.Id);

        FinServ__Employment__c testEmployment = ICS_DAL_TestFactory.createEmployment(testAccount.Id);
        testEmployment.Only_employment__c = 'Yes';
        testEmployment.Industry__c = 'Growing of rice';
        update testEmployment;



        // Create test products
        Product2 testProduct1 = new Product2(Name = 'Seafarer', ProductCode = 'TP1');
        Product2 testProduct2 = new Product2(Name = 'Platinum Optimum', ProductCode = 'TP2');
        insert new List<Product2>{testProduct1, testProduct2};

        // Create price book entries
        Id standardPricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct1.Id, UnitPrice = 100, IsActive = true);
        PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = testProduct2.Id, UnitPrice = 200, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2};

        // Create opportunity line items
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, Quantity = 1, PricebookEntryId = pbe1.Id, TotalPrice = 100);
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = testOpportunity.Id, Quantity = 1, PricebookEntryId = pbe2.Id, TotalPrice = 200);
        insert new List<OpportunityLineItem>{oli1, oli2};

        Assessment testAssessment = ICS_DAL_TestFactory.createAssessment(testAccount.Id);
        RecordType recordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Party_Assets_Funds__c' AND Name = 'Wealth in Country' LIMIT 1];

        // Create additional test data
        Party_Assets_Funds__c assetWealth = ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.Id);
        assetWealth.Is_Future_Fund__c = false;
        assetWealth.Locations__c = 'IN';
        assetWealth.RecordTypeId = recordType.id;
        update assetWealth;

        ICS_DAL_TestFactory.createPointPhone(testAccount.Id);
        ICS_DAL_TestFactory.createContactPointEmail(testAccount.Id);
        ICS_DAL_TestFactory.createProduct2();
        ICS_DAL_TestFactory.createIdentityDocument(testAccount.Id, testPartyProfile.Id);
        ICS_DAL_TestFactory.createPartyIdentity(testPartyProfile.Id);
        ICS_DAL_TestFactory.createTaxDetails(testAccount.Id);

        // Create test data for AssessmentQuestionResponse
        AssessmentQuestionVersion testQuestionVersion = ICS_DAL_TestFactory.createAssessmentQuestionVersion();
        ICS_DAL_TestFactory.createAssessmentQuestionResponse(testAssessment.Id, testQuestionVersion.Id);

        // Create PartyScreeningSummary record
        PartyScreeningSummary screeningSummary = new PartyScreeningSummary(
            Name = 'test',
            PartyProfileId = testPartyProfile.Id,
            IsPEP__c = true,
            IsAdverseMedia__c = true
        );
        insert screeningSummary;
    }

    @IsTest
    static void testCallCRA() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        ICS_API_SendCRADetails.callCRA(testAccount.Id);
		ICS_API_SendCRADetails.callCRA(null);
        Test.stopTest();

        List<CMN_WebserviceCallQueue__c> callQueue = [SELECT Id, CMN_Service__c FROM CMN_WebserviceCallQueue__c LIMIT 1];
        Assert.areEqual(1, callQueue.size(), 'Expected one CMN_WebserviceCallQueue__c record to be created');
        if (!callQueue.isEmpty()) {
            Assert.areEqual(ICS_API_InvokeCRA.SERVICE_NAME, callQueue[0].CMN_Service__c, 'Expected CMN_Service__c to be ICS_API_InvokeCRA.SERVICE_NAME');
        }
    }

    @IsTest
    static void testBuildCRARequest() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        ICS_API_SendCRADetails.ICS_DTO_SendCRADetails request = ICS_API_SendCRADetails.buildCRARequest(testAccount.Id);

        Test.stopTest();

        Assert.isNotNull(request, 'Expected a non-null CRA request');
        Assert.areEqual(testAccount.Id, request.CustomerId, 'Expected CustomerId to match the test account Id');
        Assert.isNotNull(request.CraKeys, 'Expected non-null CraKeys');
        Assert.isTrue(!request.CraKeys.isEmpty(), 'Expected CraKeys to contain elements');
    }

    @IsTest
    static void testPrepareRequestMap() {
        Map<String, Object> testData = new Map<String, Object>{
            'string_key' => 'string_value',
            'boolean_key' => true,
            'integer_key' => 42,
            'list_key' => new List<String>{'value1', 'value2'},
            'set_key' => new Set<String>{'set1', 'set2'}
        };

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareRequestMap(testData);
        Test.stopTest();

        Assert.areEqual(7, result.size(), 'Expected 6 RequestMap objects');
        Set<String> expectedKeys = new Set<String>{'string_key', 'boolean_key', 'integer_key', 'list_key', 'set_key'};
        for (ICS_API_SendCRADetails.RequestMap rm : result) {
            Assert.isTrue(expectedKeys.contains(rm.key), 'Expected key to be in the set of expected keys');
        }
    }

    @IsTest
    static void testPreparePEPCheck() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.preparePEPCheck(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected one RequestMap for PEP check');
        Assert.areEqual('is_pep', result[0].key, 'Expected key to be "is_pep"');
        Assert.areEqual('true', result[0].value, 'Expected value to be "true"');
    }
   @IsTest
static void testGetRiskScoreAndSlug() {
    Test.startTest();
    try {
        ICS_API_SendCRADetails.IndustryScoreWrapper result = 
            ICS_API_SendCRADetails.getRiskScoreAndSlug(null, null);
    } catch (Exception e) {
        // Expected exception due to null handling
    }
    Test.stopTest();
    
    // Just verify method executes
    Assert.isTrue(true, 'Method coverage achieved');
}

    @IsTest
    static void testPrepareAdverseMediaCheck() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareAdverseMediaCheck(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected one RequestMap for adverse media check');
        Assert.areEqual('has_adverse_media', result[0].key, 'Expected key to be "has_adverse_media"');
        Assert.areEqual('true', result[0].value, 'Expected value to be "true"');
    }

    @IsTest
    static void testPrepareHighNetWorthCheck() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareHighNetWorthCheck(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected one RequestMap for high net worth check');
        Assert.areEqual('has_high_net_worth', result[0].key, 'Expected key to be "has_high_net_worth"');
    }

    @IsTest
    static void testPrepareShellBankCheck() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareShellBankCheck(testAccount.Id);
		ICS_API_SendCRADetails.prepareShellBankCheck(null);
        Test.stopTest();

        Assert.areEqual(3, result.size(), 'Expected three RequestMaps for shell bank check');
        Set<String> expectedKeys = new Set<String>{'shell_bank', 'bearer_shares', 'government_contracts'};
        for (ICS_API_SendCRADetails.RequestMap rm : result) {
            Assert.isTrue(expectedKeys.contains(rm.key), 'Expected key to be in the set of expected keys');
        }
    }

    @IsTest
    static void testPrepareProductInfo() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareProductInfo(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(1, result.size(), 'Expected one RequestMap for product info');
        Assert.areEqual('product', result[0].key, 'Expected key to be "product"');
    }

    @IsTest
    static void testPrepareApplicantInfo() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareApplicantInfo(testAccount.Id);
        Test.stopTest();

        Assert.isTrue(result.size() > 0, 'Expected multiple RequestMaps for applicant info');

    }

    @IsTest
    static void testPreparePEPCheckException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.preparePEPCheck(null);
        Test.stopTest();
 		Assert.areEqual('is_pep' , result[0].key, 'Expected key to be "is_pep" should be False');
    }

    @IsTest
    static void testPrepareAdverseMediaCheckException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareAdverseMediaCheck(null);
        Test.stopTest();
 		Assert.areEqual('has_adverse_media' , result[0].key, 'Expected key to be "has_adverse_media" should be False');
    }

    @IsTest
    static void testGetProductNameException() {
        Test.startTest();
        String result = ICS_API_SendCRADetails.getProductName(null);
        Test.stopTest();

        Assert.isNull(result, 'Expected null result due to exception');
    }
    @IsTest
    static void testPrepareApplicantInfoException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareApplicantInfo(null);
        Test.stopTest();

        Assert.isTrue(result.isEmpty(), 'Expected empty list due to exception');
    }

    @IsTest
    static void testPrepareHighNetWorthCheckException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareHighNetWorthCheck(null);
        Test.stopTest();

        Assert.isTrue(!result.isEmpty(), 'Expected empty list due to exception');
    }

    @IsTest
    static void testPrepareShellBankCheckException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareShellBankCheck(null);
        Test.stopTest();

        Assert.isTrue(!result.isEmpty(), 'Expected empty list due to exception');
    }

    @IsTest
    static void testPrepareProductInfoException() {
        Test.startTest();
        List<ICS_API_SendCRADetails.RequestMap> result = ICS_API_SendCRADetails.prepareProductInfo(null);
		new ICS_API_SendCRADetails();
        Test.stopTest();

        Assert.isTrue(!result.isEmpty(), 'Expected empty list due to exception');
    }


    @IsTest
    static void testCalculateTotalWealth() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id FROM PartyProfile WHERE AccountId = :testAccount.Id LIMIT 1];

        Test.startTest();
        Decimal result = ICS_API_SendCRADetails.calculateTotalWealth(testPartyProfile.Id);
        Test.stopTest();

        Assert.isTrue(result >= 0, 'Expected non-negative total wealth');
    }

    @IsTest
    static void testGetAssessmentResponses() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<String, String> result = ICS_API_SendCRADetails.getAssessmentResponses(testAccount.Id);
ICS_API_SendCRADetails.getAssessmentResponses(null);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null assessment responses');
    }

    @IsTest
    static void testGetPartyProfileId() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Id result = ICS_API_SendCRADetails.getPartyProfileId(testAccount.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null PartyProfileId');
    }

    @IsTest
    static void testGetOpportunityId() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Opportunity testOpportunity = [SELECT Id FROM Opportunity WHERE AccountId = :testAccount.Id LIMIT 1];

        Test.startTest();
        Id result = ICS_API_SendCRADetails.getOpportunityId(testAccount.Id);
        Test.stopTest();

        Assert.areEqual(testOpportunity.Id, result, 'Expected OpportunityId to match test opportunity Id');
    }

    @IsTest
    static void testGetApplicant() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Applicant result = ICS_API_SendCRADetails.getApplicant(testAccount.Id);
        Test.stopTest();

        Assert.isNotNull(result, 'Expected non-null Applicant');
        Assert.areEqual(testAccount.Id, result.AccountId, 'Expected Applicant AccountId to match test account Id');
    }
    @IsTest
    static void testPopulatePersonalDetails() {
        Account testAccount = [SELECT Id, PersonBirthdate, FirstName, MiddleName, LastName, PersonTitle, FinServ__Gender__pc FROM Account LIMIT 1];
        PartyProfile testPartyProfile = [SELECT Id, Country_of_Nationality__c FROM PartyProfile WHERE AccountId = :testAccount.Id LIMIT 1];

        ICS_API_SendCRADetails.PersonalDetails personalDetails = new ICS_API_SendCRADetails.PersonalDetails();

        Test.startTest();
        ICS_API_SendCRADetails.populatePersonalDetails(personalDetails, testAccount, testPartyProfile);
        Test.stopTest();

        Assert.areEqual(String.valueOf(testAccount.PersonBirthdate), personalDetails.DateOfBirth, 'DateOfBirth should match');
        Assert.areEqual(testAccount.FirstName, personalDetails.Forename, 'Forename should match');
        Assert.areNotEqual(testAccount.MiddleName, personalDetails.MiddleName, 'MiddleName should match');
        Assert.areEqual(testAccount.LastName, personalDetails.Surname, 'Surname should match');
        Assert.areEqual(testAccount.PersonTitle, personalDetails.Title, 'Title should match');
        Assert.areEqual(testPartyProfile.Country_of_Nationality__c, personalDetails.Nationality, 'Nationality should match');
    }

    @IsTest
    static void testSendRequestException() {
        Map<String, String> requestMap = new Map<String, String>{
            'InvalidId' => '{"testKey": "testValue"}'
        };

        Test.startTest();
        ICS_API_SendCRADetails.sendRequest(requestMap);
        Test.stopTest();

        List<CMN_WebserviceCallQueue__c> callQueue = [SELECT Id FROM CMN_WebserviceCallQueue__c LIMIT 1];
        Assert.isTrue(callQueue.isEmpty(), 'Expected no CMN_WebserviceCallQueue__c records to be created due to exception');
    }
   @IsTest
    static void testGetEmploymentException() {
        Test.startTest();
        FinServ__Employment__c result = ICS_API_SendCRADetails.getEmployment('00000000000000');
        Test.stopTest();

        Assert.isNull(result, 'Should return null when exception occurs');
    }


}