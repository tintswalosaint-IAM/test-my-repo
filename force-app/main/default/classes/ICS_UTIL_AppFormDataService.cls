/**
* @description Utility class for getting opportunity data and all other records grouped by application
* @author Melnyk Oleg
* @date March 2023
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 18-06-2025
 * @Modification description : SFP-50276
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 03-07-2025
 * @Modification description : SFP-49403
 ***************************************************************************************
*/

public without sharing class ICS_UTIL_AppFormDataService {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_UTIL_AppFormDataService');
    
    ICS_UTIL_AppFormDataProvider dataProvider;
    public ICS_UTIL_AppFormDataService(Id recordId) {
        dataProvider = new ICS_UTIL_AppFormDataProvider(recordId);
    }
    
/**
* @description Method to get opportunity record and all other related records grouped by application
* @return Map<String, Object>
*/
    public Map<String, Object> getOpportunity() {
        return new Map<String, Object> {
            'opportunity' => dataProvider.opportunityRecord,
                'applications' => getApplications(),
                'countryValueMap' => ICS_UTIL_AppFormDataProvider.getCountryValueMap()
                };
    }
 
/**
* @description Method to get Application record
* @return List<Map<String, Object>>
*/
    public List<Map<String, Object>> getApplications() {
        List<Map<String, Object>> result = new List<Map<String, Object>>();
        List<Id>applicationIdSet =new List<Id>();
            applicationIdSet.addall(dataProvider.applicationRecords.keySet());
            Map<String, Object> applicantData = getApplicantData(applicationIdSet[0]);
        
            if(applicantData != null) {
                result.add(applicantData);
              
                
            }
        
        
        LOGGER.info('getApplications result size: ' + result.size());
        return result;
    }
    
/**
* @description Method is used to build up a map of application data and related records data
* @param applicationId Application record Id
* @return Map<String, Object> Application data and related records data
*/
 
    public  Map<String, Object> getApplicantData(Id applicationId) {
        ApplicationForm application = dataProvider.applicationRecords.get(applicationId);
        
        if (application == null) {
            LOGGER.info('Failed to get applicant data');
            return null;
        }
        
        Id accountId = application.AccountId;
        sel_PartyProfile pselectorData = new Sel_PartyProfile();
        SEL_PartyAssetFunds pselectorFunds = new SEL_PartyAssetFunds();

        PartyProfile profileInfo = pselectorData.selectByAccountAndRecordType(accountId,'ICS_PartyProfile');
        Id partyId = profileInfo.Id;
        List<Party_Assets_Funds__c> partyAssetFunds =pselectorFunds.selectByPartyProfileIds(new set<Id>{partyId});
        Map<String,Object> responsed = new Map<String, Object> {
            'applicant' => application,
                'account' => dataProvider.accountRecords.get(accountId),
                'address' => getAddressData(accountId),
                'employment' => getEmploymentData(accountId),
               
                'additionalBusinessOwner' => getAdditionalBusinessOwners(accountId),
                'partyProfileAddressRecords' => getPartyAddressData(partyId),
                'partyBankdatails' =>getPartyBankDetails(partyId),                
                'assetBasedPartyProfileDetails'=>getAssetBasedPartyProfile(accountId),
                'accountBasedtaxDetails'=>getTaxDetailsBasedOnAccount(accountId),
                'partyAssetFundRecordsForSource'=> getPartyAssetFundsForSource(partyId),
                'trustInfo'=>getTrustSectionInfo(partyId),
                'businessInfo'=>getBusinessSection(partyId),
                'businessOwnershipWithProfilesFalse' => getBusinessOwnershipWithProfiles(partyId, false), 
                'businessOwnershipWithProfilesTrue' => getBusinessOwnershipWithProfiles(partyId, true),    
                'partyAssetFundRecordsForWealth'=>getPartyAssetFundsForWealth(partyId),
                'partyAssetFundRecordsForInitialDeposit'=>getPartyAssetFundForInitialDeposit(partyId),
                'partyAssetFundRecords'=>getPartyAssetFundsForAddtionalAccount(partyId),
                'partyAssetFundForFutureDeposit'=> getPartyAssetFundForFutureDeposit(partyId), 
                'assessmentResponseForFutureDeposit'=>getAssessmentResponsesFutureDeposit(partyId,accountId),
                'getAssessmentResponseAssetIncome'=>getAssessmentResponsesAssetIncome(partyId,accountId),
                'getAssessmentResponsesAssetIncomeNew'=>getAssessmentResponsesAssetIncomeNew(partyId,accountId),
                'getAssessmentResponseAccountPurpose'=>getAssessmentResponsesDetails(accountId,'Account Purpose'),
                'partyAssetFunds' => partyAssetFunds,
                'getAssessmentResponseCurrentEmpDtl'=> getAssessmentResponsesDetails(accountId,'Current Employment Details'),
                'getAssessmentResponsePreviousEmpDtl'=> getAssessmentResponsesDetails(accountId,'Previous Employment Details'),
                'getAssessmentResponseBankAccount' =>  getAssessmentResponsesDetails(accountId,'Bank Account'),
                'getAssessmentResponseTrust' =>  getAssessmentResponsesDetails(accountId,'Trust'),
                'getAssessmentResponseAdditionRelation' => getAssessmentResponsesDetails(accountId,'Additional Relationships'),
                'getAssessmentResponseInitialDeposit' => getAssessmentResponsesDetails(accountId,'Your Initial Deposit'),
                'getAssessmentResponseFutureDeposit' => getAssessmentResponsesDetails(accountId,'Future Deposits'),
                'assessmentResponseCertificateInterest'=> getAssessmentResponsesDetails(accountId,'Certificate of Interest'),
                'assessmentResponseSecurityDetail'=> getAssessmentResponsesDetails(accountId,'Security Details'),
                 'assessmentResponseBusinessOwnerDetail'=> getAssessmentResponsesDetails(accountId,'Business Ownership'),
                 'assessmentResponseContactDetail'=> getAssessmentResponsesDetails(accountId,'Contact Details'),
                'assessmentResponseOperationAccount'=> getAssessmentResponsesDetails(accountId,'Operation of Your Account'),
                 'assessmentResponseTaxCertificate'=> getAssessmentResponsesDetails(accountId,'Tax Certificates')


                
                };
               return responsed;
    }
    
    public List<trustWrapper> getTrustSectionInfo(Id partyId) {
        List<Party_Assets_Funds__c> trustList = getTrustRecords(partyId);
        
        
        Map<Id, List<PartyProfile>> profileMap = new Map<Id, List<PartyProfile>>();
        Map<Id, List<Party_Assets_Funds__c>> benefitMap = new Map<Id, List<Party_Assets_Funds__c>>();
      
        
        // Get all profile records for each trust record
        for(Party_Assets_Funds__c fund : trustList) {
            profileMap.put(fund.Id, getProfileRecords(partyId, fund.Id)); 
            benefitMap.put(fund.Id, getBenefitRecords(fund.Id)); 
        }
       
        
        // Create wrappers using maps
        List<trustWrapper> wrapperList = new List<trustWrapper>();
        for(Party_Assets_Funds__c fund : trustList) {
            trustWrapper wrapper = new trustWrapper();
            wrapper.trustInfo = fund;
            wrapper.pepList = profileMap.get(fund.Id);
            wrapper.benifitList = benefitMap.get(fund.Id);
            wrapperList.add(wrapper);
        }
        
        return wrapperList;
    }

    public List<businessWrapper> getBusinessSection(Id partyId) {
        List<Party_Assets_Funds__c> businessListrecords = getbusinessRecords(partyId);
        List<PartyProfile> allProfiles = getProfileRecordsBusiness(partyId);
        List<businessWrapper> wrapperList = new List<businessWrapper>();
        if (!businessListrecords.isEmpty()) {
            Party_Assets_Funds__c businessRecord = businessListrecords[0]; 
            
            for(PartyProfile profile : allProfiles) {  
                businessWrapper wrapper = new businessWrapper();
                wrapper.businessInfo = businessRecord; 
                wrapper.businessList = profile;         
                wrapperList.add(wrapper);
            }
        }
        return wrapperList;
    }
/**
* @description Get business ownership records using existing pattern
* @param partyProfileId The party profile ID
* @param isFutureFund Whether to get future fund records (true) or current records (false)
* @return List of business ownership records
*/
    private List<Party_Assets_Funds__c> getBusinessOwnershipRecords(Id partyProfileId, Boolean isFutureFund) {
        Id sourceFundRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Source_of_Funds');
        List<Party_Assets_Funds__c> businessRecords = new List<Party_Assets_Funds__c>();
        
        for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
            if (asset != null && 
                asset.Party_Profile__c == partyProfileId && 
                asset.recordTypeId == sourceFundRecordTypeId && 
                asset.Is_Future_Fund__c == isFutureFund && 
                asset.Type__c == 'Ownership/shares in business') {
                businessRecords.add(asset);
            }
        }
        
        return businessRecords;
    }

    /**
    * @description Get business wrappers with related profiles using selector
    * @param partyProfileId The party profile ID
    * @param isFutureFund Whether to get future fund records (true) or current records (false)
    * @return List of business wrappers
    */
    public List<businessWrapper> getBusinessOwnershipWithProfiles(Id partyProfileId, Boolean isFutureFund) {
        List<businessWrapper> wrapperList = new List<businessWrapper>();
        
        // Get business records
        List<Party_Assets_Funds__c> businessRecords = getBusinessOwnershipRecords(partyProfileId, isFutureFund);
        
        if (businessRecords.isEmpty()) {
            return wrapperList;
        }
        
        // Use selector to get related profiles
        SEL_PartyProfile profileSelector = new SEL_PartyProfile();
        
        // Create wrappers
        for (Party_Assets_Funds__c businessRecord : businessRecords) {
            List<PartyProfile> relatedProfiles = profileSelector.selectByPartyAssetFund(businessRecord.Id);
            
            for (PartyProfile profile : relatedProfiles) {
                businessWrapper wrapper = new businessWrapper();
                wrapper.businessInfo = businessRecord;
                wrapper.businessList = profile;
                wrapperList.add(wrapper);
            }
        }
        
        return wrapperList;
    }


   private static List<Party_Assets_Funds__c> getTrustRecords(Id profileId) {
    return [SELECT Id, Name, Deed_Number__c, Related_To_PEP_Through_Trust__c, Is_Trust_Beneficiary__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type__c, Type_of_Benefit__c, Rationale_for_Trust__c,
            Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
            Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
            FROM Party_Assets_Funds__c
            WHERE Type__c='Trust' AND Party_Profile__c = :profileId ];
}
private static List<Party_Assets_Funds__c> getbusinessRecords(Id profileId) {
    return [SELECT Id, Name, Deed_Number__c, Related_To_PEP_Through_Trust__c, Is_Trust_Beneficiary__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type__c, Type_of_Benefit__c, Rationale_for_Trust__c,
            Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
            Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
            FROM Party_Assets_Funds__c
            WHERE Type__c = 'Ownership/shares in business' AND RecordType.Name='Wealth in Country' AND Party_Profile__c = :profileId ];
}


private static List<PartyProfile> getProfileRecords(Id profileDataId, Id trustRecordId) {
    return [SELECT Id, Name, Person_Title__c, FirstName, LastName, MiddleName, Gender, DateOfBirth, WI_MaritialStatus__c,
            CountryofBirth, Town_City_of_Birth__c, Country_of_Residence__c, Country_of_Nationality__c,
            Second_Country_of_Nationality__c, Different_First_Name__c, Different_Middle_Name__c, Different_Last_Name__c,
            Maiden_Name__c, Former_Name__c, PrimaryIdentifierType, PrimaryIdentifier, Has_Former_Name__c,
            Has_Maiden_Name__c, Has_different_First_Middle_Family_Name__c
            FROM PartyProfile
            WHERE RelatedPartyProfileId = :profileDataId AND name='PEP' AND Party_Assets_Funds__c = :trustRecordId];
}
private static List<PartyProfile> getProfileRecordsBusiness(Id profileDataId) {
    return [SELECT Id, Name, Person_Title__c, FirstName, LastName, MiddleName, Gender, DateOfBirth, WI_MaritialStatus__c,
            CountryofBirth, Town_City_of_Birth__c, Country_of_Residence__c, Country_of_Nationality__c,
            Second_Country_of_Nationality__c, Different_First_Name__c, Different_Middle_Name__c, Different_Last_Name__c,
            Maiden_Name__c, Former_Name__c, PrimaryIdentifierType, PrimaryIdentifier, Has_Former_Name__c,
            Has_Maiden_Name__c, Has_different_First_Middle_Family_Name__c,Percentage_of_Business__c,Birthdate__c
            FROM PartyProfile
            WHERE RelatedPartyProfileId = :profileDataId AND RecordType.Name='ICS Additional Business Owner'];
}

private static List<Party_Assets_Funds__c> getBenefitRecords(Id trustRecordId) {
    return [SELECT Id, Name, type__c, Deed_Number__c,Is_Trust_Beneficiary__c, Related_To_PEP_Through_Trust__c, Beneficiary_Of_Trust__c, Annual_Monetary_Value__c, Type_of_Benefit__c, Rationale_for_Trust__c,
            Trust_Name__c, Frequency_of_Trust_Benefit__c, TrustDeed_or_Letter_of_wishes__c, Description__c, Locations__c,
            Settlor_Name__c, Wealth_Source_and_Timeline__c, Wealth_Details_Inclusive_of_Amount__c, Date_Funds_Received__c
            FROM Party_Assets_Funds__c
            WHERE Trust__c = :trustRecordId AND Type__c = 'Benefit from a trust'];
}

   Public class trustWrapper{
    Public Party_Assets_Funds__c trustInfo{get;set;}
    Public List<PartyProfile> pepList{get;set;}
    Public List<Party_Assets_Funds__c> benifitList{get;set;}
    Public List<PartyProfile> businessList{get;set;}
   }
   Public class businessWrapper{
    Public Party_Assets_Funds__c businessInfo{get;set;}
    Public PartyProfile businessList{get;set;}
   }
/**
* @description Method is used to filter and group address data by types
* @param accountId Account record Id
* @return Grouped address data related to the account
*/
    public List<Party_Assets_Funds__c> getPartyBankDetails(Id PartyId) {         
        return  dataProvider.fetchPartyAssetsAdditionAccount(PartyId);        
    }
    
    /**
* @description Method to filter and group address data by their types for a given account
* @param accountId The ID of the account whose address data needs to be filtered and grouped
* @return A map containing lists of ContactPointAddress objects, grouped by address type
*/
    public Map<String, List<ContactPointAddress>> getAddressData(Id accountId) {
        Map<String, String> types = new Map<String, String> {
            'Current Residential' => 'current',
                'Previous Residential' => 'previous',
                'Correspondence' => 'correspondence'
                };
                    Map<String, List<ContactPointAddress>> result = new Map<String, List<ContactPointAddress>> {
                        'current' => new List<ContactPointAddress>(),
                            'previous' => new List<ContactPointAddress>(),
                            'correspondence' => new List<ContactPointAddress>()
                            };
                                
                                for (ContactPointAddress address : dataProvider.addressRecords) {
                                    if (address != null && address.ParentId == accountId) {
                                        String key = types.get(address.AddressType);
                                        List<ContactPointAddress> element = result.get(key);
                                        if (element != null) {
                                            element.add(address);
                                        }
                                    }
                                }
        return result;
    }
    
    /**
* @description Method to filter and group party profile address data by their types for a given partyProfile
* @param partyId The ID of the partyprofile whose address data needs to be filtered and grouped
* @return A map containing lists of PartyProfileAddress objects, grouped by address type
*/
    Public Map<String, List<PartyProfileAddress>> getPartyAddressData(Id PartyId) {
        Map<String, List<PartyProfileAddress>> result = new Map<String, List<PartyProfileAddress>> ();

        result.put('correspondence',new List<PartyProfileAddress>());
        result.put('Previous',new List<PartyProfileAddress>());
        result.put('Alternative', new List<PartyProfileAddress>());
                                for (PartyProfileAddress paddress : dataProvider.partyProfileAddressRecords) {
                                    if (pAddress.Date_Move_Out__c == null &&  pAddress.AddressType =='Residential Address') {
                                        if(!result.containskey('Residential')){
                                            result.put('Residential',new List<PartyProfileAddress>{pAddress});
                                        }else{
                                            result.get('Residential').add(pAddress); 
                                        }
                                    }
                                    if (pAddress.Date_Move_Out__c != null &&  pAddress.AddressType =='Residential Address') {
                                        if(!result.containskey('Previous')){
                                            result.put('Previous',new List<PartyProfileAddress>{pAddress});
                                        }else{
                                            result.get('Previous').add(pAddress); 
                                        }
                                    }
                                    if (pAddress.AddressType =='Correspondence Address') {
                                        if(!result.containskey('correspondence')){
                                            result.put('correspondence',new List<PartyProfileAddress>{pAddress});
                                        }else{
                                            result.get('correspondence').add(pAddress); 
                                        }
                                    }
                                     if (pAddress.AddressType == 'Other') {
                                        if(!result.containskey('Alternative')){
                                            result.put('Alternative', new List<PartyProfileAddress>{pAddress});
                                        } else {
                                            result.get('Alternative').add(pAddress); 
                                        }
                                    }
                                    
                                }
                               
        return result;
    }
    
/**
* @description Method is used to filter and group employment data by types
* @param accountId Account record Id
* @return Grouped employment data related to the account
*/
    public Map<String, List<FinServ__Employment__c>> getEmploymentData(Id accountId) {
        List<FinServ__Employment__c> current = new List<FinServ__Employment__c>();
        List<FinServ__Employment__c> dual = new List<FinServ__Employment__c>();
        List<FinServ__Employment__c> previous = new List<FinServ__Employment__c>();
        
        Id currentRecordTypeId = dataProvider.recordTypes.get('FinServ__Employment__c_Current');
        Id previousRecordTypeId = dataProvider.recordTypes.get('FinServ__Employment__c_Previous');
        
        for (FinServ__Employment__c employment : dataProvider.employmentRecords) {
            if (employment != null && employment.Person_Account__c == accountId) {
                if (employment.RecordTypeId == currentRecordTypeId) {
                    if (employment.Only_employment__c == 'Yes') {  
                        current.add(employment);
                    }
                    else if (employment.Only_employment__c == 'No') {
                        dual.add(employment);
                    }
                } 
                else if (employment.RecordTypeId == previousRecordTypeId) {
                    previous.add(employment);
                }
            }
        }
        
        Map<String, List<FinServ__Employment__c>> result = new Map<String, List<FinServ__Employment__c>>{
            'current' => current,
                'dual' => dual,
                'previous' => previous
                };
                    return result;
    }
    
/**
* @description Method is used to filter and group assets and income data by types
* @param applicationId Application record Id
* @return Grouped assets and income data related to the application
*/
   
/**
* @description Method is used to filter additional business owners data
* @param accountId Account record Id
* @return List of additional business owners related to the account
*/
    public List<PartyProfile> getAdditionalBusinessOwners(Id accountId) {
        List<PartyProfile> result = new List<PartyProfile>();
        Id additionalBusinessOwnerRecordType = dataProvider.recordTypes.get('PartyProfile_ICS_Additional_Business_Owner');
        for (PartyProfile record : dataProvider.partyProfileRecords) {
            if (record.AccountId == accountId &&
                record.RecordTypeId == additionalBusinessOwnerRecordType) {
                    result.add(record);
                }
        }
        return result;
    }
    
/**
* @description Method is used to filter partyProfile data of related assets
* @param accountId Account record Id
* @return List of partyprofile related to the account
*/
    public List<PartyProfile> getAssetBasedPartyProfile(Id accountId) {
        List<PartyProfile> result = new List<PartyProfile>();
        for (PartyProfile record : dataProvider.partyProfileRecords) {
            if (record.AccountId == accountId ) {
                result.add(record);
            }
        }
        return result;
    }
    
    /**
* @description Method is used to filter partyProfile data of related assets
* @param accountId Account record Id
* @return List of partyprofile related to the account
*/
    public Map<String, List<TaxDetails__c>> getTaxDetailsBasedOnAccount(Id accountId) {
        Map<String, List<TaxDetails__c>> taxDetailsMap = new Map<String, List<TaxDetails__c>>();
        
        // Use existing selector to get main profile
        sel_PartyProfile pselectorData = new Sel_PartyProfile();
        PartyProfile mainProfile = pselectorData.selectByAccountAndRecordType(accountId, 'ICS_PartyProfile');
        
        String mainCountry = (mainProfile != null) ? mainProfile.Country_of_Residence__c : null;
        
        // Fetch tax details
        List<TaxDetails__c> fetchDetails = [
            SELECT Id, TIN_IN_Number__c, Country__c,Name,
                Jurisdiction_of_Tax_Residence__c, TaxType__c, 
                TaxNumber__c, Account__c, TaxExemptReason__c,
                Reason_for_No_TIN__c
            FROM TaxDetails__c 
            WHERE Account__c = :accountId
        ];

        // Initialize result lists
        taxDetailsMap.put('mainTaxResidency', new List<TaxDetails__c>());
        taxDetailsMap.put('usTaxDetails', new List<TaxDetails__c>());
        taxDetailsMap.put('otherCountries', new List<TaxDetails__c>());

        // Categorize tax details
        for (TaxDetails__c record : fetchDetails) {
            if (record.Country__c == 'US') {
                taxDetailsMap.get('usTaxDetails').add(record);
            } else if (record.Country__c == mainCountry || record.Name=='Main Tax Details') {
                taxDetailsMap.get('mainTaxResidency').add(record);
            } else {
                taxDetailsMap.get('otherCountries').add(record);
            }
        }

        return taxDetailsMap;
    }
    public static List<String> getProcessCurrency(String input) {
            List<String> result = new List<String>();
            
            // Splitting input string into parts based on semicolon
            List<String> parts = input.split(';');
            
            for (String part : parts) {
                List<String> subParts = part.split(',');
                
                if (subParts.size() == 2) {
                    String leftPart = subParts[0].trim();   // First part
                    String rightPart = subParts[1].trim();  // Second part
                    
                    result.add(leftPart);
                    result.add(rightPart);
                }
            }
            
            return result; // Return the result list
        }
/**
* @description Method is used to filter and group party asset funds data by types whenever is future fund=false
* @param partyProfileId partyprofile record Id
* @return Grouped party asset fund data related to the partyprofile
*/ 
    public Map<String, List<Party_Assets_Funds__c>> getPartyAssetFundsForWealth(Id partyProfileId) {
        Id wealthCountryRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Wealth_in_Country');   
        Map<String, List<Party_Assets_Funds__c>> assetMap = new Map<String, List<Party_Assets_Funds__c>>{
            'Bank Account' => new List<Party_Assets_Funds__c>(),
                'Compensation Payment' => new List<Party_Assets_Funds__c>(),
                'Gift' => new List<Party_Assets_Funds__c>(),
                'Investment/Stock' => new List<Party_Assets_Funds__c>(),
                'Inheritance' => new List<Party_Assets_Funds__c>(),
                'Lottery/ Betting Winnings' => new List<Party_Assets_Funds__c>(),
                'Loan' => new List<Party_Assets_Funds__c>(),
                'Maturity of insurance policy or fixed term investment' => new List<Party_Assets_Funds__c>(),
                'Owned Property' => new List<Party_Assets_Funds__c>(),
                'Ownership/shares in business' => new List<Party_Assets_Funds__c>(),
                'Pension/Retirement' => new List<Party_Assets_Funds__c>(),
                'Salary/Bonus' => new List<Party_Assets_Funds__c>(),
                'Sale of Business' => new List<Party_Assets_Funds__c>(),
                'Sale of Property' => new List<Party_Assets_Funds__c>(),
                'Sale of Investment' => new List<Party_Assets_Funds__c>(),
                'Other' => new List<Party_Assets_Funds__c>()
                };
                for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
                   if (asset != null && asset.Party_Profile__c == partyProfileId && 
                       asset.recordTypeId == wealthCountryRecordTypeId && asset.Is_Future_Fund__c==false) {
                       if(asset.Wealth_Details_Inclusive_of_Amount__c!=null){

                       }
                       if (assetMap.containsKey(asset.Type__c)) {
                        assetMap.get(asset.Type__c).add(asset);
                    }
                  }
                }

               
        
        // Prepare the final result map with custom keys
        Map<String, List<Party_Assets_Funds__c>> result = new Map<String, List<Party_Assets_Funds__c>>();
        result.put('businessOwnershipDetailsWealthTypeFalse', assetMap.get('Ownership/shares in business'));
        result.put('otherDetailsWealthTypeFalse', assetMap.get('Other'));
        result.put('saleofPropertyDetailsWealthTypeFalse', assetMap.get('Sale of Property'));
        result.put('saleOfInvestmentDetailsWealthTypeFalse', assetMap.get('Sale of Investment'));
        result.put('salesOfBusinessDetailsWealthTypeFalse', assetMap.get('Sale of Business'));
        result.put('salaryBonusDetailsWealthTypeFalse', assetMap.get('Salary/Bonus'));
        result.put('pensionRetireDetailsWealthTypeFalse', assetMap.get('Pension/Retirement'));
        result.put('ownerPropertyDetailsWealthTypeFalse', assetMap.get('Owned Property'));
        result.put('maturedInsuranceDetailsWealthTypeFalse', assetMap.get('Maturity of insurance policy or fixed term investment'));
        result.put('lotteryDetailsWealthTypeFalse', assetMap.get('Lottery/ Betting Winnings'));
        result.put('loanDetailsWealthTypeFalse', assetMap.get('Loan'));
        result.put('investmentStockDetailsWealthTypeFalse', assetMap.get('Investment/Stock'));
        result.put('inheritanceDetailsWealthTypeFalse', assetMap.get('Inheritance'));
        result.put('giftDetailsWealthTypeFalse', assetMap.get('Gift'));
        result.put('compensationDetailsWealthTypeFalse', assetMap.get('Compensation Payment'));
        result.put('bankAccountDetailsWealthTypeFalse', assetMap.get('Bank Account'));
        return result;
    }
    
    
    /**
    * @description Method is used to filter and group party asset funds data by types whenever is future fund=false
    * @param partyProfileId partyprofile record Id
    * @return Grouped party asset fund data related to the partyprofile
    */
    public Map<String, List<Party_Assets_Funds__c>> getPartyAssetFundsForAddtionalAccount(Id partyProfileId) {
        Id additionAccountRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Additional_Accounts');
    
        Map<String, List<Party_Assets_Funds__c>> assetMap = new Map<String, List<Party_Assets_Funds__c>>{
            'Bank Account' => new List<Party_Assets_Funds__c>(),
                'Compensation Payment' => new List<Party_Assets_Funds__c>(),
                'Gift' => new List<Party_Assets_Funds__c>(),
                'Investment/Stock' => new List<Party_Assets_Funds__c>(),
                'Inheritance' => new List<Party_Assets_Funds__c>(),
                'Lottery/ Betting Winnings' => new List<Party_Assets_Funds__c>(),
                'Loan' => new List<Party_Assets_Funds__c>(),
                'Maturity of insurance policy or fixed term investment' => new List<Party_Assets_Funds__c>(),
                'Owned Property' => new List<Party_Assets_Funds__c>(),
                'Ownership/shares in business' => new List<Party_Assets_Funds__c>(),
                'Pension/Retirement' => new List<Party_Assets_Funds__c>(),
                'Salary/Bonus' => new List<Party_Assets_Funds__c>(),
                'Sale of Business' => new List<Party_Assets_Funds__c>(),
                'Sale of Property' => new List<Party_Assets_Funds__c>(),
                'Sale of Investment' => new List<Party_Assets_Funds__c>(),
                'Other' => new List<Party_Assets_Funds__c>(),
                'Other Business Interests'=> new List<Party_Assets_Funds__c>()
                };
                List<Party_Assets_Funds__c> mainAccounts = new List<Party_Assets_Funds__c>();
                List<Party_Assets_Funds__c> additionalAccounts = new List<Party_Assets_Funds__c>();
                List<Party_Assets_Funds__c> otherBusinessInterests = new List<Party_Assets_Funds__c>();

                for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
                    if (asset != null && 
                        asset.Party_Profile__c == partyProfileId && 
                        asset.recordTypeId == additionAccountRecordTypeId && 
                        asset.Is_Future_Fund__c == false &&
                        asset.Type__c == 'Bank Account') {
                        
                        if(asset.Main_Account__c == true) {
                            mainAccounts.add(asset);
                        } else if(asset.Main_Account__c == false && asset.Bank_Name__c !=null) {
                            additionalAccounts.add(asset);
                        }
                    }
                    if(asset.Type__c=='Other Business Interests')
                    {
                        otherBusinessInterests.add(asset);
                    }
                }
                additionalAccounts.sort();

        Map<String, List<Party_Assets_Funds__c>> result = new Map<String, List<Party_Assets_Funds__c>>();
        result.put('businessOwnerShipDetails', assetMap.get('Ownership/shares in business'));
        result.put('otherBusinessInterestDetails', otherBusinessInterests);
        result.put('saleofPropertyDetailsAdditionAccTypeFalse', assetMap.get('Sale of Property'));
        result.put('saleOfInvestmentDetailsAdditionAccTypeFalse', assetMap.get('Sale of Investment'));
        result.put('salesOfBusinessDetailsAdditionAccTypeFalse', assetMap.get('Sale of Business'));
        result.put('salaryBonusDetailsAdditionAccTypeFalse', assetMap.get('Salary/Bonus'));
        result.put('pensionRetireDetailsAdditionAccTypeFalse', assetMap.get('Pension/Retirement'));
        result.put('ownerPropertyDetailsAdditionAccTypeFalse', assetMap.get('Owned Property'));
        result.put('maturedInsuranceDetailsAdditionAccTypeFalse', assetMap.get('Maturity of insurance policy or fixed term investment'));
        result.put('lotteryDetailsAdditionAccTypeFalse', assetMap.get('Lottery/ Betting Winnings'));
        result.put('loanDetailsAdditionAccTypeFalse', assetMap.get('Loan'));
        result.put('investmentStockDetailsAdditionAccTypeFalse', assetMap.get('Investment/Stock'));
        result.put('inheritanceDetailsAdditionAccTypeFalse', assetMap.get('Inheritance'));
        result.put('giftDetailsAdditionAccTypeFalse', assetMap.get('Gift'));
        result.put('compensationDetailsAdditionAccTypeFalse', assetMap.get('Compensation Payment'));
        result.put('bankAccountDetails', mainAccounts);
        result.put('bankAccountDetailsAdditionAccTypeFalse', additionalAccounts);
        
        return result;
    }
    
    /**
* @description Method is used to filter and group party asset funds data by types whenever is future fund=false
* @param partyProfileId partyprofile record Id
* @return Grouped party asset fund data related to the partyprofile
*/
    
    
    public Map<String, List<Party_Assets_Funds__c>> getPartyAssetFundsForSource(Id partyProfileId) {
        Id sourceFundRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Source_of_Funds');
        
        // Initialize a map to hold the type-specific lists
        Map<String, List<Party_Assets_Funds__c>> assetMap = new Map<String, List<Party_Assets_Funds__c>>{
            'Bank Account' => new List<Party_Assets_Funds__c>(),
                'Compensation Payment' => new List<Party_Assets_Funds__c>(),
                'Gift' => new List<Party_Assets_Funds__c>(),
                'Investment/Stock' => new List<Party_Assets_Funds__c>(),
                'Inheritance' => new List<Party_Assets_Funds__c>(),
                'Lottery/ Betting Winnings' => new List<Party_Assets_Funds__c>(),
                'Loan' => new List<Party_Assets_Funds__c>(),
                'Maturity of insurance policy or fixed term investment' => new List<Party_Assets_Funds__c>(),
                'Owned Property' => new List<Party_Assets_Funds__c>(),
                'Ownership/shares in business' => new List<Party_Assets_Funds__c>(),
                'Pension/Retirement' => new List<Party_Assets_Funds__c>(),
                'Salary/Bonus' => new List<Party_Assets_Funds__c>(),
                'Sale of Business' => new List<Party_Assets_Funds__c>(),
                'Sale of Property' => new List<Party_Assets_Funds__c>(),
                'Sale of Investment' => new List<Party_Assets_Funds__c>(),
                'Other' => new List<Party_Assets_Funds__c>(),
                'Trust' => new List<Party_Assets_Funds__c>()
                };
                    
                    // Iterate over the assets and add to the appropriate list in the map
                    for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
                        if (asset != null && asset.Party_Profile__c == partyProfileId && asset.recordTypeId == sourceFundRecordTypeId &&
                            asset.Is_Future_Fund__c==false) {
                                if (assetMap.containsKey(asset.Type__c)) {
                                    assetMap.get(asset.Type__c).add(asset);
                                }
                            }
                    }
        
        // Prepare the final result map with custom keys
        Map<String, List<Party_Assets_Funds__c>> result = new Map<String, List<Party_Assets_Funds__c>>();
        result.put('businessOwnershipDetailsSourceTypeFalse', assetMap.get('Ownership/shares in business'));
        result.put('otherDetailsSourceTypeFalse', assetMap.get('Other'));
        result.put('saleofPropertyDetailsSourceTypeFalse', assetMap.get('Sale of Property'));
        result.put('saleOfInvestmentDetailsSourceTypeFalse', assetMap.get('Sale of Investment'));
        result.put('salesOfBusinessDetailsSourceTypeFalse', assetMap.get('Sale of Business'));
        result.put('salaryBonusDetailsSourceTypeFalse', assetMap.get('Salary/Bonus'));
        result.put('pensionRetireDetailsSourceTypeFalse', assetMap.get('Pension/Retirement'));
        result.put('ownerPropertyDetailsSourceTypeFalse', assetMap.get('Owned Property'));
        result.put('maturedInsuranceDetailsSourceTypeFalse', assetMap.get('Maturity of insurance policy or fixed term investment'));
        result.put('lotteryDetailsSourceTypeFalse', assetMap.get('Lottery/ Betting Winnings'));
        result.put('loanDetailsSourceTypeFalse', assetMap.get('Loan'));
        result.put('investmentStockDetailsSourceTypeFalse', assetMap.get('Investment/Stock'));
        result.put('inheritanceDetailsSourceTypeFalse', assetMap.get('Inheritance'));
        result.put('giftDetailsSourceTypeFalse', assetMap.get('Gift'));
        result.put('compensationDetailsSourceTypeFalse', assetMap.get('Compensation Payment'));
        result.put('bankAccountDetailsSourceTypeFalse', assetMap.get('Bank Account'));
        result.put('trustDetailsSourceTypeFalse',assetMap.get('Trust'));
        return result;
    }
    
    
    
    
    
    /**
* @description Method is used to filter and group party asset funds data by types whenever is future fund=true
* @param partyProfileId partyprofile record Id
* @return Grouped party asset fund data related to the partyprofile
*/
    
    
    public Map<String, List<Party_Assets_Funds__c>> getPartyAssetFundForFutureDeposit(Id partyProfileId) {
        Id sourceFundRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Source_of_Funds');
        
        // Initialize a map to hold the type-specific lists
        Map<String, List<Party_Assets_Funds__c>> assetMap = new Map<String, List<Party_Assets_Funds__c>>{
            'Bank Account' => new List<Party_Assets_Funds__c>(),
                'Compensation Payment' => new List<Party_Assets_Funds__c>(),
                'Gift' => new List<Party_Assets_Funds__c>(),
                'Investment/Stock' => new List<Party_Assets_Funds__c>(),
                'Inheritance' => new List<Party_Assets_Funds__c>(),
                'Lottery/ Betting Winnings' => new List<Party_Assets_Funds__c>(),
                'Loan' => new List<Party_Assets_Funds__c>(),
                'Maturity of insurance policy or fixed term investment' => new List<Party_Assets_Funds__c>(),
                'Owned Property' => new List<Party_Assets_Funds__c>(),
                'Ownership/shares in business' => new List<Party_Assets_Funds__c>(),
                'Pension/Retirement' => new List<Party_Assets_Funds__c>(),
                'Salary/Bonus' => new List<Party_Assets_Funds__c>(),
                'Sale of Business' => new List<Party_Assets_Funds__c>(),
                'Sale of Property' => new List<Party_Assets_Funds__c>(),
                'Sale of Investment' => new List<Party_Assets_Funds__c>(),
                'Other' => new List<Party_Assets_Funds__c>()
                };
                    
                    // Iterate over the assets and add to the appropriate list in the map
                    for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
                        if (asset != null && asset.Party_Profile__c == partyProfileId && 
                            asset.recordTypeId == sourceFundRecordTypeId && asset.Is_Future_Fund__c==true) {
                                if (assetMap.containsKey(asset.Type__c)) {
                                    assetMap.get(asset.Type__c).add(asset);
                                }
                            }
                    }
        
        // Prepare the final result map with custom keys
        Map<String, List<Party_Assets_Funds__c>> result = new Map<String, List<Party_Assets_Funds__c>>();
        result.put('businessOwnershipDetailsSourceTrue', assetMap.get('Ownership/shares in business'));
        result.put('otherDetailsSourceTrue', assetMap.get('Other'));
        result.put('saleofPropertyDetailsSourceTrue', assetMap.get('Sale of Property'));
        result.put('saleOfInvestmentDetailsSourceTrue', assetMap.get('Sale of Investment'));
        result.put('salesOfBusinessDetailsSourceTrue', assetMap.get('Sale of Business'));
        result.put('salaryBonusDetailsSourceTrue', assetMap.get('Salary/Bonus'));
        result.put('pensionRetireDetailsSourceTrue', assetMap.get('Pension/Retirement'));
        result.put('ownerPropertyDetailsSourceTrue', assetMap.get('Owned Property'));
        result.put('maturedInsuranceDetailsSourceTrue', assetMap.get('Maturity of insurance policy or fixed term investment'));
        result.put('lotteryDetailsSourceTypeTrue', assetMap.get('Lottery/ Betting Winnings'));
        result.put('loanDetailsSourceTrue', assetMap.get('Loan'));
        result.put('investmentStockDetailsSourceTypeTrue', assetMap.get('Investment/Stock'));
        result.put('inheritanceDetailsSourceTypeTrue', assetMap.get('Inheritance'));
        result.put('giftDetailsSourceTypeTrue', assetMap.get('Gift'));
        result.put('compensationDetailsSourceTypeTrue', assetMap.get('Compensation Payment'));
        result.put('bankAccountDetailsSourceTrue', assetMap.get('Bank Account'));
        
        return result;
    }
    
    /**
* @description Method is used to filter and group party asset funds data by types whenever is future fund=true
* @param partyProfileId partyprofile record Id
* @return Grouped party asset fund data related to the partyprofile
*/
    public Map<String, List<Party_Assets_Funds__c>> getPartyAssetFundForInitialDeposit(Id partyProfileId) {
        Id additionalAccountRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Additional_Accounts');
        
        // Initialize a map to hold the type-specific lists
        Map<String, List<Party_Assets_Funds__c>> assetMap = new Map<String, List<Party_Assets_Funds__c>>{
            'Bank Account' => new List<Party_Assets_Funds__c>()              
                };
                
                    // Iterate over the assets and add to the appropriate list in the map
                    for (Party_Assets_Funds__c asset : dataProvider.partyBusinessAssets) {
                        if (asset != null && asset.Party_Profile__c == partyProfileId && 
                            asset.recordTypeId == additionalAccountRecordTypeId && asset.type__c=='Bank Account') {
                                
                                if (assetMap.containsKey(asset.Type__c)) {
                                    assetMap.get(asset.Type__c).add(asset);
                                }
                            }
                    }


        
        // Prepare the final result map with custom keys
        Map<String, List<Party_Assets_Funds__c>> result = new Map<String, List<Party_Assets_Funds__c>>();       
        
        result.put('bankAccountDetailsSourceTrue', assetMap.get('Bank Account'));
        
        return result;
    }
    
    
    /**
* @description Method is used to filter and group Assessment Questions reponses data by questions
* @param parentId account Id
* @param sectionName section Name
* @return Grouped assessment question response with Questions asked data related to the accountId
*/
    public Map<String,String> getAssessmentResponsesDetails( String parentId ,string sectionName ) {
        List<AssessmentQuestionResponse> responses = [
            SELECT Id, ResponseText,AssessmentQuestion.QuestionText,name
            FROM AssessmentQuestionResponse where assessment.accountId=:parentId AND Name =: sectionName];
        Map<String,String> questionWithResponseText = new Map<String,String>();
        if (!responses.isEmpty()) {
            for(AssessmentQuestionResponse response : responses) {
                
                String rsp;
                if (response.ResponseText == 'TRUE') {
                    rsp = 'Yes';
                } else if (response.ResponseText == 'FALSE') {
                    rsp = 'No';
                } else {
                    rsp = response.ResponseText;
                }     
                questionWithResponseText.put(response.AssessmentQuestion.QuestionText ,rsp);
            }
        }
        return questionWithResponseText ;
    }
    
    /**
* @description Method is used to filter and group Assessment Questions reponses data by questions for Asset & Income section
* @param parentId account Id
* @param partyProfileId 
* @return Grouped assessment question response with Questions asked data related to the partyProfileId
*/
    public Map<String, String> getAssessmentResponses(String partyProfileId, String parentId, String sectionName, String questionType) {
        Map<String, String> typeWithResponse = new Map<String, String>();
        
        Map<String, String> questionWithResponseText = getQuestionResponseMap(parentId, sectionName, questionType);
        Set<String> allResponseTexts = new Set<String>(questionWithResponseText.values());
        
        Map<String, Set<String>> responseWithQuestTextMap = buildResponseQuestionMap(questionWithResponseText);
        
        List<Party_Assets_Funds__c> partyAssetFunds = getPartyAssetFunds(parentId, allResponseTexts);
        
        for (Party_Assets_Funds__c fund : partyAssetFunds) {
            updateTypeWithResponse(typeWithResponse, responseWithQuestTextMap, fund);
        }
        
        return typeWithResponse;
    }

    private Map<String, String> getQuestionResponseMap(String parentId, String sectionName, String questionType) {
        Map<String, String> questionWithResponseText = new Map<String, String>();
        
        List<AssessmentQuestionResponse> responses = [
            SELECT Id, ResponseText, AssessmentQuestion.QuestionText, Name
            FROM AssessmentQuestionResponse
            WHERE assessment.accountId = :parentId AND Name = :sectionName
        ];
        
        for (AssessmentQuestionResponse response : responses) {
            List<String> individualResponses = new  List<String> ();
            if(response.ResponseText != null){
                if(response.ResponseText.contains(';')){
                    individualResponses = response.ResponseText.split(';');
                }
                else{
                    individualResponses.add(response.ResponseText);
                }
            }
            String keyPrefix = response.AssessmentQuestion.QuestionText == questionType ? 'a' : 'b';
            
            for (Integer i = 0; i < individualResponses.size(); i++) {
                String key = keyPrefix + i;
                questionWithResponseText.put(key, individualResponses[i].trim());
            }
        }
        
        return questionWithResponseText;
    }

    private Map<String, Set<String>> buildResponseQuestionMap(Map<String, String> questionWithResponseText) {
        Map<String, Set<String>> responseWithQuestTextMap = new Map<String, Set<String>>();
        
        for (String question : questionWithResponseText.keySet()) {
            String response = questionWithResponseText.get(question);
            if (!responseWithQuestTextMap.containsKey(response)) {
                responseWithQuestTextMap.put(response, new Set<String>());
            }
            responseWithQuestTextMap.get(response).add(question);
        }
        
        return responseWithQuestTextMap;
    }

    private List<Party_Assets_Funds__c> getPartyAssetFunds(String parentId, Set<String> allResponseTexts) {
        Id sourceFundRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Source_of_Funds');
        Id wealthCountryRecordTypeId = dataProvider.recordTypes.get('Party_Assets_Funds__c_Wealth_in_Country');
        Set<Id> recordTypeIds = new Set<Id>{sourceFundRecordTypeId, wealthCountryRecordTypeId};
        
        return [
            SELECT Id, Name, Type__c
            FROM Party_Assets_Funds__c
            WHERE Type__c IN :allResponseTexts 
            AND Party_Profile__r.AccountId = :parentId 
            AND recordTypeId IN :recordTypeIds
        ];
    }

    private void updateTypeWithResponse(Map<String, String> typeWithResponse, Map<String, Set<String>> responseWithQuestTextMap, Party_Assets_Funds__c fund) {
        if (responseWithQuestTextMap.containsKey(fund.Type__c)) {
            for (String question : responseWithQuestTextMap.get(fund.Type__c)) {
                typeWithResponse.put(question, fund.Type__c);
            }
        }
    }
    public Map<String, String> getAssessmentResponsesAssetIncome(String partyProfileId, String parentId) {
        String sectionName = 'Assets and Income';
        String questionType = 'Select all assets and income*';
        return getAssessmentResponses(partyProfileId, parentId, sectionName, questionType);
    }
    public Map<String, String> getAssessmentResponsesAssetIncomeNew(String partyProfileId, String parentId) {
        String sectionName = 'Assets and Income';
        String questionType = 'Select all funds assets and income*';
        return getAssessmentResponses(partyProfileId, parentId, sectionName, questionType);
    }

    public Map<String, String> getAssessmentResponsesFutureDeposit(String partyProfileId, String parentId) {
        String sectionName = 'Future Deposits';
        String questionType = 'How do you intend to fund the future deposits?';
        return getAssessmentResponses(partyProfileId, parentId, sectionName, questionType);
    }  
}