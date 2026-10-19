/**
 * @description public class to as part of post copy framework to process workers
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
global class CMN_FACTORY_SPC_Worker implements SandboxPostCopy {
  private static String ERROR_NO_TYPE_FOUND = 'No Type found for: ';
  private static String ERROR_NOT_AN_INSTANCE = ' is not an instance of CMN_SPC_BaseWorker';
  @TestVisible
  private static String workClassNameForTests = CMN_UTIL_String.EMPTY;

  /**
   * @description Exception used by Post Copy Worker Factory when attempting to execute workers
   */
  public class WorkFactoryException extends Exception {
  }

  /**
   * @description Implements the required method for the SandboxPostCopy interface. It will retrieve all the configured worker tasks and enqueue them
   *
   * @param context The org ID, sandbox ID, and sandbox name for your sandbox. To work with these values, reference context.organizationId(), context.sandboxId(), and context.sandboxName() in your code.
   */
  global void runApexClass(SandboxContext context) {
    List<CMN_SPC_BaseWorker> workerList = CMN_FACTORY_SPC_Worker.getAll();

    for (CMN_SPC_BaseWorker worker : workerList) {
      if (worker != null) {
        worker.context = context;
        System.enqueueJob(worker);
      }
    }
  }

  /**
   * @description queries relevant post copy task metadata for a list of worker
   *
   * @return a list of instantiated work objects
   */
  private static List<CMN_SPC_BaseWorker> getAll() {
    List<CMN_PostCopyTask__mdt> postCopyTasks = CMN_DAL_PostCopyTask.getAll();

    return getWorkerListFromCustomMetaDataTypes(postCopyTasks);
  }

  /**
   * @description This method is use to get the list of Metadata Types from the post copy mdt
   *
   * @param taskList a list of all post copy task definitions (CMN_PostCopyTask__mdt)
   *
   * @return a list of instantiated work objects
   */
  private static List<CMN_SPC_BaseWorker> getWorkerListFromCustomMetaDataTypes(
    List<CMN_PostCopyTask__mdt> taskList
  ) {
    List<CMN_SPC_BaseWorker> workerList = new List<CMN_SPC_BaseWorker>();

    for (CMN_PostCopyTask__mdt task : taskList) {
      String workerName = task.DeveloperName;
      CMN_SPC_BaseWorker worker = createWorkerObjectFromString(workerName);
      workerList.add(worker);
    }

    return workerList;
  }

  /**
   * @description This method is use to create a worker
   *
   * @param workerName the name of Post Copy Task from CMN_PostCopyTask__mdt
   *
   * @return A worker object
   */
  private static CMN_SPC_BaseWorker createWorkerObjectFromString(
    String workerName
  ) {
    CMN_SPC_BaseWorker workerReturn = null;

    if (Test.isRunningTest() && String.isNotBlank(workClassNameForTests)) {
      workerName = workClassNameForTests;
    }

    Type workerType = Type.forName(workerName);

    if (workerType == null) {
      throw new WorkFactoryException(ERROR_NO_TYPE_FOUND + workerName);
    }

    Object worker = workerType.newInstance();

    if (!(worker instanceof CMN_SPC_BaseWorker)) {
      throw new WorkFactoryException(workerName + ERROR_NOT_AN_INSTANCE);
    }

    workerReturn = (CMN_SPC_BaseWorker) worker;

    return workerReturn;
  }
}