/**
* @description class used for sending OTP
* @author Ruchi 
* @date May 2023
* Story Number- SFP-24628
*/
public class CMN_API_SendOTP extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = CMN_API_SendOTP.class.getName();
    /**
* @description constructor used to make sure a token will be provided to authenticate to the API call
*@param jsonbody
*@param accessToken
*/
   public CMN_API_SendOTP(String jsonbody,String accessToken){
        
        this.accessToken = accessToken;
        this.jsonBody = jsonbody;
    }
    
    
    /**
* @description used get the ServiceName
  @return String
*/
    
    @TestVisible    
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }
    
    /**
* @description used get the initialise
*/
    @TestVisible
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
        
    }
       /**
* @description Mock class for Test classes
*/
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        /**
* @description populates triggering object
*@param triggeringObjectId
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
* @description Method is use to return the endpoint URL using in HTTP response.
* 
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
        request.setHeader('cifCountry','UG');
        request.setTimeout(120000); 
    }
    
    /**
* @description Method is use to return the endpoint URL using in HTTP response.
* @return String
*/
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        if (settings != null) {
            endPoint = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
        }
        return endPoint;
    }
    
    
    /**
* @description Call the parent objects' method to ensure we get code coverage
* @return AOB_CTRL_PersonalDetailsMock
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
        /**
* @description creates response
*/
        @AuraEnabled
        public String response { get; set; }
        
        /**
* @description The Type of the DTO used when deserializing the class
* @return Class of the DTO
*/
        @TestVisible
        protected override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    /**
* @description get response body
* @return String
*/
    public override String getResponseBody()
    {
        return response.getBody();
    }
    /**
* @description Mock class for Test classes
*/
    public class AOB_CTRL_PersonalDetailsMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse = '{"Code":"200"}';
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