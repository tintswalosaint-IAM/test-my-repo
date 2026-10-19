/*************************************************************
 * @description SFP-43424 Class used to test ICS_API_SAPCreateCustomer
 *
 * @author Ruchi Agarwal
 *
 * @date OCT 21 2024
 ***************************************************************
 * Last Modified By  Ruchi Agarwal
 * Last Modified Date 21/10/2024
 * Last Modified Description: updated to latest Version

 * Last Modified By  Ridhima Saxena
 * Last Modified Date 05-06-2025
 * Last Modified Description:  updated testFormatNeighborhoodParish for test coverage
 ***************************************************************
 * @Last Modified By  : Ridhima Saxena
 * @Last Modified On  : 01-11-2025
 * @Last Modified Description  :SFP-53863 Updated code to cover address mapping logic
 *
 * @Last Modified By  : Calvin Moodley
 * @Last Modified On  : 01-04-2026
 * @Last Modified Description  : Added tests to push coverage above 85%:
 *   - testCreateCustomerRequestJoint (joint account flow)
 *   - testBuildPartyRelationships (public static method)
 *   - testGetCountryCodeMap (public static method)
 *   - testCreateCustomerWithRiskCategory (PartyProfileRisk grade mapping)
 ***************************************************************
 * @Last Modified By  : Ridhima Saxena
 * @Last Modified On  : 29-07-2026
 * @Last Modified Description  : SFP- 59113 Added testToCamelCase and security question
 *   coverage tests for the AdditionalData security-question category mapping
 */
@isTest
public class ICS_API_SAPCreateCustomer_TEST {
    @TestSetup
    static void setupData() {
        Account acc = createTestAccount();
        Opportunity testOpportunity = createTestOpportunity(acc.Id);
        List<Product2> products = createTestProducts();
        List<PricebookEntry> pricebookEntries = createPricebookEntries(products);
        createOpportunityLineItems(testOpportunity.Id, pricebookEntries);
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        createAndUpdatePartyProfile(acc.Id);
        ApplicationForm form = createApplicationForm(acc.Id, testOpportunity.Id);
        createContactPointPhones(acc.Id);
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(acc.Id);
        profile.PrimaryIdentifierType='Passport Number';
        update profile;
        PartyProfile ptData = ICS_DAL_TestFactory.createPartyProfile(acc.id);
        ptData.Country_of_Residence__c = 'IN';
        ptData.Country_of_Nationality__c = 'IN';
        ptData.WI_CountryOfCitizenship__c = 'IN';
        ptData.CountryofBirth = 'IN';
        ptData.PrimaryIdentifier = 'ASD123';
        ptData.PrimaryIdentifierType = 'Passport Number';
        update ptData;
        
        PartyProfileAddress addr = ICS_DAL_TestFactory.createPartyProfileAddress(ptData.id, 'Residential Address', date.today(), null);
        addr.Street = 'Test Street';
        addr.City = 'Test City';
        addr.State = 'Test State';
        addr.PostalCode = '500001';
        addr.Country = 'India';
        update addr;
        createApplicant(acc.Id, profile.Id, form.Id);
        createPartyProfileAddress(profile.Id);
        createEmploymentRecord(acc.Id);
        createTaxDetails(acc.Id);
        createAOBReferencedData();
    }
    
    private static Account createTestAccount() {
        Account acc = new Account(
        FirstName = 'Testing Name Customers Testing',
        LastName = 'Customer Name Customers Testing',
        PersonEmail = 'test@test.com',
        PersonBirthdate = Date.today().addYears(-30),
        PersonTitle = 'Mr.',
        MiddleName = 'Middle',
        FinServ__Gender__pc = 'Male',
        FinServ__MaritalStatus__pc = 'Single'
            );
        
        insert acc;
        return acc;
    }
    
    private static Opportunity createTestOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(
        Name = 'Test Opportunity',
        StageName = 'Prospecting',
        AccountId = accountId,
        CloseDate = Date.today().addDays(30)
            );
        insert opp;
        
        return opp;
    }
    private static List<Product2> createTestProducts() {
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Seafarer', ProductCode = 'CURR_SEA'),
            new Product2(Name = 'Platinum Optimum', ProductCode = 'CURR_POPT')
        };
        insert products;
        return products;
    }
    
    private static List<PricebookEntry> createPricebookEntries(List<Product2> products) {
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> entries = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = products[0].Id, UnitPrice = 100, IsActive = true),
            new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = products[1].Id, UnitPrice = 200, IsActive = true)
        };
        insert entries;
        return entries;
    }
    
    private static void createOpportunityLineItems(Id opportunityId, List<PricebookEntry> pricebookEntries) {
        List<OpportunityLineItem> lineItems = new List<OpportunityLineItem>{
            new OpportunityLineItem(OpportunityId = opportunityId, Quantity = 1, PricebookEntryId = pricebookEntries[0].Id, TotalPrice = 100),
            new OpportunityLineItem(OpportunityId = opportunityId, Quantity = 1, PricebookEntryId = pricebookEntries[1].Id, TotalPrice = 200)
        };
        insert lineItems;
        
    }
    
    private static PartyProfile createAndUpdatePartyProfile(Id accountId) {
        PartyProfile pData = ICS_DAL_TestFactory.createPartyProfile(accountId);
        pData.Country_of_Residence__c = 'IN';
        update pData;
        ICS_DAL_TestFactory.createPartyProfileAddress(pData.Id, 'Residential Address', Date.today(), null);
        return pData;
    }
    
    private static ApplicationForm createApplicationForm(Id accountId, Id opportunityId) {
        ApplicationForm form = ICS_DAL_TestFactory.createApplicationForm(accountId);
        form.OpportunityId = opportunityId;
        update form;
        return form;
    }
    
    private static void createContactPointPhones(Id accountId) {
        List<ContactPointPhone> phones = new List<ContactPointPhone>{
            new ContactPointPhone(ParentId = accountId, TelephoneNumber = '1234567890', IsPrimary = true),
            new ContactPointPhone(ParentId = accountId, TelephoneNumber = '0987654321', IsPrimary = false)
        };
        insert phones;
    }
    
    private static void createApplicant(Id accountId, Id profileId, Id formId) {
        Applicant app = new Applicant(
        AccountId = accountId,
        PartyProfileId = profileId,
        Role = '',
        ApplicationFormId = formId
            );
        insert app;
    }
    
    private static void createPartyProfileAddress(Id profileId) {
        PartyProfileAddress address = new PartyProfileAddress(
        PartyProfileId = profileId,
        AddressType = 'Residential Address',
        Date_Move_In__c = Date.today(),
        Apartment_Number__c = '123',
        Building_Name__c = 'Test Building',
        Secondary_Street__c = 'Test Street',
        Sub_Building__c = 'Test Sub Building',
        Neighbourhood__c = 'Test Area',
        PostalCode = '12345',
        Country = 'Test Country',
        District__c = 'Test District',
        State = 'Test State',
        City = 'Test City',
        Name = 'Address'
            );
        insert address;
    }
    
    private static void createEmploymentRecord(Id accountId) {
        FinServ__Employment__c employment = new FinServ__Employment__c(
        Person_Account__c = accountId,
        Name = 'Test Employer',
        FinServ__StartDate__c = Date.today().addYears(-5)
            );
        insert employment;
    }
    
    private static void createTaxDetails(Id accountId) {
        TaxDetails__c taxDetails = new TaxDetails__c(
        Account__c = accountId,
        Jurisdiction_of_Tax_Residence__c = 'IN',
        TaxNumber__c = '123456789'
            );
        insert taxDetails;
    }
    
    private static void createAOBReferencedData() {
        AOB_ReferencedData__c parentRecord = new AOB_ReferencedData__c(
            Name = 'ICS_SAP_CREATE_CUSTOMER_DATA'
            );
        insert parentRecord;
        
        Map<String, String> referenceMap = new Map<String, String>{
            'EndDate' => '9999-12-31',
            'identificationType' => 'PASSPORT',
            'channelID' => 'TEST_CHANNEL',
            'UserID' => 'TEST_USER',
            'referenceID' => 'TEST_REF',
            'OriginatingChannel' => 'TEST_ORIG_CHANNEL',
            'OriginatingProcess' => 'TEST_ORIG_PROCESS',
            'ZSBO' => 'TEST_ZSBO',
            'ZSEC' => 'TEST_ZSEC',
            'PartnerCategory' => 'TEST_PARTNER_CAT',
            'PartnerType' => 'TEST_PARTNER_TYPE',
            'DataOriginTypeCode' => 'TEST_ORIGIN',
            'CommunicationTypeCode' => 'TEST_COMM',
            'AccountHolder' => 'TEST_ACCOUNT_HOLDER',
            'CorrespondenceRecipient' => 'TEST_CORR_RECIPIENT',
            'CardHolder' => 'TEST_CARD_HOLDER',
            'ContractPartner' => 'TEST_CONTRACT_PARTNER',
            'Counterparty' => 'TEST_COUNTERPARTY'
        };
        
        List<AOB_ReferencedData__c> referencedDataList = new List<AOB_ReferencedData__c>();
        for(String key : referenceMap.keySet()) {
            referencedDataList.add(new AOB_ReferencedData__c(
            Name = key,
            AOB_Code__c = referenceMap.get(key),
            AOB_Parent__c = parentRecord.Id
                ));
        }
        insert referencedDataList;
    }
    
    
    
    @isTest
    static void testCreateCustomerRequest() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        String jsonResult = ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, false);
        Test.stopTest();
        
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        Assert.areNotEqual(null, resultMap, 'JSON result should not be null');
        
        List<Object> partyList = (List<Object>)resultMap.get('Party');
        Assert.areNotEqual(null, partyList, 'Party list should not be null');
        Assert.areNotEqual(0, partyList.size(), 'Party list should not be empty');
    }
    
    @isTest
    static void testGenerateGUID() {
        Test.startTest();
        String guid = ICS_API_SAPCreateCustomer.generateGUID();
        Test.stopTest();
        
        Assert.areEqual(36, guid.length(), 'GUID should be 36 characters long');
        Assert.areEqual(4, guid.countMatches('-'), 'GUID should contain 4 hyphens');
    }
    
    @isTest
    static void testGenerateJSON() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        
        ICS_API_SAPCreateCustomer.isJoint = false;
        
        Test.startTest();
        String result = ICS_API_SAPCreateCustomer.generateJSON(testAcc.Id);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Should return JSON string');
    }
    
    @isTest
    static void testGetCustomMetaData() {
        Test.startTest();
        ics_customlabel__mdt result = ICS_API_SAPCreateCustomer.getCustomMetaData();
        Test.stopTest();
        if (result != null) {
            Assert.areEqual('Ics_Custom_SAPCreateCustomerData', result.DeveloperName, 'Developer name should match');
        }
        Assert.isTrue(result == null || result.DeveloperName == 'Ics_Custom_SAPCreateCustomerData',
        'Should return null or expected record');
    }
    
    @isTest
    static void testParseCustomMetadataJson() {
        // Create mock metadata with JSON content
        ics_customlabel__mdt mockMetadata = new ics_customlabel__mdt();
        mockMetadata.Description__c = '{"key1":"value1","key2":"value2","key3":123,"key4":true}';
        
        Test.startTest();
        Map<String, String> result = ICS_API_SAPCreateCustomer.parseCustomMetadataJson(mockMetadata);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(4, result.size(), 'Should have 4 keys');
        Assert.areEqual('value1', result.get('key1'), 'Should parse string value correctly');
        Assert.areEqual('value2', result.get('key2'), 'Should parse string value correctly');
        Assert.areEqual('123', result.get('key3'), 'Should convert number to string');
        Assert.areEqual('true', result.get('key4'), 'Should convert boolean to string');
    }
    
    @isTest
    static void testParseCustomMetadataJsonEmpty() {
        ics_customlabel__mdt mockMetadata = new ics_customlabel__mdt();
        mockMetadata.Description__c = '{}';
        
        Test.startTest();
        Map<String, String> result = ICS_API_SAPCreateCustomer.parseCustomMetadataJson(mockMetadata);
        Test.stopTest();
        
        Assert.isNotNull(result, 'Result should not be null');
        Assert.areEqual(0, result.size(), 'Should be empty map for empty JSON');
    }
    
    
    /**
     * Covers the joint-account code path, hitting:
     *   - determinePartyType() returning 'Joint'
     *   - addJointPartyNames() and constructFullName()
     *   - createJointReference() (PartyNameSalution from full name)
     *   - createKYCCategory('24') in createAdditionalData()
     */
    @isTest
    static void testCreateCustomerRequestJoint() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        
        Test.startTest();
        String jsonResult = ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, true);
        Test.stopTest();
        
        Assert.isNotNull(jsonResult, 'JSON result should not be null for joint account');
        
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        Assert.areNotEqual(null, resultMap, 'Parsed JSON should not be null');
        
        List<Object> partyList = (List<Object>)resultMap.get('Party');
        Assert.areNotEqual(null, partyList, 'Party list should not be null');
        Assert.isFalse(partyList.isEmpty(), 'Party list should not be empty');
        
        // The party reference should reflect type 'Joint'
        Map<String, Object> party = (Map<String, Object>)partyList[0];
        Map<String, Object> partyRef = (Map<String, Object>)party.get('PartyReference');
        Assert.areEqual('Joint', (String)partyRef.get('PartyType'), 'PartyType should be Joint');
    }
    
    /**
     * Covers buildPartyRelationships() (the public static method).
     * Relationship values are populated from the AOBReferencedDataMap, which is
     * initialised inside createCustomerRequest, so we call that first.
     */
    @isTest
    static void testBuildPartyRelationships() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        
        // Initialise the static maps that buildPartyRelationships depends on
        ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, false);
        
        Test.startTest();
        List<ICS_DTO_SAPCreateCustomerRequest.PartyRelationship> relationships =
            ICS_API_SAPCreateCustomer.buildPartyRelationships();
        Test.stopTest();
        
        Assert.isNotNull(relationships, 'Relationships list should not be null');
        Assert.isFalse(relationships.isEmpty(), 'Relationships list should not be empty');
        
        // Every returned relationship must have a non-blank type and value
        for (ICS_DTO_SAPCreateCustomerRequest.PartyRelationship rel : relationships) {
            Assert.isTrue(String.isNotBlank(rel.RelationshipType),  'RelationshipType should not be blank');
            Assert.isTrue(String.isNotBlank(rel.RelationshipValue), 'RelationshipValue should not be blank');
        }
    }
    
    /**
     * Covers getCountryCodeMap()  the public static helper that delegates to
     * ICS_CTRL_PreAppFormCreator.countryCodeMap() and trims keys/values.
     */
    @isTest
    static void testGetCountryCodeMap() {
        Test.startTest();
        Map<String, String> result = ICS_API_SAPCreateCustomer.getCountryCodeMap();
        Test.stopTest();
        
        // The method must always return a non null map empty is acceptable if the
        // underlying custom metadata has no entries in the test context.
        Assert.isNotNull(result, 'getCountryCodeMap should never return null');
    }
    
    /**
     * Covers the risk-category grade mapping in createPartyProfileRiskCategory3():
     *   - high   => '09'
     *   - medium => '10'
     *   - standard / low => '11'
     * A PartyProfileRisk record is inserted for the account's party profile so that
     * the query returns a non-empty list and exercises the mapping branch.
     */
    @isTest
    static void testCreateCustomerWithRiskCategory() {
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        
        // Find the ICS_PartyProfile party profile for this account and attach a risk record
        PartyProfile profile = [
            SELECT Id
            FROM PartyProfile
            WHERE AccountId = :testAcc.Id
              AND RecordType.Name = 'ICS Party Profile'
            LIMIT 1
        ];
        
        // Insert a PartyProfileRisk with RiskCategory = 'high' to exercise the '09' branch
        PartyProfileRisk risk = new PartyProfileRisk(
        Name           = 'Test Risk',
        PartyProfileId = profile.Id,
        RiskCategory   = 'high'
            );
        insert risk;
        
        Test.startTest();
        String jsonResult = ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, false);
        Test.stopTest();
        
        Assert.isNotNull(jsonResult, 'JSON result should not be null when risk category is set');
        
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        Assert.areNotEqual(null, resultMap, 'Parsed result map should not be null');
        
        // AdditionalData and CategoryInformation are present, confirming
        // that createPartyProfileRiskCategory3() was reached and did not throw
        List<Object> partyList = (List<Object>)resultMap.get('Party');
        Map<String, Object> party     = (Map<String, Object>)partyList[0];
        Map<String, Object> addData   = (Map<String, Object>)party.get('AdditionalData');
        Assert.isNotNull(addData, 'AdditionalData should be present in the response');
        
        Map<String, Object> catInfo   = (Map<String, Object>)addData.get('CategoryInformation');
        Assert.isNotNull(catInfo, 'CategoryInformation should be present');
        
        List<Object> categories = (List<Object>)catInfo.get('Category');
        Assert.isFalse(categories.isEmpty(), 'Categories list should not be empty');
    }
    @isTest
    static void testToCamelCase() {
        Test.startTest();
        String result = ICS_API_SAPCreateCustomer.toCamelCase('SOUTH AFRICA');
        String blankResult = ICS_API_SAPCreateCustomer.toCamelCase('');
        Test.stopTest();
        
        Assert.areEqual('South Africa', result, 'Should convert to camel case');
        Assert.areEqual('', blankResult, 'Blank input should return unchanged');
    }
    @isTest
    static void testCreateSecurityQuestionsCategoryAllQuestionsAnswered() {
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];
        createSecurityAssessmentResponses(testAcc, new Map<String, String>{
            'Code word' => 'Blue',
            'Favourite Colour' => 'Green',
            'Mother\'s Former Name' => 'Smith',
            'Name of your first School' => 'Oakwood'
        });
        
        Test.startTest();
        String jsonResult = ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, false);
        Test.stopTest();
        
        Map<String, String> securityDetails = extractSecurityQuestionDetails(jsonResult);
        Assert.areEqual(4, securityDetails.size(), 'All 4 security questions should be present');
        Assert.areEqual('Blue', securityDetails.get('question1'), 'question1 should map to Code word answer');
        Assert.areEqual('Green', securityDetails.get('question2'), 'question2 should map to Favourite Colour answer');
        Assert.areEqual('Smith', securityDetails.get('question3'), 'question3 should map to Mother\'s Former Name answer');
        Assert.areEqual('Oakwood', securityDetails.get('question4'), 'question4 should map to first School answer');
    }
    @isTest
    static void testCreateSecurityQuestionsCategoryPartialAnswers() {
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];
        createSecurityAssessmentResponses(testAcc, new Map<String, String>{
            'Code word' => 'Blue',
            'Favourite Colour' => 'Green',
            'Mother\'s Former Name' => 'Smith'
        });
        
        Test.startTest();
        String jsonResult = ICS_API_SAPCreateCustomer.createCustomerRequest(testAcc.Id, false);
        Test.stopTest();
        
        Map<String, String> securityDetails = extractSecurityQuestionDetails(jsonResult);
        Assert.isTrue(securityDetails.isEmpty(), 'No security question details should be populated when fewer than 4 are answered');
    }
    private static void createSecurityAssessmentResponses(Account acc, Map<String, String> questionTextToAnswer) {
        Assessment assessment = new Assessment(
        Name = acc.Name + ' Assessment',
        AssessmentStatus = 'In Progress',
        AccountId = acc.Id
            );
        insert assessment;
        
        List<AssessmentQuestionResponse> responses = new List<AssessmentQuestionResponse>();
        Integer i = 0;
        for (String questionText : questionTextToAnswer.keySet()) {
            i++;
            AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'securityQuestion' + i,
            Name = 'Security Question ' + i,
            QuestionCategory = 'Financial'
                );
            insert question;
            
            AssessmentQuestionVersion questionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            QuestionText = questionText,
            Name = 'Security Question ' + i,
            IsActive = true
                );
            insert questionVersion;
            
            responses.add(new AssessmentQuestionResponse(
            Name = 'Security Details',
            AssessmentId = assessment.Id,
            AssessmentQuestionId = questionVersion.Id,
            ResponseText = questionTextToAnswer.get(questionText)
                ));
        }
        insert responses;
    }
    private static Map<String, String> extractSecurityQuestionDetails(String jsonResult) {
        Map<String, String> result = new Map<String, String>();
        Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(jsonResult);
        List<Object> partyList = (List<Object>)resultMap.get('Party');
        Map<String, Object> party = (Map<String, Object>)partyList[0];
        Map<String, Object> addData = (Map<String, Object>)party.get('AdditionalData');
        Map<String, Object> catInfo = (Map<String, Object>)addData.get('CategoryInformation');
        List<Object> categories = (List<Object>)catInfo.get('Category');
        
        for (Object catObj : categories) {
            Map<String, Object> category = (Map<String, Object>)catObj;
            if (category.get('CategoryItem') == 'security-question-answer') {
                List<Object> details = (List<Object>)category.get('CategoryDetails');
                if (details != null) {
                    for (Object detailObj : details) {
                        Map<String, Object> detail = (Map<String, Object>)detailObj;
                        result.put((String)detail.get('CategoryType'), (String)detail.get('CategoryIdentifierValue'));
                    }
                }
            }
        }
        return result;
    }
}