/**
* @description This class is used as delete related record
* @author Dayakar Deekonda
* @date July 28th 2023
*/

public class AOB_BOTS_CTRL_DeleteAllfiles {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_BOTS_CTRL_DeleteAllfiles');
    private static final String COMPLETE = 'Complete';
    /**
* @description This method is used as delete record
*/
    @AuraEnabled
    public static void deleteAllfils(){
        try{
            Set<Id> appdeleteids= new Set<Id>();  
            Set<Id> partdeleteids= new Set<Id>();  
            Set<Id> documentIds= new Set<Id>(); 
            
            List<Id> documentIdsToDelete = new List<Id>();
            
            Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByDeveloperName().get('AOB_BotswanaBCC').getRecordTypeId();
            List<Application__c> filterappsList=[select Id,Status__c from Application__c where Status__c=:COMPLETE and RecordTypeId=:recordTypeId];
            
            for(Application__c app:filterappsList){
                appdeleteids.add(app.id);
            }
            
            List<Application_Participant__c> applicationPart= [select id,Application__c from Application_Participant__c where Application__c IN:appdeleteids]; 
            
            for(Application_Participant__c appPart:applicationPart){
                partdeleteids.add(appPart.Id);
            }
            
            List<Application_Document__c> deletepplist=[select id,Application__c,Application_Participant__c from Application_Document__c where Application__c in:appdeleteids];
            List<Application_Document__c> deleteparticipantlist=[select id,Application__c,Application_Participant__c from Application_Document__c where  Application_Participant__c in:partdeleteids];
        
            if(deletepplist.size()>0){
                for(Application_Document__c appd:deletepplist){
                    documentIds.add(appd.Id);
                }
            }
        
            if(deleteparticipantlist.size()>0){
                for(Application_Document__c appd:deleteparticipantlist){
                    documentIds.add(appd.Id);
                }
            }
            
            List<ContentDocumentLink> cdllist=[SELECT ContentDocument.Id,ShareType,ContentDocument.Title, LinkedEntityId,ContentDocument.CreatedDate,ContentDocument.OwnerId,  ContentDocument.FileType FROM ContentDocumentLink where LinkedEntityId IN:documentIds];
            if(cdllist.size()>0){
                for(ContentDocumentLink documentLink : cdllist) {
                    documentIdsToDelete.add(documentLink.ContentDocumentId);
                }
            }
            if(documentIdsToDelete.size()>0){
                List<ContentDocument> documentsToDelete = [SELECT Id FROM ContentDocument WHERE Id IN :documentIdsToDelete];
                delete documentsToDelete;
                database.emptyRecycleBin(documentsToDelete);
            }
        }catch (Exception ex){ 
            LOGGER.error(ex.getMessage(), new String[] {'AOB_BOTS_CTRL_DeleteAllfiles',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }  
    
}