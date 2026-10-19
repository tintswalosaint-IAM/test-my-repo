/**
* @description class used as controller for  SBO-UK onBoardingApplication Feature
*
* Story:SFP-30128
*
* @author Ikyatha Naidu 
*
* @date May 2023
* @last modified on  : 09-12-2025
* @last modified by  : Ramya Gurram
* @Modification Description : SFP-30128 class used as controller for SBO-UK onBoardingApplication

*************************************************************************************************
* @last modified on  : 09-12-2025
* @last modified by  : Ramya
* @Modification Description : SFP-52215 added new methods  for getting Industry Records

*/

public without sharing class ICS_CTRL_OnboardingFormCreator {  
    Public static Map<String,List<String>> lookupFields = new Map<String,List<String>>();
    Public static Map<string,string> linkedMap = new Map<String,String>();
    Public static Map<string,string> fecthIdMap = new Map<String,String>();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_OnboardingFormCreator');
/**
* @description To retrieve dynamic data based on the provided parameters and returns it as a JSON response.
* @param parentId The ID of the parent record.'
* @param screenName The name of the screen.
* @param sectionName The name of the section.
* @return JSON response containing the dynamic data.
*/
    @AuraEnabled
    Public static string fetchDynamicData(string parentId,string screenName,string sectionName,string type) {
        try{
            // Fetch AccountId from User record (optimize this query if possible)
            String accountId = [SELECT Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Contact.AccountId;

            if (String.isNotBlank(accountId)) {
                parentId = accountId;
        }else{
                // Handle the case where AccountId is not found for the user
                return '{}'; // Or throw an exception, depending on your requirements
        }

            // Use a switch statement for better readability and maintainability
            switch on sectionName {
                when 'Assets and Income' {
                    return ICS_CTRL_FecthOnboardingDetailsAI.fetchDynamicData(parentId, screenName, sectionName, null);
                } when 'Future Deposits' {
                    return ICS_CTRL_FecthOnboardingDetailsFD.fetchAssestListedFunds(parentId, screenName, sectionName); 
                } when 'Trusts' {
                    return ICS_CTRL_FetchTrustDataProcessor.prepareJsonForUI(parentId);
                } when 'Tax Certificates' {
                    return ICS_CTRL_Fetch_TaxDetails.fetchTaxDetails(parentId);
                } when else {
                    return ICS_CTRL_FecthOnboardingDetails.fetchDynamicData(parentId, screenName, sectionName, type);
    }
            }
        } catch (Exception exc) {
            LOGGER.error(exc.getMessage(), 'ICS_CTRL_OnboardingFormCreator.fetchDynamicData');
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
/**
** @description update ApplicationForm submit
* @param tinCountryCode - countrySelected
*@return JSON string containing validation pattern.
*
*/
    @AuraEnabled
    public static String submitApplicationForm(String parentId) {
        try {
             
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List<ApplicationForm> appData = selectorApplicationForm.selectByAccountId(parentId);
            if(appData.size()>0){
                if (!appData.isEmpty() && appData[0].stage == 'Awaiting Form Filling') {
                    List<ApplicationForm> allFormData = selectorApplicationForm.selectByOpportunityIds(new List<Id>{appData[0].opportunityId});
                    updateApplicationForm(appData[0].Id, 'Awaiting Signature', 'Onboarding');
                    disableDocumentUpload(parentId);
                    Integer awaitingSignatureCount = 1;
                    for (ApplicationForm singleData : allFormData) {
                        if (singleData.stage == 'Awaiting Signature') {
                            awaitingSignatureCount++;
                        }
                    }

                    if (awaitingSignatureCount == allFormData.size()) {
                        Opportunity opp = new Opportunity(Id = appData[0].opportunityId, ICS_AllApplicationsCompleted__c = true);
                        update opp;
                        
                    }
                    SEL_Opportunity oppSelector= new SEL_Opportunity();
                    opportunity oppData= oppSelector.selectById(appData[0].opportunityId);
                    if(oppData.Required_Approval_Processes__c == null){
                        oppData.Required_Approval_Processes__c ='';
                    }
                    if (oppData.LeadSource == 'Staff' && String.isNotBlank(oppData.Required_Approval_Processes__c) 
                        && oppData.Required_Approval_Processes__c.contains('Need FAIS Approval;') 
                        && !oppData.Required_Approval_Processes__c.contains('FAIS Approval Confirmed;'))
                        {
                        
                        try {
                            // Load the Static Resource 
                            List<StaticResource> resourceList = [
                                SELECT Body 
                                FROM StaticResource 
                                WHERE Name = 'ICS_Statutory_Disclosure_PDF' 
                                LIMIT 1
                            ];
                            if(!resourceList.isEmpty())
                            {
                                Blob fileBody = resourceList[0].Body;
                                // Prepare file metadata
                                String formattedDocumentType = 'KYC FAIS';
                                String dataToday = String.valueOf(Date.today());
                                String fileExtension = '.pdf';
                                String fileName = oppData.Name+ '_' + formattedDocumentType + '_' + dataToday;

                                // Insert ContentVersion (this auto-creates a ContentDocument)
                                ContentVersion versionData = new ContentVersion();
                                versionData.Title = fileName;
                                versionData.PathOnClient = fileName + fileExtension;
                                versionData.VersionData = fileBody;
                                versionData.DocumentType__c= 'KYC FAIS';
                                versionData.DocumentDate__c = Date.today();
                                insert versionData;

                                //Query the inserted ContentVersion to get ContentDocumentId
                                versionData = [
                                    SELECT Id, ContentDocumentId 
                                    FROM ContentVersion 
                                    WHERE Id = :versionData.Id 
                                    LIMIT 1
                                ];
                                //Link the file to the Account
                                ContentDocumentLink dLink = new ContentDocumentLink();
                                dLink.ContentDocumentId = versionData.ContentDocumentId;
                                dLink.LinkedEntityId = appData[0].AccountId; // Account Id
                                dLink.ShareType = 'V'; 
                                dLink.Visibility = 'AllUsers'; 
                                insert dLink;
                                oppData.Required_Approval_Processes__c += 'FAIS Approval Confirmed;;';
                                update oppData;
                            }
                            
                        } catch (Exception e) {
                            LOGGER.error('ERROR: ' + e.getMessage());
                            throw new AuraHandledException('Failed to attach PDF: ' + e.getMessage());
                        }

                    }
                    if(oppData.LeadSource !=null){
                        return appData[0].AccountId;
                    }
                    else{
                        return null;
                    }
                }
            }
            return null;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    @TestVisible
    public static Boolean disableDocumentUpload(String parentId) {
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId,ICS_Constants.SBO_RECNAME);
        
       
        Decimal sumTotalAmount = fetchAggregateSum(
            
            profileData.Id,
            'Source of Funds'
        );
        String defaultCurrency = UserInfo.getDefaultCurrency();
        Map<String, Decimal> conversionMap = new Map<String, Decimal>();
        for (CurrencyType ct :  [SELECT IsoCode, ConversionRate FROM CurrencyType where (IsoCode=:defaultCurrency or IsoCode= 'GBP') ]) {
            conversionMap.put(ct.IsoCode, ct.ConversionRate);
        }
        Decimal sumInitialDeposit = fetchExpectedRevenue(profileData.accountId,'Initial Deposit');
        decimal expectedRevenue = fetchExpectedRevenue(profileData.accountId,'Future Deposits');
        expectedRevenue = (expectedRevenue / conversionMap.get('GBP')) *  conversionMap.get(defaultCurrency);
        sumInitialDeposit = (sumInitialDeposit / conversionMap.get('GBP')) *  conversionMap.get(defaultCurrency);
        Decimal totalSum = sumInitialDeposit + sumTotalAmount + expectedRevenue;
        Decimal thresholdInitialDeposit = 500000;
        Decimal thresholdTotalSum = 150000;
        
        
         thresholdInitialDeposit = (thresholdInitialDeposit / conversionMap.get('GBP')) *  conversionMap.get(defaultCurrency);
         thresholdTotalSum = (thresholdTotalSum / conversionMap.get('GBP')) *  conversionMap.get(defaultCurrency);
     
       
        return updateApplicationForm(profileData.accountId, sumInitialDeposit > thresholdInitialDeposit || totalSum > thresholdTotalSum, true);
    }
    
    private static Decimal fetchAggregateSum( Id partyProfileId, String type) {
        List<AggregateResult> aggregateResult = [
            SELECT  SUM(Total_Amount__c) sumTotalAmount,
            SUM(Sale_Amount__c) sumSaleAmount, SUM(Pension_Amount__c) sumPensionAmount,
            SUM(Funds_Received__c) sumFundsReceived
            FROM Party_Assets_Funds__c
            WHERE Party_Profile__c = :partyProfileId
            AND RecordType.name = :type AND Is_Future_Fund__c=true
            GROUP BY Party_Profile__c
        ];

        Decimal result = 0;
        if (!aggregateResult.isEmpty()) {
            result += (aggregateResult[0].get('sumTotalAmount') != null) ? (Decimal)aggregateResult[0].get('sumTotalAmount') : 0;
            result += (aggregateResult[0].get('sumSaleAmount') != null) ? (Decimal)aggregateResult[0].get('sumSaleAmount') : 0;
            result += (aggregateResult[0].get('sumPensionAmount') != null) ? (Decimal)aggregateResult[0].get('sumPensionAmount') : 0;
            result += (aggregateResult[0].get('sumFundsReceived') != null) ? (Decimal)aggregateResult[0].get('sumFundsReceived') : 0;
        }
        return result;
    }
    @TestVisible
    private static decimal fetchExpectedRevenue(Id accountId,string sectionName) {
        List<AssessmentQuestionResponse> responseList = new SEL_AssesmentQuestionResponse().selectByParentIdAndSectionName(accountId, sectionName);
        for (AssessmentQuestionResponse responseData : responseList) {
            if (responseData.AssessmentQuestion.Name == 'Expected annual/yearly turnover for the account' || responseData.AssessmentQuestion.Name == 'Amount of your initial deposit') {
                return decimal.valueOf(responseData.ResponseText);
            }
        }
        return 0;
    }

    private static Boolean updateApplicationForm(Id applicationFormId, String stage, String usageType) {
        ApplicationForm formData = new ApplicationForm(Id = applicationFormId, Stage = stage, UsageType = usageType);
        update formData;
        return true;
    }
    @testvisible
    private static Boolean updateApplicationForm(Id accountId, Boolean conditionMet, Boolean enhancedDueDiligence) {
        SEL_ApplicationForm formSelector = new SEL_ApplicationForm();
        List<ApplicationForm> formList = formSelector.selectByAccountIds(new Set<Id>{accountId});
        if (conditionMet && !formList.isEmpty()) {
            ApplicationForm updateForm = formList[0];
            updateForm.Enhanced_Due_Diligence_Required__c = enhancedDueDiligence;
            update updateForm;
            return false;
        }
        return true;
    }
    /**
** @description fetch ValidationPattern based on country
* @param tinCountryCode - countrySelected
*@return JSON string containing validation pattern.
*
*/
    @AuraEnabled
    public static string returnTINPatternValidations(string tinCountryCode) {
        try {
            string tinCountryName = ICS_CTRL_PreAppFormCreator.countryCodeMap(tinCountryCode);
            string jsonResponse='';
            Map<String, ics_TINValidations__mdt> mandatoryInfo = ics_TINValidations__mdt.getAll();
            Map<String, List<ics_TINValidations__mdt>> dataMap = new Map<String,List<ics_TINValidations__mdt>>();
            for(String mandatoryKey : mandatoryInfo.keySet()) {
                if(mandatoryInfo.get(mandatoryKey).Country__c != null) {
                    if(dataMap.containskey(mandatoryInfo.get(mandatoryKey).Country__c.tolowercase())) {
                      dataMap.get(mandatoryInfo.get(mandatoryKey).Country__c.tolowercase()).add(mandatoryInfo.get(mandatoryKey));

                    }
                    else {
                        dataMap.put(mandatoryInfo.get(mandatoryKey).Country__c.tolowercase(),new List<ics_TINValidations__mdt>{mandatoryInfo.get(mandatoryKey)});
                    }
                }
            }
            if(dataMap.containskey(tinCountryName.tolowercase())) {
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartArray();
                for(ics_TINValidations__mdt mandatoryData: dataMap.get(tinCountryName.tolowercase())) {
                    gen.writeStartObject();
                    gen.writeStringField('country', mandatoryData.Country__c);
                    gen.writeStringField('uiField',mandatoryData.UI_Field__c);
                    gen.writeStringField('validationPattern',mandatoryData.Validation_Pattern__c);
                    gen.writeStringField('validationMessage',mandatoryData.Validation_Message__c);
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                jsonResponse = gen.getAsString();
            } else {
                jsonResponse = '{}';
            }
            return jsonResponse;
        }  catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    /**
* @description To fetch the current application ID associated with the user.
* @return The ID of the current application or an empty string if not found.
*/
    @AuraEnabled
    Public static string fetchCurrentApplictaionId() {
        try{
        String accountId='';
        map<string,string> userMap = new Map<string,string>();
        for(user userData : [SELECT id, contact.accountid from user where id =: userinfo.getuserid()]) {
            userMap.put(userData.id,userData.contact.accountid);
        }
        if(userMap.containskey(userinfo.getuserId())) {
            List<ApplicationForm> formDataList =[select id,opportunityId,accountid from applicationform
                                                 where accountid=:userMap.get(userinfo.getuserId())
                                                 and opportunity.iswon =false and opportunity.isclosed=false];
            if(formDataList.size() >0) {
                accountId = formDataList[0].accountid;
            }
        }
        else{
            accountId='';
        }
        return accountId;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To fetch the current application ID and associated product code for the user.
* @return JSON string containing the account ID and product code, or an empty string if not found.
*/
    @auraEnabled
    Public static string fetchCurrentApplictaionIdWithProduct() {
        try{
        String accountId='';
        String opportunityId = '';
        String productCode = '';

        map<string,string> userMap = new Map<string,string>();
        for(user userData : [SELECT id, contact.accountid from user where id=:userinfo.getuserid()]) {
            userMap.put(userData.id,userData.contact.accountid);
        }
        if(userMap.containskey(userinfo.getuserId())) {
            sel_applicationform formSelector= new sel_applicationform();
            List<ApplicationForm> formDataList  = formSelector.selectByAccountIds(new set<id>{userMap.get(userinfo.getuserId())});

            if(formDataList.size() != 0) {
                accountId = formDataList[0].accountid;
                opportunityId  = formDataList[0].opportunityId;
            }
            list<opportunitylineitem> products=[select id,product2.Name,product2.ProductCode from opportunitylineitem
                                                where OpportunityId=:opportunityId];
            if(products.size() != 0 ) {
                string productId = products[0].Product2.Id;
                SEL_Product2 selectorProduct = new SEL_Product2();
                List<Product2> productData = selectorProduct.selectById(productId);
                productCode = productData[0].ProductCode;
            }
            map<string,string> data = new map<string,string>();
            data.put('accountId',accountId);
            data.put('productCode',productCode);
            return JSON.serialize(data);
        }
        else {
            accountId='';
        }
        return accountId;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To fetch the country code of residence associated with the specified account ID.
* @param accId The ID of the account for which the country of residence is to be fetched.
* @return The country code of residence, or null if not found.
*/
    @AuraEnabled
    public static string fetchCountryofResidence(string accId) {
        try{
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile  profileData =selectorPartyProfile.selectByAccountAndRecordType(accId,ICS_Constants.SBO_RECNAME);
        map<string,string> countrycodeMap = new map<string,string>();
        countryCodeMap = countryCodeMap();
        String countryCodeFetch;
        countryCodeFetch = countrycodeMap.get((string)profileData.Country_of_Residence__c);
        return countryCodeFetch;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    /**
* @description To fetch the Date of Birth associated with the specified account ID.
* @param accId The ID of the account for which the Date of Birth is to be fetched.
* @return The Date of Birth as a String (or null if not found).
*/
@AuraEnabled
public static String fetchDOB(String accId) {
    try {

        SEL_Account selectorAccount = new SEL_Account();
        Account accountData = selectorAccount.selectById(accId);

        if (accountData != null && accountData.Date_of_Birth__c!= null) {
            return String.valueOf(accountData.Date_of_Birth__c);
        }

        return null;
    } catch (Exception exc) {
        LOGGER.error('Error in fetchDOB: ' + exc.getMessage());
        throw new AuraHandledException('Unable to fetch Date of Birth.');
    }
}


    /**
* @description To fetch the country code associated with the specified account ID.
* @param accId The ID of the account for which the country code is to be fetched.
* @return The country code, or null if not found.
*/
    @AuraEnabled
    public static string fetchCountryCode(string accId) {
        try{
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile  profileData =selectorPartyProfile.selectByAccountAndRecordType(accId,ICS_Constants.SBO_RECNAME);
        String countryCodeFetch;
        countryCodeFetch = (string)profileData.Country_of_Residence__c;
        return countryCodeFetch;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description to perform DML operations for onboarding information based on the provided parameters.
* @param jSONString The JSON string containing the data to be processed.
* @param screenName The name of the screen associated with the onboarding information.
* @param sectionName The name of the section within the screen.
* @param parentId The ID of the parent entity to which the onboarding information belongs.
* @param dmlType The type of DML operation to be performed (e.g., 'insert', 'update', 'delete').
*/
    @AuraEnabled
    Public static void performOnboardingDMLInfo(string jSONString,string screenName,string sectionName,
                                                string parentId ,string dmlType ) {
                                                   
                                                    try{
                                                        if(sectionName == 'Additional Bank Accounts'){
                                                            ICS_CTRL_DMLAdditionalBankAccounts.createPartyAssetFunds(jSONString,parentId);
                                                            return;
                                                        }
                                                        ICS_CTRL_DML_OnboardingDetails.processData(jSONString,screenName,sectionName,ParentId);
                                                    } catch (Exception exc) {
                                                        LOGGER.error(exc.getmessage());
                                                        throw new AuraHandledException(exc.getMessage());
                                                    }
                                                } 

    /**
* @description To retrieve country codes and their corresponding labels.
* @return Map where the keys are country codes and the values are the corresponding country names.
*/
    Public static Map<string,string> countryCodeMap() {
        map<string,string> countrycodeMap = new map<string,string>();
        Schema.DescribeFieldResult fieldResult = partyprofile.Country_of_Residence__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            countrycodeMap.put(f.getValue(),f.getLabel());
        }
        return countrycodeMap;
    }

    /**
* @description To check if the provided parent ID corresponds to a joint applicant.
* @param parentId The ID of the parent record.
* @return JSON string indicating whether the applicant is joint or primary, and whether they have a role.
*/

    @AuraEnabled
    Public static string checkisJoint(string parentId) {
        try{
        string isJoint='false';
        string isPrimary='false';
        SEL_Applicant selectorApplicantForm = new SEL_Applicant();
        Applicant appData = selectorApplicantForm.selectByAccountId(parentId);

        if(appData == null) {
            isJoint = 'false';
            isPrimary ='false';
        }
        if(appData.role =='Primary Applicant' ) {
            isJoint = 'true';
            isPrimary ='true';
        }
        if(appData.role =='Co-Applicant') {
            isJoint = 'true';
            isPrimary ='false';
        }
        if(appData.role =='') {
            isJoint = 'false';
            isPrimary ='true';
        }
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('isPrimary',isPrimary );
        jsonGen.writeStringField('isJoint', isJoint);
        jsonGen.writeEndObject();

        // Get the JSON string
        String jsonString = jsonGen.getAsString();
        return jsonString;
        } catch (Exception exc) {
            LOGGER.error('Error in checkisJoint: '+exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To fetch the Account record associated with the provided parent ID.
* @param parentId The ID of the parent record.
* @return The Account record associated with the provided parent ID.
*/
    @AuraEnabled
    Public static Account fetchJointPersons(string parentId) {
        try{
        SEL_Account selectorAccountInfo = new SEL_Account();
        Account acc= selectorAccountInfo.selectById(parentId);
        
        return acc;
        } catch (Exception exc) {
            LOGGER.error(exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }

    }

    /**
* @description To delete the address record identified by the provided ID.
* @param delId The ID of the record to be deleted.
*/
    @AuraEnabled
    public static void deleteAddress(id delId) {
        try{
        string objectName = delId.getSObjectType().getDescribe().getName();
        SObjectType objectType = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();

        SObject sObjectToDelete = objectType.newSObject();
        sObjectToDelete.put('Id', delId);
        delete sObjectToDelete;
        } catch (Exception exc) {
            LOGGER.error('Error in deleteAddress: '+exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To retrieve information related to the selected account identified by the provided parent ID.
* @param parentId The ID of the parent account.
* @return JSON string containing various data points, including the product name associated with the selected account, debit card information, currencies for which a debit card is desired, and selected currencies.
*/
    @AuraEnabled
    Public static string selectedAccount(string parentId) {
        try{
        map<string,object> returnData=new map<string,object>();
        Map<id,object> formMap=new map<id,object>();
        set<id> oppIds=new set<id>();
        List<ApplicationForm> formDataList =[select id,opportunityId,accountid from applicationform
                                             where accountid=:parentId];
        for(ApplicationForm form:formDataList){
            formMap.put(form.id,form);
            oppIds.add(form.opportunityId);
        }
        list<opportunitylineitem> products=[select id,product2.Name from opportunitylineitem where OpportunityId IN:oppIds];
            if(products.size()>0){
        returnData.put('Selected Account',products[0].product2.Name);
            }

        list<ApplicationFormProduct> appFormProductList=[select id,Product.ProductCode,ApplicationFormId
                                                         from ApplicationFormProduct where ApplicationFormId=:formMap.keyset()];
        set<string>prodCodes=new set<string>();
        set<string>cardValues=new set<string>();

        for(ApplicationFormProduct prod:appFormProductList) {
            if(prod.Product.ProductCode.contains('Card')) {
                cardValues.add(prod.Product.ProductCode);
            } else if(prod.Product.ProductCode.contains('Visa')) {
                returnData.put('Debit Card',prod.Product.ProductCode);
            } else {
                prodCodes.add(prod.Product.ProductCode);
            }
        }
        returnData.put('Currencies you would like a debit card',cardValues);
        returnData.put('Selected Currencies',prodCodes);

        string jsonString=JSON.serialize(returnData);
        return jsonString;
          } catch (Exception exc) {
            LOGGER.error('Error in selectedAccount: '+exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }

    /**
* @description To retrieve bank account information associated with the provided parent ID.
* @param parentId The ID of the parent account.
* @return JSON string containing bank account names and numbers.
*/
    @AuraEnabled
    Public static string getBankAccounts(string parentId) {
        try{
        SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
        PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId,ICS_Constants.SBO_RECNAME);
        SEL_PartyAssetFunds assets=new SEL_PartyAssetFunds();
        list< Map<string,object>> bankAccountData=new list< Map<string,object>>();

        list<Party_Assets_Funds__c> partyAssetFundList= assets.selectAssetFundsByRecordType(profileData.id,new List<string>{'Bank Account'},'Additional');
         partyAssetFundList.addall(assets.selectAssetFundsByRecordType(profileData.id,new List<string>{'Bank Account'},'PrimaryAdditional'));

        List<AssessmentQuestionResponse> responseList = new List<AssessmentQuestionResponse>();
        SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
        responseList = selectorAssessmentqueResponse.selectByParentIdAndSectionName(parentId,'Bank Details');
        string bankAccountValue='FALSE';
        for(AssessmentQuestionResponse repsonseData: responseList ){
            if(repsonseData != null){
                if(repsonseData.AssessmentQuestion.QuestionText =='I don\'t have a bank account'){
                    bankAccountValue = repsonseData.responsetext;
                }
            }
        }
        if(bankAccountValue == 'FALSE'){
            for(Party_Assets_Funds__c fund:partyAssetFundList){
                Map<string,object> returnData=new Map<string,object>();
                returnData.put('recordId',fund.id);
                returnData.put('value',fund.Bank_Name__c+'-'+fund.Bank_Account_Number__c);
                bankAccountData.add(returnData);
            }
        }
        string picklistValues=JSON.serialize(bankAccountData);
        return picklistValues;
            } catch (Exception exc) {
            LOGGER.error('Error in getBankAccounts: '+exc.getmessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
           /**
* @description sets account's section name
* @param parentId The ID of the parent account.
* @param screen need to update with this screen name
*/
    @AuraEnabled
    public static void updateSectionName(string parentId,String screen){
        try{
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            list<ApplicationForm> appData = selectorApplicationForm.selectByAccountId(parentId);
            if(appData.isEmpty() ){
                throw new AuraHandledException('Unable to find account Id '+parentId);
            }
            if(!appData.isEmpty()){
                    appData[0].Section_Name__c = screen;
            }
            update appData;
        }
        catch (Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'ICS_CTRL_OnboardingFormCreator: updateSectionName',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }

    }
              /**
* @description sets account's section name
* @param parentId The ID of the parent account.
*/
    @AuraEnabled
    public static string getSectionName(string parentId){
        String screen;
        try{
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            list<ApplicationForm> appData = selectorApplicationForm.selectByAccountIds(new set<id>{parentId});
            if(appData.isEmpty() ){
                throw new AuraHandledException('Unable to find account Id '+parentId);
            }
            if(!appData.isEmpty()){
                 screen= appData[0].Section_Name__c;
            }
            return screen;
        }
        catch (Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'ICS_CTRL_OnboardingFormCreator: getSectionName',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
        /**
* @description get account's name
* @param parentId The ID of the parent account.
*/
    @AuraEnabled
    public static string getNameByAccountId(string parentId){
        String name;
        try{
            SEL_Account selectorAccount = new SEL_Account();
            Account accountData = selectorAccount.selectById(parentId);
            if(accountData == null){
                throw new AuraHandledException('Unable to find account Id '+parentId);
            }
            if(accountData != null){
                 name= accountData.Name;
            }
            return name;
        }
        catch (Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'ICS_CTRL_OnboardingFormCreator: getNameByAccountId',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    /**
* @description To send an email to the contact associated with the specified account.
* @param accId The identifier of the account.
*/

    @AuraEnabled
    public static void sendEmail(string accId){
    
    try{
        ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<string,string> labelInfo =(Map<string,string>)json.deserialize(labelData.Description__c,map<string,string>.class);
        SEL_Account selectorAccount = new SEL_Account();
        Account acc= selectorAccount.selectById(accId);
        SEL_ApplicationForm afRecord = new SEL_ApplicationForm();
    
        List<ApplicationForm> apf = afRecord.selectByAccountId(acc.Id);
        Ics_CustomLabel__mdt portalUrlData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('SBOAccountOnboardingPortalUrl');
        Map<String, Object> portalInfor = (Map<String, Object>) JSON.deserializeUntyped(portalUrlData.Description__c);
        String portalUrl = (String)portalInfor.get('link');
        portalUrl = portalUrl + '?id=' + apf[0].Id;
        if(acc != null){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(acc.personContactId);
            message.setUseSignature(false);
            message.setBccSender(false);
            message.setSaveAsActivity(false);
    
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HTMLValue from EmailTemplate
                                           where Name =:labelInfo.get('SaveAndExitCommunicationTemplate')];
            List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address=:labelInfo.get('isleOfManOrgWideAddress')];
    
            String emailHtmlBody = emailTemplate.HtmlValue;
            emailHtmlBody = emailHtmlBody.replace('{{{Account.Name}}}',acc.Name);
             emailHtmlBody = emailHtmlBody.replace('here', '<a href="' + portalUrl + '"> here </a>');
            String emailSubject = emailTemplate.Subject;
            message.setHtmlBody(emailHtmlBody);
            message.setSubject(emailSubject);
            if(!test.isrunningtest()){
            message.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
            }
    
            message.setTemplateID(emailTemplate.Id);
            message.setWhatId(acc.id);
            message.toAddresses = new String[] { acc.PersonEmail};
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
            Messaging.sendEmail(messages);
        }
    }catch(exception ex){
         LOGGER.error(ex.getMessage(), new String[] {'ICS_CTRL_OnboardingFormCreator: v',ex.getMessage()}, ex);
    }
        }
    
    @AuraEnabled
    public static void sendEmailWithTemplate() {
     
    
            Id currentUserAccountId = getCurrentUserAccountId();
            List<ApplicationForm> applicationForms = getApplicationForms(currentUserAccountId);
            Map<Id, List<ApplicationForm>> opportunityToFormsMap = getOpportunityToFormsMap(applicationForms);
            sendCancellationEmails(opportunityToFormsMap);
     
    }
    
    
    
    
    private static Id getCurrentUserAccountId() {
        List<User>usersList = [select id,contact.AccountId from user where id=:userinfo.getuserid()];
        return usersList.isEmpty() ? null : usersList[0].contact.AccountId;
    }
    
    private static List<ApplicationForm> getApplicationForms(Id currentUserAccountId) {
        if (currentUserAccountId == null) {
            return new List<ApplicationForm>();
        }
        SEL_ApplicationForm afRecord = new SEL_ApplicationForm();
        return afRecord.selectByAccountId(currentUserAccountId);
    }
    
    private static Map<Id, List<ApplicationForm>> getOpportunityToFormsMap(List<ApplicationForm> applicationForms) {
        Map<Id, List<ApplicationForm>> opportunityToFormsMap = new Map<Id, List<ApplicationForm>>();
        sel_applicationform selectorAppForm = new sel_applicationform();
        List<ApplicationForm>appForms  = selectorAppForm.selectByOpportunityId(applicationForms[0].opportunityid);
        for (ApplicationForm apf :appForms ) {
            if(opportunityToFormsMap.containskey(apf.opportunityid) ==false){
            opportunityToFormsMap.put(apf.opportunityId,new List<applicationform>{apf});
            }
            else {
            opportunityToFormsMap.get(apf.opportunityId).add(apf);    
            }
        }
        
        return opportunityToFormsMap;
    }
    
    
    private static void sendCancellationEmails(Map<Id, List<ApplicationForm>> opportunityToFormsMap) {
        ICS_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ICS_Email_Templates');
        Map<string, string> labelInfo = (Map<string, string>) JSON.deserialize(labelData.Description__c, map<string, string>.class);
        EmailTemplate mail = getEmailTemplate(labelInfo.get('ApplicationCancelledAlertTemplate'));
        String noReplyOrgWideEmail = labelInfo.get('isleOfManOrgWideAddress');
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress=[select Id from OrgWideEmailAddress WHERE Address=:noReplyOrgWideEmail];
        for (List<ApplicationForm> apfList : opportunityToFormsMap.values()) {
            for (ApplicationForm apf : apfList) {
                if (apf.Account.PersonEmail != null && test.isrunningtest() ==false ) {

                    Messaging.SingleEmailMessage message = createEmailMessage(mail, apf,lstEmailAddress[0].Id);
                    messages.add(message);
                }
            }
        }
        sendEmails(messages);
    }
    
    private static EmailTemplate getEmailTemplate(String templateName) {
        EmailTemplate et = [SELECT Id,Subject,Description, HtmlValue FROM EmailTemplate WHERE Name = :templateName];
        return et;
    }
    @testVisible
    private static Messaging.SingleEmailMessage createEmailMessage(EmailTemplate mail, ApplicationForm apf,string orgEmailId) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        message.setTemplateID(mail.Id);
       
        if (orgEmailId != null) {
            message.setOrgWideEmailAddressId(orgEmailId);
        }
        String emailTextBody = mail.HtmlValue;
        if(emailTextBody != null)
        emailTextBody = emailTextBody.replace('{{{Account.Name}}}', apf.Account.Name);
        message.setWhatId(apf.AccountId);
        message.setSubject(mail.Subject);
        message.setHtmlBody(emailTextBody);
        message.setToAddresses(new String[] { apf.Account.PersonEmail });
        return message;
    }
    
    private static void sendEmails(List<Messaging.SingleEmailMessage> messages) {
        if (!Test.isRunningTest() && !messages.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
    }
    /**
     * @description Returns a grouped JSON string of main industries and their corresponding sub-industries.
     *              This data is typically used to populate dependent picklists in the UI.
     * @return JSON string representing list of industries and sub-industries, including risk rating and count.
     */
    @AuraEnabled
       public static string getIndustryPicklist(){
          CMN_CTRL_Industry industryPicklist = new CMN_CTRL_Industry();
          return industryPicklist.getGroupedDataAsJSON();
    }
     /**
     * @description Returns a list of sub-industry wrapper objects based on the given main industry.
     *              Each sub-industry includes its Id, name (value), and risk rating.
     * @param Industry The name of the main industry to retrieve sub-industries for.
     * @return List of SubIndustryWrapper records associated with the given main industry.
     */
     @AuraEnabled
       public static List<CMN_CTRL_Industry.SubIndustryWrapper> getSubIndustryPicklist(string Industry){
          CMN_CTRL_Industry industryPicklist = new CMN_CTRL_Industry();
          return industryPicklist.getSubIndustriesForMain(Industry);
    }
     /**
     * @description Retrieves a list of CMN_Industry__c records filtered by the provided Id.
     *              This can return either a sub-industry or main industry record depending on the Id passed.
     * @param Id The Id of the CMN_Industry__c record to fetch.
     * @return List of CMN_Industry__c records (typically a single record).
     */
     @AuraEnabled
       public static List<CMN_Industry__c> getIndustryPicklistWithId(String Id){
          CMN_CTRL_Industry industryPicklist = new CMN_CTRL_Industry();
          return industryPicklist.getIndustryPicklistWithId(Id);
    }

    }