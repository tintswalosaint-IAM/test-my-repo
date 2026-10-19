/**
* @description  Sends a POST request to the CMN_Generate_Token_Helper  class to  API endpoint with the provided Request.
* @author Khaliq Abdul(khaliq.abdul@standardbank.co.za)
* @param
* @return
* @date Feb 19th 2024
***************************************************************************************
* Last Modified By  Alexandr Goryachko
* Last Modified Date 23/03/2026
* Last Modified Description: Added logic to resend http request on error
* User Story : SFP-53455
***************************************************************************************
*/
public class CMN_Generate_Token_Helper {

    /**
    * @description Obtains the OAuth access token for making Generate_Token   for PING API requests.
    *
    * @return String representing the OAuth access token.
    */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_Generate_Token_Helper');
    public static final String HTTP_METHOD_POST = 'POST';
    private static final String HEADER_CONTENT_TYPE = 'content-type';
    private static final String HEADER_CONTENT_TYPE_VALUE = 'application/x-www-form-urlencoded';

    /*
    * @return String representing the OAuth access token.
	*/
    public static String getAccessToken() {
        try{
            // Create HTTP request for OAuth token
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:INS_InsuranceClaimsAccess');
            request.setMethod(HTTP_METHOD_POST);
            request.setTimeout(30000);
            request.setHeader(HEADER_CONTENT_TYPE, HEADER_CONTENT_TYPE_VALUE);
            Final String clientId = '{!$Credential.INS_InsuranceClaimsAccessToken.client_id}';
            Final String clientSecret = '{!$Credential.INS_InsuranceClaimsAccessToken.client_secret}';


            String payload = 'grant_type=client_credentials&scope=insurance-claims.*.*';
            request.setBody('client_id='+clientId+'&client_secret='+clientSecret + '&'+ payload);

            // Send HTTP request
            Http http = new Http();
            HttpResponse response;
            Map <String, Object> responseMap;
            Integer requestCounter = 0;
            do {
                response = http.send(request);
                requestCounter++;
            } while ((response.getStatusCode() != 200 || String.isBlank(response.getBody())) && requestCounter <= 3);

            // Handle response
            if (response.getStatusCode() == 200) {
                // Parse JSON response to retrieve the access token
                responseMap = (Map <String, Object> ) JSON.deserializeUntyped(response.getBody());
            } else {
                // Log error response for debugging purposes

                LOGGER.error('CMN_Generate_Token_Helper.getAccessToken', new String[] {'CMN_Generate_Token_Helper.getAccessToken', response.getStatusCode() + response.getBody()});
                responseMap = (Map <String, Object> ) JSON.deserializeUntyped(response.getBody());
            }
            return (String) responseMap.get('access_token');
        } Catch(Exception ex) {
            // Log error response for debugging purposes
            LOGGER.error('CMN_Generate_Token_Helper.getAccessToken', ex);
            throw new INS_CustomException(ex.getMessage());
        }
    }
}