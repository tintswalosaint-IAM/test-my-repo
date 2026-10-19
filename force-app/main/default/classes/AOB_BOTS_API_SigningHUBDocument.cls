/**
* @description  class used  for SigningHUBDocument api
* @date Jan 3rd 2023
*/
public class AOB_BOTS_API_SigningHUBDocument extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    public String documentId;
    public Blob PdfBody;
    /**
     * @description this method used to AOB_BOTS_API_SigningHUBDocument
     * @param Blob PdfBody
     * @param String documnetId
     */
    public AOB_BOTS_API_SigningHUBDocument(Blob PdfBody, String documnetId){
        this.accessToken = AOB_BOTS_SRV_SigningHUB.getAccessToken();
        this.PdfBody =PdfBody;
        this.documentId=documnetId;
    }
    
    public static final String SERVICE_NAME = AOB_BOTS_API_SigningHUBDocument.class.getName();
    /**
     * @description get Service Name
     */
	@TestVisible    
    protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}
    
     /**
     * @description initialise
     */
    @TestVisible
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
	     */
		public override void populate(Id triggeringObjectId)
		{
			super.populate(triggeringObjectId);
		}
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	@TestVisible
	protected virtual override String getBody()
	{
		super.getBody();

		populateRequestDTO();

		return jsonBody;
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 */
	@TestVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_POST;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected virtual override void setHeaders() 
	{
	  
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, 'application/octet-stream');
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader('x-file-name', 'SAMPLE_DOCUMENT.pdf');
        request.setHeader('x-convert-document', 'true');
        request.setHeader('x-source', 'API');
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);
        request.setBodyAsBlob(PdfBody);
        request.setTimeout(120000); 
     }
      
	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
   protected override String getWebServiceEndPoint() {
       String endPoint;
		if (settings != null) {
			endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint=endPoint+documentId+'/documents';
		}
       return endPoint;
	}
    
     /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new AOB_CTRL_PersonalDetailsMock();
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
	 * @description Wrapper class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		@AuraEnabled
		public String response { get; set; }

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		@TestVisible
		protected override Type getObjectType()
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
	 */
	public class AOB_CTRL_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = '{ "documentid": 13246}';
		/**
		* @description creates a mock response for http calls
		* @param  request
		* @param response
		*/
		@TestVisible
		protected override void setResponse(
				HttpRequest request,
				HttpResponse response
		)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
            response.setStatusCode(201);
		}
	}
    

}