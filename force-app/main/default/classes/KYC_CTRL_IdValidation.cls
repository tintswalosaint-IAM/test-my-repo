/***************************************************************************************
@Name of the Class :KYC_CTRL_IdValidation
@Description :SFP-32239	 Class used to call IdValidation API.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
****************************************************************************************/
public without sharing class KYC_CTRL_IdValidation {
    public static final String SERVICE_NAME = KYC_CTRL_IdValidation.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);

    private KYC_CTRL_IdValidation(){
       
    }

    /**
    * @description method used to call IdValidation API
    * @param ppId 
    * @return KYC_DTO_Response 
    */
    @AuraEnabled
    public static KYC_DTO_Response callIdValidation(String ppId){
        try {
            return KYC_SRV_IdValidation.callIdValidation(ppId);
        }Catch(exception ex){
            LOGGER.error(ex.getMessage(), new String[] {SERVICE_NAME,ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
}