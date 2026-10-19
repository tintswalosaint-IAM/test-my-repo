/**
 * @description             : KYC_SRV_DocUploadQueueable queable class to upload documents to RelyComply.
 * @story                   : SFP-52092
 * @author                  : Irshad Alam
 * @created date            : 13/08/2025
 */
public with sharing class KYC_SRV_DocUploadQueueable implements Queueable, Database.AllowsCallouts {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('KYC_SRV_DocUploadQueueable');
	
	private Id partyProfileId;
    private List<Id> contentDocumentIds;
    private Integer attempt;
    private static final Integer MAX_RETRIES = 3;
    private static final Integer RETRY_DELAY_MINUTES = 5;

 

    public KYC_SRV_DocUploadQueueable(Id partyProfileId, List<Id> contentDocumentIds) {
        this.partyProfileId = partyProfileId;
        this.contentDocumentIds = contentDocumentIds;
       
    }

    public void execute(QueueableContext qc) {
         List<Id> failedDocs = new List<Id>();
        // Make one callout per document
        for (Id cdId : contentDocumentIds) {
            try {
                KYC_SRV_CallDocUpload.callDocUploadService(partyProfileId, cdId);
            } catch (Exception ex) {
                System.debug('Doc upload failed for ' + cdId + ': ' + ex.getMessage());
                // log and continue so one failure doesn't block others
                LOGGER.error('Doc upload failed for ' + cdId + ': ' + ex.getMessage(), 'Error occurred in execute method of queueable');

            }
        }


    }

}