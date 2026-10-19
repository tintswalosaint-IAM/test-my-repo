/*************************************************************
* @Name of the Class:  ICS_API_fetchJourneyDefinitionId
* @description:  Class used to fetch DefId of GBG
* @Story: SFP-37310
* @author: Ikyatha Naidu
* @date 11/01/2024 
***************************************************************
* @last modified on  :11/07/2024
* @last modified by  : Ikyatha Naidu
* @Modification Description : Class used to fetch DefId of GBG 
****************************************************************/
public with sharing class ICS_API_fetchJourneyDefinitionId extends ICS_API_RestBaseOutbound {
    
    // Named credential URL format for making callouts
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    // Static variable to store access token
    Public   String tokenInfo;
    
    // Static variable to indicate if the test failed
    public static Boolean isFailedTest = false; 
    // Service name for logging and custom settings lookup
    public static final String SERVICE_NAME = ICS_API_fetchJourneyDefinitionId.class.getName();
    

    /**
    * @description Populates the request DTO (Data Transfer Object) with necessary data
    */
    protected virtual override void populateRequestDTO() {
        super.populateRequestDTO();
        if(queueItem.CMN_TriggeringObjectId__c != null){
        	baseRequestDTO.populate(queueItem.CMN_TriggeringObjectId__c);
        }
    }
    
    /**
    * @description Gets query parameters for the API call, returns null since no query parameters are needed
    * @return null
    */
    protected virtual override String getQueryParameters() {
        return null;
    }
    
    /**
    * @description Gets the service name for custom settings lookup
    * @return SERVICE_NAME
    */
    @TestVisible
    protected virtual override String getServiceName() {
        return SERVICE_NAME;
    }
	
    /**
    * @description Initializes request and response DTO types
    */
    @TestVisible
    protected override void initialise() {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
    /**
    * @description DTO_Request class used to define the structure of the request DTO
    */
    @TestVisible
    private class DTO_Request extends CMN_DTO_JsonBase {
        /**
        * @description Populates the request DTO with the triggering object ID
        * @param triggeringObjectId ID of the triggering object
        */
        public override void populate(Id triggeringObjectId) {
            super.populate(triggeringObjectId);
        }
    }
    
    /**
    * @description Serializes the request DTO to JSON after it's populated
    * @return JSON representation of the request DTO
    */
    @TestVisible
    public virtual override String getBody() {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    
    /**
    * @description Gets the HTTP verb for the API call
    * @return HTTP_VERB_GET
    */
    @TestVisible
    protected virtual override String getVerb() {
        return HTTP_VERB_GET;
    }

    /**
    * @description Sets the headers for the API request
    */
    @TestVisible
    protected virtual override void setHeaders() {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_AUTHORIZATION, ICS_Constants.BEARER + ' ' + tokenInfo);
        request.setTimeout(ICS_Constants.timeoutVal);
    }
    
    /**
    * @description Gets the endpoint URL for the API call using named credentials
    * @return Endpoint URL
    */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                    String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY
                }
            );
        }
        return endPoint;
    }
    
    /**
    * @description Gets the mock endpoint for testing purposes
    * @return Mock endpoint object
    */
    protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
        super.getEndpointMock();
        return new ICS_API_GenerateTokenGBG.ICS_API_GenerateTokenGBGMock(SERVICE_NAME,200);
    }
    
    /**
    * @description Indicates that the triggering object is not needed for this API call
    * @return false
    */
    @TestVisible
    protected virtual override Boolean triggeringObjectRequired() {
        return false;
    }
    
    /**
    * @description DTO_Response class used to define the structure of the response DTO
    */
    public class DTO_Response extends CMN_DTO_JsonBase {
        /**
        * @description Gets the type of the DTO used when deserializing the response
        * @return DTO_Response class type
        */
        @TestVisible
        public override Type getObjectType() {
            return DTO_Response.class;
        }
    }
    
    /**
    * @description Processes the HTTP response and extracts the journey definition ID
    * @return JSON string containing the journey definition ID
    */
    public override String getResponseBody() {
        String journeyDefId = '';
        List<JourneyDefinition> journeyDefinitions = (List<JourneyDefinition>)JSON.deserialize(response.getBody(), List<JourneyDefinition>.class);

        for (JourneyDefinition journey : journeyDefinitions) {
            if (journey.Name == settings.CMN_AdditionalKey__c) {
                journeyDefId = journey.JourneyDefinitionId;
            }
        }
        
        journeyDefId = '{"defId":"' + journeyDefId + '"}';
        return journeyDefId;
    }
    
    /**
    * @description JourneyDefinition class to define the structure of a journey definition
    */
    public class JourneyDefinition {
        public String journeyDefinitionId; // ID of the journey definition
        public String name; // Name of the journey definition
    }

    /**
    * @description JourneyEntryDefinition class to define the structure of a journey entry definition
    */
    public class JourneyEntryDefinition {
        public String journeyEntryDefinitionId; // ID of the journey entry definition
        public String journeyDefinitionId; // ID of the journey definition
    }
}