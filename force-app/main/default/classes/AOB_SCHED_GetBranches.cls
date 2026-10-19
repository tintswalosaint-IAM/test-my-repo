/**
 * @description AOB_SCHED_GetBranches used for updating Branches values from API
 *
 * <p></p>
 *
 * @author Salesforce
 *
 * @date 2020
 */
public inherited sharing class AOB_SCHED_GetBranches implements Schedulable,Database.AllowsCallouts {
  /**
   * @description execute the schedulable job override method implementation of schedulable
   *
   * @param context as input
   */
  public void execute(SchedulableContext context) {
    string accessToken;

    try {
      accessToken = AOB_SRV_Branches.callGetToken();
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, 'AOB_SCHED_GetBranches.callGetToken');
    }

    ID jobID;
    try {
      jobID = System.enqueueJob(new AOB_QUEUE_GetBranches(accessToken));
    } catch (Exception error) {
      CMN_UTIL_Logger.error(
        error,
        'AOB_SCHED_GetBranches.callGetBranches Queuable ' + jobID
      );
    }
  }
}