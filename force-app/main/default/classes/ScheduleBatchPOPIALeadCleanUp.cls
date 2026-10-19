/**
* @description This class is a scheduled batch job that deletes records from the Lead objects.
* @author Mthandeni Gumede
* @date  24/22/2023
*/ 
public class ScheduleBatchPOPIALeadCleanUp implements Database.Batchable<sObject> ,Schedulable {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ScheduleBatchPOPIALeadCleanUp');
    private static final String CRON = '0 0 0 ? * * *'; // 0:00PM every day
    @TestVisible
    private static final String JOB_NAME = 'DeleteExpiredLeadRecords';
    
  /**
   * @description It creates a new instance of the batch job and calls the execute method.
   * @param sc
   */
    public void execute(SchedulableContext sc) {
        ScheduleBatchPOPIALeadCleanUp batchJob = new ScheduleBatchPOPIALeadCleanUp();
        Database.executeBatch(batchJob);
    }
    
      /**
   * @description Retrieves the records to be processed.
   * @param bc
   * @return Database.QueryLocator 
   */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Lead WHERE (Status = 'Qualified' OR Status = 'Unqualified') AND DR_Retain_Until_Date__c <= TODAY
                                         AND CreatedBy.Country='South Africa']);
    }
    
  /**
   * @description It deletes the records in the scope list.
   * @param scope
   */
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        try { 
            Database.delete(scope);
        } catch (DmlException e) {
            LOGGER.debug('Deleting Retention Record :'+LoggingLevel.ERROR +' '+ e.getMessage());
        }
    }
    
  /**
   * @description
   * @param bc
   */
    public void finish(Database.BatchableContext bc) {
        
    }
    
    /**
   * @description It used to unschedule the batch class ScheduleBatchPOPIALeadCleanUp
   */
    public static void unschedule() {
        CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME LIMIT 1];
        System.abortJob(ct.Id);
    }
    
   /**
   * @description It used to schedule the batch class ScheduleBatchPOPIALeadCleanUp
   */
    public static void schedule() {
        ScheduleBatchPOPIALeadCleanUp batchToSchedule = new ScheduleBatchPOPIALeadCleanUp();
        System.schedule(JOB_NAME, CRON, batchToSchedule);
    }
}