public class CMN_QUEUE_Conversation implements Queueable {
    Map<String, Date> userAENumber2EarliestDate;
    String aeNumberOrAccountConversations;
    String accountId;
    Date accountConversationEarliestDate;

    public CMN_QUEUE_Conversation(Map<String, Date> userAENumber2EarliestDate) {
        this.userAENumber2EarliestDate = userAENumber2EarliestDate;
        this.aeNumberOrAccountConversations = 'AE Number Conversations';
    }

    public CMN_QUEUE_Conversation(String accId, Date earliestDate) {
        this.accountId = accId;
        this.accountConversationEarliestDate = earliestDate;
        this.aeNumberOrAccountConversations = 'Account Conversations';
    }

    public void execute(QueueableContext context) {
        try {
            List<CMN_Conversation__c> conversationsUntilExpiration = new List<CMN_Conversation__c>();

            if (aeNumberOrAccountConversations == 'AE Number Conversations') {
                conversationsUntilExpiration = expireAEConversations();
            } else if (aeNumberOrAccountConversations == 'Account Conversations') {
                conversationsUntilExpiration = expireAccountConversations();
            }
            update conversationsUntilExpiration;
        } catch (Exception error) {
            CMN_UTIL_Logger.error(error, 'CMN_QUEUE_Conversation.execute');
        }

    }

    private List<CMN_Conversation__c> expireAEConversations() {
        List<CMN_Conversation__c> expiredConversations = new List<CMN_Conversation__c>();
        List<CMN_Conversation__c> conversations = [SELECT Id, IsActive__c, AE_Number__c,Status__c, CreatedDate, CMN_ConversationId__c FROM CMN_Conversation__c WHERE Status__c != 'Actioned' AND AE_Number__c IN :userAENumber2EarliestDate.keySet()];

        for (CMN_Conversation__c conversation : conversations) {
            for (String aeNumber : userAENumber2EarliestDate.keySet()) {
                if (conversation.AE_Number__c == aeNumber && conversation.CreatedDate < userAENumber2EarliestDate.get(aeNumber)) {
                    conversation.IsActive__c = false;
                    expiredConversations.add(conversation);
                }
            }
        }
        return expiredConversations;
    }

    private List<CMN_Conversation__c> expireAccountConversations() {
        List<CMN_Conversation__c> expiredConversations = new List<CMN_Conversation__c>();
        List<CMN_Conversation__c> conversations = [SELECT Id, IsActive__c, AE_Number__c,Status__c, CreatedDate, CMN_ConversationId__c FROM CMN_Conversation__c WHERE Status__c != 'Actioned' AND Account__c = :accountId];

        for (CMN_Conversation__c conversation : conversations) {
            if (conversation.CreatedDate < accountConversationEarliestDate) {
                conversation.IsActive__c = false;
                expiredConversations.add(conversation);
            }
        }
        return expiredConversations;
    }
}