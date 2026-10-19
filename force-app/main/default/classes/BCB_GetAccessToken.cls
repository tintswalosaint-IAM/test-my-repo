/**
* @description  class to get access token
* @author Ruchi
*/
public class BCB_GetAccessToken extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = BCB_GetAccessToken.class.getName();
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    */
    public BCB_GetAccessToken()
    {
        
        String payload = 'grant_type='+EncodingUtil.urlEncode('client_credentials',AOB_Constants.UTF8)+'&scope='+EncodingUtil.urlEncode('prod customer retail write accounts',AOB_Constants.UTF8);
        this.jsonBody = payload;
    }
    

    /**
    * @description The name of your service to be used when looking up custom settings for you service
    * @return string
    */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

   /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
        
    }
     /**
      * @description populates CMN DTO JsonBase
     */
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
        * @param  triggeringObjectId Id

        */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
   /**
    * @description Will serialize requestDTO after its been populated.
    * @return String 
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    /**
	 * @description Overriding parent class method to use the right API Method
	 * @return String
	 */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
   /**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 */
    public  virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_URL);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_AUTHORIZATION,'Basic '+EncodingUtil.base64Encode(Blob.valueOf(settings.CMN_Username__c + ':' + settings.CMN_Password__c)));
        
    }
    /**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 * @return String
	 */
   @TestVisible
   protected override String getWebServiceEndPoint() {
       String endPoint;
       if (settings != null) {
           endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
       }
       return endPoint;
	}
    
   /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return  CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new OTP_Mock();
	}
    
   /**
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @return Boolean
    */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
   /**
    * @description Wrapper class for http CMN_DTO_JsonBase
    * @return Class of the DTO

    */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
        * @description response
        */
        @AuraEnabled
        public string response { get; set; }
         /**
        * @description getObjectType
        * @return Class of the DTO
        */
        @TestVisible
        public override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    
    /**
	 * @description getResponseBody
	 * @return String
	 */
    public override String getResponseBody()
    {
        return response.getBody();
    }
   /**
    * @description Mock class for Test classes 
    */
    public class OTP_Mock extends CMN_API_HttpBaseOutboundMock
    {
        
        // public final String validResponse = '{'+
		// '    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOltdLCJjbGllbnRfaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiMjhOMWM1R3p2bzhJQW1aSzZhREFuSyIsInN1YiI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsIm5iZiI6MTY3NTA3NTYyMiwiaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpYXQiOjE2NzUwNzU2MjIsImV4cCI6MTY3NTA3NTkyMn0.U5OMtytkp0GtRX6ztko32t7PazUNt_Ka3xLrKOZ0SjdQbgn7-eu9EDweGxGy-59eh3zI-1w4MZhVA8Ed3JEPiewqm8zTWY9BdKYxC1lkGBhrpU-zXPxxDN8LfPyTIAcqATgowWqgEIzeuu58tt_nci-VHeG7_d4t_ezCQsclHqsZfLFs8gIqP2JON5xtwngu3HJ3MGgbujCMO0XE0SBQA-9oSf4IqfeYV_EY_TXLeA7p7Jyvq2NWZ3bxML0L-WQ84ze37DBLWybWZyz_dqiEpkFj7cMZ05djz2OcnnwEps2ywqhFMwIWqDR4Ggy9e_Exeiik6cI4j7dYGAfn9_nvqA",'+
		// '    "token_type": "Bearer",'+
		// '    "expires_in": 299'+
		// '}';
        public final String validResponse  = '{"access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOltdLCJjbGllbnRfaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiMjhOMWM1R3p2bzhJQW1aSzZhREFuSyIsInN1YiI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsIm5iZiI6MTY3NTA3NTYyMiwiaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpYXQiOjE2NzUwNzU2MjIsImV4cCI6MTY3NTA3NTkyMn0.U5OMtytkp0GtRX6ztko32t7PazUNt_Ka3xLrKOZ0SjdQbgn7-eu9EDweGxGy-59eh3zI-1w4MZhVA8Ed3JEPiewqm8zTWY9BdKYxC1lkGBhrpU-zXPxxDN8LfPyTIAcqATgowWqgEIzeuu58tt_nci-VHeG7_d4t_ezCQsclHqsZfLFs8gIqP2JON5xtwngu3HJ3MGgbujCMO0XE0SBQA-9oSf4IqfeYV_EY_TXLeA7p7Jyvq2NWZ3bxML0L-WQ84ze37DBLWybWZyz_dqiEpkFj7cMZ05djz2OcnnwEps2ywqhFMwIWqDR4Ggy9e_Exeiik6cI4j7dYGAfn9_nvqA", "token_type": "Bearer", "expires_in": 299}';
       /*
        * @description creates a mock response for http calls
        * @param  request
        * @param response
        */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }
}