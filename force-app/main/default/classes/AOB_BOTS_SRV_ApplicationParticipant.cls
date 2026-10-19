/**
 * @description       : Service Class for Application Particiapnt
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 03-07-2023
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public with sharing class AOB_BOTS_SRV_ApplicationParticipant implements IService{
    
    /**
    * @description IService
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
        void saveAppParticipant(List<Application_Participant__c> appParticipants, sbgplatform.fflib_ISObjectUnitOfWork uow);
        Object getValueByFieldLabel(Application_Participant__c participant, String fieldLabel);
    }

        /**
    * @description Method to save list of Application_Participant__c using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 29-07-2024 
    * @param Application__c List<Application_Participant__c>  details
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveAppParticipant(List<Application_Participant__c> appParticipants, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(Application_Participant__c appParticipant : appParticipants) {
            if(appParticipant.Id==null){
                uow.registerNew(appParticipant);
            }
            else{
                uow.registerDirty(appParticipant);
            }
        }        
    }
   
    /**
    * @description Method to get value from the key
    * @author Nagendraprasad Mylavarapu | 08-07-2023 
    * @param participant Application_Participant__c 
    * @param fieldLabel String  
    * @return Object String  
    **/
    public Object getValueByFieldLabel(Application_Participant__c participant, String fieldLabel) {
        if(participant != null && String.isNotBlank(fieldLabel) == true) {
            Map<String, Object> deserialisedInFlightData = (Map<String, Object>) JSON.deserializeUntyped(participant.Inflight__c);
            return deserialisedInFlightData.get(fieldLabel);
        }
        return null;
    }
}