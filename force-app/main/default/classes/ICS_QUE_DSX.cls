/**
 * @description This Queueable class handles the bulk Finscan operations.
 * It allows callouts and is used to perform asynchronous processing of client number updates in DSX
 * @implements Queueable, Database.AllowsCallouts
 * @usage
 * This class can be enqueued using System.enqueueJob to handle bulk operations.
 */
public class ICS_QUE_DSX implements Queueable, Database.AllowsCallouts {


 /**
     * @description Account IDs to be processed.
     */
    final private String accountId;
    
        /**
     * @description Client Number to be processed.
     */
    final private String clientNumber;

    /**
     * @description Sector Code to be processed.
     */
    final private String sectorCode;
    
    /**
     * @description Constructor for ICS_QUE_DSX.
     * @param accountId Account IDs to be processed.
     * @param clientNumber Client Number to be processed.
     * @param sectorCode Sector Code to be processed.
     */
    public ICS_QUE_DSX(String accountId, String clientNumber, String sectorCode) {
        this.accountId = accountId;
        this.clientNumber = clientNumber;
        this.sectorCode = sectorCode;
    }

    /**
     * @description Executes the Queueable job.
     * This method is called by the system when the job is executed.
     * @param context The QueueableContext object.
     */
    public void execute(QueueableContext context) {

        ICS_API_DSX.updateClientNumber(accountId,clientNumber, sectorCode);
        
    }
}