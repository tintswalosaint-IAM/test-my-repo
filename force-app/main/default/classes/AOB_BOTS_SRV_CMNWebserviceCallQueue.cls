/**
 * @description       : Service Class for CMNWebserviceCallQueue__c Entity
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 29-07-2024
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public with sharing class AOB_BOTS_SRV_CMNWebserviceCallQueue implements IService{
    /**
    * @description 
    * @author Nagendraprasad Mylavarapu | 29-07-2024 
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
        void saveWebserviceCallQueues(List<CMN_WebserviceCallQueue__c> webserviceCallQueues, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
        /**
    * @description Method to save list of CMN_WebserviceCallQueue__c using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param webserviceCallQueues List<CMN_WebserviceCallQueue__c>  details
    * @param uow sbgplatform.fflib_ISObjectUnitOfWork  
    **/
    public void saveWebserviceCallQueues(List<CMN_WebserviceCallQueue__c> webserviceCallQueues, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(CMN_WebserviceCallQueue__c webserviceCallQueue : webserviceCallQueues) {
            if(webserviceCallQueue.Id==null){
                uow.registerNew(webserviceCallQueue);
            }
            else{
                uow.registerDirty(webserviceCallQueue);
            }
        }        
    }
}