/**
* @File Name : ug_aob_ppb_FlowController.cls
* @Description :Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper
* @Author :Gayathri Velicheti
* @Last Modified By : jagadish Thummala
* @Last Modified On : 11-11-2025
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | June 16, 2025 |   | Initial Version
**/

public without sharing class  UG_AOB_PPB_FlowController {
	
    
    private static Map<String, String> documentAndKYCNameMap = new Map<String, String>{
        'FrontImage' => 'KYC Documents Proof of Identity',
        'Proof Of Income' => 'KYC Documents Proof of Income',
        'BackImage' => 'KYC Documents Proof of Residence',
        'DocImage' => 'Account Administration Passport Sized Photos',
        'FaceImage' => 'Account Administration Passport Sized Photos',
        'selfieFile' => 'Selfie image',
        'IdFront'=>'IdFront',
        'IdBack'=>'IdBack',
        'AdmissionLetter'=>'AdmissionLetter',
        'TC_for_electronicBanking' => 'Account Administration Account Maintenance',
        'signatureFile' => 'Mandates Signature Card',
        'literacyProtectionPdf' => 'Mandatory Bank Documents Declaration Of Literacy',
        'A Contract of Employment' => 'KYC Documents\tProof of Employment',
        'Trading licence for those in business' => 'KYC Documents\tProof of Employment',
        'Contracts or Agreements' => 'KYC Documents\tProof of Employment',
        'Invoices or Receipts' => 'KYC Documents\tProof of Employment',
        'Payslips' => 'KYC Documents\tProof of Employment'
    };
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('UG_AOB_PPB_FlowController');

    @AuraEnabled(cacheable =True)
    /**
    * @description fetches products
    * @return List<Product2>
    */
    public static Map<String, List<Product2>> getActiveUgandaProduct() {
        Map<String, List<Product2>> productMap = new Map<String, List<Product2>>();
    
        try {
            List<String> productCodeList = new List<String>{'OD005', 'CTRAD'};
            string country = 'UG';
            List<Product2> products = new SEL_Product2().fetchPPBProductList(productCodeList,country);
            for (Product2 product : products) {
                String productName = product.Name;
                if (!productMap.containsKey(productName)) {
                    productMap.put(productName, new List<Product2>());
                }
                productMap.get(productName).add(product);
            }
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.getActiveUgandaProduct:Error retrieving active Uganda products', e);
            throw new AuraHandledException('An error occurred while fetching active Uganda products: ' + e.getMessage());
        }
    
        return productMap;
    }
    
    
    
    /**
    * @description Method to create lead record invoked from aob_form_Creator lwc component 
    * @param leadList 
    * @param individualList
    * @return null Response after the lead record creted
    */
    @AuraEnabled
    public static String createLeadRecord(List<Lead> leadList, List<Individual> individualList) {
        try {
            if (leadList.isEmpty()== false && individualList != null && individualList.isEmpty()== false) {
                String ugOnboardingRecordType;

                if (Test.isRunningTest()== false) {
                    PPB_Static_values__mdt ugOnboardingRecord = [SELECT value__c 
                                                                 FROM PPB_Static_values__mdt 
                                                                 WHERE Label = 'UG Onboarding Record Type' 
                                                                 WITH USER_MODE LIMIT 1] ;
                    ugOnboardingRecordType = ugOnboardingRecord.value__c;
                } else {
                    ugOnboardingRecordType = 'Uganda_Onboarding';
                }
                Lead lead = leadList[0];
                Individual individual = individualList[0];                           
                lead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(ugOnboardingRecordType).getRecordTypeId();
                individual.RecordTypeId = Schema.SObjectType.Individual.getRecordTypeInfosByDeveloperName().get(ugOnboardingRecordType).getRecordTypeId();
                lead.IndividualId = individual.Id;        
                if (Schema.sObjectType.Individual.isCreateable()) {
                    insert individual;
                }
                if (Schema.sObjectType.lead.isCreateable()) {
                    insert lead;
                }
                        
                return lead.Id;

            } else {
                return null;
            }
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.createLeadRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description Method to create lead record invoked from aob_form_Creator lwc component 
    * @param productRecord 
    * @param applicationRecord
    * @return Stringified Response after the lead record creted
    */
    @AuraEnabled
    public static String fetchKeyFactDocLink(Product2 productRecord, Application__c applicationRecord, Boolean womenOptedIn) {
        try{
            if(applicationRecord == null){
                throw new AuraHandledException('Application is empty');
            }
            List<Id> contentDocumentIdList =  new List<Id>();
            List<Id> contentDocumentForDistributionList = new List<Id>();
            String acctType    = productRecord.AOB_Account_Type__c;
            String selectedCurrency    = applicationRecord.AOB_Selected_Currency__c;
            for(ContentDocumentLink contentDocumentLinkInstance : new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationRecord.AOB_Product__c)) {
                contentDocumentIdList.add(contentDocumentLinkInstance.ContentDocumentId);
            }
            if (!contentDocumentIdList.isEmpty()) {
                String recordsToFilter = acctType + '_' + selectedCurrency  + (womenOptedIn ? '_WS' : '');
                for (ContentVersion contentVersionInstance : new SEL_ContentVersion().selectContentVersionByIds(contentDocumentIdList,recordsToFilter)) {
                    contentDocumentForDistributionList.add(contentVersionInstance.ContentDocumentId);
                }
            }
            if(contentDocumentForDistributionList.isEmpty() == false) {
                List<ContentDistribution> distributionList = [SELECT DistributionPublicUrl 
                                                              FROM ContentDistribution 
                                                              WHERE ContentDocumentId 
                                                              IN :contentDocumentForDistributionList 
                ]; 
                if(distributionList.isEmpty() == false) {
                    return distributionList[0].DistributionPublicUrl;
                }
            }
            return null;
        }
        catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.fetchKeyFactDocLink', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description Method to create upsert application record invoked from aob_form_Creator lwc component 
    * @return recordTypeId
    */
  
    @AuraEnabled(cacheable=true)
    public static Id fetchRecordTypeId() {
        Id recordTypeId = null;
        PPB_Static_values__mdt applicationRecord = [SELECT value__c FROM PPB_Static_values__mdt 
                                                    WHERE Label = 'Application Record Type' 
                                                    WITH USER_MODE LIMIT 1] ;
        string applicationRecordType = applicationRecord.value__c;
        try {
            recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(applicationRecordType).getRecordTypeId();
        } catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.fetchrecordTypeId', e);
            throw new AuraHandledException(e.getMessage());
        }
        return recordTypeId;
    }
  
    /**
    * @description Method to create upsert application record invoked from aob_form_Creator lwc component 
    * @param applicationList
    * @param screenName
    * @param productList
    * @return Stringified Response after the application record creted and also callout responses
    */
    @AuraEnabled
    public static String upsertApplicationRecord(List<Application__c> applicationList, String screenName, List<Product2> productList) {
        try {
            if(applicationList.isEmpty() == true|| applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.upsertApplicationRecord:  list should not be empty');
            }
            if (applicationList != null && !applicationList.isEmpty()) {
                String returnString;
                String applicationRecordType = [SELECT Label, value__c FROM PPB_Static_values__mdt  
                                                WHERE Label ='Application Record Type' 
                                                WITH USER_MODE LIMIT 1].value__c;
                Id ugRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(applicationRecordType).getRecordTypeId();
                Application__c currentApplication = applicationList[0];   
                returnString = processScreenSpecificLogic(screenName, currentApplication, ugRecordTypeId, applicationList);              
                if (productList[0]?.ProductCode != 'SBCHD') { 
                    upsert applicationList;
                }
                if (screenName == 'UG AOB PPB Personal Details') {
                    Map<String, Object> responseToReturnMap = handleResponseString(screenName,  applicationList[0], returnString);
                    return JSON.serialize(responseToReturnMap);
                }
                return JSON.serialize(returnString);
            }
            return null;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.upsertApplicationRecord', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description used to process screen logic based on the screen name
    * @author jagadish Thummala | 10-16-2025 
    * @param screenName 
    * @param currentApplication 
    * @param ugRecordTypeId 
    * @param applicationList 
    * @return String 
    **/
    private static String processScreenSpecificLogic(String screenName, Application__c currentApplication, Id ugRecordTypeId, List<Application__c> applicationList) {
        if (screenName == 'UG AOB PPB Personal Details') {
            return handleNationalityAndID(currentApplication, ugRecordTypeId, applicationList);
        } else if (screenName == 'UG AOB PPB Address Details') {
            return handleAddressDetails(currentApplication);
        } else if (screenName == 'UG AOB PPB Regulatory Requirements') {
            return handleRegulatoryRequirements(currentApplication); 
        }
        return null;
    }
    
    /**
    * @description used to handle MNO checks to validate mobile number
    * @author jagadish Thummala | 10-16-2025 
    * @param currentApplication 
    * @param ugRecordTypeId 
    * @param applicationList 
    * @return String 
    **/
    private static String handleNationalityAndID(Application__c currentApplication, Id ugRecordTypeId, List<Application__c> applicationList) {
        currentApplication.AOB_IP_Address__c = '';
        currentApplication.RecordTypeId = ugRecordTypeId;
        currentApplication.AOB_Consent_Status__c = true;
        String returnString = invokeMobileMoneyNumberValidate(applicationList);
        if (returnString != null) {
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
            String customerName = (String) parsedStringMap.get('CustomerName');
            if (customerName != null) {
                customerName = customerName.trim();
                currentApplication.AOB_MNO_Customer_Name__c = customerName;
                String customerNameLowerCase = customerName.toLowerCase();
                currentApplication.AOB_MNO_Name_Matched__c = (
                    customerNameLowerCase.contains(currentApplication.AOB_FirstName__c.toLowerCase().trim()) &&
                    customerNameLowerCase.contains(currentApplication.AOB_LastName__c.toLowerCase().trim())
                );
            }
                currentApplication.AOB_Stage__c = currentApplication.AOB_Stage__c ?? UG_AOB_PPB_ApplicationStages.STAGE_PERSONAL_DETAILS;
        }
        return returnString;
    }


    /**
    * @description to set the screen name
    * @author jagadish Thummala | 10-16-2025 
    * @param currentApplication 
    * @return string 
    **/
    private static string handleAddressDetails(Application__c currentApplication) {
        return currentApplication.AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_EMPLOYMENT_DETAILS;
    }
    
    /**
    * @description To set the screen name
    * @author jagadish Thummala | 10-16-2025 
    * @param currentApplication 
    * @return string 
    **/
    private static string handleRegulatoryRequirements(Application__c currentApplication) { 
        //If pep is selected as true then we should not chnage the stage to application summary.
        if(currentApplication.AOB_FamilyInProminentPublicOffice__c == true || currentApplication.AOB_PreviouslyHeldProminentOffice__c == true){
            return currentApplication.AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_ALTERNATIVE_MODE_PAYMENT;
        }
        return currentApplication.AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_APPLICATION_SUMMARY;
    }

    /**
    * @description to handle the response of MNO API
    * @author jagadish Thummala | 10-16-2025 
    * @param screenName 
    * @param currentApplication 
    * @param returnString 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> handleResponseString(String screenName, Application__c currentApplication, String returnString) {
        Map<String, Object> responseToReturnMap = new Map<String, Object>();
        if (String.isNotBlank(returnString)) {
            responseToReturnMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
        }
        responseToReturnMap.put('applicationId', currentApplication.Id);
        responseToReturnMap.put('ipAddress', currentApplication.AOB_IP_Address__c);
        responseToReturnMap.put('mnoCustomerName', currentApplication.AOB_MNO_Customer_Name__c);
        responseToReturnMap.put('mnoCustomerNameMatched', currentApplication.AOB_MNO_Name_Matched__c);
        responseToReturnMap.put('statusCode',(String) responseToReturnMap.get('statusCode') );
        if (screenName == 'UG AOB PPB Personal Details') {
            if (currentApplication.AOB_MNO_Name_Matched__c == true) {
                createVerificationRecord(currentApplication, 'MNO', 'Success');
            } else {
                Verification__c verificationInstance = new Verification__c(
                    Application__c = currentApplication.Id,
                    Verification_Source__c = 'MNO',
                    AOB_DSX_Response__c = returnString,
                    Verification_Status__c = 'Failed'
                );
                createVerificationWithInstance(verificationInstance);
            }
        }
        return responseToReturnMap;
    }
    
    /**
     * @description Method to do the Rely comply Assessment
    * @param applicationList 
    * @param productList 
    * @return Stringified Response from the Rely comply
    */
    @AuraEnabled
    public static String handleEmploymentDetails(List<Application__c> applicationList) {
        try{
            return processAssessment(applicationList, null);
        } catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.handleEmploymentDetails', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to fetch the Rely comply assessment.
    * @param applicationList 
    * @param productList 
    * @param assessmentId 
    * @return Stringified Response from the Rely comply fetch assessment
    */
    @AuraEnabled
    public static String fetchAssessmentCallout(List<Application__c> applicationList, String assessmentId) { 
        try{
            return processAssessment(applicationList,assessmentId);
        } catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.fetchAssessmentCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    /**
     * @description Method to process the responses from rely comply and do Risk assessment based on the risk status
    * @param applicationList 
    * @param assessmentId 
    * @return Stringified Response from the Rely comply fetch assessment
    */
    private static String processAssessment(List<Application__c> applicationList, String assessmentId) {
        String returnString;
        if (string.isBlank(assessmentId)== false) {
            returnString = AOB_RelyComply_FetchAssessment.invokeFetchAssessmentCallout(applicationList, assessmentId);
        } else {
            returnString = AOB_RelyComply_Individual_Screening.invokeRelyComplyScreening(applicationList);
        }        
        Map<String, Object> returnResponseObj = (Map<String, Object>) JSON.deserializeUntyped(returnString);
        
        if ('AcceptableRisk'.equals(returnResponseObj.get('assessmentStatus'))) {

            String employerName = getEmployerName(applicationList.get(0).AOB_Employer_Name__c);
            if (!String.isBlank(employerName)) {
                returnResponseObj.put('employerName', employerName);
            }
        }
        
        return JSON.serialize(returnResponseObj);
    }
    /**
     * @description Method to get the employer details based on the code
    * @param employerCode 
    * @return string of employer name 
    */
    private static String getEmployerName(String employerCode) {
        List<AOB_ReferencedData__c> empNameList = new SEL_ReferenceData().getReferencedDataName('PPB_EMP_NAME', 'AOB_SEQUENCE__C');
        for (AOB_ReferencedData__c emp : empNameList) {
            if (emp.AOB_CODE__c == employerCode) {
                return emp.Name;
            }
        }
        return null;
    }
    
  
    /**
    * @description Method to verify customer exist from first screen invoked from aob_form_Creator lwc component 
    * @param leadList 
    * @return Stringified Response if the customer already exist in the finacle system
    */
    @AuraEnabled
    public static String verifyCustomerExist(List<Lead> leadList) {//exception not covered
        try{
            return AOB_CustomerList.invokeCustomerList(leadList);
        }catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.verifyCustomerExist', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description Method to verify customer to match with NIRA from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of NIRA callout
    */
    @AuraEnabled
    public static String verifyThroughNIRA(List<Application__c> applicationList) {
        try{
            String returnString = AOB_NIRA.invokeNiraCallout(applicationList);
            if(String.isNotBlank(returnString)) {
                Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                if (parsedStringMap != null && parsedStringMap.containsKey('matchingStatus') 
                    && parsedStringMap.get('matchingStatus') === 'true') {
                    Application__c appToUpdate = new Application__c(Id = applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_IDENTIFII);
                    update appToUpdate;
                }
            }
            return returnString;
        }catch(Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.verifyThroughNIRA', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    

  
    /**
    * @description Method to Send SMS to enetered phone number
    * @param leadList 
    * @return Stringified Response of the otp from callout response
    */
    @AuraEnabled
    public static String sendSMS(List<Lead> leadList) {
        try {
            if(leadList.isEmpty() == true|| leadList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.sendSMS: Lead list should not be empty');
            }
            return AOB_SMSAlert.sendSMS(leadList);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.sendSMS', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description Method to Send Verification to entered email
    * @param leadList 
    * @return Stringified Response of the otp from callout response
    */
    @AuraEnabled
    public static String sendEmail(List<Lead> leadList) {
        try{
            if(leadList.isEmpty() == true|| leadList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.sendEmail: Lead list should not be empty');
            }
            return UG_AOB_PPB_OtpHandler.verifyEmail(leadList); 
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.sendEmail', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description Method to verify MNO invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of MNO callout
    */
    public static String invokeMobileMoneyNumberValidate(List<Application__c> applicationList) {
        return AOB_MobileNumberValidate.invokeMobileNumberCallout(applicationList);     
    }
   
    /**
    * @description Method to invoke Customer Creation into finacle system invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of Customer Creation callout
    */
   @AuraEnabled
   public static String invokeCustomerCreation(List<Application__c> applicationList) {
        try {
            if(applicationList.isEmpty() == true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeCustomerCreation: list should not be empty');
            }
            Application__c application = applicationList[0];
            String returnString = AOBCreateCIF.invokeCustomerCreate(application);
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
    
            if (parsedStringMap != null && 'SUCCESS'.equals((String) parsedStringMap.get('Status'))) {
                String custId = (String) parsedStringMap.get('CustId');
                parsedStringMap.put('AOB_Customer_Id__c', custId);
                application.AOB_Customer_Id__c = custId;
                application.AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_CIF_CREATED;
                update application;   
                returnString = JSON.serialize(parsedStringMap);
            }
    
            return returnString;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeCustomerCreation', e);
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
  
    /**
    * @description Method to get Questions and Answers for self registration invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @param questionsAndAnswers
    * @return Stringified Response of SelfRegistration callout
    */
    @AuraEnabled
    public static String invokeQuestionsAndAnswers(List<Application__c> applicationList, String questionsAndAnswers) {
        try{  
            if(applicationList.isEmpty() == true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeQuestionsAndAnswers: list should not be empty');
            }
            String returnString = AOB_CustomerRegister_QNA.invokeRegisterAnswerCallout(applicationList, questionsAndAnswers);
            update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_FUND_ACCOUNT);
            return returnString;
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeQuestionsAndAnswers', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
    /**
    * @description Method to send Documents to DSX invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @param productList
    * @return Stringified Response of DSX callout
    */
    @AuraEnabled
    public static String invokeDSXCallout(List<Application__c> applicationList, List<Product2> productList) {
        try {
            
            return AOB_DSX.invokeDsxCallout(applicationList, productList);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeDSXCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    } 
  
    /**
    * @description Method to invoke Signature Verification Callout invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @param signatureList
    * @return Stringified Response of Signature Verification Callout
    */
    @AuraEnabled
    public static String invokeSignatureVerify(List<Application__c> applicationList, List<ContentVersion> signatureList) {
        try {
            String response = AOB_SignatureVerification.invokeSvsCallout(applicationList, signatureList); 
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            for(ContentVersion signatureImage : signatureList) {
                if(signatureImage.Description == 'Signature File') {
                    String imageBlob = String.valueOf(signatureImage.VersionData);
                    ContentVersion contentVersionToCreate = new ContentVersion();
                    contentVersionToCreate.ContentLocation = 'S';
                    contentVersionToCreate.PathOnClient = signatureImage.Title;
                    contentVersionToCreate.Title = documentAndKYCNameMap.get('Signature File'); 
                    contentVersionToCreate.Description = 'Signature File'; 
                    if(Test.isRunningTest() == false) {
                        contentVersionToCreate.VersionData = EncodingUtil.base64Decode(imageBlob);
                    } else {
                        contentVersionToCreate.VersionData = EncodingUtil.base64Decode(signatureImage.Description);
                    }
                    contentVersionList.add(contentVersionToCreate);
                }
            }
            if (Schema.sObjectType.ContentVersion.isCreateable()) {
                insert contentVersionList;
            } 
            List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
            for(ContentVersion versionInstance :new SEL_ContentVersion().selectContentVersionByList( contentVersionList)){
                ContentDocumentLink documentLink = new ContentDocumentLink();
                documentLink.ContentDocumentId = versionInstance.ContentDocumentId;
                documentLink.LinkedEntityId = applicationList[0].Id;
                documentLinkList.add(documentLink);
            }
            if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                insert documentLinkList;
            }
            update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_APPLICATION_SUMMARY);
            return response;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeSignatureVerify', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
    * @description Method to invoke selfie Verification Callout invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @param selfieUpload
    * @return Stringified Response of Signature Verification Callout
    */
    @AuraEnabled
    public static String invokeSelfieUpload(List<Application__c> applicationList, Map<String, List<ContentVersion>> documentUploads) {
        try {
            if(applicationList.isEmpty() == true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeSelfieUpload: list should not be empty');
            }
            List<ContentVersion> contentVersionList = new List<ContentVersion>();           
            for (String key : documentUploads.keySet()) {
                for (ContentVersion document : documentUploads.get(key)) {
                    String imageBlob = String.valueOf(document.VersionData);
                    ContentVersion contentVersionToCreate = new ContentVersion();
                    contentVersionToCreate.ContentLocation = 'S';
                    contentVersionToCreate.PathOnClient = document.Title;
                    contentVersionToCreate.Title = documentAndKYCNameMap.get(key);
                    contentVersionToCreate.Description = documentAndKYCNameMap.get(key);        
                    if (Test.isRunningTest() == false) {
                        contentVersionToCreate.VersionData = EncodingUtil.base64Decode(imageBlob);
                    } else {
                        contentVersionToCreate.VersionData = EncodingUtil.base64Decode(document.Description);
                    }        
                    contentVersionList.add(contentVersionToCreate);
                }
            }       
            insert contentVersionList;       
            List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
            for (ContentVersion versionInstance : new SEL_ContentVersion().selectContentVersionByList(contentVersionList)) {
                ContentDocumentLink documentLink = new ContentDocumentLink();
                documentLink.ContentDocumentId = versionInstance.ContentDocumentId;
                documentLink.LinkedEntityId = applicationList[0].Id;
                documentLinkList.add(documentLink);
            }

            if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                insert documentLinkList;
                update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_ADDRESS_DETAILS);
            }        
            return null;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeSelfieUpload', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description 
    * @author jagadish Thummala | 10-16-2025 
    * @param applicationList 
    * @return List<ContentVersion> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getUploadedDocs(List<Application__c> applicationList) {
        try{
            if(applicationList.isEmpty() == true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.getUploadedDocs: list should not be empty');
            }
            Id applicationId = applicationList[0].Id;
            List<ContentDocumentLink> links = [SELECT ContentDocument.LatestPublishedVersion.Id, ContentDocument.LatestPublishedVersion.Title
                                                FROM ContentDocumentLink
                                                WHERE LinkedEntityId = :applicationId
                                                AND ContentDocument.LatestPublishedVersion.Title 
                                                IN ('Selfie image','Mandates Signature Card')];
            List<ContentVersion> versions = new List<ContentVersion>();
            for (ContentDocumentLink link : links) {
                ContentVersion ver = new ContentVersion();
                ver.Id    = link.ContentDocument.LatestPublishedVersion.Id;
                ver.Title = link.ContentDocument.LatestPublishedVersion.Title;
                versions.add(ver);
            }
            return versions;
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.getUploadedDocs', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
        
    /**
     * @description Method to register customer with choosen questions and answers invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of QNA Callout
    */
    @AuraEnabled
    public static String getSelfRegistrationQuestions(List<Application__c> applicationList) {
        try{
            List<Application__c> applst= new SEL_Application().selectAppsById( applicationList[0].ID);
            String returnString = AOB_SelfRegistration.invokeSelfRegisterCallout(applst);
            update new Application__c(Id= applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_QNA);
            return returnString;
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.getSelfRegistrationQuestions', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Method to get crated account number from finacle system invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of Customer Account Number Callout
    */
    @AuraEnabled
    public static String invokeGETCustomerAccountNumber(List<Application__c> applicationList) {
        try {
    
            String returnString = AOB_ODAccountCreation.invokeAccountCreation(applicationList);
            Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
            if(parsedStringMap != null && (String) parsedStringMap.get('status') == 'Success') {
                    
                update new Application__c(Id = applicationList[0].Id, 
                    AOB_Account_Number__c = (String) parsedStringMap.get('accountNumber')
                    
                );
                    
                    
                returnString = JSON.serialize(parsedStringMap);
            } else {
                update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_OD_ACCOUNT_CREATION);
            }
                
            return returnString;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeGETCustomerAccountNumber', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
  
        
    
    /**
     * @description Method to invoke subscription alert callout invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of subscription alert callout
    */
    @AuraEnabled
    public static String invokeSubscriptionAlertCallout(List<Application__c> applicationList) { 
        try{
            if(applicationList.isEmpty()==true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeSubscriptionAlertCallout: list should not be empty');
            }
            return AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(applicationList); 
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeSubscriptionAlertCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Method to invoke profile alert callout invoked from aob_form_Creator lwc component 
    * @param applicationList 
    * @return Stringified Response of profile alert callout
    */
    @AuraEnabled
    public static String invokeProfileAlertCallout(List<Application__c> applicationList) {
        try {
            if(applicationList.isEmpty()==true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeProfileAlertCallout: list should not be empty');
            }
            return AOB_CustomerAlertsProfile.invokeAlertsProfile(applicationList);
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeProfileAlertCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description Method to get identifii URL to rendered invoked from identifii lwc component 
    * @param applicationIds 
    * @return Stringified Response of Identifii callout
    */
    @AuraEnabled
    public static String invokeIdentifiiCallout(List<String> applicationIds) {
        try {
            if(applicationIds.isEmpty()==true || applicationIds == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeIdentifiiCallout: list should not be empty');
            }
            return AOB_IdentityApplicant.invokeIdv(applicationIds);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeIdentifiiCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Method to get inserted identifii documents invoked from identifii lwc component 
    * @param applicationList
    * @param documentId
    * @return Stringified Response of GET Identifii Documents callout
    */
    @AuraEnabled
    public static String invokeIdentifiiGETDocumentsCallout(List<Application__c> applicationList, String documentId) {
        try {
            if(applicationList.isEmpty()==true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeIdentifiiGETDocumentsCallout: list should not be empty');
            }
            String returnString = AOB_IdentityApplicant.invocableGETMethod(applicationList, documentId);
            
            if (String.isNotBlank(returnString)) {
                AOB_Identify_BodyBean.Response responseMap = (AOB_Identify_BodyBean.Response) JSON.deserialize(returnString, AOB_Identify_BodyBean.Response.class);
                
                if (responseMap != null && !applicationList.isEmpty() && !responseMap.IdentityImages.isEmpty() && 
                    String.isNotBlank(responseMap.DateOfExpiry) && String.isNotBlank(responseMap.PersonalNumber)) {
                    
                    processApplicationResponse(applicationList, responseMap); // Delegates processing to another method
                }
                return returnString;
            }
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeIdentifiiGETDocumentsCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    /**
    * @description Used to validate the IDV response with the details provided by customer
    * @author jagadish Thummala | 10-16-2025 
    * @param applicationList 
    * @param responseMap 
    **/
    private static void processApplicationResponse(List<Application__c> applicationList, AOB_Identify_BodyBean.Response responseMap) {
        String dateofExp = responseMap.DateOfExpiry;
        String personalNumber = responseMap.PersonalNumber.trim();
        Integer day = Integer.valueOf(dateofExp.split('\\.')[0]);
        Integer month = Integer.valueOf(dateofExp.split('\\.')[1]);
        Integer year = Integer.valueOf(dateofExp.split('\\.')[2]);
        Date dt = Date.newInstance(year, month, day);

        Application__c app = new Application__c(
            Id = applicationList[0].Id,
            AOB_Identifii_Expire_Date__c = Date.valueOf(dt)
        );
        
        app.AOB_Liveness_Matched__c = personalNumber == applicationList[0].AOB_NIN__c && responseMap.LivenessFRMatch;
        app.AOB_Liveness_Score__c = responseMap.LivenessFRScore == null ? 0 : responseMap.LivenessFRScore;
        app.AOB_Stage__c = (app.AOB_Liveness_Matched__c && responseMap.LivenessFRScore > 60) ? UG_AOB_PPB_ApplicationStages.STAGE_UPLOAD_PICTURE : UG_AOB_PPB_ApplicationStages.STAGE_IDENTIFII;
        
        update app;

        if (app.AOB_Liveness_Matched__c) {
            List<ContentVersion> contentVersionList = new List<ContentVersion>();
            for (AOB_Identify_BodyBean.IdentityImages identityImage : responseMap.IdentityImages) {
                String fileName = documentAndKYCNameMap.containsKey(identityImage.ImageType.Description) ? documentAndKYCNameMap.get(identityImage.ImageType.Description) : identityImage.ImageType.Description;
                ContentVersion contentVersionToCreate = new ContentVersion(
                    ContentLocation = 'S',
                    PathOnClient = fileName + '.png',
                    Title = fileName,
                    Description = identityImage.ImageType.Description,
                    VersionData = identityImage.Image
                );
                contentVersionList.add(contentVersionToCreate);
            }
            insert contentVersionList;
            
            List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
            for (ContentVersion versionInstance : new SEL_ContentVersion().selectContentVersionByList(contentVersionList)) {
                ContentDocumentLink documentLink = new ContentDocumentLink(
                    ContentDocumentId = versionInstance.ContentDocumentId,
                    LinkedEntityId = applicationList[0].Id
                );
                documentLinkList.add(documentLink);
            }
            insert documentLinkList;
        }
    }

        
    
    /**
    * @description Method to invoke Risk Assessment check invoked from aob_form_Creator lwc component 
    * @param applicationList
    * @param productList
    * @return Stringified Response of Customer Risk Assessment callout
    */
    @AuraEnabled
    public static String invokeRiskAssessmentCallout(List<Application__c> applicationList, List<Product2> productList) {
        try{
            String returnString = AOB_CustomerRiskAssessment.invokeRiskAssessment(applicationList, productList);
            if(String.isNotBlank(returnString) == true) {
                Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                if(responseObject.containsKey('RiskScoreStatus') == true && responseObject.containsKey('RiskScoreRating')) {
                    Application__c appToUpdate = applicationList[0];
                    appToUpdate.AOB_Risk_Score_Rating__c = (String) responseObject.get('RiskScoreRating');
                    appToUpdate.AOB_Risk_Score_Status__c = (String) responseObject.get('RiskScoreStatus');
                    appToUpdate.AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_ALTERNATIVE_MODE_PAYMENT;
                    // Now update the same instance—this pushes **all** its current field values,
                    update appToUpdate;
                }
                return returnString;
            }
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeRiskAssessmentCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    /**
    * @description Method to invoke Mobile Wallet invoked from aob_form_Creator lwc component 
    * @param applicationList
    * @return Stringified Response of Mobile Wallet callout
    */
    @AuraEnabled
    public static String invokeMobileWalletCallout(List<Application__c> applicationList) {
        try{
            if(applicationList.isEmpty()==true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeMobileWalletCallout: list should not be empty');
            }
            String response = AOB_MobileWallet.invokeWalletFunding(applicationList); 
            applicationList[0].AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_CONGRATULATIONS;
            update applicationList;
            return response;
        }  catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeMobileWalletCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Method to get status of the flexi pay invoked from aob_form_Creator lwc component 
    * @param applicationList
    * @param mobilewalletResponse
    * @return Stringified Response of Mobile Wallet Status callout
    */
    @AuraEnabled
    public static String invokeMobileWalletStatusCheckCallout(List<Application__c> applicationList, String mobilewalletResponse) {
        try{
            if(applicationList.isEmpty()==true || applicationList == null){
                throw new AuraHandledException('UG_AOB_PPB_FlowController.invokeMobileWalletStatusCheckCallout: list should not be empty');
            }
            Map<String, Object> responseMap = new Map<String, Object>();
            String returnString = AOB_MobileWalletStatus.invokeWalletStatus(applicationList, mobilewalletResponse);
            if(String.isNotBlank(returnString) == true && applicationList.isEmpty() == false) {
                responseMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);

                applicationList[0].AOB_Stage__c = UG_AOB_PPB_ApplicationStages.STAGE_CONGRATULATIONS;
                update applicationList;
            }
            return returnString;
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.invokeMobileWalletStatusCheckCallout', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Method to create verification record invoked from all api callouts classes 
    * @param applicationRecord
    * @param source
    * @param status
    * @return Id of the created verification record
    */
    public static Id createVerificationRecord(Application__c applicationRecord, String source, String status) {
            
        Verification__c verifyInstance = new Verification__c(
            Application__c = applicationRecord.Id,
            Verification_Source__c = source,
            Verification_Status__c = status
        );
        if (Schema.sObjectType.Verification__c.isCreateable()) {
            insert verifyInstance;
        }
                
        return verifyInstance.Id;    
    }
    
    /**
    * @description Method to create verification record with instance invoked from all api callouts classes 
    * @param verificationInstance
    * @return Id of the created verification record
    */
    public static Id createVerificationWithInstance(Verification__c verificationInstance) {
        insert verificationInstance;
        return verificationInstance.Id;
            
    }
    
    /**
    * @description Method to update verification record status for identifii invoked from aob_comp_formCreator 
    * @param verificationRecordId
    * @param status
    * @param documentId
    */
    @AuraEnabled
    public static void updateVerificationStatus(String verificationRecordId, String status, String documentId,String identityUrl ){
        try {
            Verification__c verificationRecord=new Verification__c(
                Id = verificationRecordId,
                Verification_Status__c = status,
                AOB_Identifii_Document_Id__c = documentId,
                Verification_URL__c = identityUrl
            );
            update verificationRecord;
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.updateVerificationStatus', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Method to get all flow screen record to render in container
    * @param countryName
    * @return returns all the flow screen records order by sequence
    */
    @AuraEnabled
    public static List<AOB_FlowScreen__c> getAllFlowScreenRecords(String countryName) {

        try {
            return [SELECT Id, Name, AOB_Screen_Sequence__c 
                    FROM AOB_FlowScreen__c 
                    WHERE AOB_Country__c = :countryName 
                    AND AOB_Screen_Sequence__c >=100 
                    WITH USER_MODE 
                    ORDER BY AOB_Screen_Sequence__c 
                    NULLS FIRST];
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.getAllFlowScreenRecords', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Method to get all flow screen record to render in container
    * @param applcationList
    * @return returns application with current stage
    */
    @AuraEnabled
    public static List<Application__c> verifyApplicationStage(List<Application__c> applcationList, Boolean isChildProduct) {
        try {
            if (applcationList == null || applcationList.isEmpty()) {
                return null;
            }
            Application__c app = applcationList[0];
            String otherNameCondition = String.isNotBlank(app.AOB_Other_Name__c)
                ? ' AND AOB_Other_Name__c = \'' + app.AOB_Other_Name__c.trim() + '\''
                : '';

            String filterCondition = 'AOB_FirstName__c = \'' + app.AOB_FirstName__c.trim() + '\''
                + ' AND AOB_LastName__c = \'' + app.AOB_LastName__c.trim() + '\''
                + otherNameCondition
                + ' AND AOB_Phone__c = \'' + app.AOB_Phone__c + '\''
                + ' AND AOB_DOB__c = ' + Datetime.newInstance(app.AOB_DOB__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd');

            // Add only if NOT child product
            if (!isChildProduct) {
                filterCondition += ' AND AOB_Stage__c != \'Congratulations\''
                                + ' AND AOB_Product__c = \'' + app.AOB_Product__c + '\'';
            }

            return new SEL_Application().getApplicationByFilter(filterCondition);

        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.verifyApplicationStage', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
     * @description Method to validate the whether the file is virus free ot not
    * @param applicationList
    * @param documentList
    * @return returns Reponse of file status check
    */
    @AuraEnabled
    public static String verifySelectedFile(List<Application__c> applicationList, List<ContentVersion> documentList) {
        try{
            return AOB_ScanAndVerifyFiles.invocableMethod(applicationList, documentList);  
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.verifySelectedFile', e);
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
    * @description Method to update images on summary invoked from aob_form_Creator lwc component 
    * @param applicationList
    * @return  returns the list of images.
    */     
    @AuraEnabled
    public static List<ImageWrapper> getImages(list<Application__c> applicationList) {
        try{
            List<ImageWrapper> images = new List<ImageWrapper>();
            List<ContentDocumentLink> cDocLinks = new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationList[0].Id); 
            if (!cDocLinks.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                for (ContentDocumentLink cdl : cDocLinks) {
                    contentDocumentIds.add(cdl.ContentDocumentId);
                }
                List<ContentVersion> contentVersions = new SEL_ContentVersion().selectContentVersionByContentDocListLatest(contentDocumentIds);
                if (contentVersions != null && !contentVersions.isEmpty()) {
                    for (ContentVersion cv : contentVersions) {
                        images.add(new ImageWrapper(cv.id, cv.title, EncodingUtil.base64Encode(cv.versionData), cv.FileType));
                    }
                }
            }
            return images;
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.getImages', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description class to update images on summary invoked from aob_form_Creator lwc component 
    */      
    public class ImageWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String title;
        @AuraEnabled public String versionData;
        @AuraEnabled public String FileType;

        /**
         * @description Method to update images on summary invoked from aob_form_Creator lwc component 
        * @param id
        * @param title
        * @param versionData
        */          
        public ImageWrapper(String id, String title, String versionData, String FileType) {
            this.id = id;
            this.title = title;
            this.versionData = versionData;
            this.FileType = FileType;
        }
    }
        

    /**
    * @description Method to validate the whether the file is virus free ot not
    * @param documentList
    * @return String Reponse of files
    */
    @AuraEnabled
    public static String fileScreeningByDocumentList(List<ContentVersion> documentList) {
        try{
            return AOB_ScanAndVerifyFiles.invocableMethodWithDocumentList(documentList);
        }catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.fileScreeningByDocumentList', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description	creates AppParticipant related Documents with the data that has been captured in preapplication screen
    * @param applicationId
    * @param filename 
    * @param filedata 
    * @param currencyType 
    */
    @AuraEnabled
    public static void createApplicationDocument(String applicationId, String filename,string filedata,string currencyType){
        
        try{
            list<ContentVersion> contentVersionList = new List<ContentVersion>();
            ContentVersion contentVersionToCreate = new ContentVersion();
            String imageBlob = String.valueOf(filedata);
            contentVersionToCreate.ContentLocation = 'S';
            contentVersionToCreate.PathOnClient = filename +'.png';
            Integer dotIndex = filename.lastIndexOf('.');
            String title = (dotIndex == -1) ? filename  :filename.substring(0, dotIndex) ;
            contentVersionToCreate.Title = documentAndKYCNameMap.get(title);
            contentVersionToCreate.Description = documentAndKYCNameMap.get(title);
            if(Test.isRunningTest() == false) {
                contentVersionToCreate.VersionData = EncodingUtil.base64Decode(imageBlob);
            } else {
                contentVersionToCreate.VersionData = EncodingUtil.base64Decode(filename);
            }
            contentVersionList.add(contentVersionToCreate);
                    
            insert contentVersionList;
            List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
            for(ContentVersion versionInstance : new SEL_ContentVersion().selectContentVersionByList( contentVersionList)) {
                ContentDocumentLink documentLink = new ContentDocumentLink();
                documentLink.ContentDocumentId = versionInstance.ContentDocumentId;
                documentLink.LinkedEntityId = applicationId;
                documentLinkList.add(documentLink);
            }
            insert documentLinkList;  
        }
        catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.createApplicationDocument', e);
            throw new AuraHandledException(e.getMessage());
        }  
    }
    /**
     * @description Method to create lead record if existing in finacle and not in salesforce
    * @param leadList 
    * @param individualList
    * @return null Response after the lead record creted
    */
    @AuraEnabled
    public static string createGuardianLead(Lead leadParam) {
        try {
            if (leadParam == null) {
                return null;
            }

            String ugOnboardingRecordType;
            Id queueId = null;
            Group groupRecord;
            if(Test.isRunningTest()) {
                ugOnboardingRecordType = 'Uganda_Onboarding';
                queueId = UserInfo.getUserId();
            } else {
                PPB_Static_values__mdt ugOnboardingRecord = [
                    SELECT value__c 
                    FROM PPB_Static_values__mdt 
                    WHERE Label = 'UG Onboarding Record Type' 
                    WITH USER_MODE 
                    LIMIT 1
                ];
                ugOnboardingRecordType = ugOnboardingRecord.value__c;

                // Check object and field permissions before accessing Group (Queue)
                if (Schema.sObjectType.Group.isAccessible() ) {
                    groupRecord = [
                        SELECT Id 
                        FROM Group 
                        WHERE Type = 'Queue' AND DeveloperName = 'UG_AOB_PPB_parent' 
                        WITH USER_MODE
                        LIMIT 1
                    ];
                    if (groupRecord != null) {
                        queueId = groupRecord.Id;
                    }
                }
            } 

            List<Lead> existingLeads = [
                SELECT Id FROM Lead 
                WHERE Phone = :leadParam.Phone
                LIMIT 1
            ];
            if (!existingLeads.isEmpty()) {
                return null; 
            }

            leadParam.RecordTypeId =
                Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
                .get(ugOnboardingRecordType)
                .getRecordTypeId();

            if (queueId != null) {
                leadParam.OwnerId = queueId;
            }

            if (Schema.sObjectType.Lead.isCreateable()) {
                insert leadParam;
            }
            return JSON.serialize(leadParam);
        } catch (Exception e) {
            LOGGER.error('UG_AOB_PPB_FlowController.createGuardianLead', e);
            throw new AuraHandledException(e.getMessage());
        }
    }

}