/***************************************************************************************
@Name of the Class :KYC_SRV_PartyProfileAddress
@Description : SFP-32973 Service Class for Party Profile Address Entity.
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_PartyProfileAddress implements IService{
    
    /**
    * @description This constructor class used to create new IService instance
    * @author Nagendraprasad Mylavarapu | 11-12-2023  
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
        * @description saving PartyProfileAddress record from Service Class
        * @author Nagendra Mylavarapu | 26-03-2024 
        * @param ppRec 
        * @param partyProfileAdd 
        * @param uow 
        **/
        void savePartyProfileAddress(PartyProfile ppRec, List<PartyProfileAddress> partyProfileAdd, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }


    /**
    * @description Method to save list of Party Profile Address using fflib frameowork
    * @author Nagendra Mylavarapu | 18--2024 
    * @param ppRec Partyprofile Record Id
    * @param partyProfileAdd Address need to e associated to Partyprofile
    * @param uow unit of work
    **/
    public void savePartyProfileAddress(PartyProfile ppRec, List<PartyProfileAddress> partyProfileAdd, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyProfileAddress ppaRec : partyProfileAdd) {
            if(ppaRec.Id==null){
                uow.registerNew(ppaRec);
            }
            else{
                uow.registerDirty(ppaRec);
            }
            uow.registerRelationship(ppaRec,PartyProfileAddress.PartyProfileId,ppRec);
        }
    }
}