/**
 * @description This Queueable class handles the bulk Finscan operations.
 * It allows callouts and is used to perform asynchronous processing of client updates or screenings.
 * @implements Queueable, Database.AllowsCallouts
 * @usage
 * This class can be enqueued using System.enqueueJob to handle bulk operations.
 */
public class ICS_QUE_Finscan implements Queueable, Database.AllowsCallouts {

    /**
     * @description List of applicationForm IDs to be processed.
     */
    final private List<String> applicationFormIds;

    /**
     * @description List of account IDs to be processed.
     */
    final private List<String> accountIds;

    /**
     * @description The decision type for the update (onboarded/cancelled).
     */
    final private String decision;

    /**
     * @description Constructor for ICS_QUE_Finscan.
     * Initializes the applicationFormIds and decision parameters.
     * @param applicationFormIds The list of applicationForm IDs to be processed.
     */
    public ICS_QUE_Finscan(List<String> applicationFormIds) {
        this.applicationFormIds = applicationFormIds;
        this.accountIds = null;
        this.decision = null;
    }

    /**
     * @description Constructor for ICS_QUE_Finscan.
     * Initializes the accountIds and decision parameters.
     * @param accountIds The list of account IDs to be updated.
     * @param decision The decision type for the update (onboarded/cancelled).
     */
    public ICS_QUE_Finscan(List<String> accountIds, String decision) {
        this.applicationFormIds = null;
        this.accountIds = accountIds;
        this.decision = decision;
    }

    /**
     * @description Executes the Queueable job.
     * This method is called by the system when the job is executed.
     * It delegates the client update or screening logic based on the initialized parameters.
     * @param context The QueueableContext object.
     */
    public void execute(QueueableContext context) {
        if (applicationFormIds != null) {
            for (String applicationFormId : applicationFormIds) {
                ICS_CTRL_Finscan.screenApplication(applicationFormId);
            }
            return;
        }
        if (decision != null) {
            ICS_CTRL_Finscan.updateClient(accountIds, decision);
        }
    }
}