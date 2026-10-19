/**
 * @description Class used to Perform an update to customer relationship manager.
 * @author Muvhuso Nekhubvi
 * @date September 2025
 * SFP :SFP-50270
 */
public with sharing class CMN_API_UpdateCustomerDetails extends sbgplatform.ApiGatewayService {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_UpdateCustomerDetails');
    
    //HTTP Constants
    private static final String CONTENT_TYPE_FORM_URL_ENCODED = 'application/x-www-form-urlencoded';
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String HTTP_METHOD_POST = 'POST';   
    private static final String AUTHORIZATION_TYPE_BEARER = 'Bearer ';
    public static final String HTTP_HEADER_AUTHORIZATION = 'Authorization';

   
    private static String accessToken = null;
    private static DateTime tokenExpiryDateTime = System.now();
    
    //Generic Constants
    private static final String Token_CREDENTIALS = 'CHNW_PPB_EPIC3SA_SAP_TokenN';
    private static final String CUSTOMER_TYPE = '1';
    private static final String SBSA_GROUP = 'SBRE';
    private static final String PATH_CUSTOMER = '/external-partners/customers/';
    
     //API specific
    private static final String NAMED_CREDENTIAL = 'CHNW_PPB_EPIC3SA_SAP_C';
    private static final String API_CREDENTIAL = 'PPB_GATEWAY_CUSTOMER_API';

    
    /**
     * @description private Static method to Retrieve Access Token
     * @return AccessToken
     **/
    
    public static String getAccessToken(){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+Token_CREDENTIALS);
        req.setMethod(HTTP_METHOD_POST);
        req.setHeader(CONTENT_TYPE, CONTENT_TYPE_FORM_URL_ENCODED);
        
		String body = 
            'grant_type=client_credentials' +
            '&client_id={!$Credential.CHNW_PPB_EPIC3SA_SAP_TokenE.Client_Id}' +
            '&client_secret={!$Credential.CHNW_PPB_EPIC3SA_SAP_TokenE.Client_Secret}';

        req.setBody(body);
        
        Http http = new Http();
        if(!Test.isRunningTest()){
        	HttpResponse res = http.send(req);
        	Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        	accessToken = (String) responseMap.get('access_token');
        }
		return accessToken;
    }
    /**
     * @description Constructor for CMN_API_UpdateCustomerDetails.
     * Determines the Named Credential name.
     */
    public CMN_API_UpdateCustomerDetails() {
        super(NAMED_CREDENTIAL,API_CREDENTIAL); 
    }
    
      /**
     * @description Method to Retrieve Access Token
     * @return AccessToken
     **/
    public static String refreshToken() {
        // Get a new token if no token available or the token is already expired.
        if (accessToken == null || System.now() >= tokenExpiryDateTime) {
            return getAccessToken();
        }
        return accessToken;
    }
    
        /**
    * @description Prepares an authenticated HTTP request by adding a Bearer access token.
    * @param path Endpoint path.
    * @param method HTTP method.
    * @param requestBody Request payload.
    * @param contentType Request content type.
    * @return Authenticated HttpRequest instance.
    */
    public override HttpRequest prepareHttpRequest (String path, String method, Object requestBody, String contentType){
        HttpRequest request = super.prepareHttpRequest(path,method,requestBody, contentType); 
        request.setHeader(HTTP_HEADER_AUTHORIZATION, AUTHORIZATION_TYPE_BEARER + refreshToken());
        return request;
    }
    
    /**
     * @description This method performs an API request to ESB
     * @param relManagerCode Id of our Financial Account record
     * @param customerGUID 
     * @return CMN_DTO_CustomerRMChangeResponse responseObject
     */
    
    public CMN_DTO_CustomerRMChangeResponse updateCustomeRM(String relManagerCode , String customerGUID){
        
       CMN_DTO_CustomerRMChangeResponse responseObject = new CMN_DTO_CustomerRMChangeResponse();      
       CMN_DTO_CustomerRMChangeRequest dtoRequest = new CMN_DTO_CustomerRMChangeRequest(); 
       dtoRequest.customerType = CUSTOMER_TYPE;
       dtoRequest.sbsaGroup =  SBSA_GROUP;
       dtoRequest.relManager = relManagerCode;
        
        // Serialize the DTO request into a JSON string
       String requestBody = JSON.serialize(dtoRequest);
       String responseBody = (String) this.put(PATH_CUSTOMER + customerGUID, requestBody);
               
               If(this.getStatusCode() == sbgplatform.ApiService.HTTP_OK){
                if (String.isNotBlank(responseBody)) {
                     responseObject = (CMN_DTO_CustomerRMChangeResponse) JSON.deserialize(responseBody, CMN_DTO_CustomerRMChangeResponse.class);
                    return responseObject;
                 }else{
                     LOGGER.error('updateRMCode : No response body');
                 }
               }else {
                LOGGER.error('Update : API error: Status Code: ' + this.getStatusCode());
            }
            return null;
      }

}