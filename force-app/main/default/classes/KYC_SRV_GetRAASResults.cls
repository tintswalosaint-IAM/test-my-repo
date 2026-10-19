/***************************************************************************************
@Name of the Class :KYC_SRV_GetRAASResults
@Description : SFP-40754 Class used for calling GET RAAS API for screening Customer Profile.	
@Author :Dayakar 
@Created Date :O6 Nov 2024
***************************************************************************************/
public without sharing class KYC_SRV_GetRAASResults {
    
    public static final String SERVICE_NAME = KYC_SRV_GetRAASResults.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    
    private KYC_SRV_GetRAASResults(){
        
    }
    
    /**
     * @description method used to call Get RAASCustomer API
     * @param ppId 
     * @return KYC_DTO_Response
     */
    @AuraEnabled 
    public static KYC_DTO_Response getRassCall(String partyProfileId){
        try{ 
            PartyProfile partyProfile = new SEL_PartyProfile().selectById(partyProfileId);
            partyScreeningSummary partyScreeningSummary = new SEL_PartyScreeningSummary().selectByPartyProfileIdandStatus(partyProfileId,'Completed'); 
            String transactionId=UUID.randomUUID().toString();
            KYC_API_GetRAAS customerServiceCall = new KYC_API_GetRAAS(partyProfile,transactionID,partyScreeningSummary.ThirdPartySreeningIdentifier);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_GetRAAS.SERVICE_NAME);
            customerServiceCall.process(obj);
            insert obj;
            if (customerServiceCall.getResponseStatusCode()== 201 || customerServiceCall.getResponseStatusCode() == 200) {
                Map<String,Object> jsonRes=(Map<String,Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                Map<String, Object> assessmentResult = (Map<String, Object>) jsonRes.get('assessmentResult');
                if((String) assessmentResult.get('result')=='AcceptableRisk'){
                    partyProfile.CMN_DocTypesReqd__c='Proof of address';
                    update partyProfile;
                }
                KYC_SRV_RAASCustomer.updatepartyScreeningSummary(partyScreeningSummary,assessmentResult);
                return ((String) assessmentResult.get('result')=='AcceptableRisk') ? new KYC_DTO_Response(jsonRes,'docRequired'):new KYC_DTO_Response(jsonRes, 'Success')  ;

            }else{
                return new KYC_DTO_Response('Failed',customerServiceCall.getResponseStatusCode());
            }
        }
        Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    
   /**
    * @description custom Exception 
    */  
   public class KYC_SRV_GetRAASResultsException extends Exception {}
    
}