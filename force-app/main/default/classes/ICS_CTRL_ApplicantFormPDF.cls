/**
 * @Name of the Class : ICS_CTRL_ApplicantFormPDF.cls
 * @description: class used as controller to pull the data into PDF
 * @Author Ikyatha Naidu 
 * @Date 01/06/2024
 * @Last Modified On  : 28-03-2025
 * @Last Modified By  : Tushar Walse
 * @Modification Description : Initial Version
 * ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 18-06-2025
 * @Modification description : SFP-50276
 ***************************************************************************************
  * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 08-07-2025
 * @Modification description : SFP-50777
 ***************************************************************************************
 * @Last Modified By 		: Ridhima Saxena
 * @Last Modified On 		: 12-09-2025
 * @Modification description : SFP-52838 Updated getAssessmentResponses method to get AssessmentQuestionResponse
 ***************************************************************************************
 * @Last Modified By      : Ridhima Saxena
 * @Last Modified On      : 16-07-2026
 * @Modification description :SFP-59113 – Updated the implementation to add the Assessment Question for Marketing Consent.
 */
public without sharing class ICS_CTRL_ApplicantFormPDF {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_ApplicantFormPDF');
	private static final String FUTURE_DEPOSITS = 'Future Deposits';
    private static final String TAX_CERTIFICATES = 'Tax Certificates';
    private static final String INITIAL_DEPOSIT = 'Initial Deposit';
    private static final String TRUSTS = 'Trusts';
    private static final String CURRENT_EMPLOYMENT = 'Current Employment Details';
    private static final String PREVIOUS_EMPLOYMENT = 'Previous Employment Details';
    private static final String BANK_DETAILS = 'Bank Details';
    private static final String BUSINESS_OWNERSHIP = 'Business Ownership';
    private static final String CORRESPONDENCE_ADDRESS = 'Correspondence Address';
    private static final String OTHER_BUSINESS = 'Other Business Interests';
    private static final String SELECTED_ACCOUNT = 'Selected Account';
    private static final String ACCOUNT_PURPOSE = 'Account Purpose';
    private static final String CONTACT_DETAILS = 'Contact Details';
    private static final String ADDITIONAL_BANK = 'Additional Bank Accounts';
    private static final String ASSETS_INCOME = 'Assets and Income';
    private static final String PREV_EMP_PREFIX = 'Previous Employment Details:';
    private static final String CURR_EMP_PREFIX = 'Current Employment Details:';
    private static final String DUAL_EMP_PREFIX = 'Dual Employment Details:';
    public static Map<String, Object> records {get; set;}
    public static  String SameResAddr {get; set;}
    public Integer applicationCount {get; set;}
    public Boolean isPrimaryApplicant {get; set;}
    public String applicantRelation {get; set;}
    public String otherRelation {get; set;}
    public String otherFirstName {get; set;}
    public String otherMiddleName {get; set;}
    public String otherSurname {get; set;}
    @TestVisible private static ICS_UTIL_AppFormDataProvider appFormData; 
    public static List<Party_Assets_Funds__c> partyAssetRecords {get; set;}
    Public static Blob strPdfBody = null;
    public ICS_CTRL_ApplicantFormPDF() {
        init();
    }

    private void init() {
        String recordId = ApexPages.currentPage().getParameters().get('Id');
      
        if (String.isNotBlank(recordId)) {
            appFormData = new ICS_UTIL_AppFormDataProvider(recordId);
            records = getRecords(recordId);
            checkIfPrimaryApplicant(recordId);
            setApplicationCount(recordId);   
            getApplicantRelation(recordId);
              
        } else {
            records = new Map<String, Object>();
        }
        SameResAddr = 'my add';
    }
  
    
    public void setApplicationCount(Id recordId) {
        if (String.isNotBlank(recordId)) {
            if (!Schema.sObjectType.ApplicationForm.isAccessible()) {
                applicationCount = 0;
                return;
            }
            ApplicationForm formData = [SELECT Id, OpportunityID 
                                        FROM ApplicationForm 
                                        WHERE AccountId = :recordId];
            applicationCount = [SELECT Count() 
                                FROM ApplicationForm 
                                WHERE opportunityId = :formData.OpportunityID];
        } else {
            applicationCount = 0;
        }
    }
    public void checkIfPrimaryApplicant(Id recordId) {
        if (String.isNotBlank(recordId)) {
            SEL_Applicant selApplicant = new SEL_Applicant();
            Applicant primaryApplicant = selApplicant.selectByAccountId(recordId);
            if(primaryApplicant.role == 'Primary Applicant' || primaryApplicant.role == null){
                isPrimaryApplicant =true;
            }else{
                isPrimaryApplicant =false;
            }
           
        } else {
            isPrimaryApplicant = false;
        }
    }
    public void getApplicantRelation(Id recordId) {
       
     
            SEL_Applicant selApplicant = new SEL_Applicant();
            Applicant relation = selApplicant.selectByAccountId(recordId); 
            if(relation != null) {
                applicantRelation = relation.Relationship_with_Applicants__c;
                otherRelation = relation.Other__c;
                otherFirstName= relation.Other_First_Name__c;
                otherMiddleName= relation.Other_Middle_Name__c;
                otherSurname= relation.Other_Surname__c;

            }
        
    }
    
   public static Map<String, Object> getRecords(Id recordId) {
        ICS_UTIL_AppFormDataService dataService = new ICS_UTIL_AppFormDataService(recordId);
        Map<String, Object> resultRecords = dataService.getOpportunity();
        Map<String, Object> partyProfileData = getPartyProfiles(recordId);
        Map<String, Object> selectedAccountData = getSelectedAccountDetails(recordId);
        Map<String, Object> pointPhoneData = getContactPointPhone(recordId);
        Map<String, Object> assessmentData = getAssessmentResponses(recordId);
        Map<String, String> countryCodeMap = getCountryCodeMap();
        Map<String, String> businessRecords = getBusinessRecords();
        
        if (countryCodeMap == null) {
            resultRecords.put('countryCodeMap', new Map<String, String>());
        } else {
            countryCodeMap.remove(null);
            resultRecords.put('countryCodeMap', countryCodeMap);
        }
        
        if (businessRecords == null) {
            resultRecords.put('businessRecords', new Map<String, String>());
        } else {
            businessRecords.remove(null);
            resultRecords.put('businessRecords', businessRecords);
        }
    
        resultRecords.put('identityDocumentRecords', getFilteredIdentityDocs());
        resultRecords.putAll(partyProfileData);
        resultRecords.putAll(pointPhoneData);
        resultRecords.putAll(assessmentData);
        resultRecords.putAll(selectedAccountData);
        return resultRecords;
    }
    public static Map<String, String> getSelectedAccountDetails(Id recordId) {
         
        
        Map<String, String> accountDetails = new Map<String, String>();
     
        try {
            String selectedAccountJson = ICS_CTRL_OnboardingFormCreator.selectedAccount(recordId);
            Map<String, Object> selectedAccountData = (Map<String, Object>)JSON.deserializeUntyped(selectedAccountJson);
            accountDetails.put('selectedAccount', String.valueOf(selectedAccountData.get('Selected Account')));
            if (selectedAccountData.containsKey('Debit Card')) {
                accountDetails.put('debitCard', String.valueOf(selectedAccountData.get('Debit Card')));
            } else {
                accountDetails.put('debitCard', '');  
            }
            if (selectedAccountData.containsKey('Selected Currencies')) {
                accountDetails.put('selectedCurrencies', String.valueOf(selectedAccountData.get('Selected Currencies')));
            } else {
                accountDetails.put('selectedCurrencies', '');  
            }
            if (selectedAccountData.containsKey('Currencies you would like a debit card')) {
                accountDetails.put('debitCardCurrencies', String.valueOf(selectedAccountData.get('Currencies you would like a debit card')));
            } else {
                accountDetails.put('debitCardCurrenciess', '');  
            }

        } catch (Exception e) {
            LOGGER.error(e.getMessage(),'Error deserializing JSON');
            return new Map<String, String>();
        }
        return accountDetails;
        
    }
    public static Map<String, String> getCountryCodeMap() {
            Map<String, String> countryCodeMap = new Map<String, String>();
            
            try {
                Map<String, String> tempMap = ICS_CTRL_PreAppFormCreator.countryCodeMap();
                if(tempMap != null && !tempMap.isEmpty()) {
                    for(String key : tempMap.keySet()) {
                        String value = tempMap.get(key);
                        if(key != null && value != null) {
                            countryCodeMap.put(key.trim(), value.trim());
                        }
                    }
                }
            } catch(Exception e) {
                LOGGER.error(e.getMessage(),'Error in getCountryCodeMap');
            }
            
            return countryCodeMap; 
    }
    public static Map<String, String> getBusinessRecords() {
        Map<String, String> businessRecords = new Map<String, String>();
    
        try {
            SEL_ReferenceData data = new SEL_ReferenceData();
            List<AOB_ReferencedData__c> industryList = data.getReferencedDataName('ICS_Industry', '');
    
            if (industryList != null && !industryList.isEmpty()) {
                for (AOB_ReferencedData__c industry : industryList) {
                    if (industry.AOB_Code__c != null) {
                        businessRecords.put(industry.AOB_Code__c.trim(), industry.Name.trim());
                    }
                }
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), 'Error in getBusinessRecords');
        }
    
        return businessRecords;
    }
    private static Set<String> cachedMandatoryFields = null;

    public static List<IdentityDocument> getFilteredIdentityDocs() {
        List<IdentityDocument> filtered = new List<IdentityDocument>();
        
        if (!Schema.sObjectType.ICS_GBGManadatoryFields__mdt.isAccessible()) {
            return filtered;
        }
        
        if (cachedMandatoryFields == null) {
            cachedMandatoryFields = new Set<String>();
            for (ICS_GBGManadatoryFields__mdt field : [SELECT UIField__c FROM ICS_GBGManadatoryFields__mdt]) {
                if (field.UIField__c != null) {
                    cachedMandatoryFields.add(field.UIField__c);
                }
            }
        }
        
        if (!Schema.sObjectType.IdentityDocument.isAccessible()) {
            return filtered;
        }
        
        for (IdentityDocument doc : appFormData.identityDocumentRecords) {
            for (String field : cachedMandatoryFields) {
                if (doc.Name.contains(field)) {
                    filtered.add(doc);
                    break;
                }
            }
        }
        return filtered;
    }
      public static Map<Id, Account> getAccounts(Id recordId) {
        return appFormData.accountRecords;
    }

   
   

    Public static Map<String, Object> getPartyProfiles(Id recordId){
        Map<String, Object> result = new Map<String, Object>();
        result.put('partyProfileRecords', appFormData.partyProfileRecords);
        result.put('partyProfileRecordByType', appFormData.partyProfileRecordByType);
        result.put('partyProfileRecordByTypeadd', appFormData.partyProfileRecordByTypeadd);
        return result;
    }
       public static Map<String, Object> getAssessmentResponses(Id recordId) {
        Map<String, Object> result = initAssessmentResult();
        Map<String, String> questionConfig = getQuestionConfig();

        for (String question : questionConfig.keySet()) {
            result.put(question, '');
        }

        String operationValue = ICS_CTRL_Dashboard.getOperationAccountValue(recordId);
       if (operationValue != null) {
            result.put('operationAccount', operationValue);
        } else {
            result.put('operationAccount', '');
        }

        List<String>     additionalBalancesList = new List<String>();
        Map<Id, String>  prevEmpSalaryList      = new Map<Id, String>();
        Map<Id, String>  prevBonusList           = new Map<Id, String>();
        Map<Id, String>  monetryTrustList        = new Map<Id, String>();

        for (AssessmentQuestionResponse resp : appFormData.assessmentQuestions) {
            try {
                if (resp?.AssessmentQuestion?.Name == null || resp.Name == null || resp.ResponseText == null) 
                {
                    continue;
                }
                processAssessmentResponse(resp, result, additionalBalancesList, prevEmpSalaryList, prevBonusList, monetryTrustList, questionConfig);
            } catch (Exception e) {
                LOGGER.error(e.getMessage(), 'Error processing assessment response');
            }
        }

        result.put('additionalAccountBalance', additionalBalancesList);
        result.put('prevBonus',                prevBonusList);
        result.put('monetryTrust',             monetryTrustList);
        result.put('prevEmpSalary',            prevEmpSalaryList);
        return result;
    }

    private static Map<String, Object> initAssessmentResult() {
        return new Map<String, Object>{
            'mainAccountBalance'       => '',
            'additionalAccountBalance' => new List<String>(),
            'dualEmpSalary'            => '',
            'currEmpSalary'            => '',
            'prevEmpSalary'            => new List<String>(),
            'currBonus'                => '',
            'dualBonus'                => '',
            'prevBonus'                => new List<String>(),
            'monetryTrust'             => new List<String>(),
            'currEmpDetails'           => '',
            'businessOwnershipDetails' => '',
            'dualEmpDetails'           => '',
            'bankAccountCheckbox'      => '',
            'operationAccount'         => ''
        };
    }

   private static Map<String, String> getQuestionConfig() {
        return new Map<String, String>{
            'Employment StatusF'                                                                => CURRENT_EMPLOYMENT,
            'Frequency of the payments coming into the new account'                            => FUTURE_DEPOSITS,
            'Frequency of the payments leaving the new account'                                => FUTURE_DEPOSITS,
            'Please select your main tax residency country'                                    => TAX_CERTIFICATES,
            'Please select why the country you live in is different from the country'          => TAX_CERTIFICATES,
            'Do you have a Tax Identification Number (TIN)?'                                   => TAX_CERTIFICATES,
            'Are you related to a Trust structure?'                                            => TRUSTS,
            'Please confirm if you are sending your initial deposit by bank transfer'          => INITIAL_DEPOSIT,
            'Method in which you are making your initial deposit'                              => INITIAL_DEPOSIT,
            'Is this your own bank account?'                                                   => INITIAL_DEPOSIT,
            'Please state who the account belongs to?Initial'                                  => INITIAL_DEPOSIT,
            'What is their relationship to you?Initial'                                        => INITIAL_DEPOSIT,
            'What is the reason for their transfer?Initial'                                    => INITIAL_DEPOSIT,
            'Which address should the Visa Debit Card be delivered to?'                        => SELECTED_ACCOUNT,
            'Do you have any other business interests?'                                        => OTHER_BUSINESS,
            'Is your correspondence address the same as your current residential address?'     => CORRESPONDENCE_ADDRESS,
            'Relationship to this postal address'                                              => CORRESPONDENCE_ADDRESS,
            'Other relationship'                                                               => CORRESPONDENCE_ADDRESS,
            'Please confirm if you were previously employed'                                   => PREVIOUS_EMPLOYMENT,
            'Previous employment status'                                                       => PREVIOUS_EMPLOYMENT,
            'Do you receive any income from this interest?'                                    => OTHER_BUSINESS,
            'Are you a business owner?'                                                        => BUSINESS_OWNERSHIP,
            'Is this a cash-based business?'                                                   => BUSINESS_OWNERSHIP,
            'Value of the businessCurrency'                                                    => BUSINESS_OWNERSHIP,
            'Are you the sole owner of the business?'                                          => BUSINESS_OWNERSHIP,
            'Do you have any additional bank accounts other than the main one provided?'       => BANK_DETAILS,
            'Expected annual/yearly turnover for the accountCurrency'                          => FUTURE_DEPOSITS,
            'Expected annual/yearly turnover for the account'                                  => FUTURE_DEPOSITS,
            'Amount of your initial depositCurrency'                                           => INITIAL_DEPOSIT,
            'Amount of your initial deposit'                                                   => INITIAL_DEPOSIT,
            'Current Account BalanceCurrency'                                                  => ADDITIONAL_BANK,
            'Select years*'                                                                    => ASSETS_INCOME,
            'Is your Country of Residence your main tax residency?'                            => TAX_CERTIFICATES,
            'Please provide details'                                                           => TAX_CERTIFICATES,
            'Are you a tax resident in any other country?'                                     => TAX_CERTIFICATES,
            'Do you have a Tax Identification Number?M'                                        => TAX_CERTIFICATES,
            'Do you have a Tax Identification Number?S'                                        => TAX_CERTIFICATES,
            'Are you a US Citizen, US Tax Resident, US passport holder or Green Card Holder?' => TAX_CERTIFICATES,
            'Are you aware of your obligations to the US Tax Authorities?'                     => TAX_CERTIFICATES,
            'Have you received independent tax advice in respect of US tax affairs?'           => TAX_CERTIFICATES,
            'Are your US tax affairs up to date?'                                              => TAX_CERTIFICATES,
            'If you are not resident in the US, do you intend to return to the US as a reside'=> TAX_CERTIFICATES,
            'US residence type'                                                                => TAX_CERTIFICATES,
            'Will the future deposits be funded by the same bank as your initial deposit?'     => FUTURE_DEPOSITS,
            'Please state who the account belongs to?'                                         => FUTURE_DEPOSITS,
            'What is their relationship to you?'                                               => FUTURE_DEPOSITS,
            'What is the reason for their transfer'                                            => FUTURE_DEPOSITS,
            'Other reason'                                                                     => ACCOUNT_PURPOSE,
            'Other purpose'                                                                    => ACCOUNT_PURPOSE,
            'Relationship details'                                                             => CONTACT_DETAILS,
            'Please confirm if this is your only employment'                                   => CURRENT_EMPLOYMENT,
            'consent1'                                                                         => 'Instructing the Bank',
            'Select the account the deposit will be coming from'                               => INITIAL_DEPOSIT,
            'Do you have an alternative contact number?'                                       => CONTACT_DETAILS,
            'We note your dialing code is not connected to your country of residence'          => CONTACT_DETAILS,
            'I would like to be kept informed about products, services and additional benefits that may be of interest to me.' => 'Data Protection'
        };
    }

    private static void processAssessmentResponse(
        AssessmentQuestionResponse resp,
        Map<String, Object>        result,
        List<String>               additionalBalancesList,
        Map<Id, String>            prevEmpSalaryList,
        Map<Id, String>            prevBonusList,
        Map<Id, String>            monetryTrustList,
        Map<String, String>        questionConfig
    ) {
        String qName = resp.AssessmentQuestion.Name;
        String rName = resp.Name;
        String rText = resp.ResponseText;

        if (processAccountBalance(qName, rName, rText, result, additionalBalancesList)) 
        {
            return;
        }
        if (processSalary(qName, rName, rText, result, prevEmpSalaryList))           
        {
            return;
        }
        if (processBonus(qName, rName, rText, result, prevBonusList)) 
        {
            return;
        }
        if (processEmploymentContracts(qName, rName, rText, result)) 
        {
            return;
        }
        processTrust(qName, rName, rText, monetryTrustList);
        processBankAccountCheckbox(qName, rText, result);
        processGenericQuestion(qName, rName, rText, result, questionConfig);
    }

    private static Boolean processAccountBalance(
        String qName, String rName, String rText,
        Map<String, Object> result, List<String> additionalBalancesList
    ) {
        if (!qName.contains('Current Account Balance')) 
        {
            return false;
        }
        if (rName.startsWith('Bank Details:')) {
            result.put('mainAccountBalance', rText);
        } else if (rName.startsWith('Additional Bank Accounts:')) {
            additionalBalancesList.add(rText);
        }
        return true;
    }

    private static Boolean processSalary(
        String qName, String rName, String rText,
        Map<String, Object> result, Map<Id, String> prevEmpSalaryList
    ) {
        if (!qName.contains('Gross Annual SalaryCurrency')) {
            return false;
        }
        if (rName.startsWith(CURR_EMP_PREFIX)) {
            result.put('currEmpSalary', rText);
        } else if (rName.startsWith(DUAL_EMP_PREFIX)) {
            result.put('dualEmpSalary', rText);
        } else if (rName.startsWith(PREV_EMP_PREFIX)) {
            putByIdSuffix(rName, PREV_EMP_PREFIX, rText, prevEmpSalaryList);
        }
        return true;
    }
    
    private static Boolean processBonus(
        String qName, String rName, String rText,
        Map<String, Object> result, Map<Id, String> prevBonusList
    ) {
        if (!qName.contains('Bonuses/Commissions received per annumCurrency')) {
            return false;
        }
        if (rName.startsWith(CURR_EMP_PREFIX)) {
            result.put('currBonus', rText);
        } else if (rName.startsWith(DUAL_EMP_PREFIX)) {
            result.put('dualBonus', rText);
        } else if (rName.startsWith(PREV_EMP_PREFIX)) {
            putByIdSuffix(rName, PREV_EMP_PREFIX, rText, prevBonusList);
        }
        return true;
    }

    private static Boolean processEmploymentContracts(
        String qName, String rName, String rText,
        Map<String, Object> result
    ) {
        if (!qName.contains('Do you/your employment have any contracts with public authorities/governments/s?')) {
            return false;
        }
        if (rName.startsWith(CURRENT_EMPLOYMENT)) {
            result.put('currEmpDetails', rText);
        } else if (rName.startsWith(BUSINESS_OWNERSHIP)) {
            result.put('businessOwnershipDetails', rText);
        } else if (rName.startsWith('Dual Employment Details')) {
            result.put('dualEmpDetails', rText);
        }
        return true;
    }
    private static void processTrust(
        String qName, String rName, String rText,
        Map<Id, String> monetryTrustList
    ) {
        if (qName.contains('Annual Monetary ValueCurrency') && rName.startsWith('Trusts:')) {
            putByIdSuffix(rName, 'Trusts:', rText, monetryTrustList);
        }
    }

    private static void processBankAccountCheckbox(String qName, String rText, Map<String, Object> result) {
        if (qName.contains('I don\'t have a bank account')) {
            result.put('bankAccountCheckbox', rText);
        }
    }

    private static void processGenericQuestion(
        String qName, String rName, String rText,
        Map<String, Object> result, Map<String, String> questionConfig
    ) {
        for (String question : questionConfig.keySet()) {
            if (qName.contains(question) && rName.contains(questionConfig.get(question))) {
                result.put(question, rText);
                break;
            }
        }
    }

    private static void putByIdSuffix(String rName, String prefix, String rText, Map<Id, String> targetMap) {
        String idPart = rName.substring(prefix.length());
        if (String.isNotBlank(idPart) && idPart.length() == 18) {
            try {
                targetMap.put(Id.valueOf(idPart), rText);
            } catch (Exception e) {
                LOGGER.error('Invalid ID format: ' + idPart);
            }
        }
    }

    
    
    public static Map<String, Object> getContactPointPhone(Id recordId) {
        Map<String, Object> result = new Map<String, Object>();
        ContactPointPhone emptyPhone = new ContactPointPhone();
        result.put('mainPhone', emptyPhone);
        result.put('alternativePhone', emptyPhone);
        result.put('IsAlternate', 'No');
        
        if (appFormData.PhoneRecords != null) {
            for (ContactPointPhone phone : appFormData.PhoneRecords) {
                if (phone.IsPrimary) {
                    result.put('mainPhone', phone);
                } else {
                    result.put('alternativePhone', phone);
                    result.put('IsAlternate', 'Yes');
                }
            }
        }
        
        return result;
    }
    /**
     * @description generate ApplicantForm PDF document
     * @param recordId
     * @return contentVersion ID
     */

    public static Id generatePdf(String recordId, String agreementFileName) {
        PageReference objPagePdf = Page.ICS_ApplicantForm_PDF;
        objPagePdf.getParameters().put('Id', recordId);
        if (!Test.isRunningTest()) {
            strPdfBody = objPagePdf.getContent();
        }
    
        SEL_Account selectorAccount = new SEL_Account();
        Account accData = selectorAccount.selectById(recordId);
        String title = accData.FirstName + '-' + accData.LastName + '_Mandate/Application Form_' + System.today();
    
        ContentVersion objContentVersion = new ContentVersion();
        objContentVersion.ContentLocation = 'S';
        objContentVersion.PathOnClient    = agreementFileName + '.pdf';
        objContentVersion.Title           = title;
        objContentVersion.VersionData     = strPdfBody;
        objContentVersion.DocumentDate__c = System.today();
        objContentVersion.DocumentType__c = 'Mandate/Application Form';
    
        if (Schema.sObjectType.SBO_Ping_Registration_Site__mdt.isAccessible()) {
            SBO_Ping_Registration_Site__mdt pingInfo = [
                SELECT Profile__c,Network_Id__c, IFA_Profile__c,Username_Suffix__c 
                FROM SBO_Ping_Registration_Site__mdt 
                WHERE DeveloperName = 'ICS_Account_Onboarding'
            ];
            objContentVersion.networkid = pingInfo.Network_Id__c;
        }
    
        if (Schema.sObjectType.ContentVersion.isCreateable()) {
            insert objContentVersion;
        }
    
        if (Schema.sObjectType.ContentVersion.isAccessible()) {
            objContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :objContentVersion.Id];
        }
    
        Id idRecord = (Id) recordId;
        List<PartyProfile> partyProfileList = new List<PartyProfile>();
        if ('Account' == idRecord.getSobjectType().getDescribe().getName()) {
            SEL_PartyProfile selectPartyProfile = new SEL_PartyProfile();
            partyProfileList = selectPartyProfile.selectByAccountId(idRecord);
        }
    
        if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            ContentDocumentLink objAccountDocumentLink = new ContentDocumentLink();
            objAccountDocumentLink.LinkedEntityId    = recordId;
            objAccountDocumentLink.ContentDocumentId = objContentVersion.ContentDocumentId;
            objAccountDocumentLink.shareType         = 'V';
            insert objAccountDocumentLink;
    
            if (!partyProfileList.isEmpty()) {
                ContentDocumentLink objDocumentLink = new ContentDocumentLink();
                objDocumentLink.LinkedEntityId    = partyProfileList[0].Id;
                objDocumentLink.ContentDocumentId = objContentVersion.ContentDocumentId;
                objDocumentLink.shareType         = 'V';
                insert objDocumentLink;
            }
        }
    
        return objContentVersion.Id;
    }
    /**
     * @description invocableMethod to generate ApplicantFormPDF from Flow
     */
    @InvocableMethod(label='Generate PDF' description='Return content document link' category='Opportunity')
    public static List<Results> ApplicantFormPDF(List<Requests> requestList) {
        List<Results> results = new List<Results>();
        Results res = new Results();
        res.contentDocumentId = generatePdf(requestList[0].recordID, requestList[0].agreementFileName);
        results.add(res);

        return results;
    }
  
    /**
     * @description 
     */
    public class Results {
        @InvocableVariable(label = 'contentDocumentId')
        public Id contentDocumentId;
    }
    /**
     * @description 
     */
    public class Requests {
        @InvocableVariable(label = 'recordID')
        public Id recordID;
        @InvocableVariable(label = 'agreementFileName')
        public String agreementFileName;
    }   
}