/*************************************************************
* @description SFP-43424 CTRL Class used to create Customer data
*
* @autor Ruchi Agarwal
*
* @date OCT 21 2024
***************************************************************
* Last Modified By Ridhima 
* Last Modified Date 21/10/2024
* Last Modified Description: Initial Version
*  ***************************************************************************************
* @Last Modified By 		: Ramya Gurram
* @Last Modified On 		: 19-06-2025
* @Modification description : SFP-50258
***************************************************************************************
* @Last Modified By 		: Ramya Gurram
* @Last Modified On 		: 01-11-2025
* @Modification description : SFP-52787 Added security questions to a Person Account
*************************************************
* @Last Modified By 		: Ridhima Saxena
* @Last Modified On 		: 01-11-2025
* @Modification description : SFP-53865 Correctly persist address fields in Person Account
*************************************************************************************** 
* @Last Modified By 		: Ridhima Saxena
* @Last Modified On 		: 07-11-2025
* @Modification description : SFP-53865 removed security question insert call
***************************************************************************************
* @Last Modified By 		: Ikyatha Naidu
* @Last Modified On 		: 26-02-2025
* @Modification description : SFP-55521 updated for join account and updated for SCA
***************************************************************************************
*/
public with sharing class ICS_CTRL_SAPCreateCustomer implements Queueable, Database.AllowsCallouts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_CTRL_SAPCreateCustomer');
    //get joint account recordtype
    
    private String opportunityId;
    private String accountId;
    private static List<Applicant> applicantList = new List<Applicant>();
    private final List<String> opportunityIds;
    private Boolean isJointData;
    private String customerTypeInfo = '';
    private static final String CUSTOMER_TYPE_JOINT = 'Joint';
    private final list<CMN_WebserviceCallQueue__c> webserviceList=new list<CMN_WebserviceCallQueue__c>();
    private final Map<String, Boolean> accountSuccessMap = new Map<String, Boolean>();
    private static list<Account> lstAccoutsToUpdate = new list<Account>();
    private static list<IdentityDocument> lstIdDocumentToInsert = new list<IdentityDocument>();
    private static list<FinServ__FinancialAccount__c> lstFAccoutsToInsert = new list<FinServ__FinancialAccount__c>();
    private static List<AccountContactRelation> updateacrList = new List<AccountContactRelation>();
    private static list<CMN_SecurityQuestions__c> lstSecurityQuesToInsert = new list<CMN_SecurityQuestions__c>();
    
    
    public ICS_CTRL_SAPCreateCustomer(List<String> oppIds) {
        this.opportunityIds = oppIds;
        
    }
    
    public void execute(QueueableContext context) {
        Map<Id, List<ApplicationForm>> appFormMap = new Map<Id, List<ApplicationForm>>();
        SEL_ApplicationForm selectorAppForm = new SEL_ApplicationForm();
        List<ApplicationForm> formList = selectorAppForm.selectByOpportunityIds(opportunityIds);
        applicantList = new SEL_Applicant().selectPrimaryApplicantByOppIds(opportunityIds);
        
        for(ApplicationForm formData: formList) {
            if(appFormMap.containsKey(formData.OpportunityId)) {
                appFormMap.get(formData.OpportunityId).add(formData);
                
            } else {
                appFormMap.put(formData.OpportunityId, new List<ApplicationForm>{formData}); 
                
            }
        }
        
        for(Id oppId : appFormMap.keySet()) {
            if(appFormMap.get(oppId).size() > 1) {
                processJointApplication(oppId, appFormMap.get(oppId));
            } else {
                processSingleApplication(oppId, appFormMap.get(oppId)[0]);
            }
        }
       
        if(!webserviceList.isEmpty()) {
            insertWebService(webserviceList);
        }
    }
    
    private void processJointApplication(Id oppId, List<ApplicationForm> forms) {
        map<string,string> responseStringMap=new map<string,string>();
        map<string,string> responseJointRelMap=new map<string,string>();
        opportunityId=oppId;
        for(ApplicationForm formData: forms) {
            isJointData = false;
            customerTypeInfo = CUSTOMER_TYPE_JOINT;
            CMN_WebserviceCallQueue__c responseBody = (CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService(
                'ICS_API_SAPCreateCustomer', 
                oppId,
                formData.accountId,
                false
            );
            webserviceList.add(responseBody);
            responseStringMap.put(formData.accountId,responseBody.CMN_Response__c);
            
        }
        
        for(Applicant applicantRec : applicantList) {
            if(applicantRec.Role == 'Primary Applicant') {
                isJointData = true;
                customerTypeInfo = CUSTOMER_TYPE_JOINT;
                CMN_WebserviceCallQueue__c responseBody = (CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService(
                    'ICS_API_SAPCreateCustomer',
                    applicantRec.ApplicationForm.opportunityId,
                    applicantRec.AccountId,
                    true
                );
                responseJointRelMap.put(applicantRec.AccountId,responseBody.CMN_Response__c);
                
                webserviceList.add(responseBody);
            }
        }
        
        updateTheData(forms,responseStringMap,responseJointRelMap);
        
    }
    
    private void insertWebService(list<CMN_WebserviceCallQueue__c> webserviceList) {
        insert webserviceList;
    }
    
    private void updateTheData( List<ApplicationForm> forms,map<string,string> responseStringMap,map<string,string> responseJointRelMap){
        for(ApplicationForm formData: forms) {
            isJointData = false;
            customerTypeInfo = CUSTOMER_TYPE_JOINT;
            processResponse(responseStringMap.get(formData.accountId),formData.accountId);
        }
        
        for(Applicant applicantRec : applicantList) {
            if(applicantRec.Role == 'Primary Applicant') {
                isJointData = true;
                customerTypeInfo = CUSTOMER_TYPE_JOINT;
                processResponse(responseJointRelMap.get(applicantRec.AccountId), applicantRec.AccountId);
            }
        }
        
        
    }
    private static void processDmls(){
        if(!lstAccoutsToUpdate.isEmpty()){
            update lstAccoutsToUpdate;
        }
        if(!lstIdDocumentToInsert.isEmpty()){
            insert lstIdDocumentToInsert;
        }
        If(!updateacrList.isEmpty()){
           	update  updateacrList;
        }
        if(!lstFAccoutsToInsert.isEmpty()){
            insert lstFAccoutsToInsert;
        }
        if(!lstSecurityQuesToInsert.isEmpty()){
            insert lstSecurityQuesToInsert;
        }
    }
    
    private void processSingleApplication(Id oppId, ApplicationForm form) {
        opportunityId=oppId;
        isJointData = false;
        customerTypeInfo = 'Single';
        CMN_WebserviceCallQueue__c webServiceObj = (CMN_WebserviceCallQueue__c)ICS_CTRL_InvokeSAP.callSapService(
            'ICS_API_SAPCreateCustomer', 
            oppId,
            form.accountId,
            false
        );
        
        webserviceList.add(webServiceObj);
        processResponse(webServiceObj.CMN_Response__c, form.accountId);
        
    }
    
    private void processResponse(String responseBody, String accountId) {
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        List<Object> partyList = (List<Object>)responseMap.get('Party');
        if (partyList == null || partyList.isEmpty()) {
            
            return;
        }
        
        Map<String, Object> party = (Map<String, Object>)partyList[0];
        String statusCode = getStatusCode(party);
        String cifId = getCIFId(party);
        
        accountSuccessMap.put(accountId, statusCode == 'S');
        if (statusCode == 'S') {
            accountSuccessMap.put(accountId,true);
            updateAccountCIFId(cifId, accountId,isJointData,customerTypeInfo,opportunityId);
        }else{
            accountSuccessMap.put(accountId, false);
        }
        
    }
    
    
    
    
    private String getStatusCode(Map<String, Object> party) {
        Map<String, Object> additionalData = (Map<String, Object>)party.get('AdditionalData');
        Map<String, Object> categoryInformation = (Map<String, Object>)additionalData.get('CategoryInformation');
        List<Object> categories = (List<Object>)categoryInformation.get('Category');
        
        for (Object cat : categories) {
            Map<String, Object> category = (Map<String, Object>)cat;
            if (category.get('CategoryItem') == 'providerStatus') {
                List<Object> details = (List<Object>)category.get('CategoryDetails');
                for (Object detail : details) {
                    Map<String, Object> detailMap = (Map<String, Object>)detail;
                    if (detailMap.get('CategoryType') == 'statusCode') {
                        return (String)detailMap.get('CategoryIdentifierValue');
                    }
                }
            }
        }
        return null;
    }
    
    private String getCIFId(Map<String, Object> party) {
        Map<String, Object> partyReference = (Map<String, Object>)party.get('PartyReference');
        List<Object> identifications = (List<Object>)partyReference.get('PartyIdentification');
        
        for (Object id : identifications) {
            Map<String, Object> identification = (Map<String, Object>)id;
            if (identification.get('PartyIdentificationType') == 'identificationNumber') {
                Map<String, Object> partyId = (Map<String, Object>)identification.get('PartyIdentification');
                Map<String, Object> identifierValue = (Map<String, Object>)partyId.get('IdentifierValue');
                return (String)identifierValue.get('Value');
            }
        }
        return null;
    }
    /**
*@description Method is used to update CIFID on Account and creates Financial Account
**/
    @future
    public static void updateAccountCIFId(String cifId, String accountId, Boolean isJointData, String customerTypeInfo, String opportunityId) {
           lstAccoutsToUpdate.clear();
        lstIdDocumentToInsert.clear(); 
        lstFAccoutsToInsert.clear();
        updateacrList.clear();
        lstSecurityQuesToInsert.clear();
        if(String.isBlank(cifId)){
			return;
		}
        Account accData = new sel_Account().selectById(accountId);		
        PartyProfile pProfile = new sel_partyprofile().selectByAccountAndRecordType(accData.id, 'ICS_PartyProfile');
		
		AddressInfo addressInfo = getAddressInformation(pProfile);
		
		List<ApplicationForm> formList = new SEL_ApplicationForm().selectByOpportunityId(opportunityId);
		
		boolean isPrimary = checkIsPrimary(formList,isJointData,customerTypeInfo);
		
		if(!isJointData){
			updateAccountDetails(formList, accData, addressInfo, cifId, isPrimary, pProfile);
			createIdentityDocument(pProfile, accData.id);
		}
        Opportunity opp = new Sel_Opportunity().selectById(opportunityId);
		if(isPrimary){
            List<AccountContactRelation> acrList = [SELECT Id,roles FROM AccountContactRelation WHERE AccountId =: opp.accountId ];
			createFinancialAccounts(accData, cifId, opp, formList, isJointData, customerTypeInfo, acrList);
		}
		String getStoredSecutiryQuestions = getSecurityQuestion(accountId);
        if(!isJointData) {
            insertMultipleSecurityQuestions(accountId, getStoredSecutiryQuestions);
        }
         processDmls();
    }
	private static boolean checkIsPrimary(List<ApplicationForm> formList,Boolean isJointData, String customerTypeInfo){
		Boolean singleCase = (formList.size() == 1 && !isJointData && customerTypeInfo == 'Single');
		Boolean jointCase  = (formList.size() > 1 && isJointData && customerTypeInfo == CUSTOMER_TYPE_JOINT);
		return singleCase || jointCase;
	}
	private static void updateAccountDetails(List<ApplicationForm> formList, Account accData, AddressInfo addressInfo, String cifId, boolean isPrimary, PartyProfile pProfile){
		String customerType = 'Individual';
        if(formList.size() > 1) {
            customerType = CUSTOMER_TYPE_JOINT; 
        }
		Account acc = new Account(
                    Id = accData.id,
                    ExternalCIFId__c = cifId,
                    ExternalIdentifier__c = accData.ExternalCIFCountry__c + accData.ExternalSystemId__c + cifId,
                    FinServ__Status__c = 'Active',
                    RelationshipMgrCode__c = 'SBO-Temp',
                    CMN_CustomerBPID__pc = cifId,
                    FinServ__CustomerType__c = customerType,
                    Phone = '+' + accData.ICS_Country_Code__c + accData.Phone,
                    ICS_Country_of_Residence__c = pProfile.Country_of_Residence__c,
                    ICS_Country_of_Nationality__c = pProfile.Country_of_Nationality__c,
                    WI_CountryOfCitizenship__pc = pProfile.WI_CountryOfCitizenship__c,
                    FinServ__CountryOfBirth__pc = pProfile.CountryofBirth,
                    ICS_Main_Applicant__c = isPrimary,
                    Second_Country_of_Nationality__c = pProfile.Second_Country_of_Nationality__c
                );
		if (addressInfo.currentAddress != null) {
			addressInfo.currentAddress.State = extractAfterSemicolon(addressInfo.currentAddress.State);
            addressInfo.currentAddress.Sub_Region__c = extractAfterSemicolon(addressInfo.currentAddress.Sub_Region__c);
            createResidentialAddress(addressInfo.currentAddress, acc);
            acc.BillingCity = addressInfo.currentAddress.City;
            acc.BillingState = addressInfo.currentAddress.State;
            acc.BillingPostalCode = addressInfo.currentAddress.PostalCode;
            acc.BillingCountry = addressInfo.currentAddress.Country;
        }
                
        if (addressInfo.correspondenceAddress != null) {
			addressInfo.correspondenceAddress.State = extractAfterSemicolon(addressInfo.correspondenceAddress.State);
            addressInfo.correspondenceAddress.Sub_Region__c = extractAfterSemicolon(addressInfo.correspondenceAddress.Sub_Region__c);
            createPhysicalAddress(addressInfo.correspondenceAddress, acc);
            acc.ShippingCity = addressInfo.correspondenceAddress.City;
            acc.ShippingState = addressInfo.correspondenceAddress.State;
            acc.ShippingPostalCode = addressInfo.correspondenceAddress.PostalCode;
            acc.ShippingCountry = addressInfo.correspondenceAddress.Country;
        }
                lstAccoutsToUpdate.add(acc);
        
				
	}
	private static void createIdentityDocument(PartyProfile pProfile,string strAccId){
		IdentityDocument docObj = new IdentityDocument();
        if(pProfile.PrimaryIdentifierType == 'Passport Number') {
			docObj.IdDocumentType = '6';
        } else {
			docObj.IdDocumentType = '11';
        }
        docObj.Name = pProfile.PrimaryIdentifier;
        docObj.RelatedLegalEntityId = strAccId;
        lstIdDocumentToInsert.add(docObj);
	}
	private static void createFinancialAccounts(Account accData, String cifId, Opportunity opp, List<ApplicationForm> formList, Boolean isJointData, String customerTypeInfo, List<AccountContactRelation> acrList ){
		
        FinServ__FinancialAccount__c accountFin = new FinServ__FinancialAccount__c (
                       FinServ__PrimaryOwner__c = opp.accountId,
            			Name = opp.Name,
                       ExternalCIFId__c = cifId,
                       FinServ__Status__c = 'Active',
                       ExternalCIFCountry__c = accData.ExternalCIFCountry__c,
                       ExternalSystemId__c = accData.ExternalSystemId__c,
                       ExternalIdentifier__c = accData.ExternalCIFCountry__c + accData.ExternalSystemId__c + cifId
                   );
        for(AccountContactRelation acr : acrList){
            acr.roles = 'Joint Participant';
            updateacrList.add(acr);
        }
        
        lstFAccoutsToInsert.add(accountFin);
        getSecurityQuestion(accData.Id);
        scheduleRelationAPICheck(opp.Id);
	}
    
    /**
* Helper method to extract value after semicolon, or return as-is if no semicolon
* @param value The value that might contain semicolon 
* @return The value after semicolon if present, otherwise the original value
*/
    private static String extractAfterSemicolon(String value) {
        if (String.isBlank(value)) {
            return value;
        }
        
        // Check if the value contains a semicolon
        if (value.contains(';')) {
            // Split by semicolon and return the part after it
            List<String> parts = value.split(';');
            if (parts.size() > 1) {
                return parts[1].trim();
            }
        }
        
        // If no semicolon, return the original value
        return value;
    }
    
    private class AddressInfo {
        PartyProfileAddress currentAddress;
        PartyProfileAddress correspondenceAddress;
    }
    
    // Method to get address information 
    private static AddressInfo getAddressInformation(PartyProfile profileInfo) {
        SEL_PartyProfileAddress selector = new SEL_PartyProfileAddress();
        
        
        AddressInfo info = new AddressInfo();
        
        List<PartyProfileAddress> currAddressInfoList = selector.selectCurrentAddressByPartyProfileId(profileInfo.id);
        
        if (!currAddressInfoList.isEmpty()) {
            info.currentAddress = currAddressInfoList[0];
            
        }
        
        List<PartyProfileAddress> correspondingAddressList = selector.selectByPartyProfileType(profileInfo.id, 'Correspondence Address');
        info.correspondenceAddress = correspondingAddressList.isEmpty() ? info.currentAddress : correspondingAddressList[0];
        
        return info;
    }
    
    private static void createResidentialAddress(PartyProfileAddress address, Account acc) {
        // Address Line 1: Apartment_Number__c, Building_Name__c, Sub_Building__c, Street
        String addressLine1 = buildAddressLine(new List<String>{
            address.Apartment_Number__c,
                address.Building_Name__c,
                address.Sub_Building__c,
                address.Street
                });
        
        // Address Line 2: Secondary_Street__c, Neighbourhood__c, Parish
        String addressLine2 = buildAddressLine(new List<String>{
            address.Secondary_Street__c,
                address.Neighbourhood__c,
                address.Parish__c
                });
        if (String.isNotBlank(addressLine2) && addressLine2.length() > 40) {
            addressLine2 = addressLine2.substring(0, 40);
        }
        
        // Address Line 3: District, Sub_region ONLY
        // City and State go to dedicated fields, NOT in Street
        String addressLine3 = buildAddressLine(new List<String>{
            address.District__c,
                address.Sub_region__c
                });
        if (String.isNotBlank(addressLine3) && addressLine3.length() > 40) {
            addressLine3 = addressLine3.substring(0, 40);
        }
        
        // Build street lines for BillingStreet (NO City, State, PostalCode, Country)
        List<String> streetLines = new List<String>();
        if (String.isNotBlank(addressLine1)){ streetLines.add(addressLine1);}
        if (String.isNotBlank(addressLine2)){ streetLines.add(addressLine2);}
        if (String.isNotBlank(addressLine3)){ streetLines.add(addressLine3);}
        
        // Set BillingStreet with newline separator
        if (!streetLines.isEmpty()) {
            acc.BillingStreet = String.join(streetLines, '\n');
        }
    }
    
    private static void createPhysicalAddress(PartyProfileAddress address, Account acc) {
        // Address Line 1: Apartment_Number__c, Building_Name__c, Sub_Building__c, Street
        String addressLine1 = buildAddressLine(new List<String>{
            address.Apartment_Number__c,
                address.Building_Name__c,
                address.Sub_Building__c,
                address.Street
                });
        
        // Address Line 2: Secondary_Street__c, Neighbourhood__c, Parish
        String addressLine2 = buildAddressLine(new List<String>{
            address.Secondary_Street__c,
                address.Neighbourhood__c,
                address.Parish__c
                });
        if (String.isNotBlank(addressLine2) && addressLine2.length() > 40) {
            addressLine2 = addressLine2.substring(0, 40);
        }
        
        // Address Line 3: District, Sub_region ONLY
        String addressLine3 = buildAddressLine(new List<String>{
            address.District__c,
                address.Sub_region__c
                });
        if (String.isNotBlank(addressLine3) && addressLine3.length() > 40) {
            addressLine3 = addressLine3.substring(0, 40);
        }
        
        // Build street lines for ShippingStreet (NO City, State, PostalCode, Country)
        List<String> streetLines = new List<String>();
        if (String.isNotBlank(addressLine1)){ streetLines.add(addressLine1);}
        if (String.isNotBlank(addressLine2)){ streetLines.add(addressLine2);}
        if (String.isNotBlank(addressLine3)){ streetLines.add(addressLine3);}
        
        // Set ShippingStreet with newline separator
        if (!streetLines.isEmpty()) {
            acc.ShippingStreet = String.join(streetLines, '\n');
        }
    }
    private static String buildAddressLine(List<String> fields) {
        List<String> nonEmptyFields = new List<String>();
        
        for (String field : fields) {
            if (String.isNotBlank(field)) {
                nonEmptyFields.add(field.trim());
            }
        }
        
        return nonEmptyFields.isEmpty() ? '' : String.join(nonEmptyFields, ', ');
    }
    /**
* Schedule a job to check if all CIF IDs are updated and call relation API
* Uses a static Set to prevent duplicate scheduling
*/
    private static Set<String> scheduledOpportunities = new Set<String>();
    private static void scheduleRelationAPICheck(String opportunityId) {
        // Use static Set to prevent scheduling multiple jobs for the same opportunity
        if(!scheduledOpportunities.contains(opportunityId)) {
            scheduledOpportunities.add(opportunityId);
            
            // Schedule the check job with a slight delay to allow other updates to complete
            ICS_SCH_SAPRelationAPIScheduler scheduler = new ICS_SCH_SAPRelationAPIScheduler(opportunityId);
            // Schedule job to run after 1 minute
            DateTime dt = DateTime.now().addMinutes(1);
            String cronExp = dt.second() + ' ' + dt.minute() + ' ' + 
                dt.hour() + ' ' + dt.day() + ' ' + 
                dt.month() + ' ? ' + dt.year();
            String uniqueJobName = 'Check CIF Updates ' + opportunityId + ' ' + 
                System.now().getTime() + ' ' + 
                Math.round(Math.random() * 1000000);
            System.schedule(uniqueJobName, cronExp, scheduler);
        }
    }
    /**
* Scheduler class to check if all CIF IDs are updated and call relation API
*/
    public static string getSecurityQuestion(String accId) {
        Map<string,string> mapQuestionText = new Map<string,string>{'Code word' => 'question1',
                                                                    'Favourite Colour' => 'question2',
                                                                    'Mother\'s Former Name' => 'question3',
                                                                    'Name of your first School' => 'question4'};
        // Use Map with question numbers to maintain order
        Map<String, String> collectionOfSecurity = new Map<String, String>();
        
        try {
            SEL_AssesmentQuestionResponse selectorAssessmentqueResponse = new SEL_AssesmentQuestionResponse();
            List<AssessmentQuestionResponse> responseData = selectorAssessmentqueResponse.selectByAccountIdAndName(accId, 'Security Details');
            
            if(responseData == null) {
                responseData = new List<AssessmentQuestionResponse>();
            }
            
            for (AssessmentQuestionResponse responseNameData : responseData) {
                if (responseNameData.Name.contains('Security Details')) {
                    String questionText = responseNameData.AssessmentQuestion?.QuestionText;
                    String questionValue = responseNameData.ResponseValue;
                    
                    if (String.isBlank(questionText)) {
                        continue;
                    }
                    
                    // Normalize apostrophes to match ICS_API_SAPCreateCustomer logic
                    String normalizedText = questionText.replace('\u2018', '\'').replace('\u2019', '\'');
                    
                    // Map to numbered questions in correct order
                    if (mapQuestionText.containsKey(normalizedText)) {
                        collectionOfSecurity.put(mapQuestionText.get(normalizedText), questionValue);
                    }
                }
            }
            
            return JSON.serialize(collectionOfSecurity);
            
        } catch (Exception exc) {
            LOGGER.error('Failed to retrieve security question: ' + exc.getMessage(), 'getSecurityQuestion');
            throw new AuraHandledException('An error occurred while retrieving the getSecurityQuestion');
        }
    }
    public static void insertMultipleSecurityQuestions(Id accountId, String questionsMap) {
        Map<String, Object> tempMap = (Map<String, Object>) JSON.deserializeUntyped(questionsMap);
        Map<String, String> questionRelatedData = new Map<String, String>();
        
        // Convert Object values to String
        for (String key : tempMap.keySet()) {
            questionRelatedData.put(key, String.valueOf(tempMap.get(key)));
        }
        
        // Map question numbers back to full question text
        Map<String, String> questionNameMap = new Map<String, String>{
            'question1' => 'Code word',
                'question2' => 'Favourite Colour',
                'question3' => 'Mother\'s Former Name',
                'question4' => 'Name of your first School'
                };
                    
        try {
            // Create Security Question records in order (question1, question2, question3, question4)
            for (Integer i = 1; i <= 4; i++) {
                String questionKey = 'question' + i;
                if (questionRelatedData.containsKey(questionKey)) {
                    CMN_SecurityQuestions__c secQuestion = new CMN_SecurityQuestions__c(
                        Account__c = accountId,
                        Name = questionNameMap.get(questionKey),
                        Answer__c = questionRelatedData.get(questionKey)
                    );
                    lstSecurityQuesToInsert.add(secQuestion);
                }
            }
            
            
        } catch (DmlException e) {
            LOGGER.error('Error inserting Security Questions: ' + e.getMessage());
            throw e;
        }
    }
    
}