/***************************************************************************************

@name of the Class : ICS_CTRL_DocumentUpload.cls
@description : class used as controller for  SBO-UK Document Upload Feature
@author : Ikyatha Naidu
@created Date :  01/01/2024
/***************************************************************************************
@last Modified By : ChangeMeIn@UserSettingsUnder.SFDoc
@last Modified On : 07-22-2025
@modification description: updated to latest version
***************************************************************************************
@last Modified By : Ridhima Saxena
@last Modified On : 15-01-2026
@modification description: SFP-54329 added invokeFetchCRAReport to get updated CRA report 
***************************************************************************************/
public without sharing class ICS_CTRL_DocumentUpload {
    private static final Id CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('ICS_Onboarding_Document').getRecordTypeId();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Document Storage - ICS_CTRL_Documents');
    
    /**
* Fetches upload properties for a given parent ID.
* @param parentId The ID of the parent record
* @return A JSON string containing upload properties
*/
    @AuraEnabled
    public static String fetchUploadProperty(String parentId) {
        try {
            Map<String, List<ObjectData>> tabInfo = new Map<String, List<ObjectData>>();
            SEL_PartyProfile selectorPartyProfile = new SEL_PartyProfile();
            PartyProfile profileData = selectorPartyProfile.selectByAccountAndRecordType(parentId, ICS_Constants.SBO_RECNAME);
            if (profileData == null) {
                return '';
            }
            
            Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap = getDocumentUploadSettings();
            
            Map<String, List<Party_Assets_Funds__c>> counterMap = getPartyAssetsFunds(profileData.Id);
            List<String> responseTextList=getAssessmentResponse(parentId);
            
            if(counterMap.containskey('Letter of Wishes:False')){
                responseTextList.add('Letter of Wishes');
            }if(counterMap.containskey('Trust Deed:False')){
                responseTextList.add('Trust Deed');
            }
            processWealthData(tabInfo, settingsMap, counterMap,responseTextList);
            processApplicantData(tabInfo, settingsMap, parentId);
            processTaxDetails(tabInfo, settingsMap, parentId);
            processSpecimenSignature(tabInfo, settingsMap);
            
            
            return tabInfo.isEmpty() ? '' : JSON.serialize(tabInfo);
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    public static List<String> getAssessmentResponse(String parentId) {
        List<String> assessmentResList = new List<String>();
        if (!Schema.sObjectType.Assessment.isAccessible()) {
            return assessmentResList;
        }
        SEL_AssesmentQuestionResponse assessmentSel = new SEL_AssesmentQuestionResponse();
        List<Assessment> assData= [select id from Assessment where AccountId=:parentId order by createddate asc ];
        List<AssessmentQuestionResponse> assessmentList = assessmentSel.selectByAssessmentIds(new set<Id>{assData[0].Id});
        
        for(AssessmentQuestionResponse assessmentRes : assessmentList) {
            if(assessmentRes.AssessmentQuestion.Name == 'Select all assets and income*' || 
               assessmentRes.AssessmentQuestion.Name == 'Select all funds assets and income*' || 
               assessmentRes.AssessmentQuestion.Name == 'How do you intend to fund the future deposits?') {
                   
                   if(assessmentRes.ResponseText != null && assessmentRes.ResponseText.contains(';')) {
                       assessmentResList.addAll(assessmentRes.ResponseText.split(';'));
                   } else if(assessmentRes.ResponseText != null) {
                       assessmentResList.add(assessmentRes.ResponseText);
                   }
               }
        }
        return assessmentResList;
    }
    
    /**
* Checks for enhanced due diligence.
* @param parentId The ID of the parent record
* @return True if enhanced due diligence is required, false otherwise
*/
    @AuraEnabled
    public static Boolean enhancedDueDiligenceCheck(String parentId) {
        try {
             if (!Schema.sObjectType.ApplicationForm.isAccessible()) {
                LOGGER.warn('User lacks ApplicationForm read permission: ' 
                    + UserInfo.getUserId());
            }
            Boolean returnValue = false;
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List<ApplicationForm> appData = selectorApplicationForm.selectByAccountId(parentId);
            if(!appData.isEmpty()){
                returnValue = appData[0].Enhanced_Due_Diligence_Required__c;
            }
            return returnValue;
        } catch (Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
   @AuraEnabled
    public static void updateStageValues(string recordId) {
        try {
            if (!Schema.sObjectType.ApplicationForm.isUpdateable()) {
                LOGGER.warn('User lacks ApplicationForm update permission: ' + UserInfo.getUserId());
            }
            SEL_ApplicationForm selectorApplicationForm = new SEL_ApplicationForm();
            List<ApplicationForm> appFormList = selectorApplicationForm.selectByAccountId(recordId);
            ApplicationForm appForm = appFormList[0];
            appForm.Stage = 'In Review';
            update appForm;
    
            updateOpportunityStageIfEligible(selectorApplicationForm, appForm);
            fetchRCdocuments(new List<String>{ recordId });
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    /**
    * @description Checks Opportunity accessibility and updates stage to Review
    *              if all ApplicationForms linked to the Opportunity are In Review.
    * @author Ridhima Saxena | 01-06-2026
    * @param selectorApplicationForm SEL_ApplicationForm instance to reuse for queries
    * @param appForm The ApplicationForm that was just set to In Review
    **/
    private static void updateOpportunityStageIfEligible(SEL_ApplicationForm selectorApplicationForm, ApplicationForm appForm) {
        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        if (!oppDescribe.isAccessible()) {
            LOGGER.warn('User lacks Opportunity read permission: ' + UserInfo.getUserId());
            return;
        }
        SEL_Opportunity opportunitySelector = new SEL_Opportunity();
        Opportunity opp = opportunitySelector.selectbyid(appForm.opportunityId);
        if (isEligibleForReview(opp)) {
            updateOpportunityToReview(selectorApplicationForm, appForm, opp);
        }
    }
    
    /**
    * @description Determines if the Opportunity is eligible to move to Review stage
    *              based on its Required_Approval_Processes__c field values.
    * @author Ridhima Saxena | 01-06-2026
    * @param opp The Opportunity record to evaluate
    * @return Boolean True if eligible for Review stage update
    **/
    private static Boolean isEligibleForReview(Opportunity opp) {
        return opp.Required_Approval_Processes__c == null
            || !opp.Required_Approval_Processes__c.contains('Show Provide Motivation')
            || (opp.Required_Approval_Processes__c.contains('Show Provide Motivation')
                && opp.Required_Approval_Processes__c.contains('Motivation Provided'));
    }
    
    /**
    * @description Counts ApplicationForms in In Review stage and updates the Opportunity
    *              stage to Review if all linked ApplicationForms are In Review.
    * @author Ridhima Saxena | 01-06-2026
    * @param selectorApplicationForm SEL_ApplicationForm instance to reuse for queries
    * @param appForm The ApplicationForm linked to the Opportunity
    * @param opp The Opportunity record to potentially update
    **/
    private static void updateOpportunityToReview(SEL_ApplicationForm selectorApplicationForm, ApplicationForm appForm, Opportunity opp) {
        List<ApplicationForm> allFormData = selectorApplicationForm.selectByOpportunityIds(new List<Id>{ appForm.opportunityId });
        Integer inReviewCount = 0;
        for (ApplicationForm singleData : allFormData) {
            if (singleData.stage == 'In Review') {
                inReviewCount++;
            }
        }
        if (inReviewCount == allFormData.size()) {
            if (!Schema.sObjectType.Opportunity.isUpdateable()) {
                LOGGER.warn('User lacks Opportunity update permission: ' + UserInfo.getUserId());
                return;
            }
            opp.stageName = 'Review';
            update opp;
        }
    }
    
    @future(callout = true)
    public static void fetchRCdocuments(List<String> recordIds){
        if (!Schema.sObjectType.CMN_WebserviceCallQueue__c.isAccessible()) {
            return;
        }
        List<CMN_WebserviceCallQueue__c> objs = new List<CMN_WebserviceCallQueue__c>();
        for (String recordId : recordIds) {
            if (String.isNotBlank(recordId)) {
                ICS_API_FetchCustomerDetails customerServiceCall = new ICS_API_FetchCustomerDetails();
                customerServiceCall.accountId = recordId;
                CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(ICS_API_FetchCustomerDetails.SERVICE_NAME, recordId);
                customerServiceCall.process(obj);
                objs.add(obj);
            }
        }
        if (!objs.isEmpty() && Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()) {
            insert objs;
        }
    }
     @InvocableMethod(label='Fetch RC Documents' 
                 description='Fetches customer documents from RelyComply'
                 category='Document Management')
    public static void invokeFetchCRAReport(List<String> accountIds) {
        if (accountIds != null && !accountIds.isEmpty()) {
            fetchRCdocuments(accountIds);
        }
    }

  
    /**
* @description Save multiple documents
* @author Tushar Walse | 18-01-2025 
* @param recordId The ID of the record to link the document to
* @param datas The documents
* @return String[] The IDs of the newly created ContentVersion records
**/
    @AuraEnabled
    public static String[] saveDocuments(String recordId, DocumentData[] datas) {
        try{
            string index = '0';
            if (!Schema.sObjectType.ContentVersion.isCreateable() ||
                !Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                    throw new AuraHandledException('Insufficient permissions to create ContentVersion or ContentDocumentLink.');
                }
            
            ContentVersion[] cvs = new ContentVersion[]{};
                for(DocumentData data : datas) {
                    String fileExtension = data.originalFilename.substringAfterLast('.');
                    
                    String filepath = data.filename + '.' + fileExtension;
                    cvs.add(createContentVersion(data, filepath,index));            
                }
            
            Id[] ids = new Id[]{};
                
                if(!test.isrunningtest()){
                    insert cvs;
                }
            
            ContentDocumentLink[] cdls = new ContentDocumentLink[]{};
                for(ContentVersion cv : cvs) {
                    cdls.add(createContentDocumentLink(cv.Id, recordId));
                    ids.add(cv.Id);
                }
            
            insert cdls;        
            return ids;      
        } catch (exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }  
    }
    
    /**
* Saves a document.
* @param recordId The ID of the record to link the document to
* @param data The document data
* @return The ID of the saved ContentVersion
*/
    @AuraEnabled
    public static String saveDocument(String recordId, DocumentData data,String index,String partyAssetFundId) {

        try{
            if (!Schema.sObjectType.ContentVersion.isCreateable() ||
                !Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                    throw new AuraHandledException('Insufficient permissions to create ContentVersion or ContentDocumentLink.');
                }
            if(partyAssetFundId != null){
                updateReasonForNoDocument(partyAssetFundId,null);
            }
            ContentVersion cv = new ContentVersion();
            String fileExtension = data.originalFilename.substringAfterLast('.');
            
            String filepath = data.filename + '.' + fileExtension;
            cv = createContentVersion(data, filepath,index);
            if(!test.isrunningtest()){
                insert cv;

                ContentDocumentLink cdl = createContentDocumentLink(cv.Id, recordId);
                
                insert cdl;
            }
            
            return cv.Id;
        }catch(exception exc){
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    /**
* Fetches the current party profile ID.
* @return A JSON string containing login data
*/
    @AuraEnabled
    public static String fetchCurrentPartyProfileId() {
        try {
            Map<String, String> loginData = new Map<String, String>();
            
            User currentUser = [SELECT Id, FirstName, LastName, Contact.AccountId
                                FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED];
            
            loginData.put('firstName', currentUser.FirstName);
            loginData.put('lastName', currentUser.LastName);

            if (currentUser.Contact != null && currentUser.Contact.AccountId != null) {
                ApplicationForm formData = [SELECT Id, OpportunityId, AccountId FROM ApplicationForm
                                            WHERE AccountId = :currentUser.Contact.AccountId
                                            AND Opportunity.IsWon = false AND Opportunity.IsClosed = false  LIMIT 1 ];
                
                if (formData != null) {
                    loginData.put('accountId', formData.AccountId);
                    SEL_PartyProfile partyProfileOBJ = new SEL_PartyProfile();
                    PartyProfile partyProfileData = partyProfileOBJ.selectByAccountAndRecordType(formData.AccountId, ICS_Constants.SBO_RECNAME);
                    loginData.put('partyProfileId', partyProfileData.Id);
                }
            }
            
            return JSON.serialize(loginData);
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    @AuraEnabled
    public static string getThePartyProfileId(string recordId){
        try {
            SEL_PartyProfile partyProfileOBJ = new SEL_PartyProfile();
            PartyProfile partyProfileData = partyProfileOBJ.selectByAccountAndRecordType(recordId,ICS_Constants.SBO_RECNAME);
            return partyProfileData.id;
        } catch (Exception e) {
            LOGGER.error(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
* Fetches document data for a given tab.
* @param tabName The name of the tab
* @return A JSON string containing document data
*/
    @AuraEnabled
    public static String fetchDocumentsData(String tabName,string parentId) {
        try {
            Map<String, Object> documentData = new Map<String, Object>();
            Set<Id> contentDocumentIds = new Set<Id>();
            List<ContentDocumentLink> documentLinkList = [SELECT ContentDocumentId FROM ContentDocumentLink
                                                          WHERE LinkedEntityId = :parentId WITH SECURITY_ENFORCED];
            if(documentLinkList.size()>0){
                for (ContentDocumentLink documentLink : documentLinkList) {
                    
                    contentDocumentIds.add(documentLink.ContentDocumentId);
                }
            }
            List<ContentVersion> contentVersionList = [SELECT Id, ContentDocument.Id, Title, DocumentType__c, DocumentDate__c,fileExtension, Description
                                                       FROM ContentVersion
                                                       WHERE ContentDocument.Id IN :contentDocumentIds WITH SECURITY_ENFORCED];
            
            Map<String, List<Object>> mapDocTypeToNames = new Map<String, List<Object>>{
                'SOF' => new List<Object>(),
                    'SOW' => new List<Object>(),
                    'files' => new List<Object>()
                    };
                        for (ContentVersion cv : contentVersionList) {
                            if (isMatchingType(cv.DocumentType__c, tabName)) {
                                addToDataList(cv, mapDocTypeToNames);
                            }
                        }
            
            documentData.put(tabName, mapDocTypeToNames);
            return JSON.serialize(documentData);
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    /**
* Retrieves document upload settings.
* @return A map of document upload settings
*/
    private static Map<String, List<ICS_DocumentUploadInfos__mdt>> getDocumentUploadSettings() {
        Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap = new Map<String, List<ICS_DocumentUploadInfos__mdt>>();
        for (ICS_DocumentUploadInfos__mdt uploadSettings : ICS_DocumentUploadInfos__mdt.getAll().values()) {
            if (!settingsMap.containsKey(uploadSettings.Type__c)) {
                settingsMap.put(uploadSettings.Type__c, new List<ICS_DocumentUploadInfos__mdt>());
            }
            settingsMap.get(uploadSettings.Type__c).add(uploadSettings);
        }
        return settingsMap;
    }
    
    /**
* Retrieves party assets and funds.
* @param profileId The ID of the party profile
* @return A map of party assets and funds
*/
    private static Map<String, List<Party_Assets_Funds__c>> getPartyAssetsFunds(Id profileId) {
        Map<String, List<Party_Assets_Funds__c>> counterMap = new Map<String, List<Party_Assets_Funds__c>>();
        Set<String> trustDeedOrLOW = new Set<String>{'Trust Deed', 'Letter of Wishes'};
        if (!Schema.sObjectType.Party_Assets_Funds__c.isAccessible()) {
            return counterMap;
        }
            for (Party_Assets_Funds__c wealthData : [SELECT Id, Type__c, Is_Future_Fund__c,Is_listed_in_assets__c, Is_amount_to_more_than_10__c, Type_of_Property__c, TrustDeed_or_Letter_of_wishes__c, RecordType.Name
                                                     FROM Party_Assets_Funds__c
                                                     WHERE Party_Profile__c = :profileId ]) {
                                                         processWealthDataItem(wealthData, counterMap, trustDeedOrLOW);
                                                     }
        return counterMap;
    }
    
    /**
* Processes a single wealth data item.
* @param wealthData The wealth data item
* @param counterMap The map to store processed data
* @param trustDeedOrLOW Set of trust deed or letter of wishes options
*/
    private static void processWealthDataItem(Party_Assets_Funds__c wealthData, 
                                              Map<String, List<Party_Assets_Funds__c>> counterMap, 
                                              Set<String> trustDeedOrLOW) {
                                                  if (shouldSkipProcessing(wealthData)) {
                                                      return;
                                                  }
                                                  
                                                  if (wealthData.Type__c == 'Trust') {
                                                      processTrustWealthData(wealthData, counterMap, trustDeedOrLOW);
                                                      return;
                                                  }
                                                  if (shouldProcessNonTrustData(wealthData)) {
                                                      String key = buildDataKey(wealthData);
                                                      addToCounterMap(counterMap, key, wealthData);
                                                  }
                                              }
    
    /**
* Determines if the wealth data item should be skipped.
* @param wealthData The wealth data item to check
* @return True if processing should be skipped
*/
    private static Boolean shouldSkipProcessing(Party_Assets_Funds__c wealthData) {
        return wealthData.RecordType.Name != 'Source of Funds' && wealthData.Type__c != 'Trust';
    }
    
    
    /**
* Determines if non-trust data should be processed.
* @param wealthData The wealth data item to check
* @return True if the data should be processed
*/
    private static Boolean shouldProcessNonTrustData(Party_Assets_Funds__c wealthData) {
        return wealthData.Type__c != 'Trust' && 
            (wealthData.Is_amount_to_more_than_10__c || wealthData.Is_Future_Fund__c) && 
            !wealthData.Is_listed_in_assets__c;
    }
    
    /**
* Builds the data key for the counter map.
* @param wealthData The wealth data item
* @return The constructed key
*/
    private static String buildDataKey(Party_Assets_Funds__c wealthData) {
        return wealthData.Type__c + ':' + wealthData.Is_Future_Fund__c;
    }
    
    /**
* Processes trust wealth data.
* @param wealthData The trust wealth data
* @param counterMap The map to store processed data
* @param trustDeedOrLOW Set of trust deed or letter of wishes options
*/
    private static void processTrustWealthData(Party_Assets_Funds__c wealthData, Map<String, List<Party_Assets_Funds__c>> counterMap, Set<String> trustDeedOrLOW) {
        
        if (wealthData.TrustDeed_or_Letter_of_wishes__c == 'Both') {
            for (String value : trustDeedOrLOW) {
                addToCounterMap(counterMap, value + ':False', wealthData);
            }
        } else {
            addToCounterMap(counterMap, wealthData.TrustDeed_or_Letter_of_wishes__c + ':False', wealthData);
        }
    }
    
    /**
* Adds an item to the counter map.
* @param counterMap The map to add the item to
* @param key The key for the item
* @param wealthData The wealth data to add
*/
    private static void addToCounterMap(Map<String, List<Party_Assets_Funds__c>> counterMap, String key, Party_Assets_Funds__c wealthData) {
        if (!counterMap.containsKey(key)) {
            counterMap.put(key, new List<Party_Assets_Funds__c>());
        }
        counterMap.get(key).add(wealthData);
    }
    
    /**
* Processes wealth data.
* @param tabInfo The map to store tab information
* @param settingsMap The map of document upload settings
* @param counterMap The map of processed wealth data
*/
    private static void processWealthData(Map<String, List<ObjectData>> tabInfo, Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap, Map<String, List<Party_Assets_Funds__c>> counterMap,list<string> AssessmentResList) {
        for (String typeKeyData : counterMap.keySet()) {
            String typeData = typeKeyData.split(':')[0];
            Boolean isFutureFund = Boolean.valueOf(typeKeyData.split(':')[1]);
            if(settingsMap.get(typeData) != null){
                for (ICS_DocumentUploadInfos__mdt metaDataSettings : settingsMap.get(typeData)) {
                    String info = getInfoString(metaDataSettings);
                    String tabKey = isFutureFund ? 'SOF' : 'SOW';
                    if (metaDataSettings.Is_Future_Fund__c == isFutureFund) {
                        if(AssessmentResList.contains(typeData)){
                            set<string>recorIDs = new set<String>();
                            for(Party_Assets_Funds__c fundId: counterMap.get(typeKeyData)){
                                recorIDs.add(fundId.Id);
                            }
                            ObjectData objWrapper = new ObjectData(typeData, counterMap.get(typeKeyData).size(), info,recorIDs);
                            if (!tabInfo.containsKey(tabKey)) {
                                tabInfo.put(tabKey, new List<ObjectData>());
                            }
                            tabInfo.get(tabKey).add(objWrapper);
                        }
                    }
                }
            }
        }
    }
    
    /**
* Processes applicant data.
* @param tabInfo The map to store tab information
* @param settingsMap The map of document upload settings
* @param parentId The ID of the parent record
*/
    private static void processApplicantData(Map<String, List<ObjectData>> tabInfo, Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap, String parentId) {
        if (!Schema.sObjectType.Applicant.isAccessible()) {
            return;
        }
        for (Applicant appData : [SELECT Id, Relationship_with_Applicants__c FROM Applicant
                                  WHERE AccountId = :parentId AND Role = 'Primary Applicant']) {
                                      String tabName = appData.Relationship_with_Applicants__c == 'Co-habiting together' ? 'Cohabitation' :
                                      appData.Relationship_with_Applicants__c == 'Married' ? 'Marriage' : null;
                                      
                                      if (tabName != null && settingsMap.containsKey(tabName)) {
                                          for (ICS_DocumentUploadInfos__mdt metaDataSettings : settingsMap.get(tabName)) {
                                              String info = getInfoString(metaDataSettings);
                                              ObjectData objWrapper = new ObjectData(tabName, 1, info,new set<string>{});
                                              tabInfo.put(tabName, new List<ObjectData>{objWrapper});
                                          }
                                      }
                                  }
    }
    
    /**
* Processes tax details.
* @param tabInfo The map to store tab information
* @param settingsMap The map of document upload settings
* @param parentId The ID of the parent record
*/
    private static void processTaxDetails(Map<String, List<ObjectData>> tabInfo, Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap, String parentId) {
    
        if (!AssessmentQuestionResponse.sObjectType.getDescribe().isAccessible()) {
            return;
        }

        Map<String, Object> binds = new Map<String, Object>{
            'parentId' => parentId,
            'questionText' => 'Please select why the country you live in is different from the country'
        };

        List<AssessmentQuestionResponse> taxDetailRecords = Database.queryWithBinds(
            'SELECT Id, ResponseText FROM AssessmentQuestionResponse WHERE Assessment.accountid = :parentId AND Assessmentquestion.questiontext = :questionText', binds, AccessLevel.SYSTEM_MODE
        );
        for (AssessmentQuestionResponse taxDetailRecord : taxDetailRecords) {
                                                              boolean isProcessed = false;                                         
                                                              String tabName = 'Diplomat Passport';
                                                              if (!isProcessed && settingsMap.containsKey(tabName) && taxDetailRecord.ResponseText == 'I am a diplomat') {
                                                                  for (ICS_DocumentUploadInfos__mdt metaDataSettings : settingsMap.get(tabName)) {
                                                                      String info = getInfoString(metaDataSettings);
                                                                      ObjectData objWrapper = new ObjectData(tabName, 1, info,new set<string>{});
                                                                      tabInfo.put(tabName, new List<ObjectData>{objWrapper});
                                                                      isProcessed = true;
                                                                  }
                                                              }
                                                              
                                                          }
    }
    
    private static void processSpecimenSignature(Map<String, List<ObjectData>> tabInfo, Map<String, List<ICS_DocumentUploadInfos__mdt>> settingsMap) {
        String tabName = 'Specimen Signature';
        if (settingsMap.containsKey(tabName)) {
            for (ICS_DocumentUploadInfos__mdt metaDataSettings : settingsMap.get(tabName)) {
                String info = getInfoString(metaDataSettings);
                ObjectData objWrapper = new ObjectData(tabName, 1, info,new set<string>{});
                tabInfo.put(tabName, new List<ObjectData>{objWrapper});
            }
        }
    }
    
    /**
* Gets the info string from metadata settings.
* @param metaDataSettings The metadata settings
* @return The info string
*/
    private static String getInfoString(ICS_DocumentUploadInfos__mdt metaDataSettings) {    
        return String.isBlank(metaDataSettings.Documents_Recieved__c) ?
            metaDataSettings.InfoBox__c :
        metaDataSettings.InfoBox__c + metaDataSettings.Documents_Recieved__c;
    }
    
    /**
* Creates a ContentVersion record.
* @param data The document data
* @param filepath The file path
* @return The created ContentVersion
*/
    private static ContentVersion createContentVersion(DocumentData data, String filepath,string index) {
        ContentVersion cv = new ContentVersion();
        cv.RecordTypeId = CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT;
        cv.VersionData = EncodingUtil.base64Decode(data.base64);
        cv.Title = data.filename + '-' + index;
        cv.PathOnClient = filepath;
        cv.DocumentType__c = data.documentType;
        cv.DocumentDate__c = data.documentDate;
        cv.Description = data.description;
        return cv;
    }

/**
* Updates a ContentVersion after upload record.
* @param accountId Account ID
* @param contentVersionId The file path
* @param documentType Document type of the uploaded document
* @return The updated ContentVersion
*/
    @AuraEnabled
    public static DocumentData updateContentVersion(Id accountId, Id contentVersionId, String documentType) {
        
        Integer maxSizeInBytes = 6 * 1024 * 1024;
        DocumentData newDocument = new DocumentData();

        try{
            SEL_Account selectAccount = new SEL_Account();
            Account account = selectAccount.selectById(accountId);
            ContentVersion updateCV = new ContentVersion();
            updateCV.RecordTypeId = CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT;
            updateCV.Id = contentVersionId;
            updateCV.Title = account.firstName +' '+account.LastName + '_' +documentType + '_' + String.valueOf(Date.today());
            updateCV.DocumentType__c = documentType;
            updateCV.DocumentDate__c = Date.today();
            update Security.stripInaccessible(AccessType.UPDATABLE, new List<SObject>{ updateCV }, true).getRecords();

            SEL_ContentVersion selectContentVersion = new SEL_ContentVersion();
            ContentVersion contentVersion = new ContentVersion ();
            contentVersion = selectContentVersion.selectContentVersionById(contentVersionId);
            ContentDocumentLink updateContentDocumentLink = new ContentDocumentLink();
            
            List<Id> storedDocuments = new List<Id>();
            for (ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId, ContentDocument.LatestPublishedVersion.DocumentType__c FROM ContentDocumentLink
                                                            WHERE LinkedEntityId = :accountId
                                                            ]) {
                                                                
                if(contentVersionId == cdl.ContentDocument.LatestPublishedVersionId){
                    updateContentDocumentLink =  cdl;
                }
                if(contentVersionId != cdl.ContentDocument.LatestPublishedVersionId && 
                    documentType == cdl.ContentDocument.LatestPublishedVersion.DocumentType__c){
                    storedDocuments.add(cdl.ContentDocumentId);
                }                                              
            }

            newDocument.documentId = updateContentDocumentLink.ContentDocumentId;
            newDocument.fileLimitError = contentVersion.ContentSize < maxSizeInBytes?false:true;

            if(storedDocuments.size()>0 && !newDocument.fileLimitError){
                ICS_CTRL_Documents.deleteStoredDocuments(accountId, storedDocuments);
            }
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
        return newDocument;
    }

    /**
* Creates a ContentDocumentLink record.
* @param contentVersionId The ID of the ContentVersion
* @param recordId The ID of the record to link to
* @return The created ContentDocumentLink
*/
    @testvisible
    private static ContentDocumentLink createContentDocumentLink(Id contentVersionId, Id recordId) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionId WITH SECURITY_ENFORCED].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'I';
        cdl.Visibility = 'AllUsers';
        return cdl;
    }
    
    /**
* Checks if the document type matches the tab name.
* @param documentType The document type
* @param tabName The tab name
* @return True if the document type matches, false otherwise
*/
    private static Boolean isMatchingType(String documentType, String tabName) {
        return documentType.contains(tabName) ||
            (tabName == 'Specimen Signature' && documentType == 'Proof of co-habitation') ||
            (tabName == 'Bank Account' && documentType.contains('3 months of Bank Statements')) ||
            (tabName == 'Letter of Wishes' && documentType == 'SOW Proof of Inheritance or distribution of Trust') ||
            (tabName == 'Owned Property' && documentType == 'SOW Proof of Owned Property') ||  (tabName == 'Owned Property' && documentType == 'SOF Proof of Owned Property') || 
            (tabName == 'Pension/Retirement' && documentType == 'SOF Proof of Pensions') ||
            (tabName == 'Pension/Retirement' && documentType == 'SOW Proof of Pensions') || (tabName == 'Lottery/ Betting Winnings' && documentType == 'SOF Proof of Lottery/Betting Winnings') ||
            (tabName == 'Lottery/ Betting Winnings' && documentType == 'SOW Proof of Lottery/Betting Winnings') || (tabName == 'Diplomat Passport' && documentType == 'ID/Passport/License')
            || (tabName == 'Investment/Stock' && documentType == 'SOW Proof of Investment/Stock')
            || (tabName == 'Investment/Stock' && documentType == 'SOF Proof of Investment/Stock')
            ;
    }
    
    /**
* Determines the appropriate list key based on document type
* @param documentType The type of document
* @return The determined list key (SOF, SOW, or files)
*/
    private static String determineListKey(String documentType) {
        if (String.isBlank(documentType)) {
            return 'files';
        }
        
        if (documentType.contains('SOF')) {
            return 'SOF';
        }
        
        if (documentType.contains('SOW') || 
            documentType.contains('Trust Deed') || 
            documentType.contains('3 months of Bank Statements')) {
                return 'SOW';
            }
        
        return 'files';
    }
    
    /**
* Creates a data map from ContentVersion record
* @param cv The ContentVersion record
* @param index The index for the key 
* @return Map containing the formatted data
*/
    private static Map<String, String> createDataMap(ContentVersion cv, Integer index) {
        return new Map<String, String>{
            'key' => String.valueOf(index),
                'id' => cv?.Id ?? '',
                'docId' => cv?.ContentDocument?.Id ?? '',
                'fileName' => cv?.Title ?? '',
                'date' => cv?.DocumentDate__c == null ? '':String.valueOf(cv.DocumentDate__c),
                    'description' => cv?.Description ?? '',
                    'fileExtension' => cv?.fileExtension ?? ''
                    };
                        }
    
    /**
* Adds document data to the appropriate list.
* @param cv The ContentVersion record
* @param mapDocTypeToNames The map of document types to names
*/
    private static void addToDataList(ContentVersion cv, Map<String, List<Object>> mapDocTypeToNames) {
        String listKey = determineListKey(cv?.DocumentType__c);
        List<Object> dataList = mapDocTypeToNames.get(listKey);
        
        if (dataList == null) {
            dataList = new List<Object>();
            mapDocTypeToNames.put(listKey, dataList);
        }
        
        Map<String, String> dataMap = createDataMap(cv, dataList.size());
        dataList.add(dataMap);
    }
    
    public static void deleteDocumentFiles(id documentId){
        if (!Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            return;
        }
        ContentDocumentLink cdllist=[SELECT ContentDocument.Id,ShareType,ContentDocument.Title, LinkedEntityId,ContentDocument.CreatedDate,ContentDocument.OwnerId,  ContentDocument.FileType FROM ContentDocumentLink where Id =:documentId LIMIT 1];
        if (!Schema.sObjectType.ContentDocument.isAccessible()) {
            return;
        }
        List<ContentDocument> documentsToDelete = [SELECT Id FROM ContentDocument WHERE Id =:cdllist.ContentDocumentId];
        if (!Schema.sObjectType.ContentDocument.isDeletable()) {
            return;
        }
        delete documentsToDelete;
    }
    
    /**
* Updates an document reason for party assets and fund.
* @param id The ID of the party assest and funds.
* @param data reason
*/
    @AuraEnabled
    public static void updateReasonForNoDocument(Id partyAssetFundId, String data) {
        try{
            if (!Schema.sObjectType.Party_Assets_Funds__c.isUpdateable()) {
                LOGGER.warn('User lacks Party_Assets_Funds__c update permission: ' 
                    + UserInfo.getUserId());
            }
            Party_Assets_Funds__c existingData = [Select id,Reason_for_No_documentation__c from Party_Assets_Funds__c WHERE id=:partyAssetFundId];
            existingData.Reason_for_No_documentation__c = data;
            if (!Schema.sObjectType.Party_Assets_Funds__c.isUpdateable()) {
                throw new AuraHandledException('Insufficient permissions to update Party_Assets_Funds__c.');
            }
            update existingData;
        }catch(exception exc){
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    /**
* get reason for party assets and fund.
* @param id The ID of the party assest and funds.
*/
    @AuraEnabled
    public static string getReasonForNoDocument(Id partyAssetFundId) {
        try{
            string reason;
            Party_Assets_Funds__c existingData = [Select id,Reason_for_No_documentation__c from Party_Assets_Funds__c WHERE id=:partyAssetFundId]; 
            if(existingData != null){
                reason = existingData.Reason_for_No_documentation__c;
            }
            return reason;
        }catch(exception exc){
            LOGGER.error(exc.getMessage());
            throw new AuraHandledException(exc.getMessage());
        }
    }
    
    
    /**
* Inner class to represent object data.
*/
    public class ObjectData {
        @AuraEnabled public String infoBox { get; set; }
        @AuraEnabled public String tabName { get; set; }
        @AuraEnabled public Integer recordCount { get; set; }
        @AuraEnabled public set<string> recordIds { get; set; }
        public ObjectData(String tabName, Integer recordCount, String infoBox,set<string>recordIds) {
            this.tabName = tabName;
            this.recordCount = recordCount;
            this.infoBox = infoBox;
            this.recordIds = recordIds;
        }
    }
    
    /**
* Inner class to represent document data.
*/
    public class DocumentData {
        @AuraEnabled public String documentId { get; set; }
        @AuraEnabled public String documentName { get; set; }
        @AuraEnabled public String documentType { get; set; }
        @AuraEnabled public Date documentDate { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String filename { get; set; }
        @AuraEnabled public String mimeType { get; set; }
        @AuraEnabled public String base64 { get; set; }
        @AuraEnabled public String originalFilename { get; set; }
        @AuraEnabled public String originalFiletype { get; set; }
        @AuraEnabled public Boolean fileLimitError { get; set; }

    }
}