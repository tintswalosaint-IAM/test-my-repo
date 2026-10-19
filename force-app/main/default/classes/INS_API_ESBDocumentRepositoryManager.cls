/**
 * ESB Implementation to send Files to FileNet
 * This is an implementation of DocumentManagement
 *
 * @author Dhiraj Prajapati
 */
public inherited sharing class INS_API_ESBDocumentRepositoryManager extends INS_UTIL_DocumentManagement {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ESB_Document_Repository_Manager');

    /**
     * This method will prepare the document and taxonomy attributes
     * @actions - fetch taxonomy record and update content version record
     * @return - API response object (DocumentInfo)
     */
    public override virtual INS_UTIL_DocumentInfo send() {
        INS_UTIL_DocumentManagementHelper sendDoc = new INS_UTIL_DocumentManagementHelper();
        //fetch the taxonomy record from custom meta data
        INS_UTIL_Taxonomy taxOnRec = sendDoc.getTaxonomy(this.file.getDocumentTypeId());
        //structure payload

        String payLoad = sendDoc.getPayLoad(this.file, taxOnRec);
       
        INS_UTIL_DocumentResponse documentResponse = this.registerDocument(payLoad);

        if(String.isNotBlank(documentResponse.getDocumentId())) {
            try {
                ContentVersion cv = new ContentVersion(
                    Id = this.file.getContentVersionId(),
                    INS_Document_Link__c = documentResponse.getDocumentId());

                if (Schema.sObjectType.ContentVersion.isUpdateable()){
                    update cv;
                }   
                else{
                    Throw new IllegalArgumentException('You do not have the necessary permission to update files.');
                }
            }
            catch (DmlException ex) {
                LOGGER.error('ESBDocumentRepositoryManager | documentInfo | file update | ' + ex.getMessage());
            }
        }
        else {
            LOGGER.error('ESBDocumentRepositoryManager | send | document response | ' +  documentResponse.getErrorInfo());
        }

        return new INS_UTIL_DocumentInfo(
            documentResponse.getDocumentId(),
            documentResponse.getErrorInfo()
        );
    }

     /**
     * This method will make an API call out to the customer service and store the response
     * @actions - fetch taxonomy record and update content version record
     * @param - payload in string format
     * @return - API response object (DocumentInfo)
     */
    public INS_UTIL_DocumentResponse registerDocument(String payLoad) {
        INS_UTIL_DocumentResponse response = new INS_UTIL_DocumentResponse();
        try {
            CMN_DocUpload_API customerServiceCall = new CMN_DocUpload_API(payLoad);
            //Process the web service with the prepared api payload
            customerServiceCall.process(CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_DocUpload_API.SERVICE_NAME));
            response = (INS_UTIL_DocumentResponse) JSON.deserialize(customerServiceCall.getResponseBody(), INS_UTIL_DocumentResponse.class);
        }
        catch (Exception ex) {
            LOGGER.error('ESBDocumentRepositoryManager | registerDocument | exception | ' + ex.getMessage());
        }
        return response;
    }
}