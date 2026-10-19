/***************************************************************************************
@Name of the Class :KYC_SRV_GenerateAccessToken
@Description : SFP-32239 Class used to call GenerateAccessToken API.	
@Author :Dayakar 
@Created Date :sept 09 2024
@modification details    : SFP-55635 Added Test.isRunningTest() guard to prevent 
                           live callout during test execution
***************************************************************************************/
public with sharing class KYC_SRV_GenerateAccessToken {
    public static final String SERVICE_NAME = KYC_SRV_GenerateAccessToken.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger(SERVICE_NAME);

    private KYC_SRV_GenerateAccessToken() {}

    /**
     * @description method used to get access token
     * @return String
     */
    public static String getAccessToken() {
        if (Test.isRunningTest()) {
            return 'mock-bearer-token';
        }
        try {
            Final String clientId = '{!$Credential.KYC_PingAuth_ENC.client_id}';
            Final String clientSecret = '{!$Credential.KYC_PingAuth_ENC.client_secret}';
            String payLoad = 'client_id=' + clientId + '&client_secret=' + clientSecret + '&grant_type=client_credentials&scope=insurance-claims.*.*';
            KYC_API_GenerateAccessToken accessTokenServiceCall = new KYC_API_GenerateAccessToken(payLoad);
            CMN_WebserviceCallQueue__c obj = CMN_DAL_DataFactory.newOutboundWebserviceQueue(KYC_API_GenerateAccessToken.SERVICE_NAME);
            accessTokenServiceCall.process(obj);
            Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(accessTokenServiceCall.getResponseBody());
            return (String) jsonMap.get('access_token');
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] { SERVICE_NAME, ex.getMessage() }, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}