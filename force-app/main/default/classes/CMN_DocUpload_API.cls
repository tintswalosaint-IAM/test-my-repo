/**
 * @description       : Class responsible for forming the request payload for Document Upload API and processing the same
 * @author            : NAGENDRAPRASAD MYLAVARAPU
 * @last modified on  : 06-28-2024
 * @last modified by  : Jaco de Lange
**/
public class CMN_DocUpload_API  extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String XID_IBM_CLIENT_ID='X-IBM-Client-Id';
    private static final String XID_IBM_SECRET_ID='X-IBM-Client-Secret';   
	private static final String CIF_COUNTRY ='cifCountry';
    private static final String CIF_CHNAME ='channelName';
    private static final String CIF_CHID ='channelId';
    private static final String CHID ='001';
    private static final String SF ='SF';
	private static final String ZA ='ZA';

    /**
	* @description class Constructor 
	* @param  jsonbody
	*/
    public CMN_DocUpload_API(String jsonbody){
        this.accessToken = CMN_Generate_Token_Helper.getAccessToken();
        this.jsonBody = jsonbody;
    }
    
    public static final String SERVICE_NAME = CMN_DocUpload_API.class.getName();
	@TestVisible
    protected virtual override String getServiceName(){
		return SERVICE_NAME;
	}

    @TestVisible
    protected override void initialise(){
		super.initialise();
		baseRequestDTO = new DTO_Request();
		baseResponseDTO = new DTO_Response();
	}

	private class DTO_Request extends CMN_DTO_JsonBase{
		/**
	     * @description populates triggering object
		 * @param triggeringObjectId
	     */
		public override void populate(Id triggeringObjectId){
			super.populate(triggeringObjectId);
		}
	}

	/**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	@TestVisible
	protected virtual override String getBody(){
		super.getBody();
		populateRequestDTO();
		return jsonBody;
	}

	/**
	 * @description Overriding parent class method to use the right API Method
	 * @return String
	 */
	@TestVisible
	protected override virtual String getVerb(){
		return HTTP_VERB_POST;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 */
	@TestVisible
	protected virtual override void setHeaders(){
		String clientCertificate1 = '{!$Credential.CMN_DocUpload.XClientCertificate1}';
		String clientCertificate2 = '{!$Credential.CMN_DocUpload.XClientCertificate2}';
		String clientCertificate3 = '{!$Credential.CMN_DocUpload.XClientCertificate3}';
		String clientCertificate4 = '{!$Credential.CMN_DocUpload.XClientCertificate4}';
		String clientCertificate5 = '{!$Credential.CMN_DocUpload.XClientCertificate5}';

		request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);
        request.setHeader(XID_IBM_CLIENT_ID, '{!$Credential.CMN_DocUpload.Client_Id}');
        request.setHeader(XID_IBM_SECRET_ID, '{!$Credential.CMN_DocUpload.Client_Secret}');
        request.setHeader(CIF_COUNTRY,ZA); 
		request.setHeader(HTTP_HEADER_CERTIFICATE, clientCertificate1+''+clientCertificate2+''+clientCertificate3+''+clientCertificate4+''+clientCertificate5);
        request.setHeader(CIF_CHNAME,SF); 
        request.setHeader(CIF_CHID,CHID);
        request.setTimeout(120000);
     }
	 
	protected virtual override HttpRequest createRequest(String body){
		setHeaders();

		if(String.isNotBlank(body) && !HTTP_VERB_GET.equalsIgnoreCase(request.getMethod())){
			request.setBody(body);
		}

		String endPoint = getWebServiceEndPoint();
		String queryParams = getQueryParameters();

		endPoint = String.isNotBlank(queryParams) ? endPoint + '?' + queryParams : endPoint;

		callResult.url = endPoint;

		String methodName = getServiceName();
		request.setEndpoint('callout:CMN_DocUpload_API');

		callResult.requestBody = request.getBody();

		return request;
	}
      
	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected override String getWebServiceEndPoint(){
		String endPoint;
		if (settings != null) {
			endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
		}
    	return endPoint;
	}
    
     /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock(){
		super.getEndpointMock();
		return new CMN_DocUpload_SampleMock();
	}

	/**
	 * @description Overriding parent class method to indicate that triggering object is not needed
	 * @return Boolean
	 */
	@TestVisible
	protected override virtual Boolean triggeringObjectRequired(){
		return false;
	}

	/**
	 * @description Wrapper class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase{
		/**
		* @description response
		*/
		@AuraEnabled
		public String response {get; set;}

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		@TestVisible
		protected override Type getObjectType(){
			return DTO_Response.class;
		}
	}

    /**
    * @description method to extract the body of the response
    * @author NAGENDRAPRASAD MYLAVARAPU | 02-19-2024 
    * @return String Serialized body of the response
    **/
    public override String getResponseBody(){
        return response.getBody();
    }
	/**
	 * @description Mock class for Test classes
	 */
	public class CMN_DocUpload_SampleMock extends CMN_API_HttpBaseOutboundMock{
		public final String validResponse = '{"DocumentDirectoryResponse": {"DocumentDirectoryId": "fakeId"}}';
		/**
		* @description creates a mock response for http calls
		* @param  request
		* @param response
		*/
		@TestVisible
		protected override void setResponse(HttpRequest request, HttpResponse response){
			super.setResponse(request, response);
			response.setBody(validResponse);
		}
	}
}