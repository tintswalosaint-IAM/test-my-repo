/**
 * @description CMN_DAL_JobSchedule class provides base methods and example of how to use
 * the CMN_DAL_JobSchedule methods.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_JobSchedule {
  /**
   * @description This method is use to get the list of CMN_JobScheduler__c
   *
   * @param scheduleIds as input
   *
   * @return List
   */
  private static List<CMN_JobScheduler__c> findById(Set<Id> scheduleIds) {
    return [
      SELECT
        CMN_Active__c,
        CMN_CronExpression__c,
        CMN_Description__c,
        CMN_ScheduleClassName__c,
        CMN_SchedulerName__c,
        CMN_JobName__c,
        CMN_ScheduledJobId__c,
        Id,
        Name
      FROM CMN_JobScheduler__c
      WHERE Id IN :scheduleIds
    ];
  }

  /**
   * @description find by id utility function for testing
   *
   * @param scheduleId as input
   *
   * @return test result
   */
  @TestVisible
  private static CMN_JobScheduler__c findById(Id scheduleId) {
    List<CMN_JobScheduler__c> schedulers = findById(new Set<Id>{ scheduleId });

    return schedulers.isEmpty() ? null : schedulers[0];
  }
}