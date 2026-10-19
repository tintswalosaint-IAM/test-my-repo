/**
* @description This class is used as call the relaycomply api
* @author Dayakar 
* @date Jan 5th 2021
*/
public class CMN_SRV_RelyComply{
   
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_SRV_RelyComply');
    
 /**
* @description This method is used as call the accessToken api
* @return string
*/
    public static string getAccessToken(){
        try{
            CMN_API_RelyComplyAccessToken customerServiceCall = new CMN_API_RelyComplyAccessToken();
            CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_RelyComplyAccessToken.SERVICE_NAME);
            customerServiceCall.process(obj);
            String accesToken;
            system.debug('access token'+ customerServiceCall.getResponseBody());
            if(customerServiceCall.getResponseStatusCode()==200){
                GetAccessToken accessToken= (GetAccessToken) System.JSON.deserialize(customerServiceCall.getResponseBody(), GetAccessToken.class);
                accesToken=accessToken.access_token;
            }
            return accesToken;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'getAccessToken',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

/**
* @description wrapper for GetAccessToken
*/    
    public class GetAccessToken{
        public String access_token;
        public String token_type;
        public Integer expires_in;
        public String refresh_token;
    }

    

}