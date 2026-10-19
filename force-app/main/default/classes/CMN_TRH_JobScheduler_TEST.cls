/**
 * @description CMN_TRH_JobScheduler_TEST (Common Test Trigger Handler Job Schedule Manager)
 * 				runs the testing scenarios of creating meta data (schedule) and creating and updating a scheduler record
 * 				which will trigger (start) and stop the scheduled activity.
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_TRH_JobScheduler_TEST {
  private static final String NO_EXCEPTION_WAS_THROWN_AS_EXPECTED = 'No exception was thrown as expected';
  private static final String ERROR_WAS_THROWN_AS_EXPECTED = 'Error was thrown as expected';

  /**
   * @description To test the scenario when the scheduler job start
   */
  @IsTest
  private static void start() {
    Test.startTest();

    CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(
      CMN_SCHED_Foobar.class.getName()
    );

    scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

    System.assertNotEquals(
      null,
      scheduler.CMN_ScheduledJobId__c,
      'Scheduled Job was not started'
    );

    Test.stopTest();
  }

  /**
   * @description To test the scenario when the scheduler job stop
   */
  @IsTest
  private static void stopSchedule() {
    Test.startTest();

    CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(
      CMN_SCHED_Foobar.class.getName()
    );

    scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

    System.assertNotEquals(
      null,
      scheduler.CMN_ScheduledJobId__c,
      'Scheduled Job was not started'
    );

    scheduler.CMN_Active__c = false;

    CMN_DAL_SObjectDomain.updateDBObject(scheduler);

    scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

    System.assertEquals(
      null,
      scheduler.CMN_ScheduledJobId__c,
      'Scheduled Job was not aborted'
    );

    Test.stopTest();
  }

  /**
   * @description To test the scenario when abort scheduler job
   */
  @IsTest
  private static void stopScheduleWhenNotRunning() {
    Test.startTest();

    CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(
      CMN_SCHED_Foobar.class.getName()
    );

    scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

    System.abortJob(scheduler.CMN_ScheduledJobId__c);

    scheduler.CMN_Active__c = false;

    try {
      CMN_DAL_SObjectDomain.updateDBObject(scheduler);
      System.assert(true, 'No Error was thrown');
    } catch (Exception error) {
      System.assert(false, 'Error was thrown and should have been squashed');
    }

    Test.stopTest();
  }

  /**
   * @description To test the scenario when delete scheduler job
   */
  @IsTest
  private static void deleteSchedule() {
    Test.startTest();

    CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler(
      CMN_SCHED_Foobar.class.getName()
    );

    scheduler = CMN_DAL_JobSchedule.findById(scheduler.Id);

    CMN_DAL_SObjectDomain.deleteDBObject(scheduler);

    CronTrigger job = CMN_DAL_CronTrigger.findById(
      scheduler.CMN_ScheduledJobId__c
    );

    System.assertEquals(null, job, 'Scheduled Job was not aborted');

    Test.stopTest();
  }

  /**
   * @description To test the exception when using invalid class
   */
  @IsTest
  private static void startScheduleInvalidClassName() {
    try {
      Test.startTest();

      CMN_DAL_DataFactory.insertJobScheduler(
        CMN_DAL_SObjectDomain.generateRandomName()
      );

      Test.stopTest();

      System.assert(false, NO_EXCEPTION_WAS_THROWN_AS_EXPECTED);
    } catch (Exception error) {
      System.assert(true, ERROR_WAS_THROWN_AS_EXPECTED);
    }
  }

  @IsTest
  private static void startScheduleInvalidClassType() {
    try {
      Test.startTest();

      CMN_DAL_DataFactory.insertJobScheduler(
        CMN_TRH_JobScheduler.class.getName()
      );

      Test.stopTest();

      System.assert(false, NO_EXCEPTION_WAS_THROWN_AS_EXPECTED);
    } catch (Exception error) {
      System.assert(true, ERROR_WAS_THROWN_AS_EXPECTED);
    }
  }

  @IsTest
  private static void saveScheduleInvalidCron() {
    try {
      Test.startTest();

      CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.newJobScheduler(
        CMN_SCHED_Foobar.class.getName()
      );
      scheduler.CMN_CronExpression__c = CMN_DAL_SObjectDomain.generateRandomName();

      insert scheduler;

      Test.stopTest();

      System.assert(false, NO_EXCEPTION_WAS_THROWN_AS_EXPECTED);
    } catch (Exception error) {
      System.assert(true, ERROR_WAS_THROWN_AS_EXPECTED);
    }
  }
}