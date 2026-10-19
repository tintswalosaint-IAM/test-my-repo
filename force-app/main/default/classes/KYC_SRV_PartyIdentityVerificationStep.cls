/**
 * @description       : Service Class for KYC_SRV_PartyIdentityVerificationStep Entity
 * @author            : Nagendraprasad Mylavarapu
 * @group             : 
 * @last modified on  : 10-08-2024
 * @last modified by  : Nagendra Mylavarapu
**/
public with sharing class KYC_SRV_PartyIdentityVerificationStep implements IService {

    /**
    * @description 
    * @author Nagendraprasad Mylavarapu | 10-08-2024
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
        * @description saving Party Screening Summary Step record from Service Class
        * @author Nagendra Mylavarapu | 10-08-2024
        * @param partyIdentityVerification 
        * @param partyIdentityVerificationSteps 
        * @param uow 
        **/
        void savePartyIdentityVerificationStep(PartyIdentityVerification partyIdentityVerification, List<PartyIdentityVerificationStep> partyIdentityVerificationSteps, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    
    /**
    * @description This method used to save Party Screening Summary Step using fflib framework
    * @author Nagendra Mylavarapu | 10-08-2024 
    * @param partyIdentityVerification 
    * @param partyIdentityVerificationSteps 
    * @param uow
    **/
    public void savePartyIdentityVerificationStep(PartyIdentityVerification partyIdentityVerification, List<PartyIdentityVerificationStep> partyIdentityVerificationSteps, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyIdentityVerificationStep pssRec : partyIdentityVerificationSteps) {
            if(pssRec.Id==null){
                uow.registerNew(pssRec);
            }
            else{
                uow.registerDirty(pssRec);
            }
            if(partyIdentityVerification!=null){
                uow.registerRelationship(pssRec,PartyIdentityVerificationStep.PartyIdentityVerificationId,partyIdentityVerification);
            }
        }
    }
}