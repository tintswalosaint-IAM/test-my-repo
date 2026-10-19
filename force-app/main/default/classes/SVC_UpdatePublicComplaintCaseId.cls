/**
 * @description Invocable Apex action to update the ComplaintCaseId field on a PublicComplaint record.
 *              Replaces the flow Record Update element, which is not supported for PublicComplaint
 *              by the platform's internal Unit of Work. Uses ORG_Application.unitOfWork to perform
 *              the DML in alignment with the fflib enterprise pattern.
 * @see SVC_UpdatePublicComplaintCaseId_TEST
 * @author Raymond Magezi
 * @date July-02-2026
 */
public inherited sharing class SVC_UpdatePublicComplaintCaseId {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SVC_UpdatePublicComplaintCaseId');
    private static final String CLASS_NAME = 'Class: SVC_UpdatePublicComplaintCaseId';
    private static final String METHOD_UPDATE = 'Method: updatePublicComplaintCaseId';

    /**
     * @description Private constructor to prevent instantiation.
     *              All methods are static; this constructor silences the CodeScan S1118 warning.
     */
    @TestVisible
    private SVC_UpdatePublicComplaintCaseId() {}

    /**
     * @description Invocable method called from the SVC_CaseManualCaseCreation flow to link a
     *              PublicComplaint record to a Case by setting the ComplaintCaseId field.
     *              Requests with blank publicComplaintId or caseId are silently skipped.
     * @param requests List of PublicComplaintRequest instances supplied by the flow
     */
    @InvocableMethod(label='Update PublicComplaint Case Id' description='Updates the ComplaintCaseId on a PublicComplaint record')
    public static void updatePublicComplaintCaseId(List<PublicComplaintRequest> requests) {
        try {
            List<PublicComplaint> recordsToUpdate = new List<PublicComplaint>();

            for (PublicComplaintRequest request : requests) {
                if (String.isNotBlank(request.publicComplaintId) && String.isNotBlank(request.caseId)) {
                    recordsToUpdate.add(new PublicComplaint(
                        Id = request.publicComplaintId,
                        ComplaintCaseId = request.caseId
                    ));
                }
            }

            if (!recordsToUpdate.isEmpty()) {
                sbgplatform.fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
                for (PublicComplaint record : recordsToUpdate) {
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
     * @description Input wrapper class for the updatePublicComplaintCaseId invocable method.
     *              Each instance represents a single PublicComplaint-to-Case linking request
     *              passed in from the flow.
     */
    public class PublicComplaintRequest {
        /**
         * @description Salesforce record Id of the PublicComplaint to update
         */
        @InvocableVariable(label='PublicComplaint Record Id' required=true)
        public String publicComplaintId;

        /**
         * @description Salesforce record Id of the Case to link to the PublicComplaint
         */
        @InvocableVariable(label='Case Record Id' required=true)
        public String caseId;
    }
}