/**
 * @description Class used to create test data for SBO UK Project
 * Story: SFP-36390
 * @author Ikyatha Naidu
 * @date 14/12/2023
 * @last modified on: 21-10-2024
 * @last modified by: Tushar Walse
 */
@SuppressWarnings('PMD.ExcessiveClassLength, PMD.ExcessivePublicCount')
public Inherited sharing class ICS_DAL_TestFactory {
    
    private static final String DEFAULT_LANGUAGE = 'EN';
    private static final String DEFAULT_EXTERNAL_ID = '1234';
    private static final String DEFAULT_SUBTITLE = 'Enter the following information';
    private static final String DEFAULT_CURRENCY = 'GBP';
  	 private ICS_DAL_TestFactory(){
        //Private Constructor for instantiation
    }
    /**
     * @description Create flow screens
     * @return List of AOB_FlowScreen__c records
     */ 
    public static List<AOB_FlowScreen__c> createScreen() {
        if (!Schema.sObjectType.AOB_FlowScreen__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_FlowScreen__c records');
        }
        List<AOB_FlowScreen__c> listScreen = new List<AOB_FlowScreen__c>{
            new AOB_FlowScreen__c(
                Name = 'ICS UK Pre-Account Details',
                AOB_title__c = 'ICS UK Pre-Account Details', 
                AOB_subtitle__c = DEFAULT_SUBTITLE, 
                AO_ExternalId__c = DEFAULT_EXTERNAL_ID,
                AOB_Screen_Sequence__c = 1, 
                AOB_Language__c = DEFAULT_LANGUAGE
            )
        };
        insert listScreen;
        return listScreen;    
    }


    /**
     * @description  create screen fields
     * @param sectionId
     * @return   list<AOB_Field__c>
     */
    @testvisible
    public static List<AOB_Field__c> createFields(Id sectionId) {
        List<AOB_Field__c> listField = new List<AOB_Field__c>();
        
        listField.addAll(createBasicFields(sectionId));
        listField.addAll(createAdditionalFields(sectionId));
        listField.addAll(createTypeListFields(sectionId));
        
        insert listField;
        
        updateChildParentRelationship();
        
        return listField;
    }
    
    private static List<AOB_Field__c> createBasicFields(Id sectionId) {
        return new List<AOB_Field__c>{
            new AOB_Field__c(AOB_Section__c=sectionId, Name='TRUE', AOB_Type__c='Checkbox Group', AOB_sequence__c='1', AOB_Label__c='TRUE', AOB_SFObject__c='Assessment', AOB_SFField__c='AccountId'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='cellphone', AOB_Type__c='Radio', AOB_sequence__c='2', AOB_Label__c='Do you have a cellphone?', AOB_ShowAtScreenLoad__c=true, AOB_MRITable__c='PER_CLASSIF'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Email', AOB_Type__c='Email', AOB_sequence__c='3', AOB_Label__c='Email Address'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Check Box', AOB_Type__c='Checkbox', AOB_sequence__c='4', AOB_Label__c='CheckBox'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Currency', AOB_Type__c='Currency', AOB_sequence__c='5', AOB_SFField__c='AnnualRevenue', AOB_Label__c='Currency'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='ConsentBoxt', AOB_Type__c='ConsentBox', AOB_sequence__c='6', AOB_Label__c='ConsentBox'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='TextReadOnly', AOB_Type__c='TextReadOnly', AOB_sequence__c='7', AOB_Label__c='TextReadOnly'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Combobox', AOB_Type__c='Combobox', AOB_sequence__c='8', AOB_Label__c='Combobox'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Tax', AOB_Type__c='Tax', AOB_sequence__c='9', AOB_Label__c='Tax'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='MultiSelectSearch', AOB_Type__c='MultiSelectSearch', AOB_sequence__c='10', AOB_Label__c='MultiSelectSearch')
        };
    }
    
    private static List<AOB_Field__c> createAdditionalFields(Id sectionId) {
        return new List<AOB_Field__c>{
            new AOB_Field__c(AOB_Section__c=sectionId, Name='memberdetails', AOB_Type__c='memberdetails', AOB_sequence__c='11', AOB_Label__c='memberdetails'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='directordetails', AOB_Type__c='directordetails', AOB_sequence__c='12', AOB_Label__c='directordetails'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Table', AOB_Type__c='Table', AOB_sequence__c='13', AOB_Label__c='Table'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='File Upload', AOB_Type__c='File Upload', AOB_sequence__c='14', AOB_Label__c='File Upload'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='MultiSelectReadonly', AOB_Type__c='MultiSelectReadonly', AOB_sequence__c='15', AOB_Label__c='MultiSelectReadonly'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='PicklistWithInput', AOB_Type__c='PicklistWithInput', AOB_sequence__c='16', AOB_Label__c='PicklistWithInput'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Sub Accordian', AOB_Type__c='Sub Accordian', AOB_sequence__c='17', AOB_Label__c='Sub Accordian'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Add Accordian', AOB_Type__c='Add Accordian', AOB_sequence__c='17', AOB_Label__c='Add Accordian'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='informalModal', AOB_Type__c='informalModal', AOB_sequence__c='17', AOB_Label__c='informalModal'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='isdataprivacy', AOB_Type__c='isdataprivacy', AOB_sequence__c='17', AOB_Label__c='isdataprivacy'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Card', AOB_Type__c='Card', AOB_sequence__c='17', AOB_Label__c='Card'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Addbutton', AOB_Type__c='Addbutton', AOB_sequence__c='17', AOB_Label__c='Addbutton'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Label', AOB_Type__c='Label', AOB_sequence__c='17', AOB_Label__c='Label'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Accordian', AOB_Type__c='Accordian', AOB_sequence__c='17', AOB_Label__c='Accordian'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='Text Area', AOB_Type__c='Lookup', AOB_sequence__c='17', AOB_Label__c='Text Area'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='TRUE', AOB_Type__c='Date', AOB_sequence__c='17', AOB_SFObject__c='Account', AOB_SFField__c='personBirthDate', AOB_Label__c='Date of birth'),
            new AOB_Field__c(AOB_Section__c=sectionId, Name='TRUE', AOB_Type__c='date', AOB_sequence__c='19', AOB_Label__c='TRUE', AOB_SFObject__c='IdentityDocument', AOB_SFField__c='AccountId')
        };
    }
    
    private static List<AOB_Field__c> createTypeListFields(Id sectionId) {
        List<AOB_Field__c> fields = new List<AOB_Field__c>();
        List<String> typeList = new List<String>{
            'Addbutton', 'Accordian', 'Label', 'Percent', 'Lookup', 'Text Area', 'isExpDate',
            'photosignature', 'Accordian Count', 'Textfunds', 'isMutipleFiles',
            'Pleasenote', 'defaultcountry', 'Textdefault', 'MasterDetail', 'Empty',
            'ComboboxReadonly'
        };
        
        for(Integer i = 0; i < typeList.size(); i++) {
            fields.add(new AOB_Field__c(
                AOB_Section__c = sectionId, 
                Name = typeList[i], 
                AOB_Type__c = typeList[i], 
                AOB_sequence__c = String.valueOf(20 + i), 
                AOB_Label__c = typeList[i]
            ));
        }
        return fields;
    }
    
    private static void updateChildParentRelationship() {
        AOB_Field__c parent = [SELECT Id FROM AOB_Field__c WHERE AOB_sequence__c = '11' LIMIT 1];
        AOB_Field__c child = [SELECT Id FROM AOB_Field__c WHERE AOB_sequence__c = '12' LIMIT 1];
        child.AOB_Parent__c = parent.Id;
        update child;
    }
    /**
     * @description Create financial details screen
     * @return AOB_FlowScreen__c record
     */
    public static AOB_FlowScreen__c createFinancialDetailsScreen() {
        if (!Schema.sObjectType.AOB_FlowScreen__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_FlowScreen__c records');
        }
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = 'ICS UK Financial Details',
            AOB_title__c = 'ICS UK Financial Details',
            AOB_subtitle__c = DEFAULT_SUBTITLE,
            AO_ExternalId__c = DEFAULT_EXTERNAL_ID,
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = DEFAULT_LANGUAGE
        );
        insert screen;
        return screen;    
    }

    /**
     * @description Create flow screen based on screen name
     * @param screenName Name of the screen
     * @return AOB_FlowScreen__c record
     */
    public static AOB_FlowScreen__c createFlowscreen(String screenName) {
        if (!Schema.sObjectType.AOB_FlowScreen__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_FlowScreen__c records');
        }
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(
            Name = screenName,
            AOB_title__c = screenName,
            AOB_subtitle__c = DEFAULT_SUBTITLE,
            AO_ExternalId__c = DEFAULT_EXTERNAL_ID,
            AOB_Screen_Sequence__c = 1,
            AOB_Language__c = DEFAULT_LANGUAGE
        );
        insert screen;
        return screen;
    }

    /**
     * @description Create screen section
     * @param screen Parent screen record
     * @param sectionName Name of the section
     * @return AOB_ScreenSection__c record
     */
    public static AOB_ScreenSection__c createScreenSection(AOB_FlowScreen__c screen, String sectionName) {
        if (!Schema.sObjectType.AOB_ScreenSection__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_ScreenSection__c records');
        }
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screen.Id,
            Name = sectionName,
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = sectionName
        );
        insert section;
        return section;
    }

    /**
     * @description Create financial details section
     * @param screenId ID of the parent screen
     * @return AOB_ScreenSection__c record
     */
    public static AOB_ScreenSection__c createFinancialDetailsSection(Id screenId) {
        if (!Schema.sObjectType.AOB_ScreenSection__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_ScreenSection__c records');
        }
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(
            AOB_Screen__c = screenId,
            Name = 'Trusts',
            AOB_ExternalId__c = 'Q1',
            AOB_Title__c = 'Trusts'
        );
        insert section;
        return section;    
    }

    /**
     * @description Create application form fields
     */
    public static void createApplicationFormfields() {
        if (!Schema.sObjectType.AOB_Field__c.isCreateable() || 
            !Schema.sObjectType.AssessmentQuestion.isCreateable() ||
            !Schema.sObjectType.AssessmentQuestionVersion.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create required records');
        }
       
        AOB_FlowScreen__c screen = createFlowscreen('ICS UK Personal Details');
        AOB_ScreenSection__c section = createScreenSection(screen, 'Personal Details');

        List<AOB_Field__c> fields = new List<AOB_Field__c>();
        fields.add(createField(section.Id, 'GiftW', 'Text', 'GiftW', 'GiftW'));
        fields.add(createField(section.Id, 'GiftV', 'Text', 'GiftV', 'GiftV'));

        fields.addAll(createStandardFields(section.Id));
        insert fields;

        createAssessmentQuestion();
    }

    private static AOB_Field__c createField(Id sectionId, String name, String type, String label, String parentControllingValue) {
        return new AOB_Field__c(
            AOB_Section__c = sectionId,
            Name = name,
            AOB_Type__c = type,
            AOB_Label__c = label,
            AOB_ParentControllingValue__c = parentControllingValue
        );
    }
    
    public static AssessmentQuestionVersion createAssessmentQuestionVersion() {
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Select all assets and income*',
            QuestionCategory = 'Financial'
        );
        insert question;

        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Select all assets and income*',
            Name = 'Select all assets and income*',
            IsActive = true
        );
        insert qv;
        return qv;
    }

    Public static List<AOB_Field__c> createStandardFields(Id sectionId) {
        List<AOB_Field__c> standardFields = new List<AOB_Field__c>();
        Map<String, String> fieldMap = new Map<String, String>{
            'Position' => 'FinServ__Position__c',
            'sharesCompany' => 'Is_Future_Fund__c',
            'Name of Employer' => 'Name',
            'Annual Income' => 'FinServ__AnnualIncome__c',
            'End Date' => 'FinServ__EndDate__c',
            'In Employment Alongside Studying' => 'In_Employment_Alongside_Studying__c'
        };

        for (String fieldName : fieldMap.keySet()) {
            standardFields.add(new AOB_Field__c(
                AOB_SFObject__c = 'FinServ__Employment__c',
                AOB_Section__c = sectionId,
                Name = fieldName,
                AOB_SFField__c = fieldMap.get(fieldName)
            ));
        }

        return standardFields;
    }

    public static void createAssessmentQuestion() {
        AssessmentQuestion question = new AssessmentQuestion(
            DataType = 'Text',
            DeveloperName = 'ssds',
            Name = 'Select all assets and income*',
            QuestionCategory = 'Financial'
        );
        insert question;

        AssessmentQuestionVersion qv = new AssessmentQuestionVersion(
            AssessmentQuestionId = question.Id,
            Questiontext = 'Select all assets and income*',
            Name = 'Select all assets and income*',
            IsActive = true
        );
        insert qv;
    }

    /**
     * @description Create financial details field
     * @param sfObject Salesforce object API name
     * @param name Field name
     * @param sfField Salesforce field API name
     * @param sectionId Section ID
     * @return AOB_Field__c record
     */
    public static AOB_Field__c createFinancialDetailsField(String sfObject, String name, String sfField, Id sectionId) {
        if (!Schema.sObjectType.AOB_Field__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_Field__c records');
        }
        AOB_Field__c fieldMapping = new AOB_Field__c(
            AOB_SFObject__c = sfObject,
            Name = name,
            AOB_SFField__c = sfField,
            AOB_Section__c = sectionId
        );
        insert fieldMapping;
        return fieldMapping;    
    }

    /**
     * @description Create screen sections
     * @param screenId Screen ID
     * @return List of AOB_ScreenSection__c records
     */
    public static List<AOB_ScreenSection__c> createSection(Id screenId) {
        if (!Schema.sObjectType.AOB_ScreenSection__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_ScreenSection__c records');
        }
        List<AOB_ScreenSection__c> sections = new List<AOB_ScreenSection__c>{
            new AOB_ScreenSection__c(AOB_Screen__c = screenId, Name = 'Account Details', AOB_ExternalId__c = 'Q1', AOB_Rank__c = 1, AOB_Title__c = 'Account Details'),
            new AOB_ScreenSection__c(AOB_Screen__c = screenId, Name = 'Assets and Income', AOB_ExternalId__c = 'Q1', AOB_Rank__c = 2, AOB_Title__c = 'Assets and Income'),
            new AOB_ScreenSection__c(AOB_Screen__c = screenId, Name = 'PartyProfile', AOB_ExternalId__c = 'Q1', AOB_Rank__c = 3, AOB_Title__c = 'PartyProfile')
        };
        insert sections;
        return sections;    
    }

    /**
     * @description Create screen fields from JSON
     * @param jsonString JSON string containing field data
     * @param sectionId Section ID
     * @return List of AOB_Field__c records
     */
    public static List<AOB_Field__c> createField(String jsonString, Id sectionId) {
        if (!Schema.sObjectType.AOB_Field__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_Field__c records');
        }
        List<Object> deserializedList = (List<Object>) JSON.deserializeUntyped(jsonString);
        List<AOB_Field__c> aobFieldRecords = new List<AOB_Field__c>();

        for (Object obj : deserializedList) {
            Map<String, Object> fieldMap = (Map<String, Object>) obj;
            AOB_Field__c record = new AOB_Field__c(AOB_Section__c = sectionId);

            for (String key : fieldMap.keySet()) {
                record.put(key, fieldMap.get(key));
            }

            aobFieldRecords.add(record);
        }

        insert aobFieldRecords;
        return aobFieldRecords;
    }

    /**
     * @description Create reference data
     * @return List of AOB_ReferencedData__c records
     */
    public static List<AOB_ReferencedData__c> createRefData() {
        if (!Schema.sObjectType.AOB_ReferencedData__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AOB_ReferencedData__c records');
        }
        List<AOB_ReferencedData__c> refDataList = new List<AOB_ReferencedData__c>{
            new AOB_ReferencedData__c(Name = 'Yes', AOB_Default__c = true, AOB_SAPField__c = 'PER_CLASSIF', AOB_isActive__c = true, AOB_Code__c = 'Yes', AOB_Language__c = 'en_US'),
            new AOB_ReferencedData__c(Name = 'No', AOB_Default__c = true, AOB_SAPField__c = 'PER_CLASSIF', AOB_isActive__c = true, AOB_Code__c = 'false', AOB_Language__c = 'en_US')
        };
        insert refDataList;
        return refDataList;    
    }

    /**
     * @description Create a contact
     * @return Contact record
     */
    public static Contact createContact() {
        if (!Schema.sObjectType.Contact.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Contact records');
        }
        Contact testContact = new Contact(
            Email = 'tehomax797@apn7.com',
            LastName = 'pingTest'
        );
        insert testContact;
        return testContact;
    }

    /**
     * @description Create a contact with Ping ID
     * @return Contact record
     */
    public static Contact createContactping() {
        if (!Schema.sObjectType.Contact.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Contact records');
        }
        Contact contact = new Contact(
            FirstName = 'Steve',
            LastName = 'Jones',
            Email = 'steve.jones@gmail.com',
            Ping_Id__c = '12345'
        );
        insert contact;
        return contact;
    }

    /**
     * @description Create an account
     * @return Account record
     */
    public static Account createAccount() {
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Account records');
        }
        Id personAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ICS_Applicant').getRecordTypeId();
        Account account = new Account(
            FirstName = 'TestACC',
            LastName = 'testet',
            AOB_CommerceSiteId__c = 'SB-COZA',
            AOB_TECH_CCCustomerId__c = 'XXX',
            FinServ__Gender__pc = 'Male',
            Phone = '+27823309876',
            PersonEmail = 'test@example.com',
            ExternalCIFUUID__c = 'RandonBPGUID',
            RecordTypeId = personAccountRecordTypeId
        );
        insert account;
        return account;
    }

    /**
     * @description Create an opportunity
     * @param accId Account ID
     * @return Opportunity record
     */
    public static Opportunity createOpportunity(Id accId) {
        if (!Schema.sObjectType.Opportunity.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Opportunity records');
        }
        if (!Schema.sObjectType.Sales_Codes__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Sales_Codes__c records');
        }
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ICS Applicant').getRecordTypeId();

        Opportunity opp = new Opportunity(
            AccountId = accId,
            Name = 'tesstopp',         
            StageName = 'New',
            RecordTypeId = recTypeId,
            CloseDate = Date.today()
        );
        Sales_Codes__c allocatedCode = new Sales_Codes__c();
        allocatedCode.Sales_Code_Country__c = 'ZA';
        allocatedCode.Name = '035WC';
        insert allocatedCode;
        opp.Sales_Code__c = allocatedCode.Id;

        insert opp;
        return opp;
    }

    /**
     * @description Create an account without record type
     * @return Account record
     */
    public static Account createAccountwithoutRecordType() {
        if (!Schema.sObjectType.Account.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Account records');
        }
        Account acc = new Account(
            FirstName = 'John',
            MiddleName = 'Michael',
            LastName = 'Johns'
        );
        insert acc;
        return acc;
    }

    /**
     * @description Create a party profile without record type
     * @return PartyProfile record
     */
    public static PartyProfile createPartyProfileWithoutRecordType(string profileId,string trustId) {
        if (!Schema.sObjectType.PartyProfile.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyProfile records');
        }
        PartyProfile profile = new PartyProfile(Name = 'PEP',relatedpartyprofileId=profileId , Party_Assets_Funds__c=trustId);
        insert profile;
        return profile;
        
    }

    /**
     * @description Create a party profile
     * @param accId Account ID
     * @return PartyProfile record
     */
    public static PartyProfile createPartyProfile(Id accId) {
        if (!Schema.sObjectType.PartyProfile.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyProfile records');
        }
        Id recTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Party Profile').getRecordTypeId();
        PartyProfile profile = new PartyProfile(
            Name = 'record',
            WI_MaritialStatus__c='Married',
            Has_different_First_Middle_Family_Name__c='Yes',
            AccountId = accId,
            
            Has_Former_Name__c ='Yes',
            RecordTypeId = recTypeId
        );
        insert profile;
        return profile;
    }

    /**
     * @description Create a party asset fund
     * @param partyProfileId Party profile ID
     * @return Party_Assets_Funds__c record
     */
    public static Party_Assets_Funds__c createPartyAssetFunds(Id partyProfileId) {
        if (!Schema.sObjectType.Party_Assets_Funds__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Party_Assets_Funds__c records');
        }
        Party_Assets_Funds__c assetFund = new Party_Assets_Funds__c(
            Name = 'Test Fund',
            Asset_Value__c = 1000,
            Party_Profile__c = partyProfileId,
            Type__c = 'Owned Property',
            Applicant_Share__c = 50, 
            Type_of_Property__c = 'Rental',
            Is_Future_Fund__c = true,
            TrustDeed_or_Letter_of_wishes__c = 'Both'
        );
        insert assetFund;
        return assetFund;
    }

    /**
     * @description Create a business owner party profile
     * @param accId Account ID
     * @return PartyProfile record
     */
    public static PartyProfile createBusinessOwnerPartyProfile(Id accId) {
        if (!Schema.sObjectType.PartyProfile.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyProfile records');
        }
        Id recTypeId = Schema.SObjectType.PartyProfile.getRecordTypeInfosByName().get('ICS Additional Business Owner').getRecordTypeId();
        PartyProfile profile = new PartyProfile(
            Name = 'record',
            AccountId = accId,
            RecordTypeId = recTypeId 
        );
        insert profile;
        return profile;
    }

    /**
     * @description Create a party profile address
     * @param partyProfileId Party profile ID
     * @param addressType Address type
     * @param dateMoveIn Move-in date
     * @param dateMoveOut Move-out date
     * @return PartyProfileAddress record
     */
    public static PartyProfileAddress createPartyProfileAddress(Id partyProfileId, String addressType, Date dateMoveIn, Date dateMoveOut) {
        if (!Schema.sObjectType.PartyProfileAddress.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyProfileAddress records');
        }
        PartyProfileAddress address = new PartyProfileAddress(
            PartyProfileId = partyProfileId,
            Name = 'Address',
            Date_Move_In__c = dateMoveIn,
            Date_Move_Out__c = dateMoveOut,
            AddressType = addressType
        );
        insert address;
        return address;
    }

    /**
     * @description Create a test party asset fund
     * @param partyProfileId Party profile ID
     * @param type Asset type
     * @param fundRecordType Record type ID
     * @return Party_Assets_Funds__c record
     */
    public static Party_Assets_Funds__c createTestDataPartyAssetFund(Id partyProfileId, String type, Id fundRecordType) {
        if (!Schema.sObjectType.Party_Assets_Funds__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Party_Assets_Funds__c records');
        }
        Party_Assets_Funds__c assetFund = new Party_Assets_Funds__c(
            Name = 'test',
            Party_Profile__c = partyProfileId,
            Initial_Deposit__c = 30000,
            Type__c = type,
            Is_Trust_Beneficiary__c = true,
            RecordTypeId = fundRecordType
        );
        insert assetFund;
        return assetFund;
    }

    /**
     * @description Create a contact point phone
     * @param accId Account ID
     * @return ContactPointPhone record
     */
    public static ContactPointPhone createPointPhone(Id accId) {
        if (!Schema.sObjectType.ContactPointPhone.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ContactPointPhone records');
        }
        ContactPointPhone phone = new ContactPointPhone(
            TelephoneNumber = '9032296917',
            ParentId = accId
        );
        insert phone;
        return phone;
    }

    /**
     * @description Create a contact point email
     * @param accId Account ID
     * @return ContactPointEmail record
     */
    public static ContactPointEmail createContactPointEmail(Id accId) {
        if (!Schema.sObjectType.ContactPointEmail.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ContactPointEmail records');
        }
        ContactPointEmail email = new ContactPointEmail(
            EmailAddress = 'test@gmail.com',
            ParentId = accId
        );
        insert email;
        return email;
    }

    /**
     * @description Create a product
     * @return Product2 record
     */
    public static Product2 createProduct2() {
        if (!Schema.sObjectType.Product2.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Product2 records');
        }
        Product2 product = 
            new Product2(
            ProductCode = 'SOCTY',
            AOB_Memo_Code__c = 'SOCTY',
            Name = 'test test',
            CurrencyIsoCode = DEFAULT_CURRENCY
        );
        
         insert product;
        return product;
    }

    /**
     * @description Create an employment record
     * @param accId Account ID
     * @return FinServ__Employment__c record
     */
    public static FinServ__Employment__c createEmployment(Id accId) {
        if (!Schema.sObjectType.FinServ__Employment__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create FinServ__Employment__c records');
        }
        Id employmentRecordType = Schema.SObjectType.FinServ__Employment__c.getRecordTypeInfosByName().get('Current').getRecordTypeId();
        FinServ__Employment__c employment = new FinServ__Employment__c(
            Name = 'Test Corp',
            Person_Account__c = accId,
            Only_employment__c = 'No',
            FinServ__Position__c='Manager',
            FinServ__AnnualIncome__c=100000,
            RecordTypeId = employmentRecordType
        );
        insert employment;
        return employment;
    }

    /**
     * @description Create an assessment
     * @param accId Account ID
     * @return Assessment record
     */
    public static Assessment createAssessment(Id accId) {
        if (!Schema.sObjectType.Assessment.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Assessment records');
        }
        Assessment assessment = new Assessment(
            AccountId = accId,
            Name = 'test',
            AssessmentStatus = 'In Progress'
        );
        insert assessment;
        return assessment;
    }

    /**
     * @description Create an assessment question response
     * @param assessmentId Assessment ID
     * @param questionVersionId Assessment question version ID
     * @return AssessmentQuestionResponse record
     */
    public static AssessmentQuestionResponse createAssessmentQuestionResponse(Id assessmentId, Id questionVersionId) {
        if (!Schema.sObjectType.AssessmentQuestionResponse.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create AssessmentQuestionResponse records');
        }
        AssessmentQuestionResponse response = new AssessmentQuestionResponse(
            Name = 'Trusts',
            AssessmentId = assessmentId,
            AssessmentQuestionId = questionVersionId,
            ResponseText = 'FALSE'
        );
        insert response;
        return response;
    }

    /**
     * @description Create an identity document
     * @param accId Account ID
     * @param partyId Party ID
     * @return IdentityDocument record
     */
    public static IdentityDocument createIdentityDocument(Id accId, Id partyId) {
        if (!Schema.sObjectType.IdentityDocument.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create IdentityDocument records');
        }
        IdentityDocument identity = new IdentityDocument(
            Name = 'test',
            RelatedLegalEntityId = accId,
            IdDocumentType = '2',
            PartyProfileId = partyId
        );
        insert identity;
        return identity;
    }

    /**
     * @description Create a party identity verification
     * @param partyProfileId Party profile ID
     * @return PartyIdentityVerification record
     */
    public static PartyIdentityVerification createPartyIdentity(Id partyProfileId) {
        if (!Schema.sObjectType.PartyIdentityVerification.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyIdentityVerification records');
        }
        PartyIdentityVerification verification = new PartyIdentityVerification(
            Name = 'record',
            PartyProfileId = partyProfileId,
            ThirdPartyVerfdentifier = '5804832'
        );
        insert verification;
        return verification;
    }

    /**
     * @description Create an application form
     * @param accId Account ID
     * @return ApplicationForm record
     */
    
    public static ApplicationForm createApplicationForm(string accId) {
        if (!Schema.sObjectType.ApplicationForm.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ApplicationForm records');
        }
        ApplicationForm form = new ApplicationForm(
            AccountId = accId,
            UsageType = 'Onboarding',
            Stage = 'Awaiting Verification'
        );
        insert form;
        return form;
    }

    /**
     * @description Create an application form with opportunity
     * @param accId Account ID
     * @param oppId Opportunity ID
     * @return ApplicationForm record
     */
    public static ApplicationForm createApplicationForm(Id accId, Id oppId) {
        if (!Schema.sObjectType.ApplicationForm.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ApplicationForm records');
        }
        ApplicationForm form = new ApplicationForm(
            AccountId = accId,
            OpportunityId = oppId,
            UsageType = 'Onboarding',
            Stage = 'Awaiting Verification'
        );
        insert form;
        return form;
    }

    /**
     * @description Create content versions
     * @return List of ContentVersion records
     */
    public static List<ContentVersion> createContentVersion() {
        if (!Schema.sObjectType.ContentVersion.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ContentVersion records');
        }
        List<ContentVersion> versions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Everyday Banking account_UGX',
                PathOnClient = 'TestDocument.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
                DocumentType__c = 'Proof of Address'
            )
        };
        insert versions;
        return versions;
    }

    /**
     * @description Create content document links
     * @param linkedEntityId ID of the entity to link the document to
     * @param contentDocumentId Content document ID
     * @return List of ContentDocumentLink records
     */
    public static List<ContentDocumentLink> createContentDocumentLink(Id linkedEntityId, Id contentDocumentId) {
        if (!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ContentDocumentLink records');
        }
        List<ContentDocumentLink> links = new List<ContentDocumentLink>{
            new ContentDocumentLink(
                LinkedEntityId = linkedEntityId,
                ContentDocumentId = contentDocumentId
            )
        };
        insert links;
        return links;
    }

    /**
     * @description Create an applicant
     * @param accId Account ID
     * @param partyProfileId Party profile ID
     * @param appFormId Application form ID
     * @return Applicant record
     */
    public static Applicant createApplicant(Id accId, Id partyProfileId, Id appFormId) {
        if (!Schema.sObjectType.Applicant.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Applicant records');
        }
        Applicant applicant = new Applicant(
            Role = 'Primary Applicant',
            ApplicationFormId = appFormId,
            AccountId = accId,
            PartyProfileId = partyProfileId
        );
        insert applicant;
        return applicant;
    }

    /**
     * @description Create tax details
     * @param accountId Account ID
     * @return TaxDetails__c record
     */
    public static TaxDetails__c createTaxDetails(Id accountId) {
        if (!Schema.sObjectType.TaxDetails__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create TaxDetails__c records');
        }
        TaxDetails__c taxDetail = new TaxDetails__c(
            Account__c = accountId,
            TaxExemptReason__c = '',
            ExternalIdentifier__c = 'sss'
        );
        insert taxDetail;
        return taxDetail;
    }

    /**
     * @description Create an applicant by role
     * @param role Applicant role
     * @param accId Account ID
     * @param partyProfileId Party profile ID
     * @param appFormId Application form ID
     * @return Applicant record
     */
    public static Applicant createApplicantByRole(String role, Id accId, Id partyProfileId, Id appFormId) {
        if (!Schema.sObjectType.Applicant.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Applicant records');
        }
        Applicant applicant = new Applicant(
            Role = role,
            ApplicationFormId = appFormId,
            AccountId = accId,
            PartyProfileId = partyProfileId
        );
        insert applicant;
        return applicant;
    }

   /**
     * @description This method is used to create a community user
     * @return A user that Is/not inserted
     */
    public static User createCommunityUser() {
        validatePermissions();
        User adminUser = setupAdminUser();
        
        User communityUser;
        System.runAs(adminUser) {
            Account account = createTestAccount();
            communityUser = createUserForAccount(account);
            assignPermissionSet(communityUser);
        }
        
        return communityUser;
    }

    private static void validatePermissions() {
        if (!Schema.sObjectType.User.isCreateable() || !Schema.sObjectType.UserRole.isAccessible()) {
            throw new SecurityException('Insufficient permissions to create User records or access UserRole');
        }
    }

    private static User setupAdminUser() {
        UserRole userRole = [SELECT Id, DeveloperName FROM UserRole LIMIT 1];
        User adminUser = [SELECT Id, UserRoleId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (String.isBlank(adminUser.UserRoleId)) {
            adminUser.UserRoleId = userRole.Id;
            if (Schema.sObjectType.User.isUpdateable()) {
                update adminUser;
            }
        }
        
        return adminUser;
    }

    private static Account createTestAccount() {
        if (!Schema.sObjectType.Account.isCreateable() || !Schema.sObjectType.RecordType.isAccessible()) {
            throw new SecurityException('Insufficient permissions to create Account records or access RecordType');
        }
        
        RecordType recType = [SELECT Id FROM RecordType WHERE Name = 'ICS Applicant' AND SObjectType = 'Account' LIMIT 1];
        
        Account account = new Account(
            FirstName = 'TestACC',
            LastName = 'lastAcc',
            AOB_CommerceSiteId__c = 'SB-COZA',
            AOB_TECH_CCCustomerId__c = 'XXX',
            RecordTypeId = recType.Id,
            Phone = '+27823309876',
            ExternalCIFUUID__c = 'RandomBPGUID',
            PersonEmail = 'test@example.com'
        );
        insert account;
        
        return [SELECT Id, PersonContactId FROM Account WHERE Id = :account.Id];
    }

    private static User createUserForAccount(Account account) {
        if (!Schema.sObjectType.Profile.isAccessible()) {
            throw new SecurityException('Insufficient permissions to access Profile');
        }
        
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'SBO Client Community Profile' LIMIT 1];
        String uniqueName = getUniqueName();
        
        User user = new User(
            LastName = 'test',
            Email = 'test@example.com',
            Username = uniqueName + '@test.org',
            ProfileId = profile.Id,
            EmailEncodingKey = 'ISO-8859-1',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            UserPermissionsKnowledgeUser = true,
            ContactId = account.PersonContactId,
            FederationIdentifier = 'FederationIdentifier' + uniqueName
        );
        
        insert user;
        return user;
    }

    private static void assignPermissionSet(User user) {
        if (!Schema.sObjectType.PermissionSet.isAccessible() || !Schema.sObjectType.PermissionSetAssignment.isCreateable()) {
            throw new SecurityException('Insufficient permissions to access PermissionSet or create PermissionSetAssignment');
        }
        
        List<PermissionSet> permSets = [SELECT Id FROM PermissionSet WHERE Name = 'ICS_Community_License_External_Credential' LIMIT 1];
        if (!permSets.isEmpty()) {
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = permSets[0].Id
            );
            insert psa;
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

    /**
     * @description Create test data for sales codes
     * @return List of Sales_Codes__c records
     */
    public static List<Sales_Codes__c> createTestDataSalesCode() {
        if (!Schema.sObjectType.Sales_Codes__c.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Sales_Codes__c records');
        }
        
        List<Sales_Codes__c> codeInfo = new List<Sales_Codes__c>{
            new Sales_Codes__c(Name = '028NP', Sales_Code_Country__c = 'ZA'),
            new Sales_Codes__c(Sales_Code_Country__c = 'AL')
        };
        
        insert codeInfo;
        return codeInfo;
    }

    /**
    * @description Create an ApplicationFormProduct record to be used in test class
    * @author Tushar Walse | 16-10-2024 
    * @param applicationFormId ApplicationForm Id
    * @param product2Id Product2 Id
    * @return ApplicationForm record
    **/
    public static ApplicationFormProduct createApplicationFormProduct(Id applicationFormId, Id product2Id) {
        if (!Schema.sObjectType.ApplicationFormProduct.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ApplicationFormProduct records');
        }
        ApplicationFormProduct applicationFormProduct = new ApplicationFormProduct(
            ApplicationFormId = applicationFormId,
            ProductId = product2Id
        );
        insert applicationFormProduct;
        return applicationFormProduct;
    }

    /**
    * @description Create an Group record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @return Group 
    **/
    public static Group createGroup() {
        if (!Schema.sObjectType.Group.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Group records');
        }
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        return testGroup;
    }

    /**
    * @description Create an PartyProfileRisk record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param partyProfileId To link to
    * @return PartyProfileRisk 
    **/
    public static PartyProfileRisk createPartyProfileRisk(Id partyProfileId) {
        if (!Schema.sObjectType.PartyProfileRisk.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyProfileRisk records');
        }
        PartyProfileRisk partyProfileRisk = new PartyProfileRisk(
            Name='test',
            PartyProfileId = partyProfileId,
            RiskCategory = 'High',
            Enhanced_Due_Diligence_Required__c = true,
            Full_CRA_Result__c = '{"test": "data"}'
        );
        insert partyProfileRisk;
        return partyProfileRisk;
    }

    /**
    * @description Create an PartyScreeningSummary record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param partyProfileId To link to
    * @return PartyScreeningSummary 
    **/
    public static PartyScreeningSummary createPartyScreeningSummary(Id partyProfileId) {
        if (!Schema.sObjectType.PartyScreeningSummary.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create PartyScreeningSummary records');
        }
        PartyScreeningSummary partyScreeningSummary = new PartyScreeningSummary(
            Name = 'test',
            IsAdverseMedia__c = false,
            IsBlacklist__c = false,
            IsPEP__c = false,
            IsWatchlist__c = false,
            PartyProfileId = partyProfileId,
            CitizenshipList__c = 'Malaysia'
        );
        insert partyScreeningSummary;
        return partyScreeningSummary;
    }

    /**
    * @description Create records related to approval request to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param opportunity To link to
    **/
    public static void triggerApprovalRequest(Opportunity opportunity) {
        if (!Schema.sObjectType.Opportunity.isUpdateable()) {
            throw new SecurityException('Insufficient permissions to update Opportunity records');
        }
        if(opportunity.Required_Approval_Processes__c == null || !opportunity.Required_Approval_Processes__c.contains(';FR.NC$')) {
            opportunity.Required_Approval_Processes__c += ';FR.NC$';
            update opportunity;
        }
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        approvalRequest.setObjectId(opportunity.Id);
        approvalRequest.setComments('Submitting request for approval.');
        approvalRequest.setSubmitterId(opportunity.OwnerId); 
        approvalRequest.setProcessDefinitionNameOrId('Approval_Request');
        approvalRequest.setSkipEntryCriteria(false);
        approvalRequest.setNextApproverIds(new List<Id>(new Map<Id, Group>([select Id from Group where DeveloperName = 'ICS_UK_New_Client_Officer']).keySet()));
        Approval.process(approvalRequest);
    }

    /**
    * @description Create an ProcessInstance record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param opportunity To link to
    * @return ProcessInstance 
    **/
    public static ProcessInstance createProcessInstance(Opportunity opportunity) {
        triggerApprovalRequest(opportunity);
        ProcessInstance processInstance = [select Id from ProcessInstance limit 1];
        return processInstance;
    }

    /**
    * @description Create an ProcessInstanceWorkItem record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param opportunity To link to
    * @return ProcessInstanceWorkItem 
    **/
    public static ProcessInstanceWorkItem createProcessInstanceWorkItem(Opportunity opportunity) {
        triggerApprovalRequest(opportunity);
        ProcessInstanceWorkItem processInstanceWorkItem = [select Id from ProcessInstanceWorkItem limit 1];
        return processInstanceWorkItem;
    }

    /**
    * @description Create an ProcessInstanceStep record to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @param opportunity To link to
    * @return ProcessInstanceStep 
    **/
    public static ProcessInstanceStep createProcessInstanceStep(Opportunity opportunity) {
        triggerApprovalRequest(opportunity);
        ProcessInstanceStep processInstanceStep = [select Id from ProcessInstanceStep limit 1];
        return processInstanceStep;
    }

    /**
    * @description Create an AssessmentQuestionVersion records to be used in test class
    * @author Tushar Walse | 18-10-2024 
    * @return List<AssessmentQuestionVersion> 
    **/
    public static List<AssessmentQuestionVersion> createAssessmentQuestionVersions() {
        String jsonString = '{"Likeness Photo Details4":"test LPD...3rd time","ID document details4":"test...3rd time","On hold4":"false","Account locks required?4":"false"}';
        Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(JSONString, Map<String,String>.class);
        List<AssessmentQuestion> assessmentQuestions = new List<AssessmentQuestion>();
        for(String key: jsonData.keySet()) {
            AssessmentQuestion assessmentQuestion = new AssessmentQuestion(
                Name = key,
                DeveloperName = ICS_CTRL_ApprovalFlow.getDeveloperName(key),
                DataType = 'Text',
                QuestionCategory = 'Demographic'
            );
            assessmentQuestions.add(assessmentQuestion);
        }
        insert assessmentQuestions;

        List<AssessmentQuestionVersion> assessmentQuestionVersions = new List<AssessmentQuestionVersion>();
        for(AssessmentQuestion assessmentQuestion : assessmentQuestions) {
            AssessmentQuestionVersion assessmentQuestionVersion = new AssessmentQuestionVersion(assessmentQuestionId=assessmentQuestion.Id, Questiontext=assessmentQuestion.Name, Name='Application Issues', isActive=True);
            assessmentQuestionVersions.add(assessmentQuestionVersion);
        }
        insert assessmentQuestionVersions;
        return assessmentQuestionVersions;
    }

    /**
     * @description Create an application form to be used in test class
     * @param accId Account ID
     * @param opportunity Opportunity record to link to
     * @return ApplicationForm record
     */
    public static ApplicationForm createApplicationForm(string accId, Opportunity opportunity) {
        if (!Schema.sObjectType.ApplicationForm.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create ApplicationForm records');
        }
        ApplicationForm form = new ApplicationForm(
            AccountId = accId,
            opportunityId = opportunity.Id,
            UsageType = 'Onboarding',
            Stage = 'Awaiting Verification'
        );
        insert form;
        return form;
    }

     /**
     * @description Create an opportunity
     * @param accId Account ID
     * @return Opportunity record
     */
    public static Opportunity createDirectOpportunity(Id accId) {
        if (!Schema.sObjectType.Opportunity.isCreateable()) {
            throw new SecurityException('Insufficient permissions to create Opportunity records');
        }
        Id recTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('ICS Applicant').getRecordTypeId();

        Opportunity opp = new Opportunity(
            AccountId = accId,
            Name = 'tesstopp',         
            StageName = 'New',
            RecordTypeId = recTypeId,
            LeadSource = 'Direct',
            CloseDate = Date.today()
        );
        insert opp;
        return opp;
    }
}