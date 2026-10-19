/**
* @description  class used  for ShareDocuments api
* @date Jan 3rd 2023
*/
public class AOB_BOTS_API_ShareDocuments extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    
    public Integer packageId;
    
     /**
     * @description this method used to share documents
     * @param string packageId
     */
    public AOB_BOTS_API_ShareDocuments(String packageId){
        
        this.accessToken = AOB_BOTS_SRV_SigningHUB.getAccessToken();
        this.packageId=Integer.valueOf(packageId);
    }
    
    public static final String SERVICE_NAME = AOB_BOTS_API_ShareDocuments.class.getName();
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
	 * @return string
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
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader('Content-Length', '0');
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);      
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
            endPoint=endPoint+packageId+'/workflow';
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
    * @description DTO_Response
    */
	public class DTO_Response extends CMN_DTO_JsonBase
	{
		public List<object> response;
         /**
         * @description recieving DTO_Response
         * @param resp
         */
		public DTO_Response(List<object> file)
		{
			this.response = file;
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

    
    public override String getResponseBody()
    {
        return response.getBody();
    }
	/**
	 * @description Mock class for Test classes
	 */
	public class AOB_CTRL_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String VALID_RESPONSE = '{ "businessDetOut":{ "businessDetails":{ "partnerGuid":"4989261e-a6c2-1eed-aeed-01843ec4a584", "businessAttr":{ "idtype":"10", "idnumber":"2020/705550/07", "legalEnty":"002", "nameOrg":"Printing", "turnover":"200000", "natureOfBus":"26", "industryClass":"91100", "prefBranch":"2171", "regCountry":"AF", "mobile":"0694114822", "email":"navya.gogineni@cloud23.io", "addressDetails":{ "addr1":"111", "addr3":"The PLOVER", "city":"Johannesburg", "countydistrict":"Midrand", "stateprov":"ZAF.GPMUS.GP", "countrycode":"ZA" }, "entityClass":"NFI", "taxDetails":[ { "taxType":"AF1", "zztaxReasonCode":"02" } ], "sofDetails":[ { "sofType":"0026", "sofAmount":"100" }, { "sofType":"0027", "sofAmount":"1000" }, { "sofType":"0018", "sofAmount":"2000" }, { "sofType":"0010", "sofAmount":"100" } ], "mktConsents":[ { "mktConsentCode":"ZBP_MKTG_CONSENT_EXT_MKTG", "mktConsentResp":"Y" }, { "mktConsentCode":"ZBP_MKTG_CONSENT_SHARE_CUS_DAT", "mktConsentResp":"Y" }, { "mktConsentCode":"ZBP_MKTG_CONSENT_CROSS_B_SHARE", "mktConsentResp":"Y" } ] } }, "validationErrors":[ { "type":"E", "id":"ZEVS_ID", "message":"A locally incorporated entity must have South Africa as a country" } ] } }';
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
		}
	}

}