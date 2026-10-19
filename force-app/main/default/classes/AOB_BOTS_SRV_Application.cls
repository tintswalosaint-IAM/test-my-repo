/**
 * @description       : Service Class for Application Entity
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 01-07-2023
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public without sharing class AOB_BOTS_SRV_Application implements IService{
    
    /**
    * @description 
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @return IService 
    **/
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    
    /**
     * IService Interface to define our class structure
     * @return list of IService
     */
    public interface IService { 
        void saveApp(List<Application__c> applications, sbgplatform.fflib_ISObjectUnitOfWork uow);
        void saveApplnParticipants(List<Application_Participant__c> participants, sbgplatform.fflib_ISObjectUnitOfWork uow);
        void saveApplnDocuments(Id appId, Id participantId, List<Application_Document__c> documents, sbgplatform.fflib_ISObjectUnitOfWork uow);
        void saveDocuments(Id relatedToId, List<ContentVersion> documents, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    /**
    * @description Method to save list of Application__c using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param Application__c List<Application__c>  details
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveApp(List<Application__c> applications, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(Application__c application : applications) {
            if(application.Id==null){
                uow.registerNew(application);
            }else{
              uow.registerDirty(application);
            }
        }        
    }
    
    /**
    * @description Method to save list of participants using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param participants List<Application_Participant__c> Participant details
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveApplnParticipants(List<Application_Participant__c> participants,
                                      sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(Application_Participant__c participant : participants) {
            if(participant.Id==null){
                uow.registerNew(participant);
            }
            else{
                uow.registerDirty(participant);
            }
        }        
    }
    
    /**
    * @description Method to save list of participant documents using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param appId Id to which the document is associated with
    * @param participantId Id to which the document is associated with
    * @param documents List<Application_Document__c> Documents details
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveApplnDocuments(Id appId, Id participantId, 
    List<Application_Document__c> documents, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(Application_Document__c document : documents) {
            if(document.Id==null){uow.registerNew(document);
            }
            else{
                uow.registerDirty(document);
            }
            if(participantId!=null){
            	uow.registerRelationship(document,Application_Document__c.Application_Participant__c,new Application_Participant__c(Id=participantId));
            }
            uow.registerRelationship(document,Application_Document__c.Application__c,new Application__c(Id=appId));
        }
    }
    
    /**
    * @description Method to save list of participant documents into content documents using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param relatedToId  Id captures the relationship of the document with the record
    * @param Documents List<ContentVersion> 
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveDocuments(Id relatedToId, List<ContentVersion> documents, 
                              sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(ContentVersion document : documents) {
            if(document.Id==null){uow.registerNew(document);}
            else{
                uow.registerDirty(document);
            }
            Application_Document__c relatedRec =  new Application_Document__c(Id=relatedToId);
            uow.registerRelationship(document,ContentVersion.FirstPublishLocationId,relatedRec);
        }
        
    }
    
}