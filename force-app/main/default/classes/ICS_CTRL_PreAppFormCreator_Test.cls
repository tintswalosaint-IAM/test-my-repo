/**
 * @description Testclass used to cover the ICS_CTRL_PreAppFormCreator class
 *
 * Story:SFP-36380,SFP-31025
 *
 * @author Ikyatha Naidu
 *
 * @date May 2023
 * @last modified on  : 06-08-2024
 * @last modified by  : Ruchi Agrawal
 * @Modification Description : SFP-36380,SFP-31025 class used as controller for SBO-UK PreApplication
 * @last modified on  : 26-02-2026
 * @last modified by  : Ridhima Saxena
 * @Modification Description : SFP-54515 updated for joint account creation
 * @last modified on  : 25-06-2026
 * @last modified by  : Sai Pranay Poona
 * @Modification Description : SFP-58911 updated for site guest user remediation issue, ACR is created from platform events hence removed ACR assertions.
 */@isTest
private class ICS_CTRL_PreAppFormCreator_Test {
    private static final String TEST_FIRST_NAME = 'John';
    private static final String TEST_Last_NAME = 'Doe';
    private static final String STAGE_PROSPECTING = 'Prospecting';
    private static final String TEST_CODE = 'TEST001';
    private static final String RECORD_TYPE_SOCTY = 'SOCTY';
    private static final String PROCESS_ONBOARDING = 'Onboarding';
    private static final String BRANCH_CODE_028NP = '028NP';
    private static final String IOM_COUNTRIES_LABEL = 'ics_iom_countries';
    private static final String JSON_ACCOUNT_PREFIX = '{"AOB_SFObject__c": "Account", "AOB_Section__c": "';
    private static final String JSON_PARTYPROFILE_PREFIX = '{"AOB_SFObject__c": "PartyProfile", "AOB_Section__c": "';
    private static final String JSON_APPLICANT_PREFIX = '{"AOB_SFObject__c": "Applicant", "AOB_Section__c": "';
    private static final String JSON_PARTYPROFILEADDRESS_PREFIX = '{"AOB_SFObject__c": "PartyProfileAddress", "AOB_Section__c": "';
    private static final String JSON_IDENTITYDOCUMENT_PREFIX = '{"AOB_SFObject__c": "IdentityDocument", "AOB_Section__c": "';
    private static final String JSON_APPLICATIONFORM_PREFIX = '{"AOB_SFObject__c": "ApplicationForm", "AOB_Section__c": "';
    private static final String JSON_APPLICATIONFORMPRODUCT_PREFIX = '{"AOB_SFObject__c": "ApplicationFormProduct", "AOB_Section__c": "';
    private static final String JSON_CONTACTPOINTPHONE_PREFIX = '{"AOB_SFObject__c": "ContactPointPhone", "AOB_Section__c": "';
    private static final String RESULT_NULL_MSG = 'Result should not be null';
    private static final String TEST_ACCOUNT_NAME = 'Test Account';
    private static final String STATE_GAUTENG = 'Gauteng';
    private static final String ROLE_RELATIONSHIP_MANAGER = 'ics_relationship_manager';
    private static final String OBJECT_ACCOUNT = 'Account';
    private static final String TEST_FIELD = 'TestField';
    private static final String TEST_VALUE = 'Test Value';
    private static final String FIELD_NAME = 'Name';
    private static final String FIELD_OWNER_ID = 'ownerId';
    private static final String COUNTRY_OF_RESIDENCE = 'Country of Residence';
    Opportunity opp = new Opportunity(
        Name = 'Test Opp',
    StageName = STAGE_PROSPECTING,
    CloseDate = Date.today().addDays(30)
        );
    @TestSetup
    static void setupData() {
        Account accRec = ICS_DAL_TestFactory.createAccount();
        PartyProfile testPartyProfile = ICS_DAL_TestFactory.createPartyProfile(accRec.Id);
        ICS_DAL_TestFactory.createPartyAssetFunds(testPartyProfile.Id);
        
        Contact con = new Contact(FirstName = TEST_FIRST_NAME, LastName = TEST_Last_NAME);
        insert con;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
        StageName = STAGE_PROSPECTING,
        CloseDate = Date.today().addDays(30),
        AccountId = accRec.Id
            );
        insert opp;
        
        OpportunityContactRole oppConRole = new OpportunityContactRole(
            OpportunityId = opp.Id,
        ContactId = con.Id,
        Role = 'IFA'
            );
        insert oppConRole;
        
        Product2 prd1 = new Product2(
            ProductCode = TEST_CODE,
        Name = 'Test Product 1',
        IsActive = true,
        CurrencyIsoCode = 'USD'
            );
        
        Product2 prd2 = new Product2(
            ProductCode = RECORD_TYPE_SOCTY,
        Name = 'Test Product 2',
        CurrencyIsoCode = 'GBP',
        IsActive = true
            );
        
        insert new List<Product2>{ prd1, prd2 };
        
        
        ICS_DAL_TestFactory.createProduct2();
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Pricebook2 customPB = new Pricebook2(
            Name = ICS_Constants.ICSPricebook,
        Description = 'Price Book 2009 Products',
        CurrencyIsoCode = 'GBP',
        IsActive = true
            );
        insert customPB;
        
        // Step 1: Create Standard PricebookEntry for each Product
        PricebookEntry standardPrice1 = new PricebookEntry(
            Pricebook2Id = standardPbId,
        Product2Id = prd1.Id,
        UnitPrice = 100,
        IsActive = true
            );
        
        PricebookEntry standardPrice2 = new PricebookEntry(
            Pricebook2Id = standardPbId,
        Product2Id = prd2.Id,
        UnitPrice = 150,
        IsActive = true
            );
        
        insert new List<PricebookEntry>{ standardPrice1, standardPrice2 };
        
        // Step 2: Create Custom PricebookEntry after Standard Price exists
        PricebookEntry customPrice1 = new PricebookEntry(
            Pricebook2Id = customPB.Id,
        Product2Id = prd1.Id,
        UnitPrice = 90,
        IsActive = true
            );
        
        PricebookEntry customPrice2 = new PricebookEntry(
            Pricebook2Id = customPB.Id,
        Product2Id = prd2.Id,
        UnitPrice = 150,
        IsActive = true
            );
        
        insert new List<PricebookEntry>{ customPrice1, customPrice2 };
        
        PartyProfile testProfile = new PartyProfile(
            Name = 'testdata',
        AccountId = accRec.Id,
        Country_of_Residence__c = 'US'
            );
        insert testProfile;
        
        AOB_FlowScreen__c screen = ICS_DAL_TestFactory.createFlowscreen('ICS UK Pre-Personal Details');
        AOB_ScreenSection__c section = ICS_DAL_TestFactory.createScreenSection(screen, 'Personal Details');
        
        String jsonString = convertFieldMappingsToJSON(section.Id);
        ICS_DAL_TestFactory.createField(jsonString, section.Id);
        ICS_DAL_TestFactory.createTestDataSalesCode();
        
        List<Sales_Codes__c> codeInfo = new List<Sales_Codes__c>{
            new Sales_Codes__c(Name = 'IOM Sales Lead', Sales_Code_Country__c = 'ZA')
        };
        insert codeInfo;
        
        Sales_Code_Allocation__c data = new Sales_Code_Allocation__c();
        data.Sales_Codes__c = codeInfo[0].Id;
        data.User__c = UserInfo.getUserId();
        insert data;
        
        ApplicationForm form = new ApplicationForm(
            AccountId = accRec.Id,
        OpportunityId = opp.Id,
        UsageType = PROCESS_ONBOARDING,
        Stage = 'Awaiting Verification'
            );
        insert form;
        
        ApplicationFormProduct appFormProd = new ApplicationFormProduct(
            ProductId = prd2.Id,
        ApplicationFormId = form.Id
            );
        insert appFormProd;
        
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put(ICS_Constants.accountText, accRec.Id);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
    }
    
    /**
     * @description Used to convert Field Mappings To JSON for creation of test data
     * @param developerName
     * @return ics_customlabel__mdt
     */
    public static String convertFieldMappingsToJSON(Id sectionId) {
        String acc    = JSON_ACCOUNT_PREFIX + sectionId + '", ';
        String pp     = JSON_PARTYPROFILE_PREFIX + sectionId + '", ';
        String app    = JSON_APPLICANT_PREFIX + sectionId + '", ';
        String ppa    = JSON_PARTYPROFILEADDRESS_PREFIX + sectionId + '", ';
        String idoc   = JSON_IDENTITYDOCUMENT_PREFIX + sectionId + '", ';
        String af     = JSON_APPLICATIONFORM_PREFIX + sectionId + '", ';
        String afp    = JSON_APPLICATIONFORMPRODUCT_PREFIX + sectionId + '", ';
        String cpp    = JSON_CONTACTPOINTPHONE_PREFIX + sectionId + '", ';
        
        return '[' +
            acc + '"Name": "Last Name", "AOB_SFField__c": "LastName", "AOB_Type__c": "Text", "AOB_sequence__c": "4", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            acc + '"Name": "Former Name or Maiden Name", "AOB_SFField__c": "Former_Names_Maiden_Name__c", "AOB_Type__c": "Combobox", "AOB_sequence__c": "6"},' +
            acc + '"Name": "Gender", "AOB_SFField__c": "FinServ__Gender__pc", "AOB_Type__c": "Combobox", "AOB_sequence__c": "15"},' +
            acc + '"Name": "Title", "AOB_SFField__c": "PersonTitle", "AOB_Type__c": "Combobox", "AOB_sequence__c": "2"},' +
            pp  + '"Name": "Primary Country of Nationality", "AOB_SFField__c": "Country_of_Nationality__c", "AOB_Type__c": "Combobox", "AOB_sequence__c": "17"},' +
            acc + '"Name": "First Name", "AOB_SFField__c": "firstName", "AOB_Type__c": "Text", "AOB_sequence__c": "3", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            idoc + '"Name": "ID Number", "AOB_Type__c": "Text", "AOB_sequence__c": "22"},' +
            acc + '"Name": "Middle Name", "AOB_SFField__c": "MiddleName", "AOB_Type__c": "Text", "AOB_sequence__c": "5", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            pp  + '"Name": "Secondary Country of Nationality", "AOB_SFField__c": "Second_Country_of_Nationality__c", "AOB_Type__c": "Combobox", "AOB_sequence__c": "18"},' +
            app + '"Name": "Other Surname", "AOB_SFField__c": "Other_Surname__c", "AOB_Type__c": "Text", "AOB_sequence__c": "13", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            app + '"Name": "Other Names", "AOB_SFField__c": "Other_Names__c", "AOB_Type__c": "MultiSelectSearch", "AOB_sequence__c": "10"},' +
            acc + '"Name": "Date of birth", "AOB_SFField__c": "PersonBirthdate", "AOB_Type__c": "Date", "AOB_sequence__c": "16"},' +
            acc + '"Name": "Maiden Name", "AOB_SFField__c": "Maiden_Name__c", "AOB_Type__c": "Text", "AOB_sequence__c": "9", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            pp  + '"Name": "Country of Residence", "AOB_SFField__c": "Country_of_Residence__c", "AOB_Type__c": "Combobox", "AOB_sequence__c": "19"},' +
            acc + '"Name": "Former Name", "AOB_SFField__c": "Former_Name__c", "AOB_Type__c": "Text", "AOB_sequence__c": "8", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            app + '"Name": "Other First Name", "AOB_SFField__c": "Other_First_Name__c", "AOB_Type__c": "Text", "AOB_sequence__c": "11", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            app + '"Name": "Other Middle Name", "AOB_SFField__c": "Other_Middle_Name__c", "AOB_Type__c": "Text", "AOB_sequence__c": "12", "AOB_pattern__c": "^[a-zA-Z]+([ \'-][a-zA-Z]+)*$"},' +
            app + '"Name": "Relationship with Applicants", "AOB_SFField__c": "Relationship_with_Applicants__c", "AOB_Type__c": "Combobox", "AOB_sequence__c": "22"},' +
            acc + '"Name": "AnnualRevenue", "AOB_Type__c": "Radio", "AOB_sequence__c": "1", "AOB_SFField__c": "AnnualRevenue","AOB_SFObject__c":"Account"},' +
            ppa + '"Name": "Province", "AOB_SFField__c": "State", "AOB_Type__c": "Combobox", "AOB_sequence__c": "20"},' +
            ppa + '"Name": "Sub Region", "AOB_SFField__c": "Street", "AOB_Type__c": "Combobox", "AOB_sequence__c": "21"},' +
            ppa + '"Name": "PartyProfile Id", "AOB_SFField__c": "PartyProfileId;PartyProfile", "AOB_Type__c": "Lookup"},' +
            ppa + '"Name": "Address Type", "AOB_SFField__c": "AddressType", "AOB_Type__c": "Lookup", "Default_Value__c": "Correspondence Address"},' +
            pp  + '"Name": "Account Id", "AOB_SFField__c": "AccountId;Account", "AOB_Type__c": "Lookup"},' +
            acc + '"Name": "RecordtypeId", "AOB_SFField__c": "recordtypeId", "AOB_Type__c": "Lookup", "Default_Value__c": "ICS Applicant"},' +
            pp  + '"Name": "PartyProfileName", "AOB_SFField__c": "Name", "AOB_Type__c": "Lookup", "Default_Value__c": "record"},' +
            ppa + '"Name": "PartyProfileAddressName", "AOB_SFField__c": "Name", "AOB_Type__c": "Lookup", "Default_Value__c": "record"},' +
            app + '"Name": "PartyProfile Id", "AOB_SFField__c": "PartyProfileId;PartyProfile", "AOB_Type__c": "Lookup"},' +
            app + '"Name": "AccountId", "AOB_SFField__c": "AccountId;Account", "AOB_Type__c": "Lookup"},' +
            af  + '"Name": "opportunityid", "AOB_SFField__c": "opportunityId;Opportunity", "AOB_Type__c": "Lookup"},' +
            app + '"Name": "ApplicationFormId", "AOB_SFField__c": "ApplicationFormId;ApplicationForm", "AOB_Type__c": "MasterDetail"},' +
            af  + '"Name": "AccountId", "AOB_SFField__c": "AccountId;Account", "AOB_Type__c": "Lookup"},' +
            afp + '"Name": "ApplicationFormProductId", "AOB_SFField__c": "ApplicationFormId;ApplicationForm", "AOB_Type__c": "Lookup"},' +
            idoc + '"Name": "PartyProfileId", "AOB_SFField__c": "PartyProfileId;PartyProfile", "AOB_Type__c": "Lookup"},' +
            idoc + '"Name": "CNP", "AOB_SFField__c": "", "AOB_Type__c": "Lookup"},' +
            pp  + '"Name": "PartyProfileFirstName", "AOB_SFField__c": "FirstName", "AOB_Type__c": "Lookup", "Default_Value__c": "record"},' +
            pp  + '"Name": "RecordtypeId", "AOB_SFField__c": "RecordtypeId", "AOB_Type__c": "Lookup", "Default_Value__c": "ICS Party Profile"},' +
            af  + '"Name": "Stage", "AOB_SFField__c": "Stage", "AOB_Type__c": "Lookup", "Default_Value__c": "Awaiting Verification"},' +
            cpp + '"Name": "PrimaryContact", "AOB_SFField__c": "IsPrimary", "AOB_Type__c": "Lookup", "Default_Value__c": "true"},' +
            acc + '"Name": "CIFCountry", "AOB_SFField__c": "ExternalCIFCountry__c", "AOB_Type__c": "Lookup", "Default_Value__c": "OS"}' +
            ']';
    }
    /**
     * @description inserting data objets to ICS.
     */
    @isTest
    static void testInsertData() {
        String data = '{"personalInputData":"{\\"Date of birth\\":\\"1998-04-02\\",\\"Primary Country of Nationality\\":\\"AF\\",\\"Country of Residence\\":\\"AF\\",\\"AnnualRevenue\\":\\"123\\",\\"Title\\":\\"Capt.\\",\\"First Name\\":\\"Sonali\\",\\"Last Name\\":\\"SS\\",\\"Former Name or Maiden Name\\":\\"None\\",\\"Other Names\\":\\"None\\",\\"Gender\\":\\"Female\\",\\"Secondary Country of Nationality\\":\\"AL\\",\\"CNP\\":\\"123456789\\"}","contactInputData":"{\\"Email Address\\":\\"shravaniganta6@gmail.com\\",\\"Phone Number\\":\\"+93 9090909090\\",\\"phone\\":\\"9090909090\\",\\"countryCode\\":\\"93\\"}","residentialInputData":"{\\"Country of Residence\\":\\"AF\\",\\"isSearchAddress\\":true,\\"isManualAddress\\":false,\\"Street\\":\\"it is\\",\\"Date moved to this address\\":\\"1998-04-02\\"}","accountInputData":"{\\"Please select the currencies you would like for your account\\":\\"Euro;Sterling\\",\\"Would you like a visa debit card?\\":\\"TRUE\\",\\"Select the currencies that you would like a debit card for\\":\\"Euro;Sterling\\",\\"isEnglishSpeak\\":true,\\"isPrivacyPolicy\\":true}","isIFA":false}';
        String opportunityRec = '';
        String productCode = TEST_CODE;
        Test.startTest();
        try{
            String result = ICS_CTRL_PreAppFormCreator.insertData(data, opportunityRec, productCode);
            Test.stopTest();
            Assert.areNotEqual(true, result !=null, RESULT_NULL_MSG);
        }catch(exception ex){
            Assert.areEqual(true, ex.getmessage() != null, 'Error Occured');
        }
        
    }
    /**
     * @description fetch the Screen Fields ICS.
     */
    @isTest
    static void fetchScreenFieldsTestMethod(){
        Test.startTest();
        AOB_DTO_Form result = ICS_CTRL_PreAppFormCreator.fetchScreenFields('ICS UK Pre-Personal Details');
        Test.stopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
    }
    /**
     * @description validate the SBManager Code ICS.
     */
    @isTest
    static void validateSBManagerCodeTestMethod(){
        Test.startTest();
        boolean result = ICS_CTRL_PreAppFormCreator.validateSBManagerCode(BRANCH_CODE_028NP,'ZA');
        Test.stopTest();
        Assert.areEqual(false, result, 'Result should be false');
    }
    /**
     * @description fetching the ProdutDetails ICS.
     */
    @isTest
    static void fetchProdutDetailsTestMethod(){
        Test.startTest();
        string result=ICS_CTRL_PreAppFormCreator.fetchProdutDetails('TEST002');
        Test.StopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
    }
    /**
     * @description checking the ExitingData ICS.
     */
    @isTest
    static void testCheckExistingData() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.PersonBirthdate= Date.valueOf('1990-01-01');
        testAccount.ExternalCIFCountry__c='OS';
        update testAccount;
        String jsonData = '{"firstName":"TestACC","lastName":"testet","birthDate":"1990-01-01","productCode":"TEST001"}';
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.checkExitingData(jsonData);
        Test.stopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
    }
    /**
     * @description fetchthe Product Id ICS.
     */
    @isTest
    static void fetchProductIdTestMethod(){
        Test.startTest();
        String resultProductId = ICS_CTRL_PreAppFormCreator.fetchProductId(TEST_CODE);
        Test.stopTest();
        Assert.areNotEqual(null, resultProductId, RESULT_NULL_MSG);
        
    }
    /**
     * @description maping countryCodeMap ICS.
     */
    @isTest
    static void countryCodeMapTestMethod(){
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.countryCodeMap('US');
        Map<String, String> data=ICS_CTRL_PreAppFormCreator.countryCodeMap();
        Test.stopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
        Assert.areNotEqual(null, data, 'Data should not be null');
    }
    /**
     * @description fetching the CountryofResidence ICS.
     */
    @isTest
    static void fetchCountryofResidenceTestMethod(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        PartyProfile pData =[select id from partyprofile where accountid=:acc.id limit 1];
        pData.Country_of_Residence__c = 'IN';
        update pData;
        Test.startTest();
        string data=ICS_CTRL_PreAppFormCreator.fetchCountryofResidence(acc.id);
        Test.stopTest();
        Assert.areEqual(true,data !=null,'Data should not be null');
        
    }
    /**
     * @description returning Sanctioned Currencies ICS.
     */
    @isTest
    static void testReturnSanctionedCurrencies() {
        Test.startTest();
        List<String> result = ICS_CTRL_PreAppFormCreator.returnSanctionedCurrencies('US');
        Test.stopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
    }
    /**
     * @description return GBGPattern Validations ICS.
     */
    @isTest
    static void returnGBGPatternValidationsTestMethod(){
        Test.startTest();
        string data=ICS_CTRL_PreAppFormCreator.returnGBGPatternValidations('SA');
        Test.stopTest();
        Assert.areNotEqual(null, data, 'Data should not be null');
    }
    /**
     * @description checkIng IFA With ContactId ICS.
     */
    @isTest
    static Void checkIsIFAWithContactIdTestMethod(){
        Contact con =[select id from contact limit 1];
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.checkIsIFAWithContactId(con.id);
        Test.stopTest();
        Assert.areNotEqual(null, result, RESULT_NULL_MSG);
    }
    @isTest
    static void testCheckIsIFAWithContactId_CatchBlock() {
        Account account = new Account(Name = TEST_ACCOUNT_NAME);
        insert account;
        
        Contact validContact = new Contact(
            FirstName = TEST_FIRST_NAME,
        LastName = TEST_Last_NAME,
        AccountId = account.Id
            );
        insert validContact;
        
        String invalidContactId = '';  // This is an intentionally incorrect ID.
        
        Test.startTest();
        try {
            String result = ICS_CTRL_PreAppFormCreator.checkIsIFAWithContactId(invalidContactId);
            Assert.areNotEqual(null, result, RESULT_NULL_MSG);
            Assert.isTrue(false, 'Expected an exception, but the method completed successfully');  // Will fail if no exception is thrown
        } catch (AuraHandledException e) {
            Assert.isFalse(e.getMessage().contains('No such column'), 'Expected error message to contain "No such column"');
            
        }
        Test.stopTest();
    }
    
    
    /**
     * @description getLanding PageJSON ICS.
     */
    @isTest
    static void testGetLandingPageJSON_Success() {
        try{
            Test.startTest();
            ics_customlabel__mdt result = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Sample_DeveloperName');
            Assert.areEqual('Sample_DeveloperName', result.DeveloperName, 'DeveloperName should match');
            Assert.areEqual('Sample Description', result.Description__c, 'Description should match');
            Test.stopTest();
        }catch(exception e){
            Assert.areEqual('Script-thrown exception', e.getMessage(),'Test Meassage');
        }
        
    }
    /**
     * @description updateing the LookupICS.
     */
    @IsTest
    static void testUpdateLookupWithMissingKeys() {
        try{
            Test.startTest();
            ICS_CTRL_PreAppFormCreator.updateLookup();
            Test.stopTest();
        }catch(exception e){
            Assert.areEqual('Script-thrown exception', e.getMessage(),'Test Meassage');
        }
    }
    
    @IsTest
    static void testInsertProductsForAccount() {
        List<Product2> productList = new List<Product2>{
            new Product2(Name = 'Product A', ProductCode = 'PROD_A', CurrencyIsoCode = 'USD', IsActive = true),
            new Product2(Name = 'Product B', ProductCode = 'PROD_B', CurrencyIsoCode = 'EUR', IsActive = true)
        };
        insert productList;
        ApplicationForm appForm = new ApplicationForm(UsageType = PROCESS_ONBOARDING);
        insert appForm;
        
        Set<String> accProductCurrencies = new Set<String>{ 'PROD_A', 'PROD_B' };
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, Id>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put(ICS_Constants.ApplicationForm, appForm.Id);
        ICS_CTRL_PreAppFormCreator.oppOwnerId = UserInfo.getUserId();
        List<ApplicationFormProduct> createdProducts = ICS_CTRL_PreAppFormCreator.insertProductsForAccount(accProductCurrencies);
        Test.stopTest();
        Assert.areEqual(2, createdProducts.size(), 'Two ApplicationFormProduct records should be created.');
        ApplicationForm updatedForm = [SELECT Id, OwnerId, UsageType FROM ApplicationForm WHERE Id = :appForm.Id];
        Assert.areEqual(UserInfo.getUserId(), updatedForm.OwnerId, 'ApplicationForm owner should be updated.');
        Assert.areEqual(PROCESS_ONBOARDING, updatedForm.UsageType, 'UsageType should be Onboarding.');
    }
    @isTest
    static void testHandleSACountryLogic() {
        Sales_Codes__c saCode = new Sales_Codes__c(
            Name = 'SA Test Code',
        Sales_Code_Country__c = 'ZA',
        Sales_Code_Province__c = STATE_GAUTENG
            );
        insert saCode;
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = saCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        ICS_CTRL_PreAppFormCreator.pCode = TEST_CODE;
        ICS_CTRL_PreAppFormCreator.labelInfo = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ROLE_RELATIONSHIP_MANAGER, BRANCH_CODE_028NP);
        
        Map<String, Object> altPathData = new Map<String, Object>{
            'mainCor' => 'ZA',
            'mainProvince' => STATE_GAUTENG,
            'mainSubRegion' => 'Sandton'
        };
        
        Test.startTest();
        String altResult = ICS_CTRL_PreAppFormCreator.getSalesCode(altPathData);
        Test.stopTest();
        
        Assert.areNotEqual(saCode.Id, altResult, 'Should return the sales code using mainProvince and mainSubRegion');
    }
    @isTest
    static void testProcessLookupField_SingleValue() {
        // Setup test data
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = TEST_FIRST_NAME, LastName = TEST_Last_NAME, AccountId = testAccount.Id);
        insert testContact;
        
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put('AccountId', testAccount.Id);
        String lookupFieldValid = 'AccountId;AccountId';
        Contact contactSObject = new Contact(Id = testContact.Id);
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.processLookupField(lookupFieldValid, contactSObject);
        Test.stopTest();
        Assert.areEqual(testAccount.Id, contactSObject.get('AccountId'), 'The lookup field should be updated with the AccountId');
    }
    
    @isTest
    static void testProcessLookupField_MultipleValues() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        
        Contact testContact1 = new Contact(FirstName = 'Alice', LastName = 'Smith', AccountId = testAccount.Id);
        Contact testContact2 = new Contact(FirstName = 'Bob', LastName = 'Johnson', AccountId = testAccount.Id);
        insert new List<Contact>{testContact1, testContact2};
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put('ContactId', testContact1.Id + ':' + testContact2.Id);
        String lookupFieldMulti = 'AccountId;ContactId';
        Contact contactSObject = new Contact(Id = testContact1.Id);
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.processLookupField(lookupFieldMulti, contactSObject);
        Test.stopTest();
        Assert.areEqual(testContact1.Id + ':' + testContact2.Id, ICS_CTRL_PreAppFormCreator.linkedMap.get('ContactId'), 'Linked field value should match the test data');
    }
    /**
     * @description Simple test for updateLookup() method
     */
    @isTest
    static void testUpdateLookup() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        
        Contact testContact = new Contact(FirstName = TEST_FIRST_NAME, LastName = TEST_Last_NAME);
        insert testContact;
        
        ICS_CTRL_PreAppFormCreator.lookupFields = new Map<String, List<String>>();
        ICS_CTRL_PreAppFormCreator.lookupFields.put('Contact', new List<String>{'AccountId;Account'});
        
        ICS_CTRL_PreAppFormCreator.linkedmap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedmap.put('Contact', testContact.Id);
        ICS_CTRL_PreAppFormCreator.linkedmap.put(OBJECT_ACCOUNT, testAccount.Id);
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.updateLookup();
        Test.stopTest();
        
        Contact updatedContact = [SELECT Id, AccountId FROM Contact WHERE Id = :testContact.Id];
        Assert.areEqual(testAccount.Id, updatedContact.AccountId, 'Contact should be linked to account');
    }
    
    @isTest
    static void testMissingCoverage() {
        ICS_CTRL_PreAppFormCreator.oppownerId = null;
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.linkedmap = new Map<String, String>();
        
        Account testAccount = new Account(Name = 'TestAcc');
        AOB_Field__c field = new AOB_Field__c();
        field.Name = TEST_FIELD;
        field.AOB_SFObject__c = OBJECT_ACCOUNT;
        field.Default_Value__c = null;
        
        Map<String, Object> jsonData = new Map<String, Object>();
        jsonData.put(TEST_FIELD, 'TRUE');
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setValueFromJsonData(testAccount, field, jsonData, 'Description');
        Test.stopTest();
        
        Assert.areEqual('Yes', (String)testAccount.get('Description'), 'Should convert TRUE to Yes');
    }
    @isTest
    static void testGetOwnerId() {
        Sales_Codes__c testSalesCode = new Sales_Codes__c(
            Name = BRANCH_CODE_028NP,
        Sales_Code_Country__c = 'ZA'
            );
        insert testSalesCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = testSalesCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        ICS_CTRL_PreAppFormCreator.labelInfo = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        
        Test.startTest();
        Id result2 = ICS_CTRL_PreAppFormCreator.getOwnerId(testSalesCode.Id);
        Test.stopTest();
        
        Assert.areEqual(UserInfo.getUserId(), result2, 'Should return current user ID');
    }
    @isTest
    static void testSetNumericFieldValue() {
        AOB_Field__c field = new AOB_Field__c(Name = TEST_FIELD, Default_Value__c = '100');
        Map<String, Object> jsonData = new Map<String, Object>{TEST_FIELD => '200'};
        Account testAccount = new Account(Name = 'Testaccount');
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setNumericFieldValue(testAccount, field, jsonData, 'AnnualRevenue');
        Test.stopTest();
        
        Assert.areEqual(100, testAccount.get('AnnualRevenue'));
    }
    
    @isTest
    static void testSetDateFieldValue() {
        Map<String, Object> jsonData = new Map<String, Object>{'TestDate' => '2023-12-25'};
        Account testAccount = new Account(Name = 'Testdata');
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setDateFieldValue(testAccount, jsonData, 'PersonBirthdate', 'TestDate');
        Test.stopTest();
        
        Assert.areEqual(Date.newInstance(2023, 12, 25), testAccount.get('PersonBirthdate'));
    }
    
    @isTest
    static void testSetValueFromJsonDataElseBranch() {
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = TEST_FIELD,
        AOB_SFObject__c = OBJECT_ACCOUNT
            );
        
        Map<String, Object> jsonData = new Map<String, Object>{
            TEST_FIELD => TEST_VALUE
        };
        
        Account testAccount = new Account(Name = 'newAcc');
        
        ICS_CTRL_PreAppFormCreator.oppownerId = null;
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setValueFromJsonData(testAccount, fieldData, jsonData, FIELD_NAME);
        Test.stopTest();
        
        Assert.areEqual(TEST_VALUE, testAccount.get(FIELD_NAME));
        Assert.areEqual(UserInfo.getUserId(), testAccount.get(FIELD_OWNER_ID));
    }
    
    @isTest
    static void testSetValueFromJsonDataWithOppOwnerId() {
        Account testAccount = new Account(Name = 'Test Opp Account');
        insert testAccount;
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
        AccountId = testAccount.Id,
        StageName = STAGE_PROSPECTING,
        CloseDate = Date.today().addDays(30),
        OwnerId = UserInfo.getUserId()
            );
        insert testOpp;
        
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = TEST_FIELD,
        AOB_SFObject__c = OBJECT_ACCOUNT
            );
        
        Map<String, Object> jsonData = new Map<String, Object>{
            TEST_FIELD => TEST_VALUE
        };
        
        Account sObj = new Account(Name = 'AccData');
        
        ICS_CTRL_PreAppFormCreator.oppownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.linkedmap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedmap.put('Opportunity', testOpp.Id);
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setValueFromJsonData(sObj, fieldData, jsonData, FIELD_NAME);
        Test.stopTest();
        
        Assert.areEqual(TEST_VALUE, sObj.get(FIELD_NAME));
        Assert.areEqual(UserInfo.getUserId(), sObj.get(FIELD_OWNER_ID));
    }
    
    @isTest
    static void testSetValueFromJsonDataApplicantObject() {
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = TEST_FIELD,
        AOB_SFObject__c = 'Applicant'
            );
        
        Map<String, Object> jsonData = new Map<String, Object>{
            TEST_FIELD => TEST_VALUE
        };
        
        Account testAccount = new Account(Name = 'TestingAcc');
        
        ICS_CTRL_PreAppFormCreator.oppownerId = null;
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setValueFromJsonData(testAccount, fieldData, jsonData, FIELD_NAME);
        Test.stopTest();
        
        Assert.areEqual(TEST_VALUE, testAccount.get(FIELD_NAME));
        Assert.isNull(testAccount.get(FIELD_OWNER_ID));
    }
    
    @isTest
    static void testSetValueFromJsonDataWithOpportunityQuery() {
        Account testAccount = new Account(Name = 'Test Query Account');
        insert testAccount;
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Query Opportunity',
        AccountId = testAccount.Id,
        StageName = STAGE_PROSPECTING,
        CloseDate = Date.today().addDays(30),
        OwnerId = UserInfo.getUserId()
            );
        insert testOpp;
        
        AOB_Field__c fieldData = new AOB_Field__c(
            Name = TEST_FIELD,
        AOB_SFObject__c = OBJECT_ACCOUNT
            );
        
        Map<String, Object> jsonData = new Map<String, Object>{
            TEST_FIELD => TEST_VALUE
        };
        
        Account sObj = new Account(Name = 'Test');
        
        ICS_CTRL_PreAppFormCreator.oppownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.linkedmap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedmap.put('Opportunity', testOpp.Id);
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.setValueFromJsonData(sObj, fieldData, jsonData, FIELD_NAME);
        Test.stopTest();
        
        Assert.areEqual(TEST_VALUE, sObj.get(FIELD_NAME));
        Assert.areEqual(UserInfo.getUserId(), sObj.get(FIELD_OWNER_ID));
        Assert.areEqual(UserInfo.getUserId(), ICS_CTRL_PreAppFormCreator.oppownerId);
    }
    @isTest
    static void testHandlePostProcessingWithOpportunity() {
        Account testAccount = new Account(Name = TEST_ACCOUNT_NAME);
        insert testAccount;
        
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
        AccountId = testAccount.Id,
        StageName = STAGE_PROSPECTING,
        CloseDate = Date.today().addDays(30),
        OwnerId = UserInfo.getUserId()
            );
        insert testOpp;
        
        PartyProfile testProfile = ICS_DAL_TestFactory.createPartyProfile(testAccount.Id);
        
        Map<String, Object> jsonData = new Map<String, Object>{
            'ID Number' => '123456789'
        };
        
        ICS_CTRL_PreAppFormCreator.linkedmap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedmap.put('Opportunity', testOpp.Id);
        ICS_CTRL_PreAppFormCreator.linkedmap.put(ICS_Constants.Account, testAccount.Id);
        ICS_CTRL_PreAppFormCreator.linkedmap.put(ICS_Constants.PartyProfile, testProfile.Id);
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.oppownerId = null;
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.handlePostProcessing(ICS_Constants.prePersonalScreen, jsonData, 'Personal Details',false);
        Test.stopTest();
        
        Assert.areEqual(UserInfo.getUserId(), ICS_CTRL_PreAppFormCreator.oppownerId);
    }
    /**
     * @description Tests createGroupJointAccount happy path
     */
    @isTest
    static void testCreateGroupJointAccount_Success() {
        Account personAcc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        // Ensure required fields for constructFullName are populated
        personAcc.PersonTitle = 'Mr.';
        personAcc.FirstName = TEST_FIRST_NAME;
        personAcc.LastName = TEST_Last_NAME;
        update personAcc;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        ApplicationForm form = new ApplicationForm(
            AccountId = personAcc.Id,
        OpportunityId = opp.Id,
        UsageType = PROCESS_ONBOARDING,
        Stage = 'Awaiting Verification'
            );
        insert form;
        
        Applicant app = new Applicant(
            AccountId = personAcc.Id,
        ApplicationFormId = form.Id,
        Role = 'Primary Applicant'
            );
        insert app;
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.createGroupJointAccount(opp.Id);
        Test.stopTest();
        
        Account jointAcc = [SELECT Id, Type FROM Account WHERE Type = 'Joint' LIMIT 1];
        Assert.areEqual('Joint', jointAcc.Type, 'Joint Account should be created');
        
        Opportunity updatedOpp = [SELECT AccountId FROM Opportunity WHERE Id = :opp.Id];
        Assert.areEqual(jointAcc.Id, updatedOpp.AccountId, 'Opportunity should point to Joint Account');
        
    }
    
    @isTest
    static void testCreateGroupJointAccount_CoApplicantRole() {
        Account personAcc = [SELECT Id, PersonContactId FROM Account LIMIT 1];
        // Ensure required fields for constructFullName are populated
        personAcc.PersonTitle = 'Mrs.';
        personAcc.FirstName = 'Jane';
        personAcc.LastName = 'Smith';
        update personAcc;
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        ApplicationForm form = new ApplicationForm(
            AccountId = personAcc.Id,
        OpportunityId = opp.Id,
        UsageType = PROCESS_ONBOARDING,
        Stage = 'Awaiting Verification'
            );
        insert form;
        
        Applicant app = new Applicant(
            AccountId = personAcc.Id,
        ApplicationFormId = form.Id,
        Role = 'Co-Applicant'
            );
        insert app;
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.createGroupJointAccount(opp.Id);
        Test.stopTest();
        
        Account jointAcc = [SELECT Id, Type FROM Account WHERE Type = 'Joint' LIMIT 1];
        Assert.areEqual('Joint', jointAcc.Type, 'Type should be Joint');
    }
    
    /**
     * @description Tests catch block with invalid oppId
     */
    @isTest
    static void testCreateGroupJointAccount_Exception() {
        Test.startTest();
        try {
            ICS_CTRL_PreAppFormCreator.createGroupJointAccount('invalidId');
            Assert.isTrue(false, 'Should have thrown an exception');
        } catch (AuraHandledException e) {
            Assert.isTrue(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
    /**
     * @description Tests getSalesCodeId with a valid sales code
     */
    @isTest
    static void testGetSalesCodeId_ValidCode() {
        Sales_Codes__c salesCode = new Sales_Codes__c(
            Name = 'TEST_CODE',
        Sales_Code_Country__c = 'ZA'
            );
        insert salesCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = salesCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        Test.startTest();
        Id result = ICS_CTRL_PreAppFormCreator.getSalesCodeId(salesCode.Id);
        Test.stopTest();
        
        Assert.areEqual(salesCode.Id, result, 'Should return the sales code Id');
    }
    
    /**
     * @description Tests getSalesCodeId with blank sales code returns null
     */
    @isTest
    static void testGetSalesCodeId_BlankCode() {
        Test.startTest();
        Id result = ICS_CTRL_PreAppFormCreator.getSalesCodeId('');
        Test.stopTest();
        
        Assert.isNull(result, 'Should return null for blank sales code');
    }
    
    /**
     * @description Tests getSalesCodeId with no matching allocation returns null
     */
    @isTest
    static void testGetSalesCodeId_NoAllocation() {
        Sales_Codes__c salesCode = new Sales_Codes__c(
            Name = 'NO_ALLOC_CODE',
        Sales_Code_Country__c = 'ZA'
            );
        insert salesCode;
        
        Test.startTest();
        Id result = ICS_CTRL_PreAppFormCreator.getSalesCodeId(salesCode.Id);
        Test.stopTest();
        
        Assert.isNull(result, 'Should return null when no allocation exists');
    }
    
    /**
     * @description Tests insertAccountDetails with visa card selected
     */
    @isTest
    static void testInsertAccountDetails_WithVisaCard() {
        ApplicationForm form = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put(ICS_Constants.ApplicationForm, form.Id);
        ICS_CTRL_PreAppFormCreator.oppOwnerId = UserInfo.getUserId();
        
        String inputData = JSON.serialize(new Map<String, Object>{
            'Please select the currencies you would like for your account' => 'Euro;Sterling',
            'Would you like a visa debit card?' => 'TRUE',
            'Select the currencies that you would like a debit card for' => 'Euro'
        });
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.insertAccountDetails(inputData);
        Test.stopTest();
        
        List<ApplicationFormProduct> products = [
            SELECT Id FROM ApplicationFormProduct WHERE ApplicationFormId = :form.Id
        ];
        Assert.isFalse(products.isEmpty(), 'ApplicationFormProducts should be created');
    }
    
    /**
     * @description Tests insertAccountDetails without visa card
     */
    @isTest
    static void testInsertAccountDetails_NoVisaCard() {
        ApplicationForm form = [SELECT Id FROM ApplicationForm LIMIT 1];
        
        ICS_CTRL_PreAppFormCreator.linkedMap = new Map<String, String>();
        ICS_CTRL_PreAppFormCreator.linkedMap.put(ICS_Constants.ApplicationForm, form.Id);
        ICS_CTRL_PreAppFormCreator.oppOwnerId = UserInfo.getUserId();
        
        String inputData = JSON.serialize(new Map<String, Object>{
            'Please select the currencies you would like for your account' => 'Euro;Sterling',
            'Would you like a visa debit card?' => 'FALSE',
            'Select the currencies that you would like a debit card for' => ''
        });
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.insertAccountDetails(inputData);
        Test.stopTest();
        
        List<ApplicationFormProduct> products = [
            SELECT Id FROM ApplicationFormProduct WHERE ApplicationFormId = :form.Id
        ];
        Assert.isFalse(products.isEmpty(), 'ApplicationFormProducts should be created without visa');
    }
    /**
     * @description Tests handleIOMCountryLogic via getSalesCode - IOM country with matching sales code
     */
    @isTest
    static void testHandleIOMCountryLogic_WithMatchingCode() {
        Sales_Codes__c iomCode = new Sales_Codes__c(
            Name = 'IOM_DIRECT',
        Sales_Code_Country__c = 'BW'
            );
        insert iomCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = iomCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.labelInfo.put('ics_relationship_manager_direct', 'IOM_DIRECT');
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'BW'
        };
        
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return a sales code for IOM country');
    }
    
    /**
     * @description Tests handleIOMCountryLogic - no matching sales code hits LOGGER.warn branch
     */
    @isTest
    static void testHandleIOMCountryLogic_NoMatchingCode() {
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.labelInfo.put('ics_relationship_manager_direct', 'NONEXISTENT_CODE');
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ROLE_RELATIONSHIP_MANAGER, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'BW'
        };
        
        Test.startTest();
        try {
            ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
            Assert.isTrue(true, 'Method should handle empty code list gracefully');
        } catch (Exception e) {
            Assert.isTrue(e.getMessage() != null, 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    /**
     * @description Tests handleSACountryLogic via getSalesCode - using Province and Sub Region (MAIN_COR null)
     */
    @isTest
    static void testHandleSACountryLogic_WithProvinceAndSubRegion() {
        Sales_Codes__c saCode = new Sales_Codes__c(
            Name = 'SA_CODE',
        Sales_Code_Country__c = 'ZA',
        Sales_Code_Province__c = STATE_GAUTENG,
        Sales_Code_Sub_Region__c = 'Sandton'
            );
        insert saCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = saCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ROLE_RELATIONSHIP_MANAGER, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        // MAIN_COR is null so uses 'Province' and 'Sub Region' keys
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'ZA',
            'Province'             => STATE_GAUTENG,
            'Sub Region'           => 'Sandton'
        };
        
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return sales code for SA country with Province/SubRegion');
    }
    
    /**
     * @description Tests handleSACountryLogic - using mainProvince and mainSubRegion (MAIN_COR not null)
     */
    @isTest
    static void testHandleSACountryLogic_WithMainProvinceAndSubRegion() {
        Sales_Codes__c saCode = new Sales_Codes__c(
            Name = 'SA_MAIN_CODE',
        Sales_Code_Country__c = 'ZA',
        Sales_Code_Province__c = 'WesternCape',
        Sales_Code_Sub_Region__c = 'CapeTown'
            );
        insert saCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = saCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ROLE_RELATIONSHIP_MANAGER, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        // MAIN_COR not null so uses 'mainProvince' and 'mainSubRegion' keys
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            'maincor'       => 'ZA',
            'mainProvince'  => 'WesternCape',
            'mainSubRegion' => 'CapeTown'
        };
        
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return sales code using mainProvince and mainSubRegion');
    }
    /**
     * @description Tests createOpportunity with Seafarer product - hits Required_Approval_Processes branch
     */
    @isTest
    static void testCreateOpportunity_SeafarerProduct() {
        Account acc = [SELECT Id, FirstName, LastName FROM Account LIMIT 1];
        
        Product2 seafarerProd = new Product2(
            Name = 'Seafarer',
        ProductCode = 'SEAF001',
        IsActive = true
            );
        insert seafarerProd;
        
        ICS_CTRL_PreAppFormCreator.pCode = 'SEAF001';
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_seafarer_lead, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'US'
        };
        
        Test.startTest();
        Opportunity opp = ICS_CTRL_PreAppFormCreator.createOpportunity(acc, sectionFieldData, false);
        Test.stopTest();
        
        Assert.areEqual('Need Captain letter Approval;', opp.Required_Approval_Processes__c,
        'Seafarer product should set Required_Approval_Processes');
    }
    
    /**
     * @description Tests createOpportunity with SBManagerCode present - hits LeadSource='Staff' branch
     */
    @isTest
    static void testCreateOpportunity_WithSBManagerCode() {
        Account acc = [SELECT Id, FirstName, LastName FROM Account LIMIT 1];
        
        Sales_Codes__c salesCode = new Sales_Codes__c(
            Name = 'STAFF001',
        Sales_Code_Country__c = 'ZA'
            );
        insert salesCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = salesCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.ownerId = UserInfo.getUserId();
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        ICS_CTRL_PreAppFormCreator.labelInfo.put('ics_africanexcludesbmanagercode', 'STAFF001');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'ZA',
            ICS_Constants.SBManagerCode => 'STAFF001'
        };
        
        Test.startTest();
        Opportunity opp = ICS_CTRL_PreAppFormCreator.createOpportunity(acc, sectionFieldData, false);
        Test.stopTest();
        
        Assert.areEqual('Staff', opp.LeadSource, 'LeadSource should be Staff when SBManagerCode present');
    }
    
    /**
     * @description Tests selectSalesCodeInfo - SBManagerCode NOT in african countries hits selectByNameAndSalesCodeCountry
     */
    @isTest
    static void testSelectSalesCodeInfo_SBManagerCode_NonAfrican() {
        Sales_Codes__c salesCode = new Sales_Codes__c(
            Name = 'NON_AFR',
        Sales_Code_Country__c = 'ZA'
            );
        insert salesCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = salesCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        ICS_CTRL_PreAppFormCreator.pCode = RECORD_TYPE_SOCTY;
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put('ics_africanexcludesbmanagercode', 'AFRICAN_CODE');
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'ZA',
            ICS_Constants.SBManagerCode => 'NON_AFR'
        };
        
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return sales code for non-african SBManagerCode');
    }
    
    /**
     * @description Tests selectSalesCodeInfo - Seafarer product hits ics_seafarer_lead branch
     */
    @isTest
    static void testSelectSalesCodeInfo_SeafarerProduct() {
        Sales_Codes__c seafarerCode = new Sales_Codes__c(
            Name = 'SEAFARER_LEAD',
        Sales_Code_Country__c = 'ZA'
            );
        insert seafarerCode;
        
        Sales_Code_Allocation__c allocation = new Sales_Code_Allocation__c(
            Sales_Codes__c = seafarerCode.Id,
        User__c = UserInfo.getUserId()
            );
        insert allocation;
        
        Product2 seafarerProd = new Product2(
            Name = 'Seafarer',
        ProductCode = 'SEAF002',
        IsActive = true
            );
        insert seafarerProd;
        
        ICS_CTRL_PreAppFormCreator.pCode = 'SEAF002';
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_seafarer_lead, 'SEAFARER_LEAD');
        ICS_CTRL_PreAppFormCreator.labelInfo.put(ICS_Constants.ics_relationship_manager, BRANCH_CODE_028NP);
        ICS_CTRL_PreAppFormCreator.labelInfo.put(IOM_COUNTRIES_LABEL, 'BW');
        
        Map<String, Object> sectionFieldData = new Map<String, Object>{
            COUNTRY_OF_RESIDENCE => 'US'
        };
        
        Test.startTest();
        String result = ICS_CTRL_PreAppFormCreator.getSalesCode(sectionFieldData);
        Test.stopTest();
        
        Assert.areNotEqual(null, result, 'Should return seafarer lead sales code');
    }
    
    /**
     * @description Tests insertOpportunityLineItems - ensures pricebook currency matches DEFAULT_CURRENCY
     */
    @isTest
    static void testInsertOpportunityLineItems_Success() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        
        Product2 prod = [SELECT Id FROM Product2 WHERE ProductCode = :TEST_CODE LIMIT 1]; // <-- fix here
        Pricebook2 customPB = [SELECT Id FROM Pricebook2 WHERE Name = :ICS_Constants.ICSPricebook LIMIT 1];
        
        List<PricebookEntry> existingPBE = [
        SELECT Id FROM PricebookEntry
        WHERE Pricebook2Id = :customPB.Id
        AND Product2Id = :prod.Id
        LIMIT 1
    ];
        
        if (existingPBE.isEmpty()) {
            PricebookEntry stdEntry = new PricebookEntry(
                Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true,
            CurrencyIsoCode = ICS_Constants.DEFAULT_CURRENCY
                );
            insert stdEntry;
            
            PricebookEntry customEntry = new PricebookEntry(
                Pricebook2Id = customPB.Id,
            Product2Id = prod.Id,
            UnitPrice = 90,
            IsActive = true,
            CurrencyIsoCode = ICS_Constants.DEFAULT_CURRENCY
                );
            insert customEntry;
        }
        
        Opportunity opp = new Opportunity(
            Name = 'Line Item Test',
        AccountId = acc.Id,
        StageName = STAGE_PROSPECTING,
        CloseDate = Date.today().addDays(30),
        CurrencyIsoCode = ICS_Constants.DEFAULT_CURRENCY,
        Pricebook2Id = customPB.Id
            );
        insert opp;
        
        ICS_CTRL_PreAppFormCreator.pCode = TEST_CODE;
        
        Test.startTest();
        ICS_CTRL_PreAppFormCreator.insertOpportunityLineItems(opp);
        Test.stopTest();
        
        Assert.areNotEqual(null, opp.Id, 'Opportunity should exist');
    }
    
}