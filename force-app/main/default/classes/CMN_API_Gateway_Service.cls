/**
 * @description       : Base class for IBM API Gateway integrations
 * @author            : Derek Hughes
 * @tests             : CMN_API_Service_Test
 * @group             : Common
 * @last modified on  : 18-03-2024
 * @last modified by  : Derek Hughes
  _____   ____    _   _  ____ _______   ______ _____ _____ _______ 
 |  __ \ / __ \  | \ | |/ __ \__   __| |  ____|  __ \_   _|__   __|
 | |  | | |  | | |  \| | |  | | | |    | |__  | |  | || |    | |   
 | |  | | |  | | | . ` | |  | | | |    |  __| | |  | || |    | |   
 | |__| | |__| | | |\  | |__| | | |    | |____| |__| || |_   | |   
 |_____/ \____/  |_| \_|\____/  |_|    |______|_____/_____|  |_|   
                                                                   
 THIS CODE IS CONTROLLED BY THE SALESFORCE COE PLATFORM TEAM
 For any changes requied please contact the platform team.       
    
**/
public abstract class CMN_API_Gateway_Service extends CMN_API_Service {

    private static final sbgplatform.rflib_Logger LOGGER1 = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_Gateway_Service');

    // Constants
    private static final String HEADER_INTERACTION_ID = 'x-fapi-interaction-id';

    /**
    * @description Construct the service using a specific named credential
    * @author Derek Hughes | 06-03-2024 
    * @param namedCredential 
    **/
    public CMN_API_Gateway_Service (String namedCredential) {
        super(namedCredential);
    }
   
    /**
    * @description Prepares the Http Request by calling super for the defaults and then setting Gateway specific values
    * @author Derek Hughes | 06-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return virtual 
    **/
    protected virtual override httpRequest prepareHttpRequest (String path, String method, String requestBody) {
        
        LOGGER1.info('prepareHttpRequest: Add x-fapi-interaction-id header');

        HttpRequest httpRequest = super.prepareHttpRequest(path, method, requestBody);
        
        String fApiInteractionId = createGUID();
        
        httpRequest.setHeader(HEADER_INTERACTION_ID, fApiInteractionId);
        httpRequest.setTimeout(30000); // 30 seconds

        return httpRequest;
    }
 
    /**
     * @description This method creates new unique guid value
     * @return String guid
     */
    private String createGUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String newGuid = h.SubString(0,8) + '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return newGuid;
    }
    
}