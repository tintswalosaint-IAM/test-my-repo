/***************************************************************************************
@Name of the Class :KYC_CTRL_RAASCustomer
@Description :SFP-40754 Class used for calling RAAS API for screening Customer Profile.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
***************************************************************************************
* Last Modified By  Alexandr Goryachko
* Last Modified Date 17/12/2025
* Last Modified Description: SFP-53455
****************************************************************************************/
public without sharing class KYC_CTRL_RAASCustomer {
    public static final String SERVICE_NAME = KYC_CTRL_RAASCustomer.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);
     
    /**
     * @description method used to call RAASCustomer API
     * @param ppId 
     * @return KYC_DTO_Response
     */
    @AuraEnabled
    public static KYC_DTO_Response callRAASCustomer(String ppId){
        try {
            return KYC_SRV_RAASCustomer.callRAASCustomer(ppId);
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description method used to call RAASCustomer API
     * @param ppId 
     * @param params 
     * @return KYC_DTO_Response
     */
    public static KYC_DTO_Response callRAASCustomer(String ppId, String quoteId) {
        try {
            return KYC_SRV_RAASCustomer.callRAASCustomer(ppId, null, quoteId);
        } catch(exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}