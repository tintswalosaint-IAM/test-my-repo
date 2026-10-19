/**
 * @description       : Helper class for processing KYC-related records (PartyProfile, Address, Employment, Tax, Steps)
 * @author            : Vershley Joyejob
 * @UserStory         : SFP-53627
 * @date              : 13-10-2025
 * Test class         : INS_PLI_ProcessKYCRecords_Test
 **/
public without sharing class INS_PLI_ProcessKYCRecords {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('INS_PLI_ProcessKYCRecords');

    /**
    * @description  Account object
    */
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String PARTYPROFILE_OBJECT = 'PartyProfile';

    /**
     * @description Initiate KYC by creating PartyProfile if missing for the given Account
     * @author Vershley Joyejob
     * @date 14-10-2025
     * @param initiateKycPayload JSON payload with fields: AccountId, FirstName, LastName, Gender, Email, Phone, IdNumber
     * @return String PartyProfile Id for the Account
     */
    @AuraEnabled(Cacheable=false)
    public static String initiateKYCProcess(String initiateKycPayload){
        try{
            Map<String, Object> kycInitateData = (Map<String, Object>) JSON.deserializeUntyped(initiateKycPayload);
            
            Id idRecord = (Id) kycInitateData.get('AccountId');
            String firstName = (String) kycInitateData.get('FirstName');
            String lastName = (String) kycInitateData.get('LastName');
            String gender = (String) kycInitateData.get('Gender');
            String email = (String) kycInitateData.get('Email');
            String phone = (String) kycInitateData.get('Phone');
            String IdNumber = (String) kycInitateData.get('IdNumber');
            if (ACCOUNT_OBJECT == idRecord.getSobjectType().getDescribe().getName()) {
                SEL_PartyProfile selectPartyProfile = new SEL_PartyProfile();
                List<PartyProfile> partyProfileList= new List<PartyProfile>();
                partyProfileList = selectPartyProfile.selectByAccountId(idRecord);
                if(partyProfileList == null || partyProfileList.isEmpty()){
                    PartyProfile partyProfile = new PartyProfile(
                        AccountId = idRecord,
                        Name = 'KYC - PLATINUM LIFE - ' + firstName + ' ' + lastName,
                        FirstName = firstName,
                        LastName = lastName,
                        Gender = gender,
                        PrimaryEmail = email,
                        PrimaryPhone = phone,
                        WI_PrimaryIdentificationName__c = IdNumber
                    );
                    insert partyProfile;
                    return partyProfile.Id;
                }else{
                    return partyProfileList[0].Id;
                }
                
            }
        }catch(Exception e){
            LOGGER.error('INS_PLI_ProcessKYCRecords.initiateKYCProcess'+ e.getMessage() + ' Line Exception '+ e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        
        return null;
        
    }


    /**
     * @description Create primary PartyProfileAddress (Shipping) for a PartyProfile when none exists
     * @author Vershley Joyejob
     * @date 14-10-2025
     * @param partyProfileId PartyProfile Id to attach the address to
     * @param addressJSON JSON with fields: AddressLine1, AddressLine2, City, PostalCode, CountriesLiveIn, CountriesCitizen
     * @param personalInfoJSON JSON with fields: FirstName, LastName (for naming)
     * @return String PartyProfile Id on success; null otherwise
     */
    @AuraEnabled(Cacheable=false)
    public static String createPartyAddress(String partyProfileId, String addressJSON, String personalInfoJSON){
        try{
            Map<String, Object> partyAddress = (Map<String, Object>) JSON.deserializeUntyped(addressJSON);
            String AddressLine1 = (String) partyAddress.get('AddressLine1');
            String AddressLine2 = (String) partyAddress.get('AddressLine2');
            String City = (String) partyAddress.get('City');
            String PostalCode = (String) partyAddress.get('PostalCode');
            String CountriesLiveIn = (String) partyAddress.get('CountriesLiveIn');
            
            Id idRecord = (Id) partyProfileId;
            
            Map<String, Object> personalDataInfo = (Map<String, Object>) JSON.deserializeUntyped(personalInfoJSON);
            String firstName = (String) personalDataInfo.get('FirstName');
            String lastName = (String) personalDataInfo.get('LastName');
            
            
            if (PARTYPROFILE_OBJECT == idRecord.getSobjectType().getDescribe().getName()) {
                SEL_PartyProfileAddress selector = new SEL_PartyProfileAddress();
                List<PartyProfileAddress> currAddressInfoList = selector.selectCurrentAddressByPartyProfileId(idRecord);
                if (currAddressInfoList.isEmpty()) {
                    PartyProfileAddress tempAddr = new PartyProfileAddress(
                        PartyProfileId = idRecord,
                        Name = 'PLATINUM LIFE - ' + firstName + ' ' + lastName,
                        Street = AddressLine1,
                        Secondary_Street__c = AddressLine2,
                        City = City,
                        PostalCode = PostalCode,
                        State = CountriesLiveIn,
                        Country = CountriesLiveIn,
                        AddressType = 'Shipping',
                        IsPrimaryAddress = true
                    );
                    insert tempAddr;
                    return idRecord;
                }
                
            }
        }catch(Exception e){
            LOGGER.error('INS_PLI_ProcessKYCRecords.createPartyAddress'+ e.getMessage() + ' Line Exception '+ e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
     * @description Update employment-related fields on Account from provided JSON
     * @author Vershley Joyejob
     * @date 14-10-2025
     * @param accountId Account Id to update
     * @param employmentJSON JSON with fields: employment_status, nature_business_activity, Employer, source_wealth, Employment_type, Occupation
     * @return String Account Id on success; null if input is invalid
     */
    @AuraEnabled(Cacheable=false)
    public static String processEmploymentInformation(String accountId, String employmentJSON){
        try{
            Map<String, Object> employmentInfo = (Map<String, Object>) JSON.deserializeUntyped(employmentJSON);
            String employmentStatus = (String) employmentInfo.get('employment_status');
            String natureBusinessActivity = (String) employmentInfo.get('nature_business_activity');
            String employer = (String) employmentInfo.get('Employer');
            String sourceWealth = (String) employmentInfo.get('source_wealth');
            String employmentType = (String) employmentInfo.get('Employment_type');
            String occupation = (String) employmentInfo.get('Occupation');
            
            Id idRecord = (Id) accountId;
            
            if (ACCOUNT_OBJECT == idRecord.getSobjectType().getDescribe().getName()) {
                CMN_DAL_SObjectUnitOfWork unitOfWork = new CMN_DAL_SObjectUnitOfWork(
                    new List<Schema.SObjectType>{ Account.SObjectType }
                );
                Account account = new Account();
                account.Id = idRecord;
                account.EmploymentStatus__c = employmentStatus;
                account.NatureofBusiness__c = natureBusinessActivity;
                account.FinServ__CurrentEmployer__pc = employer;
                account.Source_of_Funds__c = sourceWealth;
                account.EmploymentIndustry__c = employmentType;
                account.FinServ__Occupation__pc = occupation;
                unitOfWork.registerDirty(account);
                unitOfWork.commitWork();
                return idRecord;
            }
        }catch(Exception e){
            LOGGER.error('INS_PLI_ProcessKYCRecords.processEmploymentInformation'+ e.getMessage() + ' Line Exception '+ e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    

    /**
     * @description Create TaxDetails__c records for an Account from provided payload
     * @author Vershley Joyejob
     * @date 14-10-2025
     * @param accountId Account Id for which to create tax records
     * @param taxJSON JSON with fields: taxList (array of { country, tin, foreignAddress, foreignPhone, ownershipInterest, entityName, entityAddress, entityCountry }), ownership (object)
     * @return String status message with the number of processed tax records
     */
    @AuraEnabled(Cacheable=false)
    public static String processTaxInformation(
        String accountId,
        String taxJSON
    ) {
        try {
            Map<String, Object> taxData =
                (Map<String, Object>) JSON.deserializeUntyped(taxJSON);

            TaxDetails__c taxDetails = new TaxDetails__c();

            /*
            * Existing record:
            * Update the existing TaxDetails__c.
            *
            * New record:
            * Id will be null and Salesforce will create
            * a new TaxDetails__c record.
            */
            if (taxData.containsKey('id') &&
                taxData.get('id') != null &&
                String.isNotBlank((String) taxData.get('id'))) {

                taxDetails.Id = (Id) taxData.get('id');
            }

            taxDetails.Name =
                'Tax Captured - Platinum Life Onboarding';

            taxDetails.Account__c = accountId;

            taxDetails.Country__c =
                (String) taxData.get('country');

            taxDetails.TaxNumber__c =
                (String) taxData.get('tin');

            taxDetails.CMN_ForeignMailingAddress__c =
                (String) taxData.get('foreignAddress');

            taxDetails.CMN_ForeignPhoneNumber__c =
                (String) taxData.get('foreignPhone');

            /*
            * Ownership information
            */
            String ownershipInterest =
                (String) taxData.get('ownershipInterest');

            taxDetails.CMN_MajorityControllingInterest__c =
                ownershipInterest != null &&
                ownershipInterest.equalsIgnoreCase('Yes');

            taxDetails.CMN_EntityName__c =
                (String) taxData.get('entityName');

            taxDetails.CMN_EntityAddress__c =
                (String) taxData.get('entityAddress');

            taxDetails.CMN_EntityCountry__c =
                (String) taxData.get('entityCountry');

            /*
            * Save ONLY this record
            */
            if (taxDetails.Id != null) {

                update taxDetails;

                return String.valueOf(taxDetails.Id);

            } else {

                insert taxDetails;

                return String.valueOf(taxDetails.Id);
            }

        } catch (Exception e) {

            LOGGER.error(
                'INS_PLI_ProcessKYCRecords.processTaxInformation ' +
                e.getMessage() +
                ' Line Exception ' +
                e.getLineNumber() +
                ' Stack trace: ' +
                e.getStackTraceString()
            );

            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Get current onboarding step from Quote → Opportunity
     * @author Vershley Joyejob
     * @date 14-10-2025
     * @param quoteId Quote Id to read current step from
     * @return String current onboarding step (Opportunity.INS_OnboardingStep__c)
     */
    @AuraEnabled(Cacheable=false)
    public static String getCurrentKYCStep(String quoteId) {
        try{
            List<Quote> quotes = new SEL_Quote().selectByIds(new List<Id>{ quoteId });
            if (quotes.isEmpty()) {
                return null;
            }
            Opportunity opp = new SEL_Opportunity().selectById(quotes[0].OpportunityId);
            return opp != null ? opp.INS_OnboardingStep__c : null;
        }catch(Exception e){
            LOGGER.error('INS_PLI_ProcessKYCRecords.getCurrentKYCStep'+ e.getMessage() + ' Line Exception '+ e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

    }

    /**
     * @description Call RAAS Customer service to auto-process RelyComply for a PartyProfile
     * @author Vershley Joyejob
     * @date 20-10-2025
     * @param partyProfileId PartyProfile Id
     * @return KYC_DTO_Response response from RAAS service
     */
    @AuraEnabled(Cacheable=false)
    public static KYC_DTO_Response autoProcessRelyComply(String partyProfileId) {
        try{
            return KYC_CTRL_RAASCustomer.callRAASCustomer(partyProfileId);
        }catch(Exception e){
            LOGGER.error('INS_PLI_ProcessKYCRecords.autoProcessRelyComply'+ e.getMessage() + ' Line Exception '+ e.getLineNumber() + ' Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Fetch tax details and ownership information for an account.
     * @param accountId Account Id whose tax information is requested
     * @return JSON containing the tax records and ownership information
     */
    @AuraEnabled
    public static String fetchTaxInformation(String accountId) {
        try {
            return buildTaxInformationResponse(accountId);

        } catch (Exception e) {

            LOGGER.error(
                'INS_PLI_ProcessKYCRecords.getTaxInformation ' +
                e.getMessage() +
                ' Line Exception ' +
                e.getLineNumber() +
                ' Stack trace: ' +
                e.getStackTraceString()
            );

            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Query tax records and construct the serialized response.
     * @param accountId Account Id whose tax information is requested
     * @return JSON containing the tax records and ownership information
     */
    private static String buildTaxInformationResponse(String accountId) {
        Map<String, Object> ownership = defaultTaxOwnership();
        List<Map<String, Object>> taxList = new List<Map<String, Object>>();

        if (String.isBlank(accountId)) {
            return serializeTaxInformation(taxList, ownership);
        }

        List<String> taxFields = new List<String>{
            'Id', 'Account__c', 'Country__c', 'TaxNumber__c',
            'CMN_ForeignMailingAddress__c', 'CMN_ForeignPhoneNumber__c',
            'CMN_MajorityControllingInterest__c', 'CMN_EntityName__c',
            'CMN_EntityAddress__c', 'CMN_EntityCountry__c'
        };
        List<TaxDetails__c> taxRecords =
            new SEL_TaxDetails().selectByAccountIdAndFields(
                new Set<Id>{ accountId }, taxFields
            );

        for (TaxDetails__c tax : taxRecords) {
            Boolean isUS = String.isNotBlank(tax.Country__c) &&
                tax.Country__c.equalsIgnoreCase('US');
            taxList.add(buildTaxRecordData(tax, isUS));
            if (isUS) {
                ownership = buildTaxOwnership(tax);
            }
        }
        return serializeTaxInformation(taxList, ownership);
    }

    private static Map<String, Object> defaultTaxOwnership() {
        return new Map<String, Object>{
            'ownershipInterest' => 'No',
            'entityName' => '',
            'entityAddress' => '',
            'entityCountry' => ''
        };
    }

    private static Map<String, Object> buildTaxRecordData(
        TaxDetails__c tax,
        Boolean isUS
    ) {
        return new Map<String, Object>{
            'id' => tax.Id,
            'country' => tax.Country__c,
            'tin' => tax.TaxNumber__c,
            'foreignAddress' => tax.CMN_ForeignMailingAddress__c,
            'foreignPhone' => tax.CMN_ForeignPhoneNumber__c,
            'ownershipInterest' => tax.CMN_MajorityControllingInterest__c == true
                ? 'Yes' : 'No',
            'entityName' => tax.CMN_EntityName__c,
            'entityAddress' => tax.CMN_EntityAddress__c,
            'entityCountry' => tax.CMN_EntityCountry__c,
            'isUSCountry' => isUS
        };
    }

    private static Map<String, Object> buildTaxOwnership(TaxDetails__c tax) {
        return new Map<String, Object>{
            'ownershipInterest' => tax.CMN_MajorityControllingInterest__c == true
                ? 'Yes' : 'No',
            'entityName' => tax.CMN_EntityName__c != null ? tax.CMN_EntityName__c : '',
            'entityAddress' => tax.CMN_EntityAddress__c != null ? tax.CMN_EntityAddress__c : '',
            'entityCountry' => tax.CMN_EntityCountry__c != null ? tax.CMN_EntityCountry__c : ''
        };
    }

    private static String serializeTaxInformation(
        List<Map<String, Object>> taxList,
        Map<String, Object> ownership
    ) {
        return JSON.serialize(new Map<String, Object>{
            'taxList' => taxList,
            'ownership' => ownership
        });
    }
    /**
     * @description Delete a specific TaxDetails__c record
     * @param taxDetailsId TaxDetails__c record Id
     * @return String success message
     */
    @AuraEnabled
    public static String deleteTaxInformation(String taxDetailsId) {
        try {
            if (String.isBlank(taxDetailsId)) {
                throw new AuraHandledException('Tax Details Id is required.');
            }

            Id recordId = (Id) taxDetailsId;

            if (recordId.getSObjectType() != TaxDetails__c.SObjectType) {
                throw new AuraHandledException('Invalid Tax Details record Id.');
            }

            TaxDetails__c taxRecord = [
                SELECT Id
                FROM TaxDetails__c
                WHERE Id = :recordId
                LIMIT 1
            ];

            delete taxRecord;

            return 'Tax record deleted successfully: ' + taxDetailsId;

        } catch (Exception e) {
            LOGGER.error(
                'INS_PLI_ProcessKYCRecords.deleteTaxInformation ' +
                e.getMessage() +
                ' Line Exception ' +
                e.getLineNumber() +
                ' Stack trace: ' +
                e.getStackTraceString()
            );

            throw new AuraHandledException(e.getMessage());
        }
    }
}