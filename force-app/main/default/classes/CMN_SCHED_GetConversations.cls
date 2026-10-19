/**
* @description Schedulable class for Get Conversations batch
*
* @author Gnitsevich Anton
*
* @date October 2021
*/
public with sharing class CMN_SCHED_GetConversations implements Schedulable {
    /**
    * @description Execute Method for Schedulable Class
    *
    * @param sc SchedulableContext Variable
    *
    */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CMN_BATCH_GetConversations(), 10);
    }
}