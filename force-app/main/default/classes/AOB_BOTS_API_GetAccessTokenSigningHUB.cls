/**
* @author dayakar
* @description  class used  for GetAccessTokenSigningHUB api
* @date Jan 3rd 2023
*/
public class AOB_BOTS_API_GetAccessTokenSigningHUB extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
   /**
    * @author dayakar
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    */
    public AOB_BOTS_API_GetAccessTokenSigningHUB()
    {
       
        String payload = 'grant_type='+EncodingUtil.urlEncode('password',AOB_Constants.UTF8)+'&client_id='+EncodingUtil.urlEncode(settings.CMN_ClientID__c,AOB_Constants.UTF8)+'&client_secret='+EncodingUtil.urlEncode(settings.CMN_Client_Secret__c,AOB_Constants.UTF8)+'&username='+EncodingUtil.urlEncode(settings.CMN_Username__c,AOB_Constants.UTF8)+'&password='+EncodingUtil.urlEncode(settings.CMN_Password__c,AOB_Constants.UTF8);
        this.jsonBody = payload;
    }
    
    public static final String SERVICE_NAME = AOB_BOTS_API_GetAccessTokenSigningHUB.class.getName();
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    * @author dayakar
    * @return SERVICE_NAME
    */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }

   /**
    * @description Override to set your request and response DTO types and any other globals you may have
    * @author dayakar
    */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
        
    }
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
        * @param triggeringObjectId Id
        */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
   /**
    * @description Will serialize requestDTO after its been populated.
    * @author dayakar
    * @return result
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_POST;
    }
   
    public  virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        
    }
    
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
	 * @author dayakar
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new OTP_Mock();
	}
    
   /**
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @author dayakar
    * @return Boolean
    */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
   /**
    * @description Wrapper class for http response
    * @author dayakar
    */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
        * @description response
        * @return String
        */
        @AuraEnabled
        public string response { get; set; }
        
       /**
        * @description The Type of the DTO used when deserializing the class
        * @author dayakar
        * @return Class of the DTO
        */
        @TestVisible
        public override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    
    
    public override String getResponseBody()
    {
        return response.getBody();
    }
    
    
   /**
    * @description Mock class for Test classes 
    * @author dayakar
    */
    public class OTP_Mock extends CMN_API_HttpBaseOutboundMock
    {
        
        public final String VALID_RESPONSE = '{'+
		'    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOltdLCJjbGllbnRfaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiMjhOMWM1R3p2bzhJQW1aSzZhREFuSyIsInN1YiI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsIm5iZiI6MTY3NTA3NTYyMiwiaWQiOiJmYWFkOWFjYy01ODRhLTQ5M2QtOGM4YS1kNGIzZDY4ZjI2OWMiLCJpYXQiOjE2NzUwNzU2MjIsImV4cCI6MTY3NTA3NTkyMn0.U5OMtytkp0GtRX6ztko32t7PazUNt_Ka3xLrKOZ0SjdQbgn7-eu9EDweGxGy-59eh3zI-1w4MZhVA8Ed3JEPiewqm8zTWY9BdKYxC1lkGBhrpU-zXPxxDN8LfPyTIAcqATgowWqgEIzeuu58tt_nci-VHeG7_d4t_ezCQsclHqsZfLFs8gIqP2JON5xtwngu3HJ3MGgbujCMO0XE0SBQA-9oSf4IqfeYV_EY_TXLeA7p7Jyvq2NWZ3bxML0L-WQ84ze37DBLWybWZyz_dqiEpkFj7cMZ05djz2OcnnwEps2ywqhFMwIWqDR4Ggy9e_Exeiik6cI4j7dYGAfn9_nvqA",'+
		'    "token_type": "Bearer",'+
		'    "expires_in": 299'+
		'}';
       /*
        * @description creates a mock response for http calls
        * @aurthor dayakar
        * @param  request
        * @param response
        */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(VALID_RESPONSE);
        }
    }
}