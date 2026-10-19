/***********************************************************
* @description SFP-34697 Class used to process RelyComply to process Documents into salesforce
* @author Ikyatha Naidu
* @date 31/08/2024
******************************************************
* Last Modified By  IKYATHA NAIDU
* Last Modified Date 31/08/2024
* Last Modified Description: Updated to latest version 
******************************************************
* Last Modified By  Ridhima Saxena
* Last Modified Date 28/01/2025
* Last Modified Description: SFP-54329: Updated createContentVersions logic to retrieve CRA Report 
							 documents based on date criteria and enhanced handling to better support SCA scenarios.
******************************************************
*/ 
public without sharing class ICS_API_CRACreateDocument {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ICS_API_CRACreateDocument');
      public class request {
        public String CustomerId;
        public String Document;
        public String DocumentType;
        public String DocumentFormat;
        public String created;
    }
    private ICS_API_CRACreateDocument(){}
    public class response {
        public String status;
        public String errorMessage;
        public String documentId;
        public String customerIdentifier;
    }
    Public static string responseCall(string requestBody){
       
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        List<Object> requestObjects = (List<Object>) jsonMap.get('requests');
        
        List<Request> requestList = new List<Request>();
        
        for (Object obj : requestObjects) {
            Request req = (Request) JSON.deserialize(JSON.serialize(obj), Request.class);
            requestList.add(req);
        }
        List<response> responseList= processDocuments(requestList);
        return json.serialize(responseList);
    }
    Public static List<response> processDocuments(List<request> requests){
        Map<Id, Account> accountMap = getAccountMap(requests);
        Map<String, ICS_RelyComply_Document_Mapping__mdt> documentMappings = ICS_RelyComply_Document_Mapping__mdt.getAll();
        Map<String, ContentVersion> customerIdToContentVersionMap = createContentVersions(requests, accountMap, documentMappings);
        Map<Id, Id> contentVersionIdToDocumentIdMap = getContentDocumentIds(customerIdToContentVersionMap.values());
    
        createContentDocumentLinks(customerIdToContentVersionMap, contentVersionIdToDocumentIdMap, accountMap);
        
        return generateResponses(requests, accountMap, customerIdToContentVersionMap, contentVersionIdToDocumentIdMap);

    }
 	private static Map<Id, Account> getAccountMap(List<request> requests) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access Account.');
        }
        Set<String> accountIDs = new Set<String>();
        for(request eachRequest : requests) {
            accountIDs.add(eachRequest.CustomerId);
        }
        return new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIDs]);
    }
    /**
    * @description Processes incoming RelyComply document requests and creates ContentVersion records
    *              in Salesforce. Deduplicates requests by document type per account, checks for
    *              existing documents to avoid duplicates, replaces old CRA Reports with new ones,
    *              and skips insertion for all other already-existing document types.
    * @author Ridhima Saxena | 29-05-2026
    * @param requests          List of incoming document requests from RelyComply
    * @param accountMap        Map of Account Id to Account for all requested customer Ids
    * @param documentMappings  Custom metadata map for RelyComply document type mapping
    * @return Map<String, ContentVersion> Map of inserted documents keyed by accountId_docType
    **/
      private static Map<String, ContentVersion> createContentVersions(
        List<request> requests, 
        Map<Id, Account> accountMap, 
        Map<String, ICS_RelyComply_Document_Mapping__mdt> documentMappings
        ) {
        Map<String, ContentVersion> finalDocsToInsert = new Map<String, ContentVersion>();
        for(request eachRequest : requests) {
            if(!accountMap.containsKey(eachRequest.CustomerId)) {
                continue;
            }
            ContentVersion newDoc = createContentVersion(eachRequest, documentMappings);
            String key = eachRequest.CustomerId + '_' + newDoc.DocumentType__c;
            if(!finalDocsToInsert.containsKey(key)) {
                finalDocsToInsert.put(key, newDoc);
            }
        }
        Set<Id> accountIds = new Set<Id>(accountMap.keySet());
        Set<String> existingDocKeys = buildExistingDocKeys(accountIds, finalDocsToInsert);
        return insertAllowedDocuments(finalDocsToInsert, existingDocKeys);
    }
    
    /**
    * @description Builds a set of existing document keys for accounts to prevent duplicate inserts.
    *              Queries existing ContentDocumentLinks and ContentVersions, marks old CRA Reports
    *              for deletion so they can be replaced, and returns keys of all other existing docs.
    * @author Ridhima Saxena | 29-05-2026
    * @param accountIds        Set of Account Ids to check existing documents against
    * @param finalDocsToInsert Map of key→ContentVersion representing incoming docs to be inserted
    * @return Set<String>      Keys (accountId_docType) of already-existing non-CRA documents
    **/
    private static Set<String> buildExistingDocKeys(
    Set<Id> accountIds,
    Map<String, ContentVersion> finalDocsToInsert
    ) {
        Set<String> existingDocKeys = new Set<String>();
        if(accountIds.isEmpty()) {
            return existingDocKeys;
        }
        if (!Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ContentDocumentLink.');
        }
        Map<Id, Id> cdlDocToLinkedEntity = buildCdlDocToLinkedEntityMap(accountIds);
        if(cdlDocToLinkedEntity.isEmpty()) {
            return existingDocKeys;
        }
        return buildExistingKeysFromContentVersions(cdlDocToLinkedEntity, finalDocsToInsert);
    }
    /**
    * @description Queries ContentDocumentLinks for the given account Ids and builds a map
    *              of ContentDocumentId to LinkedEntityId for downstream processing.
    * @author Ridhima Saxena | 29-05-2026
    * @param accountIds Set of Account Ids to query ContentDocumentLinks against
    * @return Map<Id, Id> Map of ContentDocumentId to its LinkedEntityId
    **/
    private static Map<Id, Id> buildCdlDocToLinkedEntityMap(Set<Id> accountIds) {
        Map<Id, Id> cdlDocToLinkedEntity = new Map<Id, Id>();
        for(ContentDocumentLink cdl : [
            SELECT ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :accountIds
        ]) {
            cdlDocToLinkedEntity.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }
        return cdlDocToLinkedEntity;
    }
    /**
    * @description Queries ContentVersions for the given document Ids, classifies each as either
    *              a CRA Report to replace or an existing document to skip, deletes old CRA Reports,
    *              and returns the set of existing document keys for deduplication.
    * @author Ridhima Saxena | 29-05-2026
    * @param cdlDocToLinkedEntity Map of ContentDocumentId to LinkedEntityId
    * @param finalDocsToInsert    Incoming docs map used to check if CRA Report replacement applies
    * @return Set<String> Keys (accountId_docType) of already-existing non-CRA documents
    **/
    private static Set<String> buildExistingKeysFromContentVersions(
        Map<Id, Id> cdlDocToLinkedEntity,
        Map<String, ContentVersion> finalDocsToInsert
    ) {
        if (!Schema.sObjectType.ContentVersion.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ContentVersion.');
        }
        Set<String> existingDocKeys = new Set<String>();
        List<ContentDocument> craDocsToDelete = new List<ContentDocument>();
        for(ContentVersion cv : [
            SELECT ContentDocumentId, DocumentType__c, DocumentDate__c
            FROM ContentVersion
            WHERE ContentDocumentId IN :cdlDocToLinkedEntity.keySet()
            AND IsLatest = true
        ]) {
            classifyExistingDocument(cv, cdlDocToLinkedEntity, finalDocsToInsert, existingDocKeys, craDocsToDelete);
        }
        if(!craDocsToDelete.isEmpty()) {
            deleteCraDocuments(craDocsToDelete);
        }
        return existingDocKeys;
    }
    /**
    * @description Evaluates a single ContentVersion and either marks it as a CRA Report
    *              for deletion (if a replacement is incoming) or adds its key to the
    *              existing doc keys set to prevent duplicate insertion.
    * @author Ridhima Saxena | 29-05-2026
    * @param cv                   The ContentVersion record being evaluated
    * @param cdlDocToLinkedEntity Map of ContentDocumentId to LinkedEntityId
    * @param finalDocsToInsert    Incoming docs map to check if this doc type is being replaced
    * @param existingDocKeys      Set to add the key into if doc should not be replaced
    * @param craDocsToDelete      List to add ContentDocument into if it is a CRA Report to replace
    **/
    private static void classifyExistingDocument(
        ContentVersion cv,
        Map<Id, Id> cdlDocToLinkedEntity,
        Map<String, ContentVersion> finalDocsToInsert,
        Set<String> existingDocKeys,
        List<ContentDocument> craDocsToDelete
    ) {
        Id linkedEntityId = cdlDocToLinkedEntity.get(cv.ContentDocumentId);
        String key = linkedEntityId + '_' + cv.DocumentType__c;
        if(cv.DocumentType__c == 'CRA Report' && finalDocsToInsert.containsKey(key)) {
            craDocsToDelete.add(new ContentDocument(Id = cv.ContentDocumentId));
        } else {
            existingDocKeys.add(key);
        }
    }
    
    /**
    * @description Deletes a list of CRA Report ContentDocuments using partial success mode.
    *              Ignores ENTITY_IS_DELETED errors to handle concurrent duplicate RC webhook calls.
    * @author  Ridhima Saxena | 29-05-2026
    * @param craDocsToDelete List of ContentDocument records to delete
    **/
    private static void deleteCraDocuments(List<ContentDocument> craDocsToDelete) {
        if (!Schema.sObjectType.ContentDocument.isDeletable()) {
            throw new AuraHandledException('Insufficient permissions to delete ContentDocument.');
        }
        List<Database.DeleteResult> deleteResults = Database.delete(craDocsToDelete, false);
        for(Database.DeleteResult dr : deleteResults) {
            if(!dr.isSuccess()) {
                for(Database.Error err : dr.getErrors()) {
                    if(err.getStatusCode() != StatusCode.ENTITY_IS_DELETED) {
                        LOGGER.error('Delete failed: ' + err.getMessage());
                    }
                }
            }
        }
    }
    
    /**
    * @description Filters incoming documents against existing doc keys and inserts only new ones.
    *              Returns a map of key→ContentVersion for all successfully inserted documents.
    * @author  Ridhima Saxena | 29-05-2026
    * @param finalDocsToInsert Map of key→ContentVersion of all candidate docs from the request
    * @param existingDocKeys   Set of keys representing docs already present in Salesforce
    * @return Map<String, ContentVersion> Map of inserted documents keyed by accountId_docType
    **/
    private static Map<String, ContentVersion> insertAllowedDocuments(
        Map<String, ContentVersion> finalDocsToInsert,
        Set<String> existingDocKeys
    ) {
        if (!Schema.sObjectType.ContentVersion.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create ContentVersion.');
        }
        Map<String, ContentVersion> customerIdToContentVersionMap = new Map<String, ContentVersion>();
        List<ContentVersion> contentsToInsert = new List<ContentVersion>();
        for(String key : finalDocsToInsert.keySet()) {
            if(!existingDocKeys.contains(key)) {
                ContentVersion doc = finalDocsToInsert.get(key);
                contentsToInsert.add(doc);
                customerIdToContentVersionMap.put(key, doc);
            }
        }
        if(!contentsToInsert.isEmpty()) {
            insert contentsToInsert;
        }
        return customerIdToContentVersionMap;
    }
    /**
    * @description Method to set documents
    * @author Ikyatha Naidu | 20-04-2025 
    * @param eachRequest 
    * @param documentMappings 
    * @return ContentVersion 
    **/
	@TestVisible    
    private static ContentVersion createContentVersion(
        request eachRequest, 
        Map<String, ICS_RelyComply_Document_Mapping__mdt> documentMappings
    ) {
        ContentVersion contVerFile = new ContentVersion();
        contVerFile.VersionData = EncodingUtil.base64Decode(eachRequest.Document);
        contVerFile.ContentLocation = 'S';
    
        String filepath;
        String dataToday = String.valueOf(Date.today());
    
        Account accData = getAccountData(eachRequest.CustomerId);

        List<String> fileNameParts = eachRequest.DocumentType.split('\\.');
        if (documentMappings.containsKey(fileNameParts[0])) {
            contVerFile.DocumentType__c = documentMappings.get(fileNameParts[0]).Document_Type__c;
        }else {
             contVerFile.DocumentType__c = 'ID-PAL Files';
        }
            String formattedDocumentType = contVerFile.DocumentType__c.replaceAll('[\\s/]+', '-');
            
            if(eachRequest.DocumentType == 'gbg_identity_json'){
                 createIdentityDocument(eachRequest.Document, eachRequest.CustomerId);
            }
            if(eachRequest.documentformat != ''){
                filepath = accData.FirstName + '-' + accData.LastName + '_' + formattedDocumentType + '_' + dataToday + '.'+eachRequest.documentformat;
            }else if(fileNameParts.size()==2){
                filepath = accData.FirstName + '-' + accData.LastName + '_' + formattedDocumentType + '_' + dataToday +'.'+fileNameParts[1];
            }else{
                filepath = accData.FirstName + '-' + accData.LastName + '_' + formattedDocumentType + '_' + dataToday +'.'+'txt';
            }
            
            contVerFile.Title = accData.FirstName + '-' + accData.LastName + '_' + formattedDocumentType + '_' + dataToday;
            contVerFile.PathOnClient = filepath;
            if (String.isNotBlank(eachRequest.created)) {
                contVerFile.DocumentDate__c = Date.valueOf(eachRequest.created);
            } else {
                contVerFile.DocumentDate__c = Date.today();
            }
        
            return contVerFile;
    }

    /**
    * @description Method to get account data
    * @author Ikyatha Naidu | 20-04-2025 
    * @param recordId 
    * @return Account 
    **/
    private static Account getAccountData(String recordId) {
        SEL_Account selectorAccount = new SEL_Account();
        return selectorAccount.selectById(recordId);
    }

    /**
    * @description Method to create IdentityDocument from JSON data
    * @author Ikyatha Naidu | 20-04-2025 
    * @param encodedJson 
    * @param parentID 
    **/
    @testvisible
    private static void createIdentityDocument(String encodedJson, String parentID) {
        try {
            Blob decodedBlob = EncodingUtil.base64Decode(encodedJson);
            ics_customlabel__mdt labelData = ICS_CTRL_PreAppFormCreator.getLandingPageJSON('ics_rely_comply_countries');
            Map<String, String> labelInfo = (Map<String, String>) JSON.deserialize(labelData.Description__c, Map<String, String>.class);
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(decodedBlob.toString());
    
            List<Object> processedDocs = (List<Object>) jsonData.get('ProcessedDocuments');
            if (processedDocs == null || processedDocs.isEmpty()) {
                return;
            }
    
            List<IdentityDocument> docList = buildIdentityDocuments(processedDocs, parentID, labelInfo);
    
            if(docList.size() > 0 && !Test.isRunningTest()) {
                database.insert(docList);
            }
        } catch(Exception exc) {
            LOGGER.error(exc.getMessage());
        }
    }
    
    /**
    * @description Builds a list of IdentityDocument records from the processed documents array
    *              returned in the GBG identity JSON payload. Populates issuing country, document
    *              number, expiry date, and issue date for each document entry.
    * @author Ridhima Saxena | 29-05-2026
    * @param processedDocs List of raw document objects from the deserialized JSON payload
    * @param parentID      Account Id to set as RelatedLegalEntityId on each IdentityDocument
    * @param labelInfo     Map of country code to country name from custom metadata
    * @return List<IdentityDocument> List of populated IdentityDocument records ready for insert
    **/
    private static List<IdentityDocument> buildIdentityDocuments(
        List<Object> processedDocs,
        String parentID,
        Map<String, String> labelInfo
    ) {
        List<IdentityDocument> docList = new List<IdentityDocument>();
        for (Object docObj : processedDocs) {
            Map<String, Object> doc = (Map<String, Object>) docObj;
            IdentityDocument identityDoc = new IdentityDocument();
            identityDoc.RelatedLegalEntityId = parentID;
            identityDoc.IssuingCountry__c = (String) labelInfo.get((String) doc.get('IssuingCountryCode'));
            List<Object> extractedFields = (List<Object>) doc.get('ExtractedFields');
            applyExtractedFields(identityDoc, extractedFields);
            if(identityDoc.Name != null) {
                docList.add(identityDoc);
            }
        }
        return docList;
    }
    
    /**
    * @description Maps extracted field values from the GBG JSON onto an IdentityDocument record.
    *              Handles DocumentNumber, ExpiryDate, and IssueDate fields.
    * @author Ridhima Saxena | 29-05-2026
    * @param identityDoc      IdentityDocument record to populate
    * @param extractedFields  List of raw field objects from the GBG processed document payload
    **/
    private static void applyExtractedFields(IdentityDocument identityDoc, List<Object> extractedFields) {
        for (Object fieldObj : extractedFields) {
            Map<String, Object> field = (Map<String, Object>) fieldObj;
            String fieldName = (String) field.get('Name');
            String fieldValue = (String) field.get('Value');
            if (fieldName == 'DocumentNumber') {
                identityDoc.Name = fieldValue;
            } else if ('ExpiryDate'.equalsIgnoreCase(fieldName)) {
                identityDoc.ExpirationDate = Date.valueOf(fieldValue);
            } else if ('IssueDate'.equalsIgnoreCase(fieldName)) {
                identityDoc.IssueDate = Date.valueOf(fieldValue);
            }
        }
    }

    private static Map<Id, Id> getContentDocumentIds(List<ContentVersion> contentVersions) {
         if (!Schema.sObjectType.ContentVersion.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ContentVersion.');
        }
        Map<Id, Id> contentVersionIdToDocumentIdMap = new Map<Id, Id>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions]) {
            contentVersionIdToDocumentIdMap.put(cv.Id, cv.ContentDocumentId);
        }
        return contentVersionIdToDocumentIdMap;
    }

    @TestVisible
    private static void createContentDocumentLinks(
        Map<String, ContentVersion> customerIdToContentVersionMap, 
        Map<Id, Id> contentVersionIdToDocumentIdMap, 
        Map<Id, Account> accountMap
    ) {
        if (!Schema.sObjectType.ContentDocumentLink.isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create ContentDocumentLink.');
        }
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();
        for(String key : customerIdToContentVersionMap.keySet()) {
            String customerId = key.split('_')[0];
            ContentVersion cv = customerIdToContentVersionMap.get(key);
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = contentVersionIdToDocumentIdMap.get(cv.Id);
            cDe.LinkedEntityId = accountMap.get(customerId).Id;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            linksToInsert.add(cDe);
        }
        if(!linksToInsert.isEmpty()) {
            insert linksToInsert;
        }
    }
    
    private static List<response> generateResponses(
        List<request> requests, 
        Map<Id, Account> accountMap, 
        Map<String, ContentVersion> customerIdToContentVersionMap, 
        Map<Id, Id> contentVersionIdToDocumentIdMap
    ) {
        List<response> responses = new List<response>();
        for(request eachRequest : requests) {
            response thisResp = new response();
            thisResp.customerIdentifier = eachRequest.CustomerId;
            if(accountMap.containsKey(eachRequest.CustomerId)) {
                // FIX: Find the ContentVersion by scanning for keys starting with this accountId
                ContentVersion cv = null;
                for(String mapKey : customerIdToContentVersionMap.keySet()) {
                    if(mapKey.startsWith(eachRequest.CustomerId + '_')) {
                        cv = customerIdToContentVersionMap.get(mapKey);
                        break;
                    }
                }
                thisResp.Status = 'Success';
                if(cv != null) {
                    thisResp.documentId = contentVersionIdToDocumentIdMap.get(cv.Id);
                }
            } else {
                thisResp.Status = 'Error';
                thisResp.errorMessage = 'Account not found!';
            }
            responses.add(thisResp);
        }
        return responses;
    }
}