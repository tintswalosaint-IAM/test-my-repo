/**
 * @description Class with invocable method to get conversation to recommendation flow
 * @author Jakub Krawczyk
 * @date May 2023
 */
public with sharing class CMN_POC_Conversations {

    /**
     * @description Mthod to get conversation to recommendation flow
     * @param accountIds list of account ids
     * @return listOfConversations List<List<CMN_Conversation__c>>
     */
    @InvocableMethod(Callout=true Label='Get Conversations')
    public static List<List<CMN_Conversation__c>> getAccountConversations(List<Id> accountIds) {
        List<List<CMN_Conversation__c>> listOfConversations = new List<List<CMN_Conversation__c>>();
        List<CMN_Conversation__c> conversations = CMN_CTRL_Conversation.getBankerConversations(accountIds[0], null);
        listOfConversations.add(conversations);
        return listOfConversations;
    }

}