/**
 * @description (Common Trigger Handler Job Schedule Manager)
 * 				runs a scheduled class based on cron provided
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
public inherited sharing class CMN_TRH_JobScheduler extends CMN_TRH_BaseObject {
  public override void beforeInsert(SObject so) {
    super.beforeInsert(so);

    startStopJob((CMN_JobScheduler__c) so);
  }

  public override void beforeUpdate(SObject oldSo, SObject so) {
    super.beforeUpdate(oldSo, so);

    startStopJob((CMN_JobScheduler__c) so);
  }

  public override void beforeDelete(SObject so) {
    super.beforeDelete(so);

    stopJob((CMN_JobScheduler__c) so);
  }

  private void startStopJob(CMN_JobScheduler__c scheduler) {
    if (scheduler.CMN_Active__c) {
      startJob(scheduler);
    } else {
      stopJob(scheduler);
    }
  }

  /**
   * @description startJob starts the scheduled job
   *
   * @param newSchedule record input
   */
  private void startJob(CMN_JobScheduler__c newSchedule) {
    //First abort existing job, if one exists before applying updates
    stopJob(newSchedule);

    Type schedulerType = Type.forName(newSchedule.CMN_ScheduleClassName__c);

    if (schedulerType != null) {
      Object newObject = schedulerType.newInstance();

      if (newObject instanceof Schedulable) {
        try {
          newSchedule.CMN_ScheduledJobId__c = System.schedule(
            newSchedule.CMN_JobName__c,
            newSchedule.CMN_CronExpression__c,
            (Schedulable) newObject
          );
        } catch (Exception error) {
          //If we get an error thrown, the most likely issue is due to the cron expression
          newSchedule.CMN_CronExpression__c.addError(error.getMessage());
        }
      } else {
        newSchedule.CMN_ScheduleClassName__c.addError(
          '"' +
          newSchedule.CMN_ScheduleClassName__c +
          '" does not support the Schedulable Interface'
        );
      }
    } else {
      newSchedule.CMN_ScheduleClassName__c.addError(
        'Class "' +
        newSchedule.CMN_ScheduleClassName__c +
        '"  does not exist'
      );
    }
  }

  /**
   * @description stopJob stops the specified Job_Scheduler
   *
   * @param newScheduler record as input
   */
  private void stopJob(CMN_JobScheduler__c newScheduler) {
    if (
      String.isNotBlank(newScheduler.CMN_ScheduledJobId__c) && !Trigger.isInsert
    ) {
      try {
        System.abortJob(newScheduler.CMN_ScheduledJobId__c);
      } catch (Exception error) {
        // Aborting a job may fail because the schedule was manually aborted; do nothing.
        CMN_UTIL_Logger.error(error, 'CMN_TRH_JobScheduler.stopJob');
      }
    }

    if (!Trigger.isDelete) {
      newScheduler.CMN_ScheduledJobId__c = null;
    }
  }

  public override Boolean allowNonSelfInitiated() {
    return !super.allowNonSelfInitiated();
  }

  public override Boolean allowRecursion() {
    return !super.allowRecursion();
  }
}