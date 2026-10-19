/**
 * Class used to Perform an API call to update the Offer Conditions
 * 
 * <p>DBP-2295</p>
 * 
 * @author Mark Bailey (mark.bailey2@standardbank.co.za)
 * 
 * @date Feb 10th 2021
 */
public with sharing class DOC_API_SetConditions extends AOB_API_RestBaseOutboundPing {
	
	public static final String SERVICE_NAME = DOC_API_SetConditions.class.getName();
	public static final String DEFAULT_CHANNEL = 'SF_SBG';
	private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    public String applicationId;
    public String jsonBody;
    
    /**
	* @description constructor used to make sure a token will be provided to authenticate to the API call
	*
	*/ 
    public DOC_API_SetConditions(Object inputs, String applicationId){
        accessToken = AOB_Utils.getAccessToken();
        this.applicationId = applicationId;
		System.debug('### '+this.jsonBody);
        this.jsonBody = JSON.serialize(inputs);
    }
    
	protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	} 

    /**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected virtual override String getBody()
	{
		super.getBody();
		return jsonBody;
	}
    
    protected override String getWebServiceEndPoint()
	{
		String endPoint;
        string offerId;
        
        List<AOB_Application__c> applications=[SELECT id, AOB_OfferId__c   
                             FROM AOB_Application__c 
                             WHERE id =:this.applicationId];
        
 		if(settings != null && String.isNotBlank(settings.CMN_NamedCredential__c))
		{
            if(!applications.isEmpty()){
            	offerId=applications[0].AOB_OfferId__c+settings.AOB_AddPath__c;
            }
			string path=String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
        	path+=String.isNotBlank(offerId) ? offerId : CMN_UTIL_String.EMPTY;
			endPoint = String.format(NAMED_CREDENTIAL_URL_FORMAT, new String[] {settings.CMN_NamedCredential__c,String.isNotBlank(path)?path: CMN_UTIL_String.EMPTY});
		}
		return endPoint;
	}
    
    /**
	* @description Call the parent objects' method to ensure we get code coverage
	*/
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		super.getEndpointMock();
		return new DOC_API_SetConditionsMock();
	}
    
    /**
	* @description method used to initialise the api call
	*
	*/
    protected override void initialise()
	{
		super.initialise();
		baseResponseDTO = new DTO_Response('');
	}
    
    /**
     * @description Method will override the parent class method to provide headers
     */
     protected virtual override void setHeaders()
     {
        super.setHeaders();
     
        String GUID = AOB_Utils.generateGUID();
        request.setHeader('s-msg-ref', GUID);
        request.setHeader('s-user-id', 'IB_USR'); 
        request.setHeader(HTTP_HEADER_INTERACTIONID,GUID);
        request.setHeader('x-channel-id','SF_SBG');

     }
    
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public string response;
        public DTO_Response(string resp){
            this.response = resp;
        }

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		protected override Type getObjectType()
		{
			return DTO_Response.class;
		}
        
    }
    
     /**
	* @description method used to set API call Method
	*
	*/
    @testVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_PUT;
	}

    /**
	* @description method used to indicate that there is no need for a triggering object
	*
	*/
    @testVisible
	protected override virtual Boolean triggeringObjectRequired()
	{
		return false;
	}
    
    public class DOC_API_SetConditionsMock extends CMN_API_HttpBaseOutboundMock
	{
        public final String VALID_RESPONSE = '{"response":"test"}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}
}