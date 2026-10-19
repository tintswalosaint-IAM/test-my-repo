/**
* @description Class for generic form creation based on database records
*
* Story:SFP-12450
*
* @author Ramya Gurram
*
* @date Aug 2023
*/
public without sharing class CMN_Uploadfiles{
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_Uploadfiles');
    
    
    /*
* @description Creates a content version from a given file's base64 and name
* @param base64 - base64 string that represents the file
* @param filename - full file name with extension, i.e. 'products.csv'
* @return {ContentVersion} - returns the newly created ContentVersion, or null
* if there was an error inserting the record
*/
    @TestVisible private static ContentVersion createContentVersion(String base64, String filename) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient=filename;
            insert cv;
            return cv;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'CMN_Uploadfiles.createContentVersion',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
    /*
* @description Creates a content link for a given ContentVersion and record
* @param contentVersionId - Id of the ContentVersion of the file
* @param recordId - Id of the record you want to attach this file to
* @return ContentDocumentLink - returns the newly created ContentDocumentLink, 
*   or null if there was an error inserting the record
*/
    @TestVisible private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion cv = new AOB_BOTS_SEL_ContentVersion().selectContentVersionById(contentVersionId);
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
            return cdl;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'CMN_Uploadfiles.createContentLink',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
        
    
    /**
* @description creates contentVersion and ContentDocument for participant document
* @param base64 
* @param filename
* @param recordId
* @param docType
* @param isParticipant
* @return String
*/
    @AuraEnabled
    public static String uploadFileApplication(String base64, String filename, String recordId,String docType, Boolean isParticipant) {
        String recID = createAndUploadFileApplication(base64, filename,recordId,docType, isParticipant);
        ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, recID);
        if (cv == null || cdl == null) { return null; }
        return cdl.Id;
    }
    
    
    /**
* @description save participants documents and relate to participant's application document
* @param base64 
* @param filename 
* @param recordId 
* @param docType
* @param isParticipant
* @return String
*/
    private static String createAndUploadFileApplication(String base64, String filename, String recordId,String docType, Boolean isParticipant) {
        try{
            String documentId;
            Boolean isParticipantId = isParticipant;
            List<Application_Document__c> appDoc;
            if(isParticipantId){
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsParticipantByIdAndDoctype(recordId,docType); 
            } else {
                appDoc= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdAndDoctype(recordId,docType);   
            }
            if(appDoc.size()>0){
                deleteDocumentFiles(appDoc[0].id);
            }
            if(appDoc.size()>0){
                
                documentId=appDoc[0].id;
                appDoc[0].External_Id__c=filename;
                update appDoc;
                
            }else{
                Application_Document__c document = new Application_Document__c();
                if(isParticipantId){
                    document.Application_Participant__c = recordId;
                } else{
                    document.Application__c = recordId;
                }
                
                document.Document_Type__c=docType;
                document.External_Id__c=filename;
                insert document;
                documentId=document.id;
                
            }
            return documentId;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'CMN_Uploadfiles.createAndUploadFileApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
    /**
* @description gets a list of files linked to participant
* @param participantId
* @param isParticipant
* @return String
*/
    @AuraEnabled
    public static String releatedFilesApplication(String participantId, Boolean isParticipant){
        
        List<AOB_BOTS_DTO_DocumnetData> documentlist= new  List<AOB_BOTS_DTO_DocumnetData>();
        Boolean isParticipantId = isParticipant;
        List<Application_Document__c> appDocLst;
        if(isParticipantId){
            appDocLst= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdApplicationParcipant(participantId); 
        } else {
            appDocLst= new AOB_BOTS_SEL_ApplicationDocument().selectAppsByIdApplication(participantId);   
        }
        for(Application_Document__c appDoc: appDocLst){
            AOB_BOTS_DTO_DocumnetData dd= new AOB_BOTS_DTO_DocumnetData();
            dd.docType=appDoc.Document_Type__c;
            dd.title=appDoc.External_Id__c;
            dd.id=appDoc.Id;
            documentlist.add(dd);
        }
        return Json.serialize(documentlist);
    }    


    /**
* @description delete files with id
* @param documentIds
*/ 
    
    public static void deleteDocumentFiles(String documentIds){
        List<Id> documentIdsToDelete = new List<Id>();
        List<ContentDocumentLink> cdllist=[SELECT ContentDocument.Id,ShareType,ContentDocument.Title, LinkedEntityId,ContentDocument.CreatedDate,ContentDocument.OwnerId,  ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId =:documentIds];
        if(cdllist.size()>0){
            for(ContentDocumentLink documentLink : cdllist) {
                documentIdsToDelete.add(documentLink.ContentDocumentId);
            }
        }
        
        if(documentIdsToDelete.size()>0){
            List<ContentDocument> documentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :documentIdsToDelete];
            delete documentsToDelete;
        }
        
    }
/**
* @description class to form  wrapper for document data
*/
    public class AOB_BOTS_DTO_DocumnetData{
        
        public string title;
        public string docType;
        public string id;
        
    }
    
    
}