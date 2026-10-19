/**
 * @description : Schedulable class to enqueue KYC_SRV_DocUploadQueueable after delay
 * @author      : Irshad Alam
 */
public with sharing class KYC_SRV_DocUploadScheduler implements Schedulable {

    private FINAL Id partyProfileId;
    private FINAL List<Id> contentDocumentIds;

    public KYC_SRV_DocUploadScheduler(Id partyProfileId, List<Id> contentDocumentIds) {
        this.partyProfileId = partyProfileId;
        this.contentDocumentIds = contentDocumentIds;
    }

    public void execute(SchedulableContext sc) {
        System.enqueueJob(
            new KYC_SRV_DocUploadQueueable(partyProfileId, contentDocumentIds)
        );
    }

    public static void scheduleAfter5Minutes(Id partyProfileId, List<Id> contentDocumentIds) {

        Datetime runAt = System.now().addMinutes(5);

        String cron = buildCron(runAt);

        String jobName = 'KYC_DocUploadRetry_' + partyProfileId + '_' + Datetime.now().getTime();

        System.schedule(
            jobName,
            cron,
            new KYC_SRV_DocUploadScheduler(partyProfileId, contentDocumentIds)
        );
    }

    // Build cron expression for a specific datetime
    private static String buildCron(Datetime dt) {
        return String.format(
            '{0} {1} {2} {3} {4} ? {5}',
            new List<String>{
                String.valueOf(dt.second()),
                String.valueOf(dt.minute()),
                String.valueOf(dt.hour()),
                String.valueOf(dt.day()),
                String.valueOf(dt.month()),
                String.valueOf(dt.year())
            }
        );
    }
}