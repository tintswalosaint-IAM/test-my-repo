/***************************************************************************************
@ Author            :rahul
@Date              :May 2023
@ Name of the Class :BCB_AlertSubscriptionQueueable
@description       :Class for dealing with BCB_AlertSubscriptionQueueable api and sending the result to the main container and storing the values in the wrapper
@ Story Number      :SFP-26345
@ Last Modified By  : Lokesh
@ Last Modified On  :July 2023
***************************************************************************************/
public without sharing class BCB_CTRL_FileUpload {
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCB_CTRL_FileUpload');
       
/** 
* @description Creates a content version from a given file's base64 and name
* @param base64 - base64 string that represents the file
* @param filename - full file name with extension, i.e. 'products.csv'
* @return ContentVersion - returns the newly created ContentVersion, or null

*/
    @TestVisible public static ContentVersion createContentVersion(String base64, String filename) {
        try {
            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(base64);
            cv.Title = filename;
            cv.PathOnClient=filename;
            insert cv;
            
            return cv;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'createContentVersion',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
/** 
* @description Creates a content link for a given ContentVersion and record
* @param contentVersionId - Id of the ContentVersion of the file
* @param recordId - Id of the record you want to attach this file to
* @return ContentDocumentLink - returns the newly created ContentDocumentLink, 
*/
    @TestVisible public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        try {
            ContentDocumentLink cdl = new ContentDocumentLink();
            ContentVersion cv = new SEL_ContentVersion().selectContentVersionById(contentVersionId);
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
            return cdl;
        } catch(DMLException ex) {
            LOGGER.error(ex.getMessage(), new String[] {'createContentLink',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }
    
/**
* @description This method is used as get application id
* @param participantId
* @return String
*/ 
    @AuraEnabled
    public static String getapplicationId(String participantId){
        try{
            Application_Participant__c appParticpant = new SEL_ApplicationParticipant().selectApplicationParticipant(participantId);
            return appParticpant.Application__c; 
        }
        catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getapplicationId',ex.getMessage()}, ex);
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
    public static String createAndUploadFileApplication(String base64, String filename, String recordId,String docType, Boolean isParticipant) {
        try{
            String documentId;
            Boolean isParticipantId = isParticipant;
            List<Application_Document__c> appDoc;
            if(isParticipantId){
                appDoc= new SEL_ApplicationDocument().selectAppsParticipantByIdAndDoctype(recordId,docType); 
            } else {
                appDoc= new SEL_ApplicationDocument().selectAppsByIdAndDoctype(recordId,docType);   
            }
            if(appDoc.size()>0){
                deleteDocumentFiles(appDoc[0].id);
                 appDoc[0].External_Id__c = filename;
                  update appDoc;
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
            LOGGER.error(ex.getMessage(), new String[] {'createAndUploadFileApplication',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
        
    }
    
/**
* @description gets a list of files linked to participant
* @param participantId
* @param isParticipant
* @return list<contentversion> 
*/
    @AuraEnabled
    public static String releatedFilesApplication(String participantId, Boolean isParticipant){
        
        List<BCB_DTO_DocumnetData> documentlist= new  List<BCB_DTO_DocumnetData>();
        Boolean isParticipantId = isParticipant;
        List<Application_Document__c> appDocLst;
        if(isParticipantId){
            appDocLst= new SEL_ApplicationDocument().selectAppsByIdApplicationParcipant(participantId); 
        } else {
            appDocLst= new SEL_ApplicationDocument().selectAppsByIdApplication(participantId);   
        }
        for(Application_Document__c appDoc: appDocLst){
            BCB_DTO_DocumnetData dd= new BCB_DTO_DocumnetData();
            dd.docType=appDoc.Document_Type__c;
            dd.title=appDoc.External_Id__c;
            dd.id=appDoc.Id;
            documentlist.add(dd);
        }
        return Json.serialize(documentlist);
    }    
/**
* @description gets a list of files linked to participant
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
* @description gets a list of files linked to participant
* @param cipaNumber
* @return Boolean
*/ 
    public Static Boolean getExistcustomer(String cipaNumber){
        Boolean existCustomer=false;
        set<String> cipaNumberList = new set<String>();
        cipaNumberList.add(cipaNumber);
        List<Application__c> appCipa =New SEL_Application().selectApplicationByOnlyRegList(cipaNumberList);
        if(appCipa.size() > 0){
            existCustomer=true;
            for(Application__c ap:appCipa){
                if(ap.AOB_Stage__c=='Completed'){
                    existCustomer=true;
                }else{
                    existCustomer=false;
                    break;
                }
            }
        }else{
            existCustomer=false;
        }
        return existCustomer; 
    }
/**
* @description gets a list of files linked to participant
* @param groupName
* @return Boolean
*/ 
    public Static Boolean getExistcustomerGroup(String groupName){
        Boolean existCustomer=false;
        set<String> groupNameList = new set<String>();
        groupNameList.add(groupName);
        List<Application__c> appGroup =New SEL_Application().selectApplicationByOnlyGroup(groupNameList);
         if(appGroup.size() > 0){
            existCustomer=true;
            for(Application__c ap:appGroup){
                if(ap.AOB_Stage__c=='Completed'){
                    existCustomer=true;
                }else{
                    existCustomer=false;
                    break;
                }
            }
        }else{
            existCustomer=false;
        }
        return existCustomer; 
    }
/**
* @description gets a list of files linked to participant
* @param recordId
* @return Map<ID, String>
*/ 
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {     
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
    /**
* @description wapperclass

*/ 
    public class BCB_DTO_DocumnetData{
        
        public string title;
        public string docType;
        public string id;
        
    }

}