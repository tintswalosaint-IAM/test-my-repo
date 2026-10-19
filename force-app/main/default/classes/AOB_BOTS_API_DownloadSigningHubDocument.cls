public class AOB_BOTS_API_DownloadSigningHubDocument extends AOB_API_RestBaseOutboundPing{
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    /**
* @description this method used to AOB_BOTS_API_SignPackages
* @param string jsonBody
*/
    
    public String packageId;
    public AOB_BOTS_API_DownloadSigningHubDocument(String pacakageId){
        
        this.accessToken = AOB_BOTS_SRV_SigningHUB.getAccessToken();
        this.packageId=pacakageId;
    }
    
    public static final String SERVICE_NAME = AOB_BOTS_API_DownloadSigningHubDocument.class.getName();
    /**
* @description get Service Name
*/
    @TestVisible    
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
        jsonBody=jsonBody;
        
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
        return HTTP_VERB_GET;
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
        }
        endPoint=endPoint+packageId;
        
        return endPoint;
    }
    
    
    /**
* @description Overriding parent class method to indicate that triggering object is not needed
* @return Boolean
*/
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
    /**
* @description DTO_Response
*/
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public Blob response;
        /**
* @description recieving DTO_Response
* @param file 
*/
        public DTO_Response(Blob file)
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
    
    
    /**
* @description Used to get response Body
*
* @return
*/
    public Blob getResponseBlobBody()
    {
        return response.getBodyAsBlob();
    }
    
}