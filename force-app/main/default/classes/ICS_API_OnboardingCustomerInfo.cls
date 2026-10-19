@RestResource(urlMapping='/icscustomerapis/*')
global without sharing class ICS_API_OnboardingCustomerInfo {
     private static Set<Id> getAccountIds(List<ApplicationForm> applicationForms) {
        Set<Id> accountIds = new Set<Id>();
        
        for (ApplicationForm form : applicationForms) {
            // Add primary account ID
            accountIds.add(form.AccountId);
            
            // Add applicant account IDs
            for (Applicant applicant : form.Applicants) {
                accountIds.add(applicant.AccountId);
            }
        }
        
        return accountIds;
    }
    @HttpGet
    global static DTO_RESWrapper getCustomerDetails() {
        try {
            String oppId = getOpportunityId();
            if (oppId == null) {
                return createErrorResponse('Please check the combination of all mandatory fields', 500);
            }
            
            List<ApplicationForm> applicationForms = getApplicationForms(oppId);
            Set<Id> accountIds = getAccountIds(applicationForms);
             
          
            Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap = new Map<Id, DTO_REST_OnboardingManager.DTO_Address>();
            Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress1Map = new Map<Id, DTO_REST_OnboardingManager.DTO_Address>();
            Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map = new Map<Id, DTO_REST_OnboardingManager.DTO_Address>();
            
            loadAddressMaps(accountIds, primaryAddressMap, additionalAddress1Map, additionalAddress2Map);
            Map<String, String> signingMandateMap = getSigningMandates(accountIds);
            List<FinServ__FinancialAccount__c> finAccounts = getFinancialAccounts(accountIds);
            
            
            return createSuccessResponse(
                buildOnboardingResponse(
                    applicationForms, 
                    primaryAddressMap,
                    additionalAddress2Map,
                    signingMandateMap, 
                    finAccounts
                )
            );
        } catch (Exception e) {
            return createErrorResponse('Error processing request: ' + e.getMessage(), 500);
        }
    }
    
    private static String getOpportunityId() {
        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;
        
        String sfAccountID = params.get('SFAccountID');
        if (!String.isEmpty(sfAccountID)) {
            return new SEL_ApplicationForm().selectByAccountId(sfAccountID)[0].OpportunityId;
        }
        
        return getOpportunityIdByPersonalInfo(params);
    }
    
    private static String getOpportunityIdByPersonalInfo(Map<String, String> params) {
        String firstName = params.get('firstName');
        String surName = params.get('surName');
        String documentId = params.get('documetid');
        Date dob = params.get('dob') == null ? null :  Date.valueOf(params.get('dob'));
        
        if (String.isEmpty(firstName) || String.isEmpty(surName) || dob == null) {
            return null;
        }
        
        List<ApplicationForm> appForms = new SEL_ApplicationForm().selectByFirstandLastNameandBirth(new Set<String>{firstName},new Set<String>{surName},new Set<Date>{dob});
        
        if (appForms.isEmpty()) {
            return null;
        }
        
        if (!String.isEmpty(documentId)) {
            List<PartyProfile> profiles = new SEL_PartyProfile().selectByAccountIdandPrimaryIdentificationName(new set<id>{appForms[0].AccountId},new set<String>{documentId});
            if (profiles.isEmpty()) {
                return null;
            }
        }
        
        return appForms[0].OpportunityId;
    }
    
    private static List<ApplicationForm> getApplicationForms(String oppId) {
        return new SEL_ApplicationForm().selectByOpportunityId(new set<id>{oppId});
    }
    private static Map<Id, String> getDeliveryAddressTypes(Set<Id> accountIds) {
        Map<Id, String> addressTypeMap = new Map<Id, String>();
        
        for(AssessmentQuestionResponse response : [
            SELECT Assessment.AccountId, ResponseText
            FROM AssessmentQuestionResponse 
            WHERE Assessment.AccountId IN :accountIds 
            AND AssessmentQuestion.Name = 'Which address should the Visa Debit Card be delivered to?'
        ]) {
            String addressType;
            switch on response.ResponseText {
                when 'Correspondence address provided' {
                    addressType = 'Correspondence Address';
                }
                when 'Alternative delivery address' {
                    addressType = 'Other';
                }
                when 'Current residential address' {
                    addressType = 'Residential Address';
                }
            }
            addressTypeMap.put(response.Assessment.AccountId, addressType);
        }
        return addressTypeMap;
    }
    
    private static void loadAddressMaps(
        Set<Id> accountIds,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress1Map,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map
    ) {
        Map<Id, String> deliveryAddressTypes = getDeliveryAddressTypes(accountIds);
        for (PartyProfile profile : new SEL_PartyProfile().selectByAccountId(accountIds)){
            processAddresses(profile, primaryAddressMap, additionalAddress1Map, additionalAddress2Map,deliveryAddressTypes.get(profile.AccountId));
        }
    }
    
    private static void processAddresses(
        PartyProfile profile, 
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress1Map,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map,
        string deliveryAddressType
    ) { 
        Boolean primarySet = false;
        Boolean addr1Set = false;
        for (PartyProfileAddress addr : profile.PartyProfileAddresses) {
            DTO_REST_OnboardingManager.DTO_Address dtoAddr = createDTOAddress(addr);
            
            if (!primarySet && addr.Date_Move_Out__c == null && addr.AddressType=='Residential Address') {
                primaryAddressMap.put(profile.AccountId, dtoAddr);
                primarySet = true;
            } else if (!addr1Set && addr.Date_Move_Out__c != null) {
                additionalAddress1Map.put(profile.AccountId, dtoAddr);
                addr1Set = true;
            }
            if (addr.AddressType==deliveryAddressType) {
                additionalAddress2Map.put(profile.AccountId, dtoAddr);
                break;
            }
        }
    }
    
    
    private static DTO_REST_OnboardingManager.DTO_Address createDTOAddress(PartyProfileAddress addr) {
        DTO_REST_OnboardingManager.DTO_Address dtoAddr = new DTO_REST_OnboardingManager.DTO_Address();
        dtoAddr.street = getStreetValue(addr);
        dtoAddr.city = addr.City;
        dtoAddr.state = addr.State;
        dtoAddr.postalcode = addr.PostalCode;
        dtoAddr.country = addr.Country;
        return dtoAddr;
    }
    
    private static String getStreetValue(PartyProfileAddress addr) {
        // Create list of non-null address components in desired order
        List<String> addressComponents = new List<String>{
            addr.Apartment_Number__c,
            addr.Building_Name__c,
            addr.Sub_Building__c,
            addr.Street,
            addr.Secondary_Street__c == null ? addr.Neighbourhood__c : addr.Secondary_Street__c,
            addr.Parish__c
        };
        
        // Filter out null values and join with comma
        List<String> validComponents = new List<String>();
        for(String component : addressComponents) {
            if(String.isNotBlank(component)) {
                validComponents.add(component);
            }
        }
        
        return String.join(validComponents, ',');
    }

    
    private static Map<String, String> getSigningMandates(Set<Id> accountIds) {
        Map<String, String> mandateMap = new Map<String, String>();
        
        for (AssessmentQuestionResponse response : [
            SELECT Assessment.AccountId, ResponseText 
            FROM AssessmentQuestionResponse 
            WHERE AssessmentQuestion.Name = 'Do you require all the account holders to sign in order to operate the account?' 
            AND Assessment.AccountId IN :accountIds
        ]) {
            mandateMap.put(response.Assessment.AccountId, response.ResponseText);
        }
        
        return mandateMap;
    }
    
    private static List<FinServ__FinancialAccount__c> getFinancialAccounts(Set<Id> accountIds) {
        return [
            SELECT Id, SBO_All_Parties_Required_To_Sign__c
            FROM FinServ__FinancialAccount__c 
            WHERE FinServ__JointOwner__c IN :accountIds 
            LIMIT 1
        ];
    }
    
    private static DTO_REST_OnboardingManager buildOnboardingResponse(
        List<ApplicationForm> applicationForms,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map,
        Map<String, String> signingMandateMap,
        List<FinServ__FinancialAccount__c> finAccounts
    ) {
        DTO_REST_OnboardingManager response = new DTO_REST_OnboardingManager();
        List<DTO_REST_OnboardingManager.RelatedParties> relatedParties = new List<DTO_REST_OnboardingManager.RelatedParties>();
        
        for (ApplicationForm form : applicationForms) {
            processApplicants(
                form, 
                response, 
                relatedParties, 
                primaryAddressMap,
                additionalAddress2Map,
                signingMandateMap, 
                finAccounts
            );
        }
        
        response.RelatedParties = relatedParties;
        response.AccountType = relatedParties.isEmpty() ? 'Sole' : 'Joint';
        
        return response;
    }
    
    private static void processApplicants(
        ApplicationForm form,
        DTO_REST_OnboardingManager response,
        List<DTO_REST_OnboardingManager.RelatedParties> relatedParties,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map,
        Map<String, String> signingMandateMap,
        List<FinServ__FinancialAccount__c> finAccounts
    ) {
        for (Applicant applicant : form.Applicants) {
            if (isPrimaryApplicant(applicant)) {
                populatePrimaryApplicant(
                    response, 
                    form, 
                    applicant, 
                    primaryAddressMap,
                    additionalAddress2Map,
                    signingMandateMap, 
                    finAccounts
                );
            } else {
                relatedParties.add(
                    createRelatedParty(
                        form, 
                        applicant, 
                        primaryAddressMap,
                        additionalAddress2Map,
                        signingMandateMap, 
                        finAccounts
                    )
                );
            }
        }
    }
    
    private static void populatePrimaryApplicant(
        DTO_REST_OnboardingManager response,
        ApplicationForm form,
        Applicant applicant,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map,
        Map<String, String> signingMandateMap,
        List<FinServ__FinancialAccount__c> finAccounts
    ) {
        response.SFAccountID = form.AccountId; 
        response.PrimaryAddress = primaryAddressMap.get(form.AccountId);
        response.alternateCardDeliverAddress = additionalAddress2Map.get(form.AccountId);
        response.additionalAddress2 = null;//additionalAddress1Map.get(form.AccountId);
        response.SigningMandate = (getSigningMandate(form.AccountId, signingMandateMap, finAccounts) == null) ? 'No' : 'Yes';
        response.EmailAddress = form.Account.PersonEmail;
        response.FirstName = form.Account.FirstName;
        response.DateofBirth = String.valueOf(form.Account.PersonBirthdate);
        response.Surname = form.Account.lastName;
        response.Nationality = applicant.PartyProfile.Country_of_Nationality__c;
        response.BPID=applicant.Account.ExternalCIFId__c;
        response.idNumber = applicant.PartyProfile.PrimaryIdentifier;
        if(applicant.PartyProfile.WI_PassportValidTo__c !=null){
            response.validTo = String.valueOf(applicant.PartyProfile.WI_PassportValidTo__c);
        }
        if(applicant.PartyProfile.WI_PassportValidFrom__c !=null){
            response.validfrom = String.valueOf(applicant.PartyProfile.WI_PassportValidFrom__c);
        }
        if(applicant.PartyProfile.WI_VisaPermitExpiryDate__c !=null){
            response.expiryDate = String.valueOf(applicant.PartyProfile.WI_VisaPermitExpiryDate__c);
        }
    }
     
    private static DTO_REST_OnboardingManager.RelatedParties createRelatedParty(
        ApplicationForm form,
        Applicant applicant,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> primaryAddressMap,
        Map<Id, DTO_REST_OnboardingManager.DTO_Address> additionalAddress2Map,
        Map<String, String> signingMandateMap,
        List<FinServ__FinancialAccount__c> finAccounts
    ) {
        DTO_REST_OnboardingManager.RelatedParties rp = new DTO_REST_OnboardingManager.RelatedParties();
        rp.SFAccountID = form.AccountId;
        rp.SFPartyProfileID = applicant.PartyProfileId;
        rp.PrimaryAddress = primaryAddressMap.get(form.AccountId);
        rp.alternateCardDeliverAddress = additionalAddress2Map.get(form.AccountId);
        rp.additionalAddress2 = null;//additionalAddress1Map.get(form.AccountId)   ;
        rp.EmailAddress = form.Account.PersonEmail;
        rp.AuthorisedSignatory = 'Yes';
        rp.FirstName = applicant.Account.FirstName;
        rp.DateofBirth = String.valueOf(applicant.Account.PersonBirthdate);
        rp.Surname = applicant.Account.lastName;
        rp.Nationality = applicant.PartyProfile.Country_of_Nationality__c;
        rp.idNumber = applicant.PartyProfile.PrimaryIdentifier;
        rp.SigningMandate = (getSigningMandate(form.AccountId, signingMandateMap, finAccounts) == null) ? 'No' : 'Yes';
        rp.BPID=applicant.Account.ExternalCIFId__c;
        rp.idNumber = applicant.PartyProfile.PrimaryIdentifier;
        if(applicant.PartyProfile.WI_PassportValidTo__c !=null){
            rp.validTo = String.valueOf(applicant.PartyProfile.WI_PassportValidTo__c);
        }
        if(applicant.PartyProfile.WI_PassportValidFrom__c !=null){
            rp.validfrom = String.valueOf(applicant.PartyProfile.WI_PassportValidFrom__c);
        }
        if(applicant.PartyProfile.WI_VisaPermitExpiryDate__c !=null){
            rp.expiryDate = String.valueOf(applicant.PartyProfile.WI_VisaPermitExpiryDate__c);
        }
        return rp;
    }
    
    private static String getSigningMandate(
        Id accountId,
        Map<String, String> signingMandateMap,
        List<FinServ__FinancialAccount__c> finAccounts
    ) {
        if (!finAccounts.isEmpty()) {
            return finAccounts[0].SBO_All_Parties_Required_To_Sign__c;
        }
        return signingMandateMap.get(accountId);
    }
    
    private static Boolean isPrimaryApplicant(Applicant applicant) {
        return applicant.Role == 'Primary Applicant' || String.isEmpty(applicant.Role);
    }
    
    private static DTO_RESWrapper createSuccessResponse(DTO_REST_OnboardingManager result) {
        DTO_RESWrapper response = new DTO_RESWrapper();
        response.statusCode = 200;
        response.responseMessage = 'Success';
        response.result = result;
        return response;
    }
    
    private static DTO_RESWrapper createErrorResponse(String message, Integer statusCode) {
        DTO_RESWrapper response = new DTO_RESWrapper();
        response.statusCode = statusCode;
        response.responseMessage = message;
        return response;
    }

    @HttpPut
    global static void processRequest() {
        try {
            RestRequest request = RestContext.request;
            String requestBody = request.requestBody.toString();
            DTO_REST_OnboardingManager requestData = (DTO_REST_OnboardingManager)JSON.deserialize(
                requestBody, 
                DTO_REST_OnboardingManager.class
            );
            
            // Collect all account IDs and data maps
            DataMaps dataMaps = collectDataMaps(requestData);
            
            // Process updates
            processUpdates(dataMaps);
            
            // Send success response
            sendSuccessResponse();
        } catch (Exception e) {
            sendErrorResponse('Error processing request: ' + e.getMessage());
        }
    }
    
    private class DataMaps {
        Set<String> accountIds = new Set<String>();
        Map<String, String> emailMap = new Map<String, String>();
        Map<String, String> idNumberMap = new Map<String, String>();
        Map<String, DateInfo> dateInfoMap = new Map<String, DateInfo>();
        Map<String, AddressInfo> addressInfoMap = new Map<String, AddressInfo>();
    }
    
    private class DateInfo {
        Date expiryDate;
        Date validFrom;
        Date validTo;
    }
    
    private class AddressInfo {
        DTO_REST_OnboardingManager.DTO_Address primaryAddress;
        DTO_REST_OnboardingManager.DTO_Address additionalAddress1;
        DTO_REST_OnboardingManager.DTO_Address additionalAddress2;
    }
    
    private static DataMaps collectDataMaps(DTO_REST_OnboardingManager requestData) {
        DataMaps dataMaps = new DataMaps();
        map<string,string> datVal=new map<string,string>{
                        'accountId'=>requestData.SFAccountID,
                'email'=>requestData.EmailAddress,
                'idNumber'=>requestData.idNumber,
                'expiryDateStr'=>requestData.expiryDate,
                'validFromStr'=>requestData.validFrom,
                'validToStr'=>requestData.validTo
              
        };
        // Process primary account
        processAccountData(
datVal,
            requestData.PrimaryAddress,
            requestData.alternateCardDeliverAddress,
            requestData.additionalAddress2,
            dataMaps
        );
        
        // Process related parties
        if (requestData.RelatedParties != null) {
            for (DTO_REST_OnboardingManager.RelatedParties rp : requestData.RelatedParties) {
                map<string,string> dataMap=new map<string,string>{
                    'accountId'=>  rp.SFAccountID,
            'email'=>rp.EmailAddress,
            'idNumber'=>  rp.idNumber,
            'expiryDateStr'=>rp.expiryDate,
            'validFromStr'=>  rp.validFrom,
            'validToStr'=> rp.validTo
          
    };
                processAccountData(
                    dataMap,
                    rp.PrimaryAddress,
                    rp.alternateCardDeliverAddress,
                    rp.additionalAddress2,
                    dataMaps
                );
            }
        }
        
        return dataMaps;
    }
    
    private static void processAccountData(
        map<string,string> data,
        DTO_REST_OnboardingManager.DTO_Address primaryAddr,
        DTO_REST_OnboardingManager.DTO_Address addr1,
        DTO_REST_OnboardingManager.DTO_Address addr2,
        DataMaps dataMaps
    ) {

        if (String.isNotBlank(data.get('accountId'))) {
            dataMaps.accountIds.add(data.get('accountId'));
            dataMaps.emailMap.put(data.get('accountId'), data.get('email'));
            dataMaps.idNumberMap.put(data.get('accountId'), data.get('idNumber'));
            
            // Process dates
            DateInfo dateInfo = new DateInfo();
            dateInfo.expiryDate = String.isNotBlank(data.get('expiryDateStr')) ? Date.valueOf(data.get('expiryDateStr')) : null;
            dateInfo.validFrom = String.isNotBlank(data.get('validFromStr')) ? Date.valueOf(data.get('validFromStr')) : null;
            dateInfo.validTo = String.isNotBlank(data.get('validToStr')) ? Date.valueOf(data.get('validToStr')) : null;
            dataMaps.dateInfoMap.put(data.get('accountId'), dateInfo);
            
            // Process addresses
            AddressInfo addressInfo = new AddressInfo();
            addressInfo.primaryAddress = primaryAddr;
            addressInfo.additionalAddress1 = addr1;
            addressInfo.additionalAddress2 = addr2;
            dataMaps.addressInfoMap.put(data.get('accountId'), addressInfo);
        }
    }
    
    private static void processUpdates(DataMaps dataMaps) {
        List<PartyProfile> profilesToUpdate = new List<PartyProfile>();
        List<PartyProfileAddress> addressesToUpdate = new List<PartyProfileAddress>();
        List<Account> accountsToUpdate = new List<Account>();
        
        // Query and update Party Profiles
        processPartyProfileUpdates(dataMaps, profilesToUpdate, addressesToUpdate);
        
        // Query and update Accounts
        processAccountUpdates(dataMaps, accountsToUpdate);
        
        // Perform DML operations
        performUpdates(profilesToUpdate, addressesToUpdate, accountsToUpdate);
    }
    
    private static void processPartyProfileUpdates(
        DataMaps dataMaps,
        List<PartyProfile> profilesToUpdate,
        List<PartyProfileAddress> addressesToUpdate
    ) {
        for (PartyProfile profile : [
            SELECT Id, AccountId, PrimaryIdentificationName,PrimaryIdentifier,
                   WI_VisaPermitExpiryDate__c, WI_PassportValidFrom__c, WI_PassportValidTo__c,
                   (SELECT Id, Date_Move_In__c, Date_Move_Out__c, AddressType,
                           Address, Street, City, State, PostalCode, Country 
                    FROM PartyProfileAddresses 
                    WHERE AddressType = 'Residential Address'
                    ORDER BY Date_Move_In__c DESC)
            FROM PartyProfile 
            WHERE AccountId IN :dataMaps.accountIds
        ]) {
            updatePartyProfile(profile, dataMaps, profilesToUpdate, addressesToUpdate);
        }
    }
    
    private static void updatePartyProfile(
        PartyProfile profile,
        DataMaps dataMaps,
        List<PartyProfile> profilesToUpdate,
        List<PartyProfileAddress> addressesToUpdate
    ) {
        String accountId = profile.AccountId;
        DateInfo dateInfo = dataMaps.dateInfoMap.get(accountId);
        AddressInfo addressInfo = dataMaps.addressInfoMap.get(accountId);
        
        // Update profile fields
        profile.PrimaryIdentificationName = dataMaps.idNumberMap.get(accountId);
        if (dateInfo != null) {
            profile.WI_VisaPermitExpiryDate__c = dateInfo.expiryDate;
            profile.WI_PassportValidFrom__c = dateInfo.validFrom;
            profile.WI_PassportValidTo__c = dateInfo.validTo;
        }
        profilesToUpdate.add(profile);
        
        // Update addresses
        if (addressInfo != null && profile.PartyProfileAddresses != null) {
            updateAddresses(profile.PartyProfileAddresses, addressInfo, addressesToUpdate);
        }
    }
    
    private static void updateAddresses(
        List<PartyProfileAddress> existingAddresses,
        AddressInfo addressInfo,
        List<PartyProfileAddress> addressesToUpdate
    ) {
        Integer addressCount = 0;
        for (PartyProfileAddress addr : existingAddresses) {
            if (addressCount == 0 && addressInfo.primaryAddress != null) {
                updateAddress(addr, addressInfo.primaryAddress);
                addressesToUpdate.add(addr);
            } else if (addressCount == 1 && addressInfo.additionalAddress1 != null) {
                updateAddress(addr, addressInfo.additionalAddress1);
                addressesToUpdate.add(addr);
            } else if (addressCount == 2 && addressInfo.additionalAddress2 != null) {
                updateAddress(addr, addressInfo.additionalAddress2);
                addressesToUpdate.add(addr);
            }
            addressCount++;
        }
    }
    
    private static void updateAddress(
        PartyProfileAddress existingAddr,
        DTO_REST_OnboardingManager.DTO_Address newAddr
    ) {
        existingAddr.Street = newAddr.street;
        existingAddr.City = newAddr.city;
        existingAddr.State = newAddr.state;
        existingAddr.PostalCode = newAddr.postalcode;
        existingAddr.Country = newAddr.country;
    }
    
    private static void processAccountUpdates(DataMaps dataMaps, List<Account> accountsToUpdate) {
        for (Account acc : [SELECT Id, PersonEmail FROM Account WHERE Id IN :dataMaps.accountIds]) {
            acc.PersonEmail = dataMaps.emailMap.get(acc.Id);
            accountsToUpdate.add(acc);
        }
    }
    
    private static void performUpdates(
        List<PartyProfile> profilesToUpdate,
        List<PartyProfileAddress> addressesToUpdate,
        List<Account> accountsToUpdate
    ) {
        if (!profilesToUpdate.isEmpty()) {
            update profilesToUpdate;
        }
        if (!addressesToUpdate.isEmpty()) {
            update addressesToUpdate;
        }
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }
    }
    
    private static void sendSuccessResponse() {
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf('Customer Data Updated Successfully');
        res.statusCode = 200;
        res.addHeader('Content-Type', 'application/json');
    }
    
    private static void sendErrorResponse(String errorMessage) {
        RestResponse res = RestContext.response;
        res.responseBody = Blob.valueOf(errorMessage);
        res.statusCode = 500;
        res.addHeader('Content-Type', 'application/json');
    }
    
    global class DTO_RESWrapper {
        public Integer statusCode;
        public String responseMessage;
        public DTO_REST_OnboardingManager result;
    }
}