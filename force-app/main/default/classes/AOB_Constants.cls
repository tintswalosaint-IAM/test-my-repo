/**
 * @description AOB_Constants
 * <p></p>
 *
 * @author Asmae ESSBAI (aessbai@salesforce.com)
 *
 * @date Nov 9th 2020
 * 
 * ACTION  TICKET    DATE       OWNER         COMMENT
 * Changed SFP-10057 20-04-2022 Gill Lumley   Add SA_ISOCODE for South Africa ISO country code ZA
 * Changed SFP-19556 01-06-2023 Pradeep Kota  Add name of Standard Bank Group URL in AOB App Settings custom metadata 
 * Changed SFP-19887 01-06-2023 Pradeep Kota  Add personal details - employment constants (also for SFP-28785)
 * Changed SFP-27663 04-07-2023 Gill Lumley   Add FAIS disclosure and insurance T&C URLs in AOB App Settings custom metadata   
 * Changed SFP-22302 04-07-2023 Gill Lumley   Add COND_FIXED_INITIATION_FEE and COND_INSURANCE_PLAN_RATE for condition codes
 */
public with sharing class AOB_Constants {
    //Global variables
    public static final String ID_STRING = 'id';
    public static final String NONE_STRING = 'None';
    public static final String UTF8 = 'UTF-8';
    public static final String TIME_ZONE = 'Africa/Johannesburg';

    //Permission Sets
    public static final String PS_COMMUNITYUSER = 'AOB_SAAuthenticatedCommunityUsers';
    //Object names
    public static final String PROFILE = 'Profile';
    public static final String PERMISSION = 'Permission Set';
    public static final String ACCOUNT = 'Account';
    public static final String PERSON_ACCOUNT = 'Person Account';
    public static final String COMMUNITY = 'Community';
    //temporary Variables
    public static final String CREDITCARD = 'Credit Card';
    /*THIS IS ONLY USED UNTIL CORRECT PARAM IS BUILT TO HOST IT IN PRODUCT */
    public static final String DEFAULTCATEG = 'ZBRW';

    //SAP Fields == should have a prefix SAPFIELD_FIELDNAME
    public static final String SAPFIELD_PHONE = 'PHONE';
    public static final String SAPFIELD_EMAIL = 'EMAIL';
    public static final String TITLE = 'title';
    public static final String IDTYPE = 'idType';
    public static final String ID_ISSUINGCOUNTRY = 'issuingCountry';
    public static final String ID_ISSUINGDATE = 'issuedDate';
    public static final String ID_EXPIRATIONDATE = 'expirationDate';
    public static final String FIRSTNAME = 'firstName';
    public static final String LASTNAME = 'firstName';
    public static final String SURNAME = 'surName';
    public static final String INDIVIDUAL = '1';
    public static final String CELLPHONE = 'cellPhone';
    public static final String EMAIL = 'email';
    public static final String TAXNUMBER= 'taxNumber';
    public static final String SATAXNUMBER= 'ZA3';
    public static final String SOFAMOUNT = 'sourceOfFundsAmount';
    public static final String INITIALS = 'initials';
    public static final String SUBURB = 'suburb';
    public static final String SAPFIELD_ACCESSTOKEN = 'accessToken';
    public static final String NATUREOFRELATION = 'relationshipNature';
    public static final String NAMEOFRELATION = 'nameofTheIndividual';
    public static final String SOURCEOFFUNDS = 'sourceOfFunds';
    public static final String STREETNUMBER = 'streetNumber';
    public static final String UNITNUMBER = 'unitNumber';
    public static final String BUILDINGNAME = 'buildingName';
    public static final String CITY = 'city';
    public static final String PROVINCE = 'province';
    public static final String PROVINCECITY = 'provinceCity';
    public static final String POSTALCODE = 'postalCode';
    public static final String INCOMETYPE = 'incomeType';
    public static final String EMPLOYMENTTYPE = 'employmentType';
    public static final String DESIGNATION = 'designation';
    public static final String EMPLOYERNAME = 'employerName';
    public static final String INDUSTRY = 'industry';
    public static final String FUNDAMOUNT = 'sourceOfFundsAmount';
    public static final String STARTDATE = 'startDate';
    public static final String ENDDATE = 'endDate';                // SFP-19887 
    public static final String ADDINCONE = 'AddIncome';
    public static final String INHERITANCE = 'inheritance';
    public static final String PUBLICOFF = 'publicOff';
    public static final String PUBLICOFFREL = 'publicOffRelated';
    public static final String APPLICATIONID = 'applicationId';
    public static final String IDNUMBER = 'idNumber';
    public static final String AREEMPLOYED = 'areEmployed';        // SFP-19887
    public static final String PERMEMPLOYED = 'permEmployed';      // SFP-19887
    
    
    public static final String COUNTRYOFBIRTH = 'countryOfBirth';
    public static final String RESIDENCE = 'residenceCountry';     // SFP-19887
    public static final String NATIONALITY = 'Nationality';
    public static final String CITIZENSHIP = 'citizenship';
    
    /*SAP Condition Codes*/
    public static final String COND_FIXED_INITIATION_FEE = 'Z010'; // SFP-22302
    public static final String COND_INSURANCE_PLAN_RATE = 'Z175';  // SFP-22302

    /*SAP Debit Order Fields*/
    public static final String DEBITORDERACCID = 'debitOrderAccountUniqueId';
    public static final String USEOFLOAN = 'intendedUseOfLoan';
    public static final String PAYSLIPDATE = 'payDay';
    public static final String DEBITORDERDAY = 'debitOrderDay';
    public static final String LEGALDELIVERYMETH = 'legalDeliveryMethod';
    public static final String DELIVERY = 'delivery';
    public static final String NOCOST = 'No Cost';
    public static final String BRANCH = 'branch';

    //Salesforce Fields == should have a prefix SFFIELD
    public static final String MRIFIELD_EMPLOYMENTTYPE = 'EMPMT_STTUS';
    public static final String MRIFIELD_INCOMETYPE = 'INCOME _TYPE';
    public static final String MRIFIELD_SOURCEOFFUNDS = 'SOURC_OF_FUNDS';
    public static final String MRIFIELD_RELATIONTYPE = 'PMIFP_RLTNP';

    // Certificate
    public static final String API_TESTCERTIFICATE = [SELECT AOB_Body__c FROM AOB_Certificate__mdt WHERE DeveloperName = 'SBG_IBM_API_Connect'].AOB_Body__c;

    //API Calls Constants
    public static final String NC_CUSTOMERS = 'callout:AOB_API_PersonalDetails';
    public static final String API_METHOD_POST = 'POST';
    public static final String API_METHOD_PUT = 'PUT';
    public static final String API_ACCEPT_JSON = 'application/json';
    public static final String API_CONTENTTYPE_URL = 'application/x-www-form-urlencoded';

    //Ping params 
    public static final String PING = 'PING';
    public static final String PING_ID = 'Ping Id';
    public static final String PING_TYPE = 'Ping Type';
    public static final String PING_FIRST_NAME = 'first_name';
    public static final String PING_LAST_NAME = 'last_name';
    public static final String PING_EMAIL = 'email';
    public static final String PING_BPID = 'bpid';
    public static final String PING_DIGITALID = 'digitalId';
    public static final String PING_BPGUID = 'bpidguid';
    public static final String PING_SUB = 'sub';
    public static final String COUNTRY_CODE = 'countryCode';
    public static final String NATIONAL_ID = 'nationalId';
    public static final String CUSTOMER_CC = 'customerCCId';
    public static final String PHONE = 'phoneNumber';
    public static final String PING_REG = 'pingReg';
    public static final String PING_LOGIN ='pingLogin';
    
    //Sandbox
    public static final String SANDBOX_SUFIX = AOB_Utils.getAppSettingByLabel('Sandbox Prefix');

    //Settings
    public static final String COMMERCE_SITE_ID = 'commerceSiteId';
    public static final String SB_COZA = 'SB-COZA';
    public static final String SA = 'SA';
    public static final String SA_ISOCODE = 'ZA';
    public static final String OWNER = 'Account Owner';

    //Flow params
    public static final String FLOW = 'FLOW';
    public static final String FLOW_PERSONAL_DETAIL = 'Personal details';
    public static final String FLOW_BEFORE_WE_BEGIN = 'Before we begin';
    public static final String FLOW_NAMES_WITH_BPID = 'Flow names with WFR';
    public static final String FLOW_NAMES_WITHOUT_BPID = 'Flow names without WFR';

    //Initiate AO
    public static final String INITIATE_AO_SUCCESS_MESSAGE = 'Application created successfully';
    public static final String INITIATE_AO_ERROR_MESSAGE = 'Something is wrong';
    public static final String AOB_FINAL_OFFER_FLOW = 'AOB_CardFinalOffer';

    //Flow Screen
    public static final String FINAL_OFFER_SECTION = 'Main';
    public static final String FINAL_OFFER = 'FINAL_OFFER';
    public static final String FINAL_OFFER_API_VAR = 'Final Offer API Variables';
    public static final String FINAL_OFFER_VAR = 'Final Offer Custom Variables';
    public static final String URL = 'URL';    
    public static final String COMMERCE_URL = 'Commerce Cloud URL';
    public static final String DOCUMENT_UPLOAD = 'AOB_DocumentUpload';
    public static final String NTU = 'SAPBS_NTU_REASN';
    public static final String SCREEN_FINAL_OFFER = 'Final Offer';
    public static final String SCREEN_CARD_PERSONALIZATION = 'Card Personalisation';
    public static final String SCREEN_INSURANCE = 'Insurance';

    // OTP
    public static final String CALL_CENTER_PHONE_NUMBER = 'Call Center Phone Number';
    //WFR
    public static final String WFR_DEFAULT_CODE = '004';
    public static final String WFR_DONE_STATUS = 'Done';
    public static final String WFR_FLOW = 'AOB_WebFaceRecognition';
    public static final String WFR_GUIDATT = 'bpidguid';
    public static final String WFR_ERROR = 'ERROR';
    public static final String WFR_COMPLETED_STATUS = 'Completed by Customer';
    public static final String WFR_STATUS_SUCCESS_MESSAGE = 'Application WFR Status updated successfully';
    public static final String WFR_STATUS_ERROR_MESSAGE = 'Something is wrong';

    //Profiles
    public static final String SYSTEM_ADMINISTRATOR = 'System Administrator';

    //Exceptions
    public static final String SCRIPT_THROWN_EXCEPTION = 'Script-thrown exception';
    public static final String NO_PRODUCTS_DATA_EXCEPTION = 'There are no data related to current products';
    // HTTP header
    public static final String HTTP_ENCODING_XML = 'text/xml';

    //Links
    public static final String TERM_AND_CONDITIONS = 'Term and Conditions URL';
    public static final String URL_STANDARD_BANK_GROUP = 'URL Standard Bank Group';         // SFP-19556  
    public static final String URL_FAIS_DISCLOSURE = 'URL FAIS Disclosure';                 // SFP-27663
    public static final String URL_INSURANCE_TERMS_AND_CONDITIONS = 'URL Insurance T&C';    // SFP-27663   
    public static final String LINK = 'LINK';

    public static final Integer CURRENT_SCREEN_NUMBER = 3;
    public static final Integer NUMBER_OF_SCREENS = 5;
    public static final String CURRENT_SCREEN = 'Current Screen';
    public static final String PREVIOUS_SCREEN = 'Previous Screen';
    public static final String PRODUCT_NAME = 'WORLD CITIZEN CREDIT CARD';
    public static final String REQUIRED_DOC_DESCRIPTION = 'Required Document Description';
    public static final String REQUIRED_DOC_HELPTEXT = 'Required Document Help Text';
    public static final Integer REQUIRED_DOC_ORDER = 1;
    public static final String PRODUCT_QUALIF_DESCRIPTION = 'Product Qualification Description';
    public static final String PRODUCT_QUALIF_HELPTEXT = 'Product Qualification Help Text';
    public static final Integer PRODUCT_QUALIF_ORDER = 1;
    public static final String SERVICE_NAME = 'Service Name';
    public static final String RESPONSE = 'Response';
    public static final Map<String, String> CURRENCIES = new Map<String, String>{ 'R' => 'ZAR' };
}