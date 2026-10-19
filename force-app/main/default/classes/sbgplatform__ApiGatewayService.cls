/**
 * @description       : Base class for IBM API Gateway integrations
 * @author            : Derek Hughes
 * @tests             : ApiServiceTest
 * @group             : Common
 * @last modified on  : 13-04-2024
 * @last modified by  : Derek Hughes
 * 
 * @last modified on  : 02-07-2025
 * @last modified by  : Milica Milicevic
 * @description       : Additional constructor to handle custom metadata type record that holds header parameter and values. 
 * @User-Story        : SFP-50927
 * 
 * 2025-08-20   Derek Hughes    SFP-52319 
 *                              Moved the correlation Id method to the ApiService class and made it more generic
 * 
**/
global virtual class ApiGatewayService extends ApiService {

    // Constants
    private static final String HEADER_X_FAPI_INTERACTION_ID = 'x-fapi-interaction-id';

    /**
    * @description Construct the service using a specific named credential
    * @author Derek Hughes | 06-03-2024 
    * @param namedCredential 
    **/
    global ApiGatewayService (String namedCredential) {
        super(namedCredential);
        setTimeout(30000); // 30 seconds
        setCorrelationIdHeader(HEADER_X_FAPI_INTERACTION_ID);
    }

    /**
     * @description Construct the service using a specific named credential
     * @author Milica Milicevic | 02-07-2025
     * @param namedCredential 
     * @param apiCredential
    **/
    global ApiGatewayService (String namedCredential, String apiCredential) {
        super(namedCredential, apiCredential);
        setTimeout(30000); // 30 seconds
        setCorrelationIdHeader(HEADER_X_FAPI_INTERACTION_ID);
    }
   
    /**
    * @description Prepares the Http Request by calling super for the defaults and then setting Gateway specific values
    * @author Derek Hughes | 06-03-2024 
    * @param path 
    * @param method 
    * @param requestBody 
    * @return virtual 
    *
    * This method is required for backward compatibility as global classes cannot be removed.
    * The addition of a correlationId Header is now handled in the ApiService class and set in the ApiGatewayService constructor.
    **/
    global virtual override httpRequest prepareHttpRequest (String path, String method, String requestBody) {
        return super.prepareHttpRequest(path, method, (Object)requestBody, null);
    }       
    
}