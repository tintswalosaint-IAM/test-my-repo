/**
 * @description CMN_DAL_CronTrigger class provides base methods and example of how to use
 * the CMN_DAL_CronTrigger methods.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_DAL_CronTrigger {
  /**
   * @description This method is use to return the list of CronTrigger
   *
   * @param cronIds as input
   *
   * @return List
   */
  private static List<CronTrigger> findById(Set<Id> cronIds) {
    return [
      SELECT
        CronExpression,
        CronJobDetailId,
        EndTime,
        Id,
        NextFireTime,
        PreviousFireTime,
        StartTime,
        State,
        TimesTriggered
      FROM CronTrigger
      WHERE Id IN :cronIds
    ];
  }

  /**
   * @description This method is use to return the Cron Trigger Id
   *
   * @param cronId as input
   *
   * @return List
   */
  public static CronTrigger findById(Id cronId) {
    List<CronTrigger> cronTriggers = findById(new Set<Id>{ cronId });

    return cronTriggers.isEmpty() ? null : cronTriggers[0];
  }
}