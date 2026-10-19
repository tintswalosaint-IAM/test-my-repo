/***************************************************************************************
@Name of the Class :KYC_FLOW_CreatePartyProfile
@Description : SFP-32973 Controller to request for KYC Process
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_FLOW_CreatePartyProfile {
    
    @Testvisible
    private KYC_FLOW_CreatePartyProfile(){
        
    }
    
    /**
    * @description Apex Action method used to Start the KYC Process
    * @author Nagendra Mylavarapu | 11-MAR-2024 
    * @param reqLst
    * @return List<KYC_CTRL_PartyProfile.KYCResponse>
    **/
    @InvocableMethod(Label = 'Create Partyprofile' Description = 'Create Partyprofile for KYC Process' category='PartyProfile')
    public static List<KYC_DTO_ClientWrapper.Response> processKYC(List<KYC_DTO_FlowCreatePartyProfile> reqLst){
        List<KYC_DTO_ClientWrapper.Response> retVal = new List<KYC_DTO_ClientWrapper.Response>();
        retVal.add(KYC_CTRL_PartyProfile.processKycTest(JSON.serialize(reqLst[0])));
        return retVal;
    }

}