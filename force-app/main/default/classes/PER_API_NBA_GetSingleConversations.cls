/**
 * @description       : API Service get conversations for a single client
 * @test              : PER_API_NBA_Service_Test
 * @author            : Derek Hughes
 * @group             : Personalisation
 * @last modified on  : 16-04-2024
 * @last modified by  : Derek Hughes
**/
public with sharing class PER_API_NBA_GetSingleConversations extends PER_API_NBA_Service {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_NBA_GetResponses');

    // Constants
    private static final String PATH_CONVERSATIONS_SINGLE = '/smart-conversations/conversations-single';
  
    /**
    * @description Sends the API call for the specified country and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode 
    * @return List<DTO_ConversationResponses> 
    **/
    public CMN_DTO_ConversationsResponse call(String countryCode, String aeNumber) {

        //Prepare Request Data
        String requestBody = '{"aeNumber":"{0}", "countryCode": "{1}"}';
        requestBody = requestBody.replace('{0}', aeNumber);
        requestBody = requestBody.replace('{1}', countryCode);

		setResponseDtoType(List<CMN_DTO_ConversationsResponse.Conversation>.class);

        List<CMN_DTO_ConversationsResponse.Conversation> conversations = (List<CMN_DTO_ConversationsResponse.Conversation>) post(PATH_CONVERSATIONS_SINGLE, requestBody);

        // This call returns "customerNumber" and not "newCustN" so a conversion is required to make this standard
        for (CMN_DTO_ConversationsResponse.Conversation conversation : conversations) {
            if (conversation.newCustN ==null || conversation.newCustN == 0) {
                conversation.newCustN = conversation.customerNumber;
            }
        }

        CMN_DTO_ConversationsResponse dto = new CMN_DTO_ConversationsResponse();
        dto.clientPortfolioConversationList = conversations;

        return dto;
    }

    /**
     * DTO object to represent the API responses
     */
    // public class DTO {
    //     public Integer totalSize;
    //     public List<Conversation> clientPortfolioConversationList;
    // }

    public class DTO {
        public Long newCustN;
        public Long customerNumber;
        public String clientType;
        public String clientName;
        public String identification;
        public String identifier;
        public String tier;
        public String aeNumber;

        public String conversationId;
        public String category;
        public Integer catPosition;
        public String subCategory;
        public Integer subCatPosition;
        public String detail;
        public String actionScript;
        public String contactType;
        public String response;
        public String reason;
        public String additionalInformation;
        public Decimal expectedRevenue;
        public String futureContactDate;
        public String leadKey;
    }

}