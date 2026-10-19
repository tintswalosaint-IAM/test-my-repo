/***************************************************************************************
@Name of the Class :KYC_SRV_PartyIdentityVerification
@Description : SFP-32973 Service Class for Party Identity Verification as per.
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_PartyIdentityVerification implements IService{
    /**
    * @description This method used for creating new instance of ORG_Application.service
    * @author Nagendraprasad Mylavarapu | 13-12-2023 
    * @return IService 
    **/
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }
    
    /**
     * @description IService Interface to define our class structure
     * @return list of IService
     **/
    public interface IService { 
        /**
         * @description registering save Party Identity Verification method
         * @param partyIdentityVerifications 
         * @param uow 
         **/
        void savePartyIdentityVerification(List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow);
        /**
        * @description registering save Party Identity Verification method
        * @author Nagendra Mylavarapu | 20-03-2024 
        * @param ppId 
        * @param partyIdentityVerifications 
        * @param uow 
        **/
        void savePartyIdentityVerification(Id ppId, List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow);
        /**
        * @description registering save Party Identity Verification method
        * @author Nagendra Mylavarapu | 20-03-2024 
        * @param ppRec 
        * @param partyIdentityVerifications 
        * @param uow 
        **/
        void savePartyIdentityVerification(PartyProfile ppRec, List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    

    /**
    * @description Method to save list of Party Identity Verification using fflib frameowork
    * @author Nagendra Mylavarapu | 18-03-2024 
    * @param partyIdentityVerifications 
    * @param uow 
    **/
    public void savePartyIdentityVerification(List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyIdentityVerification pivRec : partyIdentityVerifications) {
            if(pivRec.Id==null){
                uow.registerNew(pivRec);
            }
            else{
                uow.registerDirty(pivRec);
            }
        }    
    }
    

    /**
    * @description Method to save list of Party Identity Verification using fflib frameowork
    * @author Nagendra Mylavarapu | 18-03-2024 
    * @param ppId 
    * @param partyIdentityVerifications 
    * @param uow 
    **/
    public void savePartyIdentityVerification(Id ppId, List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyIdentityVerification pivRec : partyIdentityVerifications) {
            if(pivRec.Id==null){
                uow.registerNew(pivRec);
            }
            else{
                uow.registerDirty(pivRec);
            }
            if(ppId!=null){
                uow.registerRelationship(pivRec,PartyIdentityVerification.PartyProfileId,new PartyProfile(Id=ppId));
            }
        }
    }
    

    /**
    * @description Method to save list of Party Identity Verification using fflib frameowork
    * @author Nagendra Mylavarapu | 18-03-2024 
    * @param ppRec 
    * @param partyIdentityVerifications 
    * @param uow 
    **/
    public void savePartyIdentityVerification(PartyProfile ppRec, List<PartyIdentityVerification> partyIdentityVerifications, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyIdentityVerification pivRec : PartyIdentityVerifications) {
            if(pivRec.Id==null){
                uow.registerNew(pivRec);
            }
            else{
                uow.registerDirty(pivRec);
            }
            if(ppRec!=null){
            	uow.registerRelationship(pivRec,PartyIdentityVerification.PartyProfileId,ppRec);
            }
        }
    }
}