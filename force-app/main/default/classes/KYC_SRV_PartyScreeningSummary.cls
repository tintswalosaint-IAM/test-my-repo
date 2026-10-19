/***************************************************************************************
@Name of the Class :KYC_SRV_PartyScreeningSummary
@Description : SFP-32973 Service Class for Party Screening Summary Entity
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_PartyScreeningSummary implements IService{

    /**
    * @description 
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
        * @description saving Party Screening Summary record from Service Class
        * @author Nagendra Mylavarapu | 26-03-2024 
        * @param partyScreeningSummaries 
        * @param uow 
        **/
        void savePartyScreeningSummary(List<PartyScreeningSummary> partyScreeningSummaries, sbgplatform.fflib_ISObjectUnitOfWork uow);
        
        /**
        * @description saving Party Screening Summary record from Service Class
        * @author Nagendra Mylavarapu | 26-03-2024 
        * @param ppRec 
        * @param partyScreeningSummaries 
        * @param uow 
        **/
        void savePartyScreeningSummary(PartyProfile ppRec, List<PartyScreeningSummary> partyScreeningSummaries, sbgplatform.fflib_ISObjectUnitOfWork uow);
    }
    

    /**
    * @description This method used to save Party Screening Summary using fflib framework
    * @author Nagendra Mylavarapu | 18-Mar-2024 
    * @param partyScreeningSummaries 
    * @param uow 
    **/
    public void savePartyScreeningSummary(List<PartyScreeningSummary> partyScreeningSummaries, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyScreeningSummary pssRec : partyScreeningSummaries) {
            if(pssRec.Id==null){
                uow.registerNew(pssRec);
            }
            else{
                uow.registerDirty(pssRec);
            }
        }        
    }
    
    /**
    * @description This method used to save Party Screening Summary using fflib framework
    * @author Nagendra Mylavarapu | 18-Mar-2024 
    * @param ppRec 
    * @param partyScreeningSummaries 
    * @param uow 
    **/
    public void savePartyScreeningSummary(PartyProfile ppRec, List<PartyScreeningSummary> partyScreeningSummaries, sbgplatform.fflib_ISObjectUnitOfWork uow){
        for(PartyScreeningSummary pssRec : partyScreeningSummaries) {
            if(pssRec.Id==null){
                uow.registerNew(pssRec);
            }
            else{
                uow.registerDirty(pssRec);
            }
            if(ppRec!=null){
                uow.registerRelationship(pssRec,PartyScreeningSummary.PartyProfileId,ppRec);
            }
        }
    }
}