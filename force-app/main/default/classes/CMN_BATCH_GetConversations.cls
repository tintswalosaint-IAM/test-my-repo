/**
 * @description Class used to Perform Batch Request for get Conversations
 *
 * @author BlueSky Team
 *
 * @date October 2021
 */
public with sharing class CMN_BATCH_GetConversations implements Database.Batchable<sObject>, Database.AllowsCallouts {
    @TestVisible String query = 'SELECT Id, RM_AE_Code__c FROM User WHERE RM_AE_Code__c != null';

    /**
     * @description Start Method for Batch Class
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        if (Test.isRunningTest()) {
            query = 'SELECT Id, RM_AE_Code__c FROM User WHERE LastName = \'TestLastName\' LIMIT 1';
        }
        return Database.getQueryLocator(query);
    }
    
    /**
     * @description Execute Method for Batch Class
     * @param bc Database.BatchableContext
     * @param scope List<User> scope
     */
    public void execute(Database.BatchableContext bc, List<User> scope) {
        CMN_CTRL_Conversation.retrieveRMConversations(scope);
    }
    
    /**
     * @description Finish Method for Batch Class
     * @param bc Database.BatchableContext
     */
    public void finish(Database.BatchableContext bc) {
        List<AsyncApexJob> jobs = [SELECT Id, NumberOfErrors, JobItemsProcessed FROM AsyncApexJob  WHERE Id =: bc.getJobId()];
        if (jobs[0].NumberOfErrors > 0) {
            String message = 'A number of jobs failed during batch execution: ' + jobs[0].NumberOfErrors + '; total jobs processed: ' + jobs[0].JobItemsProcessed;
            CMN_UTIL_Logger.error(message, 'CMN_BATCH_GetConversations');
        }
    }
}