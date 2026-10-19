/***************************************************************************************
@Name of the Class :KYC_API_GenerateAccessToken
@Description :SFP-32817 Class used to call GenerateAccessToken API.	
@Author :Dayakar 
@Created Date :sept 09 2024
***************************************************************************************
* Last Modified By  Dayakar
* Last Modified Date sept 23 2024
* Last Modified Description: Initital Version
***************************************************************************************
* Last Modified By  Alexandr Goryachko
* Last Modified Date 17/12/2025
* Last Modified Description: Added timeout 30 seconds
* User Story : SFP-53455
****************************************************************************************/
public inherited sharing class KYC_API_GenerateAccessToken extends AOB_API_RestBaseOutboundPing {
    public static Boolean isFailed=true;
   
    public KYC_API_GenerateAccessToken(String jsonBody)
    {   
        
        this.jsonBody = jsonBody;
       
    }
    public static final String SERVICE_NAME = KYC_API_GenerateAccessToken.class.getName();
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    *
    * @return SERVICE_NAME
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
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
        */
        @TestVisible
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
    public virtual override String getBody()
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
    
    @TestVisible
    protected virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setTimeout(30000);
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_FORM_URL_ENCODED);
        
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
        if (settings != null && String.isNotBlank(settings.CMN_Path__c)) {
            endPoint=settings.CMN_Path__c;
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
        if(isFailed){
            return new GenerateAccessTokenMock();
        }
        return new GenerateAccessTokenNegMock();
        
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
        * @return String
        */
        @AuraEnabled
        public string response { get; set; }
        
       /**
        * @description The Type of the DTO used when deserializing the class
        *
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
    */
    public class GenerateAccessTokenMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{"access_token":"eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0xIiwicGkuYXRtIjoieHkwaCJ9.eyJzY3AiOltdLCJhdXRob3JpemF0aW9uX2RldGFpbHMiOltdLCJjbGllbnRfaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiNXk5NDhTQkVFZjdIZ040SERGMDFJTyIsInN1YiI6ImI3MTI1OGI2LTQ3NDAtNDE5Ny1hNzg5LTkwMGFiYzY4Zjc3MyIsIm5iZiI6MTcyNjA1MzM2MywiaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpYXQiOjE3MjYwNTMzNjMsImV4cCI6MTcyNjA1Njk2M30.Ep-pWgIjU9jzzPEmJBi_wzQTkMIgd7Kv8tday9blwshG4xxDgGlccdqSmLAOBWq3jNQDR20sdI2--ZagBzwFLMhPTuhz2cY_0V2sZ1I81iWj7Ke99eWht17kmKHbrnft1c9G3v3TCiK94iiLOYB_4Wz3SDN8xAZH5f9ej3zFTNRjp4iFyNAex_W2FkgfXcJwZuv27BVXU31AwyAg56VYUU9Wv5Xy7Z_6ZD8_zwQm9cXptaEJISBlbvBanm3WXmya2t4a47pCKbi_NcCvMImQO7qH04wXXCYGphZ-Oc32M-9AQLadYlFqD9KL479VKotVuQNRe6p4I2iI3Ipjx_P2uA","token_type":"Bearer","expires_in":3599}';
        
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
    
    /**
    * @description Mock class for Test classes
    */
    public class GenerateAccessTokenNegMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{"access_token"{:"eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0xIiwicGkuYXRtIjoieHkwaCJ9.eyJzY3AiOltdLCJhdXRob3JpemF0aW9uX2RldGFpbHMiOltdLCJjbGllbnRfaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwianRpIjoiNXk5NDhTQkVFZjdIZ040SERGMDFJTyIsInN1YiI6ImI3MTI1OGI2LTQ3NDAtNDE5Ny1hNzg5LTkwMGFiYzY4Zjc3MyIsIm5iZiI6MTcyNjA1MzM2MywiaWQiOiJiNzEyNThiNi00NzQwLTQxOTctYTc4OS05MDBhYmM2OGY3NzMiLCJpYXQiOjE3MjYwNTMzNjMsImV4cCI6MTcyNjA1Njk2M30.Ep-pWgIjU9jzzPEmJBi_wzQTkMIgd7Kv8tday9blwshG4xxDgGlccdqSmLAOBWq3jNQDR20sdI2--ZagBzwFLMhPTuhz2cY_0V2sZ1I81iWj7Ke99eWht17kmKHbrnft1c9G3v3TCiK94iiLOYB_4Wz3SDN8xAZH5f9ej3zFTNRjp4iFyNAex_W2FkgfXcJwZuv27BVXU31AwyAg56VYUU9Wv5Xy7Z_6ZD8_zwQm9cXptaEJISBlbvBanm3WXmya2t4a47pCKbi_NcCvMImQO7qH04wXXCYGphZ-Oc32M-9AQLadYlFqD9KL479VKotVuQNRe6p4I2iI3Ipjx_P2uA","token_type":"Bearer","expires_in":3599}';
        
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