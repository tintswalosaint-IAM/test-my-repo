/***************************************************************************************
@ Author            :Yashwanth
@ Date              :june 2022
@ Name of the Class :AOB_PPB_Internal_FlowController
@ Description       :Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper for staff Assist
@ Last Modified By  :Jagadish Thummala 
@ Last Modified On  :13/11/2023.
@ Modification Description : SFP-28286
***************************************************************************************/
/**
      * @description Class for dealing with Main Flow and sending the result to the main flow and storing the values in the wrapper for staff Assist
*/
public class AOB_PPB_Internal_FlowController {
    /**
      * @description String for documentAndKYCNameMap
      */
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
            'Signature File' => 'Mandates Signature Card',
            'literacyProtectionPdf' => 'Mandatory Bank Documents Declaration Of Literacy'
        };
      @AuraEnabled(cacheable =True)
      /**
      * @description fetches products
      * @return List<Product2>
      */
      public static List<Product2> getActiveUgandaProduct() {
        try {
            return [
                SELECT Id, Name, AOB_Account_Type__c, ProductCode, Product_Image__c, AOB_Pricing_Option__c,
                       Description, AOB_Product_Details__c, AOB_Memo_Code__c, AOB_Scheme_Type__c
                FROM Product2
                WHERE (AOB_Memo_Code__c != 'OD005' AND AOB_Memo_Code__c != 'CTRAD') AND IsActive = True AND Country__c = 'UG'
            ];
        } catch (Exception e) {
            LOGGER.error('Error retrieving active Uganda products', e);
            throw new AuraHandledException('An error occurred while fetching active Uganda products: ' + e.getMessage());
        }
    }
      private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_PPB_Internal_FlowController');
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
                            PPB_Static_values__mdt ugOnboardingRecord = [SELECT value__c FROM PPB_Static_values__mdt WHERE Label = 'UG Onboarding Record Type' WITH USER_MODE LIMIT 1] ;
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
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
      public static String fetchKeyFactDocLink(Product2 productRecord, Application__c applicationRecord) {
        try{
  
        List<Id> contentDocumentIdList =  new List<Id>();
        List<Id> contentDocumentForDistributionList = new List<Id>();
      
        for(ContentDocumentLink contentDocumentLinkInstance : new SEL_ContentDocumentLink().getDocumentLinkByLinkedEntityId(applicationRecord.AOB_Product__c)) {
            contentDocumentIdList.add(contentDocumentLinkInstance.ContentDocumentId);
        }

        if (!contentDocumentIdList.isEmpty()) {
          String recordsToFilter =(productRecord.AOB_Account_Type__c + '_' + applicationRecord.AOB_Selected_Currency__c);   
          // Use selector method to retrieve ContentVersion records based on ContentDocumentIds
          for (ContentVersion contentVersionInstance : new SEL_ContentVersion().selectContentVersionByIds(contentDocumentIdList,recordsToFilter)) {
              // Filter ContentVersion records based on the Title condition
                  contentDocumentForDistributionList.add(contentVersionInstance.ContentDocumentId);
          }
      }
        if(contentDocumentForDistributionList.isEmpty() == false) {
            List<ContentDistribution> distributionList = [
                SELECT DistributionPublicUrl FROM ContentDistribution WHERE ContentDocumentId IN :contentDocumentForDistributionList
            ];
            
            if(distributionList.isEmpty() == false) {
                return distributionList[0].DistributionPublicUrl;
            }
        }    
        return null;
        } catch(Exception e) {
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
          PPB_Static_values__mdt applicationRecord = [SELECT value__c FROM PPB_Static_values__mdt WHERE Label = 'Application Record Type' WITH USER_MODE LIMIT 1] ;
          string applicationRecordType = applicationRecord.value__c;
          try {
              recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(applicationRecordType).getRecordTypeId();
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
                if (applicationList != null && !applicationList.isEmpty()) {
                    String returnString;
                    PPB_Static_values__mdt applicationRecord = [SELECT value__c FROM PPB_Static_values__mdt WHERE Label = 'Application Record Type' WITH USER_MODE LIMIT 1];
                    String applicationRecordType = applicationRecord.value__c;
                    Id ugRecordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get(applicationRecordType).getRecordTypeId();
                    
                    handleScreenSpecificLogic(applicationList[0], screenName, ugRecordTypeId);
                    
                    upsert applicationList;

                    if (screenName == 'PPB_INT_Nationality and ID' || String.isBlank(returnString)) {
                        returnString = handleReturnString(applicationList[0], screenName, returnString);
                    }

                    return returnString;
                }
                return null;
            } catch (Exception e) {
                LOGGER.error('AOB_FlowController.handleEmploymentDetails', e);
                throw new AuraHandledException(e.getMessage());
            }
        }

        private static void handleScreenSpecificLogic(Application__c application, String screenName, Id ugRecordTypeId) {
            if (screenName == 'PPB_INT_Nationality and ID') {
                handleNationalityAndID(application, ugRecordTypeId);
            } else if (screenName == 'PPB_INT_Upload Picture') {
                application.AOB_Stage__c = 'PPB_INT_Personal Details';
            } else if (screenName == 'PPB_INT_Personal Details') {
                handlePersonalDetails(application);
            } else if (screenName == 'PPB_INT_Alternative Mode of Payment') {
                application.AOB_Stage__c = 'PPB_INT_Confirmation & Signature';
            } else if (screenName == 'PPB_INT_Confirmation & Signature') {
                application.AOB_Stage__c = 'PPB_INT_Application summary';
            }
        }

        private static void handleNationalityAndID(Application__c application, Id ugRecordTypeId) {
            application.AOB_IP_Address__c = '';
            application.AOB_Stage__c = 'PPB_INT_Nationality and ID';
            application.RecordTypeId = ugRecordTypeId;
            application.AOB_Consent_Status__c = true;
            String returnString = invokeMobileMoneyNumberValidate(new List<Application__c> { application });
            if (returnString != null) {
                Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                String customerName = (String) parsedStringMap.get('CustomerName');
                if (customerName != null) {
                    customerName = customerName.trim();
                    application.AOB_MNO_Customer_Name__c = customerName;
                    String customerNameLowerCase = customerName.toLowerCase();
                    application.AOB_MNO_Name_Matched__c = (
                        customerNameLowerCase.contains(application.AOB_FirstName__c.toLowerCase().trim()) &&
                        customerNameLowerCase.contains(application.AOB_LastName__c.toLowerCase().trim())
                    );
                }
            }
        }

        private static void handlePersonalDetails(Application__c application) {
            if (application.AOB_FamilyInProminentPublicOffice__c || application.AOB_PreviouslyHeldProminentOffice__c) {
                application.AOB_Stage__c = 'PPB_INT_Personal Details';
            } else {
                application.AOB_Stage__c = 'PPB_INT_Employment Details';
            }
        }

        private static String handleReturnString(Application__c application, String screenName, String returnString) {
            Map<String, Object> responseToReturnMap = new Map<String, Object>();
            if (String.isNotBlank(returnString)) {
                responseToReturnMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
            }
            responseToReturnMap.put('applicationId', application.Id);
            responseToReturnMap.put('ipAddress', application.AOB_IP_Address__c);
            responseToReturnMap.put('mnoCustomerName', application.AOB_MNO_Customer_Name__c);
            responseToReturnMap.put('mnoCustomerNameMatched', application.AOB_MNO_Name_Matched__c);
            if (screenName == 'PPB_INT_Nationality and ID') {
                if (application.AOB_MNO_Name_Matched__c) {
                    AOB_PPB_Internal_FlowController.createVerificationRecord(application, 'MNO', 'Success');
                } else {
                    Verification__c verificationInstance = new Verification__c(
                        Application__c = application.Id,
                        Verification_Source__c = 'MNO',
                        AOB_DSX_Response__c = returnString,
                        Verification_Status__c = 'Failed'
                    );
                    AOB_PPB_Internal_FlowController.createVerificationWithInstance(verificationInstance);
                }
            }
            return JSON.serialize(responseToReturnMap);
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
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
            try{
            if (string.isBlank(assessmentId)==false) {
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
        } catch(Exception e) {
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
            throw new AuraHandledException(e.getMessage());
          }
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
      public static String verifyCustomerExist(List<Lead> leadList) {
          try {
              return AOB_CustomerList.invokeCustomerList(leadList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      }
  
     
        /**
      * @description Method to verify customer to match with NIRA from aob_internal_comp_formCreator lwc component 
      * @param applicationList 
      * @return Stringified Response of NIRA callout
      */
      @AuraEnabled
      public static String verifyThroughNIRAInternal(List<Application__c> applicationList) {
          try {
  
              String returnString = AOB_NIRA.invokeNiraCallout(applicationList);
              AOB_PPB_Internal_FlowController.getReferalCodeByUser( applicationList);
              if(String.isNotBlank(returnString)) {
                  Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                  if(parsedStringMap != null && parsedStringMap.containsKey('matchingStatus') 
                      && parsedStringMap.get('matchingStatus') === 'true') {
                      update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = 'Upload Picture',WI_ClientType__c = 'Staff Assist');
                  }
              }
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              return AOB_SMSAlert.sendSMS(leadList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              return AOB_OtpHandler.verifyEmail(leadList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      }
  
      /**
      * @description Method to verify MNO invoked from aob_form_Creator lwc component 
      * @param applicationList 
      * @return Stringified Response of MNO callout
      */
       public static String invokeMobileMoneyNumberValidate(List<Application__c> applicationList) {
          try {
              return AOB_MobileNumberValidate.invokeMobileNumberCallout(applicationList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      } 
  
      /**
      * @description Method to invoke Customer Creation into finacle system invoked from aob_form_Creator lwc component 
      * @param applicationList 
      * @return Stringified Response of Customer Creation callout
      */
      @AuraEnabled
      public static String invokeCustomerCreation(List<Application__c> applicationList) {
          try {
  
              String returnString = AOB_Customer.invokeCustomerCreate(applicationList);
              Map<String, Object> parsedStringMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
              if(parsedStringMap != null && (String) parsedStringMap.get('Status') == 'SUCCESS') {
                  parsedStringMap.put('AOB_Customer_Id__c', (String) parsedStringMap.get('CustId'));
                  
                  applicationList[0].AOB_Customer_Id__c = (String) parsedStringMap.get('CustId');
                  applicationList[0].AOB_Stage__c = 'Document Upload Popup';
                  update applicationList;
                  returnString = JSON.serialize(parsedStringMap);
              }
  
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
          try {
  
              String returnString = AOB_CustomerRegister_QNA.invokeRegisterAnswerCallout(applicationList, questionsAndAnswers);
              update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = 'Funding');
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
      public static String invokeDSXCalloutInternal(List<Application__c> applicationList, List<Product2> productList) {
         try {
              return AOB_Internal_DSX.invokeDsxCallout(applicationList, productList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              if ( Schema.sObjectType.ContentVersion.isCreateable()) {
                insert contentVersionList;
            }
  
              List<ContentDocumentLink> documentLinkList = new List<ContentDocumentLink>();
                for(ContentVersion versionInstance :new SEL_ContentVersion().selectContentVersionByList( contentVersionList)){
                  ContentDocumentLink documentLink = new ContentDocumentLink();
                  documentLink.ContentDocumentId = versionInstance.ContentDocumentId;
                  documentLink.LinkedEntityId = applicationList[0].Id;
                  documentLinkList.add(documentLink);
              }
              if ( Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                insert documentLinkList;
            }
                update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = 'PPB_INT_Application summary');
                
              return response;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
    
            insert documentLinkList;
            update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = 'PPB_INT_Personal Details');
            update applicationList;
    
            return null;
        } catch (Exception e) {
            LOGGER.error('AOB_PPB_Internal_FlowController.invokeDSXCallout', e);
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
          try {
              String returnString = AOB_SelfRegistration.invokeSelfRegisterCallout(applicationList);
              update new Application__c(Id= applicationList[0].Id, AOB_Stage__c = 'QNA');
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
                  
                  if(applicationList[0].AOB_Email__c != null) {
                      try {
                          AOB_Email_send.sendEmailTemplateWithTemplate(applicationList);
                      } catch (Exception ex) {
                          parsedStringMap.put('Message', ex.getMessage());
                      }
                  }
                  returnString = JSON.serialize(parsedStringMap);
              } else {
                  update new Application__c(Id = applicationList[0].Id, AOB_Stage__c = 'OD Account Creation');
              }
              
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
          try {
              return AOB_CustomerAlertSubscription.invokeAlertSubscriptionCallout(applicationList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              return AOB_CustomerAlertsProfile.invokeAlertsProfile(applicationList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              return AOB_IdentityApplicant.invokeIdv(applicationIds);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
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
          try {
              String returnString = AOB_CustomerRiskAssessment.invokeRiskAssessment(applicationList, productList);
              if(String.isNotBlank(returnString) == true) {
                  Map<String, Object> responseObject = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                  if(responseObject.containsKey('RiskScoreStatus') == true && responseObject.containsKey('RiskScoreRating')) {
                  
                      update new Application__c(Id = applicationList[0].Id, 
                          AOB_Risk_Score_Rating__c = ((String) responseObject.get('RiskScoreRating')),
                          AOB_Risk_Score_Status__c = ((String) responseObject.get('RiskScoreStatus')),
                          AOB_Stage__c = 'PPB_INT_Alternative Mode of Payment'
                      );
                  }
                  return returnString;
              }
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
          try {
              return AOB_MobileWallet.invokeWalletFunding(applicationList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
              Map<String, Object> responseMap = new Map<String, Object>();
              String returnString = AOB_MobileWalletStatus.invokeWalletStatus(applicationList, mobilewalletResponse);
              if(String.isNotBlank(returnString) == true && applicationList.isEmpty() == false) {
                  responseMap = (Map<String, Object>) JSON.deserializeUntyped(returnString);
                  if(responseMap.containsKey('status') && String.valueOf(responseMap.get('status')).equals('FAILED')){
                      applicationList[0].AOB_Fund_Amount__c='';
                  }
                  applicationList[0].AOB_Stage__c = 'Congratulations';
                  update applicationList;
              }
              return returnString;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
          try {
              Verification__c verifyInstance = new Verification__c(
                  Application__c = applicationRecord.Id,
                  Verification_Source__c = source,
                  Verification_Status__c = status
              );
              if (Schema.sObjectType.Verification__c.isCreateable()) {
                insert verifyInstance;
             }
              return verifyInstance.Id;
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      }
  
      /**
      * @description Method to create verification record with instance invoked from all api callouts classes 
      * @param verificationInstance
      * @return Id of the created verification record
      */
      public static Id createVerificationWithInstance(Verification__c verificationInstance) {
          
        if (Schema.sObjectType.Verification__c.isCreateable()) {
            insert verificationInstance;
         }
              return verificationInstance.Id;
      }
  
      /**
      * @description Method to update verification record status for identifii invoked from aob_comp_formCreator 
      * @param verificationRecordId
      * @param status
      * @param documentId
      */
      @AuraEnabled
      public static void updateVerificationStatus(String verificationRecordId, String status, String documentId){
          try {
              Verification__c verificationRecord=new Verification__c(
                  Id = verificationRecordId,
                  Verification_Status__c = status,
                  AOB_Identifii_Document_Id__c = documentId
              );
              if (Schema.sObjectType.Verification__c.isUpdateable()) {
                update verificationRecord;
             }               
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
            return [SELECT Id, Name, AOB_Screen_Sequence__c FROM AOB_FlowScreen__c WHERE AOB_Country__c = :countryName  and name like 'PPB_INT_%' WITH USER_MODE ORDER BY AOB_Screen_Sequence__c NULLS FIRST];
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      }
  
      /**
      * @description Method to get all flow screen record to render in container
      * @param applcationList
      * @return returns application with current stage
      */
      @AuraEnabled
      public static List<Application__c> verifyApplicationStage(List<Application__c> applcationList) {
          try {
              if (applcationList == null || applcationList.isEmpty()) {
                  return null;
              }
  
              Application__c app = applcationList[0];
              
              String filterCondition = 'AOB_FirstName__c = \'' + String.escapeSingleQuotes(app.AOB_FirstName__c?.trim()) + '\''
                  + ' AND AOB_LastName__c = \'' + String.escapeSingleQuotes(app.AOB_LastName__c?.trim()) + '\''
                  + ' AND AOB_Phone__c = \'' + String.escapeSingleQuotes(app.AOB_Phone__c) + '\''
                  + ' AND AOB_DOB__c = ' + Datetime.newInstance(app.AOB_DOB__c, Time.newInstance(0, 0, 0, 0)).format('yyyy-MM-dd')
                  + ' AND AOB_Stage__c != \'Congratulations\''
                  + ' AND AOB_Product__c = \'' + String.escapeSingleQuotes(app.AOB_Product__c) + '\'';
  
              // Handle AOB_Other_Name__c explicitly
              if (String.isNotBlank(app.AOB_Other_Name__c)) {
                  filterCondition += ' AND AOB_Other_Name__c = \'' + String.escapeSingleQuotes(app.AOB_Other_Name__c.trim()) + '\'';
              } else {
                  filterCondition += ' AND AOB_Other_Name__c = null';
              }
  
              return new SEL_AOB_Application().getApplicationByFilter(filterCondition);
  
          } catch (Exception e) {
              LOGGER.error('AOB_FlowController.verifyApplicationStage', e);
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
          try {
              return AOB_ScanAndVerifyFiles.invocableMethod(applicationList, documentList);
            } catch(Exception e) {
                LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
                throw new AuraHandledException(e.getMessage());
              }
      }
  
    /**
      * @description Method to update images on summary invoked from aob_form_Creator lwc component 
      * @param applicationList
        @return  returns the list of images.
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
                    images.add(new ImageWrapper(cv.id, cv.title, EncodingUtil.base64Encode(cv.versionData)));
                }
            }
          }
          return images;
        } catch(Exception e) {
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
  
      /**
      * @description Method to update images on summary invoked from aob_form_Creator lwc component 
      * @param id
      * @param title
      * @param versionData
      */          
          public ImageWrapper(String id, String title, String versionData) {
              this.id = id;
              this.title = title;
              this.versionData = versionData;
          }
      }
    
     /**
      * @description Method to update images on summary invoked from aob_form_Creator lwc component 
      * @param applicationList
      */  
      @AuraEnabled   
      public static void getReferalCodeByUser(list<Application__c> applicationList) {
        try{
        Id userId = UserInfo.getUserId();
        list<User> u = new SEL_User().selectUsersByIds(new set<id> {userId});
        Application__c app = new SEL_Application().selectAppById(applicationList[0].Id);
        app.AOB_Referal_Code__c = u[0].RM_AE_Code__c??'';
        app.WI_ClientType__c = 'Staff Assist';
        update app;
    } catch(Exception e) {
        LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
        throw new AuraHandledException(e.getMessage());
      }
    }
    

/**
* @description Method to validate the whether the file is virus free ot not
* @param documentList
* @return String Reponse of files
*/
@AuraEnabled
public static String fileScreeningByDocumentList(List<ContentVersion> documentList) {
    try {
        return AOB_ScanAndVerifyFiles.invocableMethodWithDocumentList(documentList);
    } catch(Exception e) {
        LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
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
                contentVersionToCreate.PathOnClient = filename ;
                contentVersionToCreate.Title = fileName;
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
        
        
        
        } catch(Exception e) {
            LOGGER.error('AOB_PPB_Internal_FlowController.fetchrecordTypeId', e);
            throw new AuraHandledException(e.getMessage());
          }  
}

  }