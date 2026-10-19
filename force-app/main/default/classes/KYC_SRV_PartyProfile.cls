/***************************************************************************************
@Name of the Class :KYC_SRV_PartyProfile
@Description : SFP-32973 Service Class for Party Profile Entity.
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_PartyProfile implements IService{
    
    /**
    * @description This constructor used to create new instance ORG_Application.service
    * @author Nagendraprasad Mylavarapu | 11-Dec-2023 
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
        * @description saving PartyProfile record from Service Class
        * @author Nagendra Mylavarapu | 26-03-2024 
        * @param partyProfiles 
        * @param uow 
        **/
        void savePartyProfiles(List<PartyProfile> partyProfiles, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    

    /**
    * @description Method to save list of Party Profiles using fflib frameowork
    * @author Nagendra Mylavarapu | 18-Mar-2024 
    * @param partyProfiles 
    * @param uow 
    **/
    public void savePartyProfiles(List<PartyProfile> partyProfiles, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyProfile ppRec : partyProfiles) {
            if(ppRec.Id==null){
                uow.registerNew(ppRec);
            }
            else{
                uow.registerDirty(ppRec);
            }
        }        
    }
}