/**
* @description class AOB_BOTS_API_SearchCustomer
*   
* @author Dayakar   
* 
*/ 
public class AOB_BOTS_API_SearchCustomer extends AOB_API_RestBaseOutboundPing{

    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    private static final String CIF_COUNTRY ='cifCountry';
	private static final String BW ='BW';
	private static final String CUSTOMER_TYPE ='customerType';
	private static final String RETAIL ='retail';
    public String firstname;
    public String lastname;
    public String documentCode='D0021';
    public String documentTypeCode='DT000';
	public String dob;
	/**
	* @description class AOB_BOTS_API_SearchCustomer
	* @param  firstname
	* @param lastname 
	* @param dob 
	*/  
    public AOB_BOTS_API_SearchCustomer(String firstname,string lastname,string dob){
        
        this.accessToken = AOB_SRV_GetAccessToken.getAccessToken();
        this.firstname=firstname;
        this.lastname=lastname;
        this.dob=dob;
        
    }
    
    public static final String SERVICE_NAME = AOB_BOTS_API_SearchCustomer.class.getName();
	@TestVisible    
    protected virtual override String getServiceName()
	{
		return SERVICE_NAME;
	}
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
		 * @param triggeringObjectId
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
	 * @return String
	 */
	@TestVisible
	protected override virtual String getVerb()
	{
		return HTTP_VERB_GET;
	}

	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 */
	@TestVisible
	protected virtual override void setHeaders() 
	{
	  
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer '+this.accessToken);
        request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
         request.setHeader(CIF_COUNTRY,BW); 
        request.setHeader(CUSTOMER_TYPE ,RETAIL);  
        request.setTimeout(120000); 
     }
      
	/**
	 * @description Method is use to return the endpoint URL using in HTTP response.
	 *
	 * @return endpoint
	 */
	@TestVisible
	protected override String getWebServiceEndPoint()
	{
        String endPoint;
        if (settings != null) {
            endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint=endPoint+'?firstName='+firstname+'&lastName='+lastname+'&dob='+dob;
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
		return new AOB_BOTS_API_SearchCustomerMock();
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
		/**
		* @description response
		*/
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
	public class AOB_BOTS_API_SearchCustomerMock extends CMN_API_HttpBaseOutboundMock
	{
		public final String validResponse = '{'+
		'   "customers":['+
		'      {'+
		'         "uuid":"d671ca37-9e03-1ee8-8ccb-83263da59c9A",'+
		'         "customerType":"INDIVIDUAL",'+
		'         "personDetails":{},'+
		'         "identifications":['+
		'            ['+
		'               {'+
		'                  "identificationType":"10",'+
		'                  "identificationNumber":"1002212640085",'+
		'                  "issuingCountry":"ZA",'+
		'                  "issuedOrganisation":"ZA",'+
		'                  "issuedDate":"2018-03-28T00:00:00.000Z",'+
		'                  "expirationDate":"9999-12-31T00:00:00.000Z",'+
		'                  "PreferredIdentificationIndicator":"Y",'+
		'                  "documentCode":"",'+
		'                  "documentDescription":"",'+
		'                  "documentTypeCode":"",'+
		'                  "documentTypeDescription":""'+
		'               }'+
		'            ]'+
		'         ],'+
		'         "orgDetails":{'+
		'            "legalName":"TESTING LTD",'+
		'            "companyName":"TESTing",'+
		'            "legalForm":"OTHER",'+
		'            "orgEstablishDt":"2010-10-01T00:00:00.000Z",'+
		'            "numEmployees":20,'+
		'            "fiscalYearEnd":"2021-02-28T00:00:00.000Z",'+
		'            "ownership":"string"'+
		'         },'+
		'         "additionalProp1":{'+
		'            '+
		'         }'+
		'      }'+
		'   ],'+
		'   "pages-sent":"10",'+
		'   "matched-page-count":"500",'+
		'   "pages-remaining":406'+
		'}';
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
			response.setBody(validResponse);
		}
	}
    
}