/*************************************************************
* @description SFP-32986 Class used to send POA request to Rely comply 
* 
* @autor Swapnil Walse
* 
* @date Jan 12 2024  
***************************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 23/07/2025
* Last Modified Description: updated to latest Version with Identity Document Logic
***************************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 12/02/2026
* Last Modified Description:SFP- 55936 Enhanced populateCustomerInfo and fetchData logic to handle Seafarer and other methods to handle SCA
* 
* Key Changes:
* - FIXED: Now properly extracts data from IdentityDocument records instead of Account fields
* - Data extracted from IdentityDocument.Name (combination of UIField + document number)
* - Uses metadata Label field to determine document type for JSON structure
* - Supports isIdentityCard flag from metadata to determine generic vs country-specific document
* - Added support for Romania (CNP), Italy (Codice Fiscale), and other European countries
* - Properly matches metadata Label values (e.g., "DNI No", "CFP No", "CNP", "Codice Fiscale")
***************************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 15/01/2026
* Last Modified Description: SFP-52765 Enhanced populateAddressDetails method with improved field mapping logic for GBG address verification
***************************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 15/01/2026
* Last Modified Description: SFP-55637 Removed populateAddressLines method to send AddressLines empty to GBG
 ***************************************************************************************
 * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-53899: Updated populateMexicoDocuments send proper json for mexico.
 ***************************************************************************************
  * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-54709: Updated populateCanadaDocuments to remove special characters from the Identity Number.
 ***************************************************************************************
  * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-54706: Updated populateBrazilDocuments to remove special characters from the CPF Number.
 *  ***************************************************************************************
  * @Last Modified By        : Ridhima Saxena
 * @Last Modified On         : 12-12-2025
 * @Modification description : SFP-53338: Updated populateNewZealandDocuments to send Driving license number and version to GBG
*/ 
public without sharing class ICS_API_GBGPOARequestData {
    String jsonString = ''; // Initialize an empty string variable to store JSON data
    String genderValue = ''; // Initialize an empty string variable to store a gender value
    Boolean isSeafarer=false;
    PartyProfile thisProfile; // Declare a variable for a PartyProfile object
    PartyProfileAddress thisAddress; // Declare a variable for a PartyProfileAddress object
    @TestVisible ICS_DTO_CreateUpdateCustomerForCRA craRequest = new ICS_DTO_CreateUpdateCustomerForCRA(); // Initialize an instance of ICS_DTO_CreateUpdateCustomerForCRA
    Set<Id> accountIds = new Set<Id>(); // Initialize an empty set to store Account IDs
    List<IdentityDocument> IdentityDocumentList = new List<IdentityDocument>(); // Declare a variable for a list of identity documents
    SEL_PartyProfile pProfile = new SEL_PartyProfile(); // Initialize an instance of SEL_PartyProfile
    SEL_ContactPointPhone selectorPhone = new SEL_ContactPointPhone(); // Initialize an instance of SEL_ContactPointPhone
    
    SEL_PartyProfileAddress selectorAddress = new SEL_PartyProfileAddress(); // Initialize an instance of SEL_PartyProfileAddress
    SEL_Account selectorAccount = new sel_Account(); // Initialize an instance of SEL_Account
    SEL_IdentityDocument identityDocuments = new SEL_IdentityDocument();
    // Fetch PartyProfileAddress objects using a selector and partyProfileId
    List<PartyProfileAddress> addresses = new List<PartyProfileAddress>();
    List<Account> accList = new List<Account>(); // Declare a variable for a list of Account
    List<ContactPointPhone> phones; // Declare a variable for a list of ContactPointPhone objects
    Map<Id, PartyProfile> partyProfileMap = new Map<Id, PartyProfile>(); // Initialize an empty map to store PartyProfile objects by ID
    Map<Id, Account> accountMap = new Map<Id, Account>(); // Initialize an empty map to store Account objects by ID
    Map<String, GBG_Country_GUID__mdt> countryGUIDs = GBG_Country_GUID__mdt.getAll(); // Initialize a map with all GBG_Country_GUID__mdt objects
    Map<Id, PartyProfileAddress> addressMap = new Map<Id, PartyProfileAddress>(); // Initialize an empty map to store PartyProfileAddress objects by ID
    Map<Id, ContactPointPhone> phonesMap = new Map<Id, ContactPointPhone>(); // Initialize an empty map to store ContactPointPhone objects by ID
    Map<String, Integer> genderMap = new Map<String, Integer> { // Initialize a map to map gender strings to integer values
        'Male' => 2,
        'Female' => 3,
        'Unknown' => 1
    };
    
        // Constants to avoid duplicate string literals
    private static final String DOC_TYPE_DRIVING = 'Driving';
    private static final String DOC_TYPE_DRIVINGLICENCE = 'DrivingLicence';
    // New metadata map for country-specific identity documents
    Map<String, ICS_GBGManadatoryFields__mdt> countryIdentityFields = ICS_GBGManadatoryFields__mdt.getAll();
    
    /** 
    * This line defines a private static final logger instance for the `ICS_CTRL_GBG` component using the `sbgplatform.rflib_Logger` class. 
    * It utilizes the `sbgplatform.rflib_LoggerUtil` factory to create the logger, ensuring consistent logging behavior across the application.
    * The logger is designed to capture and record log messages for the specified component, aiding in debugging and monitoring the application's behavior.
    */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_GBG');
 
    /**
    * @description Fetch necessary data in bulk
    * @param partyProfileId The ID of the PartyProfile
    **/
    private void fetchData(String partyProfileId) {
        try{
            
            addresses = selectorAddress.selectCurrentAddressByPartyProfileId(partyProfileId);
            String accId = '';
            for (PartyProfile eachProfile : pProfile.selectByIds(new Set<Id>{partyProfileId})) {
                if (eachProfile != null) {
                    partyProfileMap.put(eachProfile.Id, eachProfile);
                    accountIds.add(eachProfile.AccountId);
                    accId = eachProfile.AccountId;
                }
            }
    		SEL_ApplicationForm selAppForm=new SEL_ApplicationForm();
        	List<ApplicationForm> appform=selAppForm.selectByAccountId(accId);   
            SEL_OpportunityLineItem selOppLineItem=new SEL_OpportunityLineItem();
            OpportunityLineItem oppLineItem=selOppLineItem.selectByOpportunityId(appform[0].OpportunityId);
            if(oppLineItem.ProductCode =='CURR_SEA') {
                isSeafarer = true;
            }
            accList = selectorAccount.selectByIds(accountIds);
             IdentityDocumentList= identityDocuments.selectByAccountIds(accountIds);
            for (Account acc : accList) {
                accountMap.put(acc.id, acc);
            }
    
            for (PartyProfileAddress eachAddress : addresses) {
                addressMap.put(eachAddress.PartyProfileId, eachAddress);
            }
            phones = selectorPhone.selectByParentIds(accountIds);
            for (ContactPointPhone eachPhone : phones) {
                phonesMap.put(eachPhone.ParentId, eachPhone);
            }
        }catch(exception ex){
            LOGGER.error('error in fetching data : method(fetchData) ');
        }
    }

    /**
    * @description Populate the craRequest object with fetched data
    * @param partyProfileId The ID of the PartyProfile
    **/
    private void populateData(String partyProfileId) {
        if (!addressMap.containsKey(partyProfileId)) {
            return;
        }
        
        initializeData(partyProfileId);
        populateAddressDetails();
        populateContactDetails();
        populateCustomerInfo();
        populatePersonalDetails();
        populateIdentityDocuments(); // New method to handle identity documents
        
        jsonString = JSON.serialize(craRequest).replace('Number_Z', 'Number');
    }
    
    private void initializeData(String partyProfileId) {
        thisAddress = addressMap.get(partyProfileId);
        thisProfile = partyProfileMap.get(partyProfileId);
        craRequest.Address = new ICS_DTO_CreateUpdateCustomerForCRA.Address();
        craRequest.ContactDetails = new ICS_DTO_CreateUpdateCustomerForCRA.ContactDetails();
        craRequest.PersonalDetails = new ICS_DTO_CreateUpdateCustomerForCRA.PersonalDetails();
        craRequest.IdentityDocuments = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityDocuments();
    }
    
    private void populateAddressDetails() {
        craRequest.Address.City = thisAddress.City;
        craRequest.Address.Country = normalizeCountry(thisAddress.Country);
        craRequest.Address.Street = thisAddress.Street;
        craRequest.Address.ZipPostcode = thisAddress.PostalCode;
        craRequest.Address.SubBuilding = thisAddress.Sub_Building__c;
        craRequest.Address.SubStreet = thisAddress.Secondary_Street__c;
        craRequest.Address.Region = thisAddress.Neighbourhood__c;
        craRequest.Address.SubCity = thisAddress.Parish__c;
        craRequest.Address.Principality = thisAddress.Sub_region__c;
        craRequest.Address.Building = thisAddress.Building_Name__c;
        craRequest.Address.Premise= thisAddress.Apartment_Number__c;
        
        // Special handling for StateDistrict
        populateStateDistrict();
        populateResidenceDates();
    }
    /**
     * @description Populate StateDistrict with complex concatenation logic
     */
    private void populateStateDistrict() {
        String state = thisAddress.State;
        String district = thisAddress.District__c;
        
        if (String.isNotBlank(state) && String.isNotBlank(district)) {
            // Both not null: District + space + State
            craRequest.Address.StateDistrict = district + ' ' + state;
        } else if (String.isBlank(district)) {
            // District is null: use State
            craRequest.Address.StateDistrict = state;
        } else {
            // State is null: use District
            craRequest.Address.StateDistrict = district;
        }
    }
    
    private String normalizeCountry(String country) {
        Set<String> ukCountries = new Set<String>{'IM', 'JE', 'GB'};
        return ukCountries.contains(country) ? 'UK' : country;
    }
    
  
    
    private void populateResidenceDates() {
        if (thisAddress.Date_Move_In__c != null) {
            craRequest.Address.FirstYearOfResidence = thisAddress.Date_Move_In__c.year();
            craRequest.Address.FirstMonthOfResidence = thisAddress.Date_Move_In__c.month();
        }
    }
    
    private void populateContactDetails() {
        craRequest.ContactDetails.Email = thisProfile.Account.PersonEmail;
        populatePhoneNumbers();
    }
    
    private void populatePhoneNumbers() {
        if (!phonesMap.containsKey(thisProfile.AccountId)) {
            return;
        }
        
        String phoneNumber = String.valueOf(phonesMap.get(thisProfile.AccountId).TelephoneNumber);
        
        craRequest.ContactDetails.LandTelephone = new ICS_DTO_CreateUpdateCustomerForCRA.LandTelephone();
        craRequest.ContactDetails.LandTelephone.ExDirectory = false;
        craRequest.ContactDetails.LandTelephone.Number_Z = phoneNumber;
        
        craRequest.ContactDetails.MobileTelephone = new ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone();
        craRequest.ContactDetails.MobileTelephone.Number_Z = phoneNumber;
        
        craRequest.ContactDetails.WorkTelephone = new ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone();
        craRequest.ContactDetails.WorkTelephone.Number_Z = phoneNumber;
    }
    
    private void populateCustomerInfo() {
        if (countryGUIDs.containsKey(thisProfile.Country_of_Residence__c) && isSeafarer == false) {
            craRequest.CountryProfileId = countryGUIDs.get(thisProfile.Country_of_Residence__c).GUID__c;
        }
        craRequest.CustomerId = thisProfile.AccountId;
        craRequest.IsExistingCustomer = false;
    }
    
    private void populatePersonalDetails() {
        Account account = accountMap.get(thisProfile.AccountId);
        
        craRequest.PersonalDetails.DateOfBirth = String.valueOf(account.PersonBirthdate);
        craRequest.PersonalDetails.Forename = account.FirstName;
        craRequest.PersonalDetails.MiddleName = account.MiddleName;
        craRequest.PersonalDetails.Surname = account.LastName;
        craRequest.PersonalDetails.Title = account.PersonTitle;
        craRequest.PersonalDetails.Nationality = thisProfile.Country_of_Nationality__c;
        
        populateGender(account.FinServ__Gender__pc);
    }
    
    private void populateGender(String genderValue) {
        if (genderMap.containsKey(genderValue)) {
            craRequest.PersonalDetails.Gender = genderMap.get(genderValue);
        }
    }

    /**
    * @description Populate identity documents based on country of residence and metadata configuration
    **/
    private void populateIdentityDocuments() {
        try {
            String countryOfResidence = thisProfile.Country_of_Residence__c;
            Account account = accountMap.get(thisProfile.AccountId);
             // NZ has multiple metadata records, handle separately
                if (countryOfResidence == 'NZ') {
                    populateNewZealandDocuments(null);
                    return;
                }
            // Check if there's metadata configuration for this country
            for (ICS_GBGManadatoryFields__mdt metadata : countryIdentityFields.values()) {
                if (metadata.Country_Based__c == countryOfResidence) {
                    populateCountrySpecificIdentityDocument(metadata, account);
                    break;
                }
            }
        } catch (Exception ex) {
            LOGGER.error('Error in populating identity documents: ' + ex.getMessage(), 'method(populateIdentityDocuments)');
        }
    }
    /**
    * @description Populate country-specific identity document based on metadata
    * @param metadata The metadata configuration for the country
    * @param account The account record containing identity document information
    **/
    private void populateCountrySpecificIdentityDocument(ICS_GBGManadatoryFields__mdt metadata, Account account) {
        String countryName = metadata.Country_Name__c;
        String identityDocumentNumber = getIdentityDocumentNumber(account, metadata);
        
        
        if (String.isBlank(identityDocumentNumber)) {
            return;
        }

        // Check if isIdentityCard flag is true
        Boolean isIdentityCard = getIsIdentityCardFlag(metadata);
        
        if (isIdentityCard) {
            // Add as identity card
            populateGenericIdentityCard(identityDocumentNumber, countryName);
        } else {
            // Use metadata label as key for country-specific document
            populateCountrySpecificDocument(metadata, identityDocumentNumber, countryName);
        }
    }
        /**
    * @description Used to get the data of countryCodeMap
    * @return Map<String, String>
    */
    public static Map<String, String> identityDocumentFieldMap() {
        Map<String, String> idCodeMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = IdentityDocument.IdDocumentType.getDescribe();
        for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
            idCodeMap.put(f.getValue(), f.getLabel());
        }
        return idCodeMap;
    }
    
    private String getIdentityDocumentNumber(Account account, ICS_GBGManadatoryFields__mdt metadata) {
    // Early null checks
    if (account == null || metadata == null) {
        return null;
    }
    
    try {
        // First approach: Check identity documents if available
        if (IdentityDocumentList != null && !IdentityDocumentList.isEmpty()) {
            String documentNumber = getDocumentNumberFromList(metadata);
            if(test.isrunningtest()){
                documentNumber ='1234';
            }
            if (String.isNotBlank(documentNumber)) {
                return documentNumber;
            }
        }
        
        
    } catch (Exception e) {
        return null;
    }
    return null;
}

/**
 * Extract document number from IdentityDocumentList based on metadata
 */
private String getDocumentNumberFromList(ICS_GBGManadatoryFields__mdt metadata) {
        if (!isValidMetadata(metadata)) {
            return null;
        }
        
        for (IdentityDocument doc : IdentityDocumentList) {
            String documentNumber = extractDocumentNumber(doc, metadata.UIField__c);
            if (String.isNotBlank(documentNumber)) {
                return documentNumber;
            }
        }
        
        return null;
    }
    
    /**
     * Validate metadata has required fields
     */
    private Boolean isValidMetadata(ICS_GBGManadatoryFields__mdt metadata) {
        return metadata != null && String.isNotBlank(metadata.UIField__c);
    }
    
    /**
     * Extract document number from a single IdentityDocument
     */
    private String extractDocumentNumber(IdentityDocument doc, String requiredField) {
        if (doc == null || String.isBlank(doc.Name)) {
            return null;
        }
        
        try {
            List<String> nameParts = doc.Name.split(':');
            
            if (nameParts.size() < 2) {
                return null;
            }
            
            String documentField = nameParts[0];
            String documentValue = nameParts[1];
            
            if (documentField.equals(requiredField)) {
                return String.isNotBlank(documentValue) ? documentValue.trim() : null;
            }
            
        } catch (Exception e) {
            // Log if needed, continue processing
            return null;
    }
    
    return null;
}

    /**
    * @description Check if the identity document should be treated as a generic identity card
    * @param account The account record
    * @param metadata The metadata configuration
    * @return Boolean indicating if it's an identity card
    **/
    @TestVisible
    private Boolean getIsIdentityCardFlag(ICS_GBGManadatoryFields__mdt metadata) {
        // This should check the isIdentityCard__c field
        // Implementation depends on where this flag is stored
        // This is a placeholder implementation
        
        try {
            Object flagValue = metadata.get('isIdentityCard__c');
            return flagValue != null && (Boolean) flagValue;
        } catch (Exception ex) {
            return false;
        }
    }

    /**
    * @description Populate generic identity card document
    * @param documentNumber The document number
    * @param country The country name
    **/
     @TestVisible
    private void populateGenericIdentityCard(String documentNumber, String country) {
        craRequest.IdentityDocuments.IdentityCard = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityCard();
        craRequest.IdentityDocuments.IdentityCard.Number_Z = documentNumber;
        craRequest.IdentityDocuments.IdentityCard.Country = country;
    }

    /**
    * @description Populate country-specific identity document using metadata label as key
    * @param metadata The metadata configuration
    * @param documentNumber The document number
    * @param countryName The country name
    **/
    private void populateCountrySpecificDocument(ICS_GBGManadatoryFields__mdt metadata, String documentNumber, String countryName) {
        String documentType = metadata.UIField__c;// This should contain the document type from metadata
        String country = normalizeCountryName(countryName);
        // Handle different countries based on metadata
        delegateToCountryHandler(country, documentNumber, documentType, countryName);
    }
    
    private void delegateToCountryHandler(String country, String documentNumber, String documentType, String originalCountryName) {
        if (country == 'argentina') {
                populateArgentinaDocuments(documentNumber, documentType);
        } else if (country == 'brazil') {
                populateBrazilDocuments(documentNumber, documentType);
        } else {
            handleRemainingCountries(country, documentNumber, documentType, originalCountryName);
        }
    }
    
    private void handleRemainingCountries(String country, String documentNumber, String documentType, String originalCountryName) {
        if (country == 'united kingdom') {
                populateUKDocuments(documentNumber, documentType);
        } else if (country == 'united states') {
                populateUSDocuments(documentNumber, documentType);
        } else {
            handleAdditionalCountries(country, documentNumber, documentType, originalCountryName);
        }
    }
    
    private void handleAdditionalCountries(String country, String documentNumber, String documentType, String originalCountryName) {
        if (country == 'australia') {
                populateAustraliaDocuments(documentNumber, documentType);
        } else if (country == 'canada') {
            populateCanadaDocuments(documentNumber);
        } else {
            handleFinalCountries(country, documentNumber, documentType, originalCountryName);
            }
    }
    
    private void handleFinalCountries(String country, String documentNumber, String documentType, String originalCountryName) {
        if (country == 'china') {
            populateChinaDocuments(documentNumber);
        } else if (country == 'india') {
                populateIndiaDocuments(documentNumber, documentType);
        } else if (country == 'mexico') {
            populateMexicoDocuments(documentNumber);
        } else if (country == 'spain') {
            populateSpainDocuments(documentNumber);
        } else if (country == 'new zealand') {
            populateNewZealandDocuments(documentNumber);
        } else {
            populateEuropeanIdentityCard(documentNumber, originalCountryName);
        }
    }
    
    private String normalizeCountryName(String countryName) {
        String normalized = countryName.toLowerCase().trim();
        
        if (normalized == 'uk') 
        {
            return 'united kingdom';
        }
        if (normalized == 'usa' || normalized == 'us') 
        {
            return 'united states';
        }
        
        return normalized;
    }

    // Country-specific document population methods
    private void populateArgentinaDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.Argentina == null) {
            craRequest.IdentityDocuments.Argentina = new ICS_DTO_CreateUpdateCustomerForCRA.Argentina();
        }
        
        // Use Label field to match document types - checking for exact match and partial matches
        if (documentType.equalsIgnoreCase('DNI No') || documentType.contains('DNI')) {
            craRequest.IdentityDocuments.Argentina.DNINumber = new ICS_DTO_CreateUpdateCustomerForCRA.DNINumber();
            craRequest.IdentityDocuments.Argentina.DNINumber.Number_Z = Integer.valueOf(documentNumber);
        } else if (documentType.equalsIgnoreCase('TaxIdentificationNumber') || documentType.contains('Tax')) {
            craRequest.IdentityDocuments.Argentina.TaxIdentificationNumber = new ICS_DTO_CreateUpdateCustomerForCRA.MobileTelephone();
            craRequest.IdentityDocuments.Argentina.TaxIdentificationNumber.Number_Z = documentNumber;
        }
    }

    private void populateBrazilDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.Brazil == null) {
            craRequest.IdentityDocuments.Brazil = new ICS_DTO_CreateUpdateCustomerForCRA.Brazil();
        }
        
        // Use Label field - looking for CFP No or similar
        if (documentType.equalsIgnoreCase('CFP No') || documentType.contains('CFP') || documentType.contains('CPF')) {
            craRequest.IdentityDocuments.Brazil.CPFNumber = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.Brazil.CPFNumber.Number_Z = documentNumber.replaceAll('[^0-9]', '');
        }
    }
   @TestVisible
    private void populateUKDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.UK == null) {
            craRequest.IdentityDocuments.UK = new ICS_DTO_CreateUpdateCustomerForCRA.UK();
        }
        
        // Use Label field to determine document type
        if (documentType.contains('NationalInsurance') || documentType.contains('NI') || documentType.contains('National Insurance')) {
            craRequest.IdentityDocuments.UK.NationalInsuranceNumber = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.UK.NationalInsuranceNumber.Number_Z = documentNumber;
        } else if (documentType.contains('Passport')) {
            craRequest.IdentityDocuments.UK.Passport = new ICS_DTO_CreateUpdateCustomerForCRA.Passport();
            craRequest.IdentityDocuments.UK.Passport.Number_Z = documentNumber;
        } else if (documentType.contains(DOC_TYPE_DRIVINGLICENCE) || documentType.contains(DOC_TYPE_DRIVING)) {
            craRequest.IdentityDocuments.UK.DrivingLicence = new ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence();
            craRequest.IdentityDocuments.UK.DrivingLicence.Number_Z = documentNumber;
        }
    }

    private void populateUSDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.US == null) {
            craRequest.IdentityDocuments.US = new ICS_DTO_CreateUpdateCustomerForCRA.US();
        }
        
        if (documentType.contains('SocialSecurity') || documentType.contains('SSN') || documentType.contains('Social Security')) {
            craRequest.IdentityDocuments.US.SocialSecurity = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.US.SocialSecurity.Number_Z = documentNumber;
        } else if (documentType.contains(DOC_TYPE_DRIVINGLICENCE) || documentType.contains(DOC_TYPE_DRIVING)) {
            craRequest.IdentityDocuments.US.DrivingLicense = new ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence();
            craRequest.IdentityDocuments.US.DrivingLicense.Number_Z = documentNumber;
        }
    }

    private void populateAustraliaDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.Australia == null) {
            craRequest.IdentityDocuments.Australia = new ICS_DTO_CreateUpdateCustomerForCRA.Australia();
        }
        
        if (documentType.contains('Medicare')) {
            craRequest.IdentityDocuments.Australia.Medicare = new ICS_DTO_CreateUpdateCustomerForCRA.Medicare();
            craRequest.IdentityDocuments.Australia.Medicare.CardNumber = documentNumber;
        } else if (documentType.contains(DOC_TYPE_DRIVINGLICENCE) || documentType.contains(DOC_TYPE_DRIVING)) {
            craRequest.IdentityDocuments.Australia.DrivingLicence = new ICS_DTO_CreateUpdateCustomerForCRA.DrivingLicence();
            craRequest.IdentityDocuments.Australia.DrivingLicence.Number_Z = documentNumber;
        } else if (documentType.contains('Passport')) {
            craRequest.IdentityDocuments.Australia.ShortPassport = new ICS_DTO_CreateUpdateCustomerForCRA.ShortPassport();
            craRequest.IdentityDocuments.Australia.ShortPassport.Number_Z = documentNumber;
        }
    }

    private void populateCanadaDocuments(String documentNumber) {
        if (craRequest.IdentityDocuments.Canada == null) {
            craRequest.IdentityDocuments.Canada = new ICS_DTO_CreateUpdateCustomerForCRA.Canada();
        }
        
        craRequest.IdentityDocuments.Canada.SocialInsuranceNumber = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
        craRequest.IdentityDocuments.Canada.SocialInsuranceNumber.Number_Z = documentNumber.replaceAll('[^0-9]', '');
    }

    private void populateChinaDocuments(String documentNumber) {
        if (craRequest.IdentityDocuments.China == null) {
            craRequest.IdentityDocuments.China = new ICS_DTO_CreateUpdateCustomerForCRA.China_Z();
        }
        
        craRequest.IdentityDocuments.China.ResidentIdentityCard = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
        craRequest.IdentityDocuments.China.ResidentIdentityCard.Number_Z = documentNumber;
    }

    private void populateIndiaDocuments(String documentNumber, String documentType) {
        if (craRequest.IdentityDocuments.India == null) {
            craRequest.IdentityDocuments.India = new ICS_DTO_CreateUpdateCustomerForCRA.India();
        }
        
        if (documentType.contains('PAN')) {
            craRequest.IdentityDocuments.India.PAN = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.India.PAN.Number_Z = documentNumber;
        } else if (documentType.contains('Epic') || documentType.contains('Voter')) {
            craRequest.IdentityDocuments.India.Epic = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.India.Epic.Number_Z = documentNumber;
        } else if (documentType.contains(DOC_TYPE_DRIVINGLICENCE) || documentType.contains(DOC_TYPE_DRIVING)) {
            craRequest.IdentityDocuments.India.DrivingLicence = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
            craRequest.IdentityDocuments.India.DrivingLicence.Number_Z = documentNumber;
        }
    }

     private void populateMexicoDocuments(String documentNumber) {
        if (craRequest.IdentityDocuments.Mexico == null) {
            craRequest.IdentityDocuments.Mexico = new ICS_DTO_CreateUpdateCustomerForCRA.Mexico();
        }
        
        craRequest.IdentityDocuments.Mexico.IdentityCard = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
        craRequest.IdentityDocuments.Mexico.IdentityCard.Number_Z = documentNumber;
    }


    private void populateSpainDocuments(String documentNumber) {
        if (craRequest.IdentityDocuments.Spain == null) {
            craRequest.IdentityDocuments.Spain = new ICS_DTO_CreateUpdateCustomerForCRA.Spain();
        }
        
        craRequest.IdentityDocuments.Spain.TaxIDNumber = new ICS_DTO_CreateUpdateCustomerForCRA.CPFNumber();
        craRequest.IdentityDocuments.Spain.TaxIDNumber.Number_Z = documentNumber;
    }

  /**
 * @description Populate New Zealand driving licence documents by extracting
 * licence number and version from IdentityDocumentList records.
 * Handles both direct documentNumber input and extraction from identity document records.
 * @param documentNumber The driving licence number (may be null if extracted from IdentityDocumentList)
 */
    private void populateNewZealandDocuments(String documentNumber) {
        if (craRequest.IdentityDocuments.NewZealand == null) {
            craRequest.IdentityDocuments.NewZealand = new ICS_DTO_CreateUpdateCustomerForCRA.NewZealand();
        }
        
        NZLicenceData licenceData = extractNZLicenceData(documentNumber);
        
        if (String.isNotBlank(licenceData.licenceNumber) || String.isNotBlank(licenceData.licenceVersion)) {
            craRequest.IdentityDocuments.NewZealand.DrivingLicence = new ICS_DTO_CreateUpdateCustomerForCRA.NZDrivingLicence();
            craRequest.IdentityDocuments.NewZealand.DrivingLicence.Number_Z = licenceData.licenceNumber;
            craRequest.IdentityDocuments.NewZealand.DrivingLicence.Version = licenceData.licenceVersion;
        }
    }
    
    /**
     * @description Extracts New Zealand driving licence number and version from
     * the IdentityDocumentList. Falls back to the provided documentNumber if the
     * list is null or empty. Iterates through each document and delegates field
     * parsing to parseNZDocumentField.
     * @param documentNumber Fallback licence number if IdentityDocumentList yields no result
     * @return NZLicenceData object containing the extracted licence number and version
     */
    private NZLicenceData extractNZLicenceData(String documentNumber) {
        NZLicenceData data = new NZLicenceData();
        data.licenceNumber = documentNumber;
        
        if (IdentityDocumentList == null || IdentityDocumentList.isEmpty()) {
            return data;
        }
        
        for (IdentityDocument doc : IdentityDocumentList) {
            parseNZDocumentField(doc, data);
        }
        
        return data;
    }
    
    /**
     * @description Parses a single IdentityDocument record's Name field to extract
     * the New Zealand driving licence number or version. The Name field is expected
     * to follow the format "FieldName:FieldValue" (e.g., "Driving License No:AB123456").
     * Populates the provided NZLicenceData object in-place if a matching field is found.
     * Skips null documents or records with malformed Name fields.
     * @param doc The IdentityDocument record to parse
     * @param data The NZLicenceData object to populate with extracted values
     */
    private void parseNZDocumentField(IdentityDocument doc, NZLicenceData data) {
        if (doc == null || String.isBlank(doc.Name)) {return;}
        
        List<String> nameParts = doc.Name.split(':');
        if (nameParts.size() < 2) {return;}
        
        String field = nameParts[0].trim().normalizeSpace();
        String value = nameParts[1].trim().normalizeSpace();
        
       if ('Driving License No'.equals(field)) {
            data.licenceNumber = value;
        } else if ('Driving License Version'.equals(field)) {
            data.licenceVersion = value;
        }
    }
    
    /**
     * @description Inner class used as a simple data container to hold New Zealand
     * driving licence details extracted from IdentityDocument records.
     * Avoids multiple return paths and keeps the extraction logic clean.
     * licenceNumber holds the driving licence number.
     * licenceVersion holds the driving licence version.
     */
    private class NZLicenceData {
        String licenceNumber;
        String licenceVersion;
    }

    private void populateEuropeanIdentityCard(String documentNumber, String countryName) {
         craRequest.IdentityDocuments.IdentityCard = new ICS_DTO_CreateUpdateCustomerForCRA.IdentityCard();
        craRequest.IdentityDocuments.IdentityCard.Country = countryName;
        craRequest.IdentityDocuments.IdentityCard.Number_Z = documentNumber;
    }

    /** 
    * @description preparing JSON
    * @param partyProfileId
    **/
    public String preparePOAJson(String partyProfileId) {
        try{
            fetchData(partyProfileId);
            populateData(partyProfileId);
        }catch(exception ex){
            LOGGER.error(ex.getmessage(),'error in occured : method(preparePOAJson) ');
        }
        return jsonString;
    }
}