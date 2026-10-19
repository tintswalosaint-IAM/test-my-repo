/**
 * @description       : API Service for Personalisation NBA 
 * @test              : PER_API_NBA_Service_Test
 * @author            : Derek Hughes
 * @group             : API
 * @last modified on  : 24-04-2024
 * @last modified by  : Derek Hughes
 **/
public virtual with sharing class PER_API_NBA_Service extends sbgplatform.ApiGatewayService {

    // Constants
    private static final String NAMED_CREDENTIAL = 'API_Gateway_Personalisation';
    private static final String PATH_CONVERSATIONS_SINGLE = '/smart-conversations/conversations-single';
    private static final String PATH_PORTFOLIO_SINGLE = '/smart-conversations/portfolio-single-conversations';
    private static final String PATH_NBA_SINGLE = '/smart-conversations/conversations-single-nba';

    public PER_API_NBA_Service () {
        super(NAMED_CREDENTIAL);
    }
 
    /**
    * @description Sends the API call for the specified country and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode 
    * @return List<DTO_ConversationResponses> 
    **/
    public CMN_DTO_ConversationsResponse getPortfolioSingle(String countryCode, String aeNumber) {

        //Prepare Request Data
        String requestBody = '{"aeNumber":"{0}", "countryCode": "{1}"}';
        requestBody = requestBody.replace('{0}', aeNumber);
        requestBody = requestBody.replace('{1}', countryCode);

        setResponseDtoType(CMN_DTO_ConversationsResponse.class);

        CMN_DTO_ConversationsResponse dto = (CMN_DTO_ConversationsResponse) post(PATH_PORTFOLIO_SINGLE, requestBody);

        return dto;
    }

    /**
    * @description Sends the API call for the specified country and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode 
    * @param cifNumber
    * @return List<DTO_ConversationResponses> 
    **/
    public CMN_DTO_ConversationsResponse getClientSingle(String countryCode, String cifNumber) {

        //Prepare Request Data
        String requestBody = '{"newCustN":"{0}","countryCode": "{1}", "onlyIndicated": true}';
        requestBody = requestBody.replace('{0}', cifNumber);
        requestBody = requestBody.replace('{1}', countryCode);

        setResponseDtoType(List<CMN_DTO_ConversationsResponse.Conversation>.class);

        List<CMN_DTO_ConversationsResponse.Conversation> conversations;
        conversations = (List<CMN_DTO_ConversationsResponse.Conversation>) post(PATH_CONVERSATIONS_SINGLE, requestBody);

        // This call returns "customerNumber" and not "newCustN" so a conversion is required to make this standard
        for (CMN_DTO_ConversationsResponse.Conversation conversation    : conversations) {
            if (conversation.newCustN ==null || conversation.newCustN == 0) {
                conversation.newCustN = conversation.customerNumber;
            }
        }

        CMN_DTO_ConversationsResponse dto = new CMN_DTO_ConversationsResponse();
        dto.clientPortfolioConversationList = conversations;

        return dto;
    }

    /**
    * @description Sends the API call for the specified country and returns the response as a list of DTOs
    * @author Derek Hughes | 01-03-2024 
    * @param countryCode 
    * @param actionId 
    * @param results 
    **/
    public void sendConversations(String countryCode, List<String> actionIds, List<sbgpers.RecommendedActionResult> results) {

        //Prepare Request Data
        String requestBody;
        requestBody = '{"listNbas":[';

        for (Integer i=0; i<results.size(); i++) {
            sbgpers.RecommendedActionResult result = results[i];
            String actionId = actionIds[i];

            String followUpDate = '';
            if (result.followUpDate != null) {
                Datetime output = Datetime.newInstanceGmt(result.followUpDate, Time.newInstance(0,0,0,0));
                // now output is the same as it was in `bar`
                followUpDate = output.formatGmt('yyyy-MM-dd');
            }

            String encodedNotes = JSON.serialize(result.notes);
            encodedNotes = encodedNotes.mid(1, encodedNotes.length()-2);  // remove the leading and trailing doubl quote
            encodedNotes = encodedNotes.left(500); // API can only accept 500 characters.
            String conversationBody = '{';
            conversationBody += '"leadKey":"' + actionId + '"';
            conversationBody += ',"response":"' + result.response + '"';
            conversationBody += ',"reason":"' + result.reason + '"';
            conversationBody += ',"futureContactDate":"' + followUpDate + '"';
            conversationBody += ',"additionalInfo":"' + encodedNotes + '"'; 
            conversationBody += '}';
            requestBody += conversationBody + ',';
        }
        requestBody = requestBody.removeEnd(',');
        requestBody += ']';
        requestBody += ',"countryCode": "'+countryCode+'"';
        requestBody += '}';

        String response = (String) put(PATH_NBA_SINGLE, requestBody);

        if (!response.equalsIgnoreCase('true')) {
            throw new ServiceException('API callout failed: Unknown error occurred when updating NBA.');
        }
    }

    private class ServiceException extends Exception {}

}