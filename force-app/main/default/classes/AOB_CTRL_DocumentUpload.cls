/**
 * Controller of lwc: aob_comp_documentUpload
 *
 * <p>DBP-1467</p>
 *
 * @author Achraf ABOUL (aaboul@salesforce.com)
 *
 * @date Dec 18th 2020
 */
public with sharing class AOB_CTRL_DocumentUpload {
  public static final String SERVICE_NAME = AOB_CTRL_DocumentUpload.class
    .getName();

  /**
   * Method used to call API to get an access token to be able to call APIs
   * @return	String
   */
  @auraEnabled
  public static String callAccessToken() {
    try {
      return AOB_SRV_OpenApplications.callGetToken();
    } catch (Exception error) {
      CMN_UTIL_Logger.error(error, SERVICE_NAME + ':callAccessToken');
      throw new AuraHandledException(error.getMessage());
    }
  }
  /**
   * Method used to create a case when the customer choose to skip uploading documents
   * @param	applicationId application Id
   */
  @auraEnabled
  public static void createCaseAfterSkip(Id applicationId) {
    Case documentsCase = DOC_SRV_Document.createDocumentsCase(applicationId);
  } 
  /**
   * Method returning the required documents to be uploaded
   * @param	token the token to authenticate to the findOpenApps API
   * @return	returns the required documents dto
   */
  @AuraEnabled
  public static String getDocumentsToUpload() {
    AOB_DTO_Documents documentsDTO = new AOB_DTO_Documents();
    try {
      String response = AOB_SRV_OpenApplications.callOpenApplications();
      Map<String, Object> jsonMAp = (Map<String, Object>) System.JSON.deserializeUntyped(
        response
      );
      if (jsonMAp.containskey('errorCode'))
        documentsDTO.errorCode = (Integer) jsonMAp.get('errorCode');
      if (jsonMAp.containskey('message'))
        documentsDTO.message = (String) jsonMAp.get('message');
      if (
        documentsDTO.errorCode != 50015 &&
        documentsDTO.errorCode != 50016 &&
        documentsDTO.errorCode != 50017 &&
        documentsDTO.errorCode != 50018 &&
        documentsDTO.errorCode != 50019 
      ) {
        Map<String, Object> offerItem = AOB_SRV_OpenApplications.getOfferFromFOA(
          response
        );
        List<Object> productConditionItems = AOB_SRV_OpenApplications.getConditionItems(
          offerItem
        );
        if (productConditionItems != null) {
          documentsDTO.documentsToUpload = AOB_SRV_OpenApplications.getDocumentsFromConditionItems(
            productConditionItems
          );
        }
      }
    } catch (Exception exc) {
      CMN_UTIL_Logger.error(exc, SERVICE_NAME + ':getDocumentsToUpload');
      throw exc;
    }
    return JSON.serialize(documentsDTO);
  }
  /**
   * Method uploading files and creating document records linked to application
   * @param	documentsString - String : documents json
   * @param   applicationId - Id: application Id related to the documents
   * @return	Number of documents uploaded
   */
  @AuraEnabled
  public static Integer uploadFiles(String documentsString, Id applicationId) {
    Savepoint sp;
    if (!Test.isRunningTest()) {
      sp = Database.setSavepoint();
    }
    try {
      List<DOC_Document__c> createdDocuments = DOC_SRV_Document.uploadDocuments(
        documentsString,
        applicationId
      );
      Case documentsCase = DOC_SRV_Document.createDocumentsCase(applicationId);
      DOC_SRV_Document.addDocumentsToCase(documentsCase.Id, createdDocuments);
      DOC_SRV_Document.assignCaseToQueue(
        'DOCUMENT',
        documentsCase.Id,
        applicationId
      );
      DOC_SRV_Document.createLegalOptionsCase(applicationId);
      return createdDocuments.size();
    } catch (Exception exc) {
      Database.rollback(sp);
      CMN_UTIL_Logger.error(exc, SERVICE_NAME + ':uploadFiles');
      throw exc;
    }
  }
}