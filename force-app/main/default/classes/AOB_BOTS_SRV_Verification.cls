/**
 * @description       : Service Class for Verification Entity
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 01-07-2023
 * @last modified by  : Nagendraprasad Mylavarapu
**/
public with sharing class AOB_BOTS_SRV_Verification implements IService{
    
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
        void saveVerification(List<Verification__c> verifications, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    /**
    * @description Method to save list of leads using fflib frameowork
    * @author Nagendraprasad Mylavarapu | 01-07-2023 
    * @param List<Verification__c> verifications 
    * @param sbgplatform.fflib_ISObjectUnitOfWork uow 
    **/
    public void saveVerification(List<Verification__c> verifications, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(Verification__c verification : verifications) {
            if(verification.Id==null){
                uow.registerNew(verification);
            } else{
                uow.registerDirty(verification);
            }
        }
    }
}