/**
 * @description Class used to send Conversation updates to SB API
 * @author BlueSky Team
 * @date January 2022
 */
public without sharing class CMN_FLOW_SendConversation {
    
    /**
     * @description Invocable method thta sends conversation updates to SB API
     * @param conversationIds List of conversation Ids
     */
    @InvocableMethod(
        label='Send Conversation'
        description='Accepts Conversation record Id, executes callous in a future method'
    )
    public static void sendConversations(List<String> conversationIds) {
        sendConversationsFuture(conversationIds);
    }

    /**
     * @description Future method that sends conversation updates to SB API and create History notes based on actioned conversation
     * @param conversationIds List of conversation Ids
     */
    @future(callout=true)
    public static void sendConversationsFuture(List<String> conversationIds) {
        CMN_DTO_AuthenticationResponse accessToken = CMN_API_GetAccessToken.getAccessToken('customer prod retail');
        if (accessToken == null || accessToken.access_token == null) {
            CMN_UTIL_Logger.error('No API access token available', 'CMN_FLOW_SendConversation');
            return;
        }
        List<CMN_Conversation__c> conversations = [
            SELECT Id, Account__c, Lead_Key__c, Reason__c, Response__c, Details__c
            FROM CMN_Conversation__c
            WHERE Id IN :conversationIds
        ];
        if (conversations.size() > 0) {
            // send conversations updates to NBA
            CMN_API_GetConversations.sendConversations(accessToken.access_token, conversations);
            // create history notes (TODO: does NOT handle multiple conversations)
            String conversationResponseDetails =
                ' DETAIL : ' + conversations[0].Details__c +
                ' RESPONSE : ' + conversations[0].Response__c +
                ' REASON ' + conversations[0].Reason__c;
            CMN_CTRL_HistoryNotes.createHistoryNotes(conversations[0].Account__c, conversationResponseDetails, 'CUSTOMER NOTE');
        }
    }
}