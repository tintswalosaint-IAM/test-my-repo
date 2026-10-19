/**
 * @description This Schedule class is for PbbSmart2ConversionalPicklistDel
 *
 * @author		Sandile mathe
 * @date	    April 2021
*/
public without sharing class PbbSmart2ConversionalPicklistDel_Sched implements Schedulable, Database.AllowsCallouts {

    private static final String CRON = '0 13 2 ? * * *'; // 2:13AM every day
    @TestVisible
    private static final String JOB_NAME = 'Daily Refreshing Conversation Values';

	/**
    * @description This is execute method for this class to Schedule a Batch job
    * 
    * @param	sc SchedulableContext
    **/ 
    public void execute(SchedulableContext sc) { 
      PbbSmart2ConversionalPicklistDel bc = new PbbSmart2ConversionalPicklistDel(); 
      Database.executebatch(bc);
   }

    /**
    * @description This method schedules the job with the prepared properties
    */
   public static void scheduleMe() {
       PbbSmart2ConversionalPicklistDel_Sched batchToSchedule = new PbbSmart2ConversionalPicklistDel_Sched();
       System.schedule(JOB_NAME, CRON, batchToSchedule);
   }

    /**
    * @description This method unchedules the job
    */
   public static void unscheduleMe() {
       CronTrigger ct = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :JOB_NAME LIMIT 1];
       System.abortJob(ct.Id);
   }
}