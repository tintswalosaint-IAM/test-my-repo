/**
 * @description This is batch class that deletes unsynced Files with filenet asynchronously
 *
 * <p>DBP-2291</p>
 *
 * @author Salesforce
 *
 * @date 2021
 */
public inherited sharing class DOC_BATCH_DocumentCleanUp implements Database.Batchable<SObject>, Database.Stateful, Database.AllowsCallouts {
  /**
   * @description Start method of batch class
   *
   * @param context as input
   *
   * @return iterable result
   */
  public Database.QueryLocator start(Database.BatchableContext BC) {
    //here add a time interval createddate >= LAST_N_DAYS:1
    String query = 'SELECT Id, Name FROM DOC_Document__c where DOC_DocumentGUID__c !=null ';
    return Database.getQueryLocator(query);
  }

  /**
   * @description Execute method of batch class
   *
   * @param context as input
   * @param queueItems as input
   */
  public void execute(
    Database.BatchableContext context,
    List<DOC_Document__c> docItems
  ) {
    //Track the elements that have been deleted
    try {
      delete docItems;
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, 'DOC_BATCH_DocumentCleanUp');
    }
  }

  /**
   * @description Finish method of batch class
   *
   * @param context as input
   */
  public void finish(Database.BatchableContext context) {
  }
}