/**
 * @description Data Access Layer class for the CMN_Conversation__c object
 *
 * @author Joan MacDonald
 *
 * @date October 2021
 */
public with sharing class CMN_DAL_Conversation {

	/**
	 * @description Method returns Conversations for account
	 * @param accountId Id of account
	 * @return conversations List of Conversations
	 */
    public static List<CMN_Conversation__c> getAccountConversations(Id accountId) {
        List<CMN_Conversation__c> conversations = [
            SELECT Id, Account__r.Name, Account__c, Category__c, Client_Type__c, Name, Lead_Key__c, Sub_Category__c, Conversation_Details__c,
                    CMN_ConversationId__c, CMN_ValueTier__c, CMN_ExpectedRevenue__c, AE_Number__c, Cat_Position__c, CMN_SubCategoryPosition__c
            FROM CMN_Conversation__c
            WHERE Account__c = :accountId AND Status__c != 'Actioned' AND IsActive__c = TRUE
            ORDER BY LastModifiedDate DESC
        ];
        return conversations;
    }

	/**
	 * @description Method returns Conversations for specified RM AE code
	 * @param rmAeCode RM AE code
	 * @return conversations List of Conversations
	 */
    public static List<CMN_Conversation__c> getConversationsByRmAeCode(String rmAeCode) {
        List<CMN_Conversation__c> conversations = [
            SELECT Id, Account__r.Name, Account__c, Category__c, Client_Type__c, Name, Lead_Key__c, Sub_Category__c, Conversation_Details__c,
                    CMN_ConversationId__c, CMN_ValueTier__c, CMN_ExpectedRevenue__c, AE_Number__c, Cat_Position__c, CMN_SubCategoryPosition__c
            FROM CMN_Conversation__c
            WHERE AE_Number__c = :rmAeCode AND Status__c != 'Actioned' AND IsActive__c = TRUE
            ORDER BY LastModifiedDate DESC
        ];
        return conversations;
    }
    
	/**
	 * @description Method returns RM AE Code for specified user
	 * @param userId The id of our current User
	 * @return string
	 */
    public static String getRmAeCode(Id userId) {
        User userAECode = [SELECT Id, RM_AE_Code__c FROM User WHERE Id = :userId LIMIT 1];
        return userAECode.RM_AE_Code__c;
    }
    
    /**
     * @description Get conversation records by Lead Key
	 * @param conversationIds Conversation Id Set
     * @return List of conversations
     */
    public static List<CMN_Conversation__c> getConversationsByConversationIds(Set<String> conversationIds) {
        List<CMN_Conversation__c> conversations = [
            SELECT Id, AE_Number__c, Lead_Key__c, Reason__c, Response__c, Details__c, Status__c, CMN_ConversationId__c, CMN_ValueTier__c,
                    CMN_ExpectedRevenue__c, Cat_Position__c, CMN_SubCategoryPosition__c
            FROM CMN_Conversation__c
            WHERE CMN_ConversationId__c IN :conversationIds
        ];
        return conversations;
    }
    
    /**
     * @description Get conversation records for Actioned Status
     * @return List of conversations
     */
    public static List<CMN_Conversation__c> getUnActionedConversations() {
        List<CMN_Conversation__c> conversations = [SELECT Id FROM CMN_Conversation__c WHERE Status__c != 'Actioned' AND CreatedDate < :(System.Date.Today() - 7)];
        return conversations;
    }
    
    /**
     * @description Get conversation records for Unactioned Status
     * @return List of conversations
     */
    public static List<CMN_Conversation__c> getActionedConversations() {
        List<CMN_Conversation__c> conversations = [SELECT Id FROM CMN_Conversation__c WHERE Status__c = 'Actioned' AND CreatedDate < :(System.Date.today() - 90)];
        List<Opportunity> opportunitiesFromConversations = [SELECT Id, CMN_NBAConversation__c FROM Opportunity WHERE CMN_NBAConversation__c IN :conversations];

        List<CMN_Conversation__c> conversationsToDelete = new List<CMN_Conversation__c>();
        Map<Id, List<Opportunity>> conversationIdToOpportunity = new Map<Id, List<Opportunity>>();
        for(Opportunity opportunity : opportunitiesFromConversations) {
            if(!conversationIdToOpportunity.containsKey(opportunity.CMN_NBAConversation__c)) {
                conversationIdToOpportunity.put(opportunity.CMN_NBAConversation__c, new List<Opportunity>());
            }
            conversationIdToOpportunity.get(opportunity.CMN_NBAConversation__c).add(opportunity);
        }
        for(CMN_Conversation__c conversation : conversations) {
            if(!conversationIdToOpportunity.containsKey(conversation.Id)) {
                conversationsToDelete.add(conversation);
            }
        }

        return conversationsToDelete;
    }    
}