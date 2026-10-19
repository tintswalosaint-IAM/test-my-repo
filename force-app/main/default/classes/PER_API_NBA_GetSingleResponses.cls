/**
 * @description       : API Service for the Personlisation NBA Conversation response 
 * @test              : PER_API_NBA_Service_Test
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 25-04-2024
 * @last modified by  : Derek Hughes
**/
public with sharing class PER_API_NBA_GetSingleResponses extends PER_API_NBA_Service {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_NBA_GetResponses');

    // Constants
    private static final String PATH_SINGLE_RESPONSES = '/smart-conversations/conversations-single-responses';
  
    /**
    * @description Sends the API call for the specified country and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode 
    * @return List<DTO_ConversationResponses> 
    **/
    public List<DTO> call(String countryCode) {
		setResponseDtoType(List<DTO>.class);
        List<DTO> dto = (List<DTO>) get(PATH_SINGLE_RESPONSES + '?countryCode='+countryCode);
        return dto;
    }

    /**
     * DTO object to represent the API responses
     * JsonAccess required to allowed package code in another namepace to use this class
     */
	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always') 
    public class DTO {
        public String countryCode;
        public List<Response> responses;
    }

	@SuppressWarnings('PMD') 
    @JsonAccess(deserializable='always') 
    public class Response {
        public String subCategory;
        public String response;
        public Boolean futureDate;
    }

}