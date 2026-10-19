/***************************************************************************************
@Name of the Class :KYC_SRV_Identifii
@Description :SFP-40755 Class used for calling Identifii Document API for OCRC Check
@Author :Dayakar 
@Created Date :OCT 09 2024
***************************************************************************************
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_Identifii {
    public static final String SERVICE_NAME = KYC_SRV_Identifii.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
    
    @TestVisible 
    private KYC_SRV_Identifii(){

    }
    
    /**
     * @description make documentCallout
     * @param requestId
     * @return KYC_DTO_Response
     */
    public static KYC_DTO_Response documentCallout(String requestId){
        try{
            KYC_API_Identifii documentServiceCall = new KYC_API_Identifii(requestId);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_Identifii.SERVICE_NAME);
            documentServiceCall.process(obj);
            if(Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()){
                insert obj;
            }
            KYC_DTO_Response identifiiResponse= new KYC_DTO_Response();
            identifiiResponse.responseCode=documentServiceCall.getResponseStatusCode();
            identifiiResponse.responseBody=documentServiceCall.getResponseBody();
            return identifiiResponse;
            
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'An error occurred at: KYC_CTRL_CustomLabels', ex.getMessage()}, ex);
            throw new KYC_SRV_IdentifiiException(ex.getMessage());
        }
    }
    
    
   /**
    * @description KYC_DTO_Response
    */
    public class KYC_DTO_Response{
        public Integer responseCode;
        public String responseBody;
    }
    
 /**
  * @description custom Exception 
  */  
  public class KYC_SRV_IdentifiiException extends Exception {}
    
    
}