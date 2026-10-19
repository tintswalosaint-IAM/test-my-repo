/**
 * @description Invocable Apex action to update the RelatedRecordId field on a VoiceCall record.
 *              Replaces the flow Record Update element, which is not supported for VoiceCall
 *              by the platform's internal Unit of Work. Uses ORG_Application.unitOfWork to perform
 *              the DML in alignment with the fflib enterprise pattern.
 * @see SVC_UpdateVoiceCallRelatedRecord_TEST
 * @author Raymond Magezi
 * @date July-02-2026
 */
public inherited sharing class SVC_UpdateVoiceCallRelatedRecord {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_UpdateVoiceCallRelatedRecord');
    private static final String CLASS_NAME = 'Class: SVC_UpdateVoiceCallRelatedRecord';
    private static final String METHOD_UPDATE = 'Method: updateVoiceCallRelatedRecord';

    /**
     * @description Private constructor to prevent instantiation.
     *              All methods are static; this constructor silences the CodeScan S1118 warning.
     */
    @TestVisible
    private SVC_UpdateVoiceCallRelatedRecord() {}

    /**
     * @description Invocable method called from the SVC_CaseManualCaseCreation flow to link a
     *              VoiceCall record to a Case by setting the RelatedRecordId field.
     *              Requests with blank voiceCallId or caseId are silently skipped.
     * @param requests List of VoiceCallRequest instances supplied by the flow
     */
    @InvocableMethod(label='Update VoiceCall Related Record' description='Updates the RelatedRecordId on a VoiceCall record')
    public static void updateVoiceCallRelatedRecord(List<VoiceCallRequest> requests) {
        try {
            List<VoiceCall> voiceCallsToUpdate = new List<VoiceCall>();

            for (VoiceCallRequest request : requests) {
                if (String.isNotBlank(request.voiceCallId) && String.isNotBlank(request.caseId)) {
                    voiceCallsToUpdate.add(new VoiceCall(
                        Id = request.voiceCallId,
                        RelatedRecordId = request.caseId
                    ));
                }
            }

            if (!voiceCallsToUpdate.isEmpty()) {
                sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
                for (VoiceCall record : voiceCallsToUpdate) {
                    uow.registerDirty(record);
                }
                uow.commitWork();
            }
        } catch (Exception e) {
            LOGGER.error(e.getMessage(), new String[] {CLASS_NAME, METHOD_UPDATE}, e);
            throw e;
        }
    }

    /**
     * @description Input wrapper class for the updateVoiceCallRelatedRecord invocable method.
     *              Each instance represents a single VoiceCall-to-Case linking request
     *              passed in from the flow.
     */
    public class VoiceCallRequest {
        /**
         * @description Salesforce record Id of the VoiceCall to update
         */
        @InvocableVariable(label='VoiceCall Record Id' required=true)
        public String voiceCallId;

        /**
         * @description Salesforce record Id of the Case to link to the VoiceCall
         */
        @InvocableVariable(label='Case Record Id' required=true)
        public String caseId;
    }
}