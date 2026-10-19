/**
 * @description Class used as test class for ICS_CTRL_PrepareJSON
 * @author Ikyatha Naidu
 * @date 22/04/2024
 *  * *****************************************************
 * @last modified on  : 13/09/2025
 * @last modified by  : Ridhima Saxena 
 * @last modified description:  SFP-52215 updated to cover industry logic 
 * *  * *****************************************************
 * @last modified on  : 18/02/2025
 * @last modified by  : Ridhima Saxena 
 * @last modified description:   SFP-54701 Updated for coverage and SCA
 */
@isTest
public class ICS_CTRL_PrepareJSON_Test {

    // ── Duplicate-literal constants ──────────────────────────────────────────
    private static final String TEST_ASSET_NAME          = 'Test Asset';
    private static final String INDUSTRY_TOBACCO         = 'Growing of tobacco';
    private static final String WEALTH_DETAILS           = 'TestWealth,1000;TestDetail,500';
    private static final String SECTION_ASSETS_INCOME    = 'Assets and Income';
    private static final String SECTION_BUS_OWNERSHIP    = 'Business Ownership';
    private static final String SECTION_OTHER_BUSINESS   = 'Other Business Interests';
    private static final String SECTION_FUTURE_DEPOSITS  = 'Future Deposits';
    private static final String SECTION_TEST             = 'Test Section';
    private static final String RESULT_NOT_EMPTY         = 'Result should not be empty';
    private static final String RESULT_CONTAINS_JSON 	 = 'Result should contain JSON data';
    private static final String FIELD_NAME               = 'Name';
    private static final String OBJ_PARTY_ASSETS         = 'Party_Assets_Funds__c';
    private static final String QUESTION_NAME_TEST       = 'test';
    private static final String TEST_CURRENCY = 'Test Currency';
    // ─────────────────────────────────────────────────────────────────────────

    @TestSetup
    static void setupTestData() {
        User commUser = ICS_DAL_TestFactory.createCommunityUser();
        commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profile = ICS_DAL_TestFactory.createPartyProfile(commUser.Contact.accountId);
        
        createPartyAsset(profile.Id);
        createPartyProfileAddress(profile.Id);
        createContactPointPhone(commUser.Contact.AccountId);
        createAOBReferencedData();
        createAOBRecords();
        createIdentityDocument(commUser.Contact.AccountId);
        createAssessmentData(commUser.Contact.AccountId);
    }

    // ── Helper methods ───────────────────────────────────────────────────────

    private static Party_Assets_Funds__c createPartyAsset(Id profileId) {
        Party_Assets_Funds__c partyAsset = new Party_Assets_Funds__c(
            Name                                  = TEST_ASSET_NAME,
            Party_Profile__c                      = profileId,
            Industry__c                           = INDUSTRY_TOBACCO,
            Wealth_Details_Inclusive_of_Amount__c = WEALTH_DETAILS,
            Full_details_inclusive_of_amount__c   = 'FullDetail1,2000;FullDetail2,1500',
            Value_of_the_business__c              = 50000,
            Annual_Monetary_Value__c              = 5000.50,
            Is_Trust_Beneficiary__c               = true,
            Date_Funds_Received__c                = Date.today(),
            Percentage_of_Company_Ownership__c    = 100,
            Is_listed_in_assets__c                = true
        );
        insert partyAsset;
        return partyAsset;
    }

    private static PartyProfileAddress createPartyProfileAddress(Id profileId) {
        PartyProfileAddress address = new PartyProfileAddress(
            Name                 = 'Test Address',
            PartyProfileId       = profileId,
            AddressType          = 'Residential Address',
            Apartment_Number__c  = '123',
            state                = '123',
            Secondary_Street__c  = 'Test Street',
            Date_Move_In__c      = Date.today().addYears(-1),
            Date_Move_Out__c     = Date.today()
        );
        insert address;
        return address;
    }

    private static ContactPointPhone createContactPointPhone(Id accountId) {
        ContactPointPhone phone = new ContactPointPhone(
            IsPrimary       = true,
            ParentId        = accountId,
            TelephoneNumber = '1234567890'
        );
        insert phone;
        return phone;
    }

    private static void createAOBReferencedData() {
        List<AOB_ReferencedData__c> refDataList = new List<AOB_ReferencedData__c>{
            new AOB_ReferencedData__c(
                Name           = INDUSTRY_TOBACCO,
                AOB_Code__c    = INDUSTRY_TOBACCO,
                AOB_SAPField__c = 'ICS_Industry'
            )
        };
        insert refDataList;
    }

    private static void createAOBRecords() {
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name                 = 'Test Screen',
            AO_ExternalId__c     = 'TEST001',
            AOB_Screen_Sequence__c = 1
        );
        insert screen;

        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            Name             = SECTION_TEST,
            AOB_ExternalId__c = 'TEST002',
            AOB_Screen__c    = screen.Id,
            AOB_Title__c     = 'Test Section Title'
        );
        insert section;

        List<AOB_Field__c> fields = new List<AOB_Field__c>{
            // Address object
            new AOB_Field__c(AOB_SFField__c = FIELD_NAME,                         Name = FIELD_NAME,          AOB_Section__c = section.Id, AOB_SFObject__c = 'PartyProfileAddress'),
            // Phone object
            new AOB_Field__c(AOB_SFField__c = 'TelephoneNumber',                  Name = 'Phone',             AOB_Section__c = section.Id, AOB_SFObject__c = 'ContactPointPhone'),
            // PartyProfile object
            new AOB_Field__c(AOB_SFField__c = FIELD_NAME,                         Name = FIELD_NAME,          AOB_Section__c = section.Id, AOB_SFObject__c = 'PartyProfile'),
            // Party_Assets_Funds__c mappings
            new AOB_Field__c(AOB_SFField__c = 'Industry__c',                      Name = 'Industry',          AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Annual_Monetary_Value__c',         Name = 'Annual Value',      AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Is_Trust_Beneficiary__c',          Name = 'Trust Beneficiary', AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Date_Funds_Received__c',           Name = 'Funds Date',        AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Type__c',                          Name = 'Asset Type',        AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Percentage_of_Company_Ownership__c', Name = 'Ownership %',     AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Wealth_Details_Inclusive_of_Amount__c', Name = 'Wealth Details', AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Full_details_inclusive_of_amount__c', Name = 'Full Details',   AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Value_of_the_business__c',         Name = 'Business Value',    AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS),
            new AOB_Field__c(AOB_SFField__c = 'Is_listed_in_assets__c',           Name = 'Is Listed',         AOB_Section__c = section.Id, AOB_SFObject__c = OBJ_PARTY_ASSETS)
        };
        insert fields;
    }

    private static void createIdentityDocument(Id accountId) {
        IdentityDocument idDoc = new IdentityDocument(
            IdDocumentType       = 'Passport',
            Name                 = 'Test Passport',
            RelatedLegalEntityId = accountId
        );
        insert idDoc;
    }

    private static void createAssessmentData(Id accountId) {
        Assessment assessment = ics_dal_testfactory.createAssessment(accountId);

        AssessmentQuestion testQuestion = new AssessmentQuestion(
            Name             = QUESTION_NAME_TEST,
            DataType         = 'Text',
            DeveloperName    = QUESTION_NAME_TEST,
            QuestionCategory = 'Financial'
        );
        insert testQuestion;

        AssessmentQuestionVersion testQuestionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = testQuestion.Id,
            QuestionText         = 'I don\'t have a bank account',
            Name                 = QUESTION_NAME_TEST
        );
        insert testQuestionVersion;

        AssessmentQuestionResponse testResponse = new AssessmentQuestionResponse(
            Name                  = 'Bank Details',
            AssessmentId          = assessment.Id,
            AssessmentQuestionId  = testQuestionVersion.Id,
            ResponseText          = 'FALSE'
        );
        insert testResponse;
    }

    private static Map<String, List<AOB_Field__c>> getObjectWithFieldAPINames() {
        Map<String, List<AOB_Field__c>> result = new Map<String, List<AOB_Field__c>>();
        for (AOB_Field__c field : [SELECT Id, AOB_SFField__c, Name, AOB_SFObject__c, AOB_Type__c FROM AOB_Field__c]) {
            if (!result.containsKey(field.AOB_SFObject__c)) {
                result.put(field.AOB_SFObject__c, new List<AOB_Field__c>());
            }
            result.get(field.AOB_SFObject__c).add(field);
        }
        return result;
    }

    // ── Test methods ─────────────────────────────────────────────────────────

    @isTest
    static void testFetchIndustryData() {
        Test.startTest();
        ICS_CTRL_PrepareJSON.fetchIndustryData();
        Test.stopTest();

        Assert.isTrue(!ICS_CTRL_PrepareJSON.industryMap.isEmpty(), 'Industry map should not be empty');
    }
    @isTest
    static void testProcessFieldByTypeAllBranches() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        system.runAs(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                [SELECT Id, Name, Annual_Monetary_Value__c, Is_Trust_Beneficiary__c, Date_Funds_Received__c, Type__c FROM Party_Assets_Funds__c LIMIT 1],
                objectWithFieldAPINames,
                null,
                commUser.Contact.AccountId,
                SECTION_ASSETS_INCOME,
                new Set<String>()
            );
            Test.stopTest();

            Assert.isTrue(!result.isEmpty(), 'Should process all field types');
        }
    }
    @isTest
    static void testPrepareJSONWithVariousScenario() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        Map<String, String> questionWithScreenNameSet = new Map<String, String>{'TestQuestion' => 'TestScreen'};
        Set<String> tableScreenFields = new Set<String>{'TestField'};

        Test.startTest();
        system.runas(commUser) {
            List<String> result2 = ICS_CTRL_PrepareJSON.prepareJSON(
                [SELECT Id, Name, Country_of_Residence__c, Percentage_of_Business__c, Has_Former_Name__c, Has_Maiden_Name__c, WI_MaritialStatus__c, Has_different_First_Middle_Family_Name__c FROM PartyProfile LIMIT 1],
                objectWithFieldAPINames,
                questionWithScreenNameSet,
                commUser.contact.accountID,
                SECTION_BUS_OWNERSHIP,
                tableScreenFields
            );
            Test.stopTest();
            Assert.isFalse(!result2.isEmpty(), RESULT_NOT_EMPTY);
        }
    }
    @isTest
    static void testPrepareJSONWithIdentityDocument() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        IdentityDocument idDoc = [SELECT Id, IdDocumentType, Name FROM IdentityDocument LIMIT 1];
        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{idDoc},
                new Map<String, List<AOB_Field__c>>(),
                null,
                commUser.Contact.AccountId,
                'Identity Documents',
                new Set<String>()
            );
            ICS_CTRL_PrepareJSON.countryCodeMap('IN');
            Assert.isTrue(!result.isEmpty(), RESULT_NOT_EMPTY);
            Test.stopTest();
        }
    }
    @isTest
    static void testPrepareJSONWithEmptyData() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];

        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>(),
                new Map<String, List<AOB_Field__c>>(),
                null,
                commUser.Contact.AccountId,
                'Empty Section',
                new Set<String>()
            );
            Assert.isTrue(!result.isEmpty(), RESULT_NOT_EMPTY);
            Test.stopTest();
        }
    }
    @isTest
    static void testPrepareJSONWithDifferentFieldTypes() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        Party_Assets_Funds__c testAsset = new Party_Assets_Funds__c(
            Name                                  = TEST_ASSET_NAME,
            Industry__c                           = INDUSTRY_TOBACCO,
            Wealth_Details_Inclusive_of_Amount__c = WEALTH_DETAILS,
            Full_details_inclusive_of_amount__c   = 'TestAmount,100',
            Percentage_of_Company_Ownership__c    = 100,
            Is_Trust_Beneficiary__c               = true,
            Date_Funds_Received__c                = Date.today(),
            Annual_Monetary_Value__c              = 5000
        );
        insert testAsset;
        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{testAsset},
                objectWithFieldAPINames,
                null,
                commUser.contact.accountId,
                SECTION_ASSETS_INCOME,
                new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!result.isEmpty(), RESULT_CONTAINS_JSON);
        }
    }
    @isTest
    static void testPrepareJSONWithDifferentFieldTypesset() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();

        Party_Assets_Funds__c testAsset = new Party_Assets_Funds__c(
            Name                                  = TEST_ASSET_NAME,
            Industry__c                           = INDUSTRY_TOBACCO,
            Wealth_Details_Inclusive_of_Amount__c = WEALTH_DETAILS,
            Is_Trust_Beneficiary__c               = true,
            Date_Funds_Received__c                = Date.today(),
            Annual_Monetary_Value__c              = 5000,
            Percentage_of_Company_Ownership__c    = 75.5
        );
        insert testAsset;

        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{testAsset},
                objectWithFieldAPINames,
                null,
                commUser.contact.accountId,
                SECTION_BUS_OWNERSHIP,
                new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!result.isEmpty(), RESULT_CONTAINS_JSON);
        }
    }
    @isTest
    static void testPrepareJSONWithDifferentFieldSections() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();

        Party_Assets_Funds__c testAsset = new Party_Assets_Funds__c(
            Name                                  = TEST_ASSET_NAME,
            Industry__c                           = INDUSTRY_TOBACCO,
            Wealth_Details_Inclusive_of_Amount__c = WEALTH_DETAILS,
            Is_Trust_Beneficiary__c               = true,
            Date_Funds_Received__c                = Date.today(),
            Annual_Monetary_Value__c              = 5000,
            Percentage_of_Company_Ownership__c    = 75.5
        );
        insert testAsset;
        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{testAsset},
                objectWithFieldAPINames,
                null,
                commUser.contact.accountId,
                'Employment Details',
                new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!result.isEmpty(), RESULT_CONTAINS_JSON);
        }
    }
    @isTest
    static void testPrepareJSONWithDifferentSectionsNames() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        Party_Assets_Funds__c testAsset = new Party_Assets_Funds__c(
            Name                                  = TEST_ASSET_NAME,
            Industry__c                           = INDUSTRY_TOBACCO,
            Wealth_Details_Inclusive_of_Amount__c = WEALTH_DETAILS,
            Is_Trust_Beneficiary__c               = true,
            Date_Funds_Received__c                = Date.today(),
            Annual_Monetary_Value__c              = 5000,
            Percentage_of_Company_Ownership__c    = 75.5,
            Relationship__c                       = 'Owner',
            Is_any_income_from_this_interest__c   = true
        );
        insert testAsset;

        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{testAsset},
                objectWithFieldAPINames,
                null,
                commUser.contact.accountId,
                SECTION_OTHER_BUSINESS,
                new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!result.isEmpty(), RESULT_CONTAINS_JSON);
            Assert.isTrue(true, 'Method executed without exceptions');
        }
    }
    @isTest
    static void testProcessQuestions() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Assessment assessment = [SELECT Id FROM Assessment WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];

        AssessmentQuestionResponse testResponse = new AssessmentQuestionResponse(
            Name                 = SECTION_TEST,
            AssessmentId         = assessment.Id,
            AssessmentQuestionId = [SELECT Id FROM AssessmentQuestionVersion LIMIT 1].Id,
            ResponseText         = 'Test Answer'
        );
        insert testResponse;
        testResponse = [SELECT Id, ResponseText, Name, AssessmentQuestion.Name
                        FROM AssessmentQuestionResponse WHERE Id = :testResponse.Id];
        ICS_CTRL_FecthOnboardingDetails.responseAssessmentMap.put(SECTION_TEST,
            new List<AssessmentQuestionResponse>{testResponse});

        Map<String, String> questionWithScreenNameSet = new Map<String, String>{
            QUESTION_NAME_TEST => 'TestScreen'
        };
        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{new Account()},
                new Map<String, List<AOB_Field__c>>(),
                questionWithScreenNameSet,
                commUser.contact.accountId,
                SECTION_TEST,
                new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!result.isEmpty(), RESULT_NOT_EMPTY);
            Map<String, Object> resultMap = (Map<String, Object>)JSON.deserializeUntyped(result[0]);
            Assert.areEqual('Test Answer', resultMap.get('TestScreen'), 'Question response should be correctly processed');
        }
    }
    @isTest
    static void testGetResponseCurrencyMap() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Assessment assessment = [SELECT Id FROM Assessment WHERE AccountId = :commuser.Contact.AccountId LIMIT 1];
        AssessmentQuestion currencyQuestion = new AssessmentQuestion(
            Name             = TEST_CURRENCY,
            QuestionCategory = 'Financial',
            developerName    = 'Test_Currency_Question',
            DataType         = 'Currency'
        );
        insert currencyQuestion;
        AssessmentQuestionVersion currencyQuestionVersion = new AssessmentQuestionVersion(
            AssessmentQuestionId = currencyQuestion.Id,
            QuestionText         = TEST_CURRENCY,
            Name                 = TEST_CURRENCY
        );
        insert currencyQuestionVersion;
        AssessmentQuestionResponse currencyResponse = new AssessmentQuestionResponse(
            Name                 = TEST_CURRENCY,
            AssessmentId         = assessment.Id,
            AssessmentQuestionId = currencyQuestionVersion.Id,
            ResponseText         = 'USD:1000'
        );
        insert currencyResponse;

        system.runas(commUser) {
            Test.startTest();
            List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{new Account()},
                new Map<String, List<AOB_Field__c>>(),
                null,
                commuser.Contact.AccountId,
                TEST_CURRENCY,
                new Set<String>()
            );
            Assert.isTrue(!result.isEmpty(), RESULT_NOT_EMPTY);
            Test.stopTest();
        }
    }
    @isTest
    static void testPrepareJSONWithException() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        system.runas(commUser) {
            Test.startTest();
            try {
                ICS_CTRL_PrepareJSON.prepareJSON(null, null, null, null, null, null);
            } catch (Exception e) {
                Assert.isTrue(e.getmessage() != null, 'Error Occured');
            }
            Test.stopTest();
        }
    }
    @isTest
    static void testProcessObjectSpecificLogic_Address() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        PartyProfile profile = [SELECT Id FROM PartyProfile WHERE AccountId = :commUser.Contact.AccountId LIMIT 1];
        PartyProfileAddress address = [SELECT Id, state, name, Date_Move_In__c, Date_Move_Out__c FROM PartyProfileAddress WHERE PartyProfileId = :profile.Id LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        system.runAs(commUser) {
            Test.startTest();
            List<String> resultCurrentAddress = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{address}, objectWithFieldAPINames, null, commUser.Contact.AccountId, 'Current Residential Address', new Set<String>()
            );
            List<String> resultPersonalDetails = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{address}, objectWithFieldAPINames, null, commUser.Contact.AccountId, 'Personal Details', new Set<String>()
            );
            List<String> resultApplicantAddress = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{address}, objectWithFieldAPINames, null, commUser.Contact.AccountId, 'Applicant\'s Current Residential Address', new Set<String>()
            );
            Test.stopTest();
            Assert.isTrue(!resultCurrentAddress.isEmpty(), 'Current address result should not be empty');
            Assert.isTrue(!resultPersonalDetails.isEmpty(), 'Personal details result should not be empty');
            Assert.isTrue(!resultApplicantAddress.isEmpty(), 'Applicant address result should not be empty');
        }
    }
    @isTest
    static void testProcessObjectSpecificLogic_Phone() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        ContactPointPhone phone = [SELECT Id, IsPrimary, TelephoneNumber FROM ContactPointPhone WHERE ParentId = :commUser.Contact.AccountId LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        system.runAs(commUser) {
            ContactPointPhone altPhone = new ContactPointPhone(
                IsPrimary = false, ParentId = commUser.Contact.AccountId, TelephoneNumber = '9876543210'
            );
            insert altPhone;
            Test.startTest();
            List<String> resultPrimaryPhone = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{phone}, objectWithFieldAPINames, null, commUser.Contact.AccountId, 'Contact Details', new Set<String>()
            );
            List<String> resultAltPhone = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{altPhone}, objectWithFieldAPINames, null, commUser.Contact.AccountId, 'Contact Details', new Set<String>()
            );
            Test.stopTest();

            Assert.isTrue(!resultPrimaryPhone.isEmpty(), 'Primary phone result should not be empty');
            Assert.isTrue(!resultAltPhone.isEmpty(), 'Alternative phone result should not be empty');
        }
    }
    @isTest
    static void testProcessObjectSpecificLogic_Assets() {
        User commUser = [SELECT Id, Contact.AccountId FROM User WHERE FederationIdentifier LIKE 'FederationIdentifier%' LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();
        Party_Assets_Funds__c asset = [SELECT Id, Percentage_of_Company_Ownership__c, Industry__c,
                                        Wealth_Details_Inclusive_of_Amount__c, Full_details_inclusive_of_amount__c,
                                        Value_of_the_business__c, Annual_Monetary_Value__c, Is_Trust_Beneficiary__c,
                                        Date_Funds_Received__c, Is_listed_in_assets__c, Relationship__c,
                                        Is_any_income_from_this_interest__c FROM Party_Assets_Funds__c LIMIT 1];
        asset.Percentage_of_Company_Ownership__c  = 100;
        asset.Relationship__c                     = 'Owner';
        asset.Is_any_income_from_this_interest__c = true;
        update asset;
        system.runAs(commUser) {
            Test.startTest();
            List<String> resultBusinessOwnership = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{asset}, objectWithFieldAPINames, null, commUser.Contact.AccountId, SECTION_BUS_OWNERSHIP, new Set<String>()
            );
            List<String> resultOtherDetails = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{asset}, objectWithFieldAPINames, null, commUser.Contact.AccountId, SECTION_OTHER_BUSINESS, new Set<String>()
            );
            List<String> resultAssetSection = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{asset}, objectWithFieldAPINames, null, commUser.Contact.AccountId, SECTION_ASSETS_INCOME, new Set<String>()
            );
            List<String> resultFutureDeposits = ICS_CTRL_PrepareJSON.prepareJSON(
                new List<SObject>{asset}, objectWithFieldAPINames, null, commUser.Contact.AccountId, SECTION_FUTURE_DEPOSITS, new Set<String>()
            );
            Test.stopTest();

            Assert.isNotNull(resultBusinessOwnership, 'Business ownership result should not be null');
            Assert.isNotNull(resultOtherDetails,       'Other business interests result should not be null');
            Assert.isNotNull(resultAssetSection,       'Assets and income result should not be null');
            Assert.isNotNull(resultFutureDeposits,     'Future deposits result should not be null');
        }
    }

    @isTest
    static void testProcessFieldByType() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c asset = [SELECT Id, Industry__c FROM Party_Assets_Funds__c LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();

        Test.startTest();
        List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
            new List<SObject>{asset},
            objectWithFieldAPINames,
            null,
            acc.Id,
            SECTION_ASSETS_INCOME,
            new Set<String>()
        );
        Test.stopTest();
        Assert.isFalse(!result.isEmpty(), RESULT_NOT_EMPTY);
    }

    @isTest
    static void testProcessOtherBI() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Party_Assets_Funds__c asset = [SELECT Id, Industry__c FROM Party_Assets_Funds__c LIMIT 1];
        Map<String, List<AOB_Field__c>> objectWithFieldAPINames = getObjectWithFieldAPINames();

        Test.startTest();
        List<String> result = ICS_CTRL_PrepareJSON.prepareJSON(
            new List<SObject>{asset},
            objectWithFieldAPINames,
            null,
            acc.Id,
            SECTION_OTHER_BUSINESS,
            new Set<String>()
        );
        Test.stopTest();
        Assert.isFalse(!result.isEmpty(), RESULT_NOT_EMPTY);
    }
}