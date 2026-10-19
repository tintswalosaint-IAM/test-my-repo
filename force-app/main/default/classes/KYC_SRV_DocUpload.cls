/***************************************************************************************
@Name of the Class :KYC_SRV_DocUpload
@Description :SFP-51843:Created
@Author :Irshad 
@Created Date :12/08/2025
@LastModifiedDate : 19/01/2026 - Updtaed the getWebServiceEndPoint to get the endpoint from custom metadata
***************************************************************************************/
public inherited sharing class KYC_SRV_DocUpload extends AOB_API_RestBaseOutboundPing{

   
    
    public String transactionID;
    public String assessmentId;
    public KYC_SRV_DocUpload(String jsonBody)
    {   
        this.jsonBody = jsonBody;
        this.accessToken=KYC_SRV_GenerateAccessToken.getAccessToken();
        this.transactionID=UUID.randomUUID().toString();
    }
    public static final String SERVICE_NAME = KYC_SRV_DocUpload.class.getName();
    @TestVisible static CMN_API_HttpBaseOutboundMock injectedMock;
    
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
    
    /**
    * @description Overriding parent class method to use set Headers
    */
    @TestVisible
    protected virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, 'Bearer ' + this.accessToken);
        request.setHeader('country_code','KE');
        request.setHeader('transaction_id',transactionID);
        request.setHeader('client_id', '{!$Credential.KYC_MulesoftConnect_ENC.Kyc_client_id}');
        request.setHeader('ORG_CLIENT_ID', '{!$Credential.KYC_MulesoftConnect_ENC.Kyc_client_id}');
        
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
        String subUrl='/' + settings.AOB_Channel__c + settings.CMN_Path__c.replace('{transactionId}', transactionId);
        if (settings != null && String.isNotBlank(settings.CMN_Path__c)) {
            endPoint=settings.CMN_NamedCredential__c +subUrl;
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
        if (Test.isRunningTest() && injectedMock != null){
            return injectedMock;
        }
        return new RassMockCallout();
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
    
    /**
    * @description Overriding parent class method to use responseBody
    */
    public override String getResponseBody()
    {
        return response.getBody();
    }
    
    
    /**
    * @description Mock class for Test classes
    */
    
    public class RassMockCallout extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{"documentStatus":"Success","documentStatusMessage":"Uploaded OK"}';
        
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