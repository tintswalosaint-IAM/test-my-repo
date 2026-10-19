/**
 * @author		Emmanuel Mulea(Nocks)
 * @date	    18/10/2021
 * @description Batch class to insert records returned from smart2 Integration
*/
global without sharing class PbbSmart2ConversationPicklistSyncBatch  implements Database.Batchable<sObject>{
    global List<SObject> dataList;
    /**
    * @description This is a constructor that get a list of conv list
    * @param	convList List<SObject>
    **/
    global PbbSmart2ConversationPicklistSyncBatch(List<SObject> convList) {
        this.dataList = convList;
    }
    /**
    * @description This is Start method for a Batch to run the Qyery locator
    * @param	bc Database.BatchableContext of the Apex batch
    * @return   Query locator results
    **/
    global Iterable<sObject> start(Database.BatchableContext bc) {
        return this.dataList;
    }
    /**
    * @description This is exucute method for a Batch to run the and execute results from dataList
    * @param	bc Database.BatchableContext of the Apex batch
    * @param	scope Object List
    **/
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        List<Conversation_Value__c> convList = (Conversation_Value__c[]) scope;
        try {
            insert convList;
        } catch (Exception ex){
            CMN_UTIL_Logger.error(ex, 'PbbSmart2ConversationPicklistSyncBatch.execute');
        }
    }
    /**
    * @description This is Finish Method for a batch Job
    * @param	bc Database.BatchableContext of the Apex batch
    **/
    global void finish(Database.BatchableContext bc) {}
}