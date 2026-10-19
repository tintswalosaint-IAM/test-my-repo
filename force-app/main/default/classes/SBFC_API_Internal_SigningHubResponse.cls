/**
* @File Name : SBFC_API_Internal_SigningHubResponse.cls
* @Description : SFP-54443 - API Service call for REST Service to receieve Signed Document Details .
* @Author : Amlendu Bajpai
* @Last Modified By : Gul
* @Last Modified On : 07-09-2026
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | December 2, 2025 |   | Initial Version
* 2.0 | June 30 , 2026 | Amlendu Bajpai | Latest version
**/

/**
* @File Name : SBFC_API_Internal_SigningHubResponse.cls
* @Description : SigningHub callback handler
*/
public with sharing class SBFC_API_Internal_SigningHubResponse extends CMN_API_RestBaseInbound {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SBFC_API_Internal_SigningHubResponse');

    public static final String SERVICE_NAME = SBFC_API_Internal_SigningHubResponse.class.getName();

    private Boolean isProcessed = false;
    private Boolean isSignWorkflow = false;
    private Boolean isUploadflow = false;
    private String documentId = '';

    private InfoAuthorizationRequest infoAuthorizationRequest;

    /**
     * Initialise DTOs
     */
    protected override void initialise() {
        super.initialise();

        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }

    /**
     * Register SObject Types
     */
    protected override void setUnitOfWorksObjectTypes() {
        super.setUnitOfWorksObjectTypes();
    }

    /**
     * Process SigningHub callback
     */
    protected override void processRequest() {
        try {
            super.processRequest();
            DTO_Request dtoRequest = parseRequest();
            determineWorkflow(dtoRequest);
            if (isSignWorkflow) {
                if (!validateRequest(dtoRequest)) {
                	return;
                    }
                processSigningWorkflow(dtoRequest);
            }
        } catch (Exception ex) {
            LOGGER.ERROR(
                'SBFC_API_Internal_SigningHubResponse.processRequest',
                ex
            );
            throw ex;
        }
    }

    /**
     * Parse Request DTO
     */
    private DTO_Request parseRequest() {

        DTO_Request dtoRequest =
            (DTO_Request)JSON.deserialize(
                requestBody,
                DTO_Request.class
            );

        documentId = dtoRequest.documentId;

        return dtoRequest;
    }

    /**
     * Determine workflow based on client response
     */
    private void determineWorkflow(DTO_Request dtoRequest) {

        if (String.isBlank(dtoRequest.clientResponse)) {
            return;
        }

        isUploadflow =
            dtoRequest.clientResponse.equalsIgnoreCase('UPLOADED');

        isSignWorkflow =
            dtoRequest.clientResponse.equalsIgnoreCase('APPROVED')
            ||
            dtoRequest.clientResponse.equalsIgnoreCase('DECLINED');
    }

    /**
     * Validate Request DTO
     */
    private Boolean validateRequest(DTO_Request dtoRequest) {

        if (String.isBlank(dtoRequest.documentId)) {

            LOGGER.INFO(
                'SigningHub Callback : Document Id is blank.'
            );

            return false;
        }

        return true;
    }

    /**
     * Process Signing Workflow
     */
    private void processSigningWorkflow(DTO_Request dtoRequest) {

        if (!loadInfoAuthorizationRequest(dtoRequest.documentId)) {
            return;
        }

        updateInfoAuthorizationRequest(dtoRequest);

        uploadDocuments(dtoRequest);

        isProcessed = true;
    }

    /**
     * Load InfoAuthorizationRequest by Document Id
     */
    private Boolean loadInfoAuthorizationRequest(String documentId) {

        List<InfoAuthorizationRequest> requests =
            new SEL_InfoAuthorizationRequest()
                .selectBySignedDocNumber(documentId);

        if (requests.isEmpty()) {

            LOGGER.INFO(
                'SigningHub Callback : No InfoAuthorizationRequest found for Document Id : '
                + documentId
            );

            return false;
        }

        infoAuthorizationRequest = requests[0];

        return true;
    }

    /**
     * Update InfoAuthorizationRequest based on client response
     */
    private void updateInfoAuthorizationRequest(DTO_Request dtoRequest) {
        try{
        infoAuthorizationRequest.RequestedDateTime =
            System.now();

        infoAuthorizationRequest.ExpirationDateTime =
            System.now().addYears(1);

        infoAuthorizationRequest.ResponseStatus =
            dtoRequest.clientResponse.equalsIgnoreCase('APPROVED')
            ? 'Signed'
            : 'Rejected';

        sbgplatform.fflib_ISObjectUnitOfWork uow =
            ORG_Application.unitOfWork.newInstance();

        uow.registerDirty(infoAuthorizationRequest);

        uow.commitWork();
        } catch (Exception e) {
        LOGGER.error(e.getMessage(),new String[] { SBFC_API_Internal_SigningHubResponse.class.getName(),e.getMessage()},e );
    }
    }

    /**
     * Upload Signed Document and Audit Log
     */
    private void uploadDocuments(DTO_Request dtoRequest) {

        uploadDocument(
            infoAuthorizationRequest.Id,
            'Signed Disclosure Document',
            dtoRequest.signeddocContent
        );

        uploadDocument(
            infoAuthorizationRequest.Id,
            'SigningHub Audit Log',
            dtoRequest.auditLogContent
        );
    }

    /**
     * Upload Base64 PDF as Salesforce File
     */
    private void uploadDocument(Id parentId,String fileName,String content) {

        if (String.isBlank(content)) {
            return;
        }

        uploadPdfAsFile(
            parentId,
            fileName,
            content
        );
    }

    /**
     * Update Response DTO
     */
    @TestVisible
    protected override void updateResponseDTO() {

        super.updateResponseDTO();

        DTO_Response response = (DTO_Response)baseResponseDTO;

        if(isProcessed && infoAuthorizationRequest != null && isSignWorkflow){

            response.infoAuthorizationRequestId = infoAuthorizationRequest.Id;

            response.message = SBFC_Constants.SUCCESSFUL;

            response.statusCode = CMN_API_HttpBase.HTTP_OK;

        } else if(isUploadflow){
            response.message =SBFC_Constants.SUCCESSFUL;

            response.statusCode =CMN_API_HttpBase.HTTP_OK;
        }
        else{

            response.message = 'With '+documentId + ' '+
                SBFC_Constants.NO_APPLICATION;

            response.statusCode =
                CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR;

        }

    }

    /**
     * Upload Base64 PDF as Salesforce File
     */
    private static void uploadPdfAsFile(
        Id parentId,
        String fileName,
        String base64Data
    ){
        try{

        if(String.isBlank(base64Data)){
            return;
        }

        Blob pdfBlob;

        try{
            pdfBlob =
                EncodingUtil.base64Decode(base64Data);
        }
        catch(Exception e){

            LOGGER.ERROR('Unable to decode Base64 PDF : ' + fileName,e);

            return;
        }

        ContentVersion cv = new ContentVersion();

        cv.Title = fileName;
        cv.PathOnClient = fileName + '.pdf';
        cv.VersionData = pdfBlob;
        
        sbgplatform.fflib_ISObjectUnitOfWork uowcv = ORG_Application.unitOfWork.newInstance();
        uowcv.registerNew(cv);
        uowcv.commitWork();

        cv = new SEL_ContentVersion().selectContentVersionById(cv.id);
        
        ContentDocumentLink cdl =
            new ContentDocumentLink();

        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = cv.ContentDocumentId;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';

        sbgplatform.fflib_ISObjectUnitOfWork uowcdl = ORG_Application.unitOfWork.newInstance();
        uowcdl.registerNew(cdl);
        uowcdl.commitWork();

        FeedItem post = new FeedItem(
            ParentId=parentId,
            Body = fileName,
            RelatedRecordId = cv.Id,
            Type='ContentPost'
        );
        sbgplatform.fflib_ISObjectUnitOfWork uowpost = ORG_Application.unitOfWork.newInstance();
        uowpost.registerNew(post);
        uowpost.commitWork();
        } catch (Exception e) {
        LOGGER.error(e.getMessage(),new String[] { SBFC_API_Internal_SigningHubResponse.class.getName(),e.getMessage()},e );
    }

    }
        /**
     * Custom Exception
     */
    public class SBFC_API_Internal_SigningHubResponseException extends Exception {}

    /**
     * Request DTO
     */
    public class DTO_Request extends CMN_DTO_JsonBase {

        /**
         * Existing SigningHub fields
         */
        public String packageId;
        public String documentId;
        public String clientResponse;
        public String strAddtionalComments;

        /**
         * Base64 PDFs
         */
        public String signeddocContent;
        public String auditLogContent;

        /**
         * Existing DTOs (kept for backward compatibility)
         */
        public List<SBFC_DTO_Signinghub.DTO_UploadDocumentResponses> uploadDocumentResponses;

        public SBFC_DTO_Signinghub.DTO_AddSignerToWorkFlowResponse addSignerToWorkFlowResponse;

        public List<SBFC_DTO_Signinghub.DTO_ShareDocumentResponses> shareDocumentResponses;

        protected override Type getObjectType() {
        return DTO_Request.class;
    }

    }

    /**
     * Response DTO
     */
    public class DTO_Response extends CMN_DTO_JsonBase {

        public String infoAuthorizationRequestId;
        public String message;
        public Integer statusCode;

        protected override Type getObjectType() {
        return DTO_Response.class;
    }

    }
}