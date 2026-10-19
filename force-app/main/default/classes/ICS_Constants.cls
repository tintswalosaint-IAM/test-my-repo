/**
 * @description       : class used to store Constants for SBO-UK PreApplication Feature
 * @story             : SFP-30128
 * @date              : 2024-06-04
 * @last modified on  : 06-23-2025
 * @Modification Description : SFP-30128, class used to store Constants for SBO-UK PreApplication
 */
public with sharing class ICS_Constants {
    // Global variables
    
    /** Error message when a product is not available */
    public static final String PRODUCT_ERRORMESSAGE = 'Not Available'; 
    /** AccountRecordType */
    public static final String SBO_RECNAME = 'ICS_PartyProfile';

    /** Status indicating a document is signed */
    public static final String SIGNED = 'Signed';
     public static final String taxCertificate = 'Tax Certificates';

    /** Constant for ICS GBG */
    public static final String ics_gbg = 'ics_gbg';

    /** Server sent URL for ICS */
    public static final String ics_serverSentUrl = 'ics_serverSentUrl';

    /** Constant for African countries in ICS */
    public static final String ICS_AFRICAN_COUNTRIES = 'ics_african_countries';

    /** Relationship manager in ICS */
    public static final String ICS_RELATIONSHIP_MANAGER = 'ics_relationship_manager';

    /** Seafarer lead in ICS */
    public static final String ICS_SEAFARER_LEAD = 'ics_seafarer_lead';

    /** Object name for identity documents */
    public static final String DOCUMENTOBJ = 'IdentityDocument';

    /** Status indicating awaiting document upload */
    public static final String AWAITING_DOCUMENT_UPLOAD = 'Awaiting Document Upload';

    /** Constant for true text */
    public static final String TRUETEXT = 'TRUE';

    /** Constant for false text */
    public static final String FALSETEXT = 'FALSE';

    /** Constant for 'No' text */
    public static final String NOTEXT = 'No';

    /** Constant for 'Yes' text */
    public static final String YESTEXT = 'Yes';

    /** Constant for 'None' text */
    public static final String NONETEXT = 'None';

    /** Constant for 'Country' text */
    public static final String COUNTRYTEXT = 'Country';

    /** DML operation type for update */
    public static final String UPDATEDML = 'Update';

    /** DML operation type for insert */
    public static final String INSERTDML = 'Insert';

    /** Constant for 'Country of Residence' text */
    public static final String CORTEXT = 'Country of Residence';

    /** Prefix for bearer tokens */
    public static final String BEARER = 'Bearer';

    /** Object name for opportunity */
    public static final String OPPORTUNITYOBJ = 'Opportunity';

    /** Constant for ping operation */
    public static final String PING = 'PING';

    /** Identifier for ping operation */
    public static final String PING_ID = 'Ping Id';

    /** Type for ping operation */
    public static final String PING_TYPE = 'Ping Type';

    /** Object name for identity document */
    public static final String IDENTITYDOCUMENT = 'IdentityDocument';

    /** Object name for applicant */
    public static final String APPLICANT = 'Applicant';

    /** Identifier for primary index check */
    public static final String ISPRIMARYINDEX = 'isPrimaryChecked';

    /** Constant for role */
    public static final String ROLE = 'role';

    /** Identifier for primary applicant */
    public static final String PRIMARYAPPLICANT = 'Primary Applicant';

    /** Identifier for co-applicant */
    public static final String COAPPLICANT = 'Co-Applicant';

    /** Constant for merge operation */
    public static final String MERGES = 'merge';

    /** Field name for street */
    public static final String STREET = 'Street';

    /** Field name for ID */
    public static final String ID = 'Id';

    /** Object name for opportunity */
    public static final String OPPORTUNITY = 'Opportunity';

    /** Object name for account */
    public static final String ACCOUNT = 'Account';

    /** Object name for party profile */
    public static final String PARTYPROFILE = 'PartyProfile';

    /** Manager code for SB */
    public static final String SBMANAGERCODE = 'SB Manager Code';

    /** Field name for province */
    public static final String PROVINCE = 'Province';

    /** Field name for sub-region */
    public static final String SUBREGION = 'Sub Region';

    /** Applicant type for ICS */
    public static final String ICSAPPLICANT = 'ICS Applicant';

    /** Pricebook for ICS */
    public static final String ICSPRICEBOOK = 'ICS Pricebook';

    /** Field for UI */
    public static final String UI_FIELD = 'uiField';

    /** Pattern for validation */
    public static final String VALIDATIONPATTERN = 'validationPattern';

    /** Message for validation */
    public static final String VALIDATIONMESSAGE = 'validationMessage';
    /** Message for country based GBG */
    public static final String COUNTRY_BASED_GBG = 'countryBased';

    /** Relationship type for master-detail */
    public static final String MASTERDETAIL = 'MasterDetail';

    /** Relationship type for lookup */
    public static final String LOOKUP = 'Lookup';

    /** Constant for visa */
    public static final String VISA = 'Visa';

    /** Constant for semicolon */
    public static final String SEMICOLON = ';';

    /** Constant for card */
    public static final String CARD = 'Card';

    /** Success code for HTTP responses */
    public static final String successCode = '200';

    /** Status indicating awaiting screening */
    public static final String awaitScreening = 'Awaiting Screening';

    /** Status indicating screening in process */
    public static final String screening = 'Screening';

    /** Timeout value in milliseconds */
    public static final Integer timeoutVal = 120000;

    // Used in checkExitingData method

    /** Status indicating multiple records found */
    public static final String MULTIPLE = 'Multiple';

    /** Status indicating duplicate records */
    public static final String DUPLICATE = 'Duplicate';

    /** Status indicating new data */
    public static final String NEWDATA = 'New';

    /** Status indicating no product found */
    public static final String NOPRODUCT = 'No Product';

    /** Country code for South Africa */
    public static final String SACOUNTRYCODE = 'ZA';

    /** Text for account */
    public static final String ACCOUNTTEXT = 'Account';

    /** Text for assessment */
    public static final String ASSESSMENTTEXT = 'Assessment';

    /** Data type for currency */
    public static final String CURRENCYDATA = 'currency';

    /** Data type for double */
    public static final String DOUBLEDATA = 'double';

    /** Data type for percent */
    public static final String PERCENTDATA = 'percent';

    /** Data type for decimal */
    public static final String DECIMALDATA = 'decimal';

    /** Data type for boolean */
    public static final String BOOLEANDATA = 'boolean';

    /** Data type for date */
    public static final String DATEDATA = 'date';

    /** Reason for diplomat or military tax exemption */
    public static final String DIPLOMAT_TAX_EXEMPT_REASON = 'I am a diplomat or a member of the armed forces posted to the country/jurisdiction';

    /** Default currency */
    public static final String DEFAULT_CURRENCY = 'GBP';

    /** Form name for application */
    public static final String APPLICATIONFORM = 'ApplicationForm';

    /** Status indicating awaiting verification */
    public static final String AWAITINGVERIFICATION = 'Awaiting Verification';

    /** Message for selecting currencies */
    public static final String PLEASESELECTTHECURRENCIES = 'Please select the currencies you would like for your account';

    /** Message for selecting debit card currencies */
    public static final String SELECTTHECURRENCIES = 'Select the currencies that you would like a debit card for';

    /** Message for visa debit card inquiry */
    public static final String WOULDYOULIKE = 'Would you like a visa debit card?';

    // Screen Names Sections

    /** Pre-personal details screen for ICS UK */
    public static final String PREPERSONALSCREEN = 'ICS UK Pre-Personal Details';

    /** Pre-contact details screen for ICS UK */
    public static final String PRECONTACTSCREEN = 'ICS UK Pre-Contact Details';

    /** Pre-current residential address screen for ICS UK */
    public static final String PREADDRESSSCREEN = 'ICS UK Pre-Current Residential Address';

    /** Pre-account details screen for ICS UK */
    public static final String PREACCOUNTSCREEN = 'ICS UK Pre-Account Details';

    /** Section name for personal details */
    public static final String PREPERSONALSECTION = 'Personal Details';

    /** Section name for contact details */
    public static final String PRECONTACTSECTION = 'Contact Details';

    /** Section name for current residential address */
    public static final String PREADDRESSSSECTION = 'Current Residential Address';

    /** Section name for account details */
    public static final String PREACCOUNTSECTION = 'Account Details';

    /** Prefix for schema */
    public static final String SCHEMA = 'Schema.';

    /** Locale for US English */
    public static final String EN_US = 'en_US';

    /** Country code for US */
    public static final String US = 'US';

    /** Language code for English */
    public static final String EN = 'EN';
      /** Field name for ID-Pal Document type*/
      public static final String IDPAL = 'ID-PAL Files';
        /** Field name for Liveness Document type*/
        public static final String LivesnessType = 'Liveness Photo/Selfie';
     /** Field name for Passport Document type*/
     public static final String PassportDoc = 'ID/Passport/License';
        /** Field name for GBG addres json*/
        public static final String GBGAddressJson = 'gbg_address_json';
          /** Field name for GBG Identity json*/
          public static final String GBGIdentityJson = 'gbg_identity_json';
            /** Field name for face photo*/
        public static final String facePhoto = 'face_photo';
           /** Field name for face photo*/
           public static final String passportCheck = 'passport';
            /** Field name for face photo*/
            public static final String CRAReport = 'cra_report';
    /** Message indicating unable to find sections */
    public static final String UNABLETOFIND = 'Unable to find any sections';

    /** Message indicating unable to find fields */
    public static final String UNABLETOFINDANY = 'Unable to find any fields';

    /** Error message for unable to find currency list */
    public static final String ERRORUNABLETOFIND = 'Error:Unable to find any Currency List from metadata in returnSanctionedCurrencies method';

    /** Message indicating unable to find any currency list */
    public static final String UNABLETOFINDANYCURRENCYLIST = 'Unable to find any Currency List from metadata';

    /** Field name for product code */
    public static final String PRODUCTCODE = 'productCode';

    /** Error message for checkExitingData method */
    public static final String ERRORCHECKEXITINGDATA = 'Error:checkExitingData';

    /** Controller name for pre-application form creator */
    public static final String ICS_CTRL_PREAPPFORMCREATOR = 'ICS_CTRL_PreAppFormCreator';

    /** Object name for bank account */
    public static final String BANK_ACCOUNT = 'Bank Account';

    /** Field name for business risk appetite */
    public static final String BUSINESS_RISK_APPETITE = 'Business Risk Appetite';

    /** Field name fro ID & POA	*/
    public static final String ID_AND_POA	= 'ID & POA';

    /** Field name for IOM other reasons */
    public static final String IOM_OTHER_REASONS = 'IOM Other reasons';
    
    /** Field name for Association to prohibited industry */
    public static final String Association_To_Prohibited_Industry = 'Association to prohibited industry';
    
     /** Field name for Outside of Business Acceptance */
    public static final String Outside_of_Business_Acceptance = 'Outside of Business Acceptance';
    
     /** Field name for Exception Declined */
    public static final String Exception_Declined = 'Exception Declined';

     /** Field name for Other reasons */
    public static final String Other_Reasons = 'Other reasons';
    
       /** Field name for Reason unknown  */
    public static final String Reason_Unknown = 'Reason unknown';
    
     /** Field name for Account costs */
    public static final String Account_Costs = 'Account costs';
    
    /** Field name for Onboarding time */
    public static final String Onboarding_Time = 'Onboarding time';
    
    /** Field name for Onboarding effort */
    public static final String Onboarding_Effort = 'Onboarding effort';
    
     /** Field name for Lost to competitor */
    public static final String Lost_To_Competitor = 'Lost to competitor';
    
      /** Field name for Price*/
    public static final String Price = 'Price';
    
      /** Field name for Abandoned Application */
    public static final String Abandoned_Application = 'Abandoned Application';
    
    /** Status indicating closed lost */
    public static final String CLOSED_LOST = 'Closed Lost';

    /** Status indicating closed Declined */
    public static final String CLOSED_DECLINED = 'Closed Declined';

    /** Status indicating closed Won */
    public static final String CLOSED_WON= 'Closed Won';

    /** Field name for account ID */
    public static final String ACCOUNTID = 'accountId';

    /** Success response code for HTTP */
    public static final Integer successResponse = 200;

    /** Failure response code for HTTP */
    public static final Integer failureResponse = 400;
	  /** Status indicating opportunity record type name */
    public static final string ICS_APPLICANT='ICS_Applicant';
    
     public static final string TaxCertificates='Tax Certificates';
    
     public static final string APPLICANT_TAX_ID_NUMBER='Does the applicant have a Tax Identification Number?S';
    
   	public static final string TAX_ID_NUMBER='Do you have a Tax Identification Number?S';
    /**
     * @description Constructor
     * @param
     *
     */
    public ICS_Constants() {
        String productInfo = 'Optimum';
        if (productInfo != null) {
            productInfo = 'Optimum';
        }
    }
}