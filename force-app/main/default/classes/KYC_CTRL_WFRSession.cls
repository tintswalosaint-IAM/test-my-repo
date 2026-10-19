/***************************************************************************************
@Name of the Class :KYC_CTRL_WFRSession
@Description : SFP-32170 Class used for calling WFRSessionToken API for screening Customer Profile.		
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_CTRL_WFRSession {
    public static final String SERVICE_NAME = KYC_CTRL_WFRSession.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);

    private KYC_CTRL_WFRSession(){
       
    }
   /**
    * @description method used to call WfrSession API
    * @param ppId 
    * @return KYC_DTO_Response
    */
    @AuraEnabled
    public static KYC_DTO_Response callWfrSessionToken(String ppId){
        try {
            return KYC_SRV_WFRSession.callWfrSessionToken(ppId);
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}