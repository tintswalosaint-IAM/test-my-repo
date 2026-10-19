/**
 * @description       : Controller class for update prospect records
 * @author            : Vershley Joyejob
 * @UserStory         : SFP-52379
 * @date              : 19-09-2025
 * @lastModified      : Brendon Mahwete
 * @lastEditDate      : 25-05-2026
 **/
public without sharing class INS_PLI_UpdateProspectRecord{

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_UpdateProspectRecord');

    public class personalInformation {
        public String ProductName;
        public String FirstName;
        public String LastName;
        public String DateOfBirth;
        public String IdNumber;
        public String Email;
        public String PhoneNumber;
        public String Gender;
        public String AccountId;
        public String OpportunityId;
        public String QuoteId;
        public String CoverAmount;
        public String MonthlyPremium;
    }

    /**
     * @description Get full list of countries available in the ICS_UTIL_AppFormDataProvider.getCountryValueMap
     * @author Vershley Joyejob | 19-09-2025
     * @return Map<String,String> containing Country Code, Country Name
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String, String> getCountriesList(){
        try {
            return CMN_UTIL_System.getPicklistEntriesMap(TaxDetails__c.getSObjectType(),'Country__c');
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.getCountriesList',e.getMessage()},e);
            throw new AuraHandledException('Failed to retrieve countries list: '+e.getMessage());
        }
    }

    /**
     * @description Initiates onboarding process, creates PersonAccount, Individual, and IdentityDocument if not exists
     * @author Vershley Joyejob | 19-09-2025
     * @param personalInformationJSON JSON string of personalInformation
     * @return Map<String,Object> containing AccountId, IdentityDocumentId, IndividualId
     **/
    @AuraEnabled(Cacheable=false)
    public static Map<String,Object> initiateOnboardingProcess(String personalInformationJSON){
        personalInformation personalInfoWrapper = (personalInformation) JSON.deserialize(personalInformationJSON, personalInformation.class);

        Map<String,Object> outMap = new Map<String, Object>();

        //Create PersonAccount
        try 
        { 
            List<IdentityDocument> identityDocuments = new SEL_IdentityDocument().selectByName(personalInfoWrapper.IdNumber);
            if (identityDocuments.isEmpty()) {

                // Create Unit of Work
                CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                        new List<Schema.SObjectType>{
                                Individual.SObjectType, Account.SObjectType, IdentityDocument.SObjectType
                        }
                );

                //individual
                Id recordTypeIdindividual = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get('Botswana_BCC').getRecordTypeId();
                Individual ind = new Individual();
                ind.FirstName = personalInfoWrapper.FirstName;
                ind.LastName = personalInfoWrapper.LastName;
                ind.BirthDate = Date.valueOf(personalInfoWrapper.DateOfBirth);
                ind.Data_Privacy_Consent__c = true;
                ind.RecordTypeId = recordTypeIdindividual;
                ind.National_Identity_Number__c = personalInfoWrapper.IdNumber;
                unitOfWork.registerNew(ind);

                //create account
                Id recordTypePersonId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Person_Account_Prospect').getRecordTypeId();
                Account perAcc = new Account();
                perAcc.FirstName = personalInfoWrapper.FirstName;
                perAcc.LastName = personalInfoWrapper.LastName;
                perAcc.PersonEmail = personalInfoWrapper.Email;
                perAcc.FinServ__Gender__pc = personalInfoWrapper.Gender;
                perAcc.CMN_IdentityNumber__pc = personalInfoWrapper.IdNumber;
                perAcc.RecordTypeId = recordTypePersonId;
                perAcc.PersonBirthdate = Date.valueOf(personalInfoWrapper.DateOfBirth);
                perAcc.PersonMobilePhone = '+254' + personalInfoWrapper.PhoneNumber;
                perAcc.Phone = '+254' + personalInfoWrapper.PhoneNumber;
                perAcc.Receive_Marketing__c = true;
                perAcc.FinServ__KYCStatus__c = 'In Queue';
                perAcc.External_CIF_Country__pc = 'KE'; //personAccount Field
                perAcc.INS_SalesAgentPortalLicenseType__pc = 'AOB_Community Authenticated Customer'; //personAccount Field
                unitOfWork.registerNew(perAcc, Account.PersonIndividualId, ind);

                IdentityDocument identDoc = new IdentityDocument();
                identDoc.Name = personalInfoWrapper.IdNumber;
                identDoc.IdDocumentType = 'NATIONAL IDENTITY DOCUMENT';
                unitOfWork.registerNew(identDoc, IdentityDocument.RelatedLegalEntityId, perAcc);

                // Commit all changes
                unitOfWork.commitWork();

                outMap.put('AccountId', perAcc.Id);
                outMap.put('IdentityDocumentId', identDoc.Id);
                outMap.put('IndividualId', ind.Id);

            } else {

                List<IdentityDocument> existingIdentityDocument = new SEL_IdentityDocument().selectByName(personalInfoWrapper.IdNumber);
                Account acc = new SEL_Account().selectByIdWithPersonIndividualId(existingIdentityDocument[0].RelatedLegalEntityId);

                outMap.put('AccountId', acc.Id);
                outMap.put('IdentityDocumentId', existingIdentityDocument[0].Id);
                outMap.put('IndividualId', acc.PersonIndividualId);
            }
            return outMap;
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.initiateOnboardingProcess ',e.getMessage()},e);
            throw new AuraHandledException('Failed to initiate onboarding process: '+e.getMessage());
        }

    }

    /**
     * @description Initiates quoting process, creates Opportunity and Quote
     * @author Vershley Joyejob | 19-09-2025
     * @param personalDetailsJSON JSON string of personalInformation
     * @return Map<String,Object> containing OpportunityId and QuoteId
     **/
    @AuraEnabled(Cacheable=false)
    public static Map<String,Object> initiateQuotingProcess(String personalDetailsJSON, String pageIdentifier) {
		Map<String, Object> outMap = new Map<String, Object>();
        try {
            Id recordTypeOpportunityId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();

            personalInformation personalInfoWrapper = (personalInformation) JSON.deserialize(personalDetailsJSON, personalInformation.class);
            
            // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Opportunity.SObjectType, Quote.SObjectType }
            );

            Set<Id> ids = new Set<Id>{ UserInfo.getUserId() };
            List<User> users = SEL_User.newInstance().selectUsersByIds(ids);
			// Fetch Sales Agent A Number from Contact using SEL_Contact
            String salesAgentANumber = null;
            if (personalInfoWrapper.AccountId != null) {
                SEL_Contact contactSelector = new SEL_Contact();
                List<Contact> contacts = contactSelector.selectByAccountIds(
                    new Set<Id>{ personalInfoWrapper.AccountId }
                );
                if (!contacts.isEmpty() && contacts[0].INS_SalesAgentANumber__c != null) {
                    salesAgentANumber = contacts[0].INS_SalesAgentANumber__c;
                }                
            }            
            String oppSource = resolveOpportunitySource(pageIdentifier, users);

            Opportunity opp = new Opportunity();
            opp.RecordTypeId = recordTypeOpportunityId;
            opp.Name = personalInfoWrapper.FirstName + ' '+ personalInfoWrapper.LastName +' '+ personalInfoWrapper.ProductName + ' ' + Date.today().format();
            opp.Pricebook2Id = getStdPriceBook();
            opp.AccountId = personalInfoWrapper.AccountId;                        
            opp.StageName = 'Proposal';
            opp.Type = 'New Business';
            opp.Country__c = 'KE';
            opp.INS_OnboardingStep__c = 'Step 2 - Choose Your Cover';
            opp.CurrencyIsoCode = 'KES';
            opp.CloseDate = Date.today().addMonths(1);
            opp.Opportunity_Source__c = oppSource;
            opp.Sales_Agent_A_Number__c = salesAgentANumber;
            unitOfWork.registerNew(opp);

            Quote qt = new Quote();
            qt.Name = personalInfoWrapper.FirstName + ' ' + personalInfoWrapper.ProductName + ' ' + Date.today().format();
            qt.OpportunityId = opp.Id;
            qt.Pricebook2Id = opp.Pricebook2Id;
            qt.INS_PolicyDocumentLatestStatus__c = 'Pending';
            unitOfWork.registerNew(qt, Quote.OpportunityId, opp);

            // Commit all changes
            unitOfWork.commitWork();

            outMap.put('OpportunityId', opp.Id);
            outMap.put('QuoteId', qt.Id);
           
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.initiateQuotingProcess',e.getMessage()},e);
            if(!Test.IsRunningTest()){               
            	throw new AuraHandledException('Failed to initiate quoting process: '+e.getMessage());
            }
        }
        return outMap;
    }

    /**
     * @description updates Opportunity and Quote
     * @author Alexandr Goryachko
     * @param personalDetailsJSON JSON string of personalInformation
     * @param quoteId String Id of the Quote record
     * @param oppId String Id of the Opportunity record
     * @return Map<String,Object> containing OpportunityId and QuoteId
     **/
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> updateQuotingProcess(String personalDetailsJSON, String quoteId, String oppId) {
        Map<String, Object> outMap = new Map<String, Object>{
                'OpportunityId' => oppId,
                'QuoteId' => quoteId
        };
        try {
            personalInformation personalInfoWrapper = (personalInformation) JSON.deserialize(personalDetailsJSON, personalInformation.class);

            // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Opportunity.SObjectType, Quote.SObjectType }
            );

            Opportunity opp = new Opportunity(Id = oppId);
            opp.Total_Cover_Amount__c = Double.valueOf(personalInfoWrapper.CoverAmount);
            opp.Total_Monthly_Premium__c = Double.valueOf(personalInfoWrapper.MonthlyPremium);
            unitOfWork.registerDirty(opp);

            Quote qt = new Quote(Id = quoteId);
            qt.INS_IndicativePremium__c = Double.valueOf(personalInfoWrapper.MonthlyPremium);
            qt.INS_MonthlyPremium__c = Double.valueOf(personalInfoWrapper.MonthlyPremium);
            unitOfWork.registerDirty(qt);

            // Commit all changes
            unitOfWork.commitWork();

        } catch(Exception e) {
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.initiateQuotingProcess',e.getMessage()},e);
            throw new AuraHandledException('Failed to update quote: ' + e.getMessage());
        }
        return outMap;
    }

    private static Id getStdPriceBook () {
        if(Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        } else {
            return new SEL_Pricebook2().selectPriceBook('isStandard = TRUE')[0].Id;
        }
    }

    /**
     * @description Updates the onboarding step of an Opportunity
     * @author Vershley Joyejob | 19-09-2025
     * @param opportunityId Id of the Opportunity to update
     * @param stepName New onboarding step name
     * @return void
     **/
    @AuraEnabled(cacheable=false)
    public static void updateOnboardingSteps(String opportunityId, String stepName) {

        try {
            // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Opportunity.SObjectType }
            );

            Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.INS_OnboardingStep__c = stepName;
            
            unitOfWork.registerDirty(opp);

            // Commit changes
            unitOfWork.commitWork();
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.updateOnboardingSteps',e.getMessage()},e);
            throw new AuraHandledException('Failed to update Opportunity steps: ' + e.getMessage());
        }

    }

     @AuraEnabled(cacheable=false)
    public static void updateOpportunityStatus(String opportunityId, String status) {

        try {
             // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Opportunity.SObjectType }
            );

            Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.StageName = status;
            unitOfWork.registerDirty(opp);

            // Commit changes
            unitOfWork.commitWork();
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.updateOpportunityStatus',e.getMessage()},e);
            throw new AuraHandledException('Failed to update Opportunity status: ' + e.getMessage());
        }

    }
     @AuraEnabled(cacheable=false)
    public static void updateQuoteReference(String quoteId, String reference) {

        try {
             // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Quote.SObjectType }
            );

            Quote quote = new Quote();
            quote.Id = quoteId;
            quote.UnderwriterQuoteReferenceNumber__c = reference;
            unitOfWork.registerDirty(quote);

            // Commit changes
            unitOfWork.commitWork();
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.updateQuoteReference',e.getMessage()},e);
            throw new AuraHandledException('Failed to update Quote reference: ' + e.getMessage());
        }

    }

     @AuraEnabled(cacheable=false)
    public static void covertToPersonAcc(String accountId, String policynum) {

        try {

             // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Account.SObjectType }
            );

            Account acc = new Account();
            acc.Id = accountId;
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            unitOfWork.registerDirty(acc);

            // Commit changes
            unitOfWork.commitWork();

            createPolicyRecord(accountId, policynum);
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.covertToPersonAcc',e.getMessage()},e);
            throw new AuraHandledException('Failed to update convert to person account: ' + e.getMessage());
        }

    }

    @AuraEnabled(cacheable=false)
    public static void createPolicyRecord(String accountId, String policyNumber) {

        try {
          
             // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ InsurancePolicy.SObjectType }
            );
			String currentDate = System.now().format('yyyyMMddHHmmss');
            InsurancePolicy policy = new InsurancePolicy();
            policy.NameInsuredId = accountId;
            policy.Name = policyNumber + currentDate;
            policy.recordTypeId = Schema.SObjectType.InsurancePolicy.getRecordTypeInfosByDeveloperName().get('Commercial_Long_Term_Insurance').getRecordTypeId();
            unitOfWork.registerNew(policy);
  

            // Commit changes
            unitOfWork.commitWork();
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.createPolicyRecord',e.getMessage()},e);
            throw new AuraHandledException('Failed to create Policy Record ' + e.getMessage());
        }

    }

    /**
     * @description Updates the Sales Event step of an Opportunity
     * @author Vershley Joyejob | 19-09-2025
     * @param opportunityId Id of the Opportunity to update
     * @param salesEvent New onboarding step name
     **/
    @AuraEnabled(cacheable=false)
    public static void updateSalesEvent(String opportunityId, String salesEvent) {

        try {
            // Create Unit of Work
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Opportunity.SObjectType }
            );

            Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.Quote_Id__c = salesEvent;
            unitOfWork.registerDirty(opp);

            // Commit changes
            unitOfWork.commitWork();
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.updateSalesEvent',e.getMessage()},e);
            throw new AuraHandledException('Failed to update sale event ' + e.getMessage());
        }

    }

    /**
     * @description Updates the Sales Event step of an Opportunity
     * @author Vershley Joyejob | 19-09-2025
     * @param quoteId Id of the Quote to update
     * @return Boolean
     **/
    @AuraEnabled(cacheable=false)
    public static Boolean checkPolicyDocumentStatus(String quoteId) {
        Boolean isReturn = false;
        try {
            if(Schema.SObjectType.Quote.isAccessible() && (Schema.SObjectType.Quote.fields.Id.isAccessible() || Schema.SObjectType.Quote.fields.INS_PolicyDocumentLatestStatus__c.isAccessible())) {            
                Quote quote = [SELECT Id, INS_PolicyDocumentLatestStatus__c FROM Quote WHERE Id = :quoteId LIMIT 1];
                if(quote.INS_PolicyDocumentLatestStatus__c.containsIgnoreCase('Signed')){                    
                   isReturn = true;
                }
                else{                    
                    isReturn = false;
                }            
        	}
        }catch(Exception e){
            LOGGER.error(e.getMessage(),new String[]{'INS_PLI_UpdateProspectRecord.updateSalesEvent',e.getMessage()},e);
            throw new AuraHandledException('Failed to get policy document status ' + e.getMessage());
        }
        return isReturn;
    }

    /**
     * @description Resumes or starts onboarding based on existing Account and open Opportunity.
     *              If Account fields are blank, they are updated with the incoming personal information.
     * @author Vershley Joyejob | 19-09-2025
     * @param personalInformationJSON JSON string of personalInformation
     * @return Map<String,Object> containing Account and Opportunity details
     **/
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> resumeOrStartOnboarding(String personalInformationJSON) {
        Map<String, Object> outMap = new Map<String, Object>();

        try {
            personalInformation personalInfoWrapper = (personalInformation) JSON.deserialize(
                personalInformationJSON,
                personalInformation.class
            );
            String idNumber = personalInfoWrapper.IdNumber;
            List<Account> accs = new List<Account>();
            if(personalInfoWrapper.AccountId != null){
                accs = new SEL_Account().selectOpportunityByAccountId(Id.valueOf(personalInfoWrapper.AccountId));
            } else{
                accs = new SEL_Account().selectByIdentityNumberWithOpportunities(idNumber);
            }
            
            if (hasElements(accs)) {
                List<Quote> quotes = new SEL_Quote().selectByAccIds(new List<Id>{ accs[0].Id });                
                Account acc = accs[0];

                // Check for blank fields on the account and patch them
                // from the incoming personal information if needed
                acc = patchBlankAccountFields(acc, personalInfoWrapper);

                outMap.put('AccountId', acc.Id);

                Map<String, Object> accountMap = new Map<String, Object>();
                accountMap.put('FirstName', acc.FirstName);
                accountMap.put('LastName', acc.LastName);
                accountMap.put('Email', acc.PersonEmail);
                if (acc.PersonBirthdate != null) {
                    accountMap.put('DateOfBirth', String.valueOf(acc.PersonBirthdate));
                }
                accountMap.put('Phone', acc.PersonMobilePhone);
                accountMap.put('Gender', acc.FinServ__Gender__pc);
                accountMap.put('IdNumber', acc.CMN_IdentityNumber__pc);
                outMap.put('Account', accountMap);

                if (hasElements(acc.Opportunities)) {
                    Opportunity opp = acc.Opportunities[0];
                    outMap.put('OpportunityId', opp.Id);
                    outMap.put('CoverAmount', opp.Total_Cover_Amount__c);
                    outMap.put('MonthlyPremium', opp.Total_Monthly_Premium__c);
                    outMap.put('OnboardingStep', opp.INS_OnboardingStep__c);
                    outMap.put('QuoteId', quotes[0].Id);
                    outMap.put('SalesEvent', quotes[0].UnderwriterQuoteReferenceNumber__c);
                    outMap.put('Resume', true);
                } else {
                    outMap.put('Resume', false);
                }
            } else {
                outMap.put('Resume', false);
            }

        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_UpdateProspectRecord.resumeOrStartOnboarding', e.getMessage()}, e);
            throw new AuraHandledException('Failed to resume or start onboarding: ' + e.getMessage());
        }

        return outMap;
    }

    /**
     * @description Updates Account fields from provided map (keys -> person account fields)
     * @author Vershley Joyejob | 28-10-2025
     * @param accountId Id of the Account to update
     * @param data Map with keys: employment_status, nature_business_activity, employer, source_wealth, employment_type, occupation
     */
    @AuraEnabled(cacheable=false)
    public static void updateAccountRecord(String accountId, Map<String, String> data) {
        Map<String, Schema.sObjectField> fieldMapping = new Map<String, Schema.sObjectField>{
                'employment_status' => Account.CMN_EmploymentStatus__pc,
                'nature_business_activity' => Account.Location_of_Business__c,
                'employer' => Account.FinServ__CurrentEmployer__pc,
                'source_wealth' => Account.Source_of_Funds__c,
                'employment_type' => Account.EmploymentIndustry__c,
                'occupation' => Account.FinServ__Occupation__pc
        };
        try {
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Account.SObjectType }
            );
            Account acc = new Account();
            acc.Id = accountId;
            for (String key : fieldMapping.keySet()) {
                if (data != null && data.containsKey(key) && String.isNotBlank(data.get(key))) {
                    acc.put(fieldMapping.get(key).getDescribe().getName(), data.get(key));
                }
            }
            unitOfWork.registerDirty(acc);
            unitOfWork.commitWork();
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_UpdateProspectRecord.updateAccountRecord', e.getMessage()}, e);
            throw new AuraHandledException('Failed to update account information: '+e.getMessage());
        }
    }

    /**
     * @description Updates Account billing address and PartyProfile/PartyProfileAddress from JSON payload
     * @author M.Matabadul | 06-11-2025
     * @param jsonPayload
     */
    @AuraEnabled
    public static void updateAddress(String jsonPayload) {
        try {
            AddressData addressData = parseAndValidateAddressPayload(jsonPayload);
            
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                new List<Schema.SObjectType>{
                    Account.SObjectType, PartyProfile.SObjectType, PartyProfileAddress.SObjectType
                }
            );
            
            Account acc = getAccountById(addressData.accountId);
            updateAccountBillingAddress(acc, addressData, unitOfWork);
            
            PartyProfile partyProfile = upsertPartyProfile(acc, addressData, unitOfWork);
            upsertPartyProfileAddress(acc, partyProfile, addressData, unitOfWork);
            
            unitOfWork.commitWork();
            
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_UpdateProspectRecord.updateAddress', e.getMessage()}, e);
            throw new AuraHandledException('Failed to update address: ' + e.getMessage());
        }
    }

    /**
     * @description convert long url to short via API
     * @author Alexandr Goryachko | 12-11-2025
     * @param longUrl String
     * @return  `String` short url
     */
    @AuraEnabled
    public static String getShortUrl(String longUrl) {
        String result;
        try {
            result = INS_URL_ShorteningService.createShortUrl(longUrl);
        } catch(Exception e) {
            LOGGER.error(e.getMessage(), new String[]{'INS_PLI_UpdateProspectRecord.getShortUrl', e.getMessage()}, e);
            throw new AuraHandledException('Failed to get short link: ' + e.getMessage());
        }
        return result;
    }

    /**
     * @description Checks if a list has elements
     * @param items List to check
     * @return true if list is not null and has elements
     */
    private static Boolean hasElements(List<SObject> items) {
        return items != null && !items.isEmpty();
    }

    /**
     * @description Wrapper class for address data
     */
    private class AddressData {
        public String accountId;
        public String addressLine1;
        public String addressLine2;
        public String city;
        public String postalCode;
        public String countriesLiveIn;
        public String countriesCitizen;
    }

    /**
     * @description Parse and validate JSON payload
     * @param jsonPayload
     * @return AddressData
     */
    private static AddressData parseAndValidateAddressPayload(String jsonPayload) {
        Map<String, Object> data = (Map<String, Object>) JSON.deserializeUntyped(jsonPayload);
        
        String accId = (String) data.get('AccId');
        if (String.isBlank(accId)) {
            throw new AuraHandledException('Missing Account Id.');
        }
        
        Map<String, Object> addressInfo = (Map<String, Object>) data.get('AddressInformation');
        if (addressInfo == null) {
            throw new AuraHandledException('AddressInformation section missing.');
        }
        
        AddressData addressData = new AddressData();
        addressData.accountId = accId;
        addressData.addressLine1 = (String) addressInfo.get('AddressLine1');
        addressData.addressLine2 = (String) addressInfo.get('AddressLine2');
        addressData.city = (String) addressInfo.get('City');
        addressData.postalCode = (String) addressInfo.get('PostalCode');
        addressData.countriesLiveIn = (String) addressInfo.get('CountriesLiveIn');
        addressData.countriesCitizen = (String) addressInfo.get('CountriesCitizen');
        
        return addressData;
    }

    /**
     * @description Get Account by Id with validation
     * @param accountId
     * @return Account
     */
    private static Account getAccountById(String accountId) {
        Account acc = new SEL_Account().selectByIdWithServicingFields(accountId);
        if (acc == null) {
            throw new AuraHandledException('Account not found with Id: ' + accountId);
        }
        return acc;
    }

    /**
     * @description Update Account billing address fields
     * @param acc Account to update
     * @param addressData Address information
     * @param unitOfWork Unit of work
     */
    private static void updateAccountBillingAddress(Account acc, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        String billingStreet = addressData.addressLine1;
        if (String.isNotBlank(addressData.addressLine2)) {
            billingStreet += '\n' + addressData.addressLine2;
        }
        
        acc.BillingStreet = billingStreet;
        acc.BillingCity = addressData.city;
        acc.BillingPostalCode = addressData.postalCode;
        acc.BillingCountry = addressData.countriesLiveIn;
        unitOfWork.registerDirty(acc);
    }

    /**
     * @description Create or update PartyProfile
     * @param acc Account record
     * @param addressData Address information
     * @param unitOfWork Unit of work
     * @return PartyProfile (new or existing)
     */
    private static PartyProfile upsertPartyProfile(Account acc, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        SEL_PartyProfile partyProfileSelector = new SEL_PartyProfile();
        List<PartyProfile> partyProfiles = partyProfileSelector.selectByAccountId(acc.Id);
        
        PartyProfile partyProfile;
        
        if (hasElements(partyProfiles)) {
            partyProfile = partyProfiles[0];
            partyProfile.Country_of_Nationality__c = addressData.countriesLiveIn;
            partyProfile.WI_CountryOfCitizenship__c = addressData.countriesCitizen;
            unitOfWork.registerDirty(partyProfile);
        } else {
            partyProfile = createNewPartyProfile(acc, addressData, unitOfWork);
        }
        
        return partyProfile;
    }

    /**
     * @description Create new PartyProfile record
     * @param acc Account record
     * @param addressData Address information
     * @param unitOfWork Unit of work
     * @return New PartyProfile
     */
    private static PartyProfile createNewPartyProfile(Account acc, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        Id recordTypeId = getPartyProfileRecordTypeId();
        String fullName = buildFullName(acc.FirstName, acc.LastName);
        
        PartyProfile partyProfile = new PartyProfile();
        partyProfile.AccountId = acc.Id;
        partyProfile.FirstName = String.isNotBlank(acc.FirstName) ? acc.FirstName : '';
        partyProfile.LastName = String.isNotBlank(acc.LastName) ? acc.LastName : '';
        partyProfile.FullName = fullName;
        partyProfile.RecordTypeId = recordTypeId;
        partyProfile.Country_of_Nationality__c = addressData.countriesLiveIn;
        partyProfile.WI_CountryOfCitizenship__c = addressData.countriesCitizen;
        partyProfile.Name = 'KYC - PLATINUM LIFE - ' + fullName;
        
        unitOfWork.registerNew(partyProfile);
        return partyProfile;
    }

    /**
     * @description Get PartyProfile record type ID
     * @return Record Type Id
     */
    private static Id getPartyProfileRecordTypeId() {
        Schema.RecordTypeInfo rtInfo = Schema.SObjectType.PartyProfile
            .getRecordTypeInfosByDeveloperName()
            .get('Insurance_Individual');
            
        if (rtInfo == null) {
            throw new AuraHandledException('PartyProfile record type "Insurance_Individual" not found. Please contact your administrator.');
        }
        
        return rtInfo.getRecordTypeId();
    }

    /**
     * @description Build full name from first and last name
     * @param firstName
     * @param lastName
     * @return Full name
     */
    private static String buildFullName(String firstName, String lastName) {
        String first = String.isNotBlank(firstName) ? firstName : '';
        String last = String.isNotBlank(lastName) ? lastName : '';
        
        if (String.isBlank(first) && String.isBlank(last)) {
            throw new AuraHandledException('Account must have a FirstName or LastName to create PartyProfile');
        }
        
        return (first + ' ' + last).trim();
    }

    /**
     * @description Create or update PartyProfileAddress
     * @param acc Account record
     * @param partyProfile PartyProfile record
     * @param addressData Address information
     * @param unitOfWork Unit of work
     */
    private static void upsertPartyProfileAddress(Account acc, PartyProfile partyProfile, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        SEL_PartyProfileAddress addressSelector = new SEL_PartyProfileAddress();
        List<PartyProfileAddress> existingAddresses = new List<PartyProfileAddress>();
        
        if (String.isNotBlank(partyProfile.Id)) {
            existingAddresses = addressSelector.selectCurrentAddressByPartyProfileId(partyProfile.Id);
        }
        
        if (hasElements(existingAddresses)) {
            updateExistingAddress(existingAddresses[0], addressData, unitOfWork);
        } else {
            createNewAddress(acc, partyProfile, addressData, unitOfWork);
        }
    }

    /**
     * @description Update existing PartyProfileAddress
     * @param address Existing address
     * @param addressData Address information
     * @param unitOfWork Unit of work
     */
    private static void updateExistingAddress(PartyProfileAddress address, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        address.Street = addressData.addressLine1;
        address.Secondary_Street__c = addressData.addressLine2;
        address.City = addressData.city;
        address.PostalCode = addressData.postalCode;
        address.Country = addressData.countriesLiveIn;
        unitOfWork.registerDirty(address);
    }

    /**
     * @description Create new PartyProfileAddress
     * @param acc Account record
     * @param partyProfile PartyProfile record
     * @param addressData Address information
     * @param unitOfWork Unit of work
     */
    private static void createNewAddress(Account acc, PartyProfile partyProfile, AddressData addressData, CMN_DAL_SObjectUnitOfWork unitOfWork) {
        String fullName = buildFullName(acc.FirstName, acc.LastName);
        
        PartyProfileAddress partyProfileAddress = new PartyProfileAddress();
        partyProfileAddress.Name = 'PLATINUM LIFE - ' + fullName;
        partyProfileAddress.Street = addressData.addressLine1;
        partyProfileAddress.Secondary_Street__c = addressData.addressLine2;
        partyProfileAddress.City = addressData.city;
        partyProfileAddress.PostalCode = addressData.postalCode;
        partyProfileAddress.Country = addressData.countriesLiveIn;
        partyProfileAddress.AddressType = 'Residential Address';
        partyProfileAddress.Date_Move_In__c = Date.today();
        
        if (String.isNotBlank(partyProfile.Id)) {
            partyProfileAddress.PartyProfileId = partyProfile.Id;
            unitOfWork.registerNew(partyProfileAddress);
        } else {
            unitOfWork.registerNew(partyProfileAddress, Schema.PartyProfileAddress.PartyProfileId, partyProfile);
        }
    }

    /**
     * @description Resolves the opportunity source string based on the page identifier or the current user's company.
     *              If a page identifier is provided, a web-based source is returned.
     *              If no page identifier is provided, the current user's company name is used to derive a DSA source.
     *              Returns null if the source cannot be determined.
     * @param pageIdentifier The identifier of the page initiating the quoting process (e.g. 'Liberty', 'Stanbic'). May be blank or null.
     * @param users          List of User records for the current user. Expected to contain at most one record.
     * @return               The resolved opportunity source string, or null if it cannot be determined.
     */    
	@TestVisible    
    private static String resolveOpportunitySource(String pageIdentifier, List<User> users) {
        final Map<String, String> WEB_SOURCE_MAP = new Map<String, String>{
            'Liberty' => 'WEB Liberty',
            'Stanbic' => 'WEB Stanbic'
        };
        final Map<String, String> DSA_SOURCE_MAP = new Map<String, String>{
            'Liberty' => 'DSA Liberty',
            'Stanbic' => 'DSA Stanbic'
        };

        if (String.isNotBlank(pageIdentifier)) {
            return WEB_SOURCE_MAP.get(pageIdentifier);
        }

        if (!users.isEmpty()) {
            String companyName = users[0].CompanyName;
            if (String.isNotBlank(companyName)) {
                return DSA_SOURCE_MAP.get(companyName);
            }
            return 'FSC';
        }

        LOGGER.error(
            'User not found',
            new String[]{ 'INS_PLI_UpdateProspectRecord.updateOnboardingSteps' },
            null
        );
        return null;
    }

    /**
     * @description Checks each mapped Account field — if blank on the org record,
     *              patches it with the value from the incoming personal information wrapper.
     *              Only performs a DML update if at least one field was actually patched.
     * @param acc                 The Account record retrieved from the org
     * @param personalInfoWrapper The deserialised personal information from the LWC
     * @return The updated Account record (with patched values reflected in memory)
     **/
    private static Account patchBlankAccountFields(Account acc, personalInformation personalInfoWrapper) {
        Boolean needsUpdate = false;

        if (String.isBlank(acc.PersonEmail) && String.isNotBlank(personalInfoWrapper.Email)) {
            acc.PersonEmail = personalInfoWrapper.Email;
            needsUpdate = true;
        }
        if (String.isBlank(acc.FinServ__Gender__pc) && String.isNotBlank(personalInfoWrapper.Gender)) {
            acc.FinServ__Gender__pc = personalInfoWrapper.Gender;
            needsUpdate = true;
        }
        if (String.isBlank(acc.PersonMobilePhone) && String.isNotBlank(personalInfoWrapper.PhoneNumber)) {
            acc.PersonMobilePhone = '+254' + personalInfoWrapper.PhoneNumber;
            needsUpdate = true;
        }
        if (acc.PersonBirthdate == null && String.isNotBlank(personalInfoWrapper.DateOfBirth)) {
            acc.PersonBirthdate = Date.valueOf(personalInfoWrapper.DateOfBirth);
            needsUpdate = true;
        }

        if (needsUpdate) {
            CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                new List<Schema.SObjectType>{ Account.SObjectType }
            );
            unitOfWork.registerDirty(acc);
            unitOfWork.commitWork();

            LOGGER.info(
                'patchBlankAccountFields: Account fields patched for Id: ' + acc.Id,
                new String[]{'INS_PLI_UpdateProspectRecord.patchBlankAccountFields'}
            );
        }

        return acc;
    }

    /**
     * @description Updates only Email and Phone fields on an existing Prospect Person Account.
     * @author
     * @param accountId Account Id to update
     * @param email Email address
     * @param phoneNumber Phone number without country code
     **/
    @AuraEnabled
    public static void updateProspectContactDetails(
        String accountId,
        String email,
        String phoneNumber
    ) {
        try {
            if (String.isBlank(accountId)) {
                throw new AuraHandledException('Account Id is required.');
            }

            CMN_DAL_SObjectUnitOfWork unitOfWork =
                new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{
                        Account.SObjectType
                    }
                );

            Account acc = new Account();
            acc.Id = accountId;

            if (String.isNotBlank(email)) {
                acc.PersonEmail = email;
            }

            if (String.isNotBlank(phoneNumber)) {
                acc.Phone = phoneNumber;
            }

            unitOfWork.registerDirty(acc);
            unitOfWork.commitWork();

        } catch (Exception e) {
            LOGGER.error(
                e.getMessage(),
                new String[]{
                    'INS_PLI_UpdateProspectRecord.updateProspectContactDetails',
                    e.getMessage()
                },
                e
            );

            throw new AuraHandledException(
                'Failed to update prospect contact details: ' + e.getMessage()
            );
        }
    }
    /**
     * @description Updates the Opportunity Close Date to today's date.
     * @author
     * @param opportunityId Id of the Opportunity to update
     **/
    @AuraEnabled
    public static void updateOpportunityCloseDate(String opportunityId) {

        try {
            if (String.isBlank(opportunityId)) {
                throw new AuraHandledException('Opportunity Id is required.');
            }

            CMN_DAL_SObjectUnitOfWork unitOfWork =
                new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{
                        Opportunity.SObjectType
                    }
                );

            Opportunity opp = new Opportunity();
            opp.Id = opportunityId;
            opp.CloseDate = Date.today();

            unitOfWork.registerDirty(opp);
            unitOfWork.commitWork();

        } catch (Exception e) {
            LOGGER.error(
                e.getMessage(),
                new String[]{
                    'INS_PLI_UpdateProspectRecord.updateOpportunityCloseDate',
                    e.getMessage()
                },
                e
            );

            throw new AuraHandledException(
                'Failed to update Opportunity Close Date: ' + e.getMessage()
            );
        }
    }
}