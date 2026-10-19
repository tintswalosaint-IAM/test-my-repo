/**
 * @description Test class to as part of post copy framework test the post copy interface
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false)
private class CMN_FACTORY_SPC_Worker_TEST {
  /**
   * @description This method tests the runApexClass as part of the post copy interface
   */
  @IsTest
  private static void runPostCopy() {
    Test.startTest();

    runPostCopyWorkers();

    Test.stopTest();
  }

  /**
   * @description Will check the behaviour when the worker class name configured in metadata is not a valid type
   */
  @IsTest
  private static void invalidWorkerTypeName() {
    CMN_FACTORY_SPC_Worker.workClassNameForTests = CMN_DAL_SObjectDomain.generateRandomName();

    Test.startTest();

    try {
      runPostCopyWorkers();
      System.assert(false, 'Error not thrown');
    } catch (Exception error) {
      System.assert(true, 'Exception thrown as expected');
    }

    Test.stopTest();
  }

  /**
   * @description Will check the behaviour when the worker class name configured in metadata is not of type CMN_SPC_BaseWorker
   */
  @IsTest
  private static void invalidWorkClass() {
    CMN_FACTORY_SPC_Worker.workClassNameForTests = CMN_SCHED_Foobar.class
      .getName();

    try {
      runPostCopyWorkers();
      System.assert(false, 'Error not thrown');
    } catch (Exception error) {
      System.assert(true, 'Exception thrown as expected');
    }
  }

  /**
   * @description setups the worker factory and executes SandboxPostCopyScript process
   */
  private static void runPostCopyWorkers() {
    Test.testSandboxPostCopyScript(
      new CMN_FACTORY_SPC_Worker(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationId(),
      UserInfo.getOrganizationName()
    );
  }
}