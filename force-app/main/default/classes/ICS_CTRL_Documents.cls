/**
 * @description Document storage controller
 * @author Gnitsevich Anton
 * @date January 2023
 */
public without sharing class ICS_CTRL_Documents {
    
    /**
    * @description  Logging framework
    */ 
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS Document Storage - ICS_CTRL_Documents');
    /**
    * @description  Content Version record type for ICS Onboarding
    */     
    private static final Id CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT =
        Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName().get('ICS_Onboarding_Document').getRecordTypeId();
    /**
    * @description  Content Version record type for ICS Onboarding
    */     
    private static final Id PARTYPROFILE_RECORDTYPEID =
        Schema.SObjectType.PartyProfile.getRecordTypeInfosByDeveloperName().get('ICS_PartyProfile').getRecordTypeId();
    /**
    * @description  Reasons for Opportunity Decline to determine the retention date
    */         
    private static final Set<String> OPPORTUNITY_DECLINE_LEGAL_REASONS = new Set<String>{
        'Confirmed PEP', 'Confirmed Adverse Media', 'Confirmed Sanctions', 'Confirmed Watchlist', 'Business Risk Appetite'
    };
    /**
    * @description  Party Profile object  
    */     
    private static final String PARTY_PROFILE_OBJECT = 'PartyProfile';
    /**
    * @description  Account object  
    */     
    private static final String ACCOUNT_OBJECT = 'Account';
    /**
    * @description  DSX document storage   
    */     
    private static final String DSX_STORAGE = 'DSX';

    /**
     * @description Ensures that id is of Account record
     * @param id PartyProfile Id or Account Id
     * @return Id Account id
     */
    public static Id getAccountId(String id) {
        
        Id idRecord = (Id) id;
        if (PARTY_PROFILE_OBJECT == idRecord.getSobjectType().getDescribe().getName()) {
            SEL_PartyProfile selectPartyProfile = new SEL_PartyProfile();
            PartyProfile partyProfile = selectPartyProfile.selectById(idRecord);
            idRecord = partyProfile.AccountId;
        }
        return idRecord;
    }
	
        /**
     * @description Updates Document Type for DSX storage
     * @param String documentType Value selected for document upload
     * @return String Document Type for DSX storage
     */
    public static String checkDocumentType(String documentType) {
        
      	if(documentType.contains('Letter of Wishes')){
             return 'Trust Deed';
        }else if (documentType.contains('Bank Statements')) {
             return '3 months of Bank Statements';
		}else if (documentType.contains('Captain Letter')||documentType.contains('Seafarer Contract')) {
             return 'Proof of Address';
		}else if (documentType.contains('CRA Report')|| documentType.contains('Correspondence')) {
             return 'KYC Files';
		}else if (documentType.contains('Proof of Owned Property')) {
             return documentType.replace('Owned Property','Sale of Property');
		}else if (documentType.contains('Investment/Stock')) {
             return documentType.replace('Investment/Stock','Investment/Dividend');
		}else if (documentType == 'SOW Proof of Sale of Investment'|| documentType == 'SOF Proof of Sale of Investment') {
             return documentType.replace('Investment','Investments');
		}else {
             return documentType;
		}
    }
    
    /**
     * @description Ensures that id is of Account record
     * @param id  Account Id
     * @return ClientNumberDetails clientNumber/BP id & sector code 
     */
    public static ClientNumberDetails checkClientNumber(String id) {
    
       	Opportunity opportunity = getOpportunity(id);
       	SEL_ApplicationForm selectApplicationForm = new SEL_ApplicationForm();
 		List<ApplicationForm> applicatioFormList = selectApplicationForm.selectByOpportunityId(opportunity.Id);
        SEL_FinServ_FinancialAccount selectFinancialAccount = new SEL_FinServ_FinancialAccount();     
		List<FinServ__FinancialAccount__c> financialAccountList  = new List<FinServ__FinancialAccount__c>();  
 		Set <Id> accountIds = new Set<Id>();

        if(applicatioFormList.size()>1){
                accountIds.add(opportunity.AccountId);
            
            financialAccountList = selectFinancialAccount.selectByPrimaryOwnerIds(accountIds);
        }

        Id accountId = getAccountId(id);
        ICS_SEL_Account selectAccount = new ICS_SEL_Account();
        Account account = selectAccount.getAccount(accountId);
        ClientNumberDetails clientNumberDetails = new ClientNumberDetails ();
        String clientNumber;
        if(applicatioFormList.size()>1 && financialAccountList.size()>0){
           clientNumber = financialAccountList[0].ExternalCIFId__c.remove('_'+financialAccountList[0].CurrencyIsoCode);
        }else if(applicatioFormList.size()==1){
           clientNumber = account.ExternalCIFId__c; 
        }

        if ( String.IsNotBlank(clientNumber) && clientNumber.left(2) == '00') {
            clientNumberDetails.clientNumber = clientNumber.right(clientNumber.length() - 2);
        }else if(String.IsNotBlank(clientNumber)){
            clientNumberDetails.clientNumber = clientNumber;
        }else {
            clientNumberDetails.clientNumber = null;
        }

        if (account.ICS_Country_of_Residence__c != 'ZA' && String.IsNotBlank(account.ICS_Country_of_Residence__c)) {
            clientNumberDetails.sectorCode = '1008';
        }
        else {
            clientNumberDetails.sectorCode = '1002';
        }
        return clientNumberDetails;
    }
    
    /**
     * @description Client Number Details: clientNumber/BP id & RM sector code 
     */
    public class ClientNumberDetails {
       
        /**
        * @description  Client Number/BP id & sector code
        */ 
        public String clientNumber;
        /**
        * @description  Sector code based on the client Country of Residence
        */         
        public String sectorCode;
    }
    

        /**
     * @description Ensures that id is of Application__c record
     * @param id PartyProfile Id or Account Id
     * @return Id PartyProfile id
     */
    public static Set<Id> getPartyProfileIds(String id) {
        
        Id idRecord = (Id) id;
        Set<Id> partyProfileIds = new Set<Id> ();
        if (ACCOUNT_OBJECT == idRecord.getSobjectType().getDescribe().getName()) {
            SEL_PartyProfile selectPartyProfile = new SEL_PartyProfile();
            List<PartyProfile> partyProfileList= new List<PartyProfile>();
            partyProfileList = selectPartyProfile.selectByAccountId(idRecord);
            partyProfileIds = (new Map<Id,SObject>(partyProfileList)).keySet();
            partyProfileList = null;
        }
        else {
            partyProfileIds = new Set<Id>{ idRecord };
        }
        return partyProfileIds;
    }
    
     /**
     * @description This method sends all documents to storage and deletes them from SF
     * @param id Party Profile Id or Account Id
     */

    public static void storeDocumentsUpdate(String id) {
        
        Id idRecord = (Id) id;
        SEL_ApplicationForm selectApplicationForm = new SEL_ApplicationForm();
 		List<ApplicationForm> applicatioFormList = selectApplicationForm.selectByOpportunityId(idRecord);
 		Set <Id> applicatioFormIds = new Set<Id>();
        for(ApplicationForm appForm : applicatioFormList){
                applicatioFormIds.add(appForm.Id);
        }
        
        Map<Id,Id> partyProfileAccountMap = new Map<Id,Id>();
        SEL_Applicant selectApplicant = new SEL_Applicant ();
 		List<Applicant> applicantList = selectApplicant.selectByApplicationFormIds(applicatioFormIds);
        if(applicantList.size()>0){
            for(Applicant applicant : applicantList){
                partyProfileAccountMap.put(applicant.PartyProfileId, applicant.AccountId);
            }
        } 
              
		ICS_SEL_ContentDocumentLink selectContentDocumentLink = new ICS_SEL_ContentDocumentLink ();
		List<ContentDocumentLink> links = selectContentDocumentLink.selectContentDocumentLinks(partyProfileAccountMap.keySet());
        links.addAll(selectContentDocumentLink.selectContentDocumentLinks(new Set<Id>(partyProfileAccountMap.values())));

        Map<Id,Id> linkedEntityIdMap = new Map<Id,Id>();
  		List<Id> documentIds = new List<Id>();
		for (ContentDocumentLink link : links) {
			documentIds.add(link.ContentDocumentId);
            linkedEntityIdMap.put(link.ContentDocumentId, link.LinkedEntityId);
		}
        
		SEL_ContentVersion selectContentVersion = new SEL_ContentVersion ();
        List<ContentVersion> contentVersions = new  List<ContentVersion> ();
		contentVersions = selectContentVersion.selectContentVersionByIds(documentIds);
        
        List<ContentVersion> latestContentVersions = new  List<ContentVersion> ();
        for (ContentVersion contentVersion: contentVersions){
			if(contentVersion.Islatest){
                    latestContentVersions.add(contentVersion);
			}
		}
        
        for (ContentVersion contentVersion: latestContentVersions){
            
            Id linkedEntityId = linkedEntityIdMap.containsKey(contentVersion.ContentDocumentId) ? linkedEntityIdMap.get(contentVersion.ContentDocumentId) :null;
            ICS_FLOW_StoreDocuments.Requests request = new ICS_FLOW_StoreDocuments.Requests();
            request.linkedEntityIds = partyProfileAccountMap.containsKey(linkedEntityId) ? partyProfileAccountMap.get(linkedEntityId) :linkedEntityId;
            request.contentVersion = contentVersion;
            List<ICS_FLOW_StoreDocuments.Requests> requestList = new List<ICS_FLOW_StoreDocuments.Requests>();
            requestList.add(request);       
            ICS_FLOW_StoreDocuments.invokeStoreDocuments(requestList);
        } 
    }

    /**
     * @description This method returns Party Profile record details
     * @param id Party Profile Id or Account Id
     * @return PartyProfile record
     */
    @AuraEnabled
    public static PartyProfile getPartyProfile(String id) {

        Id idRecord = (Id) id;
        PartyProfile partyProfile = new PartyProfile();

        try {
			Set<Id> partyProfileIds = new Set<Id>();
			partyProfileIds = getPartyProfileIds(idRecord); 
			SEL_PartyProfile selectPartyProfile = new SEL_PartyProfile();
			List<PartyProfile> partyProfileList = new List<PartyProfile>();
			partyProfileList = selectPartyProfile.selectByIds(partyProfileIds);
			for(PartyProfile partyProfileRecord : partyProfileList){
				if(Schema.SObjectType.PartyProfile.getRecordTypeInfosById().get(partyProfileRecord.RecordTypeId).getDeveloperName() == 'ICS_PartyProfile'){
					partyProfile = partyProfileRecord;
					return partyProfile;                    
				}
			}
        }catch(Exception ex) {
            String message = String.format(
                'Get Party Profile exception -['+idRecord.getSobjectType().getDescribe().getName()+' ID:] {0} [Exception Message:] {1}',
                new List<Object> { idRecord, ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Party Profile error. Please contact your System Administrator.');   
        }
        return null;
    }
    /**
     * @description This method returns Account record details
     * @param id Party Profile Id or Account Id
     * @return Account record
     */
    @AuraEnabled
    public static Account getAccount(String id) {

        Id accountId = getAccountId(id);
		Account account = new  Account();
        try {

            ICS_SEL_Account selectAccount = new ICS_SEL_Account();
            account = selectAccount.getAccount(accountId);
        }catch(Exception ex) {
            String message = String.format(
                'Get Account exception -['+accountId.getSobjectType().getDescribe().getName()+' ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Account error. Please contact your System Administrator.');   
        }
        return account;
    }
    /**
     * @description This method returns Opportunity record details
     * @param id PartyProfile Id or Account Id
     * @return Opportunity record
     */
    @AuraEnabled
    public static Opportunity getOpportunity(String id) {
        
        PartyProfile partyProfile =  getPartyProfile(id);
        Id idRecord = getAccountId(id);
        Opportunity opportunity = new Opportunity ();
		Id opportunityId;
        
        try {
            if (ACCOUNT_OBJECT == idRecord.getSobjectType().getDescribe().getName() ) {
                SEL_Applicant selectApplicant = new SEL_Applicant ();
                List<Applicant> applicantList = selectApplicant.selectByAccountIds(new Set<Id>{idRecord});
                ICS_SEL_Opportunity selectOpportunity = new ICS_SEL_Opportunity();
                for(Applicant applicant:applicantList){
                    if(applicant.PartyProfileId == partyProfile.Id){
                		opportunityId = applicant.ApplicationForm.OpportunityId;
                    }
                }
                if(opportunityId != null){
                  opportunity = selectOpportunity.getOpportunity(opportunityId);
                }
            } 
        } catch(Exception ex) {
            String message = String.format(
                'Get Opportunity exception -['+idRecord.getSobjectType().getDescribe().getName()+' ID:] {0} [Exception Message:] {1}',
                new List<Object> { idRecord, ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Opportunity error. Please contact your System Administrator.');   
        }
        return opportunity;
    }

     /**
     * @description This method returns document stream from DSX
     * @param accountId account Id 
     * @param clientNumber BP id to be sent to DSX  
     * @param storage  String to identify DSX storage 
     * @return ID Queued job ID
     */
    public static ID updateClientNumber(String accountId, String clientNumber, String storage) {
        
        Opportunity opportunity = getOpportunity(accountId);
        SEL_ApplicationForm selectApplicationForm = new SEL_ApplicationForm();
 		List<ApplicationForm> applicatioFormList = selectApplicationForm.selectByOpportunityId(opportunity.Id);
		ID jobID;
        
        for(ApplicationForm applicatioForm : applicatioFormList){
            ClientNumberDetails clientNumberDetails = new ClientNumberDetails ();
        	clientNumberDetails = checkClientNumber(applicatioForm.AccountId);
        	
        	if (storage == DSX_STORAGE) {
           		ICS_API_DSX.updateRetention(accountId, '9999-12-31');
            	jobID = System.enqueueJob(new ICS_QUE_DSX(applicatioForm.AccountId, clientNumberDetails.clientNumber, clientNumberDetails.sectorCode));
        	}
        }
       
        return jobID;
    }
    
    /**
     * @description This method saves a document to SF
     * @param recordId record to relate document to
     * @param data DocumentData object containing document's base64 data and details
     * @return String DSX response result
     */
    @AuraEnabled
    public static String saveDocument(String recordId, DocumentData data) {
        ContentVersion cv = new ContentVersion();
        try {
            String fileExtension = data.originalFilename.substringAfterLast('.');
            String filepath = data.filename + '.' + fileExtension;
           
            cv.RecordTypeId = CONTENTVERSION_RECORDTYPEID_ONBOARDINGDOCUMENT;
            cv.VersionData = EncodingUtil.base64Decode(data.base64);
            cv.Title = data.filename;
            cv.PathOnClient = filepath;
            cv.DocumentType__c = data.documentType;
            cv.DocumentDate__c = data.documentDate;
            cv.Description = data.description;
            
            List<SObject> cvObject = new List<SObject>{ cv };
            SObjectAccessDecision contentVersions = Security.stripInaccessible(AccessType.CREATABLE, cvObject);
            insert contentVersions.getRecords();
            cv.Id = contentVersions.getRecords()[0].Id;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            SEL_ContentVersion selectContentVersion = new SEL_ContentVersion();
            ContentVersion contentVersion = new ContentVersion ();
            contentVersion = selectContentVersion.selectContentVersionById(cv.Id);
            cdl.ContentDocumentId = contentVersion.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'I';
            List<SObject> cdlObject = new List<SObject>{ cdl };
            SObjectAccessDecision contentDocumentLink = Security.stripInaccessible(AccessType.CREATABLE, cdlObject);
            insert contentDocumentLink.getRecords();
            
        } catch(Exception ex) {
            String message = String.format(
                'Save Document exception - [LinkedEntityId:] {0} [Exception Message:] {1}',
                new List<Object> { recordId, ex.getMessage() }
            );
            LOGGER.error(message);
            if (cv.Id != null && Schema.sObjectType.ContentDocument.isDeletable()) {
                SEL_ContentVersion selectContentVersion = new SEL_ContentVersion();
                ContentVersion contentVersion = new ContentVersion ();
                contentVersion = selectContentVersion.selectContentVersionById(cv.Id);
                List<ContentDocument> contentDoc = new List<ContentDocument> ();
                contentDoc = CMN_DAL_ContentDocument.getContentDocumentsById(new Set<Id>{contentVersion.ContentDocumentId});
                delete contentDoc;
            }
            if(!Test.isRunningTest()){
                throw new AuraHandledException('Documents upload on Salesforce failed. Please contact your System Administrator.');   
            }
        }
        return cv.Id;
    }

    /**
     * @description This method sends all documents to storage and deletes them from SF
     * @param id Party Profile Id or Account Id
     * @param storage Storage application name
     * @param contentVersion File to be stored in DSX
     * @return String result
     */
    public static String storeDocuments(String id, String storage, ContentVersion contentVersion) {
        
		String result;                 
       	Id accountId = getAccountId(id);
		Set<Id> partyProfileIds = getPartyProfileIds(id);
       	List<Id> storedDocumentIds = new List<Id>();
        try {
            If(String.IsNotBlank(contentVersion.DocumentType__c)){
				contentVersion.DocumentType__c = checkDocumentType(contentVersion.DocumentType__c);
            }
            Integer statusCode = ICS_API_DSX.storeDocument(accountId, contentVersion);
            if (statusCode == CMN_API_HttpBase.HTTP_OK) {
            	storedDocumentIds.add(contentVersion.ContentDocumentId);
            }                
			List<Id> lStrings = new List<Id>(partyProfileIds);

			for(Id partyProfileId : lStrings){
				ICS_API_DSX.updateRetention(accountId, '9999-12-31');
            }

            if (storedDocumentIds.isEmpty()) {  
                result = 'No documents stored';
            }else{
                result = deleteStoredDocuments(accountId, storedDocumentIds);
            }
        } catch(Exception ex) {
            String message = String.format(
                'Store Document exception - [AccountId:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
            result = message;
        }
        return result;
    }

      /**
     * @description Delete stored documents after submssion to DSX 
     * @param accountId Account ID
     * @param storedDocumentIds Stored documents ID    
     * @return String result
     */
    public static String deleteStoredDocuments(Id accountId, List<Id> storedDocumentIds) {

        String result;
        try {
            List<String> documentDeleteFailed = new List<String>();
            Database.DeleteResult[] deleteResults = Database.delete(storedDocumentIds, true, AccessLevel.SYSTEM_MODE);
            for (Database.DeleteResult deleteResult : deleteResults) {                   
                if (!deleteResult.isSuccess()) {
                    for (Database.Error err : deleteResult.getErrors()) {
                        String message = String.format(
                            'ContentDocument delete failed - [Account ID:] {0} [Status Code:] {1} [Message:] {2} [Fields:] {3}',
                            new List<Object> { accountId, err.getStatusCode(), err.getMessage(), err.getFields() }
                            );
                        LOGGER.error(message);
                        documentDeleteFailed.add(message);
                    }
                }
            }
            if(documentDeleteFailed.isEmpty()){
                result = 'ContentDocument delete successful for Account: '+accountId;
            }else{
                result = 'ContentDocument delete failed for Account: '+accountId;
				LOGGER.error(result);
            }
        } catch(Exception ex) {
            String message = String.format(
                            'ContentDocument delete failed - [Account ID:] {0} [Exception Message:] {1}',
                            new List<Object> { accountId, ex.getMessage()}
                            );
            LOGGER.error(message);
            result = 'ContentDocument delete failed for Account: '+accountId;
        }
       return result;   

    }
    
    /**
     * @description This method resets storage retention dates for specified accounts
     * @param accountId List of Account Ids
     * @param storage Storage name
     * @return Integer DSX status code after retention date update
     */
    public static Integer resetRetentionDates(String accountId, String storage) {
        
        Integer statusCode;
        if (storage == DSX_STORAGE) {
            Date retentionDate = Date.newInstance(9999, 12, 31);
            String retentionDateString = retentionDate.year() + '-' +
                (retentionDate.month() < 10 ? '0' + retentionDate.month() : '' + retentionDate.month()) + '-' +
                (retentionDate.day() < 10 ? '0' + retentionDate.day() : '' + retentionDate.day());
            statusCode = ICS_API_DSX.updateRetention(accountId, retentionDateString);
        }
        return statusCode;
    }

    /**
     * @description This method calculates retention date string YYYY-MM-DD based on application's Opportunity record stage
     * @param partyProfileId PartyProfile Id
     * @return String Retention date result
     */
    public static String calculateRetentionDate(Id partyProfileId) {

        Opportunity opportunity = getOpportunity(partyProfileId);
        String retentionDateString;

        Date retentionDate;
        if (opportunity.StageName == 'Closed Won') {
            retentionDate = Date.newInstance(9999, 12, 31); 
        }
        else if (opportunity.StageName == 'Closed Lost') {
            retentionDate = Date.today().addYears(1);
        }
        else if (opportunity.StageName == 'Closed Declined' && OPPORTUNITY_DECLINE_LEGAL_REASONS.contains(opportunity.ICS_Decline_Reason__c)) {
            retentionDate = Date.newInstance(9999, 12, 31); 
        }
        else if (opportunity.StageName == 'Closed Declined' ) {
            retentionDate = Date.today().addYears(1);
        }
        else {
            retentionDate = Date.today().addYears(1);
        }
        retentionDateString =
            retentionDate.year() + '-' +
            (retentionDate.month() < 10 ? '0' + retentionDate.month() : '' + retentionDate.month()) + '-' +
            (retentionDate.day() < 10 ? '0' + retentionDate.day() : '' + retentionDate.day());
        return retentionDateString;
    }

    /**
     * @description This method returns list of documents stored in SF
     * @param id PartyProfile Id or Account Id
     * @return List<ContentVersion> List of documents on Salesforce
     */
    @AuraEnabled
    public static List<ContentVersion> getLocalDocuments(String id) {
       
        Set<Id> partyProfileIds = getPartyProfileIds(id);
        Id accountId = getAccountId(id);

        List<ContentVersion> contentVersions = new  List<ContentVersion> ();
        List<ContentVersion> latestContentVersions = new  List<ContentVersion> ();
        try {
            ICS_SEL_ContentDocumentLink selectContentDocumentLink = new ICS_SEL_ContentDocumentLink ();
            List<ContentDocumentLink> links = selectContentDocumentLink.selectContentDocumentLinks(partyProfileIds);
			links.addAll(selectContentDocumentLink.selectContentDocumentLinks(new Set<Id>{accountId}));
                        
            List<Id> documentIds = new List<Id>();
            for (ContentDocumentLink link : links) {
                    documentIds.add(link.ContentDocumentId);
            }
            SEL_ContentVersion selectContentVersion = new SEL_ContentVersion ();
            contentVersions = selectContentVersion.selectContentVersionByIds(documentIds);

            for (ContentVersion contentVersion: contentVersions){
                if(contentVersion.Islatest){
                    latestContentVersions.add(contentVersion);
                }
            }

        } catch(Exception ex) {
            String message = String.format(
                'Stored document exception -[Party Profile ID:] {0} [Exception Message:] {1}',
                new List<Object> { partyProfileIds, ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Documents stored on Salesforce could not be retrieved. Please contact your System Administrator.');   
        }
        return latestContentVersions;
    }
    
    /**
     * @description This method returns documents stored in DSX for specified client, recursive
     * @param accountId Account Id
     * @param clientNumber BP Id from Account record
     * @param page Page number of the results to fetch from DSX.
     * @return String
     */
    public static String searchPayload(String accountId, String clientNumber, String sectorCode, Integer page){
          
        JSONGenerator searchBody = JSON.createGenerator(true);
            searchBody.writeStartObject();
            searchBody.writeStringField('salesforceid', accountId );
            searchBody.writeNumberField('page', page);
            searchBody.writeNumberField('pageSize', 50);
            if(String.IsNotBlank(clientNumber)){
                searchBody.writeStringField('clientNo',clientNumber);
                searchBody.writeStringField('sectorCode', sectorCode );
            } 
        searchBody.writeEndObject();
        return searchBody.getAsString();
        
    }

    /**
     * @description This method returns list of documents stored in DSX
     * @param id PartyProfile Id or Account Id
     * @param storage Storage place name
     * @return List<DocumentData> list of stored documents on DSX
     */
    @AuraEnabled
    public static List<DocumentData> getStoredDocuments(String id, String storage) {

        Id accountId = getAccountId(id);
        List<DocumentData> storedDocuments;
        try {
            if (storage == DSX_STORAGE) {
                ClientNumberDetails clientNumberDetails = checkClientNumber(id);
                storedDocuments = ICS_API_DSX.searchDocuments(accountId, clientNumberDetails.clientNumber,clientNumberDetails.sectorCode, 1);
            }
        }catch(Exception ex) {
            String message = String.format(
                'Stored document exception -[Account ID:] {0} [Exception Message:] {1}',
                new List<Object> { accountId, ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Documents stored on DSX could not be retrieved. Please contact your System Administrator.');   
        }
        return storedDocuments;
    }

    /**
     * @description This method returns document stream from DSX
     * @param documentId Document Id
     * @param storage Storage name
     * @return DocumentData DSX response code
     */
    @AuraEnabled
    public static DocumentData downloadDocument(String documentId, String storage) {
        
        DocumentData result;
        try {
            if (storage == DSX_STORAGE) {
                result = ICS_API_DSX.downloadDocument(documentId);
            }
        }catch(Exception ex) {
            String message = String.format(
                'Download document exception - [Exception Message:] {0}',
                new List<Object> {ex.getMessage() }
            );
            LOGGER.error(message);
            throw new AuraHandledException('Document download from DSX failed. Please contact your System Administrator.');   
        }
        return result;
    }
    
        
    /**
     * @description Document Data
     */
    public class DocumentData {
        /**
       * @description  Document id when document is stored in DSX
       */        
        @AuraEnabled public String documentId { get; set; }
       /**
       * @description  Document name
       */        
        @AuraEnabled public String documentName { get; set; }
       /**
       * @description  DSX document type
       */        
        @AuraEnabled public String documentType { get; set; }
       /**
       * @description  Document received date
       */        
        @AuraEnabled public Date documentDate { get; set; }
       /**
       * @description  Document retention date
       */        
        @AuraEnabled public Date retentionDate { get; set; }
       /**
       * @description  File description
       */        
        @AuraEnabled public String description { get; set; }
       /**
       * @description  File name
       */        
        @AuraEnabled public String filename { get; set; }
       /**
       * @description  Mime type for document download
       */        
        @AuraEnabled public String mimeType { get; set; } 
       /**
       * @description  Binary data
       */        
        @AuraEnabled public String base64 { get; set; }
       /**
       * @description  File name
       */        
        @AuraEnabled public String originalFilename { get; set; }
       /**
       * @description  File type stored
       */        
        @AuraEnabled public String originalFiletype { get; set; }
       /**
       * @description  DSX client number/BP number Account id
       */        
        @AuraEnabled public String clientNo { get; set; }
       /**
       * @description  DSX client name
       */        
        @AuraEnabled public String clientName { get; set; }
        /**
       * @description  Salesforce Account id
       */   
        @AuraEnabled public String salesForceId { get; set; }

    }
}