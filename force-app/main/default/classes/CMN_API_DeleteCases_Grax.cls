/**
* @description This class do a callout to Grax to delete relent records.
* @author Mthandeni Gumede
* @date  18/01/2024
*/ 
public class CMN_API_DeleteCases_Grax extends CMN_API_HttpBaseOutbound {
    public static final String SERVICE_NAME = CMN_API_DeleteCases_Grax.class.getName();
    public String jsonBody;
  
    /**
	* @description class construtor CMN_API_DeleteCases_Grax
	* @param  jsonbody
	*/
    public CMN_API_DeleteCases_Grax(String jsonbody){
        this.jsonBody = jsonbody;
    }
    
    /**
	* @description Overriding parent class method to getServiceName
	* @return  String
	*/
    @TestVisible    
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }
    
    /**
	 * @description Overriding parent class method to initialise
	 */
    @TestVisible
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        
    }
    
    /**
	 * @description Will serialize requestDTO after its been populated.
	 * @return String
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
		return HTTP_VERB_POST;
	}
    
    /**
	 * @description Overriding parent class method to set headers on Request
	 */
	@TestVisible
	protected virtual override void setHeaders() 
	{
	  
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer');
       
     }

    /**
	 * @description Overriding parent class method to get endpoint on Request
	 * @return String
	 */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        POPIA_API_Config__mdt calloutConfig = POPIA_API_Config__mdt.getInstance('Grax');
        if (settings != null) {
         endPoint = 'callout:Grax_API/api/v2/salesforce/' + calloutConfig.OrgId__c + '/objects/' + calloutConfig.HierarchyObject__c +  '/delete?cascade=true&forceCascadeObjects=' +calloutConfig.CascadeObjects__c+ '&skipDeletedCheck=false';
        }
        return endPoint;
    } 
    
    /**
	 * @description Overriding parent class method to get RequestCode
	 * @return Integer
	 */
    @TestVisible
	public virtual Integer getResponseStatusCode()
	{
		return response.getStatusCode();
	}

    /**
	 * @description Overriding parent class triggeringObjectRequired method
	 * @return Boolean
	 */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
    /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() 
    {
		super.getEndpointMock();
		return new CMN_API_DeleteCases_CreateCustomerMock();
	}
    
    /**
	 * @description Wrapper class for http Request
	 */
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
   ** @description Mock class for Test classes
   */
    public class CMN_API_DeleteCases_CreateCustomerMock extends CMN_API_HttpBaseOutboundMock
    {
       public final Integer validResponseCode = 202;
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
            response.setStatusCode(validResponseCode);
		}
	}
        
}