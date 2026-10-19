/***************************************************************************************
@ Author            :prem.lingala@standardbank.co.za
@ Date              :September 2023
@ Name of the Class :PRX_API_AccessToken
@description        :Apex class responsible for obtaining an access token from the Standard Bank API 
                     using the client credentials grant type. This class extends the PRX_API_RestBase 
                     class to provide common functionality for handling API requests.
@ Last Modified By  :prem.lingala@standardbank.co.za
@ Last Modified On  :Jan 2024
@ Jira Ticket       : SFP-29221  
* ---------------------------------------------------------------------------
*version   Date               Developer                  Description
* ---------------------------------------------------------------------------
  1.0     Sept 2023   prem.lingala@standardbank.co.za   Initial Version
***************************************************************************************/
public class PRX_API_AccessToken extends PRX_API_RestBase {
    
     /* @description Declaring the PATH_CALLOUT for Endpoints */
     private static final String PATH_CALLOUT = '/sysauth/oauth2/token'; 
    /**
     * @description This method is used to Overrides the getEndpoint method to provide the API endpoint URL for obtaining an access token.
     * @return String representing the API endpoint URL.
     */
    protected override String getEndpoint() {
        return 'callout:PRX_ESB_TOKEN_CREDENTIALS_NC'+PATH_CALLOUT;
    }
    /**
     * @description this method is used to Overrides the getRequestHeaders method to provide the required HTTP request headers.
     * @return Map<String, String> containing the HTTP request headers.
     */
    protected override Map<String, String> getRequestHeaders() {
        Map<String, String> headers = new Map<String, String>();
        headers.put('Content-Type', 'application/x-www-form-urlencoded');
        return headers;
    }
    /**
     * @description Overrides the getRequestBody method to provide the request body for obtaining an access token.
     * @return String representing the request body.
     */
    protected override String getRequestBody() {
        return 'grant_type=client_credentials&scope=vas retail customer prod';
    }
     /**
     * @description Invokes the API by sending a POST request to obtain an access token.
     * @return String representing the access token obtained from the API response.
     */
    public String callApi(){
        HttpResponse resp = super.sendHttpRequest('POST');
        String responseBody = resp.getBody();
        Map<String, Object> jsonResponse = (MAp<String, Object>)JSON.deserializeUntyped(responseBody);
        if(jsonResponse.get('access_token') != NULL){
            return (String)jsonResponse.get('access_token');
        }
        return null;
    }
}