/**
 * @description Post Copy framework Base class
 * <p/>
 * <p>VCCC-378</p>
 *
 * @author Accenture
 *
 * @date 2020
 */
public abstract class CMN_SPC_BaseWorker implements Queueable {
  private static final Integer SANDBOX_NAME_LENGTH = 10;

  /**
   * @description The SandBoxContext provided to the Worker during the Post Copy Process;
   * please NOTE in unit test where the worker class is run directly, this will be initialised with a mock sandbox context
   */
  public SandboxContext context {
    get {
      if (context == null) {
        context = new SPC_MockSandboxContext();
      }
      return context;
    }
    set;
  }

  /**
   * @description Allows this class to be queued and will execute the run method asynchronously
   *
   * @param context Contains the job ID.
   */

  public void execute(QueueableContext context) {
    run();
  }

  /**
   * @description The main entry point for executing the actions of a post copy worker
   * can be called directly or executing asynchronously via Execute and Queueable interface
   */
  public void run() {
    try {
      internalRun();
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, 'CMN_SPC_BaseWorker.run');
    }
  }

  /**
   * @description Override this method in descendant class to implement the actions that the Post Copy Worker will do
   */
  protected abstract void internalRun();

  /**
   * @description This class mocks the SandboxContext that would be provided for testing in the event that the BaseWorker code is called directly
   */
  public class SPC_MockSandboxContext implements SandboxContext {
    public Id organizationId() {
      return UserInfo.getOrganizationId();
    }

    public Id sandboxId() {
      return UserInfo.getOrganizationId();
    }

    public String sandboxName() {
      return CMN_UTIL_Random.randomAlphabetic(SANDBOX_NAME_LENGTH);
    }
  }
}