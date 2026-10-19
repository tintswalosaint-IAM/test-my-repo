/*
* @description SFP-32986 Class used to send Risk Assessment request to Rely comply.
*              This class extends ICS_API_RestBaseOutbound for handling outbound REST API calls.
* @author Ikyatha Naidu, Swapnil Walse
* @date 22/04/2024
***************************************************** 
 * @last modified on  : 01/07/2024.
 * @last modified by  : Ikyatha Naidu
 * @last modified description: updated to latest version with improved error handling
 * ***************************************************** 
 * @last modified on  : 13/09/2025
 * @last modified by  : Ramya Gurram
 * @last modified description:  SFP-52215 Updated Industry Specific Logic 
*/
public without sharing class ICS_API_SendCRADetails extends CMN_API_RestBaseOutbound {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_SendCRADetails');
    public static final String SERVICE_NAME = ICS_API_SendCRADetails.class.getName();
    Public static Map<String, Integer> genderMap = new Map<String, Integer> { // Initialize a map to map gender strings to integer values
        'Male' => 2,
            'Female' => 3,
            'Unknown' => 1
            };
                @testVisible
                private ICS_API_SendCRADetails() {}
    @future(callout=true)
    public static void callCRA(string accountId) {
        try {
            map<string,string> requestCustomerIdMap = new Map<string,string>();
            List<Id> failedAccounts = new List<Id>();
            
            
            try {
                ICS_DTO_SendCRADetails request = buildCRARequest(accountId);
                PartyProfile partyProfile = getPartyProfile(accountId);
                
                string reqString  = JSON.serialize(request);
                Map<String, Object> updatedRequest = (Map<String, Object>) JSON.deserializeUntyped(reqString);
                if(partyProfile.Second_Country_of_Nationality__c!=null){
                    updatedRequest.put('nationality_2',partyProfile.Second_Country_of_Nationality__c);
                }
                requestCustomerIdMap.put(accountId,JSON.serialize(updatedRequest) );
                LOGGER.debug('Built CRA request for account {0}', new Object[]{accountId});
            } catch (Exception e) {
                LOGGER.error('Error building CRA request for account {0}: {1}', new Object[]{accountId, e.getMessage()});
                failedAccounts.add(accountId);
            }
            
            
            if (requestCustomerIdMap.isEmpty()) {
                LOGGER.error('No valid CRA requests were built. Aborting sendRequest.');
            } else {
                sendRequest(requestCustomerIdMap);
                LOGGER.info('Sent CRA requests for {0} accounts', new Object[]{requestCustomerIdMap.size()});
            }
            
            if (!failedAccounts.isEmpty()) {
                LOGGER.warn('Failed to process {0} accounts: {1}', new Object[]{failedAccounts.size(), failedAccounts});
            }
        } catch (Exception e) {LOGGER.error('Fatal error in callCRA: {0}', new Object[]{e.getMessage()});}
    }
    @testvisible
    private static void populatePersonalDetails(PersonalDetails personalDetails, Account account, PartyProfile partyProfile) {
        try {
            personalDetails.DateOfBirth = String.valueOf(account.PersonBirthdate);
            personalDetails.Forename = account.FirstName;
            personalDetails.MiddleName = account.MiddleName!=null?account.MiddleName:'';
            personalDetails.Surname = account.LastName;
            personalDetails.Title = account.PersonTitle;
            personalDetails.nationality = partyProfile.Country_of_Nationality__c;
            
            
            
            String genderValue = account.FinServ__Gender__pc;
            if (genderMap.containsKey(genderValue)) {
                personalDetails.Gender = genderMap.get(genderValue);
            }
        } catch (Exception e) {LOGGER.error('Error populating personal details: {0}', new Object[]{e.getMessage()});}
    }
    
    @testvisible
    private static PartyProfile getPartyProfile(Id accountId) {
        try {
            SEL_PartyProfile pProfile = new SEL_PartyProfile();
            PartyProfile profileData = pProfile.selectByAccountAndRecordType(accountId,ICS_Constants.SBO_RECNAME);
            return  profileData;
        } catch (Exception e) {
            LOGGER.error('Error getting PartyProfile for account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        }
    }
    
    @testvisible
    private static Account getAccount(Id accountId) {
        try {
            SEL_Account accountSelector=new SEL_Account();
            return accountSelector.selectById(accountId);
        } catch (Exception e) {
            LOGGER.error('Error getting Account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        }
    }
    
    @testvisible
    private static ICS_DTO_SendCRADetails buildCRARequest(Id accountId) {
        try {
            ICS_DTO_SendCRADetails request = new ICS_DTO_SendCRADetails();
            request.CraKeys = new List<RequestMap>();
            request.CustomerId = accountId;
            request.personalDetails = new PersonalDetails();
            PartyProfile partyProfile = getPartyProfile(accountId);
            Account account = getAccount(accountId);
            
            if (partyProfile != null && account != null) {
                populatePersonalDetails(request.personalDetails, account, partyProfile);
            }
            
            request.CraKeys.addAll(prepareAdverseMediaCheck(accountId));
            request.CraKeys.addAll(preparePEPCheck(accountId));
            request.CraKeys.addAll(prepareHighNetWorthCheck(accountId));
            request.CraKeys.addAll(prepareShellBankCheck(accountId));
            request.CraKeys.addAll(prepareProductInfo(accountId));
            request.CraKeys.addAll(prepareApplicantInfo(accountId));
            
            return request;
        } catch (Exception e) {
            LOGGER.error('Error in buildCRARequest for account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        }
    }
    @TestVisible
    private static List<RequestMap> prepareRequestMap(Map<String, Object> dataMap) {
        List<RequestMap> requestMaps = new List<RequestMap>();
        for (String key : dataMap.keySet()) {
            Object value = dataMap.get(key);
            if (value instanceof List<Object>) {
                for (Object item : (List<Object>)value) {
                    requestMaps.add(new RequestMap(key, String.valueOf(item)));
                }
            } else if (value instanceof Set<String>) {
                for (String item : (Set<String>)value) {
                    requestMaps.add(new RequestMap(key, item));
                }
            } else {
                requestMaps.add(new RequestMap(key, String.valueOf(value)));
            }
        }
        return requestMaps;
    }
    
    @testvisible
    private static List<RequestMap> preparePEPCheck(Id applicantId) {
        try {
            Map<String, Object> dataMap = new Map<String, Object>();  
            SEL_PartyScreeningSummary selectorScreeningSummary = new SEL_PartyScreeningSummary();
            string pProfileId= getPartyProfileId(applicantId);
            sel_partyprofile pSelector = new sel_partyprofile();
            PartyProfile pData = pSelector.selectById(pProfileId);
            List<PartyScreeningSummary> screeningSummaryList = selectorScreeningSummary.selectListBypartyProfileId(pProfileId);
            if (screeningSummaryList.isEmpty()) {
                LOGGER.warn('PEP Status not found for applicant {0}', new Object[]{applicantId});
                dataMap.put('is_pep',false);
            }
            else{
                boolean ispep=false;
                for(PartyScreeningSummary summary : screeningSummaryList) {
                    if(summary.IsPEP__c == true) {
                        // If any PEP is found with a status other than 'Matches discounted', 
                        // set ispep to true and we can exit the loop
                        if(pData.WorldcheckStatus__c != 'Matches discounted') {
                            ispep = true;
                            break; 
                        }
                    }
                }
                dataMap.put('is_pep',ispep);
                
            }
            
            return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error in preparePEPCheck for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
        
    }
    @testVisible
    private static List<RequestMap> prepareAdverseMediaCheck(Id applicantId) {
        try {
            Map<String, Object> dataMap = new Map<String, Object>();
            SEL_PartyScreeningSummary selectorScreeningSummary = new SEL_PartyScreeningSummary();
            string pProfileId= getPartyProfileId(applicantId);
            sel_partyprofile pSelector = new sel_partyprofile();
            PartyProfile pData = pSelector.selectById(pProfileId);
            List<PartyScreeningSummary> screeningSummaryList = selectorScreeningSummary.selectListBypartyProfileId(getPartyProfileId(applicantId));
            if (screeningSummaryList.isEmpty()) {
                LOGGER.warn('Adverse Media Status not found for applicant {0}', new Object[]{applicantId});
                dataMap.put('has_adverse_media',false);
            } else{
                boolean isAM = false;
                
                for(PartyScreeningSummary summary : screeningSummaryList) {
                    if(summary.IsAdverseMedia__c == true) {
                        if(pData.WorldcheckStatus__c != 'Matches discounted') {
                            isAM = true;
                            break; // Exit the loop once we find a valid adverse media case
                        }
                    }
                }
                dataMap.put('has_adverse_media',isAM);
            }
            return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error in prepareAdverseMediaCheck for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
    }
    @testvisible
    private static List<RequestMap> prepareHighNetWorthCheck(Id applicantId) {
        try {
            Decimal totalWealth = calculateTotalWealth(applicantId);
            Decimal wealthThreshold = ICS_Approval_Conditions__mdt.getInstance('Approval_Condition_Values').Wealth_Threshold__c;
            
            Map<String, Object> dataMap = new Map<String, Object>{
                'has_high_net_worth' => (totalWealth >= wealthThreshold)
                    };
                        return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error in prepareHighNetWorthCheck for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
    }
    @testvisible
    private static List<RequestMap> prepareShellBankCheck(Id applicantId) {
        try {
            Map<String, String> assessmentResponses = getAssessmentResponses(applicantId);
            Map<String, Object> dataMap = new Map<String, Object>{
                'shell_bank' => assessmentResponses.get('Are you associated to any Shell Banks?') != null ? 
                    assessmentResponses.get('Are you associated to any Shell Banks?') : 'false',
                        'bearer_shares' => assessmentResponses.get('Do you directly or indirectly hold bearer shares certificates?') != null ? 
                        assessmentResponses.get('Do you directly or indirectly hold bearer shares certificates?') : 'false',
                            'government_contracts' => assessmentResponses.get('Do you/your employment have any contracts with public authorities/governments/s?') != null ? 
                            assessmentResponses.get('Do you/your employment have any contracts with public authorities/governments/s?') : 'false'
                                };
                                    return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error in prepareShellBankCheck for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
    }
    @testvisible
    private static List<RequestMap> prepareProductInfo(Id applicantId) {
        try {
            String productName = getProductName(applicantId);
            Map<String, Object> dataMap = new Map<String, Object>{
                'product' => productName
                    };
                        return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error in prepareProductInfo for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
    }
    
    public static List<RequestMap> prepareApplicantInfo(Id applicantId) {
        try {
            Applicant applicant =  getApplicant(applicantId);
            
            FinServ__Employment__c employment = getEmployment(applicant.accountId);
            
            FinServ__Employment__c dualEmployment = getDualEmployment(applicant.accountId);
            
            ICS_CustomLabel__mdt occupationCategoryLabel = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('CRAOccupationCategory');
            Map<String, String> occupationCategoryInfo = (Map<String, String>)JSON.deserialize(occupationCategoryLabel.Description__c, Map<String, String>.class);
            
            ICS_CustomLabel__mdt positionLabel = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('CRAPosition');
            Map<String, String> positionInfo = (Map<String, String>)JSON.deserialize(positionLabel.Description__c, Map<String, String>.class);
            
            ICS_CustomLabel__mdt industryLabel = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('CRAIndustry');
            Map<String, String> industryInfo = (Map<String, String>)JSON.deserialize(industryLabel.Description__c, Map<String, String>.class);
            
            ICS_CustomLabel__mdt DistributionChannelLabel = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('CRADistributionChannel');
            Map<String, String> DistributionChannelInfo = (Map<String, String>)JSON.deserialize(DistributionChannelLabel.Description__c, Map<String, String>.class);
            SEL_Opportunity opportunitySelector = new SEL_Opportunity();
            Opportunity opp = opportunitySelector.selectById(applicant.ApplicationForm.OpportunityId);
            
            
            Map<String, Object> dataMap = new Map<String, Object>{
                'residence' => applicant.PartyProfile.country_of_Residence__c,
                    'country_of_birth' => applicant.PartyProfile.CountryofBirth,
                    'country_of_citizenship' => applicant.PartyProfile.WI_CountryOfCitizenship__c,
                    'nationality' => applicant.PartyProfile.Country_of_Nationality__c,
                    'distribution_channel' => DistributionChannelInfo.get(opp.LeadSource),
                    'opportunity' => applicant.ApplicationForm.OpportunityId
                    };
                        
                        if(applicant.partyProfile.Second_Country_of_Nationality__c !=null){
                            dataMap.put('nationality_2',applicant.partyProfile.Second_Country_of_Nationality__c);
                        }
            
            List<Party_Assets_Funds__c> wealthInfo =  fetchAssets( applicant,'Source of Funds','Select all funds assets and income*',false);
            List<Party_Assets_Funds__c> fundInfo =  fetchAssets( applicant,'Source of Funds','How do you intend to fund the future deposits?',true);
            Integer counter = 0;
            List<String> fields = new List<String>{'Business_Location__c', 'Country__c', 'Locations__c', 'Jurisdiction_Where_Investments_Held__c','Jurisdictional_Cover_of_Sale__c'};
                
                for(Party_Assets_Funds__c wealthMap : wealthInfo) { 
                    for(String field : fields) {
                        if(wealthMap.get(field) != null) {
                            String key = counter == 0 ? 'country_of_wealth' : 'country_of_wealth' + counter;
                            String value = (String)wealthMap.get(field);
                            if(field.equals('Jurisdiction_Where_Investments_Held__c') || field.equals('Jurisdictional_Cover_of_Sale__c')||field.equals('Locations__c')) {
                                value = getCountryCodeFromName(value);
                            }
                            
                            dataMap.put(key, value);
                            counter++;
                        }
                    }
                }
            
            counter = 0;
            for(Party_Assets_Funds__c fundMap : fundInfo) {
                for(String field : fields) {
                    if(fundMap.get(field) != null) {
                        String key = counter == 0 ? 'country_of_funds' : 'country_of_funds' + counter;
                        String value = (String)fundMap.get(field);
                        if(field.equals('Jurisdiction_Where_Investments_Held__c') || field.equals('Jurisdictional_Cover_of_Sale__c')||field.equals('Locations__c')) {
                            value = getCountryCodeFromName(value);
                        }
                        dataMap.put(key, value);
                        counter++;
                    }
                }
            }
            
            if (employment != null) {
                
                if (employment != null && employment.CMN_Industry__c != null) {
                    Id dualIndustryId = (dualEmployment != null) ? dualEmployment.CMN_Industry__c : null;
                    ICS_API_SendCRADetails.IndustryScoreWrapper result = getRiskScoreAndSlug(employment.CMN_Industry__c, dualIndustryId);
                   
                    if (result != null) {
                        dataMap.put('business_activity', result.slugId);
                    }
                }
                string oCat ='';
                if(occupationCategoryInfo.get(employment.FinServ__EmploymentStatus__c) == null){
                    oCat = '';
                }else{
                    oCat = occupationCategoryInfo.get(employment.FinServ__EmploymentStatus__c); 
                    
                }
                
                if(oCat!= null){
                    dataMap.put('occupation_category', oCat);
                }
                if(positionInfo.containskey(employment.FinServ__Occupation__c)){
                    dataMap.put('occupation_position', positionInfo.get(employment.FinServ__Occupation__c));
                }
                
            }
            
            return prepareRequestMap(dataMap);
        } catch (Exception e) {
            LOGGER.error('Error adding applicant info for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new List<RequestMap>();
        }
    }
    public static IndustryScoreWrapper getRiskScoreAndSlug(String currentIndustryId, String dualIndustryId) {
        // Fetch both records in a single SOQL
        set<string> idSet = new set<string>();
        idSet.add(currentIndustryId);
        idSet.add(dualIndustryId);
        SEL_Industry selectorIndustry = new SEL_Industry();
        List<CMN_Industry__c> industryList=  selectorIndustry.selectByRecordTypeIds(true, 'SBO', idSet);
        Map<Id, CMN_Industry__c> industriesMap = new Map<Id, CMN_Industry__c>();
        
        for(CMN_Industry__c industryInfo : industryList){
            industriesMap.put(industryInfo.Id,industryInfo);
        }
        
        
        CMN_Industry__c currentIndustry = industriesMap.get(currentIndustryId);
        CMN_Industry__c dualIndustry = industriesMap.get(dualIndustryId);
        
        Integer currentScore = getScore(currentIndustry?.CMN_RiskRating__c);
        Integer dualScore = getScore(dualIndustry?.CMN_RiskRating__c);
        ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Ics_Industry');
        Map<string,Integer>   labelInfo = (Map<string,Integer>)json.deserialize(labelData.Description__c, map<string,Integer>.class);
        // Apply business rules
        if (currentScore == labelInfo.get('High')) {
            return new IndustryScoreWrapper(currentScore, currentIndustry.CMN_SlugID__c);
        } else if (dualScore == labelInfo.get('High')) {
            return new IndustryScoreWrapper(dualScore, dualIndustry.CMN_SlugID__c);
        } else if (currentScore >= dualScore) {
            return new IndustryScoreWrapper(currentScore, currentIndustry.CMN_SlugID__c);
        } else {
            return new IndustryScoreWrapper(dualScore, dualIndustry.CMN_SlugID__c);
        }
    }
    
    // Utility method to convert risk rating to score
    private static Integer getScore(String risk) {
        ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('Ics_Industry');
        Map<string,Integer>   labelInfo = (Map<string,Integer>)json.deserialize(labelData.Description__c, map<string,Integer>.class);
        if(labelInfo.containskey(risk)){
            return labelInfo.get(risk);
        }
        return 0; // Default if unknown
    }
    private static String getCountryCodeFromName(String countryName) {
        try {
            if (String.isBlank(countryName)) {
                return '';
            }
            Map<String, String> countryCodeToNameMap = new Map<String, String>();
            Schema.DescribeFieldResult fieldResult = PartyProfile.Country_of_Residence__c.getDescribe();
            for(Schema.PicklistEntry f : fieldResult.getPicklistValues()) {
                countryCodeToNameMap.put(f.getValue(), f.getLabel());
            }
            Map<String, String> countryNameToCodeMap = new Map<String, String>();
            for(String code : countryCodeToNameMap.keySet()) {
                String name = countryCodeToNameMap.get(code);
                countryNameToCodeMap.put(name.toUpperCase(), code);
            }
            String upperCountryName = countryName.toUpperCase().trim();
            return countryNameToCodeMap.containsKey(upperCountryName) ? 
                countryNameToCodeMap.get(upperCountryName) : countryName;
            
        } catch(Exception e) {
            LOGGER.error('Error in getCountryCodeFromName: ' + e.getMessage());
            return countryName; 
        }
    }
    Public static String getResponseValue(String accountId, String assessmentName,string recName) {
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        List<AssessmentQuestionResponse> responseList = selectorAssessmentqueResponse.selectByAccountIdAndAssessmentName(accountId, assessmentName);
        
        if (responseList == null || responseList.isEmpty()) {
            return '';
        }
        Map<String, AssessmentQuestionResponse> assResponseMap = new Map<String, AssessmentQuestionResponse>();
        for (AssessmentQuestionResponse responseInfo : responseList) {
            assResponseMap.put(responseInfo.AssessmentQuestion.Name, responseInfo);
        }
        
        return assResponseMap?.get(assessmentName)?.ResponseText ?? '';
    }
    private static List<Party_Assets_Funds__c> fetchAssets(Applicant applicant , string recName,string questionName,boolean isFutureFund){
        SEL_PartyAssetFunds fundsSelector = new SEL_PartyAssetFunds();
        String responseValue = getResponseValue(applicant.accountId, questionName, recName);
        
        List<String> responseValueList = responseValue.split(';');
        
        
        List<Party_Assets_Funds__c> fundsList =fundsSelector.selectByPartyProfileBulkTypewithRecordAssests(applicant.partyprofileId,responseValueList,recName,isFutureFund);
        return fundsList;
    }
    @testVisible
    private static FinServ__Employment__c getEmployment(string accountId){
        try {
            SEL_Employment employmentSelectorInfo = new SEL_Employment();
            List<FinServ__Employment__c> employmentInfo = employmentSelectorInfo.selectByParentIdAndSectionName(accountId,'Current Employment Details');
            return employmentInfo.isEmpty() ? null: employmentInfo[0]  ;
        } catch (Exception e) {
            LOGGER.error('Error retrieving employment for account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        }
    }
    
    private static FinServ__Employment__c getDualEmployment(string accountId){
        try {
            SEL_Employment employmentSelectorInfo = new SEL_Employment();
            List<FinServ__Employment__c> employmentInfo = employmentSelectorInfo.selectByParentIdAndSectionName(accountId,'Dual Employment Details');
            return employmentInfo.isEmpty() ? null:employmentInfo[0] ;
        } catch (Exception e) {
            LOGGER.error('Error retrieving dual employment for account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        }
    }
    @testvisible
    private static Decimal calculateTotalWealth(Id applicantId) {
        try {
            SEL_PartyAssetFunds selectorPartyAssetFunds = new SEL_PartyAssetFunds();
            List<Party_Assets_Funds__c> partyAssetFunds = selectorPartyAssetFunds.selectAssetFundsByRecordType(getPartyProfileId(applicantId), new List<string>{}, 'Funds');
            
            Decimal totalWealth = 0;
            for (Party_Assets_Funds__c fund : partyAssetFunds) {
                if (!fund.Is_Future_Fund__c) {
                    totalWealth += (fund.Funds_Received__c ?? 0) +
                        (fund.Salary__c ?? 0) +
                        (fund.Bonus_Amount__c ?? 0) +
                        (fund.Sale_Amount__c ?? 0) +
                        (fund.Applicant_Share__c ?? 0) +
                        (fund.Pension_Amount__c ?? 0) +
                        (fund.Total_Amount__c ?? 0) +
                        (fund.Maturity_Proceeds__c ?? 0) +
                        (fund.Share_of_Client__c ?? 0) +
                        (fund.Current_Account_Balance__c ?? 0) +
                        (fund.Anticipated_Credit_Turnover__c ?? 0);
                }
            }
            return totalWealth;
        } catch (Exception e) {
            LOGGER.error('Error calculating total wealth for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return 0;
        }
    }
    
    
    @testvisible
    
    private static void sendRequest(Map<String, String> requestCustomerIdMap) {
        List<String> failedAccounts = new List<String>();
        List<CMN_WebserviceCallQueue__c> webserviceList = new List<CMN_WebserviceCallQueue__c>();
        for(String accId : requestCustomerIdMap.keySet()) {
            try {
                ICS_API_InvokeCRA customerServiceCall = new ICS_API_InvokeCRA();
                customerServiceCall.reqBody = requestCustomerIdMap.get(accId);
                CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_InvokeCRA.SERVICE_NAME, accId);
                customerServiceCall.process(obj);
                
                webserviceList.add(obj);
                LOGGER.info('Successfully processed request for account {0}', new Object[]{accId});
            } catch (Exception e) {
                LOGGER.error('Error processing request for account {0}: {1}', new Object[]{accId, e.getMessage()});
                failedAccounts.add(accId);
            }
        }
        if(!webserviceList.isEmpty()){
            Insert webserviceList;
        }
        
        if (!failedAccounts.isEmpty()) {
            LOGGER.warn('Failed to process requests for {0} accounts: {1}', new Object[]{failedAccounts.size(), failedAccounts});
        }
    }
    @testvisible
    private static String getProductName(Id applicantId) {
        try {
            List<String> applicableProducts = ICS_Approval_Conditions__mdt.getInstance('Approval_Condition_Values').Applicable_Products__c.split(',');
            Set<String> productSet = new Set<String>(applicableProducts);
            SEL_OpportunityLineItem lineItemSelector = new SEL_OpportunityLineItem();
            List<OpportunityLineItem> productList = lineItemSelector.selectByOpportunityIds(new Set<Id>{getOpportunityId(applicantId)});
            
            for (OpportunityLineItem lineItem : productList) {
                if (productSet.contains(lineItem.Product2.Name)) {
                    return lineItem.Product2.Name.toLowerCase().replace(' ', '_') + '_account';
                }
            }
            
            return null;
        } catch (Exception e) {
            LOGGER.error('Error getting product name for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return null;
        } 
    }
    @testvisible
    private static Map<String, String> getAssessmentResponses(Id applicantId) {
        try {
            getAccountId(applicantId);
            SEL_Assesment selectorAssessment = new SEL_Assesment();
            List<Assessment> partyAssessments = selectorAssessment.SelectByAccountId(applicantId);
            
            Set<Id> assessmentIdSet = new Set<Id>();
            for (Assessment assessment : partyAssessments) {
                assessmentIdSet.add(assessment.Id);
            }
            
            SEL_AssesmentQuestionResponse selectorQuestionResponse = new SEL_AssesmentQuestionResponse();
            List<AssessmentQuestionResponse> responses = selectorQuestionResponse.selectByAssessmentIds(assessmentIdSet);
            
            Map<String, String> assessmentResponses = new Map<String, String>();
            for (AssessmentQuestionResponse response : responses) {
                assessmentResponses.put(response.AssessmentQuestion.Name, response.ResponseValue.toLowerCase());
            }
            
            return assessmentResponses;
        } catch (Exception e) {
            LOGGER.error('Error getting assessment responses for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return new Map<String, String>();
        }
    }
    @testvisible
    // Helper methods to get various IDs
    private static Id getPartyProfileId(Id applicantId) {
        try {
            return getApplicant(applicantId).PartyProfileId;
        } catch (Exception e) {
            LOGGER.error('Error getting PartyProfileId for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return null;
        } 
    }
    @testvisible
    private static Id getAccountId(Id applicantId) {
        try {
            return getApplicant(applicantId).AccountId;
        } catch (Exception e) {
            LOGGER.error('Error getting AccountId for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return null;
        } 
    }
    @testvisible
    private static Id getOpportunityId(Id applicantId) {
        try {
            return getApplicant(applicantId).ApplicationForm.OpportunityId;
        } catch (Exception e) {
            LOGGER.error('Error getting OpportunityId for applicant {0}: {1}', new Object[]{applicantId, e.getMessage()});
            return null;
        } 
    }
    @testvisible
    private static Applicant getApplicant(Id accountId) {
        try {
            SEL_Applicant selectorApplicant = new SEL_Applicant();
            return selectorApplicant.selectByAccountId(accountId);
        } catch (Exception e) {
            LOGGER.error('Error getting Applicant for account {0}: {1}', new Object[]{accountId, e.getMessage()});
            return null;
        } 
    }
    
    // Inner classes
    public class ICS_DTO_SendCRADetails extends CMN_DTO_JsonBase {
        public String CustomerId { get; set; }
        public List<RequestMap> CraKeys { get; set; }
        /** Personal Details object. */
        public PersonalDetails  PersonalDetails{get;set;}
    }
    public class PersonalDetails {
        /** Date of Birth details. */
        public String DateOfBirth {get;set;}
        /** Forename details. */
        public String Forename {get;set;}
        /** Gender details. */
        public Integer Gender {get;set;}
        public String MiddleName {get;set;}
        /** Surname details. */
        public String Surname {get;set;}
        /** Title details. */
        public String Title {get;set;}
        /** Nationality details. */
        public String nationality {get;set;}
        
    }
    public class RequestMap {
        public String key { get; set; } 
        public String value { get; set; }
        
        public RequestMap(String key, String value) {
            this.key = key;
            this.value = value;
        }
    }
    public class IndustryScoreWrapper {
        public Integer score;
        public String slugId;
        
        public IndustryScoreWrapper(Integer score, String slugId) {
            this.score = score;
            this.slugId = slugId;
        }
    }
}