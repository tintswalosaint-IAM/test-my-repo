/**
* @description Scheduled Class that Deletes All Actioned NBA Conversation Records
*
* @author BlueSky
*
* @date October 2021
*/
public with sharing class CMN_SCHED_DeleteActionedConversations implements Schedulable {
    
    /**
    * @description Execute Method for Schedulable Class
    *
    * @param sc SchedulableContext Variable
    */
    public void execute(SchedulableContext sc) {
        
        List<CMN_Conversation__c> conversations = CMN_DAL_Conversation.getActionedConversations();
        if(conversations != null
           && !conversations.isEmpty())
        {
            delete conversations;
        }
    }
}