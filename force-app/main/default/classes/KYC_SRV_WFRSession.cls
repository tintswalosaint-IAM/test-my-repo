/***************************************************************************************
@Name of the Class :KYC_SRV_WFRSession
@Description :SFP-32209 Class used for calling WFRSessionToken API for screening Customer Profile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_SRV_WFRSession{
    public static final String SERVICE_NAME = KYC_SRV_WFRSession.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);

    private KYC_SRV_WFRSession(){
       
    }
    /**
    * @description method used to call WfrSession API
    * @param partyProfileId 
    * @return KYC_DTO_Response
    */
    public static KYC_DTO_Response callWfrSessionToken(String partyProfileId){
        try{
            KYC_DTO_Response response;
            String transactionId=UUID.randomUUID().toString();
            PartyProfile pProfile = new SEL_PartyProfile().selectById(partyProfileId);
            
            KYC_DTO_WFRSession wfrSession= new KYC_DTO_WFRSession();
            wfrSession.identificationType='IdentityNumber';
            wfrSession.countryOfIssue=pProfile.WI_IdentificationDocumentIssuingCountry__c;
            Map<String,Object> verificationReq = new Map<String, Object>();
            verificationReq.put('newUserIndicator',0);
            verificationReq.put('livenessMethod',0);
            switch on pProfile.WI_IdentificationDocumentIssuingCountry__c {
                when 'ZA' {
                    verificationReq.put('dhaCheck', 0);
                    verificationReq.put('documentCapture', 0);
                }
                when 'UG' {
                    verificationReq.put('dhaCheck', 1);
                    verificationReq.put('documentCapture', 0);
                }
            }
            
            wfrSession.verificationRequirement=verificationReq;
            KYC_API_WFRSession customerServiceCall = new KYC_API_WFRSession(JSON.serialize(wfrSession) ,pProfile,transactionID);
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_WFRSession.SERVICE_NAME);
            customerServiceCall.process(obj);
            if(Schema.sObjectType.CMN_WebserviceCallQueue__c.isCreateable()){
                insert obj;
            }
            if (customerServiceCall.getResponseStatusCode()== 201 || customerServiceCall.getResponseStatusCode() == 200 ) {
                Map<String,Object> jsonRes=(Map<String,Object>)JSON.deserializeUntyped(customerServiceCall.getResponseBody());
                response = new KYC_DTO_Response(jsonRes,(String) jsonRes.get('sessionToken'));
                System.debug('jsonRes' +jsonRes);
                return response;
                
            }else{
                response = new KYC_DTO_Response('Failed',customerServiceCall.getResponseStatusCode());
                return response;
            }
            
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new KYC_SRV_WFRSessionException(ex.getMessage());
        }
}


 /**
  * @description custom Exception 
  */  
  public class KYC_SRV_WFRSessionException extends Exception {}

   
/***************************************************************************************
@Name of the Class :KYC_DTO_WFRSession
@Description : This is wrapper class for converting Salesforce Object into parameter for api	
@Author :Dayakar 
@Created Date :sept 09 2024
*    ***************************************************************************************/
 public  class  KYC_DTO_WFRSession{
  public String identificationType;
  public String countryOfIssue; 
  Map<String,Object> verificationRequirement;
 }
}